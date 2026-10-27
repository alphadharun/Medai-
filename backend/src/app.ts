import express from "express";
import cors from "cors";
import helmet from "helmet";
import { authenticate } from "./auth.js";
import { router } from "./routes.js";

export const app = express();
app.disable("x-powered-by");
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN === "*" ? true : (process.env.CORS_ORIGIN ?? "http://localhost:5000,http://localhost:3000").split(",") }));
app.use(express.json({ limit: "1mb" }));
app.get("/health", (_req, res) => res.json({ ok: true, service: "medicare-ai-api" }));
app.use("/api", router);
app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  const message = "Unexpected server error";
  res.status(500).json({ error: message });
});