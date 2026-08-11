#!/bin/sh
set -e

echo "⏳ Waiting for PostgreSQL to be ready..."

# Wait for PostgreSQL to accept connections
until node -e "
  import('pg').then(({ default: pg }) => {
    const config = process.env.DATABASE_URL ? { connectionString: process.env.DATABASE_URL } : {
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT || '5432'),
      database: 'postgres',
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    };
    if (process.env.DB_SSL === 'true' || (process.env.DATABASE_URL && process.env.DATABASE_URL.includes('supabase.com'))) {
      config.ssl = { rejectUnauthorized: false };
    }
    const pool = new pg.Pool(config);
    pool.query('SELECT 1')
      .then(() => { pool.end(); process.exit(0); })
      .catch((e) => { console.error('DB Check Error:', e.message); pool.end(); process.exit(1); });
  });
"; do
  echo "   PostgreSQL not ready yet, retrying in 2s..."
  sleep 2
done

echo "✅ PostgreSQL is ready!"
echo ""

# Run database setup (creates DB if it doesn't exist)
echo "🗄️  Running database setup..."
node scripts/setup-db.js || echo "⚠️  Database setup had warnings (may already exist)"
echo ""

# Run migrations
echo "🔧 Running migrations..."
node scripts/migrate.js || echo "⚠️  Migrations had warnings (may already be applied)"
echo ""

# Start the server
echo "🚀 Starting Grihastha API server..."
exec node src/server.js
