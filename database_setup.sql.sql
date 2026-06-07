/*******************************************************************************
 * PROJECT PORTFOLIO: Cafe 104 Point of Sale (POS) System - Backend Schema
 * DATABASE ENGINE:   Microsoft SQL Server (T-SQL)
 * SCHEMA VERSION:    2.1 (Enterprise Enhanced Void & Security Release)
 * * DESCRIPTION:
 * This script initializes the core database architecture for Cafe 104 POS.
 * Includes relationally linked schemas for employee access tracking, 
 * live cashier checkouts, real-time trigger-based data synchronization, 
 * and full ledger-audit structures for line-item loss prevention.
 ******************************************************************************/

USE [master];
GO

-- ══════════════════════════════════════════════════════════════════════════════
--  1. DATABASE INITIALIZATION
-- ══════════════════════════════════════════════════════════════════════════════
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Cafe104DB')
BEGIN
    ALTER DATABASE [Cafe104DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Cafe104DB];
END
GO

CREATE DATABASE [Cafe104DB];
GO

USE [Cafe104DB];
GO

-- ══════════════════════════════════════════════════════════════════════════════
--  2. TABLE SCHEMAS & RELATIONSHIPS
-- ══════════════════════════════════════════════════════════════════════════════

/****** Object: Table [dbo].[Employees] ******/
CREATE TABLE [dbo].[Employees](
    [EmployeeId]  INT IDENTITY(1,1) NOT NULL,
    [FullName]    NVARCHAR(100)     NOT NULL,
    [PinCode]     NVARCHAR(6)       NOT NULL,
    [Role]        NVARCHAR(50)      NOT NULL,
    [IsActive]    BIT               NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME          NOT NULL DEFAULT GETDATE(),
    [IsDeleted]   BIT               NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([EmployeeId] ASC)
);
GO

/****** Object: Table [dbo].[MenuOverrides] ******/
CREATE TABLE [dbo].[MenuOverrides](
    [MenuId]          INT             NOT NULL,
    [CustomPrice]     DECIMAL(18, 2)  NOT NULL,
    [CustomImagePath] VARCHAR(500)    NULL,
    CONSTRAINT [PK_MenuOverrides] PRIMARY KEY CLUSTERED ([MenuId] ASC)
);
GO

/****** Object: Table [dbo].[Transactions] ******/
CREATE TABLE [dbo].[Transactions](
    [Id]                     INT IDENTITY(1,1) NOT NULL,
    [TransactionDate]        DATETIME          NOT NULL,
    [OrderType]              VARCHAR(50)       NOT NULL,
    [TotalAmount]            DECIMAL(18, 2)    NOT NULL,
    [PaymentMethod]          VARCHAR(50)       NOT NULL,
    [DiscountApplied]        VARCHAR(50)       NOT NULL,
    [Subtotal]               DECIMAL(18, 2)    NULL,
    [TaxAmount]              DECIMAL(18, 2)    NULL,
    [EmployeeId]             INT               NULL,
    [DiscountIdNumber]       NVARCHAR(100)     NULL,
    [DiscountName]           NVARCHAR(150)     NULL,
    [DiscountDOB]            DATE              NULL,
    [DiscountDisabilityType] NVARCHAR(100)     NULL,
    [CardholderName]         NVARCHAR(100)     NULL,
    [CardType]               NVARCHAR(50)      NULL,
    [CardExpiry]             NVARCHAR(10)      NULL,
    [ReferenceNumber]        NVARCHAR(50)      NULL,
    [IsVoided]               BIT               NULL DEFAULT 0,
    [VoidedBy]               VARCHAR(100)      NULL,
    [VoidDate]               DATETIME          NULL,
    CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Transactions_Employees] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId])
);
GO

