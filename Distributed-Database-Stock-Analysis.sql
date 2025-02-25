USE stock_project;
CREATE TABLE stock_data (
    date DATE NOT NULL,
    adj_close DECIMAL(15, 4),
    close DECIMAL(15, 4),
    high DECIMAL(15, 4),
    low DECIMAL(15, 4),
    open DECIMAL(15, 4),
    volume BIGINT,
    ticker VARCHAR(10),
    market VARCHAR(10),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ticker, date)
);
SHOW TABLES;
select * from stock_data;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE                 
);


CREATE TABLE stocks (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL,
    exchange_id INT NOT NULL,
    industry VARCHAR(255),
    FOREIGN KEY (exchange_id) REFERENCES exchanges(exchange_id) ON DELETE CASCADE ON UPDATE CASCADE 
);


CREATE TABLE exchanges (
    exchange_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255),
    timezone VARCHAR(255)
);


CREATE TABLE trades (
    trade_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    stock_id INT NOT NULL,
    trade_date DATE NOT NULL,
    quantity INT NOT NULL,
    trade_type ENUM('BUY', 'SELL') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE portfolios (
    portfolio_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    stock_id INT NOT NULL,
    quantity_hold INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE market_data (
    market_data_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_id INT NOT NULL,
    date DATE NOT NULL,
    open_price DECIMAL(15, 4),
    close_price DECIMAL(15, 4),
    volume BIGINT,
    high DECIMAL(15, 4),
    low DECIMAL(15, 4),
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE ON UPDATE CASCADE
);



-- create fragment tables
CREATE TABLE stock_data_us (
    date DATE NOT NULL,
    adj_close DECIMAL(15, 4),
    close DECIMAL(15, 4),
    high DECIMAL(15, 4),
    low DECIMAL(15, 4),
    open DECIMAL(15, 4),
    volume BIGINT,
    ticker VARCHAR(10),
    market VARCHAR(10),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ticker, date)
);
CREATE TABLE stock_data_eu (
    date DATE NOT NULL,
    adj_close DECIMAL(15, 4),
    close DECIMAL(15, 4),
    high DECIMAL(15, 4),
    low DECIMAL(15, 4),
    open DECIMAL(15, 4),
    volume BIGINT,
    ticker VARCHAR(10),
    market VARCHAR(10),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ticker, date)
);
CREATE TABLE stock_data_asian (
    date DATE NOT NULL,
    adj_close DECIMAL(15, 4),
    close DECIMAL(15, 4),
    high DECIMAL(15, 4),
    low DECIMAL(15, 4),
    open DECIMAL(15, 4),
    volume BIGINT,
    ticker VARCHAR(10),
    market VARCHAR(10),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ticker, date)
);

-- insert data to fragment tables
INSERT INTO stock_data_us
SELECT * FROM stock_data WHERE market = 'USA';

INSERT INTO stock_data_eu
SELECT * FROM stock_data WHERE market = 'EU';

INSERT INTO stock_data_asian
SELECT * FROM stock_data WHERE market = 'Asian';



-- create target tables
CREATE TABLE stock_data_us_target LIKE stock_data_us;
CREATE TABLE stock_data_eu_target LIKE stock_data_eu;
CREATE TABLE stock_data_asian_target LIKE stock_data_asian;

-- insert dataset to target tables
INSERT INTO stock_data_us_target SELECT * FROM stock_data_us;
INSERT INTO stock_data_eu_target SELECT * FROM stock_data_eu;
INSERT INTO stock_data_asian_target SELECT * FROM stock_data_asian;


-- replication
DELIMITER //

CREATE EVENT sync_us_table
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    INSERT INTO stock_data_us_target
    SELECT * FROM stock_data_us
    WHERE updated_at >= NOW() - INTERVAL 1 MINUTE
    ON DUPLICATE KEY UPDATE
        adj_close = VALUES(adj_close),
        close = VALUES(close),
        high = VALUES(high),
        low = VALUES(low),
        open = VALUES(open),
        volume = VALUES(volume),
        market = VALUES(market);

    DELETE FROM stock_data_us_target
    WHERE NOT EXISTS (
        SELECT 1 FROM stock_data_us
        WHERE stock_data_us_target.ticker = stock_data_us.ticker
          AND stock_data_us_target.date = stock_data_us.date
    );
END //
DELIMITER ;

DELIMITER //

CREATE EVENT sync_eu_table
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    INSERT INTO stock_data_eu_target
    SELECT * FROM stock_data_eu
    WHERE updated_at >= NOW() - INTERVAL 1 MINUTE
    ON DUPLICATE KEY UPDATE
        adj_close = VALUES(adj_close),
        close = VALUES(close),
        high = VALUES(high),
        low = VALUES(low),
        open = VALUES(open),
        volume = VALUES(volume),
        market = VALUES(market);

    DELETE FROM stock_data_eu_target
    WHERE NOT EXISTS (
        SELECT 1 FROM stock_data_eu
        WHERE stock_data_eu_target.ticker = stock_data_eu.ticker
          AND stock_data_eu_target.date = stock_data_eu.date
    );
