import { Router, type Request, type Response } from "express";
import { randomBytes } from "node:crypto";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { z } from "zod";
import { db } from "./db.js";
import { processCareReminders } from "./monitor.js";
import { allow, authenticate, requireApprovedDoctor, userId } from "./auth.js";

type UserRole = "PATIENT" | "CAREGIVER" | "DOCTOR";
type DoseStatus = "SCHEDULED" | "TAKEN" | "SNOOZED" | "SKIPPED" | "MISSED";
type AppointmentStatus = "REQUESTED" | "CONFIRMED" | "CANCELLED" | "COMPLETED";
const USER_ROLES = ["PATIENT", "CAREGIVER", "DOCTOR"] as const;
export const router = Router();
const auth = [authenticate];
const patientOnly = [authenticate, allow("PATIENT")];
const caregiverOnly = [authenticate, allow("CAREGIVER")];
const doctorOnly = [authenticate, allow("DOCTOR")];
const fail = (res: Response, status: number, error: string) => res.status(status).json({ error });
const asyncRoute = (fn: (req: Request, res: Response) => Promise<unknown>) =>
  (req: Request, res: Response, next: (e?: unknown) => void) => { void fn(req, res).catch(next); };
const user = (req: Request) => userId(req);
const date = z.string().datetime({ offset: true }).transform(v => new Date(v));
const times = z.array(z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/)).min(1).max(8);
function decodeTimes(value: string): string[] {
  try {
    const parsed: unknown = JSON.parse(value);
    return Array.isArray(parsed) ? parsed.filter((v): v is string => typeof v === "string") : [];
  } catch {
    return [];
  }
}
const medicationForApi = <T extends { reminderTimes: string }>(medication: T) => ({
  ...medication,
  reminderTimes: decodeTimes(medication.reminderTimes)
});

function tokenFor(id: string, role: UserRole) {
  return jwt.sign({ id, role }, process.env.JWT_SECRET!, { expiresIn: "12h" });
}

router.post("/auth/register", asyncRoute(async (req, res) => {
  const parsed = z.object({
    name: z.string().trim().min(2).max(100),
    email: z.string().trim().email().transform(v => v.toLowerCase()),
    phone: z.string().trim().max(30).optional(),
    password: z.string().min(10).max(128),
    role: z.enum(USER_ROLES)
  }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, parsed.error.issues[0]?.message ?? "Invalid registration");
  const existing = await db.user.findFirst({ where: { OR: [{ email: parsed.data.email }, ...(parsed.data.phone ? [{ phone: parsed.data.phone }] : [])] } });
  if (existing) return fail(res, 409, "Email is already registered");
  const account = await db.user.create({ data: { ...parsed.data, passwordHash: await bcrypt.hash(parsed.data.password, 12) } });
  return res.status(201).json({ token: tokenFor(account.id, account.role as UserRole), user: { id: account.id, name: account.name, email: account.email, role: account.role } });
}));

