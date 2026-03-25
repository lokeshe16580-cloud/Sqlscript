-- =============================================
-- DATABASE: Material Issue & Transfer Management System
-- DESCRIPTION: Material Issue, Receive, and Transfer to Employee
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- CREATE EMPLOYEE MASTER TABLE
-- =============================================
CREATE TABLE [dbo].[EmployeeMaster] (
    -- Primary Key
    [EmployeeID] INT IDENTITY(1,1) NOT NULL,
    [EmployeeCode] NVARCHAR(50) NOT NULL,
    [EmployeeName] NVARCHAR(200) NOT NULL,
    [Department] NVARCHAR(100) NULL,
    [Designation] NVARCHAR(100) NULL,
    [Section] NVARCHAR(100) NULL,
    
    -- Contact Information
    [Email] NVARCHAR(100) NULL,
    [Phone] NVARCHAR(20) NULL,
    [Mobile] NVARCHAR(20) NULL,
    
    -- Employment Details
    [EmployeeType] NVARCHAR(50) NULL, -- 'Permanent', 'Contract', 'Temporary'
    [JoinDate] DATE NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    
    -- Cost Center
    [CostCenter] NVARCHAR(50) NULL,
    [ProjectCode] NVARCHAR(50) NULL,
    
    -- Supervisor
    [SupervisorID] INT NULL,
    [SupervisorName] NVARCHAR(200) NULL,
    
    -- Address
    [Address] NVARCHAR(500) NULL,
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    
    CONSTRAINT PK_EmployeeMaster PRIMARY KEY CLUSTERED (EmployeeID ASC),
    CONSTRAINT UQ_EmployeeMaster_EmployeeCode UNIQUE NONCLUSTERED (EmployeeCode ASC)
)

GO

-- =============================================
-- CREATE MATERIAL ISSUE TABLE
-- =============================================
CREATE TABLE [dbo].[MaterialIssue] (
    -- Primary Key
    [IssueID] INT IDENTITY(1,1) NOT NULL,
    [IssueNumber] NVARCHAR(50) NOT NULL,
    [IssueDate] DATE NOT NULL DEFAULT GETDATE(),
    [IssueType] NVARCHAR(50) NOT NULL, -- 'Employee', 'Department', 'Project', 'Consumption', 'Return'
    
    -- Requisition Details
    [RequisitionNumber] NVARCHAR(50) NULL,
    [RequisitionDate] DATE NULL,
    [RequisitionedBy] NVARCHAR(100) NULL,
    
    -- Employee/Department Details
    [EmployeeID] INT NULL,
    [EmployeeCode] NVARCHAR(50) NULL,
    [EmployeeName] NVARCHAR(200) NULL,
    [Department] NVARCHAR(100) NULL,
    [Designation] NVARCHAR(100) NULL,
    [CostCenter] NVARCHAR(50) NULL,
    [ProjectCode] NVARCHAR(50) NULL,
    
    -- Issue From Store
    [StoreID] INT NOT NULL,
    [StoreCode] NVARCHAR(50) NOT NULL,
    [StoreName] NVARCHAR(200) NOT NULL,
    
    -- Issue Details
    [Purpose] NVARCHAR(500) NULL,
    [Priority] NVARCHAR(20) NULL DEFAULT 'Normal', -- 'Urgent', 'Normal', 'Low'
    [IssueStatus] NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Submitted', 'Approved', 'Issued', 'Partially Issued', 'Cancelled'
    
    -- Approval Details
    [ApprovedBy] NVARCHAR(100) NULL,
    [ApprovedDate] DATETIME NULL,
    [ApprovalRemarks] NVARCHAR(MAX) NULL,
    
    -- Issued By
    [IssuedBy] NVARCHAR(100) NULL,
    [IssuedDate] DATETIME NULL,
    
    -- Summary
    [TotalItems] INT NULL,
    [TotalQuantity] DECIMAL(18,3) NULL,
    [TotalValue] DECIMAL(18,2) NULL,
    
    -- Return Information
    [IsReturnable] BIT NOT NULL DEFAULT 0,
    [ExpectedReturnDate] DATE NULL,
    [ActualReturnDate] DATE NULL,
    
    -- Delivery
    [DeliveryLocation] NVARCHAR(500) NULL,
    [DeliveryMode] NVARCHAR(50) NULL, -- 'Handover', 'Courier', 'Dispatch'
    
    -- Attachments
    [Attachments] NVARCHAR(500) NULL,
    
    -- Dates
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Audit
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    
    CONSTRAINT PK_MaterialIssue PRIMARY KEY CLUSTERED (IssueID ASC),
    CONSTRAINT UQ_MaterialIssue_IssueNumber UNIQUE NONCLUSTERED (IssueNumber ASC),
    CONSTRAINT FK_MaterialIssue_StoreMaster FOREIGN KEY (StoreID) REFERENCES StoreMaster(StoreID),
    CONSTRAINT FK_MaterialIssue_EmployeeMaster FOREIGN KEY (EmployeeID) REFERENCES EmployeeMaster(EmployeeID)
)

GO

-- =============================================
-- CREATE MATERIAL ISSUE DETAILS TABLE
-- =============================================
CREATE TABLE [dbo].[MaterialIssueDetails] (
    [IssueDetailID] INT IDENTITY(1,1) NOT NULL,
    [IssueID] INT NOT NULL,
    [LineNumber] INT NOT NULL,
    
    -- Item Information
    [ItemID] INT NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    [UnitOfMeasure] NVARCHAR(20) NOT NULL,
    
    -- Quantity Details
    [RequestedQuantity] DECIMAL(18,3) NOT NULL,
    [IssuedQuantity] DECIMAL(18,3) NOT NULL,
    [PendingQuantity] DECIMAL(18,3) NULL,
    
    -- Stock Information
    [BatchNumber] NVARCHAR(100) NULL,
    [SerialNumber] NVARCHAR(500) NULL,
    [BinID] INT NULL,
    [BinCode] NVARCHAR(50) NULL,
    
    -- Pricing
    [UnitPrice] DECIMAL(18,2) NULL,
    [TotalAmount] DECIMAL(18,2) NULL,
    
    -- Status
    [IssueStatus] NVARCHAR(50) NULL DEFAULT 'Pending', -- 'Pending', 'Issued', 'Partially Issued', 'Cancelled'
    
    -- Return Tracking
    [IsReturned] BIT NOT NULL DEFAULT 0,
    [ReturnedQuantity] DECIMAL(18,3) NULL DEFAULT 0,
    [ReturnDate] DATETIME NULL,
    
    -- Expiry
    [ExpiryDate] DATE NULL,
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    CONSTRAINT PK_MaterialIssueDetails PRIMARY KEY CLUSTERED (IssueDetailID ASC),
    CONSTRAINT FK_MaterialIssueDetails_MaterialIssue FOREIGN KEY (IssueID) REFERENCES MaterialIssue(IssueID) ON DELETE CASCADE,
    CONSTRAINT FK_MaterialIssueDetails_ItemMaster FOREIGN KEY (ItemID) REFERENCES ItemMaster(ItemID)
)

GO

