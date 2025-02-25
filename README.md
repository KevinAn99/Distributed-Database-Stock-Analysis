# Distributed-Database-Stock-Analysis
A term project for Advanced Database Management, implementing horizontal partitioning, replication, and query optimization on stock market data using MySQL and Python. The project evaluates data synchronization, query performance, and distributed database simulation using event schedulers.

# 📊 Distributed Database Stock Analysis  
**Term Project - Advanced Database Management**  
**Zhenghao An | Boston University MET | December 2024**  

## 🔍 Project Overview  
This project explores **distributed database design and optimization** by implementing **horizontal partitioning, replication, and query performance analysis** on **stock market data** using MySQL and Python. Due to limitations with multi-instance MySQL and PostgreSQL Citus, the project simulates a distributed system within a **single MySQL instance** and uses Python to simulate multiple nodes.  

## 📁 Repository Contents  
- **`Distributed-Database-Stock-Analysis.ipynb`** - Jupyter Notebook for data retrieval, processing, and performance testing.  
- **`Distributed-Database-Stock-Analysis.sql`** - SQL scripts for partitioning, replication, and event schedulers.  
- **`Distributed-Database-Stock-Analysis.pptx`** - Presentation summarizing project architecture, implementation, and findings.  
- **`project_stock_data.csv`** - Stock market dataset (2020-2023) collected from Yahoo Finance.  

## 📊 Dataset Information  
- **Data Source:** Yahoo Finance API  
- **Time Range:** 2020 - 2023  
- **Fields Included:**
  - Stock **open, close, adjusted close, high, low prices**
  - **Trading volume**
  - **Market distribution**
  - **Ticker symbols**  

## 🔧 System Implementation  
### **1️⃣ Data Partitioning**
- **Horizontal Partitioning**: Splitting stock data based on the **market field**.  

### **2️⃣ Data Replication**
- **Event Schedulers**: Simulating **asynchronous replication** by syncing stock data from a **source table** to a **target table**.  
- **Comparison**: Evaluating **MySQL event scheduler vs. MySQL asynchronous replication**.  

### **3️⃣ Query Performance Analysis**
- **Using `SHOW PROFILES` to analyze query execution times.**  
- **Comparing performance between raw stock tables vs. partitioned tables.**  

### **4️⃣ Data Synchronization & Consistency Testing**
- **Verifying data delay between source and target tables.**  
- **Ensuring correct synchronization of INSERT, UPDATE, and DELETE operations.**  
- **Testing the scheduled event for synchronizing key stocks (AAPL, GOOGL) across partitions.**  

## 📈 Key Findings  
- **Partitioning** improved query efficiency by **reducing query execution time**.  
- **Event schedulers** provided a lightweight alternative to MySQL asynchronous replication.  
- **Synchronization delay was within an acceptable range**, ensuring data consistency.  

## 🏆 Technologies Used  
- **MySQL** (Partitioning, Replication, Event Schedulers)  
- **Python (Jupyter Notebook, Pandas, Yahoo Finance API)**  
- **SQL Performance Analysis (SHOW PROFILES, Query Optimization)**  

## 🚀 How to Run the Project  
1. **Install Required Packages**  
   ```sh
   pip install pandas yfinance mysql-connector-python
2. Load the SQL Schema (Distributed-Database-Stock-Analysis.sql) into MySQL.
3. Run the Jupyter Notebook (Distributed-Database-Stock-Analysis.ipynb) for data retrieval and query analysis.
Analyze query performance with MySQL event schedulers.
## 🔗 References
1. Yahoo Finance API: Yahoo Finance
2. MySQL Documentation: MySQL Docs
## 👤 Author
Zhenghao An
## ⭐ Contributions & Feedback
If you find this project helpful, feel free to star ⭐ the repository and provide feedback!
## Disclaimer
This project was developed as part of my coursework at Boston University (BU MET Program). The contents of this repository represent my own work and do not include any proprietary course materials, data, or solutions provided by BU. If you are a current student, please adhere to BU’s academic integrity policies.
