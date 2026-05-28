import axios from 'axios';
import { query } from './src/config/db.js';

async function test() {
  // Create user
  try {
     await axios.post('http://localhost:5001/v1/auth/user/signup', {
      full_name: 'Test Guest',
      email: 'testguest123@example.com',
      password: 'password123',
      phone: '1234567890'
    });
  } catch (e) {
    // maybe already exists
  }
  
  const loginRes = await axios.post('http://localhost:5001/v1/auth/user/login', {
    email: 'testguest123@example.com',
    password: 'password123'
  });
  const token = loginRes.data.data.token;

  const listingRes = await query('SELECT id FROM listings LIMIT 1');
  const listing_id = listingRes.rows[0].id;

  try {
    const bookingRes = await axios.post('http://localhost:5001/v1/bookings', {
      listing_id,
      check_in: '2026-06-01',
      check_out: '2026-06-05',
      guests: 2,
      booking_type: 'instant'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log("Success:", bookingRes.data);
  } catch (err) {
    console.log("Error:", err.response?.data || err.message);
  }
  process.exit(0);
}
test();
