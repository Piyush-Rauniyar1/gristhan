import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, "../../.env") });

// Dynamic import to ensure dotenv runs first!
const { sendVerificationEmail } = await import("../src/utils/mailer.js");

async function test() {
  const email = "eb6dd88060899a1b@30minemail.com";
  const otp = "123456";
  try {
    await sendVerificationEmail(email, otp);
    console.log("Email sent successfully!");
  } catch (error) {
    console.error("Email failed:", error);
  }
}
test();
