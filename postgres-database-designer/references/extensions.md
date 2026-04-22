# PostgreSQL Extensions Guide

Enable extensions only when needed. Check availability with `SELECT * FROM pg_available_extensions;`

## uuid-ossp

**Purpose**: Generate UUIDs using various algorithms

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Different UUID generation methods
uuid_generate_v1()     -- Time-based (MAC address + timestamp)
uuid_generate_v1mc()   -- Time-based (random multicast MAC)
uuid_generate_v3(ns, name)  -- MD5 hash of namespace + name
uuid_generate_v4()     -- Random (most common)
uuid_generate_v5(ns, name)  -- SHA-1 hash of namespace + name
```

**Use v4 for most cases** (random UUIDs for primary keys, tokens).

```sql
-- Example
CREATE TABLE tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ
);
```

## pgcrypto

**Purpose**: Cryptographic functions for hashing, encryption

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Hashing passwords (use this, not MD5/SHA directly)
crypt('password', gen_salt('bf'))     -- Blowfish (recommended)
crypt('password', gen_salt('md5'))     -- MD5 (legacy)
digest('data', 'sha256')               -- SHA-256 for HMAC

-- Example: password storage
UPDATE users SET password_hash = crypt('new_password', gen_salt('bf')) WHERE id = 1;

-- Verify password
SELECT id FROM users WHERE id = 1 AND password_hash = crypt('entered_password', password_hash);
```

**For encryption**:
```sql
-- Symmetric encryption
pgp_sym_encrypt(data, key)
pgp_sym_decrypt(encrypted_data, key)

-- Asymmetric encryption
pgp_pub_encrypt(data, public_key)
pgp_pub_decrypt(encrypted_data, private_key)
```

## pg_trgm

**Purpose**: Trigram matching for fuzzy text search

```sql
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Enable trigram GIN index
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);

-- Fuzzy search queries
SELECT * FROM products WHERE name % 'bicycle';           -- similarity > threshold
SELECT * FROM products WHERE name ILIKE '%bike%';         -- ILIKE with wildcard
SELECT * FROM products ORDER BY similarity(name, 'bike') DESC LIMIT 5;
```

**Use case**: Search-as-you-type, autocomplete, typo tolerance

## fuzzystrmatch

**Purpose**: String similarity and Levenshtein distance

```sql
CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch";

-- Levenshtein distance (edit distance)
SELECT levenshtein('kitten', 'sitting');  -- Returns 3

-- Soundex (phonetic matching)
SELECT soundex('Smith'), soundex('Smyth');  -- Both return 'S530'

-- Metaphone (better phonetic matching)
SELECT metaphone('Smith', 4), metaphone('Smyth', 4);  -- Both return 'SM0'
```

## hstore

**Purpose**: Key-value store within a column

```sql
CREATE EXTENSION IF NOT EXISTS "hstore";

-- hstore is good for semi-structured data without JSON overhead
ALTER TABLE products ADD COLUMN attributes hstore DEFAULT '';

-- Use hstore for:
-- - Dynamic attributes that vary per product
-- - Simple key-value without nested structure
-- - When you need operators like @> (contains) or ? (exists)

-- Example
UPDATE products SET attributes = 'color=>red, size=>large' WHERE id = 1;
SELECT * FROM products WHERE attributes @> 'color=>red'::hstore;
SELECT attributes->'color' FROM products WHERE id = 1;
```

**hstore vs JSONB**: Use hstore for simple flat key-value pairs. Use JSONB when you need nested structures or array values.

## citext

**Purpose**: Case-insensitive text

```sql
CREATE EXTENSION IF NOT EXISTS "citext";

-- Use citext for emails, usernames, tags
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email CITEXT NOT NULL UNIQUE
);

-- Now case-insensitive automatically
INSERT INTO users (email) VALUES ('User@Example.com');
SELECT * FROM users WHERE email = 'user@example.com';  -- Matches!
```