-- =============================================
-- CREATE MATERIAL RETURN TABLE
-- =============================================
CREATE TABLE [dbo].[MaterialReturn] (
    [ReturnID] INT IDENTITY(1,1) NOT NULL,
    [ReturnNumber] NVARCHAR(50) NOT NULL,
    [ReturnDate] DATE NOT NULL DEFAULT GETDATE(),
    [ReturnType] NVARCHAR(50) NOT NULL, -- 'Employee Return', 'Damage Return', 'Expired Return', 'Excess Return'
    
    -- Reference to Issue
    [IssueID] INT NULL,
    [IssueNumber] NVARCHAR(50) NULL,
    [IssueDetailID] INT NULL,
    
    -- Employee/Department Details
    [EmployeeID] INT NULL,
    [EmployeeCode] NVARCHAR(50) NULL,
    [EmployeeName] NVARCHAR(200) NULL,
    [Department] NVARCHAR(100) NULL,
    
    -- Store Details
    [StoreID] INT NOT NULL,
    [StoreCode] NVARCHAR(50) NOT NULL,
    [StoreName] NVARCHAR(200) NOT NULL,
    
    -- Return Details
    [Reason] NVARCHAR(500) NOT NULL,
    [ReturnStatus] NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Submitted', 'Approved', 'Completed', 'Rejected'
    
    -- Quality Check
    [IsQualityChecked] BIT NOT NULL DEFAULT 0,
    [QualityChecker] NVARCHAR(100) NULL,
    [QualityCheckDate] DATETIME NULL,
    [QualityRemarks] NVARCHAR(MAX) NULL,
    
    -- Summary
    [TotalItems] INT NULL,
    [TotalQuantity] DECIMAL(18,3) NULL,
    [TotalValue] DECIMAL(18,2) NULL,
    
    -- Approval
    [ApprovedBy] NVARCHAR(100) NULL,
    [ApprovedDate] DATETIME NULL,
    [ApprovalRemarks] NVARCHAR(MAX) NULL,
    
    -- Received By
    [ReceivedBy] NVARCHAR(100) NULL,
    [ReceivedDate] DATETIME NULL,
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    
    CONSTRAINT PK_MaterialReturn PRIMARY KEY CLUSTERED (ReturnID ASC),
    CONSTRAINT UQ_MaterialReturn_ReturnNumber UNIQUE NONCLUSTERED (ReturnNumber ASC),
    CONSTRAINT FK_MaterialReturn_StoreMaster FOREIGN KEY (StoreID) REFERENCES StoreMaster(StoreID)
)

GO

-- =============================================
-- CREATE MATERIAL RETURN DETAILS TABLE
-- =============================================
CREATE TABLE [dbo].[MaterialReturnDetails] (
    [ReturnDetailID] INT IDENTITY(1,1) NOT NULL,
    [ReturnID] INT NOT NULL,
    [LineNumber] INT NOT NULL,
    
    -- Reference to Issue Details
    [IssueDetailID] INT NULL,
    
    -- Item Information
    [ItemID] INT NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    [UnitOfMeasure] NVARCHAR(20) NOT NULL,
    
    -- Quantity Details
    [ReturnedQuantity] DECIMAL(18,3) NOT NULL,
    [AcceptedQuantity] DECIMAL(18,3) NULL,
    [RejectedQuantity] DECIMAL(18,3) NULL,
    
    -- Batch/Serial
    [BatchNumber] NVARCHAR(100) NULL,
    [SerialNumber] NVARCHAR(500) NULL,
    
    -- Condition
    [Condition] NVARCHAR(50) NULL, -- 'Good', 'Damaged', 'Expired', 'Used'
    [ConditionRemarks] NVARCHAR(500) NULL,
    
    -- Stock Update
    [IsStockUpdated] BIT NOT NULL DEFAULT 0,
    [StockUpdateDate] DATETIME NULL,
    
    -- Pricing
    [UnitPrice] DECIMAL(18,2) NULL,
    [TotalAmount] DECIMAL(18,2) NULL,
    
    -- Status
    [ReturnStatus] NVARCHAR(50) NULL DEFAULT 'Pending',
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    CONSTRAINT PK_MaterialReturnDetails PRIMARY KEY CLUSTERED (ReturnDetailID ASC),
    CONSTRAINT FK_MaterialReturnDetails_MaterialReturn FOREIGN KEY (ReturnID) REFERENCES MaterialReturn(ReturnID) ON DELETE CASCADE
)

GO

-- =============================================
-- CREATE STOCK TRANSFER TABLE (Between Stores)
-- =============================================
CREATE TABLE [dbo].[StockTransfer] (
    [TransferID] INT IDENTITY(1,1) NOT NULL,
    [TransferNumber] NVARCHAR(50) NOT NULL,
    [TransferDate] DATE NOT NULL DEFAULT GETDATE(),
    [TransferType] NVARCHAR(50) NOT NULL, -- 'Store to Store', 'Store to Employee', 'Store to Department', 'Store to Project'
    
    -- Source Store
    [SourceStoreID] INT NOT NULL,
    [SourceStoreCode] NVARCHAR(50) NOT NULL,
    [SourceStoreName] NVARCHAR(200) NOT NULL,
    
    -- Destination
    [DestinationType] NVARCHAR(50) NOT NULL, -- 'Store', 'Employee', 'Department', 'Project'
    [DestinationStoreID] INT NULL,
    [DestinationStoreCode] NVARCHAR(50) NULL,
    [DestinationStoreName] NVARCHAR(200) NULL,
    [DestinationEmployeeID] INT NULL,
    [DestinationEmployeeCode] NVARCHAR(50) NULL,
    [DestinationEmployeeName] NVARCHAR(200) NULL,
    [DestinationDepartment] NVARCHAR(100) NULL,
    [DestinationProject] NVARCHAR(100) NULL,
    
    -- Transfer Details
    [Purpose] NVARCHAR(500) NULL,
    [Priority] NVARCHAR(20) NULL DEFAULT 'Normal',
    [TransferStatus] NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Approved', 'In Transit', 'Received', 'Completed', 'Cancelled'
    
    -- Approval
    [ApprovedBy] NVARCHAR(100) NULL,
    [ApprovedDate] DATETIME NULL,
    
    -- Dispatch
    [DispatchedBy] NVARCHAR(100) NULL,
    [DispatchedDate] DATETIME NULL,
    [DispatchMode] NVARCHAR(50) NULL, -- 'Hand Delivery', 'Courier', 'Internal Transport'
    [TrackingNumber] NVARCHAR(100) NULL,
    
    -- Receipt
    [ReceivedBy] NVARCHAR(100) NULL,
    [ReceivedDate] DATETIME NULL,
    [ReceivedRemarks] NVARCHAR(MAX) NULL,
    
    -- Summary
    [TotalItems] INT NULL,
    [TotalQuantity] DECIMAL(18,3) NULL,
    [TotalValue] DECIMAL(18,2) NULL,
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    
    CONSTRAINT PK_StockTransfer PRIMARY KEY CLUSTERED (TransferID ASC),
    CONSTRAINT UQ_StockTransfer_TransferNumber UNIQUE NONCLUSTERED (TransferNumber ASC),
    CONSTRAINT FK_StockTransfer_SourceStore FOREIGN KEY (SourceStoreID) REFERENCES StoreMaster(StoreID)
)

GO

-- =============================================
-- CREATE STOCK TRANSFER DETAILS TABLE
-- =============================================
CREATE TABLE [dbo].[StockTransferDetails] (
    [TransferDetailID] INT IDENTITY(1,1) NOT NULL,
    [TransferID] INT NOT NULL,
    [LineNumber] INT NOT NULL,
    
    -- Item Information
    [ItemID] INT NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    [UnitOfMeasure] NVARCHAR(20) NOT NULL,
    
    -- Quantity Details
    [TransferQuantity] DECIMAL(18,3) NOT NULL,
    [ReceivedQuantity] DECIMAL(18,3) NULL DEFAULT 0,
    [PendingQuantity] DECIMAL(18,3) NULL,
    
    -- Batch/Serial
    [BatchNumber] NVARCHAR(100) NULL,
    [SerialNumber] NVARCHAR(500) NULL,
    [BinID] INT NULL,
    [BinCode] NVARCHAR(50) NULL,
    
    -- Pricing
    [UnitPrice] DECIMAL(18,2) NULL,
    [TotalAmount] DECIMAL(18,2) NULL,
    
    -- Status
    [TransferStatus] NVARCHAR(50) NULL DEFAULT 'Pending',
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    CONSTRAINT PK_StockTransferDetails PRIMARY KEY CLUSTERED (TransferDetailID ASC),
    CONSTRAINT FK_StockTransferDetails_StockTransfer FOREIGN KEY (TransferID) REFERENCES StockTransfer(TransferID) ON DELETE CASCADE
)

