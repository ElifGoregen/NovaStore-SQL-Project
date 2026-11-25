
-- =====================================================
-- PROJE ADI: NovaStore E-Ticaret Veri Yönetim Sistemi
-- PROJE AMACI:
-- E-ticaret sistemindeki kategori, ürün, müşteri ve
-- sipariş verilerini SQL Server kullanarak yönetmek
-- ve çeşitli raporlama sorguları oluşturmaktır.
-- =====================================================


-- =====================================================
-- 1. VERITABANI OLUŞTURMA
-- =====================================================

-- Veritabanı mevcut değilse oluşturulur.
-- Mevcut veritabanı kesinlikle silinmez.

USE master;
GO

IF DB_ID('NovaStoreDB') IS NULL
BEGIN
    EXEC('CREATE DATABASE NovaStoreDB');
END;
GO

USE NovaStoreDB;
GO


-- =====================================================
-- 2. TABLOLARIN OLUŞTURULMASI
-- =====================================================

-- 2.1 CATEGORIES TABLOSU

IF OBJECT_ID('dbo.Categories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories
    (
        CategoryID INT IDENTITY(1,1) PRIMARY KEY,
        CategoryName VARCHAR(50) NOT NULL
    );
END;
GO


-- 2.2 PRODUCTS TABLOSU

IF OBJECT_ID('dbo.Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products
    (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName VARCHAR(100) NOT NULL,
        Price DECIMAL(10,2),
        Stock INT DEFAULT 0,
        CategoryID INT,
        FOREIGN KEY (CategoryID)
            REFERENCES dbo.Categories(CategoryID)
    );
END;
GO


-- 2.3 CUSTOMERS TABLOSU

-- NOT: Mevcut veritabanımızdaki sütun adı CustomerID'dir.
-- Bu nedenle aynı isim korunmuştur.

IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers
    (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        FullName VARCHAR(50) NOT NULL,
        City VARCHAR(20),
        Email VARCHAR(100) UNIQUE
    );
END;
GO


-- 2.4 ORDERS TABLOSU

IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders
    (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(10,2),
        FOREIGN KEY (CustomerID)
            REFERENCES dbo.Customers(CustomerID)
    );
END;
GO


-- 2.5 ORDERDETAILS TABLOSU

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderDetails
    (
        DetailID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL,
        FOREIGN KEY (OrderID)
            REFERENCES dbo.Orders(OrderID),
        FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID)
    );
END;
GO


-- =====================================================
-- 3. TABLOLARA ÖRNEK VERİLERİN EKLENMESİ
-- =====================================================

-- Her tabloya yalnızca boşsa örnek veri eklenir.
-- Böylece script tekrar çalıştırıldığında
-- mevcut kayıtlar çoğaltılmaz.


-- 3.1 CATEGORIES TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
BEGIN
    INSERT INTO dbo.Categories (CategoryName)
    VALUES
    ('Elektronik'),
    ('Giyim'),
    ('Kitap'),
    ('Ev ve Yaşam'),
    ('Spor');
END;


-- 3.2 PRODUCTS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    INSERT INTO dbo.Products
    (ProductName, Price, Stock, CategoryID)
    VALUES
    ('Laptop', 25000, 15, 1),
    ('Telefon', 18000, 25, 1),
    ('Kulaklık', 1200, 40, 1),
    ('Tisört', 450, 30, 2),
    ('Pantolon', 900, 18, 2),
    ('SQL Kitabi', 350, 12, 3),
    ('Roman', 200, 35, 3),
    ('Kahve Makinesi', 3200, 10, 4),
    ('Yoga Mati', 600, 22, 5),
    ('Dambil', 1500, 8, 5);
END;


-- 3.3 CUSTOMERS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Customers)
BEGIN
    INSERT INTO dbo.Customers
    (FullName, City, Email)
    VALUES
    ('Elif Göregen', 'Bursa', 'elif@gmail.com'),
    ('Eren Göregen', 'Antalya', 'eren@gmail.com'),
    ('Enes Göregen', 'Kars', 'enes@gmail.com'),
    ('Enes Ağırman', 'İstanbul', 'enesa@gmail.com'),
    ('Canan Coşar', 'Bursa', 'canan@gmail.com');
END;


-- 3.4 ORDERS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Orders)
BEGIN
    INSERT INTO dbo.Orders
    (CustomerID, OrderDate, TotalAmount)
    VALUES
    (1, '2026-11-20T10:00:00', 26200),
    (1, '2026-11-21T14:30:00', 1350),
    (2, '2026-11-22T11:00:00', 18450),
    (2, '2026-11-23T16:00:00', 3200),
    (3, '2026-11-23T12:00:00', 2700),
    (4, '2026-11-24T13:00:00', 2100),
    (4, '2026-11-24T17:00:00', 25000),
    (5, '2026-11-25T09:00:00', 1800);
