-- =============================================
-- DATABASE: Item Management System
-- DESCRIPTION: Item Master table and stored procedures
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- CREATE ITEM MASTER TABLE
-- =============================================
CREATE TABLE [dbo].[ItemMaster] (
    -- Primary Key
    [ItemID] INT IDENTITY(1,1) NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    
    -- Categorization
    [CategoryID] INT NULL,
    [CategoryName] NVARCHAR(100) NULL,
    [SubCategory] NVARCHAR(100) NULL,
    [ItemType] NVARCHAR(50) NULL, -- e.g., 'Product', 'Service', 'Raw Material'
    
    -- Pricing and Cost
    [UnitPrice] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [CostPrice] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [MRP] DECIMAL(18,2) NULL,
    [TaxRate] DECIMAL(5,2) NULL DEFAULT 0,
    [DiscountPercent] DECIMAL(5,2) NULL DEFAULT 0,
    
    -- Inventory
    [UnitOfMeasure] NVARCHAR(20) NOT NULL, -- e.g., 'Pcs', 'Kg', 'Ltr'
    [MinimumStock] INT NULL DEFAULT 0,
    [MaximumStock] INT NULL,
    [CurrentStock] INT NOT NULL DEFAULT 0,
    [ReorderLevel] INT NULL DEFAULT 0,
    [ReorderQuantity] INT NULL,
    
    -- Status and Tracking
    [IsActive] BIT NOT NULL DEFAULT 1,
    [IsTaxable] BIT NOT NULL DEFAULT 1,
    [IsPerishable] BIT NOT NULL DEFAULT 0,
    [IsBatchTracked] BIT NOT NULL DEFAULT 0,
    [IsSerialTracked] BIT NOT NULL DEFAULT 0,
    
    -- Supplier Information
    [SupplierID] INT NULL,
    [SupplierName] NVARCHAR(200) NULL,
    [ManufacturerName] NVARCHAR(200) NULL,
    
    -- Dates
    [ManufacturingDate] DATE NULL,
    [ExpiryDate] DATE NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Audit
    [CreatedBy] NVARCHAR(100) NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    
    -- Additional Fields
    [Weight] DECIMAL(10,3) NULL,
    [Dimensions] NVARCHAR(100) NULL,
    [Color] NVARCHAR(50) NULL,
    [Brand] NVARCHAR(100) NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    
    -- Constraints
    CONSTRAINT PK_ItemMaster PRIMARY KEY CLUSTERED (ItemID ASC),
    CONSTRAINT UQ_ItemMaster_ItemCode UNIQUE NONCLUSTERED (ItemCode ASC)
)

GO

-- Create indexes for better performance
CREATE NONCLUSTERED INDEX IX_ItemMaster_ItemCode ON ItemMaster(ItemCode)
CREATE NONCLUSTERED INDEX IX_ItemMaster_CategoryID ON ItemMaster(CategoryID)
CREATE NONCLUSTERED INDEX IX_ItemMaster_ItemType ON ItemMaster(ItemType)
CREATE NONCLUSTERED INDEX IX_ItemMaster_IsActive ON ItemMaster(IsActive)
CREATE NONCLUSTERED INDEX IX_ItemMaster_SupplierID ON ItemMaster(SupplierID)

GO

