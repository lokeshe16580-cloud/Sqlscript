-- =============================================
-- DATABASE: Serial Number Tracking System
-- DESCRIPTION: Complete Item Serial Number Tracking Integration
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- CREATE SERIAL NUMBER MASTER TABLE
-- =============================================
CREATE TABLE [dbo].[SerialNumberMaster] (
    [SerialID] INT IDENTITY(1,1) NOT NULL,
    [SerialNumber] NVARCHAR(100) NOT NULL,
    [ItemID] INT NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [BatchNumber] NVARCHAR(100) NULL,
    
    -- Serial Number Details
    [SerialType] NVARCHAR(50) NOT NULL DEFAULT 'Unique', -- 'Unique', 'Batch', 'Range'
    [SerialStatus] NVARCHAR(50) NOT NULL DEFAULT 'Available', -- 'Available', 'Issued', 'Returned', 'Damaged', 'Expired', 'Under Repair', 'Scrapped'
    [SerialGenerationDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ExpiryDate] DATE NULL,
    
    -- Manufacturing Details
    [ManufacturingDate] DATE NULL,
    [Manufacturer] NVARCHAR(200) NULL,
    [WarrantyStartDate] DATE NULL,
    [WarrantyEndDate] DATE NULL,
    [WarrantyPeriodMonths] INT NULL,
    
    -- Current Location
    [CurrentStoreID] INT NULL,
    [CurrentStoreCode] NVARCHAR(50) NULL,
    [CurrentStoreName] NVARCHAR(200) NULL,
    [CurrentBinID] INT NULL,
    [CurrentBinCode] NVARCHAR(50) NULL,
    [CurrentEmployeeID] INT NULL,
    [CurrentEmployeeCode] NVARCHAR(50) NULL,
    [CurrentEmployeeName] NVARCHAR(200) NULL,
    
    -- Current Status
    [IsAvailable] BIT NOT NULL DEFAULT 1,
    [IsIssued] BIT NOT NULL DEFAULT 0,
    [IsUnderMaintenance] BIT NOT NULL DEFAULT 0,
    [IsDamaged] BIT NOT NULL DEFAULT 0,
    
    -- Financial
    [PurchasePrice] DECIMAL(18,2) NULL,
    [CurrentValue] DECIMAL(18,2) NULL,
    [DepreciationRate] DECIMAL(5,2) NULL,
    
    -- Tracking
    [LastTransactionType] NVARCHAR(50) NULL, -- 'GRN', 'Issue', 'Return', 'Transfer'
    [LastTransactionID] INT NULL,
    [LastTransactionNumber] NVARCHAR(50) NULL,
    [LastTransactionDate] DATETIME NULL,
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    
    CONSTRAINT PK_SerialNumberMaster PRIMARY KEY CLUSTERED (SerialID ASC),
    CONSTRAINT UQ_SerialNumberMaster_SerialNumber UNIQUE NONCLUSTERED (SerialNumber ASC),
    CONSTRAINT FK_SerialNumberMaster_ItemMaster FOREIGN KEY (ItemID) REFERENCES ItemMaster(ItemID)
)

GO

-- =============================================
-- CREATE SERIAL NUMBER HISTORY TABLE
-- =============================================
CREATE TABLE [dbo].[SerialNumberHistory] (
    [HistoryID] INT IDENTITY(1,1) NOT NULL,
    [SerialID] INT NOT NULL,
    [SerialNumber] NVARCHAR(100) NOT NULL,
    [ItemID] INT NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    
    [ActionType] NVARCHAR(50) NOT NULL, -- 'GRN', 'Issue', 'Return', 'Transfer', 'Repair', 'Scrap', 'Status Change'
    [ActionDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ActionBy] NVARCHAR(100) NOT NULL,
    
    [PreviousStatus] NVARCHAR(50) NULL,
    [NewStatus] NVARCHAR(50) NOT NULL,
    
    [SourceStoreID] INT NULL,
    [SourceStoreCode] NVARCHAR(50) NULL,
    [DestinationStoreID] INT NULL,
    [DestinationStoreCode] NVARCHAR(50) NULL,
    [EmployeeID] INT NULL,
    [EmployeeCode] NVARCHAR(50) NULL,
    
    [ReferenceType] NVARCHAR(50) NULL, -- 'GRN', 'Issue', 'Return', 'Transfer'
    [ReferenceID] INT NULL,
    [ReferenceNumber] NVARCHAR(50) NULL,
    
    [Remarks] NVARCHAR(MAX) NULL,
    [IPAddress] NVARCHAR(50) NULL,
    
    CONSTRAINT PK_SerialNumberHistory PRIMARY KEY CLUSTERED (HistoryID ASC),
    CONSTRAINT FK_SerialNumberHistory_SerialNumberMaster FOREIGN KEY (SerialID) REFERENCES SerialNumberMaster(SerialID)
)

GO

-- =============================================
-- CREATE SERIAL NUMBER MAPPING TABLE FOR TRANSACTIONS
-- =============================================
CREATE TABLE [dbo].[TransactionSerialMapping] (
    [MappingID] INT IDENTITY(1,1) NOT NULL,
    [TransactionType] NVARCHAR(50) NOT NULL, -- 'GRN', 'Issue', 'Return', 'Transfer'
    [TransactionID] INT NOT NULL,
    [TransactionDetailID] INT NULL,
    [TransactionNumber] NVARCHAR(50) NOT NULL,
    [SerialID] INT NOT NULL,
    [SerialNumber] NVARCHAR(100) NOT NULL,
    [ItemID] INT NOT NULL,
    
    [Action] NVARCHAR(50) NOT NULL, -- 'Add', 'Remove', 'Transfer'
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_TransactionSerialMapping PRIMARY KEY CLUSTERED (MappingID ASC),
    CONSTRAINT FK_TransactionSerialMapping_SerialNumberMaster FOREIGN KEY (SerialID) REFERENCES SerialNumberMaster(SerialID)
)

