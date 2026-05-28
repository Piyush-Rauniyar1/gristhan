import CryptoJS from 'crypto-js';

const SECRET_KEY = 'grihastha_default_secret_key';
const ciphertext = 'U2FsdGVkX19Ycd0NNhCsGILS6jWbYKhAq37IHPb/LwA=';

try {
  const bytes = CryptoJS.AES.decrypt(ciphertext, SECRET_KEY);
  const decryptedText = bytes.toString(CryptoJS.enc.Utf8);
  console.log('Decrypted text:', decryptedText);
} catch (e) {
  console.error('Error:', e);
}
