# NovaStore - E-Commerce Database Management System

## Project Overview
NovaStore is an e-commerce database management project developed using Microsoft SQL Server. It manages product, category, customer, and order information and provides reporting queries for business analysis.

## Technologies
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL

## Database Structure
The database consists of five relational tables:

- Categories
- Products
- Customers
- Orders
- OrderDetails

## SQL Concepts Used
- Database and table creation
- Primary Keys and Foreign Keys
- INSERT statements
- INNER JOIN and LEFT JOIN
- GROUP BY and ORDER BY
- Aggregate functions (COUNT, SUM)
- DATEDIFF
- SQL Views

## Reports
- Products with stock levels below 20
- Customer order information
- Products purchased by a specific customer
- Product counts by category
- Total spending by customer
- Days elapsed since each order

## View
Created `vw_SiparisOzet` to display customer, order, and product information in a single view.

## Database Diagram
The database relationship diagram is available in `NovaStore_Diagram.png`.
