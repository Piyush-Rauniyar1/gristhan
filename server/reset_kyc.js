import dotenv from "dotenv";
import path from "path";
dotenv.config({ path: path.resolve(process.cwd(), "../.env") });

const { query } = await import("./src/config/db.js");

async function reset() {
  try {
    const userRes = await query("SELECT id, email FROM users WHERE full_name ILIKE '%aden%' OR email ILIKE '%aden%' OR email ILIKE '%host%'");
    console.log("Found users:", userRes.rows);
    
    for (const user of userRes.rows) {
      const hostId = user.id;
      const deleteRes = await query("DELETE FROM kyc_documents WHERE host_id = $1", [hostId]);
      console.log(`Deleted ${deleteRes.rowCount} KYC records for host ${hostId} (${user.email})`);
      
      await query("UPDATE users SET kyc_status = 'not_submitted', is_verified = FALSE WHERE id = $1", [hostId]);
      console.log(`Reset user kyc_status to 'not_submitted' for ${user.email}`);
    }
  } catch (err) {
    console.error(err);
  }
  process.exit(0);
}
reset();
