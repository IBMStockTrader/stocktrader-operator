# Stock Trader Database Setup

This guide explains how to configure the database for the Stock Trader application, specifically the Portfolio service.

## Database Options

The Stock Trader Helm chart supports two database configurations:

1. **Internal PostgreSQL** - Uses the bundled [Bitnami PostgreSQL Helm subchart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) (default for development). This deploys a PostgreSQL instance within your Kubernetes cluster and automatically initializes the schema.
2. **External PostgreSQL** - Connects to an external PostgreSQL database hosted outside the cluster (recommended for production), such as Azure Database for PostgreSQL, AWS RDS, or any managed database service.

## Configuration

### Database Type Selection

Configure the database type in `values.yaml`:

```yaml
database:
  type: external  # or 'internal'
  kind: postgres
  external:
    host: your-database.postgres.database.azure.com
    port: 5432
    db: trader
    id: stocktrader
    password: YourSecurePassword
    ssl: true  # Required for Azure PostgreSQL and most cloud providers
```

### Liberty Server Configuration

The Portfolio service uses OpenLiberty, which requires JDBC configuration to connect to PostgreSQL. This configuration is provided via a central ConfigMap (`portfolio-postgres-config`) that is automatically configured based on your `database.type` setting:

- **Internal Database** (`database.type: internal`):
  - Configures connection to the PostgreSQL Helm subchart service
  - Uses non-SSL connection (`sslMode=disable`)
  - Connects to service name: `<release-name>-postgresql`

- **External Database** (`database.type: external`):
  - Configures connection to your external PostgreSQL server
  - Conditionally enables SSL based on `database.external.ssl` setting
  - Uses connection details from `database.external.*` values

The ConfigMap is mounted into the Portfolio pod at `/opt/ol/wlp/usr/servers/defaultServer/includes/postgres.xml` and contains the Liberty server datasource configuration.

## Database Schema

The Portfolio service requires the following tables to be created in your database:

```sql
-- Stock Trader Database Schema
CREATE TABLE IF NOT EXISTS Portfolio(
  owner VARCHAR(32) NOT NULL, 
  total DOUBLE PRECISION, 
  accountID VARCHAR(64), 
  PRIMARY KEY(owner)
);

CREATE TABLE IF NOT EXISTS Stock(
  owner VARCHAR(32) NOT NULL, 
  symbol VARCHAR(8) NOT NULL, 
  shares INTEGER, 
  price DOUBLE PRECISION, 
  total DOUBLE PRECISION, 
  dateQuoted VARCHAR(10), 
  commission DOUBLE PRECISION, 
  FOREIGN KEY (owner) REFERENCES Portfolio(owner) ON DELETE CASCADE, 
  PRIMARY KEY(owner, symbol)
);

CREATE TABLE IF NOT EXISTS cashaccount(
  owner VARCHAR(32) NOT NULL, 
  balance DOUBLE PRECISION, 
  currency VARCHAR(8), 
  PRIMARY KEY(owner)
);

-- Add currency constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'allowed_currencies'
  ) THEN
    ALTER TABLE cashaccount ADD CONSTRAINT allowed_currencies 
    CHECK (currency IN (
      'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 
      'EUR', 'GBP', 'HKD', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 
      'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 
      'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR'
    ));
  END IF;
END$$;
```

## Initializing an External Database

### Prerequisites

Install the PostgreSQL client on your local machine:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql-client

# macOS
brew install postgresql
```

### Execute the Initialization Script

1. **Save the schema** to a file (e.g., `init-database-schema.sql`) by copying the SQL from the Database Schema section above.

2. **Connect and execute** the script against your PostgreSQL database:

```bash
psql -h <your-host>.postgres.database.azure.com \
     -p 5432 \
     -U <your-username> \
     -d <your-database> \
     -f init-database-schema.sql
```

**Example for Azure PostgreSQL:**

```bash
psql -h remote-stocktrader-jonathan.postgres.database.azure.com \
     -p 5432 \
     -U stocktrader \
     -d trader \
     -f init-database-schema.sql
```

3. **Verify the tables were created:**

```bash
psql -h <your-host>.postgres.database.azure.com \
     -p 5432 \
     -U <your-username> \
     -d <your-database> \
     -c "\dt"
```

Or within an interactive psql session:

```sql
\dt
\d Portfolio
\d Stock
\d cashaccount
```

## Internal PostgreSQL Setup

If using the internal PostgreSQL subchart (`database.type: internal`), the PostgreSQL Helm subchart from Bitnami is deployed automatically, and the schema is initialized on first startup via the `postgresql.primary.initdb.scripts` configuration in `values.yaml`.

To enable the internal PostgreSQL:

```yaml
database:
  type: internal

postgresql:
  enabled: true
  auth:
    username: stocktrader
    password: changeme
    database: trader
```

**How it works:**
- The Bitnami PostgreSQL chart creates a StatefulSet with persistent storage
- The init script in `values.yaml` automatically creates the required tables
- The Portfolio service uses the `portfolio-postgres-config` ConfigMap
- No manual database initialization is required

**Service endpoint:** The PostgreSQL service is accessible within the cluster at `<release-name>-postgresql:5432`

## Troubleshooting

### Connection Issues

If the Portfolio service cannot connect to the database, check:

1. **Hostname resolution**: Ensure the database host is reachable from your Kubernetes cluster
2. **SSL configuration**: Azure PostgreSQL requires `ssl: true` in your values.yaml
3. **Credentials**: Verify the username and password in `database.external.id` and `database.external.password`
4. **Firewall rules**: Ensure your Kubernetes cluster's egress IPs are allowed in the database firewall

### View Portfolio Service Logs

```bash
kubectl logs -l app=portfolio -f
```

Look for connection errors like:
- `java.net.UnknownHostException` - Hostname cannot be resolved
- `SQL State = 08001` - Connection attempt failed
- `SSL required` - Enable SSL in values.yaml