## btree_gin

**Purpose**: GIN indexes for common types (array, range, jsonb, etc.)

```sql
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- GIN indexes for common types
CREATE INDEX idx_tags ON products USING GIN (tags);
CREATE INDEX idx_price_range ON products USING GIN (price_range);
```

## btree_gist

**Purpose**: GiST indexes for exclusion constraints and complex types

```sql
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- Exclusion constraints (prevents overlapping ranges)
CREATE TABLE reservations (
    room_id INTEGER NOT NULL,
    period TSTZRANGE NOT NULL,
    EXCLUDE USING GIST (room_id WITH =, period WITH &&)
);

-- Can also use for geometric types
CREATE INDEX idx_location ON properties USING GIST (location);
```

## PostGIS (External Extension)

**Purpose**: Geographic information system (GIS)

```sql
-- PostGIS must be installed separately (apt-get install postgis)

-- Common types
POINT                      -- Single point
LINESTRING                 -- Line
POLYGON                    -- Area
GEOGRAPHY(POINT, 4326)    -- For geographic coordinates

-- Common functions
ST_Distance(g1, g2)        -- Distance between geometries
ST_Within(g1, g2)         -- Is g1 within g2
ST_Contains(g1, g2)       -- Does g1 contain g2
ST_Intersects(g1, g2)      -- Do geometries intersect
```

**Example**:
```sql
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    coordinates GEOGRAPHY(POINT, 4326)
);

CREATE INDEX idx_locations_coords ON locations USING GIST (coordinates);

-- Find locations within 10km of a point
SELECT * FROM locations
WHERE ST_DWithin(
    coordinates,
    ST_MakePoint(-122.4194, 37.7749)::geography,
    10000  -- meters
);
```

## pg_stat_statements

**Purpose**: Track query performance statistics

```sql
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- View top queries by total time
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

## pg_partman

**Purpose**: Automatic partition management (external extension)

```sql
-- pg_partman handles:
-- - Automatic creation of new partitions
-- - Automatic archival of old partitions
-- - Partition maintenance automation

-- Requires installation: apt-get install postgresql-14-partman
```

## temporal tables (extends tablefunc)

For time-travel queries, consider temporal extensions or implement manually:
```sql
-- Manual approach: validity period
ALTER TABLE products ADD COLUMN valid_from TIMESTAMPTZ DEFAULT '-infinity';
ALTER TABLE products ADD COLUMN valid_to TIMESTAMPTZ DEFAULT 'infinity';

-- Use tstzrange for periods
ALTER TABLE product_pricing ADD COLUMN period TSTZRANGE;
```

## Extension Quick Reference

| Extension | Purpose | When to Use |
|-----------|---------|-------------|
| `uuid-ossp` | UUID generation | Primary keys, distributed systems |
| `pgcrypto` | Hashing/encryption | Password storage, sensitive data |
| `pg_trgm` | Fuzzy search | Search features, typo tolerance |
| `fuzzystrmatch` | String similarity | Name matching, deduplication |
| `hstore` | Key-value store | Dynamic attributes |
| `citext` | Case-insensitive text | Emails, usernames, tags |
| `btree_gin` | GIN for btree types | Array/RANGE columns |
| `btree_gist` | GiST for btree types | Exclusion constraints |
| `pg_stat_statements` | Query statistics | Performance tuning |

## Checking Installed Extensions

```sql
-- List installed extensions
SELECT * FROM pg_extension;

-- Check if specific extension is available
SELECT * FROM pg_available_extensions WHERE name = 'uuid-ossp';

-- Check extension version
SELECT extversion FROM pg_extension WHERE extname = 'uuid-ossp';
```

## Security Considerations

1. **Only enable extensions you need** - Each extension adds surface area
2. **pgcrypto requires superuser** for some functions - Use carefully
3. **PostGIS** may expose sensitive location data - Implement access controls