-- =============================================
-- STORED PROCEDURE: Insert New Item
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertItem]
    @ItemCode NVARCHAR(50),
    @ItemName NVARCHAR(200),
    @ItemDescription NVARCHAR(500) = NULL,
    @CategoryID INT = NULL,
    @CategoryName NVARCHAR(100) = NULL,
    @SubCategory NVARCHAR(100) = NULL,
    @ItemType NVARCHAR(50) = NULL,
    @UnitPrice DECIMAL(18,2) = 0,
    @CostPrice DECIMAL(18,2) = 0,
    @MRP DECIMAL(18,2) = NULL,
    @TaxRate DECIMAL(5,2) = 0,
    @DiscountPercent DECIMAL(5,2) = 0,
    @UnitOfMeasure NVARCHAR(20),
    @MinimumStock INT = 0,
    @MaximumStock INT = NULL,
    @CurrentStock INT = 0,
    @ReorderLevel INT = 0,
    @ReorderQuantity INT = NULL,
    @IsActive BIT = 1,
    @IsTaxable BIT = 1,
    @IsPerishable BIT = 0,
    @IsBatchTracked BIT = 0,
    @IsSerialTracked BIT = 0,
    @SupplierID INT = NULL,
    @SupplierName NVARCHAR(200) = NULL,
    @ManufacturerName NVARCHAR(200) = NULL,
    @ManufacturingDate DATE = NULL,
    @ExpiryDate DATE = NULL,
    @CreatedBy NVARCHAR(100) = NULL,
    @Weight DECIMAL(10,3) = NULL,
    @Dimensions NVARCHAR(100) = NULL,
    @Color NVARCHAR(50) = NULL,
    @Brand NVARCHAR(100) = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @NewItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if ItemCode already exists
            IF EXISTS (SELECT 1 FROM ItemMaster WHERE ItemCode = @ItemCode)
            BEGIN
                RAISERROR('Item code already exists.', 16, 1)
                RETURN
            END
            
            -- Insert new item
            INSERT INTO ItemMaster (
                ItemCode, ItemName, ItemDescription, CategoryID, CategoryName,
                SubCategory, ItemType, UnitPrice, CostPrice, MRP, TaxRate,
                DiscountPercent, UnitOfMeasure, MinimumStock, MaximumStock,
                CurrentStock, ReorderLevel, ReorderQuantity, IsActive, IsTaxable,
                IsPerishable, IsBatchTracked, IsSerialTracked, SupplierID,
                SupplierName, ManufacturerName, ManufacturingDate, ExpiryDate,
                CreatedBy, Weight, Dimensions, Color, Brand, Remarks
            )
            VALUES (
                @ItemCode, @ItemName, @ItemDescription, @CategoryID, @CategoryName,
                @SubCategory, @ItemType, @UnitPrice, @CostPrice, @MRP, @TaxRate,
                @DiscountPercent, @UnitOfMeasure, @MinimumStock, @MaximumStock,
                @CurrentStock, @ReorderLevel, @ReorderQuantity, @IsActive, @IsTaxable,
                @IsPerishable, @IsBatchTracked, @IsSerialTracked, @SupplierID,
                @SupplierName, @ManufacturerName, @ManufacturingDate, @ExpiryDate,
                @CreatedBy, @Weight, @Dimensions, @Color, @Brand, @Remarks
            )
            
            SET @NewItemID = SCOPE_IDENTITY()
            
        COMMIT TRANSACTION
        
        SELECT @NewItemID AS ItemID, 'Item inserted successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Update Item
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateItem]
    @ItemID INT,
    @ItemCode NVARCHAR(50),
    @ItemName NVARCHAR(200),
    @ItemDescription NVARCHAR(500) = NULL,
    @CategoryID INT = NULL,
    @CategoryName NVARCHAR(100) = NULL,
    @SubCategory NVARCHAR(100) = NULL,
    @ItemType NVARCHAR(50) = NULL,
    @UnitPrice DECIMAL(18,2) = 0,
    @CostPrice DECIMAL(18,2) = 0,
    @MRP DECIMAL(18,2) = NULL,
    @TaxRate DECIMAL(5,2) = 0,
    @DiscountPercent DECIMAL(5,2) = 0,
    @UnitOfMeasure NVARCHAR(20),
    @MinimumStock INT = 0,
    @MaximumStock INT = NULL,
    @CurrentStock INT = 0,
    @ReorderLevel INT = 0,
    @ReorderQuantity INT = NULL,
    @IsActive BIT = 1,
    @IsTaxable BIT = 1,
    @IsPerishable BIT = 0,
    @IsBatchTracked BIT = 0,
    @IsSerialTracked BIT = 0,
    @SupplierID INT = NULL,
    @SupplierName NVARCHAR(200) = NULL,
    @ManufacturerName NVARCHAR(200) = NULL,
    @ManufacturingDate DATE = NULL,
    @ExpiryDate DATE = NULL,
    @ModifiedBy NVARCHAR(100) = NULL,
    @Weight DECIMAL(10,3) = NULL,
    @Dimensions NVARCHAR(100) = NULL,
    @Color NVARCHAR(50) = NULL,
    @Brand NVARCHAR(100) = NULL,
    @Remarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if item exists
            IF NOT EXISTS (SELECT 1 FROM ItemMaster WHERE ItemID = @ItemID)
            BEGIN
                RAISERROR('Item not found.', 16, 1)
                RETURN
            END
            
            -- Check if ItemCode already exists for another item
            IF EXISTS (SELECT 1 FROM ItemMaster WHERE ItemCode = @ItemCode AND ItemID != @ItemID)
            BEGIN
                RAISERROR('Item code already exists for another item.', 16, 1)
                RETURN
            END
            
            -- Update item
            UPDATE ItemMaster SET
                ItemCode = @ItemCode,
                ItemName = @ItemName,
                ItemDescription = @ItemDescription,
                CategoryID = @CategoryID,
                CategoryName = @CategoryName,
                SubCategory = @SubCategory,
                ItemType = @ItemType,
                UnitPrice = @UnitPrice,
                CostPrice = @CostPrice,
                MRP = @MRP,
                TaxRate = @TaxRate,
                DiscountPercent = @DiscountPercent,
                UnitOfMeasure = @UnitOfMeasure,
                MinimumStock = @MinimumStock,
                MaximumStock = @MaximumStock,
                CurrentStock = @CurrentStock,
                ReorderLevel = @ReorderLevel,
                ReorderQuantity = @ReorderQuantity,
                IsActive = @IsActive,
                IsTaxable = @IsTaxable,
                IsPerishable = @IsPerishable,
                IsBatchTracked = @IsBatchTracked,
                IsSerialTracked = @IsSerialTracked,
                SupplierID = @SupplierID,
                SupplierName = @SupplierName,
                ManufacturerName = @ManufacturerName,
                ManufacturingDate = @ManufacturingDate,
                ExpiryDate = @ExpiryDate,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy,
                Weight = @Weight,
                Dimensions = @Dimensions,
                Color = @Color,
                Brand = @Brand,
                Remarks = @Remarks
            WHERE ItemID = @ItemID
            
        COMMIT TRANSACTION
        
        SELECT 'Item updated successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Delete Item (Soft Delete)
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteItem]
    @ItemID INT,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if item exists
            IF NOT EXISTS (SELECT 1 FROM ItemMaster WHERE ItemID = @ItemID)
            BEGIN
                RAISERROR('Item not found.', 16, 1)
                RETURN
            END
            
            -- Soft delete (set IsActive to 0)
            UPDATE ItemMaster SET
                IsActive = 0,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE ItemID = @ItemID
            
        COMMIT TRANSACTION
        
        SELECT 'Item deleted successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Get Item by ID
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetItemByID]
    @ItemID INT
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        ItemID, ItemCode, ItemName, ItemDescription,
        CategoryID, CategoryName, SubCategory, ItemType,
        UnitPrice, CostPrice, MRP, TaxRate, DiscountPercent,
        UnitOfMeasure, MinimumStock, MaximumStock, CurrentStock,
        ReorderLevel, ReorderQuantity, IsActive, IsTaxable,
        IsPerishable, IsBatchTracked, IsSerialTracked,
        SupplierID, SupplierName, ManufacturerName,
        ManufacturingDate, ExpiryDate, CreatedDate, ModifiedDate,
        CreatedBy, ModifiedBy, Weight, Dimensions, Color, Brand, Remarks
    FROM ItemMaster
    WHERE ItemID = @ItemID
