# PostgreSQL Data Types Guide

## Choosing the Right Type

**Principles**:
1. Use the most specific type that fits your needs
2. Consider storage, indexing, and validation together
3. Prefer immutable types when possible

## Numeric Types

### Integer Family

| Type | Storage | Range | Use Case |
|------|---------|-------|----------|
| `SMALLINT` | 2 bytes | -32,768 to 32,767 | Age, small counts |
| `INTEGER` | 4 bytes | -2.1B to 2.1B | Default for counts, IDs |
| `BIGINT` | 8 bytes | -9 quintillion | Large counts, totals |
| `SMALLSERIAL` | 2 bytes | 1 to 32,767 | Auto-increment small |
| `SERIAL` | 4 bytes | 1 to 2.1B | Auto-increment default |
| `BIGSERIAL` | 8 bytes | 1 to 9 quintillion | Auto-increment large |

```sql
-- Prefer BIGSERIAL for production primary keys (handles more rows)
CREATE TABLE examples (
    id BIGSERIAL PRIMARY KEY,
    small_count SMALLINT DEFAULT 0,
    big_total BIGINT DEFAULT 0
);
```

### Decimal Types

| Type | Storage | Precision |
|------|---------|-----------|
| `NUMERIC(p,s)` or `DECIMAL(p,s)` | Variable | p = total digits, s = decimal places |
| `REAL` | 4 bytes | ~6 digits |
| `DOUBLE PRECISION` | 8 bytes | ~15 digits |

```sql
-- DECIMAL for money (exact precision)
price DECIMAL(10,2)        -- 99999999.99 max

-- REAL/DOUBLE for scientific values (speed, not precision)
measurement DOUBLE PRECISION
```

**Money Type**: PostgreSQL has a `MONEY` type, but DECIMAL is preferred for cross-database compatibility.

### Boolean

```sql
-- Explicit is better
is_active BOOLEAN DEFAULT true
is_verified BOOLEAN DEFAULT false

-- PostgreSQL accepts these as boolean:
-- 'true', 'false', 't', 'f', 'yes', 'no', '1', '0'
```

## Character Types

| Type | Storage | Max Size | Use When |
|------|---------|----------|----------|
| `CHAR(n)` | Fixed | 10,485,760 | Fixed-length (codes, SSN) |
| `VARCHAR(n)` | Variable | 10,485,760 | Bounded strings |
| `TEXT` | Variable | Unlimited | Truly unbounded text |

```sql
-- VARCHAR with explicit limit (preferred for most strings)
email VARCHAR(255)
phone VARCHAR(20)
name VARCHAR(100)

-- TEXT for content that truly has no upper bound
body TEXT                      -- blog post content
description TEXT                -- product descriptions

-- CHAR only for fixed-length data
country_code CHAR(2)           -- ISO country codes
currency_code CHAR(3)          -- ISO currency codes
```

## Date/Time Types

| Type | Storage | Range | Resolution |
|------|---------|-------|------------|
| `DATE` | 4 bytes | 4713 BC to 5874897 AD | Day |
| `TIME` | 8 bytes | 00:00 to 24:00 | Microsecond |
| `TIMETZ` | 12 bytes | Time with timezone | Microsecond |
| `TIMESTAMP` | 8 bytes | 4713 BC to 294276 AD | Microsecond |
| `TIMESTAMPTZ` | 8 bytes | UTC + timezone | Microsecond |

```sql
-- ALWAYS prefer TIMESTAMPTZ for timestamps
-- It stores UTC and converts to user's timezone automatically
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

-- DATE for calendar dates without times
birth_date DATE
subscription_end_date DATE

-- Avoid TIMESTAMP without TZ unless you explicitly need local time only
```

### Time Zone Handling

```sql
-- TIMESTAMPTZ is stored as UTC
created_at TIMESTAMPTZ DEFAULT NOW()

-- To extract in a specific timezone:
created_at AT TIME ZONE 'America/New_York'

-- To set session timezone:
SET TIME ZONE 'America/New_York';
```

## UUID Type

```sql
-- UUID for globally unique identifiers
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- UUID generation methods:
gen_random_uuid()              -- PostgreSQL 13+ (recommended)
uuid_generate_v4()             -- uuid-ossp extension
uuid_generate_v1mc()          -- Time-based UUID
```