router.post("/auth/login", asyncRoute(async (req, res) => {
  const parsed = z.object({ identifier: z.string().trim().min(3).max(200), password: z.string().min(1), role: z.enum(USER_ROLES).optional() }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Enter a valid email or phone number and password");
  const identifier = parsed.data.identifier;
  const account = await db.user.findFirst({ where: { OR: [{ email: identifier.toLowerCase() }, { phone: identifier } ] } });
  if (!account || !(await bcrypt.compare(parsed.data.password, account.passwordHash)) || (parsed.data.role && account.role !== parsed.data.role)) {
    return fail(res, 401, "Email or password is incorrect");
  }
  return res.json({ token: tokenFor(account.id, account.role as UserRole), user: { id: account.id, name: account.name, email: account.email, role: account.role } });
}));

router.get("/auth/me", ...auth, asyncRoute(async (req, res) => {
  const account = await db.user.findUnique({ where: { id: user(req) }, select: { id: true, name: true, email: true, phone: true, role: true, specialty: true, language: true, notificationsOn: true } });
  return account ? res.json(account) : fail(res, 404, "Account not found");
}));

router.patch("/profile", ...auth, asyncRoute(async (req, res) => {
  const parsed = z.object({ name: z.string().trim().min(2).max(100).optional(), phone: z.string().trim().max(30).nullable().optional(), language: z.string().min(2).max(12).optional(), notificationsOn: z.boolean().optional(), specialty: z.string().trim().max(100).optional() }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Invalid profile fields");
  const updated = await db.user.update({ where: { id: user(req) }, data: parsed.data, select: { id: true, name: true, email: true, phone: true, role: true, specialty: true, language: true, notificationsOn: true } });
  return res.json(updated);
}));

const medicationInput = z.object({
  name: z.string().trim().min(1).max(120), dosage: z.string().trim().min(1).max(100),
  frequency: z.string().trim().min(1).max(100), instructions: z.string().trim().max(1000).optional(),
  startDate: date, endDate: date.optional(), reminderTimes: times
});

function dateAtTime(day: Date, hhmm: string) {
  const [h, m] = hhmm.split(":").map(Number);
  const value = new Date(day);
  value.setHours(h, m, 0, 0);
  return value;
}
async function generateDoseRows(medicationId: string, patientId: string, start: Date, end: Date, reminderTimes: string[]) {
  const rows: { patientId: string; medicationId: string; scheduledFor: Date }[] = [];
  const cursor = new Date(start); cursor.setHours(0, 0, 0, 0);
  const last = new Date(end); last.setHours(0, 0, 0, 0);
  for (let day = cursor; day <= last; day.setDate(day.getDate() + 1)) {
    for (const time of reminderTimes) {
      const scheduledFor = dateAtTime(day, time);
      if (scheduledFor >= start && scheduledFor <= end) rows.push({ patientId, medicationId, scheduledFor });
    }
  }
  for (const row of rows) await db.doseLog.upsert({ where: { medicationId_scheduledFor: { medicationId: row.medicationId, scheduledFor: row.scheduledFor } }, create: row, update: {} });
}
async function createMedication(patientId: string, data: z.infer<typeof medicationInput>) {
  const medication = await db.medication.create({ data: { ...data, reminderTimes: JSON.stringify(data.reminderTimes), patientId } });
  const rangeEnd = data.endDate && data.endDate < new Date(Date.now() + 30 * 86400000) ? data.endDate : new Date(Date.now() + 30 * 86400000);
  await generateDoseRows(medication.id, patientId, data.startDate, rangeEnd, data.reminderTimes);
  return { ...medication, reminderTimes: data.reminderTimes };
}

router.get("/medications", ...patientOnly, asyncRoute(async (req, res) => {
  const medications = await db.medication.findMany({ where: { patientId: user(req), active: true }, orderBy: { createdAt: "desc" } });
  return res.json(medications.map(medicationForApi));
}));
router.post("/medications", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = medicationInput.safeParse(req.body);
  if (!parsed.success) return fail(res, 400, parsed.error.issues[0]?.message ?? "Invalid medication");
  if (parsed.data.endDate && parsed.data.endDate < parsed.data.startDate) return fail(res, 400, "End date must be on or after start date");
  return res.status(201).json(await createMedication(user(req), parsed.data));
}));
router.patch("/medications/:id", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = medicationInput.partial().safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Invalid medication fields");
  const found = await db.medication.findFirst({ where: { id: req.params.id, patientId: user(req), active: true } });
  if (!found) return fail(res, 404, "Medication not found");
  const { reminderTimes, ...fields } = parsed.data;
  const data = { ...fields, ...(reminderTimes ? { reminderTimes: JSON.stringify(reminderTimes) } : {}) };
  const updated = await db.medication.update({ where: { id: found.id }, data });
  return res.json(medicationForApi(updated));
}));
router.delete("/medications/:id", ...patientOnly, asyncRoute(async (req, res) => {
  const result = await db.medication.updateMany({ where: { id: req.params.id, patientId: user(req), active: true }, data: { active: false } });
  return result.count ? res.json({ ok: true }) : fail(res, 404, "Medication not found");
}));