END
GO

-- =============================================
-- STORED PROCEDURE: Get All Items (with filters)
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAllItems]
    @IsActive BIT = NULL,
    @CategoryID INT = NULL,
    @ItemType NVARCHAR(50) = NULL,
    @SearchTerm NVARCHAR(200) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    
    SELECT 
        ItemID, ItemCode, ItemName, ItemDescription,
        CategoryID, CategoryName, SubCategory, ItemType,
        UnitPrice, CostPrice, MRP, TaxRate, DiscountPercent,
        UnitOfMeasure, MinimumStock, MaximumStock, CurrentStock,
        ReorderLevel, ReorderQuantity, IsActive, IsTaxable,
        IsPerishable, IsBatchTracked, IsSerialTracked,
        SupplierID, SupplierName, ManufacturerName,
        ManufacturingDate, ExpiryDate, CreatedDate, ModifiedDate,
        CreatedBy, ModifiedBy, Weight, Dimensions, Color, Brand, Remarks,
        COUNT(*) OVER() AS TotalRecords
    FROM ItemMaster
    WHERE 
        (@IsActive IS NULL OR IsActive = @IsActive)
        AND (@CategoryID IS NULL OR CategoryID = @CategoryID)
        AND (@ItemType IS NULL OR ItemType = @ItemType)
        AND (@SearchTerm IS NULL OR 
            ItemCode LIKE '%' + @SearchTerm + '%' OR 
            ItemName LIKE '%' + @SearchTerm + '%' OR
            ItemDescription LIKE '%' + @SearchTerm + '%')
    ORDER BY ItemCode
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
GO