END //

DELIMITER ;

DELIMITER //

CREATE EVENT sync_asian_table
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    INSERT INTO stock_data_asian_target
    SELECT * FROM stock_data_asian
    WHERE updated_at >= NOW() - INTERVAL 1 MINUTE
    ON DUPLICATE KEY UPDATE
        adj_close = VALUES(adj_close),
        close = VALUES(close),
        high = VALUES(high),
        low = VALUES(low),
        open = VALUES(open),
        volume = VALUES(volume),
        market = VALUES(market);

    DELETE FROM stock_data_asian_target
    WHERE NOT EXISTS (
        SELECT 1 FROM stock_data_asian
        WHERE stock_data_asian_target.ticker = stock_data_asian.ticker
          AND stock_data_asian_target.date = stock_data_asian.date
    );
END //

DELIMITER ;

DELIMITER //



Show tables;


SET GLOBAL event_scheduler = ON;
-- Read and write performance analysis
-- 1
SET profiling = 1;
-- original table query
SELECT * FROM stock_data WHERE market = 'USA';
-- horizontal fragment table query
SELECT * FROM stock_data_us;
SHOW PROFILES;


-- Test write performance: Analyze whether the data write speed is affected by the fragmentation 

-- original table insert
INSERT INTO stock_data (date, adj_close, close, high, low, open, volume, ticker, market)
VALUES (CURDATE(), 150.0, 155.0, 160.0, 145.0, 150.0, 1000000, 'AAPL', 'USA');

-- horizontal fragment table insert
INSERT INTO stock_data_us (date, adj_close, close, high, low, open, volume, ticker, market)
VALUES (CURDATE(), 150.0, 155.0, 160.0, 145.0, 150.0, 1000000, 'AAPL', 'USA');
SHOW PROFILES;

-- Data delay 

INSERT INTO stock_data_us (date, adj_close, close, high, low, open, volume, ticker, market)
VALUES ('2025-12-04', 150.0, 155.0, 160.0, 145.0, 150.0, 1000000, 'AAPL', 'USA');
-- after 1 minute
SELECT * FROM stock_data_us_target WHERE ticker = 'AAPL' AND date = '2025-12-04';
SELECT * FROM stock_data_us_target;
-- Data  consistency

INSERT INTO stock_data_us (date, adj_close, close, high, low, open, volume, ticker, market)
VALUES ('2023-12-26', 150.0, 155.0, 160.0, 145.0, 150.0, 1000000, 'GOOGL', 'USA');
-- about 1min insert
SELECT * FROM stock_data_us_target WHERE ticker = 'GOOGL';

UPDATE stock_data_us SET adj_close = 205.0 WHERE ticker = 'GOOGL';
-- less than 1 min update
SELECT * FROM stock_data_us_target WHERE ticker = 'GOOGL';

DELETE FROM stock_data_us WHERE ticker = 'GOOGL';
-- less than 1 min delete
SELECT * FROM stock_data_us_target WHERE ticker = 'GOOGL';


DELIMITER //

CREATE EVENT sync_key_stocks_us_to_eu
ON SCHEDULE EVERY 1 MINUTE
DO BEGIN
    
    INSERT INTO stock_data_eu (date, adj_close, close, high, low, open, volume, ticker, market, updated_at)
    SELECT date, adj_close, close, high, low, open, volume, ticker, market, updated_at
    FROM stock_data_us
    WHERE ticker IN ('AAPL', 'GOOGL') 
      AND updated_at >= NOW() - INTERVAL 1 MINUTE 
    ON DUPLICATE KEY UPDATE
        adj_close = VALUES(adj_close),
        close = VALUES(close),
        high = VALUES(high),
        low = VALUES(low),
        open = VALUES(open),
        volume = VALUES(volume),
        market = VALUES(market),
        updated_at = VALUES(updated_at);

    DELETE FROM stock_data_eu
    WHERE ticker IN ('AAPL', 'GOOGL')
      AND NOT EXISTS (
          SELECT 1 FROM stock_data_us
          WHERE stock_data_us.ticker = stock_data_eu.ticker
            AND stock_data_us.date = stock_data_eu.date
      );
END //

DELIMITER ;

INSERT INTO stock_data_us (date, adj_close, close, high, low, open, volume, ticker, market)
VALUES ('2023-12-04', 150.0, 155.0, 160.0, 145.0, 150.0, 1000000, 'AAPL', 'USA');

-- about 1 min
SELECT * FROM stock_data_eu WHERE ticker = 'AAPL';