GO

-- Create indexes for performance
CREATE NONCLUSTERED INDEX IX_MaterialIssue_IssueNumber ON MaterialIssue(IssueNumber)
CREATE NONCLUSTERED INDEX IX_MaterialIssue_IssueStatus ON MaterialIssue(IssueStatus)
CREATE NONCLUSTERED INDEX IX_MaterialIssue_EmployeeID ON MaterialIssue(EmployeeID)
CREATE NONCLUSTERED INDEX IX_MaterialIssue_StoreID ON MaterialIssue(StoreID)

CREATE NONCLUSTERED INDEX IX_MaterialReturn_ReturnNumber ON MaterialReturn(ReturnNumber)
CREATE NONCLUSTERED INDEX IX_MaterialReturn_IssueID ON MaterialReturn(IssueID)
CREATE NONCLUSTERED INDEX IX_MaterialReturn_ReturnStatus ON MaterialReturn(ReturnStatus)

CREATE NONCLUSTERED INDEX IX_StockTransfer_TransferNumber ON StockTransfer(TransferNumber)
CREATE NONCLUSTERED INDEX IX_StockTransfer_TransferStatus ON StockTransfer(TransferStatus)
CREATE NONCLUSTERED INDEX IX_StockTransfer_SourceStoreID ON StockTransfer(SourceStoreID)

GO

-- =============================================
-- STORED PROCEDURE: Create Material Issue
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateMaterialIssue]
    @IssueType NVARCHAR(50),
    @EmployeeID INT = NULL,
    @EmployeeCode NVARCHAR(50) = NULL,
    @EmployeeName NVARCHAR(200) = NULL,
    @Department NVARCHAR(100) = NULL,
    @Designation NVARCHAR(100) = NULL,
    @CostCenter NVARCHAR(50) = NULL,
    @ProjectCode NVARCHAR(50) = NULL,
    @StoreID INT,
    @Purpose NVARCHAR(500) = NULL,
    @Priority NVARCHAR(20) = 'Normal',
    @IsReturnable BIT = 0,
    @ExpectedReturnDate DATE = NULL,
    @DeliveryLocation NVARCHAR(500) = NULL,
    @DeliveryMode NVARCHAR(50) = NULL,
    @RequisitionNumber NVARCHAR(50) = NULL,
    @RequisitionedBy NVARCHAR(100) = NULL,
    @CreatedBy NVARCHAR(100),
    @IssueID INT OUTPUT,
    @IssueNumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Generate Issue Number (Format: ISS-YYYYMMDD-XXXX)
            DECLARE @DateStr NVARCHAR(8) = FORMAT(GETDATE(), 'yyyyMMdd')
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(IssueNumber, 4) AS INT)), 0) + 1
            FROM MaterialIssue
            WHERE IssueNumber LIKE 'ISS-' + @DateStr + '-%'
            
            SET @IssueNumber = 'ISS-' + @DateStr + '-' + RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Get Employee details if EmployeeID provided
            IF @EmployeeID IS NOT NULL AND @EmployeeName IS NULL
            BEGIN
                SELECT 
                    @EmployeeCode = EmployeeCode,
                    @EmployeeName = EmployeeName,
                    @Department = Department,
                    @Designation = Designation,
                    @CostCenter = ISNULL(CostCenter, @CostCenter)
                FROM EmployeeMaster
                WHERE EmployeeID = @EmployeeID
            END
            
            -- Get Store details
            DECLARE @StoreCode NVARCHAR(50)
            DECLARE @StoreName NVARCHAR(200)
            
            SELECT 
                @StoreCode = StoreCode,
                @StoreName = StoreName
            FROM StoreMaster
            WHERE StoreID = @StoreID AND IsActive = 1
            
            -- Insert Material Issue
            INSERT INTO MaterialIssue (
                IssueNumber, IssueType, EmployeeID, EmployeeCode, EmployeeName,
                Department, Designation, CostCenter, ProjectCode,
                StoreID, StoreCode, StoreName, Purpose, Priority,
                IsReturnable, ExpectedReturnDate, DeliveryLocation, DeliveryMode,
                RequisitionNumber, RequisitionedBy, IssueStatus, CreatedBy
            )
            VALUES (
                @IssueNumber, @IssueType, @EmployeeID, @EmployeeCode, @EmployeeName,
                @Department, @Designation, @CostCenter, @ProjectCode,
                @StoreID, @StoreCode, @StoreName, @Purpose, @Priority,
                @IsReturnable, @ExpectedReturnDate, @DeliveryLocation, @DeliveryMode,
                @RequisitionNumber, @RequisitionedBy, 'Draft', @CreatedBy
            )
            
            SET @IssueID = SCOPE_IDENTITY()
            
        COMMIT TRANSACTION
        
        SELECT @IssueID AS IssueID, @IssueNumber AS IssueNumber, 
               'Material issue created successfully.' AS Message
        
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
-- STORED PROCEDURE: Add Items to Material Issue
-- =============================================
CREATE PROCEDURE [dbo].[sp_AddIssueItems]
    @IssueID INT,
    @Items AS IssueItemType READONLY,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @TotalQuantity DECIMAL(18,3) = 0
            DECLARE @TotalValue DECIMAL(18,2) = 0
            DECLARE @StoreID INT
            
            -- Get Store ID for stock validation
            SELECT @StoreID = StoreID FROM MaterialIssue WHERE IssueID = @IssueID
            
            -- Validate stock availability
            DECLARE @ItemID INT
            DECLARE @RequestedQty DECIMAL(18,3)
            DECLARE @CurrentStock DECIMAL(18,3)
            
            DECLARE item_cursor CURSOR FOR
            SELECT ItemID, IssuedQuantity FROM @Items
            
            OPEN item_cursor
            FETCH NEXT FROM item_cursor INTO @ItemID, @RequestedQty
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @CurrentStock = CurrentStock 
                FROM ItemMaster 
                WHERE ItemID = @ItemID
                
                IF @CurrentStock < @RequestedQty
                BEGIN
                    CLOSE item_cursor
                    DEALLOCATE item_cursor
                    RAISERROR('Insufficient stock for item ID: %d. Available: %f, Requested: %f', 
                             16, 1, @ItemID, @CurrentStock, @RequestedQty)
                    RETURN
                END
                
                FETCH NEXT FROM item_cursor INTO @ItemID, @RequestedQty
            END
            
            CLOSE item_cursor
            DEALLOCATE item_cursor
            
            -- Insert Issue Details
            INSERT INTO MaterialIssueDetails (
                IssueID, LineNumber, ItemID, ItemCode, ItemName, ItemDescription,
                UnitOfMeasure, RequestedQuantity, IssuedQuantity, PendingQuantity,
                UnitPrice, TotalAmount, IssueStatus, CreatedDate
            )
            SELECT 
                @IssueID, LineNumber, ItemID, ItemCode, ItemName, ItemDescription,
                UnitOfMeasure, RequestedQuantity, IssuedQuantity, 
                RequestedQuantity - IssuedQuantity AS PendingQuantity,
                UnitPrice, TotalAmount, 'Pending', GETDATE()
            FROM @Items
            
            -- Calculate totals
            SELECT 
                @TotalQuantity = SUM(IssuedQuantity),
                @TotalValue = SUM(TotalAmount)
            FROM @Items
            
            -- Update Issue Master
            UPDATE MaterialIssue
            SET TotalItems = (SELECT COUNT(*) FROM @Items),
                TotalQuantity = @TotalQuantity,
                TotalValue = @TotalValue,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE IssueID = @IssueID
            
        COMMIT TRANSACTION
        
        SELECT 'Issue items added successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'item_cursor') >= 0
        BEGIN
            CLOSE item_cursor
            DEALLOCATE item_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Approve Material Issue
