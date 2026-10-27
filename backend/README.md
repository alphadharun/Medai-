# MediCare AI API

Node.js/TypeScript REST API with SQLite and Prisma for local development. SQLite is a SQL database stored in a local file, so Docker or a separate database server is not needed. Prescription camera capture and OCR are intentionally excluded.

## Run from PowerShell

Open PowerShell and run these commands exactly:

```powershell
Set-Location "E:\Medai app\medai\backend"
Copy-Item .env.example .env
npm install
npm run db:generate
npm run db:migrate -- --name init
npm run dev
```

Set a private JWT_SECRET in .env before using accounts. The SQLite file will be created under prisma/dev.db. Base URL: http://localhost:3000/api. Health check: GET http://localhost:3000/health.

Register with POST /api/auth/register using name, email, password and role (PATIENT, CAREGIVER, DOCTOR). Login with POST /api/auth/login using identifier (email or phone) and password. Send the returned token as Authorization: Bearer <token>. See API.md for endpoint examples.

All data is for prototyping. Do not use real patient information. Before production, add clinician identity verification, audit trails, security/privacy review, backups, monitoring, retention controls, and jurisdiction-specific compliance. Device push and offline alarms require Flutter-side integrations; this API stores in-app notifications.
