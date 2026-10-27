import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { db } from "./db.js";

export type Role = "PATIENT" | "CAREGIVER" | "DOCTOR";
export type UserClaims = { id: string; role: Role };
export type AuthedRequest = Request & { user?: UserClaims };

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const token = req.header("authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return res.status(401).json({ error: "Sign in required" });
  try {
    const secret = process.env.JWT_SECRET;
    if (!secret || secret.length < 32) throw new Error("JWT_SECRET is not configured");
    (req as AuthedRequest).user = jwt.verify(token, secret) as UserClaims;
    next();
  } catch {
    return res.status(401).json({ error: "Invalid or expired access token" });
  }
}

export function allow(...roles: Role[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as AuthedRequest).user;
    if (!user) return res.status(401).json({ error: "Sign in required" });
    if (!roles.includes(user.role)) return res.status(403).json({ error: "This account cannot perform that action" });
    next();
  };
}

export function userId(req: Request): string {
  const id = (req as AuthedRequest).user?.id;
  if (!id) throw new Error("Missing authenticated user");
  return id;
}

export async function requireApprovedDoctor(patientId: string, doctorId: string) {
  return db.accessRequest.findFirst({
    where: { patientId, doctorId, status: "APPROVED" },
    select: { id: true }
  });
}