END;


-- 3.5 ORDERDETAILS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.OrderDetails)
BEGIN
    INSERT INTO dbo.OrderDetails
    (OrderID, ProductID, Quantity)
    VALUES
    (1, 1, 1),
    (1, 3, 1),
    (2, 4, 3),
    (3, 2, 1),
    (3, 4, 1),
    (4, 8, 1),
    (5, 5, 3),
    (6, 6, 6),
    (7, 1, 1),
    (8, 9, 3);
END;
GO


-- =====================================================
-- 4. RAPORLAMA VE SORGULAMA İŞLEMLERİ
-- =====================================================

-- 4.1 STOK MİKTARI 20'DEN AZ OLAN ÜRÜNLER

SELECT
    ProductName,
    Stock
FROM dbo.Products
WHERE Stock < 20
ORDER BY Stock DESC;


-- 4.2 MÜŞTERİLERİN SİPARİŞ BİLGİLERİ

SELECT
    c.FullName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID;


-- 4.3 BELİRLİ BİR MÜŞTERİNİN SATIN ALDIĞI ÜRÜNLER

SELECT
    c.FullName,
    o.OrderID,
    cat.CategoryName,
    p.ProductName,
    od.Quantity,
    p.Price
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
INNER JOIN dbo.Categories AS cat
    ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Elif Göregen';


-- 4.4 KATEGORİLERE GÖRE ÜRÜN SAYISI

SELECT
    c.CategoryName,
    COUNT(p.ProductID) AS ProductCount
FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName;


-- 4.5 MÜŞTERİLERİN TOPLAM HARCAMALARI

SELECT
    c.FullName,
    SUM(o.TotalAmount) AS TotalRevenue
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY TotalRevenue DESC;


-- 4.6 SİPARİŞLERİN ÜZERİNDEN GEÇEN GÜN SAYISI

SELECT
    OrderID,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder
FROM dbo.Orders;



-- =====================================================
-- 5. VIEW OLUŞTURMA
-- =====================================================

USE NovaStoreDB;
GO
CREATE VIEW dbo.vw_SiparisOzet AS
SELECT 
    c.FullName,
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    od.Quantity,
    p.Price
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID;
GO

SELECT *
FROM dbo.vw_SiparisOzet;


-- =====================================================
-- PROJE ADI: NovaStore E-Ticaret Veri Yönetim Sistemi
-- PROJE AMACI:
-- E-ticaret sistemindeki kategori, ürün, müşteri ve
-- sipariş verilerini SQL Server kullanarak yönetmek
-- ve çeşitli raporlama sorguları oluşturmaktır.
-- =====================================================


-- =====================================================
-- 1. VERITABANI OLUŞTURMA
-- =====================================================

-- Veritabanı mevcut değilse oluşturulur.
-- Mevcut veritabanı kesinlikle silinmez.

USE master;
GO

IF DB_ID('NovaStoreDB') IS NULL
BEGIN
    EXEC('CREATE DATABASE NovaStoreDB');
END;
GO

USE NovaStoreDB;
GO


-- =====================================================
-- 2. TABLOLARIN OLUŞTURULMASI
-- =====================================================

-- 2.1 CATEGORIES TABLOSU

IF OBJECT_ID('dbo.Categories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories
    (
        CategoryID INT IDENTITY(1,1) PRIMARY KEY,
        CategoryName VARCHAR(50) NOT NULL
    );
END;
GO


-- 2.2 PRODUCTS TABLOSU

IF OBJECT_ID('dbo.Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products
    (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName VARCHAR(100) NOT NULL,
        Price DECIMAL(10,2),
        Stock INT DEFAULT 0,
        CategoryID INT,
        FOREIGN KEY (CategoryID)
            REFERENCES dbo.Categories(CategoryID)
    );
END;
GO


-- 2.3 CUSTOMERS TABLOSU

-- NOT: Mevcut veritabanımızdaki sütun adı CustomerID'dir.
-- Bu nedenle aynı isim korunmuştur.

IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers
    (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        FullName VARCHAR(50) NOT NULL,
        City VARCHAR(20),
        Email VARCHAR(100) UNIQUE
    );
END;
GO


-- 2.4 ORDERS TABLOSU

IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders
    (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(10,2),
        FOREIGN KEY (CustomerID)
            REFERENCES dbo.Customers(CustomerID)
    );
END;
GO


-- 2.5 ORDERDETAILS TABLOSU

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderDetails
    (
        DetailID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL,
        FOREIGN KEY (OrderID)
            REFERENCES dbo.Orders(OrderID),
        FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID)
    );
END;
GO


-- =====================================================
-- 3. TABLOLARA ÖRNEK VERİLERİN EKLENMESİ
-- =====================================================

-- Her tabloya yalnızca boşsa örnek veri eklenir.
-- Böylece script tekrar çalıştırıldığında
-- mevcut kayıtlar çoğaltılmaz.


-- 3.1 CATEGORIES TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
BEGIN
    INSERT INTO dbo.Categories (CategoryName)
    VALUES
    ('Elektronik'),
    ('Giyim'),
    ('Kitap'),
    ('Ev ve Yaşam'),
    ('Spor');
END;


-- 3.2 PRODUCTS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    INSERT INTO dbo.Products
    (ProductName, Price, Stock, CategoryID)
    VALUES
    ('Laptop', 25000, 15, 1),
    ('Telefon', 18000, 25, 1),
    ('Kulaklık', 1200, 40, 1),
    ('Tisört', 450, 30, 2),
    ('Pantolon', 900, 18, 2),
    ('SQL Kitabi', 350, 12, 3),
    ('Roman', 200, 35, 3),
    ('Kahve Makinesi', 3200, 10, 4),
    ('Yoga Mati', 600, 22, 5),
    ('Dambil', 1500, 8, 5);
END;


-- 3.3 CUSTOMERS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Customers)
BEGIN
    INSERT INTO dbo.Customers
    (FullName, City, Email)
    VALUES
    ('Elif Göregen', 'Bursa', 'elif@gmail.com'),
    ('Eren Göregen', 'Antalya', 'eren@gmail.com'),
    ('Enes Göregen', 'Kars', 'enes@gmail.com'),
    ('Enes Ağırman', 'İstanbul', 'enesa@gmail.com'),
    ('Canan Coşar', 'Bursa', 'canan@gmail.com');
