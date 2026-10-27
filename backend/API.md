# REST API quick reference

Routes are prefixed with `/api`. Protected routes require `Authorization: Bearer <token>`. JSON dates use ISO-8601 timestamps with timezone offsets.

## Accounts
- `POST /auth/register`: `{name,email,phone?,password,role}`; password must be at least 10 characters.
- `POST /auth/login`: `{identifier,password,role?}`; identifier is email or registered phone.
- `GET /auth/me`, `PATCH /profile`

## Patient medication and doses
- `GET /medications`
- `POST /medications`: `{name,dosage,frequency,instructions?,startDate,endDate?,reminderTimes:["08:00"]}`
- `PATCH /medications/:id`, `DELETE /medications/:id` (deactivates)
- `GET /doses?from=<ISO>&to=<ISO>`: generates scheduled rows (maximum 31 days).
- `PATCH /doses/:id/status`: `{status:"TAKEN"|"SNOOZED"|"SKIPPED",snoozeMinutes?}`

## Doctors and appointments
- `GET /doctors?specialty=...`
- `GET /doctors/:id/availability?from=<ISO>&to=<ISO>`
- Doctor: `POST /doctor/availability` with `{startsAt,endsAt}`; `DELETE /doctor/availability/:id`
- Patient: `POST /appointments` with `{availabilityId,reason?}`; `GET /appointments`
- Doctor: `GET /appointments`; `PATCH /appointments/:id/status` with CONFIRMED, CANCELLED, or COMPLETED

## Patient consent, caregiver links, and prescriptions
- Doctor: `POST /doctor/access-requests` with `{patientId,purpose}`
- Patient: `GET /doctor/access-requests`; `PATCH /doctor/access-requests/:id/consent` with APPROVED, DECLINED, or REVOKED
- Doctor patient details and prescriptions require approved patient access.
- Doctor: `GET /doctor/patients/:patientId`; `POST /doctor/prescriptions` with patientId and medicine items
- Patient: `GET /prescriptions`; `PATCH /prescriptions/:id/decision` with CONFIRMED or DECLINED. Confirmation creates medication records and schedules.
- Patient: `POST /caregivers/invitations` with `{caregiverEmail}`; approve or revoke at `PATCH /caregivers/links/:id/consent`.
- Caregiver: `POST /caregivers/accept` with `{inviteCode}`; approved linked data is available at `GET /caregivers/patients`.

## Notifications
- `GET /notifications`, `PATCH /notifications/:id/read`
- Missed-dose and refill alerts are stored in PostgreSQL. Flutter must poll this endpoint or add a push provider integration for device notifications.