router.get("/doses", ...patientOnly, asyncRoute(async (req, res) => {
  await processCareReminders();
  const from = req.query.from ? new Date(String(req.query.from)) : new Date(new Date().setHours(0, 0, 0, 0));
  const to = req.query.to ? new Date(String(req.query.to)) : new Date(Date.now() + 7 * 86400000);
  if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime()) || to < from || to.getTime() - from.getTime() > 31 * 86400000) return fail(res, 400, "Use a valid date range up to 31 days");
  const meds = await db.medication.findMany({ where: { patientId: user(req), active: true, startDate: { lte: to }, OR: [{ endDate: null }, { endDate: { gte: from } }] } });
  for (const med of meds) await generateDoseRows(med.id, user(req), from, to, decodeTimes(med.reminderTimes));
  const doses = await db.doseLog.findMany({ where: { patientId: user(req), scheduledFor: { gte: from, lte: to } }, include: { medication: true }, orderBy: { scheduledFor: "asc" } });
  return res.json(doses.map(dose => ({ ...dose, medication: medicationForApi(dose.medication) })));
}));
router.patch("/doses/:id/status", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ status: z.enum(["TAKEN", "SNOOZED", "SKIPPED"]), snoozeMinutes: z.number().int().min(1).max(180).optional() }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Status must be TAKEN, SNOOZED, or SKIPPED");
  const found = await db.doseLog.findFirst({ where: { id: req.params.id, patientId: user(req) } });
  if (!found) return fail(res, 404, "Dose not found");
  const snoozedUntil = parsed.data.status === "SNOOZED" ? new Date(Date.now() + (parsed.data.snoozeMinutes ?? 15) * 60000) : null;
  return res.json(await db.doseLog.update({ where: { id: found.id }, data: { status: parsed.data.status as DoseStatus, actedAt: new Date(), snoozedUntil } }));
}));

