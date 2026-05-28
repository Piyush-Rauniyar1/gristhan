import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import nodemailer from 'nodemailer';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, "../.env") });

async function test() {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT, 10),
    secure: parseInt(process.env.SMTP_PORT, 10) === 465,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  const mailOptions = {
    from: process.env.EMAIL_FROM,
    to: 'grihasthaguest@piyushrauniyar.tech',
    subject: 'Booking Confirmed: Test Property on Grihastha',
    html: `
      <!DOCTYPE html>
      <html lang="en">
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background-color: #f7f9fa; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
            <h1 style="color: #0b8e72; margin-top: 0;">Booking Confirmed! 🎉</h1>
          </div>
          
          <p>Hi <strong>Test Guest</strong>,</p>
          <p>Great news! Your booking and payment for <strong>Test Property</strong> have been successfully processed.</p>
          
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 8px; margin: 25px 0; border-left: 4px solid #0b8e72;">
            <h3 style="margin-top: 0; color: #0b8e72;">Booking Details</h3>
            <p style="margin: 5px 0;"><strong>Confirmation Code:</strong> test_booking_id</p>
            <p style="margin: 5px 0;"><strong>Check-in:</strong> ${new Date().toLocaleDateString()}</p>
            <p style="margin: 5px 0;"><strong>Check-out:</strong> ${new Date().toLocaleDateString()}</p>
            <p style="margin: 5px 0;"><strong>Total Paid:</strong> NPR 1000</p>
            <p style="margin: 5px 0;"><strong>Host Phone:</strong> 9876543210</p>
          </div>
        </body>
      </html>
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Booking email sent successfully:', info.messageId);
  } catch (error) {
    console.error('Failed to send booking email:', error);
  }
}
test();