GO

-- =============================================
-- ADD SERIAL TRACKING FLAG TO ITEM MASTER
-- =============================================
ALTER TABLE ItemMaster ADD 
    [IsSerialTracked] BIT NOT NULL DEFAULT 0,
    [IsBatchTracked] BIT NOT NULL DEFAULT 0,
    [SerialNumberFormat] NVARCHAR(50) NULL,
    [RequireWarrantyTracking] BIT NOT NULL DEFAULT 0

GO

-- =============================================
-- ADD SERIAL NUMBER COLUMNS TO EXISTING TABLES
-- =============================================

-- Add to GRNDetails
ALTER TABLE GRNDetails ADD
    [HasSerialNumbers] BIT NOT NULL DEFAULT 0,
    [SerialNumbersCount] INT NULL DEFAULT 0

-- Add to MaterialIssueDetails
ALTER TABLE MaterialIssueDetails ADD
    [HasSerialNumbers] BIT NOT NULL DEFAULT 0,
    [SerialNumbersCount] INT NULL DEFAULT 0

-- Add to MaterialReturnDetails
ALTER TABLE MaterialReturnDetails ADD
    [HasSerialNumbers] BIT NOT NULL DEFAULT 0,
    [SerialNumbersCount] INT NULL DEFAULT 0

-- Add to StockTransferDetails
ALTER TABLE StockTransferDetails ADD
    [HasSerialNumbers] BIT NOT NULL DEFAULT 0,
    [SerialNumbersCount] INT NULL DEFAULT 0

GO

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_SerialNumber ON SerialNumberMaster(SerialNumber)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_ItemID ON SerialNumberMaster(ItemID)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_SerialStatus ON SerialNumberMaster(SerialStatus)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_CurrentStoreID ON SerialNumberMaster(CurrentStoreID)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_CurrentEmployeeID ON SerialNumberMaster(CurrentEmployeeID)

CREATE NONCLUSTERED INDEX IX_SerialNumberHistory_SerialID ON SerialNumberHistory(SerialID)
CREATE NONCLUSTERED INDEX IX_SerialNumberHistory_ActionDate ON SerialNumberHistory(ActionDate)

CREATE NONCLUSTERED INDEX IX_TransactionSerialMapping_TransactionType_TransactionID ON TransactionSerialMapping(TransactionType, TransactionID)
CREATE NONCLUSTERED INDEX IX_TransactionSerialMapping_SerialID ON TransactionSerialMapping(SerialID)

GO