**When to use UUID vs BIGSERIAL**:

| UUID | BIGSERIAL |
|------|-----------|
| Distributed systems | Single database |
| URLs that shouldn't expose counts | Auto-increment is acceptable |
| Merge/replicate databases | Performance-critical inserts |
| Security through obscurity | Simplicity preferred |

## JSON Types

| Type | Storage | Indexable | Use Case |
|------|---------|-----------|----------|
| `JSON` | Raw | No | Legacy compatibility |
| `JSONB` | Parsed/Binary | Yes (GIN) | Nearly all cases |

```sql
-- JSONB is almost always preferred
metadata JSONB

-- Create GIN index for efficient queries
CREATE INDEX idx_products_metadata ON products USING GIN (metadata);

-- Query JSONB
SELECT * FROM products WHERE metadata @> '{"color": "red"}';
SELECT metadata->>'brand' FROM products WHERE metadata ? 'brand';
```

## Array Types

```sql
-- PostgreSQL supports native arrays
email_addresses TEXT[],
phone_numbers CHAR(20)[3],

-- But prefer normalized tables for most cases
-- Arrays are good for:
-- - Tags/labels that don't need separate queries
-- - Simple coordinate pairs
-- - Quick prototyping
```

## Range Types

```sql
-- For temporal ranges (PostgreSQL 9.2+)
-- Useful for reservations, schedules, validity periods

-- Built-in range types:
INT4RANGE   -- integer range
INT8RANGE   -- bigint range
NUMRANGE    -- numeric range
TSRANGE     -- timestamp range (no timezone)
TSTZRANGE   -- timestamp with timezone range
DATERANGE   -- date range

-- Example: reservation system
CREATE TABLE room_reservations (
    room_id UUID,
    guest_name VARCHAR(100),
    stay_period TSTZRANGE,
    EXCLUDE USING GIST (room_id WITH =, stay_period WITH &&)
);
```

## Network Types

```sql
-- For IP addresses
ip_address INET           -- IPv4 or IPv6
ip_address CIDR           -- Network range
ip_address MACADDR        -- MAC addresses

-- Example
client_ip INET
server_network CIDR
```

## Geometric Types

| Type | Description |
|------|-------------|
| `POINT` | (x, y) coordinate |
| `LINE` | Infinite line |
| `LSEG` | Line segment |
| `BOX` | Rectangle |
| `PATH` | Polygon path |
| `POLYGON` | Polygon |
| `CIRCLE` | Circle |

```sql
-- Point is commonly used
location POINT            -- (x, y)
```

## PostgreSQL ENUM

**Caveat**: PostgreSQL ENUMs are mutable but changes require a lock. Consider VARCHAR with CHECK instead for frequently modified enums.

```sql
-- Simple ENUM
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');

-- Use as column type
status order_status DEFAULT 'pending'

-- Better for frequently changing enums (CHECK constraint)
status VARCHAR(20) CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'))
```

## Bytea (Binary Data)

```sql
-- For binary data (images, files)
file_data BYTEA

-- Better for large files: use S3/file storage, store URL in DB
```

## Composite Types

```sql
-- Define custom composite type
CREATE TYPE address AS (
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    country VARCHAR(2)
);

-- Use in tables
shipping_address address
```

## Default Values

```sql
-- Use DEFAULT keyword, not triggers for simple defaults
created_at TIMESTAMPTZ DEFAULT NOW()
updated_at TIMESTAMPTZ DEFAULT NOW()
is_active BOOLEAN DEFAULT true
priority INTEGER DEFAULT 0
```

## Type Casting and Coercion

```sql
-- Explicit cast
SELECT '2024-01-01'::DATE;
SELECT '123'::INTEGER;

-- Avoid implicit casts (they can be slow)
-- Good: parameterized queries with correct types
-- Bad: SELECT * FROM t WHERE id = '123' (string to int cast)
```

## Summary: Common Patterns

```sql
-- User table
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    avatar_url    VARCHAR(500),
    is_active     BOOLEAN DEFAULT true,
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Order table
CREATE TABLE orders (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id),
    status     VARCHAR(20) NOT NULL CHECK (status IN (...)),
    total      DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    metadata   JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```