router.get("/doctors", ...auth, asyncRoute(async (req, res) => {
  const specialty = String(req.query.specialty ?? "").trim();
  return res.json(await db.user.findMany({ where: { role: "DOCTOR", ...(specialty ? { specialty: { contains: specialty } } : {}) }, select: { id: true, name: true, specialty: true }, orderBy: { name: "asc" } }));
}));
router.get("/doctors/:id/availability", ...auth, asyncRoute(async (req, res) => {
  const from = req.query.from ? new Date(String(req.query.from)) : new Date();
  const to = req.query.to ? new Date(String(req.query.to)) : new Date(Date.now() + 30 * 86400000);
  if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime()) || to <= from || to.getTime() - from.getTime() > 90 * 86400000) return fail(res, 400, "Use a valid availability range up to 90 days");
  return res.json(await db.doctorAvailability.findMany({ where: { doctorId: req.params.id, isBooked: false, startsAt: { gte: from, lte: to } }, orderBy: { startsAt: "asc" } }));
}));
router.post("/doctor/availability", ...doctorOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ startsAt: date, endsAt: date }).safeParse(req.body);
  if (!parsed.success || parsed.data.endsAt <= parsed.data.startsAt || parsed.data.startsAt <= new Date()) return fail(res, 400, "Provide a future slot with an end time after its start");
  return res.status(201).json(await db.doctorAvailability.create({ data: { doctorId: user(req), ...parsed.data } }));
}));
router.delete("/doctor/availability/:id", ...doctorOnly, asyncRoute(async (req, res) => {
  const slot = await db.doctorAvailability.findFirst({ where: { id: req.params.id, doctorId: user(req), isBooked: false } });
  if (!slot) return fail(res, 404, "Available slot not found");
  await db.doctorAvailability.delete({ where: { id: slot.id } });
  return res.json({ ok: true });
}));
router.post("/appointments", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ availabilityId: z.string().min(1), reason: z.string().trim().max(500).optional() }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Choose an available doctor appointment time");
  const slot = await db.doctorAvailability.findFirst({ where: { id: parsed.data.availabilityId, isBooked: false, startsAt: { gt: new Date() } }, include: { doctor: { select: { id: true } } } });
  if (!slot) return fail(res, 409, "That appointment time is no longer available");
  try {
    const appointment = await db.$transaction(async tx => {
      const reserved = await tx.doctorAvailability.updateMany({ where: { id: slot.id, isBooked: false }, data: { isBooked: true } });
      if (!reserved.count) throw new Error("APPOINTMENT_SLOT_TAKEN");
      return tx.appointment.create({ data: { patientId: user(req), doctorId: slot.doctorId, startsAt: slot.startsAt, availabilityId: slot.id, reason: parsed.data.reason } });
    });
    await db.notification.create({ data: { userId: slot.doctor.id, kind: "APPOINTMENT", title: "Appointment request", body: "A patient requested an appointment." } });
    return res.status(201).json(appointment);
  } catch (error) {
    if (error instanceof Error && error.message === "APPOINTMENT_SLOT_TAKEN") return fail(res, 409, "That appointment time is no longer available");
    throw error;
  }
}));
router.get("/appointments", ...auth, asyncRoute(async (req, res) => {
  const claims = (req as Request & { user?: { id: string; role: UserRole } }).user!;
  const where = claims.role === "PATIENT" ? { patientId: claims.id } : claims.role === "DOCTOR" ? { doctorId: claims.id } : { patientId: "__none__" };
  return res.json(await db.appointment.findMany({ where, include: { patient: { select: { id: true, name: true } }, doctor: { select: { id: true, name: true, specialty: true } } }, orderBy: { startsAt: "asc" } }));
}));
router.patch("/appointments/:id/status", ...doctorOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ status: z.enum(["CONFIRMED", "CANCELLED", "COMPLETED"]) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Invalid appointment status");
  const result = await db.appointment.updateMany({ where: { id: req.params.id, doctorId: user(req), status: { not: "CANCELLED" } }, data: { status: parsed.data.status as AppointmentStatus } });
  if (!result.count) return fail(res, 404, "Appointment not found");
  if (parsed.data.status === "CANCELLED") {
    const appointment = await db.appointment.findUnique({ where: { id: req.params.id }, select: { availabilityId: true } });
    if (appointment?.availabilityId) {
      await db.appointment.update({ where: { id: req.params.id }, data: { availabilityId: null } });
      await db.doctorAvailability.update({ where: { id: appointment.availabilityId }, data: { isBooked: false } });
    }
  }
  return res.json(await db.appointment.findUnique({ where: { id: req.params.id } }));
}));

