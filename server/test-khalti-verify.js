import axios from 'axios';

async function test() {
  try {
    const loginRes = await axios.post('http://localhost:5001/v1/auth/user/login', {
      email: 'testuser@example.com',
      password: 'password123'
    });
    const token = loginRes.data.data.token;

    const res = await axios.post('http://localhost:5001/v1/payments/khalti/verify', {
      pidx: 'JEqiLiDKjmYCpkwdrkTnR4',
      booking_id: 'b01e6af4-362c-4d02-9389-e4d22ed3dabc'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log("Success:", res.data);
  } catch (err) {
    console.log("Error status:", err.response?.status);
    console.log("Error data:", err.response?.data);
    console.log("Error message:", err.message);
  }
}
test();