-- =============================================
-- STORED PROCEDURE: Generate Serial Numbers for GRN
-- =============================================
CREATE PROCEDURE [dbo].[sp_GenerateSerialNumbersForGRN]
    @GRNDetailID INT,
    @ItemID INT,
    @Quantity INT,
    @SerialNumberPrefix NVARCHAR(20) = NULL,
    @StartingNumber INT = NULL,
    @BatchNumber NVARCHAR(100) = NULL,
    @CreatedBy NVARCHAR(100),
    @GeneratedCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @GRNID INT
            DECLARE @GRNNumber NVARCHAR(50)
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @StoreID INT
            
            -- Get GRN details
            SELECT 
                @GRNID = GRNID,
                @GRNNumber = G.GRNNumber,
                @StoreID = G.StoreID
            FROM GRNDetails GD
            INNER JOIN GRNMaster G ON GD.GRNID = G.GRNID
            WHERE GD.GRNDetailID = @GRNDetailID
            
            SELECT @ItemCode = ItemCode FROM ItemMaster WHERE ItemID = @ItemID
            
            -- Generate serial numbers
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @Counter INT = 1
            DECLARE @Year INT = YEAR(GETDATE())
            DECLARE @Month INT = MONTH(GETDATE())
            
            SET @GeneratedCount = 0
            
            WHILE @Counter <= @Quantity
            BEGIN
                -- Generate serial number
                IF @SerialNumberPrefix IS NULL
                    SET @SerialNumber = @ItemCode + '-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                                        RIGHT('0000' + CAST(@StartingNumber + @Counter - 1 AS VARCHAR(10)), 4)
                ELSE
                    SET @SerialNumber = @SerialNumberPrefix + '-' + 
                                        RIGHT('0000' + CAST(@StartingNumber + @Counter - 1 AS VARCHAR(10)), 4)
                
                -- Check if serial number already exists
                IF EXISTS (SELECT 1 FROM SerialNumberMaster WHERE SerialNumber = @SerialNumber)
                BEGIN
                    SET @Counter = @Counter + 1
                    CONTINUE
                END
                
                -- Insert serial number
                INSERT INTO SerialNumberMaster (
                    SerialNumber, ItemID, ItemCode, ItemName, BatchNumber,
                    SerialStatus, CurrentStoreID, CurrentStoreCode, CurrentStoreName,
                    PurchasePrice, LastTransactionType, LastTransactionID, 
                    LastTransactionNumber, LastTransactionDate, CreatedBy
                )
                SELECT 
                    @SerialNumber, I.ItemID, I.ItemCode, I.ItemName, @BatchNumber,
                    'Available', S.StoreID, S.StoreCode, S.StoreName,
                    GD.UnitPrice, 'GRN', @GRNID, @GRNNumber, GETDATE(), @CreatedBy
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                CROSS JOIN GRNDetails GD
                WHERE I.ItemID = @ItemID 
                    AND S.StoreID = @StoreID
                    AND GD.GRNDetailID = @GRNDetailID
                
                SET @SerialID = SCOPE_IDENTITY()
                
                -- Map serial to transaction
                INSERT INTO TransactionSerialMapping (
                    TransactionType, TransactionID, TransactionDetailID, TransactionNumber,
                    SerialID, SerialNumber, ItemID, Action
                )
                VALUES (
                    'GRN', @GRNID, @GRNDetailID, @GRNNumber,
                    @SerialID, @SerialNumber, @ItemID, 'Add'
                )
                
                -- Add to history
                INSERT INTO SerialNumberHistory (
                    SerialID, SerialNumber, ItemID, ItemCode,
                    ActionType, ActionBy, NewStatus,
                    DestinationStoreID, DestinationStoreCode,
                    ReferenceType, ReferenceID, ReferenceNumber
                )
                VALUES (
                    @SerialID, @SerialNumber, @ItemID, @ItemCode,
                    'GRN', @CreatedBy, 'Available',
                    @StoreID, (SELECT StoreCode FROM StoreMaster WHERE StoreID = @StoreID),
                    'GRN', @GRNID, @GRNNumber
                )
                
                SET @GeneratedCount = @GeneratedCount + 1
                SET @Counter = @Counter + 1
            END
            
            -- Update GRN Detail with serial numbers count
            UPDATE GRNDetails
            SET HasSerialNumbers = 1,
                SerialNumbersCount = @GeneratedCount
            WHERE GRNDetailID = @GRNDetailID
            
        COMMIT TRANSACTION
        
        SELECT @GeneratedCount AS GeneratedCount, 'Serial numbers generated successfully.' AS Message
        
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
-- STORED PROCEDURE: Issue Serialized Items
-- =============================================
CREATE PROCEDURE [dbo].[sp_IssueSerializedItems]
    @IssueDetailID INT,
    @SerialNumbers XML, -- List of serial numbers to issue
    @IssuedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @IssueID INT
            DECLARE @IssueNumber NVARCHAR(50)
            DECLARE @ItemID INT
            DECLARE @StoreID INT
            DECLARE @EmployeeID INT
            
            -- Get issue details
            SELECT 
                @IssueID = IssueID,
                @ItemID = ItemID,
                @StoreID = M.StoreID,
                @EmployeeID = M.EmployeeID
            FROM MaterialIssueDetails MID
            INNER JOIN MaterialIssue M ON MID.IssueID = M.IssueID
            WHERE MID.IssueDetailID = @IssueDetailID
            
            SELECT @IssueNumber = IssueNumber FROM MaterialIssue WHERE IssueID = @IssueID
            
            -- Process each serial number
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @SerialID INT
            
            DECLARE serial_cursor CURSOR FOR
            SELECT X.value('@SerialNumber', 'NVARCHAR(100)') AS SerialNumber
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            OPEN serial_cursor
            FETCH NEXT FROM serial_cursor INTO @SerialNumber
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get serial ID
                SELECT @SerialID = SerialID 
                FROM SerialNumberMaster 
                WHERE SerialNumber = @SerialNumber 
                    AND ItemID = @ItemID
                    AND SerialStatus = 'Available'
                    AND CurrentStoreID = @StoreID
                
                IF @SerialID IS NULL
                BEGIN
                    CLOSE serial_cursor
                    DEALLOCATE serial_cursor
                    RAISERROR('Serial number %s is not available for issue.', 16, 1, @SerialNumber)
                    RETURN
                END
                
                -- Update serial number status
                UPDATE SerialNumberMaster
                SET SerialStatus = 'Issued',
                    IsAvailable = 0,
                    IsIssued = 1,
                    CurrentEmployeeID = @EmployeeID,
                    CurrentEmployeeCode = (SELECT EmployeeCode FROM EmployeeMaster WHERE EmployeeID = @EmployeeID),
                    CurrentEmployeeName = (SELECT EmployeeName FROM EmployeeMaster WHERE EmployeeID = @EmployeeID),
                    LastTransactionType = 'Issue',
                    LastTransactionID = @IssueID,
                    LastTransactionNumber = @IssueNumber,
                    LastTransactionDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @IssuedBy
                WHERE SerialID = @SerialID
                
                -- Map serial to transaction
                INSERT INTO TransactionSerialMapping (
                    TransactionType, TransactionID, TransactionDetailID, TransactionNumber,
                    SerialID, SerialNumber, ItemID, Action
                )
                VALUES (
                    'Issue', @IssueID, @IssueDetailID, @IssueNumber,
                    @SerialID, @SerialNumber, @ItemID, 'Remove'
                )
                
                -- Add to history
                INSERT INTO SerialNumberHistory (
                    SerialID, SerialNumber, ItemID, ItemCode,
                    ActionType, ActionBy, PreviousStatus, NewStatus,
                    SourceStoreID, SourceStoreCode,
                    EmployeeID, EmployeeCode,
                    ReferenceType, ReferenceID, ReferenceNumber
                )
                SELECT 
                    @SerialID, @SerialNumber, @ItemID, I.ItemCode,
                    'Issue', @IssuedBy, 'Available', 'Issued',
                    @StoreID, S.StoreCode,
                    @EmployeeID, E.EmployeeCode,
                    'Issue', @IssueID, @IssueNumber
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                CROSS JOIN EmployeeMaster E
                WHERE I.ItemID = @ItemID 
                    AND S.StoreID = @StoreID
                    AND E.EmployeeID = @EmployeeID
                
                FETCH NEXT FROM serial_cursor INTO @SerialNumber
            END
            
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
            
            -- Update issue detail with serial numbers count
            DECLARE @SerialCount INT
            SELECT @SerialCount = COUNT(*) 
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            UPDATE MaterialIssueDetails
            SET HasSerialNumbers = 1,
                SerialNumbersCount = @SerialCount
            WHERE IssueDetailID = @IssueDetailID
            
        COMMIT TRANSACTION
        
        SELECT 'Serialized items issued successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'serial_cursor') >= 0
        BEGIN
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Return Serialized Items
-- =============================================
CREATE PROCEDURE [dbo].[sp_ReturnSerializedItems]
    @ReturnDetailID INT,
    @SerialNumbers XML,
    @Condition NVARCHAR(50) = 'Good',
    @ConditionRemarks NVARCHAR(500) = NULL,
    @ReceivedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @ReturnID INT
            DECLARE @ReturnNumber NVARCHAR(50)
            DECLARE @ItemID INT
            DECLARE @StoreID INT
            DECLARE @EmployeeID INT
            
            -- Get return details
            SELECT 
                @ReturnID = ReturnID,
                @ItemID = ItemID,
                @StoreID = R.StoreID,
                @EmployeeID = R.EmployeeID
            FROM MaterialReturnDetails MRD
            INNER JOIN MaterialReturn R ON MRD.ReturnID = R.ReturnID
            WHERE MRD.ReturnDetailID = @ReturnDetailID
            
            SELECT @ReturnNumber = ReturnNumber FROM MaterialReturn WHERE ReturnID = @ReturnID
            
            -- Process each serial number
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @SerialID INT
            
            DECLARE serial_cursor CURSOR FOR
            SELECT X.value('@SerialNumber', 'NVARCHAR(100)') AS SerialNumber
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            OPEN serial_cursor
            FETCH NEXT FROM serial_cursor INTO @SerialNumber
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get serial ID
                SELECT @SerialID = SerialID 
                FROM SerialNumberMaster 
                WHERE SerialNumber = @SerialNumber 
                    AND ItemID = @ItemID
                    AND SerialStatus = 'Issued'
                
                IF @SerialID IS NULL
                BEGIN
                    CLOSE serial_cursor
                    DEALLOCATE serial_cursor
                    RAISERROR('Serial number %s is not in issued status.', 16, 1, @SerialNumber)
                    RETURN
                END
                
                -- Update serial number status based on condition
                DECLARE @NewStatus NVARCHAR(50)
                SET @NewStatus = CASE 
                    WHEN @Condition = 'Good' THEN 'Available'
                    WHEN @Condition = 'Damaged' THEN 'Damaged'
                    WHEN @Condition = 'Expired' THEN 'Expired'
                    WHEN @Condition = 'Under Repair' THEN 'Under Repair'
                    ELSE 'Returned'
                END
                
                UPDATE SerialNumberMaster
                SET SerialStatus = @NewStatus,
                    IsAvailable = CASE WHEN @Condition = 'Good' THEN 1 ELSE 0 END,
                    IsIssued = 0,
                    CurrentEmployeeID = NULL,
                    CurrentEmployeeCode = NULL,
                    CurrentEmployeeName = NULL,
                    CurrentStoreID = @StoreID,
                    CurrentStoreCode = (SELECT StoreCode FROM StoreMaster WHERE StoreID = @StoreID),
                    CurrentStoreName = (SELECT StoreName FROM StoreMaster WHERE StoreID = @StoreID),
                    LastTransactionType = 'Return',
                    LastTransactionID = @ReturnID,
                    LastTransactionNumber = @ReturnNumber,
                    LastTransactionDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ReceivedBy
                WHERE SerialID = @SerialID
                
                -- Map serial to transaction
                INSERT INTO TransactionSerialMapping (
                    TransactionType, TransactionID, TransactionDetailID, TransactionNumber,
                    SerialID, SerialNumber, ItemID, Action
                )
                VALUES (
                    'Return', @ReturnID, @ReturnDetailID, @ReturnNumber,
                    @SerialID, @SerialNumber, @ItemID, 'Add'
                )
                
                -- Add to history
                INSERT INTO SerialNumberHistory (
                    SerialID, SerialNumber, ItemID, ItemCode,
                    ActionType, ActionBy, PreviousStatus, NewStatus,
                    DestinationStoreID, DestinationStoreCode,
                    EmployeeID, EmployeeCode,
                    ReferenceType, ReferenceID, ReferenceNumber,
                    Remarks
                )
                SELECT 
                    @SerialID, @SerialNumber, @ItemID, I.ItemCode,
                    'Return', @ReceivedBy, 'Issued', @NewStatus,
                    @StoreID, S.StoreCode,
                    @EmployeeID, E.EmployeeCode,
                    'Return', @ReturnID, @ReturnNumber,
                    'Condition: ' + @Condition + '. ' + ISNULL(@ConditionRemarks, '')
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                CROSS JOIN EmployeeMaster E
                WHERE I.ItemID = @ItemID 
                    AND S.StoreID = @StoreID
                    AND E.EmployeeID = @EmployeeID
                
                FETCH NEXT FROM serial_cursor INTO @SerialNumber
            END
            
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
            
            -- Update return detail with serial numbers count
            DECLARE @SerialCount INT
            SELECT @SerialCount = COUNT(*) 
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            UPDATE MaterialReturnDetails
            SET HasSerialNumbers = 1,
                SerialNumbersCount = @SerialCount,
                Condition = @Condition,
                ConditionRemarks = @ConditionRemarks
            WHERE ReturnDetailID = @ReturnDetailID
            
        COMMIT TRANSACTION
        
        SELECT 'Serialized items returned successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'serial_cursor') >= 0
        BEGIN
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Transfer Serialized Items
-- =============================================
CREATE PROCEDURE [dbo].[sp_TransferSerializedItems]
    @TransferDetailID INT,
    @SerialNumbers XML,
    @DispatchedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @TransferID INT
            DECLARE @TransferNumber NVARCHAR(50)
            DECLARE @ItemID INT
            DECLARE @SourceStoreID INT
            DECLARE @DestinationStoreID INT
            
            -- Get transfer details
            SELECT 
                @TransferID = TransferID,
                @ItemID = ItemID,
                @SourceStoreID = ST.SourceStoreID,
                @DestinationStoreID = ST.DestinationStoreID
            FROM StockTransferDetails STD
            INNER JOIN StockTransfer ST ON STD.TransferID = ST.TransferID
            WHERE STD.TransferDetailID = @TransferDetailID
            
            SELECT @TransferNumber = TransferNumber FROM StockTransfer WHERE TransferID = @TransferID
            
            -- Process each serial number
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @SerialID INT
            
            DECLARE serial_cursor CURSOR FOR
            SELECT X.value('@SerialNumber', 'NVARCHAR(100)') AS SerialNumber
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            OPEN serial_cursor
            FETCH NEXT FROM serial_cursor INTO @SerialNumber
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get serial ID
                SELECT @SerialID = SerialID 
                FROM SerialNumberMaster 
                WHERE SerialNumber = @SerialNumber 
                    AND ItemID = @ItemID
                    AND SerialStatus = 'Available'
                    AND CurrentStoreID = @SourceStoreID
                
                IF @SerialID IS NULL
                BEGIN
                    CLOSE serial_cursor
                    DEALLOCATE serial_cursor
                    RAISERROR('Serial number %s is not available for transfer.', 16, 1, @SerialNumber)
                    RETURN
                END
                
                -- Update serial number status (in transit)
                UPDATE SerialNumberMaster
                SET SerialStatus = 'In Transit',
                    IsAvailable = 0,
                    LastTransactionType = 'Transfer',
                    LastTransactionID = @TransferID,
                    LastTransactionNumber = @TransferNumber,
                    LastTransactionDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @DispatchedBy
                WHERE SerialID = @SerialID
                
                -- Map serial to transaction
                INSERT INTO TransactionSerialMapping (
                    TransactionType, TransactionID, TransactionDetailID, TransactionNumber,
                    SerialID, SerialNumber, ItemID, Action
                )
                VALUES (
                    'Transfer', @TransferID, @TransferDetailID, @TransferNumber,
                    @SerialID, @SerialNumber, @ItemID, 'Transfer'
                )
                
                -- Add to history
                INSERT INTO SerialNumberHistory (
                    SerialID, SerialNumber, ItemID, ItemCode,
                    ActionType, ActionBy, PreviousStatus, NewStatus,
                    SourceStoreID, SourceStoreCode,
                    DestinationStoreID, DestinationStoreCode,
                    ReferenceType, ReferenceID, ReferenceNumber
                )
                SELECT 
                    @SerialID, @SerialNumber, @ItemID, I.ItemCode,
                    'Transfer', @DispatchedBy, 'Available', 'In Transit',
                    @SourceStoreID, S1.StoreCode,
                    @DestinationStoreID, S2.StoreCode,
                    'Transfer', @TransferID, @TransferNumber
                FROM ItemMaster I
                CROSS JOIN StoreMaster S1
                CROSS JOIN StoreMaster S2
                WHERE I.ItemID = @ItemID 
                    AND S1.StoreID = @SourceStoreID
                    AND S2.StoreID = @DestinationStoreID
                
                FETCH NEXT FROM serial_cursor INTO @SerialNumber
            END
            
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
            
            -- Update transfer detail with serial numbers count
            DECLARE @SerialCount INT
            SELECT @SerialCount = COUNT(*) 
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            UPDATE StockTransferDetails
            SET HasSerialNumbers = 1,
                SerialNumbersCount = @SerialCount
            WHERE TransferDetailID = @TransferDetailID
            
        COMMIT TRANSACTION
        
        SELECT 'Serialized items transferred successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'serial_cursor') >= 0
        BEGIN
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Receive Serialized Transfer
-- =============================================
CREATE PROCEDURE [dbo].[sp_ReceiveSerializedTransfer]
    @TransferDetailID INT,
    @SerialNumbers XML,
    @ReceivedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @TransferID INT
            DECLARE @TransferNumber NVARCHAR(50)
            DECLARE @ItemID INT
            DECLARE @DestinationStoreID INT
            
            -- Get transfer details
            SELECT 
                @TransferID = TransferID,
                @ItemID = ItemID,
                @DestinationStoreID = ST.DestinationStoreID
            FROM StockTransferDetails STD
            INNER JOIN StockTransfer ST ON STD.TransferID = ST.TransferID
            WHERE STD.TransferDetailID = @TransferDetailID
            
            SELECT @TransferNumber = TransferNumber FROM StockTransfer WHERE TransferID = @TransferID
            
            -- Process each serial number
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @SerialID INT
            
            DECLARE serial_cursor CURSOR FOR
            SELECT X.value('@SerialNumber', 'NVARCHAR(100)') AS SerialNumber
            FROM @SerialNumbers.nodes('/SerialNumbers/SerialNumber') AS T(X)
            
            OPEN serial_cursor
            FETCH NEXT FROM serial_cursor INTO @SerialNumber
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get serial ID
                SELECT @SerialID = SerialID 
                FROM SerialNumberMaster 
                WHERE SerialNumber = @SerialNumber 
                    AND ItemID = @ItemID
                    AND SerialStatus = 'In Transit'
                
                IF @SerialID IS NULL
                BEGIN
                    CLOSE serial_cursor
                    DEALLOCATE serial_cursor
                    RAISERROR('Serial number %s is not in transit.', 16, 1, @SerialNumber)
                    RETURN
                END
                
                -- Update serial number status to available at destination
                UPDATE SerialNumberMaster
                SET SerialStatus = 'Available',
                    IsAvailable = 1,
                    CurrentStoreID = @DestinationStoreID,
                    CurrentStoreCode = (SELECT StoreCode FROM StoreMaster WHERE StoreID = @DestinationStoreID),
                    CurrentStoreName = (SELECT StoreName FROM StoreMaster WHERE StoreID = @DestinationStoreID),
                    LastTransactionType = 'Transfer Receive',
                    LastTransactionID = @TransferID,
                    LastTransactionNumber = @TransferNumber,
                    LastTransactionDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ReceivedBy
                WHERE SerialID = @SerialID
                
                -- Add to history
                INSERT INTO SerialNumberHistory (
                    SerialID, SerialNumber, ItemID, ItemCode,
                    ActionType, ActionBy, PreviousStatus, NewStatus,
                    DestinationStoreID, DestinationStoreCode,
                    ReferenceType, ReferenceID, ReferenceNumber
                )
                SELECT 
                    @SerialID, @SerialNumber, @ItemID, I.ItemCode,
                    'Transfer Receive', @ReceivedBy, 'In Transit', 'Available',
                    @DestinationStoreID, S.StoreCode,
                    'Transfer', @TransferID, @TransferNumber
                FROM ItemMaster I
                CROSS JOIN StoreMaster S
                WHERE I.ItemID = @ItemID 
                    AND S.StoreID = @DestinationStoreID
                
                FETCH NEXT FROM serial_cursor INTO @SerialNumber
            END
            
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
            
        COMMIT TRANSACTION
        
        SELECT 'Serialized transfer received successfully.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'serial_cursor') >= 0
        BEGIN
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: Get Serial Number Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSerialNumberDetails]
    @SerialNumber NVARCHAR(100) = NULL,
    @ItemID INT = NULL,
    @SerialStatus NVARCHAR(50) = NULL,
    @EmployeeID INT = NULL,
    @StoreID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        S.SerialID,
        S.SerialNumber,
        S.ItemID,
        S.ItemCode,
        S.ItemName,
        S.BatchNumber,
        S.SerialStatus,
        S.SerialGenerationDate,
        S.ExpiryDate,
        S.ManufacturingDate,
        S.Manufacturer,
        S.WarrantyStartDate,
        S.WarrantyEndDate,
        S.WarrantyPeriodMonths,
        S.CurrentStoreID,
        S.CurrentStoreCode,
        S.CurrentStoreName,
        S.CurrentBinID,
        S.CurrentBinCode,
        S.CurrentEmployeeID,
        S.CurrentEmployeeCode,
        S.CurrentEmployeeName,
        S.PurchasePrice,
        S.CurrentValue,
        S.LastTransactionType,
        S.LastTransactionNumber,
        S.LastTransactionDate,
        DATEDIFF(DAY, GETDATE(), S.ExpiryDate) AS DaysToExpiry,
        CASE 
            WHEN S.ExpiryDate IS NULL THEN 'No Expiry'
            WHEN S.ExpiryDate < GETDATE() THEN 'Expired'
            WHEN DATEDIFF(DAY, GETDATE(), S.ExpiryDate) <= 30 THEN 'Expiring Soon'
            ELSE 'Valid'
        END AS ExpiryStatus,
        CASE 
            WHEN S.WarrantyEndDate IS NULL THEN 'No Warranty'
            WHEN S.WarrantyEndDate < GETDATE() THEN 'Warranty Expired'
            WHEN DATEDIFF(DAY, GETDATE(), S.WarrantyEndDate) <= 30 THEN 'Warranty Expiring Soon'
            ELSE 'Under Warranty'
        END AS WarrantyStatus
    FROM SerialNumberMaster S
    WHERE (@SerialNumber IS NULL OR S.SerialNumber LIKE '%' + @SerialNumber + '%')
        AND (@ItemID IS NULL OR S.ItemID = @ItemID)
        AND (@SerialStatus IS NULL OR S.SerialStatus = @SerialStatus)
        AND (@EmployeeID IS NULL OR S.CurrentEmployeeID = @EmployeeID)
        AND (@StoreID IS NULL OR S.CurrentStoreID = @StoreID)
    ORDER BY S.SerialNumber
