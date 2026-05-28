import pg from 'pg';
const { Client } = pg;
const client = new Client({ connectionString: 'postgres://piyushrauniyar@localhost:5432/grihastha' });
async function test() {
  await client.connect();
  try {
    await client.query('SELECT $1::text', [undefined]);
    console.log("Success");
  } catch (err) {
    console.log("Error:", err.message);
  }
  await client.end();
}
test();