/****** Object: Table [dbo].[TransactionItems] ******/
CREATE TABLE [dbo].[TransactionItems](
    [Id]            INT IDENTITY(1,1) NOT NULL,
    [TransactionId] INT               NOT NULL,
    [ItemName]      NVARCHAR(100)     NOT NULL,
    [Quantity]      INT               NOT NULL,
    [Category]      NVARCHAR(100)     NULL,
    [Price]         DECIMAL(18, 2)    NULL,
    [UnitPrice]     DECIMAL(18, 2)    NULL,
    [IsVoided]      BIT               NOT NULL DEFAULT 0,
    [VoidReason]    NVARCHAR(100)     NULL,
    [DisposalType]  NVARCHAR(20)      NULL,
    CONSTRAINT [PK_TransactionItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

/****** Object: Table [dbo].[VoidLogs] ******/
CREATE TABLE [dbo].[VoidLogs](
    [Id]              INT IDENTITY(1,1) NOT NULL,
    [TransactionId]   INT               NOT NULL,
    [ReasonCode]      NVARCHAR(100)     NOT NULL,
    [VoidedBy]        NVARCHAR(100)     NOT NULL,
    [VoidDate]        DATETIME          NOT NULL DEFAULT GETDATE(),
    [IsFullVoid]      BIT               NOT NULL DEFAULT 0,
    [DisposalSummary] NVARCHAR(500)     NULL,
    CONSTRAINT [PK_VoidLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

-- ══════════════════════════════════════════════════════════════════════════════
--  3. BUSINESS METRIC INDEX OPTIMIZATIONS
-- ══════════════════════════════════════════════════════════════════════════
CREATE NONCLUSTERED INDEX [IX_Employees_PinCode] ON [dbo].[Employees] ([PinCode] ASC) INCLUDE ([EmployeeId], [FullName], [Role], [IsActive]);
CREATE NONCLUSTERED INDEX [IX_Transactions_TransactionDate] ON [dbo].[Transactions] ([TransactionDate] DESC) INCLUDE ([EmployeeId], [TotalAmount], [PaymentMethod]);
GO

-- ══════════════════════════════════════════════════════════════════════════════
--  4. ENTERPRISE AUTOMATION: PRICING CONCURRENCY TRIGGER
-- ══════════════════════════════════════════════════════════════════════════════
CREATE TRIGGER trg_SyncPrices
ON [dbo].[TransactionItems]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET t.UnitPrice = i.Price
    FROM [dbo].[TransactionItems] t
    INNER JOIN inserted i ON t.Id = i.Id
    WHERE i.UnitPrice IS NULL AND i.Price IS NOT NULL;
END
GO

-- ══════════════════════════════════════════════════════════════════════════════
--  5. COMPREHENSIVE PRODUCTION SEED DATA
-- ══════════════════════════════════════════════════════════════════════════════
SET IDENTITY_INSERT [dbo].[Employees] ON;
INSERT [dbo].[Employees] ([EmployeeId], [FullName], [PinCode], [Role], [IsActive], [CreatedDate], [IsDeleted]) VALUES 
(1, N'Angelica Gura', N'1234', N'Cashier', 1, '2026-04-16 06:17:13', 0),
(2, N'Lindsay Espina', N'5678', N'Cashier', 1, '2026-04-16 06:17:13', 0),
(3, N'Dustin Yara', N'1234', N'Manager', 1, '2026-05-04 04:16:28', 0),
(4, N'System Admin', N'0000', N'Admin', 1, '2026-04-20 08:12:03', 0),
(16, N'Gab Velarde', N'7777', N'Barista', 1, '2026-05-16 11:07:04', 0);
SET IDENTITY_INSERT [dbo].[Employees] OFF;
GO

SET IDENTITY_INSERT [dbo].[Transactions] ON;
INSERT [dbo].[Transactions] ([Id], [TransactionDate], [OrderType], [TotalAmount], [PaymentMethod], [DiscountApplied], [Subtotal], [TaxAmount], [EmployeeId], [IsVoided], [VoidedBy], [VoidDate]) VALUES 
(61, '2026-05-04 05:50:17', N'Dine-in', 170.00, N'Card', N'None', 151.79, 18.21, 1, 0, NULL, NULL),
(62, '2026-05-04 06:16:41', N'Dine-in', 150.00, N'Card', N'None', 133.93, 16.07, 1, 0, NULL, NULL),
(68, '2026-05-10 07:28:52', N'Dine-in', 165.00, N'Cash', N'None', 147.32, 17.68, 1, 1, N'Dustin Yara', '2026-05-25 16:48:30'),
(69, '2026-05-10 08:48:54', N'Dine-in', 100.00, N'Cash', N'None', 89.29, 10.71, 2, 1, N'Dustin Yara', '2026-05-25 16:40:55'),
(70, '2026-05-11 04:04:10', N'Dine-in', 369.75, N'Cash', N'PWD (15%)', 388.39, 46.61, 1, 0, NULL, NULL),
(71, '2026-05-16 11:24:26', N'Dine-in', 323.00, N'Cash', N'PWD (15%)', 339.29, 40.71, 16, 0, NULL, NULL),
(72, '2026-05-16 11:26:29', N'Dine-in', 140.00, N'Card', N'None', 125.00, 15.00, 16, 1, N'Dustin Yara', '2026-05-25 16:23:51'),
(74, '2026-05-21 12:54:42', N'Dine-in', 175.00, N'Cash', N'None', 156.25, 18.75, 3, 1, N'Gab Velarde', '2026-05-21 17:56:14'),
(75, '2026-05-21 12:55:00', N'Dine-in', 90.00,  N'Cash', N'None', 80.36,  9.64,  3, 1, N'Gab Velarde', '2026-05-21 17:54:26'),
(76, '2026-05-21 17:25:35', N'Dine-in', 155.00, N'Cash', N'None', 138.39, 16.61, 3, 1, N'Gab Velarde', '2026-05-21 17:53:01'),
(84, '2026-06-04 15:41:11', N'Dine-in', 175.00, N'Cash', N'None', 290.18, 34.82, 3, 0, NULL, NULL);
SET IDENTITY_INSERT [dbo].[Transactions] OFF;
GO

SET IDENTITY_INSERT [dbo].[TransactionItems] ON;
INSERT [dbo].[TransactionItems] ([Id], [TransactionId], [ItemName], [Quantity], [Category], [Price], [UnitPrice], [IsVoided], [VoidReason], [DisposalType]) VALUES 
(1, 84, N'Iced Americano', 1, N'Cold Coffee', 150.00, 150.00, 1, N'Customer Changed Mind', N'Waste'),
(2, 84, N'Hazelnut Latte', 1, N'Cold Coffee', 175.00, 175.00, 0, NULL, NULL);
SET IDENTITY_INSERT [dbo].[TransactionItems] OFF;
GO

SET IDENTITY_INSERT [dbo].[VoidLogs] ON;
INSERT [dbo].[VoidLogs] ([Id], [TransactionId], [ReasonCode], [VoidedBy], [VoidDate], [IsFullVoid], [DisposalSummary]) VALUES 
(1, 84, N'Customer Changed Mind', N'Dustin Yara', '2026-06-04 15:42:29', 0, N'Iced Americano×1=Waste');
SET IDENTITY_INSERT [dbo].[VoidLogs] OFF;
GO

PRINT '=======================================================';
PRINT ' CAFE 104 ENTERPRISE SCHEMA DEPLOYED SUCCESSFULLY ';
PRINT '=======================================================';