END
GO

-- =============================================
-- STORED PROCEDURE: Get Serial Number History
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSerialNumberHistory]
    @SerialNumber NVARCHAR(100),
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        H.HistoryID,
        H.SerialNumber,
        H.ItemCode,
        H.ActionType,
        H.ActionDate,
        H.ActionBy,
        H.PreviousStatus,
        H.NewStatus,
        H.SourceStoreCode,
        H.DestinationStoreCode,
        H.EmployeeCode,
        H.ReferenceType,
        H.ReferenceNumber,
        H.Remarks,
        DATEDIFF(DAY, H.ActionDate, GETDATE()) AS DaysAgo
    FROM SerialNumberHistory H
    WHERE H.SerialNumber = @SerialNumber
        AND (@FromDate IS NULL OR CAST(H.ActionDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(H.ActionDate AS DATE) <= @ToDate)
    ORDER BY H.ActionDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Serial Number Availability
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSerialNumberAvailability]
    @ItemID INT,
    @StoreID INT = NULL,
    @IncludeIssued BIT = 0
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        SerialNumber,
        ItemCode,
        ItemName,
        BatchNumber,
        SerialStatus,
        CurrentStoreCode,
        CurrentStoreName,
        CurrentEmployeeName,
        ExpiryDate,
        DaysToExpiry,
        WarrantyStatus
    FROM (
        SELECT 
            SerialNumber,
            ItemCode,
            ItemName,
            BatchNumber,
            SerialStatus,
            CurrentStoreCode,
            CurrentStoreName,
            CurrentEmployeeName,
            ExpiryDate,
            DATEDIFF(DAY, GETDATE(), ExpiryDate) AS DaysToExpiry,
            CASE 
                WHEN WarrantyEndDate IS NULL THEN 'No Warranty'
                WHEN WarrantyEndDate < GETDATE() THEN 'Warranty Expired'
                ELSE 'Under Warranty'
            END AS WarrantyStatus
        FROM SerialNumberMaster
        WHERE ItemID = @ItemID
            AND (@StoreID IS NULL OR CurrentStoreID = @StoreID)
            AND (SerialStatus = 'Available' OR (@IncludeIssued = 1 AND SerialStatus = 'Issued'))
    ) AS AvailableSerials
    WHERE ExpiryDate IS NULL OR ExpiryDate >= GETDATE()
    ORDER BY SerialNumber