-- =============================================
CREATE PROCEDURE [dbo].[sp_ApproveMaterialIssue]
    @IssueID INT,
    @ApprovedBy NVARCHAR(100),
    @ApprovalRemarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @IssueStatus NVARCHAR(50)
            
            SELECT @IssueStatus = IssueStatus 
            FROM MaterialIssue 
            WHERE IssueID = @IssueID
            
            IF @IssueStatus IS NULL
            BEGIN
                RAISERROR('Issue not found.', 16, 1)
                RETURN
            END
            
            IF @IssueStatus != 'Draft'
            BEGIN
                RAISERROR('Issue can only be approved from Draft status.', 16, 1)
                RETURN
            END
            
            -- Update Issue status
            UPDATE MaterialIssue
            SET IssueStatus = 'Approved',
                ApprovedBy = @ApprovedBy,
                ApprovedDate = GETDATE(),
                ApprovalRemarks = @ApprovalRemarks,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ApprovedBy
            WHERE IssueID = @IssueID
            
        COMMIT TRANSACTION
        
        SELECT 'Material issue approved successfully.' AS Message
        
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
-- STORED PROCEDURE: Process Material Issue (Update Stock)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcessMaterialIssue]
    @IssueID INT,
    @IssuedBy NVARCHAR(100),
    @Remarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @IssueStatus NVARCHAR(50)
            DECLARE @IssueNumber NVARCHAR(50)
            DECLARE @StoreID INT
            
            SELECT 
                @IssueStatus = IssueStatus,
                @IssueNumber = IssueNumber,
                @StoreID = StoreID
            FROM MaterialIssue
            WHERE IssueID = @IssueID
            
            IF @IssueStatus IS NULL
            BEGIN
                RAISERROR('Issue not found.', 16, 1)
                RETURN
            END
            
            IF @IssueStatus NOT IN ('Approved', 'Partially Issued')
            BEGIN
                RAISERROR('Issue can only be processed from Approved status.', 16, 1)
                RETURN
            END
            
            -- Process each issue detail
            DECLARE @IssueDetailID INT
            DECLARE @ItemID INT
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @IssuedQuantity DECIMAL(18,3)
            DECLARE @UnitPrice DECIMAL(18,2)
            DECLARE @UnitOfMeasure NVARCHAR(20)
            
            DECLARE issue_cursor CURSOR FOR
            SELECT 
                IssueDetailID, ItemID, ItemCode, IssuedQuantity, 
                UnitPrice, UnitOfMeasure
            FROM MaterialIssueDetails
            WHERE IssueID = @IssueID AND IssueStatus = 'Pending' AND IssuedQuantity > 0
            
            OPEN issue_cursor
            FETCH NEXT FROM issue_cursor INTO @IssueDetailID, @ItemID, @ItemCode, @IssuedQuantity, 
                                           @UnitPrice, @UnitOfMeasure
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Update Item Master stock (reduce)
                UPDATE ItemMaster
                SET CurrentStock = CurrentStock - @IssuedQuantity,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @IssuedBy
                WHERE ItemID = @ItemID
                
                -- Create Stock Movement record
                DECLARE @MovementNumber NVARCHAR(50)
                DECLARE @MovementSeq INT
                
                SELECT @MovementSeq = ISNULL(MAX(CAST(RIGHT(MovementNumber, 6) AS INT)), 0) + 1
                FROM StockMovement
                WHERE MovementNumber LIKE 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-%'
                
                SET @MovementNumber = 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + RIGHT('000000' + CAST(@MovementSeq AS VARCHAR(6)), 6)
                
                INSERT INTO StockMovement (
                    MovementNumber, MovementType, ItemID, ItemCode, ItemName,
                    SourceStoreID, SourceStoreCode,
                    Quantity, UnitOfMeasure, UnitPrice, TotalValue,
                    MovementDate, CreatedBy, Remarks
                )
                SELECT 
                    @MovementNumber, 'Issue', I.ItemID, I.ItemCode, I.ItemName,
                    @StoreID, S.StoreCode,
                    @IssuedQuantity, @UnitOfMeasure, @UnitPrice, @IssuedQuantity * @UnitPrice,
                    GETDATE(), @IssuedBy, @Remarks
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                WHERE I.ItemID = @ItemID AND S.StoreID = @StoreID
                
                -- Update Stock Ledger (Outward)
                INSERT INTO StockLedger (
                    ItemID, ItemCode, StoreID, BatchNumber,
                    OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                    UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                )
                SELECT 
                    @ItemID, @ItemCode, @StoreID, NULL,
                    ISNULL(ClosingStock, 0), 0, @IssuedQuantity, 
                    ISNULL(ClosingStock, 0) - @IssuedQuantity,
                    @UnitOfMeasure, GETDATE(), @IssueNumber, 'Issue'
                FROM (
                    SELECT TOP 1 ClosingStock
                    FROM StockLedger
                    WHERE ItemID = @ItemID AND StoreID = @StoreID
                    ORDER BY TransactionDate DESC, LedgerID DESC
                ) AS LastStock
                
                -- If no previous stock, set opening to 0
                IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO StockLedger (
                        ItemID, ItemCode, StoreID, BatchNumber,
                        OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                        UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                    )
                    VALUES (
                        @ItemID, @ItemCode, @StoreID, NULL,
                        0, 0, @IssuedQuantity, -@IssuedQuantity,
                        @UnitOfMeasure, GETDATE(), @IssueNumber, 'Issue'
                    )
                END
                
                -- Update Issue Detail status
                UPDATE MaterialIssueDetails
                SET IssueStatus = 'Issued',
                    ModifiedDate = GETDATE()
                WHERE IssueDetailID = @IssueDetailID
                
                FETCH NEXT FROM issue_cursor INTO @IssueDetailID, @ItemID, @ItemCode, @IssuedQuantity, 
                                               @UnitPrice, @UnitOfMeasure
            END
            
            CLOSE issue_cursor
            DEALLOCATE issue_cursor
            
            -- Update Issue Master status
            UPDATE MaterialIssue
            SET IssueStatus = 'Issued',
                IssuedBy = @IssuedBy,
                IssuedDate = GETDATE(),
                Remarks = @Remarks,
                ModifiedDate = GETDATE(),
                ModifiedBy = @IssuedBy
            WHERE IssueID = @IssueID
            
        COMMIT TRANSACTION
        
        SELECT 'Material issue processed and stock updated successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'issue_cursor') >= 0
        BEGIN
            CLOSE issue_cursor
            DEALLOCATE issue_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Create Material Return
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateMaterialReturn]
    @IssueID INT,
    @EmployeeID INT = NULL,
    @EmployeeCode NVARCHAR(50) = NULL,
    @EmployeeName NVARCHAR(200) = NULL,
    @Department NVARCHAR(100) = NULL,
    @StoreID INT,
    @Reason NVARCHAR(500),
    @ReturnType NVARCHAR(50) = 'Employee Return',
    @CreatedBy NVARCHAR(100),
    @ReturnID INT OUTPUT,
    @ReturnNumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Generate Return Number (Format: RET-YYYYMMDD-XXXX)
            DECLARE @DateStr NVARCHAR(8) = FORMAT(GETDATE(), 'yyyyMMdd')
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(ReturnNumber, 4) AS INT)), 0) + 1
            FROM MaterialReturn
            WHERE ReturnNumber LIKE 'RET-' + @DateStr + '-%'
            
            SET @ReturnNumber = 'RET-' + @DateStr + '-' + RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Get Issue details if IssueID provided
            DECLARE @IssueNumber NVARCHAR(50)
            
            IF @IssueID IS NOT NULL
            BEGIN
                SELECT 
                    @IssueNumber = IssueNumber,
                    @EmployeeID = ISNULL(@EmployeeID, EmployeeID),
                    @EmployeeName = ISNULL(@EmployeeName, EmployeeName),
                    @Department = ISNULL(@Department, Department)
                FROM MaterialIssue
                WHERE IssueID = @IssueID
            END
            
            -- Get Employee details if EmployeeID provided
            IF @EmployeeID IS NOT NULL AND @EmployeeName IS NULL
            BEGIN
                SELECT 
                    @EmployeeCode = EmployeeCode,
                    @EmployeeName = EmployeeName,
                    @Department = Department
                FROM EmployeeMaster
                WHERE EmployeeID = @EmployeeID
            END
            
            -- Get Store details
            DECLARE @StoreCode NVARCHAR(50)
            DECLARE @StoreName NVARCHAR(200)
            
            SELECT 
                @StoreCode = StoreCode,
                @StoreName = StoreName
            FROM StoreMaster
            WHERE StoreID = @StoreID
            
            -- Insert Material Return
            INSERT INTO MaterialReturn (
                ReturnNumber, ReturnType, IssueID, IssueNumber,
                EmployeeID, EmployeeCode, EmployeeName, Department,
                StoreID, StoreCode, StoreName, Reason, ReturnStatus, CreatedBy
            )
            VALUES (
                @ReturnNumber, @ReturnType, @IssueID, @IssueNumber,
                @EmployeeID, @EmployeeCode, @EmployeeName, @Department,
                @StoreID, @StoreCode, @StoreName, @Reason, 'Draft', @CreatedBy
            )
            
            SET @ReturnID = SCOPE_IDENTITY()
            
        COMMIT TRANSACTION
        
        SELECT @ReturnID AS ReturnID, @ReturnNumber AS ReturnNumber, 
               'Material return created successfully.' AS Message
        
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
-- STORED PROCEDURE: Add Items to Material Return
-- =============================================
CREATE PROCEDURE [dbo].[sp_AddReturnItems]
    @ReturnID INT,
    @Items AS ReturnItemType READONLY,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @TotalQuantity DECIMAL(18,3) = 0
            DECLARE @TotalValue DECIMAL(18,2) = 0
            
            -- Insert Return Details
            INSERT INTO MaterialReturnDetails (
                ReturnID, LineNumber, IssueDetailID, ItemID, ItemCode, ItemName,
                ItemDescription, UnitOfMeasure, ReturnedQuantity, AcceptedQuantity,
                RejectedQuantity, BatchNumber, SerialNumber, Condition,
                ConditionRemarks, UnitPrice, TotalAmount, ReturnStatus, CreatedDate
            )
            SELECT 
                @ReturnID, LineNumber, IssueDetailID, ItemID, ItemCode, ItemName,
                ItemDescription, UnitOfMeasure, ReturnedQuantity, ReturnedQuantity,
                0, BatchNumber, SerialNumber, Condition, ConditionRemarks,
                UnitPrice, TotalAmount, 'Pending', GETDATE()
            FROM @Items
            
            -- Calculate totals
            SELECT 
                @TotalQuantity = SUM(ReturnedQuantity),
                @TotalValue = SUM(TotalAmount)
            FROM @Items
            
            -- Update Return Master
            UPDATE MaterialReturn
            SET TotalItems = (SELECT COUNT(*) FROM @Items),
                TotalQuantity = @TotalQuantity,
                TotalValue = @TotalValue,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE ReturnID = @ReturnID
            
        COMMIT TRANSACTION
        
        SELECT 'Return items added successfully.' AS Message
        
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
-- STORED PROCEDURE: Process Material Return (Update Stock)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcessMaterialReturn]
    @ReturnID INT,
    @ReceivedBy NVARCHAR(100),
    @QualityChecker NVARCHAR(100) = NULL,
    @QualityRemarks NVARCHAR(MAX) = NULL,
    @Remarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @ReturnStatus NVARCHAR(50)
            DECLARE @ReturnNumber NVARCHAR(50)
            DECLARE @StoreID INT
            
            SELECT 
                @ReturnStatus = ReturnStatus,
                @ReturnNumber = ReturnNumber,
                @StoreID = StoreID
            FROM MaterialReturn
            WHERE ReturnID = @ReturnID
            
            IF @ReturnStatus IS NULL
            BEGIN
                RAISERROR('Return not found.', 16, 1)
                RETURN
            END
            
            IF @ReturnStatus != 'Draft'
            BEGIN
                RAISERROR('Return can only be processed from Draft status.', 16, 1)
                RETURN
            END
            
            -- Process each return detail
            DECLARE @ReturnDetailID INT
            DECLARE @ItemID INT
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @AcceptedQuantity DECIMAL(18,3)
            DECLARE @UnitPrice DECIMAL(18,2)
            DECLARE @UnitOfMeasure NVARCHAR(20)
            DECLARE @Condition NVARCHAR(50)
            
            DECLARE return_cursor CURSOR FOR
            SELECT 
                ReturnDetailID, ItemID, ItemCode, AcceptedQuantity, 
                UnitPrice, UnitOfMeasure, Condition
            FROM MaterialReturnDetails
            WHERE ReturnID = @ReturnID AND ReturnStatus = 'Pending' AND AcceptedQuantity > 0
            
            OPEN return_cursor
            FETCH NEXT FROM return_cursor INTO @ReturnDetailID, @ItemID, @ItemCode, @AcceptedQuantity, 
                                           @UnitPrice, @UnitOfMeasure, @Condition
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Update Item Master stock (increase)
                UPDATE ItemMaster
                SET CurrentStock = CurrentStock + @AcceptedQuantity,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ReceivedBy
                WHERE ItemID = @ItemID
                
                -- Create Stock Movement record
                DECLARE @MovementNumber NVARCHAR(50)
                DECLARE @MovementSeq INT
                
                SELECT @MovementSeq = ISNULL(MAX(CAST(RIGHT(MovementNumber, 6) AS INT)), 0) + 1
                FROM StockMovement
                WHERE MovementNumber LIKE 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-%'
                
                SET @MovementNumber = 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + RIGHT('000000' + CAST(@MovementSeq AS VARCHAR(6)), 6)
                
                INSERT INTO StockMovement (
                    MovementNumber, MovementType, ItemID, ItemCode, ItemName,
                    DestinationStoreID, DestinationStoreCode,
                    Quantity, UnitOfMeasure, UnitPrice, TotalValue,
                    MovementDate, CreatedBy, Remarks
                )
                SELECT 
                    @MovementNumber, 'Return', I.ItemID, I.ItemCode, I.ItemName,
                    @StoreID, S.StoreCode,
                    @AcceptedQuantity, @UnitOfMeasure, @UnitPrice, @AcceptedQuantity * @UnitPrice,
                    GETDATE(), @ReceivedBy, @Remarks + ' Condition: ' + ISNULL(@Condition, '')
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                WHERE I.ItemID = @ItemID AND S.StoreID = @StoreID
                
                -- Update Stock Ledger (Inward)
                INSERT INTO StockLedger (
                    ItemID, ItemCode, StoreID, BatchNumber,
                    OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                    UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                )
                SELECT 
                    @ItemID, @ItemCode, @StoreID, NULL,
                    ISNULL(ClosingStock, 0), @AcceptedQuantity, 0, 
                    ISNULL(ClosingStock, 0) + @AcceptedQuantity,
                    @UnitOfMeasure, GETDATE(), @ReturnNumber, 'Return'
                FROM (
                    SELECT TOP 1 ClosingStock
                    FROM StockLedger
                    WHERE ItemID = @ItemID AND StoreID = @StoreID
                    ORDER BY TransactionDate DESC, LedgerID DESC
                ) AS LastStock
                
                -- If no previous stock, set opening to 0
                IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO StockLedger (
                        ItemID, ItemCode, StoreID, BatchNumber,
                        OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                        UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                    )
                    VALUES (
                        @ItemID, @ItemCode, @StoreID, NULL,
                        0, @AcceptedQuantity, 0, @AcceptedQuantity,
                        @UnitOfMeasure, GETDATE(), @ReturnNumber, 'Return'
                    )
                END
                
                -- Update Return Detail status
                UPDATE MaterialReturnDetails
                SET IsStockUpdated = 1,
                    StockUpdateDate = GETDATE(),
                    ReturnStatus = 'Completed',
                    ModifiedDate = GETDATE()
                WHERE ReturnDetailID = @ReturnDetailID
                
                FETCH NEXT FROM return_cursor INTO @ReturnDetailID, @ItemID, @ItemCode, @AcceptedQuantity, 
                                               @UnitPrice, @UnitOfMeasure, @Condition
            END
            
            CLOSE return_cursor
            DEALLOCATE return_cursor
            
            -- Update Return Master status
            UPDATE MaterialReturn
            SET ReturnStatus = 'Completed',
                IsQualityChecked = CASE WHEN @QualityChecker IS NOT NULL THEN 1 ELSE 0 END,
                QualityChecker = @QualityChecker,
                QualityCheckDate = GETDATE(),
                QualityRemarks = @QualityRemarks,
                ReceivedBy = @ReceivedBy,
                ReceivedDate = GETDATE(),
                Remarks = @Remarks,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ReceivedBy
            WHERE ReturnID = @ReturnID
            
        COMMIT TRANSACTION
        
        SELECT 'Material return processed and stock updated successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'return_cursor') >= 0
        BEGIN
            CLOSE return_cursor
            DEALLOCATE return_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Create Stock Transfer (Store to Store)
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateStockTransfer]
    @SourceStoreID INT,
    @DestinationType NVARCHAR(50),
    @DestinationStoreID INT = NULL,
    @DestinationEmployeeID INT = NULL,
    @DestinationDepartment NVARCHAR(100) = NULL,
    @DestinationProject NVARCHAR(100) = NULL,
    @Purpose NVARCHAR(500) = NULL,
    @Priority NVARCHAR(20) = 'Normal',
    @DispatchMode NVARCHAR(50) = 'Hand Delivery',
    @CreatedBy NVARCHAR(100),
    @TransferID INT OUTPUT,
    @TransferNumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Generate Transfer Number (Format: TRF-YYYYMMDD-XXXX)
            DECLARE @DateStr NVARCHAR(8) = FORMAT(GETDATE(), 'yyyyMMdd')
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(TransferNumber, 4) AS INT)), 0) + 1
            FROM StockTransfer
            WHERE TransferNumber LIKE 'TRF-' + @DateStr + '-%'
            
            SET @TransferNumber = 'TRF-' + @DateStr + '-' + RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Get Source Store details
            DECLARE @SourceStoreCode NVARCHAR(50)
            DECLARE @SourceStoreName NVARCHAR(200)
            
            SELECT 
                @SourceStoreCode = StoreCode,
                @SourceStoreName = StoreName
            FROM StoreMaster
            WHERE StoreID = @SourceStoreID
            
            -- Get Destination details
            DECLARE @DestinationStoreCode NVARCHAR(50)
            DECLARE @DestinationStoreName NVARCHAR(200)
            DECLARE @DestinationEmployeeCode NVARCHAR(50)
            DECLARE @DestinationEmployeeName NVARCHAR(200)
            
            IF @DestinationStoreID IS NOT NULL
            BEGIN
                SELECT 
                    @DestinationStoreCode = StoreCode,
                    @DestinationStoreName = StoreName
                FROM StoreMaster
                WHERE StoreID = @DestinationStoreID
            END
            
            IF @DestinationEmployeeID IS NOT NULL
            BEGIN
                SELECT 
                    @DestinationEmployeeCode = EmployeeCode,
                    @DestinationEmployeeName = EmployeeName
                FROM EmployeeMaster
                WHERE EmployeeID = @DestinationEmployeeID
            END
            
            -- Insert Stock Transfer
            INSERT INTO StockTransfer (
                TransferNumber, TransferType, SourceStoreID, SourceStoreCode, SourceStoreName,
                DestinationType, DestinationStoreID, DestinationStoreCode, DestinationStoreName,
                DestinationEmployeeID, DestinationEmployeeCode, DestinationEmployeeName,
                DestinationDepartment, DestinationProject, Purpose, Priority,
                DispatchMode, TransferStatus, CreatedBy
            )
            VALUES (
                @TransferNumber, 'Store to Store', @SourceStoreID, @SourceStoreCode, @SourceStoreName,
                @DestinationType, @DestinationStoreID, @DestinationStoreCode, @DestinationStoreName,
                @DestinationEmployeeID, @DestinationEmployeeCode, @DestinationEmployeeName,
                @DestinationDepartment, @DestinationProject, @Purpose, @Priority,
                @DispatchMode, 'Draft', @CreatedBy
            )
            
            SET @TransferID = SCOPE_IDENTITY()
            
        COMMIT TRANSACTION
        
        SELECT @TransferID AS TransferID, @TransferNumber AS TransferNumber, 
               'Stock transfer created successfully.' AS Message
        
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
-- STORED PROCEDURE: Process Stock Transfer (Dispatch)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcessStockTransferDispatch]
    @TransferID INT,
    @DispatchedBy NVARCHAR(100),
    @TrackingNumber NVARCHAR(100) = NULL,
    @Remarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @TransferStatus NVARCHAR(50)
            DECLARE @TransferNumber NVARCHAR(50)
            DECLARE @SourceStoreID INT
            
            SELECT 
                @TransferStatus = TransferStatus,
                @TransferNumber = TransferNumber,
                @SourceStoreID = SourceStoreID
            FROM StockTransfer
            WHERE TransferID = @TransferID
            
            IF @TransferStatus IS NULL
            BEGIN
                RAISERROR('Transfer not found.', 16, 1)
                RETURN
            END
            
            IF @TransferStatus != 'Draft'
            BEGIN
                RAISERROR('Transfer can only be dispatched from Draft status.', 16, 1)
                RETURN
            END
            
            -- Process transfer details and update stock
            DECLARE @TransferDetailID INT
            DECLARE @ItemID INT
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @TransferQuantity DECIMAL(18,3)
            DECLARE @UnitPrice DECIMAL(18,2)
            DECLARE @UnitOfMeasure NVARCHAR(20)
            
            DECLARE transfer_cursor CURSOR FOR
            SELECT 
                TransferDetailID, ItemID, ItemCode, TransferQuantity, 
                UnitPrice, UnitOfMeasure
            FROM StockTransferDetails
            WHERE TransferID = @TransferID AND TransferStatus = 'Pending'
            
            OPEN transfer_cursor
            FETCH NEXT FROM transfer_cursor INTO @TransferDetailID, @ItemID, @ItemCode, @TransferQuantity, 
                                           @UnitPrice, @UnitOfMeasure
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Reduce stock from source store
                UPDATE ItemMaster
                SET CurrentStock = CurrentStock - @TransferQuantity,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @DispatchedBy
                WHERE ItemID = @ItemID
                
                -- Create Stock Movement for dispatch
                DECLARE @MovementNumber NVARCHAR(50)
                DECLARE @MovementSeq INT
                
                SELECT @MovementSeq = ISNULL(MAX(CAST(RIGHT(MovementNumber, 6) AS INT)), 0) + 1
                FROM StockMovement
                WHERE MovementNumber LIKE 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-%'
                
                SET @MovementNumber = 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + RIGHT('000000' + CAST(@MovementSeq AS VARCHAR(6)), 6)
                
                INSERT INTO StockMovement (
                    MovementNumber, MovementType, ItemID, ItemCode, ItemName,
                    SourceStoreID, SourceStoreCode,
                    Quantity, UnitOfMeasure, UnitPrice, TotalValue,
                    MovementDate, CreatedBy, Remarks
                )
                SELECT 
                    @MovementNumber, 'Transfer Out', I.ItemID, I.ItemCode, I.ItemName,
                    @SourceStoreID, S.StoreCode,
                    @TransferQuantity, @UnitOfMeasure, @UnitPrice, @TransferQuantity * @UnitPrice,
                    GETDATE(), @DispatchedBy, @Remarks
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                WHERE I.ItemID = @ItemID AND S.StoreID = @SourceStoreID
                
                -- Update Stock Ledger (Outward)
                INSERT INTO StockLedger (
                    ItemID, ItemCode, StoreID, BatchNumber,
                    OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                    UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                )
                SELECT 
                    @ItemID, @ItemCode, @SourceStoreID, NULL,
                    ISNULL(ClosingStock, 0), 0, @TransferQuantity, 
                    ISNULL(ClosingStock, 0) - @TransferQuantity,
                    @UnitOfMeasure, GETDATE(), @TransferNumber, 'Transfer Out'
                FROM (
                    SELECT TOP 1 ClosingStock
                    FROM StockLedger
                    WHERE ItemID = @ItemID AND StoreID = @SourceStoreID
                    ORDER BY TransactionDate DESC, LedgerID DESC
                ) AS LastStock
                
                -- If no previous stock, set opening to 0
                IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO StockLedger (
                        ItemID, ItemCode, StoreID, BatchNumber,
                        OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                        UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                    )
                    VALUES (
                        @ItemID, @ItemCode, @SourceStoreID, NULL,
                        0, 0, @TransferQuantity, -@TransferQuantity,
                        @UnitOfMeasure, GETDATE(), @TransferNumber, 'Transfer Out'
                    )
                END
                
                -- Update Transfer Detail status
                UPDATE StockTransferDetails
                SET TransferStatus = 'Dispatched',
                    ModifiedDate = GETDATE()
                WHERE TransferDetailID = @TransferDetailID
                
                FETCH NEXT FROM transfer_cursor INTO @TransferDetailID, @ItemID, @ItemCode, @TransferQuantity, 
                                               @UnitPrice, @UnitOfMeasure
            END
            
            CLOSE transfer_cursor
            DEALLOCATE transfer_cursor
            
            -- Update Transfer Master status
            UPDATE StockTransfer
            SET TransferStatus = 'In Transit',
                DispatchedBy = @DispatchedBy,
                DispatchedDate = GETDATE(),
                TrackingNumber = @TrackingNumber,
                Remarks = @Remarks,
                ModifiedDate = GETDATE(),
                ModifiedBy = @DispatchedBy
            WHERE TransferID = @TransferID
            
        COMMIT TRANSACTION
        
        SELECT 'Stock transfer dispatched successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'transfer_cursor') >= 0
        BEGIN
            CLOSE transfer_cursor
            DEALLOCATE transfer_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Receive Stock Transfer