router.post("/caregivers/invitations", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ caregiverEmail: z.string().email().transform(v => v.toLowerCase()) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Enter a valid caregiver email");
  const caregiver = await db.user.findUnique({ where: { email: parsed.data.caregiverEmail } });
  if (!caregiver || caregiver.role !== "CAREGIVER") return fail(res, 404, "No caregiver account found for that email");
  const inviteCode = randomBytes(4).toString("hex").toUpperCase();
  const link = await db.caregiverLink.upsert({ where: { patientId_caregiverId: { patientId: user(req), caregiverId: caregiver.id } }, create: { patientId: user(req), caregiverId: caregiver.id, inviteCode }, update: { status: "PENDING", inviteCode } });
  await db.notification.create({ data: { userId: caregiver.id, kind: "CARE_ACCESS", title: "Caregiver invitation", body: "A patient invited you to connect. Code: " + inviteCode } });
  return res.status(201).json({ id: link.id, inviteCode, status: link.status });
}));
router.post("/caregivers/accept", ...caregiverOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ inviteCode: z.string().trim().min(4).max(32) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Enter a valid invitation code");
  const link = await db.caregiverLink.findUnique({ where: { inviteCode: parsed.data.inviteCode.toUpperCase() } });
  if (!link || link.caregiverId !== user(req)) return fail(res, 404, "Invitation not found");
  return res.json({ id: link.id, status: link.status, message: "Patient approval is still required before records are visible." });
}));
router.get("/caregivers/links", ...patientOnly, asyncRoute(async (req, res) => {
  return res.json(await db.caregiverLink.findMany({ where: { patientId: user(req) }, include: { caregiver: { select: { id: true, name: true, email: true } } } }));
}));
router.patch("/caregivers/links/:id/consent", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ status: z.enum(["APPROVED", "DECLINED", "REVOKED"]) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Invalid consent decision");
  const updated = await db.caregiverLink.updateMany({ where: { id: req.params.id, patientId: user(req) }, data: { status: parsed.data.status } });
  return updated.count ? res.json(await db.caregiverLink.findUnique({ where: { id: req.params.id }, select: { id: true, status: true } })) : fail(res, 404, "Caregiver request not found");
}));
router.get("/caregivers/patients", ...caregiverOnly, asyncRoute(async (req, res) => {
  const links = await db.caregiverLink.findMany({ where: { caregiverId: user(req), status: "APPROVED" }, include: { patient: { select: { id: true, name: true } } } });
  const data = await Promise.all(links.map(async l => ({
    linkId: l.id, patient: l.patient,
    medications: l.canViewDoses ? await db.medication.findMany({ where: { patientId: l.patientId, active: true }, select: { id: true, name: true, dosage: true, frequency: true } }) : [],
    doses: l.canViewDoses ? await db.doseLog.findMany({ where: { patientId: l.patientId, scheduledFor: { gte: new Date(Date.now() - 86400000) } }, include: { medication: { select: { name: true, dosage: true } } }, orderBy: { scheduledFor: "asc" }, take: 100 }) : [],
    appointments: l.canViewAppointments ? await db.appointment.findMany({ where: { patientId: l.patientId, startsAt: { gte: new Date() }, status: { in: ["REQUESTED", "CONFIRMED"] } }, include: { doctor: { select: { name: true, specialty: true } } }, orderBy: { startsAt: "asc" }, take: 10 }) : []
  })));
  return res.json(data);
}));

