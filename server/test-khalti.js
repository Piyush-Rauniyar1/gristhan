import axios from 'axios';
import jwt from 'jsonwebtoken';

async function test() {
  const userId = '51e17920-40ba-4be7-aa59-b053d32aaca0';
  const token = jwt.sign({ sub: userId, role: 'user' }, 'dev_secret_key_change_in_production', { expiresIn: '7d' });
  
  try {
    const res = await axios.post('http://127.0.0.1:5001/v1/payments/khalti/verify', {
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
