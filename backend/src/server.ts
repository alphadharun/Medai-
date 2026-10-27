import "dotenv/config";
import { app } from "./app.js";
import { db } from "./db.js";
import { processCareReminders } from "./monitor.js";

const port = Number(process.env.PORT ?? 3000);
if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");
if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  throw new Error("Set JWT_SECRET to a private value of at least 32 characters");
}
const server = app.listen(port, () => console.log("MediCare AI API listening on :" + port));
void processCareReminders().catch(console.error);
const reminderTimer = setInterval(() => void processCareReminders().catch(console.error), 60_000);

async function shutdown() {
  clearInterval(reminderTimer);
  server.close();
  await db.$disconnect();
  process.exit(0);
}
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);