#/bin/bash!
# PostgreSQL Ready4Use configuration script
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update
# helm install stocktrader-db bitnami/postgresql \
#   --namespace stocktrader \
#   --set auth.username=stocktrader \
#   --set auth.password=stocktrader \
#   --set auth.database=stocktrader


helm repo add ibm-db2 https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm repo update

helm install stocktrader-db2 ibm-db2/db2u \
  --namespace stocktrader \
  --set db2inst1.password=stocktrader \
  --set db2inst1.username=db2inst1 \
  --set db2inst1.dbname=stocktrader


  #Script to create tables
CREATE TABLE IF NOT EXISTS Portfolio(owner VARCHAR(32) NOT NULL, total DOUBLE PRECISION, accountID VARCHAR(64), PRIMARY KEY(owner));
CREATE TABLE IF NOT EXISTS Stock(owner VARCHAR(32) NOT NULL, symbol VARCHAR(8) NOT NULL, shares INTEGER, price DOUBLE PRECISION, total DOUBLE PRECISION, dateQuoted VARCHAR(10), commission DOUBLE PRECISION, FOREIGN KEY (owner) REFERENCES Portfolio(owner) ON DELETE CASCADE, PRIMARY KEY(owner, symbol));
CREATE TABLE IF NOT EXISTS cashaccount(owner VARCHAR(32) NOT NULL, balance DOUBLE PRECISION, currency VARCHAR(8), PRIMARY KEY(owner));
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'allowed_currencies') THEN
    ALTER TABLE cashaccount ADD CONSTRAINT allowed_currencies CHECK (currency IN ('AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP', 'HKD', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR'));
  END IF;
END$$; 

