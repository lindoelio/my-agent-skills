# PostgreSQL Naming Conventions

## Core Principles

1. **Consistency**: Use the same pattern everywhere
2. **Clarity**: Names should be self-documenting
3. **Brevity**: Shorter is better, but not at the cost of clarity
4. **PostgreSQL compatibility**: Avoid reserved words

## Tables

- **Format**: `plural_snake_case`
- **Examples**: `users`, `order_items`, `product_categories`

```sql
CREATE TABLE users (...);
CREATE TABLE order_items (...);
CREATE TABLE product_categories (...);
```

## Columns

- **Format**: `singular_snake_case`
- **Examples**: `user_id`, `created_at`, `is_active`

```sql
user_id, first_name, last_name, created_at, updated_at, is_verified, price_amount
```

## Primary Keys

| Pattern | Example | When to Use |
|---------|---------|-------------|
| `id` | Surrogate UUID | Default choice for new tables |
| `{table}_id` | `user_id`, `product_id` | When table name is compound |
| `{table}_pk` | `tenant_pk` | Only when ambiguity exists |

```sql
-- Preferred: simple id
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- For legacy serial IDs
id BIGSERIAL PRIMARY KEY

-- When table name is part of the key
tenant_id UUID REFERENCES tenants(id)
```

## Foreign Keys

- **Format**: `{referenced_table_singular}_id`
- **Examples**: `user_id`, `product_id`, `parent_category_id`

```sql
-- Correct
user_id UUID REFERENCES users(id)
product_id UUID REFERENCES products(id)

-- Avoid (redundant naming)
users_id (table already pluralized)
fk_user_id (冗長)
```

## Indexes

- **Format**: `idx_{table}_{column(s)}`
- **Examples**: `idx_users_email`, `idx_orders_user_id_created_at`

```sql
-- Single column
CREATE INDEX idx_users_email ON users(email);

-- Composite (include sort order for clarity)
CREATE INDEX idx_orders_user_id_created_at ON orders(user_id, created_at DESC);

-- Unique index
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

## Constraints

- **Format**: `{table}_{column}_{type}`
- **Types**: `pk`, `fk`, `unique`, `check`, `notnull`

```sql
-- Examples
users_email_unique     -- UNIQUE constraint
users_id_pk            -- Primary key
orders_user_id_fk     -- Foreign key
orders_status_check    -- CHECK constraint
users_email_notnull    -- NOT NULL
```

## Sequences

- **Format**: `{table}_{column}_seq`

```sql
-- For BIGSERIAL columns
users_id_seq
orders_id_seq
```

## Functions and Procedures

- **Format**: `{verb}_{noun(s)}`
- **Examples**: `get_user_by_email`, `calculate_order_total`, `update_audit_timestamp`

```sql
CREATE FUNCTION get_user_by_email(p_email VARCHAR)
CREATE FUNCTION calculate_order_total(p_order_id UUID)
CREATE PROCEDURE update_inventory(p_product_id UUID, p_quantity INTEGER)
```

## Triggers

- **Format**: `{table}_{action}_trigger` or `{table}_trg_{action}`

```sql
-- Before insert trigger
CREATE TRIGGER users_before_insert_trg
    BEFORE INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION set_created_at();

-- Audit trigger
CREATE TRIGGER orders_audit_trg
    AFTER UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION log_order_changes();
```

## Variables and Parameters

- **Format**: `p_{parameter_name}` for procedure parameters
- **Format**: `v_{variable_name}` for local variables

```sql
CREATE FUNCTION calculate_total(p_price DECIMAL, p_quantity INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    v_total := p_price * p_quantity;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;
```

## Reserved Words to Avoid

```
user, order, group, table, index, key, date, time, timestamp
select, insert, update, delete, create, drop, alter, grant
```

Use alternatives: `app_user`, `user_order`, `created_date`

## Summary Table

| Object Type | Format | Example |
|-------------|--------|---------|
| Table | plural_snake_case | `users` |
| Column | singular_snake_case | `user_id` |
| PK | `id` or `{table}_id` | `id` |
| FK | `{ref_table}_id` | `user_id` |
| Index | `idx_{table}_{col}` | `idx_users_email` |
| Constraint | `{table}_{col}_{type}` | `users_email_unique` |
| Sequence | `{table}_{col}_seq` | `users_id_seq` |
| Function | verb_noun | `get_user_by_email` |
| Trigger | `{table}_{action}_trg` | `users_before_insert_trg` |