END
GO

-- =============================================
-- STORED PROCEDURE: Update Serial Number Warranty
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateSerialWarranty]
    @SerialID INT,
    @WarrantyStartDate DATE = NULL,
    @WarrantyEndDate DATE = NULL,
    @WarrantyPeriodMonths INT = NULL,
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @ItemID INT
            
            SELECT @SerialNumber = SerialNumber, @ItemID = ItemID
            FROM SerialNumberMaster
            WHERE SerialID = @SerialID
            
            IF @SerialNumber IS NULL
            BEGIN
                RAISERROR('Serial number not found.', 16, 1)
                RETURN
            END
            
            -- Calculate warranty end date if period provided
            IF @WarrantyPeriodMonths IS NOT NULL AND @WarrantyStartDate IS NOT NULL
                SET @WarrantyEndDate = DATEADD(MONTH, @WarrantyPeriodMonths, @WarrantyStartDate)
            
            -- Update warranty information
            UPDATE SerialNumberMaster
            SET WarrantyStartDate = ISNULL(@WarrantyStartDate, WarrantyStartDate),
                WarrantyEndDate = ISNULL(@WarrantyEndDate, WarrantyEndDate),
                WarrantyPeriodMonths = ISNULL(@WarrantyPeriodMonths, WarrantyPeriodMonths),
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE SerialID = @SerialID
            
            -- Add to history
            INSERT INTO SerialNumberHistory (
                SerialID, SerialNumber, ItemID, ItemCode,
                ActionType, ActionBy, NewStatus,
                Remarks, ReferenceType
            )
            SELECT 
                @SerialID, @SerialNumber, @ItemID, I.ItemCode,
                'Warranty Update', @ModifiedBy, SerialStatus,
                'Warranty updated. Start: ' + ISNULL(CONVERT(NVARCHAR, @WarrantyStartDate), 'Not Set') + 
                ', End: ' + ISNULL(CONVERT(NVARCHAR, @WarrantyEndDate), 'Not Set'),
                'System'
            FROM ItemMaster I
            WHERE I.ItemID = @ItemID
            
        COMMIT TRANSACTION
        
        SELECT 'Warranty information updated successfully.' AS Message
        
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
-- STORED PROCEDURE: Get Serial Number Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSerialNumberReport]
    @ReportType NVARCHAR(50), -- 'ByStatus', 'ByStore', 'ByEmployee', 'Expiring', 'Warranty'
    @DateRange INT = 30 -- Days for expiry/warranty
