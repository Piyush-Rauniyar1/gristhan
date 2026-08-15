const fs = require('fs');

const inputSQL = fs.readFileSync('server/database_azure.sql', 'utf-8');
const lines = inputSQL.split('\n');

let outputLines = [];
let insideCopy = false;
let currentTable = '';
let currentColumns = '';

for (const line of lines) {
  if (line.startsWith('COPY ')) {
    insideCopy = true;
    // e.g. COPY public.admins (id, email, full_name, password_hash) FROM stdin;
    const match = line.match(/^COPY (public\.\w+) \((.+?)\) FROM stdin;/);
    if (match) {
      currentTable = match[1];
      currentColumns = match[2];
    } else {
      console.warn('Could not parse COPY line:', line);
    }
    continue;
  }

  if (insideCopy) {
    if (line === '\\.') {
      insideCopy = false;
      currentTable = '';
      currentColumns = '';
      continue;
    }

    if (currentTable) {
      // Split by tab, escape single quotes, wrap in single quotes or use NULL
      const values = line.split('\t').map(v => {
        if (v === '\\N') return 'NULL';
        // Check if value looks like a boolean or number (simplification)
        if (v === 't') return 'TRUE';
        if (v === 'f') return 'FALSE';
        if (!isNaN(v) && v.trim() !== '' && !v.includes('-')) return v; // Keep numbers unquoted unless UUID
        // UUIDs and dates and text must be quoted
        return `'${v.replace(/'/g, "''")}'`;
      });
      
      outputLines.push(`INSERT INTO ${currentTable} (${currentColumns}) VALUES (${values.join(', ')});`);
    }
  } else {
    // Some psql metacommmands like \connect aren't supported in Supabase either
    if (!line.startsWith('\\connect') && !line.startsWith('SET ')) {
      outputLines.push(line);
    }
  }
}

fs.writeFileSync('server/database_supabase.sql', outputLines.join('\n'));
console.log('Converted to database_supabase.sql');