router.post("/doctor/access-requests", ...doctorOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ patientId: z.string().min(1), purpose: z.string().trim().min(5).max(500) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Provide a patient and access purpose");
  const patient = await db.user.findFirst({ where: { id: parsed.data.patientId, role: "PATIENT" }, select: { id: true } });
  if (!patient) return fail(res, 404, "Patient not found");
  const request = await db.accessRequest.create({ data: { doctorId: user(req), patientId: patient.id, purpose: parsed.data.purpose } });
  await db.notification.create({ data: { userId: patient.id, kind: "CARE_ACCESS", title: "Doctor access request", body: "A doctor requested access to your information. Review the request in the app." } });
  return res.status(201).json(request);
}));
router.get("/doctor/access-requests", ...patientOnly, asyncRoute(async (req, res) => {
  return res.json(await db.accessRequest.findMany({ where: { patientId: user(req) }, include: { doctor: { select: { id: true, name: true, specialty: true } } }, orderBy: { createdAt: "desc" } }));
}));
router.patch("/doctor/access-requests/:id/consent", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ status: z.enum(["APPROVED", "DECLINED", "REVOKED"]) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Invalid access decision");
  const request = await db.accessRequest.findFirst({ where: { id: req.params.id, patientId: user(req) } });
  if (!request) return fail(res, 404, "Access request not found");
  const updated = await db.accessRequest.update({ where: { id: request.id }, data: { status: parsed.data.status, decidedAt: new Date() } });
  return res.json(updated);
}));
router.get("/doctor/patients/:patientId", ...doctorOnly, asyncRoute(async (req, res) => {
  if (!(await requireApprovedDoctor(req.params.patientId, user(req)))) return fail(res, 403, "Patient has not approved access");
  const patient = await db.user.findFirst({ where: { id: req.params.patientId, role: "PATIENT" }, select: { id: true, name: true } });
  if (!patient) return fail(res, 404, "Patient not found");
  const medications = await db.medication.findMany({ where: { patientId: patient.id, active: true } });
  const appointments = await db.appointment.findMany({ where: { patientId: patient.id }, orderBy: { startsAt: "desc" }, take: 25 });
  return res.json({ patient, medications: medications.map(medicationForApi), appointments });
}));
router.post("/doctor/prescriptions", ...doctorOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({
    patientId: z.string().min(1), notes: z.string().trim().max(1000).optional(),
    items: z.array(z.object({ name: z.string().trim().min(1).max(120), dosage: z.string().trim().min(1).max(100), frequency: z.string().trim().min(1).max(100), durationDays: z.number().int().positive().max(365).optional(), instructions: z.string().trim().max(1000).optional(), reminderTimes: times })).min(1).max(20)
  }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, parsed.error.issues[0]?.message ?? "Invalid prescription");
  if (!(await requireApprovedDoctor(parsed.data.patientId, user(req)))) return fail(res, 403, "Patient approval is required before prescribing through this prototype");
  const prescription = await db.prescription.create({ data: { doctorId: user(req), patientId: parsed.data.patientId, notes: parsed.data.notes, items: { create: parsed.data.items.map(item => ({ ...item, reminderTimes: JSON.stringify(item.reminderTimes) })) } }, include: { items: true } });
  await db.notification.create({ data: { userId: parsed.data.patientId, kind: "PRESCRIPTION", title: "Digital prescription received", body: "Review and confirm the prescription in MediCare AI." } });
  return res.status(201).json({ ...prescription, items: prescription.items.map(item => ({ ...item, reminderTimes: decodeTimes(item.reminderTimes) })) });
}));
router.get("/prescriptions", ...auth, asyncRoute(async (req, res) => {
  const claims = (req as Request & { user?: { id: string; role: UserRole } }).user!;
  const where = claims.role === "PATIENT" ? { patientId: claims.id } : claims.role === "DOCTOR" ? { doctorId: claims.id } : { id: "__none__" };
  const prescriptions = await db.prescription.findMany({ where, include: { items: true, doctor: { select: { id: true, name: true, specialty: true } }, patient: { select: { id: true, name: true } } }, orderBy: { createdAt: "desc" } });
  return res.json(prescriptions.map(p => ({ ...p, items: p.items.map(item => ({ ...item, reminderTimes: decodeTimes(item.reminderTimes) })) })));
}));
router.patch("/prescriptions/:id/decision", ...patientOnly, asyncRoute(async (req, res) => {
  const parsed = z.object({ decision: z.enum(["CONFIRMED", "DECLINED"]) }).safeParse(req.body);
  if (!parsed.success) return fail(res, 400, "Decision must be CONFIRMED or DECLINED");
  const p = await db.prescription.findFirst({ where: { id: req.params.id, patientId: user(req), status: "SENT" }, include: { items: true } });
  if (!p) return fail(res, 404, "Pending prescription not found");
  const updated = await db.prescription.update({ where: { id: p.id }, data: { status: parsed.data.decision, confirmedAt: new Date() } });
  if (parsed.data.decision === "CONFIRMED") {
    for (const item of p.items) {
      const startDate = new Date();
      const endDate = item.durationDays ? new Date(Date.now() + item.durationDays * 86400000) : undefined;
      await createMedication(user(req), { name: item.name, dosage: item.dosage, frequency: item.frequency, instructions: item.instructions, reminderTimes: decodeTimes(item.reminderTimes), startDate, endDate });
    }
  }
  return res.json(updated);
}));

router.get("/notifications", ...auth, asyncRoute(async (req, res) => {
  return res.json(await db.notification.findMany({ where: { userId: user(req) }, orderBy: { createdAt: "desc" }, take: 100 }));
}));
router.patch("/notifications/:id/read", ...auth, asyncRoute(async (req, res) => {
  const changed = await db.notification.updateMany({ where: { id: req.params.id, userId: user(req) }, data: { readAt: new Date() } });
  return changed.count ? res.json({ ok: true }) : fail(res, 404, "Notification not found");
}));