AS
BEGIN
    SET NOCOUNT ON
    
    IF @ReportType = 'ByStatus'
    BEGIN
        SELECT 
            SerialStatus,
            COUNT(*) AS TotalCount,
            SUM(CASE WHEN ExpiryDate IS NOT NULL AND ExpiryDate < GETDATE() THEN 1 ELSE 0 END) AS ExpiredCount,
            SUM(CASE WHEN WarrantyEndDate IS NOT NULL AND WarrantyEndDate < GETDATE() THEN 1 ELSE 0 END) AS WarrantyExpiredCount
        FROM SerialNumberMaster
        GROUP BY SerialStatus
        ORDER BY SerialStatus
    END
    
    ELSE IF @ReportType = 'ByStore'
    BEGIN
        SELECT 
            CurrentStoreCode,
            CurrentStoreName,
            COUNT(*) AS TotalSerials,
            SUM(CASE WHEN SerialStatus = 'Available' THEN 1 ELSE 0 END) AS AvailableCount,
            SUM(CASE WHEN SerialStatus = 'Issued' THEN 1 ELSE 0 END) AS IssuedCount,
            SUM(CASE WHEN SerialStatus = 'Under Repair' THEN 1 ELSE 0 END) AS UnderRepairCount,
            SUM(CASE WHEN SerialStatus = 'Damaged' THEN 1 ELSE 0 END) AS DamagedCount
        FROM SerialNumberMaster
        WHERE CurrentStoreID IS NOT NULL
        GROUP BY CurrentStoreCode, CurrentStoreName
        ORDER BY CurrentStoreName
    END
    
    ELSE IF @ReportType = 'ByEmployee'
    BEGIN
        SELECT 
            CurrentEmployeeCode,
            CurrentEmployeeName,
            COUNT(*) AS TotalSerials,
            SUM(CASE WHEN SerialStatus = 'Issued' THEN 1 ELSE 0 END) AS CurrentlyIssued,
            SUM(CASE WHEN WarrantyEndDate IS NOT NULL AND WarrantyEndDate >= GETDATE() THEN 1 ELSE 0 END) AS UnderWarranty
        FROM SerialNumberMaster
        WHERE CurrentEmployeeID IS NOT NULL
        GROUP BY CurrentEmployeeCode, CurrentEmployeeName
        ORDER BY CurrentEmployeeName
    END
    
    ELSE IF @ReportType = 'Expiring'
    BEGIN
        SELECT 
            SerialNumber,
            ItemCode,
            ItemName,
            BatchNumber,
            CurrentStoreCode,
            CurrentEmployeeName,
            ExpiryDate,
            DATEDIFF(DAY, GETDATE(), ExpiryDate) AS DaysRemaining,
            SerialStatus
        FROM SerialNumberMaster
        WHERE ExpiryDate IS NOT NULL
            AND ExpiryDate >= GETDATE()
            AND DATEDIFF(DAY, GETDATE(), ExpiryDate) <= @DateRange
        ORDER BY DaysRemaining ASC
    END
    
    ELSE IF @ReportType = 'Warranty'
    BEGIN
        SELECT 
            SerialNumber,
            ItemCode,
            ItemName,
            CurrentStoreCode,
            CurrentEmployeeName,
            WarrantyStartDate,
            WarrantyEndDate,
            DATEDIFF(DAY, GETDATE(), WarrantyEndDate) AS DaysRemaining,
            SerialStatus
        FROM SerialNumberMaster
        WHERE WarrantyEndDate IS NOT NULL
            AND WarrantyEndDate >= GETDATE()
            AND DATEDIFF(DAY, GETDATE(), WarrantyEndDate) <= @DateRange
        ORDER BY DaysRemaining ASC
    END
