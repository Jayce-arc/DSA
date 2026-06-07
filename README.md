# Cafe 104 - Enterprise Point of Sale (POS) System

A modern, high-performance desktop POS system designed for coffee shops and fast-casual dining environments. Built entirely via programmatic UI construction in C# Windows Forms with a warm mocha-cream theme.

## 🚀 Key Features

* **100% Programmatic UI:** Built completely via backend code architecture to avoid toolbox dependencies and ensure crisp, dynamic window resizing rendering alignment metrics.
* **Enterprise Void Console:** Implements a realistic loss prevention audit trail featuring:
  * Live Manager/Admin PIN Overrides.
  * Line-Item (Partial) order modifications with dynamic total recalculation.
  * Real-time shrinkage/waste inventory inventory tracking logs.
* **Database Optimization:** High-concurrency schema using T-SQL Triggers to seamlessly handle price sync variations without degrading transaction turnaround.
* **Kitchen Slip Systems:** Integrated printable document rendering triggers to sync cashiers directly to barista preparation centers.

## 🛠️ Tech Stack
* **Language:** C# (.NET Framework / WinForms)
* **Database:** Microsoft SQL Server (T-SQL)
* **Data Access:** ADO.NET (Microsoft.Data.SqlClient) with full Async/Await execution pattern

## 📦 Database Setup
To deploy the backend schema, execute the queries found inside the `database_setup.sql` script within SQL Server Management Studio (SSMS).
