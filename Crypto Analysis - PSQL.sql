/*
===========================================================
   CRYPTO ANALYTICS PROJECT – PostgreSQL Implementation
===========================================================

 Project Overview:
This project demonstrates how relational databases (RDBMS) 
can be used to manage and analyze cryptocurrency trading data. 
The dataset is synthetic and generated using Faker library in Python, inspired by real-world crypto exchange 
records, and contains three main entities:

1. members      → User details such as member_id, name, and region
2. prices       → Historical daily close prices of cryptocurrencies
3. transactions → Trade records including price, quantity, and timestamp

The database is designed in PostgreSQL to show practical 
applications of SQL for analytics, reporting, and business insights.

Business Goal:
- Track user activity and trading volume
- Analyze crypto price trends
- Identify top traders and active regions
- Generate KPIs useful for product, finance, and operations teams

===========================================================
*/

/* ------------------------------------- Task 1- Setting up Data Base, Normalizing, Creating & Importing Data into Created Tables  ----------------------------- */ 


--                             Create Database
CREATE analytics_cryptodb
-- Create Schema
-- Create members table
CREATE TABLE members (
  member_id   INTEGER PRIMARY KEY,
  name        VARCHAR(120) NOT NULL,
  region      VARCHAR(60)
);

-- create prices table
CREATE TABLE prices (
  price_id    BIGSERIAL PRIMARY KEY,
  timestamp   DATE NOT NULL,
  ticker      VARCHAR(10) NOT NULL,
  open_price  NUMERIC(18,8),
  high_price  NUMERIC(18,8),
  low_price   NUMERIC(18,8),
  close_price NUMERIC(18,8),
  volume      NUMERIC(24,8),
  UNIQUE(price_id, timestamp)
);


-- create transactions table
CREATE TABLE transactions (
  tx_id        BIGINT PRIMARY KEY,
  member_id    INTEGER NOT NULL,
  ticker       VARCHAR(10) NOT NULL,
  tx_timestamp TIMESTAMP NOT NULL,
  side         VARCHAR(4) NOT NULL CHECK (side IN ('BUY','SELL')),
  quantity     NUMERIC(18,8) NOT NULL,
  price        NUMERIC(18,8) NOT NULL,
  fee          NUMERIC(18,8) NOT NULL,
  CONSTRAINT fk_tx_member FOREIGN KEY (member_id) REFERENCES members(member_id)
);

---- Importing Excel files into analytics_cryptodb tables using pgadmin
 \copy members(member_id,name,region) FROM 'C:\Users\sarve\Downloads\members_fresh.csv' DELIMITER ',' CSV HEAD
ER;
\copy prices(timestamp,ticker,open_price,high_price,low_price,close_price,volume) FROM 'C:\Users\sarve\Downlo
ads\prices_fresh.csv' DELIMITER ',' CSV HEADER;

\copy transactions(tx_id,member_id,ticker,tx_timestamp,side,quantity,price,fee) FROM 'C:\Users\sarve\Download
s\transactions_fresh.csv' DELIMITER ',' CSV HEADER;

/* ------------------------------------- Task 2:- Basic & Advanced Analysis ----------------------------- */

/*1.Write a query to find distinct available Ticker in ascending order ****/

SELECT DISTINCT Ticker FROM prices ORDER BY Ticker Asc;

/*2.Write a query to find list of members from different region`s ****/

SELECT region, COUNT(*) AS members
FROM members
GROUP BY region
ORDER BY members DESC;

/*3.Write a query to find count of traders in Members Table  ****/

SELECT Count(member_id) as Total_Traders
FROM members


/*4.Write a query to find most traded ticker`s based on transaction count  ****/

SELECT Ticker, COUNT(*) AS trades
FROM transactions
GROUP BY Ticker
ORDER BY trades DESC
LIMIT 5;

/*5.Write a query to find average trade size (quantity) by symbol  ****/

SELECT Ticker,
       ROUND(AVG(quantity), 4) AS avg_trade_size
FROM transactions
GROUP BY Ticker
ORDER BY avg_trade_size DESC;

/*6.Write a query to find average prices per ticker  ****/

SELECT Ticker,
       ROUND(AVG(close_price), 2) AS avg_price
FROM prices
GROUP BY Ticker
ORDER BY avg_price DESC;

/*7.Write a query to find daily active members( Who trades uniquely)  ****/

SELECT DATE(tx_timestamp) AS trade_date,
       COUNT(DISTINCT member_id) AS active_members
FROM transactions
GROUP BY trade_date
ORDER BY trade_date;

/*8.Write a query to find monthly trading volume per ticker ****/

SELECT Ticker,
       DATE_TRUNC('month', tx_timestamp)::date AS month,
       SUM(quantity) AS total_volume