-- =============================================
-- STORED PROCEDURE: Update Stock Quantity
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateStock]
    @ItemID INT,
    @QuantityChange INT, -- Positive for increase, negative for decrease
    @TransactionType NVARCHAR(50), -- e.g., 'Purchase', 'Sale', 'Return', 'Adjustment'
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @CurrentStock INT
            DECLARE @NewStock INT
            
            -- Get current stock
            SELECT @CurrentStock = CurrentStock
            FROM ItemMaster
            WHERE ItemID = @ItemID
            
            IF @CurrentStock IS NULL
            BEGIN
                RAISERROR('Item not found.', 16, 1)
                RETURN
            END
            
            -- Calculate new stock
            SET @NewStock = @CurrentStock + @QuantityChange
            
            -- Check if new stock is negative
            IF @NewStock < 0
            BEGIN
                RAISERROR('Insufficient stock. Current stock: %d, Requested decrease: %d', 16, 1, @CurrentStock, ABS(@QuantityChange))
                RETURN
            END
            
            -- Update stock
            UPDATE ItemMaster SET
                CurrentStock = @NewStock,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE ItemID = @ItemID
            
            -- Log stock movement (you might want to create a StockMovement table for this)
            -- INSERT INTO StockMovement (ItemID, QuantityChange, TransactionType, NewStock, CreatedBy)
            -- VALUES (@ItemID, @QuantityChange, @TransactionType, @NewStock, @ModifiedBy)
            
        COMMIT TRANSACTION
        
        SELECT 
            @NewStock AS CurrentStock,
            'Stock updated successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Get Low Stock Items
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetLowStockItems]
    @ReorderThreshold INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        ItemID, ItemCode, ItemName, CurrentStock, 
        ReorderLevel, MinimumStock, UnitOfMeasure,
        SupplierID, SupplierName
    FROM ItemMaster
    WHERE IsActive = 1
        AND (
            (ReorderLevel > 0 AND CurrentStock <= ReorderLevel)
            OR (MinimumStock > 0 AND CurrentStock <= MinimumStock)
            OR (@ReorderThreshold IS NOT NULL AND CurrentStock <= @ReorderThreshold)
        )
    ORDER BY CurrentStock ASC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Items by Supplier
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetItemsBySupplier]
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        ItemID, ItemCode, ItemName, UnitPrice, 
        CurrentStock, UnitOfMeasure
    FROM ItemMaster
    WHERE SupplierID = @SupplierID AND IsActive = 1
    ORDER BY ItemName
END
GO

-- =============================================
-- STORED PROCEDURE: Get Item Summary Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetItemSummaryReport]
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        COUNT(*) AS TotalItems,
        SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveItems,
        SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS InactiveItems,
        SUM(CurrentStock) AS TotalStockQuantity,
        SUM(CurrentStock * UnitPrice) AS TotalInventoryValue,
        SUM(CASE WHEN CurrentStock <= ReorderLevel THEN 1 ELSE 0 END) AS LowStockItems,
        COUNT(DISTINCT CategoryID) AS TotalCategories,
        COUNT(DISTINCT SupplierID) AS TotalSuppliers
    FROM ItemMaster
    WHERE IsActive = 1
END
GO

-- =============================================
-- STORED PROCEDURE: Bulk Insert Items
-- =============================================
CREATE PROCEDURE [dbo].[sp_BulkInsertItems]
    @Items XML,
    @CreatedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Insert items from XML
            INSERT INTO ItemMaster (
                ItemCode, ItemName, ItemDescription, CategoryName,
                UnitPrice, CostPrice, UnitOfMeasure, CurrentStock,
                IsActive, CreatedBy
            )
            SELECT
                X.value('@ItemCode', 'NVARCHAR(50)'),
                X.value('@ItemName', 'NVARCHAR(200)'),
                X.value('@ItemDescription', 'NVARCHAR(500)'),
                X.value('@CategoryName', 'NVARCHAR(100)'),
                X.value('@UnitPrice', 'DECIMAL(18,2)'),
                X.value('@CostPrice', 'DECIMAL(18,2)'),
                X.value('@UnitOfMeasure', 'NVARCHAR(20)'),
                X.value('@CurrentStock', 'INT'),
                1,
                @CreatedBy
            FROM @Items.nodes('/Items/Item') AS T(X)
            
            DECLARE @InsertedCount INT = @@ROWCOUNT
            
        COMMIT TRANSACTION
        
        SELECT CONVERT(NVARCHAR(10), @InsertedCount) + ' items inserted successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

PRINT 'Item Master table and stored procedures created successfully!'