END
GO

-- =============================================
-- STORED PROCEDURE: Bulk Import Serial Numbers
-- =============================================
CREATE PROCEDURE [dbo].[sp_BulkImportSerialNumbers]
    @Serials XML,
    @CreatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @InsertedCount INT = 0
            DECLARE @ErrorCount INT = 0
            
            -- Process each serial number from XML
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @BatchNumber NVARCHAR(100)
            DECLARE @ManufacturingDate DATE
            DECLARE @ExpiryDate DATE
            DECLARE @PurchasePrice DECIMAL(18,2)
            DECLARE @StoreCode NVARCHAR(50)
            DECLARE @ItemID INT
            DECLARE @StoreID INT
            
            DECLARE serial_cursor CURSOR FOR
            SELECT 
                X.value('@SerialNumber', 'NVARCHAR(100)'),
                X.value('@ItemCode', 'NVARCHAR(50)'),
                X.value('@BatchNumber', 'NVARCHAR(100)'),
                X.value('@ManufacturingDate', 'DATE'),
                X.value('@ExpiryDate', 'DATE'),
                X.value('@PurchasePrice', 'DECIMAL(18,2)'),
                X.value('@StoreCode', 'NVARCHAR(50)')
            FROM @Serials.nodes('/Serials/Serial') AS T(X)
            
            OPEN serial_cursor
            FETCH NEXT FROM serial_cursor INTO @SerialNumber, @ItemCode, @BatchNumber, 
                                           @ManufacturingDate, @ExpiryDate, @PurchasePrice, @StoreCode
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get Item ID
                SELECT @ItemID = ItemID FROM ItemMaster WHERE ItemCode = @ItemCode
                
                IF @ItemID IS NULL
                BEGIN
                    SET @ErrorCount = @ErrorCount + 1
                    FETCH NEXT FROM serial_cursor INTO @SerialNumber, @ItemCode, @BatchNumber, 
                                                   @ManufacturingDate, @ExpiryDate, @PurchasePrice, @StoreCode
                    CONTINUE
                END
                
                -- Get Store ID
                SELECT @StoreID = StoreID FROM StoreMaster WHERE StoreCode = @StoreCode
                
                IF @StoreID IS NULL
                BEGIN
                    SET @ErrorCount = @ErrorCount + 1
                    FETCH NEXT FROM serial_cursor INTO @SerialNumber, @ItemCode, @BatchNumber, 
                                                   @ManufacturingDate, @ExpiryDate, @PurchasePrice, @StoreCode
                    CONTINUE
                END
                
                -- Check if serial number already exists
                IF NOT EXISTS (SELECT 1 FROM SerialNumberMaster WHERE SerialNumber = @SerialNumber)
                BEGIN
                    INSERT INTO SerialNumberMaster (
                        SerialNumber, ItemID, ItemCode, ItemName, BatchNumber,
                        ManufacturingDate, ExpiryDate, PurchasePrice,
                        CurrentStoreID, CurrentStoreCode, CurrentStoreName,
                        SerialStatus, CreatedBy
                    )
                    SELECT 
                        @SerialNumber, I.ItemID, I.ItemCode, I.ItemName, @BatchNumber,
                        @ManufacturingDate, @ExpiryDate, @PurchasePrice,
                        @StoreID, @StoreCode, S.StoreName,
                        'Available', @CreatedBy
                    FROM ItemMaster I
                    CROSS JOIN StoreMaster S
                    WHERE I.ItemID = @ItemID AND S.StoreID = @StoreID
                    
                    SET @InsertedCount = @InsertedCount + 1
                END
                ELSE
                BEGIN
                    SET @ErrorCount = @ErrorCount + 1
                END
                
                FETCH NEXT FROM serial_cursor INTO @SerialNumber, @ItemCode, @BatchNumber, 
                                               @ManufacturingDate, @ExpiryDate, @PurchasePrice, @StoreCode
            END
            
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
            
        COMMIT TRANSACTION
        
        SELECT @InsertedCount AS InsertedCount, @ErrorCount AS ErrorCount,
               CAST(@InsertedCount AS NVARCHAR(10)) + ' serial numbers imported successfully. ' +
               CAST(@ErrorCount AS NVARCHAR(10)) + ' errors encountered.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'serial_cursor') >= 0
        BEGIN
            CLOSE serial_cursor
            DEALLOCATE serial_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- TRIGGER: Auto-update serial number status on item master update
-- =============================================
CREATE TRIGGER trg_SerialNumber_ItemMasterUpdate
ON ItemMaster
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    
    -- Update serial numbers when item code changes
    IF UPDATE(ItemCode)
    BEGIN
        UPDATE S
        SET ItemCode = I.ItemCode
        FROM SerialNumberMaster S
        INNER JOIN inserted I ON S.ItemID = I.ItemID
    END
    
    -- Update serial numbers when item name changes
    IF UPDATE(ItemName)
    BEGIN
        UPDATE S
        SET ItemName = I.ItemName
        FROM SerialNumberMaster S
        INNER JOIN inserted I ON S.ItemID = I.ItemID
    END
END
GO

PRINT 'Serial Number Tracking system implemented successfully!'