FROM transactions
GROUP BY Ticker, month
ORDER BY Ticker, month;

/*9.Write a query to find most recent transaction per each individual ****/

SELECT member_id,
       MAX(tx_timestamp) AS last_trade
FROM transactions
GROUP BY member_id
ORDER BY last_trade DESC;

/*10.Write a query to find total transactions and trade value  ****/

SELECT COUNT(*) AS total_trades,
       ROUND(SUM(price * quantity), 2) AS total_traded_value
FROM transactions;

/*11.Write a query to find average fee percentage per ticker ****/

SELECT ticker,
       ROUND(AVG(fee / NULLIF(price * quantity,0) * 100), 4) AS avg_fee_pct
FROM transactions
GROUP BY ticker
ORDER BY avg_fee_pct DESC;

/*12.Write a query to find most top 10 members by trade count ****/

SELECT t.member_id, m.name, COUNT(*) AS trades
FROM transactions t
JOIN members m USING (member_id)
GROUP BY t.member_id, m.name
ORDER BY trades DESC
LIMIT 10;

/*13.Write a query to find over all profit and loss per member ****/

SELECT t.member_id, m.name,
       ROUND(SUM(CASE WHEN side='SELL' THEN price * quantity ELSE 0 END)
           - SUM(CASE WHEN side='BUY' THEN price * quantity ELSE 0 END), 2) AS net_cashflow
FROM transactions t
JOIN members m ON m.member_id = t.member_id
GROUP BY t.member_id, m.name
ORDER BY net_cashflow DESC
LIMIT 20;

/*14.Write a query to find monthly active users  ****/

SELECT date_trunc('month', tx_timestamp)::date AS month,
       COUNT(DISTINCT member_id) AS mau
FROM transactions
GROUP BY 1
ORDER BY 1;

/*15.Write a query to find most traded regions based on trade value  ****/

SELECT m.region,
       ROUND(SUM(t.price * t.quantity), 2) AS region_traded_value
FROM transactions t
JOIN members m ON t.member_id = m.member_id
GROUP BY m.region
ORDER BY region_traded_value DESC;

/*16.Write a query to find average price per ticker ****/

SELECT Ticker,
       ROUND(AVG(close_price), 2) AS avg_price
FROM prices
GROUP BY Ticker
ORDER BY avg_price DESC;

/*17.Write a query to find last day closing price per ticker  ****/

SELECT p.Ticker, p.timestamp, p.close_price
FROM prices p
JOIN (
  SELECT Ticker, MAX(timestamp) AS max_ts FROM prices GROUP BY Ticker
) x ON x.Ticker = p.Ticker AND x.max_ts = p.timestamp
ORDER BY p.Ticker;

/*18.Write a query to find the traders who traded with more than 3 tickers  ****/

SELECT t.member_id, m.name, COUNT(DISTINCT t.Ticker) AS distinct_tickers
FROM transactions t
JOIN members m ON m.member_id = t.member_id
GROUP BY t.member_id, m.name
HAVING COUNT(DISTINCT t.Ticker) > 3
ORDER BY distinct_tickers DESC
LIMIT 50;

/*19.Write a query to find the market share of each ticker  ****/

WITH total_by_ticker AS (
  SELECT Ticker, SUM(price * quantity) AS traded_value
  FROM transactions
  GROUP BY Ticker
),
total_all AS (
  SELECT SUM(traded_value) AS all_value FROM total_by_ticker
)
SELECT s.Ticker,
       ROUND(s.traded_value::numeric,2) AS traded_value,
       ROUND( (s.traded_value / t.all_value) * 100, 2) AS market_share_pct
FROM total_by_ticker s, total_all t
ORDER BY traded_value DESC;

/*20.Write a query to find the members for >60 days  ****/

WITH last_trade AS (
  SELECT member_id, MAX(tx_timestamp)::date AS last_trade_date
  FROM transactions
  GROUP BY member_id
)
SELECT member_id, last_trade_date,
       (current_date - last_trade_date) AS days_inactive
FROM last_trade
WHERE current_date - last_trade_date > 60
ORDER BY days_inactive DESC
LIMIT 100;

/*21.Write a query to find daily Correlation between Etherium(ETH) quantity vs Etherium(ETH) close price ****/

WITH daily_qty AS (
  SELECT date(tx_timestamp) AS day, SUM(quantity) AS daily_qty
  FROM transactions WHERE Ticker='ETH' GROUP BY day
),
daily_price AS (
  SELECT timestamp AS day, AVG(close_price) AS avg_close
  FROM prices WHERE Ticker='ETH' GROUP BY timestamp
)
SELECT CORR(daily_qty, avg_close) AS corr_qty_price
FROM daily_qty d JOIN daily_price p ON d.day = p.day;

-- Thank You