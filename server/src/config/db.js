import pg from "pg";

const { Pool } = pg;

// Use DATABASE_URL if available (e.g., from Supabase/Render), else fallback to individual credentials
const poolConfig = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      connectionTimeoutMillis: 5000,
      idleTimeoutMillis: 30000,
      max: 10,
    }
  : {
      host: process.env.DB_HOST || "localhost",
      port: parseInt(process.env.DB_PORT || "5432", 10),
      database: process.env.DB_NAME || "grihastha",
      user: process.env.DB_USER || "postgres",
      password: process.env.DB_PASSWORD,
      connectionTimeoutMillis: 5000,
      idleTimeoutMillis: 30000,
      max: 10,
    };

// Enable SSL if specified in env or automatically for Azure/Supabase hostnames
if (
  process.env.DB_SSL === "true" ||
  (process.env.DB_HOST && process.env.DB_HOST.includes("database.azure.com")) ||
  (process.env.DATABASE_URL && process.env.DATABASE_URL.includes("supabase.com"))
) {
  poolConfig.ssl = {
    rejectUnauthorized: false, // Prevents certificate verification errors unless a specific CA is set up
  };
}

const pool = new Pool(poolConfig);

// Handle pool errors without crashing the process
pool.on("error", (err) => {
  console.error("[DB] Unexpected error on idle client:", err.message);
});

/**
 * Execute a parameterized query against the database.
 * @param {string} text - SQL query string
 * @param {Array} params - Query parameters
 * @returns {Promise<import("pg").QueryResult>}
 */
const query = (text, params) => pool.query(text, params);

export { pool, query };
export default pool;