-- =============================================
CREATE PROCEDURE [dbo].[sp_ReceiveStockTransfer]
    @TransferID INT,
    @ReceivedBy NVARCHAR(100),
    @ReceivedRemarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @TransferStatus NVARCHAR(50)
            DECLARE @TransferNumber NVARCHAR(50)
            DECLARE @DestinationStoreID INT
            
            SELECT 
                @TransferStatus = TransferStatus,
                @TransferNumber = TransferNumber,
                @DestinationStoreID = DestinationStoreID
            FROM StockTransfer
            WHERE TransferID = @TransferID
            
            IF @TransferStatus IS NULL
            BEGIN
                RAISERROR('Transfer not found.', 16, 1)
                RETURN
            END
            
            IF @TransferStatus != 'In Transit'
            BEGIN
                RAISERROR('Transfer can only be received from In Transit status.', 16, 1)
                RETURN
            END
            
            -- Process receipt and update stock at destination
            DECLARE @TransferDetailID INT
            DECLARE @ItemID INT
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @TransferQuantity DECIMAL(18,3)
            DECLARE @UnitPrice DECIMAL(18,2)
            DECLARE @UnitOfMeasure NVARCHAR(20)
            
            DECLARE receive_cursor CURSOR FOR
            SELECT 
                TransferDetailID, ItemID, ItemCode, TransferQuantity, 
                UnitPrice, UnitOfMeasure
            FROM StockTransferDetails
            WHERE TransferID = @TransferID AND TransferStatus = 'Dispatched'
            
            OPEN receive_cursor
            FETCH NEXT FROM receive_cursor INTO @TransferDetailID, @ItemID, @ItemCode, @TransferQuantity, 
                                           @UnitPrice, @UnitOfMeasure
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Increase stock at destination store
                UPDATE ItemMaster
                SET CurrentStock = CurrentStock + @TransferQuantity,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ReceivedBy
                WHERE ItemID = @ItemID
                
                -- Create Stock Movement for receipt
                DECLARE @MovementNumber NVARCHAR(50)
                DECLARE @MovementSeq INT
                
                SELECT @MovementSeq = ISNULL(MAX(CAST(RIGHT(MovementNumber, 6) AS INT)), 0) + 1
                FROM StockMovement
                WHERE MovementNumber LIKE 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-%'
                
                SET @MovementNumber = 'STM-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + RIGHT('000000' + CAST(@MovementSeq AS VARCHAR(6)), 6)
                
                INSERT INTO StockMovement (
                    MovementNumber, MovementType, ItemID, ItemCode, ItemName,
                    DestinationStoreID, DestinationStoreCode,
                    Quantity, UnitOfMeasure, UnitPrice, TotalValue,
                    MovementDate, CreatedBy, Remarks
                )
                SELECT 
                    @MovementNumber, 'Transfer In', I.ItemID, I.ItemCode, I.ItemName,
                    @DestinationStoreID, S.StoreCode,
                    @TransferQuantity, @UnitOfMeasure, @UnitPrice, @TransferQuantity * @UnitPrice,
                    GETDATE(), @ReceivedBy, @ReceivedRemarks
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                WHERE I.ItemID = @ItemID AND S.StoreID = @DestinationStoreID
                
                -- Update Stock Ledger (Inward) at destination
                INSERT INTO StockLedger (
                    ItemID, ItemCode, StoreID, BatchNumber,
                    OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                    UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                )
                SELECT 
                    @ItemID, @ItemCode, @DestinationStoreID, NULL,
                    ISNULL(ClosingStock, 0), @TransferQuantity, 0, 
                    ISNULL(ClosingStock, 0) + @TransferQuantity,
                    @UnitOfMeasure, GETDATE(), @TransferNumber, 'Transfer In'
                FROM (
                    SELECT TOP 1 ClosingStock
                    FROM StockLedger
                    WHERE ItemID = @ItemID AND StoreID = @DestinationStoreID
                    ORDER BY TransactionDate DESC, LedgerID DESC
                ) AS LastStock
                
                -- If no previous stock, set opening to 0
                IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO StockLedger (
                        ItemID, ItemCode, StoreID, BatchNumber,
                        OpeningStock, InwardQuantity, OutwardQuantity, ClosingStock,
                        UnitOfMeasure, TransactionDate, ReferenceNumber, ReferenceType
                    )
                    VALUES (
                        @ItemID, @ItemCode, @DestinationStoreID, NULL,
                        0, @TransferQuantity, 0, @TransferQuantity,
                        @UnitOfMeasure, GETDATE(), @TransferNumber, 'Transfer In'
                    )
                END
                
                -- Update Transfer Detail status
                UPDATE StockTransferDetails
                SET ReceivedQuantity = @TransferQuantity,
                    TransferStatus = 'Received',
                    ModifiedDate = GETDATE()
                WHERE TransferDetailID = @TransferDetailID
                
                FETCH NEXT FROM receive_cursor INTO @TransferDetailID, @ItemID, @ItemCode, @TransferQuantity, 
                                               @UnitPrice, @UnitOfMeasure
            END
            
            CLOSE receive_cursor
            DEALLOCATE receive_cursor
            
            -- Update Transfer Master status
            UPDATE StockTransfer
            SET TransferStatus = 'Received',
                ReceivedBy = @ReceivedBy,
                ReceivedDate = GETDATE(),
                ReceivedRemarks = @ReceivedRemarks,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ReceivedBy
            WHERE TransferID = @TransferID
            
        COMMIT TRANSACTION
        
        SELECT 'Stock transfer received successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'receive_cursor') >= 0
        BEGIN
            CLOSE receive_cursor
            DEALLOCATE receive_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Get Employee Material History
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetEmployeeMaterialHistory]
    @EmployeeID INT,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    -- Issues to Employee
    SELECT 
        'Issue' AS TransactionType,
        MI.IssueNumber AS DocumentNumber,
        MI.IssueDate AS TransactionDate,
        MI.Purpose,
        MI.TotalQuantity,
        MI.TotalValue,
        MI.IssueStatus
    FROM MaterialIssue MI
    WHERE MI.EmployeeID = @EmployeeID
        AND (@FromDate IS NULL OR MI.IssueDate >= @FromDate)
        AND (@ToDate IS NULL OR MI.IssueDate <= @ToDate)
    
    UNION ALL
    
    -- Returns from Employee
    SELECT 
        'Return' AS TransactionType,
        MR.ReturnNumber AS DocumentNumber,
        MR.ReturnDate AS TransactionDate,
        MR.Reason AS Purpose,
        MR.TotalQuantity,
        MR.TotalValue,
        MR.ReturnStatus
    FROM MaterialReturn MR
    WHERE MR.EmployeeID = @EmployeeID
        AND (@FromDate IS NULL OR MR.ReturnDate >= @FromDate)
        AND (@ToDate IS NULL OR MR.ReturnDate <= @ToDate)
    
    ORDER BY TransactionDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Store Transaction Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetStoreTransactionReport]
    @StoreID INT,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @TransactionType NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    -- Issues from Store
    IF @TransactionType IS NULL OR @TransactionType = 'Issue'
    BEGIN
        SELECT 
            'Issue' AS TransactionType,
            MI.IssueNumber AS DocumentNumber,
            MI.IssueDate AS TransactionDate,
            MI.EmployeeName AS Recipient,
            MI.Department,
            MI.Purpose,
            MI.TotalQuantity,
            MI.TotalValue,
            MI.IssueStatus
        FROM MaterialIssue MI
        WHERE MI.StoreID = @StoreID
            AND (@FromDate IS NULL OR MI.IssueDate >= @FromDate)
            AND (@ToDate IS NULL OR MI.IssueDate <= @ToDate)
    END
    
    -- Returns to Store
    IF @TransactionType IS NULL OR @TransactionType = 'Return'
    BEGIN
        SELECT 
            'Return' AS TransactionType,
            MR.ReturnNumber AS DocumentNumber,
            MR.ReturnDate AS TransactionDate,
            MR.EmployeeName AS ReturnedBy,
            MR.Department,
            MR.Reason AS Purpose,
            MR.TotalQuantity,
            MR.TotalValue,
            MR.ReturnStatus
        FROM MaterialReturn MR
        WHERE MR.StoreID = @StoreID
            AND (@FromDate IS NULL OR MR.ReturnDate >= @FromDate)
            AND (@ToDate IS NULL OR MR.ReturnDate <= @ToDate)
    END
    
    -- Transfers from Store
    IF @TransactionType IS NULL OR @TransactionType = 'Transfer Out'
    BEGIN
        SELECT 
            'Transfer Out' AS TransactionType,
            ST.TransferNumber AS DocumentNumber,
            ST.TransferDate AS TransactionDate,
            ST.DestinationStoreName AS Destination,
            ST.Purpose,
            ST.TotalQuantity,
            ST.TotalValue,
            ST.TransferStatus
        FROM StockTransfer ST
        WHERE ST.SourceStoreID = @StoreID
            AND (@FromDate IS NULL OR ST.TransferDate >= @FromDate)
            AND (@ToDate IS NULL OR ST.TransferDate <= @ToDate)
    END
    
    -- Transfers to Store
    IF @TransactionType IS NULL OR @TransactionType = 'Transfer In'
    BEGIN
        SELECT 
            'Transfer In' AS TransactionType,
            ST.TransferNumber AS DocumentNumber,
            ST.TransferDate AS TransactionDate,
            ST.SourceStoreName AS Source,
            ST.Purpose,
            ST.TotalQuantity,
            ST.TotalValue,
            ST.TransferStatus
        FROM StockTransfer ST
        WHERE ST.DestinationStoreID = @StoreID
            AND (@FromDate IS NULL OR ST.TransferDate >= @FromDate)
            AND (@ToDate IS NULL OR ST.TransferDate <= @ToDate)
    END
    
    ORDER BY TransactionDate DESC
