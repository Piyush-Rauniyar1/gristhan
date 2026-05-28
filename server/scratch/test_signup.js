import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import pg from "pg";
import bcrypt from "bcryptjs";

const { Pool } = pg;

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, "../../.env") });

console.log("DB_USER from env:", process.env.DB_USER);

const poolConfig = {
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "5432", 10),
  database: process.env.DB_NAME || "grihastha",
  user: process.env.DB_USER || "postgres",
};

const pool = new Pool(poolConfig);
const query = (text, params) => pool.query(text, params);

async function test() {
  const email = `testuser_${Date.now()}@example.com`;
  const full_name = "Test User";
  const password = "password123";
  const phone = "1234567890";

  try {
    const password_hash = await bcrypt.hash(password, 12);
    const result = await query(
      `INSERT INTO users (email, full_name, password_hash, phone, is_host)
       VALUES ($1, $2, $3, $4, FALSE)
       RETURNING id, email, full_name`,
      [email, full_name, password_hash, phone]
    );
    console.log("User inserted successfully:", result.rows[0]);
  } catch (error) {
    console.error("Signup failed:", error);
  } finally {
    await pool.end();
  }
}
test();