END;


-- 3.4 ORDERS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.Orders)
BEGIN
    INSERT INTO dbo.Orders
    (CustomerID, OrderDate, TotalAmount)
    VALUES
    (1, '2026-11-20T10:00:00', 26200),
    (1, '2026-11-21T14:30:00', 1350),
    (2, '2026-11-22T11:00:00', 18450),
    (2, '2026-11-23T16:00:00', 3200),
    (3, '2026-11-23T12:00:00', 2700),
    (4, '2026-11-24T13:00:00', 2100),
    (4, '2026-11-24T17:00:00', 25000),
    (5, '2026-11-25T09:00:00', 1800);
END;


-- 3.5 ORDERDETAILS TABLOSU

IF NOT EXISTS (SELECT 1 FROM dbo.OrderDetails)
BEGIN
    INSERT INTO dbo.OrderDetails
    (OrderID, ProductID, Quantity)
    VALUES
    (1, 1, 1),
    (1, 3, 1),
    (2, 4, 3),
    (3, 2, 1),
    (3, 4, 1),
    (4, 8, 1),
    (5, 5, 3),
    (6, 6, 6),
    (7, 1, 1),
    (8, 9, 3);
END;
GO


-- =====================================================
-- 4. RAPORLAMA VE SORGULAMA İŞLEMLERİ
-- =====================================================

-- 4.1 STOK MİKTARI 20'DEN AZ OLAN ÜRÜNLER

SELECT
    ProductName,
    Stock
FROM dbo.Products
WHERE Stock < 20
ORDER BY Stock DESC;


-- 4.2 MÜŞTERİLERİN SİPARİŞ BİLGİLERİ

SELECT
    c.FullName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID;


-- 4.3 BELİRLİ BİR MÜŞTERİNİN SATIN ALDIĞI ÜRÜNLER

SELECT
    c.FullName,
    o.OrderID,
    cat.CategoryName,
    p.ProductName,
    od.Quantity,
    p.Price
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
INNER JOIN dbo.Categories AS cat
    ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Elif Göregen';


-- 4.4 KATEGORİLERE GÖRE ÜRÜN SAYISI

SELECT
    c.CategoryName,
    COUNT(p.ProductID) AS ProductCount
FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName;


-- 4.5 MÜŞTERİLERİN TOPLAM HARCAMALARI

SELECT
    c.FullName,
    SUM(o.TotalAmount) AS TotalRevenue
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY TotalRevenue DESC;


-- 4.6 SİPARİŞLERİN ÜZERİNDEN GEÇEN GÜN SAYISI

SELECT
    OrderID,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder
FROM dbo.Orders;



-- =====================================================
-- 5. VIEW OLUŞTURMA
-- =====================================================

USE NovaStoreDB;
GO
CREATE VIEW dbo.vw_SiparisOzet AS
SELECT 
    c.FullName,
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    od.Quantity,
    p.Price
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID;
GO

SELECT *
FROM dbo.vw_SiparisOzet;

-- =====================================================
-- 6. BACKUP İŞLEMİ
-- =====================================================

BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\NovaStoreDB_Final.bak'
WITH INIT,
     NAME = 'NovaStoreDB Final Full Backup';
GO

RESTORE VERIFYONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\NovaStoreDB_Final.bak';
GO

