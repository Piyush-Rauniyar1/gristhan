import dotenv from 'dotenv';
dotenv.config({ path: '../.env' });
console.log("Loaded DB_USER:", process.env.DB_USER);

async function check() {
  try {
    const { query } = await import("./src/config/db.js");
    const res = await query("SELECT COUNT(*) FROM disputes");
    console.log("Total disputes:", res.rows[0].count);
    
    const res2 = await query("SELECT * FROM disputes LIMIT 5");
    console.log("Sample disputes:", res2.rows);
  } catch (err) {
    console.error("Error:", err.message);
  }
}

check();
