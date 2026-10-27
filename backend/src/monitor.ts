import { db } from "./db.js";

// Generates in-app missed-dose and refill alerts. A mobile client can poll
// /api/notifications; native push delivery is a separate client/provider setup.
export async function processCareReminders() {
  const grace = Number(process.env.MISSED_DOSE_GRACE_MINUTES ?? 30);
  const cutoff = new Date(Date.now() - grace * 60_000);
  const overdue = await db.doseLog.findMany({
    where: { OR: [{ status: "SCHEDULED", scheduledFor: { lt: cutoff } }, { status: "SNOOZED", snoozedUntil: { lt: new Date() } }] },
    include: { medication: { select: { name: true, dosage: true } } },
    take: 250
  });
  for (const dose of overdue) {
    const changed = await db.doseLog.updateMany({
      where: { id: dose.id, status: dose.status }, data: { status: "MISSED" }
    });
    if (!changed.count) continue;
    const links = await db.caregiverLink.findMany({
      where: { patientId: dose.patientId, status: "APPROVED", canViewDoses: true },
      select: { caregiverId: true }
    });
    for (const link of links) await db.notification.create({ data: {
      userId: link.caregiverId, kind: "MISSED_DOSE", title: "Missed dose alert",
      body: "A linked patient has an unconfirmed dose of " + dose.medication.name + " (" + dose.medication.dosage + ")."
    } });
  }

  const now = new Date();
  const refillWindow = new Date(Date.now() + 7 * 86_400_000);
  const nearEnd = await db.medication.findMany({
    where: { active: true, endDate: { gt: now, lte: refillWindow }, refillNotifiedAt: null },
    take: 250
  });
  for (const medication of nearEnd) {
    const changed = await db.medication.updateMany({
      where: { id: medication.id, refillNotifiedAt: null },
      data: { refillNotifiedAt: now }
    });
    if (changed.count) {
      await db.notification.create({
        data: { userId: medication.patientId, kind: "REFILL", title: "Refill reminder", body: medication.name + " is nearing its end date. Contact your pharmacy or clinician if a refill is needed." }
      });
    }
  }
}