END
GO

-- =============================================
-- CREATE USER-DEFINED TABLE TYPES
-- =============================================
CREATE TYPE [dbo].[IssueItemType] AS TABLE (
    LineNumber INT NOT NULL,
    ItemID INT NOT NULL,
    ItemCode NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(200) NOT NULL,
    ItemDescription NVARCHAR(500) NULL,
    UnitOfMeasure NVARCHAR(20) NOT NULL,
    RequestedQuantity DECIMAL(18,3) NOT NULL,
    IssuedQuantity DECIMAL(18,3) NOT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    TotalAmount DECIMAL(18,2) NULL
)
GO

CREATE TYPE [dbo].[ReturnItemType] AS TABLE (
    LineNumber INT NOT NULL,
    IssueDetailID INT NULL,
    ItemID INT NOT NULL,
    ItemCode NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(200) NOT NULL,
    ItemDescription NVARCHAR(500) NULL,
    UnitOfMeasure NVARCHAR(20) NOT NULL,
    ReturnedQuantity DECIMAL(18,3) NOT NULL,
    BatchNumber NVARCHAR(100) NULL,
    SerialNumber NVARCHAR(500) NULL,
    Condition NVARCHAR(50) NULL,
    ConditionRemarks NVARCHAR(500) NULL,
    UnitPrice DECIMAL(18,2) NULL,
    TotalAmount DECIMAL(18,2) NULL
)
GO

-- =============================================
-- INSERT SAMPLE EMPLOYEE DATA
-- =============================================
INSERT INTO EmployeeMaster (
    EmployeeCode, EmployeeName, Department, Designation, 
    Email, Phone, EmployeeType, CostCenter, CreatedBy
)
VALUES 
    ('EMP001', 'John Smith', 'Production', 'Operator', 'john.smith@company.com', '1234567890', 'Permanent', 'CC-PROD-01', 'SYSTEM'),
    ('EMP002', 'Sarah Johnson', 'Maintenance', 'Technician', 'sarah.johnson@company.com', '1234567891', 'Permanent', 'CC-MAINT-01', 'SYSTEM'),
    ('EMP003', 'Mike Brown', 'Quality', 'Inspector', 'mike.brown@company.com', '1234567892', 'Permanent', 'CC-QC-01', 'SYSTEM'),
    ('EMP004', 'Lisa Davis', 'R&D', 'Engineer', 'lisa.davis@company.com', '1234567893', 'Permanent', 'CC-RND-01', 'SYSTEM'),
    ('EMP005', 'Robert Wilson', 'Production', 'Supervisor', 'robert.wilson@company.com', '1234567894', 'Permanent', 'CC-PROD-02', 'SYSTEM')

GO

PRINT 'Material Issue, Return, and Transfer tables and stored procedures created successfully!'