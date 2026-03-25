-- =============================================
-- ENHANCED SERIAL NUMBER TRACKING WITH MANUAL SERIALS
-- DESCRIPTION: Support for both system-generated and manual serial numbers
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- ENHANCE SERIAL NUMBER MASTER TABLE FOR MANUAL SERIALS
-- =============================================
ALTER TABLE [dbo].[SerialNumberMaster] ADD
    [SerialGenerationMethod] NVARCHAR(20) NOT NULL DEFAULT 'Auto', -- 'Auto', 'Manual', 'Import'
    [IsOwnedAsset] BIT NOT NULL DEFAULT 0, -- For company-owned assets like desktops, laptops
    [AssetType] NVARCHAR(50) NULL, -- 'Desktop', 'Laptop', 'Server', 'Printer', 'Scanner', 'Phone', 'Vehicle', 'Furniture', 'Equipment'
    [AssetModel] NVARCHAR(100) NULL,
    [AssetMake] NVARCHAR(100) NULL,
    [AssetSpecifications] NVARCHAR(MAX) NULL,
    [OwnershipStatus] NVARCHAR(50) NULL DEFAULT 'Owned', -- 'Owned', 'Leased', 'Rented', 'On Loan'
    [LeaseStartDate] DATE NULL,
    [LeaseEndDate] DATE NULL,
    [LeaseProvider] NVARCHAR(200) NULL,
    [LeaseAgreementNumber] NVARCHAR(100) NULL,
    
    -- IT Asset Specific Fields
    [MACAddress] NVARCHAR(50) NULL,
    [IPAddress] NVARCHAR(50) NULL,
    [ComputerName] NVARCHAR(100) NULL,
    [OperatingSystem] NVARCHAR(100) NULL,
    [Processor] NVARCHAR(200) NULL,
    [RAM] NVARCHAR(50) NULL,
    [HardDisk] NVARCHAR(100) NULL,
    [GraphicsCard] NVARCHAR(200) NULL,
    [MonitorDetails] NVARCHAR(500) NULL,
    
    -- Asset Management
    [AssetTag] NVARCHAR(50) NULL, -- Company asset tag number
    [POReference] NVARCHAR(100) NULL,
    [PurchaseOrderNumber] NVARCHAR(50) NULL,
    [InvoiceNumber] NVARCHAR(100) NULL,
    [InvoiceDate] DATE NULL,
    [VendorName] NVARCHAR(200) NULL,
    [Department] NVARCHAR(100) NULL,
    [CostCenter] NVARCHAR(50) NULL,
    
    -- Physical Location
    [PhysicalLocation] NVARCHAR(500) NULL, -- Building, Floor, Room, Desk
    [RackPosition] NVARCHAR(50) NULL,
    [SeatNumber] NVARCHAR(50) NULL,
    
    -- Maintenance
    [LastMaintenanceDate] DATE NULL,
    [NextMaintenanceDate] DATE NULL,
    [MaintenanceIntervalMonths] INT NULL,
    [ServiceProvider] NVARCHAR(200) NULL,
    [ServiceContractNumber] NVARCHAR(100) NULL,
    
    -- Additional Flags
    [IsActive] BIT NOT NULL DEFAULT 1,
    [IsAssigned] BIT NOT NULL DEFAULT 0,
    [IsUnderMaintenance] BIT NOT NULL DEFAULT 0,
    [IsInUse] BIT NOT NULL DEFAULT 0,
    
    -- User Defined Fields (Flexible)
    [CustomField1] NVARCHAR(200) NULL,
    [CustomField2] NVARCHAR(200) NULL,
    [CustomField3] NVARCHAR(200) NULL,
    [CustomField4] NVARCHAR(200) NULL,
    [CustomField5] NVARCHAR(200) NULL

GO

-- =============================================
-- CREATE ASSIGNMENT HISTORY TABLE
-- =============================================
CREATE TABLE [dbo].[AssetAssignmentHistory] (
    [AssignmentID] INT IDENTITY(1,1) NOT NULL,
    [SerialID] INT NOT NULL,
    [SerialNumber] NVARCHAR(100) NOT NULL,
    [ItemID] INT NOT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    
    [AssignmentType] NVARCHAR(50) NOT NULL, -- 'Issue', 'Transfer', 'Return'
    [AssignmentDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [AssignmentNumber] NVARCHAR(50) NOT NULL,
    [AssignedToType] NVARCHAR(50) NOT NULL, -- 'Employee', 'Department', 'Location', 'Project'
    
    [EmployeeID] INT NULL,
    [EmployeeCode] NVARCHAR(50) NULL,
    [EmployeeName] NVARCHAR(200) NULL,
    [Department] NVARCHAR(100) NULL,
    [Location] NVARCHAR(500) NULL,
    [ProjectCode] NVARCHAR(50) NULL,
    
    [Purpose] NVARCHAR(500) NULL,
    [ExpectedReturnDate] DATE NULL,
    [ActualReturnDate] DATE NULL,
    [ReturnCondition] NVARCHAR(50) NULL,
    [ReturnRemarks] NVARCHAR(MAX) NULL,
    
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_AssetAssignmentHistory PRIMARY KEY CLUSTERED (AssignmentID ASC),
    CONSTRAINT FK_AssetAssignmentHistory_SerialNumberMaster FOREIGN KEY (SerialID) 
        REFERENCES SerialNumberMaster(SerialID)
)

GO

-- =============================================
-- CREATE MAINTENANCE LOG TABLE
-- =============================================
CREATE TABLE [dbo].[AssetMaintenanceLog] (
    [MaintenanceID] INT IDENTITY(1,1) NOT NULL,
    [SerialID] INT NOT NULL,
    [SerialNumber] NVARCHAR(100) NOT NULL,
    [ItemID] INT NOT NULL,
    
    [MaintenanceType] NVARCHAR(50) NOT NULL, -- 'Preventive', 'Corrective', 'Emergency', 'Upgrade', 'Warranty'
    [MaintenanceDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [MaintenanceBy] NVARCHAR(100) NULL,
    [ServiceProvider] NVARCHAR(200) NULL,
    [ServiceCost] DECIMAL(18,2) NULL,
    [WorkOrderNumber] NVARCHAR(100) NULL,
    
    [Description] NVARCHAR(MAX) NULL,
    [IssuesFound] NVARCHAR(MAX) NULL,
    [ActionsTaken] NVARCHAR(MAX) NULL,
    [PartsReplaced] NVARCHAR(MAX) NULL,
    [PartsCost] DECIMAL(18,2) NULL,
    [LaborCost] DECIMAL(18,2) NULL,
    
    [NextMaintenanceDue] DATE NULL,
    [IsWarrantyClaim] BIT NOT NULL DEFAULT 0,
    [WarrantyClaimNumber] NVARCHAR(100) NULL,
    
    [Attachments] NVARCHAR(500) NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_AssetMaintenanceLog PRIMARY KEY CLUSTERED (MaintenanceID ASC),
    CONSTRAINT FK_AssetMaintenanceLog_SerialNumberMaster FOREIGN KEY (SerialID) 
        REFERENCES SerialNumberMaster(SerialID)
)

GO

-- =============================================
-- STORED PROCEDURE: Add Manual Serial Number (For Owned Assets)
-- =============================================
CREATE PROCEDURE [dbo].[sp_AddManualSerialNumber]
    @SerialNumber NVARCHAR(100),
    @ItemID INT,
    @BatchNumber NVARCHAR(100) = NULL,
    @IsOwnedAsset BIT = 1,
    @AssetType NVARCHAR(50) = NULL,
    @AssetModel NVARCHAR(100) = NULL,
    @AssetMake NVARCHAR(100) = NULL,
    @AssetSpecifications NVARCHAR(MAX) = NULL,
    @OwnershipStatus NVARCHAR(50) = 'Owned',
    @PurchasePrice DECIMAL(18,2) = NULL,
    @CurrentValue DECIMAL(18,2) = NULL,
    @PurchaseOrderNumber NVARCHAR(50) = NULL,
    @InvoiceNumber NVARCHAR(100) = NULL,
    @InvoiceDate DATE = NULL,
    @VendorName NVARCHAR(200) = NULL,
    @WarrantyStartDate DATE = NULL,
    @WarrantyEndDate DATE = NULL,
    @WarrantyPeriodMonths INT = NULL,
    @ManufacturingDate DATE = NULL,
    @ExpiryDate DATE = NULL,
    @AssetTag NVARCHAR(50) = NULL,
    @MACAddress NVARCHAR(50) = NULL,
    @ComputerName NVARCHAR(100) = NULL,
    @OperatingSystem NVARCHAR(100) = NULL,
    @Processor NVARCHAR(200) = NULL,
    @RAM NVARCHAR(50) = NULL,
    @HardDisk NVARCHAR(100) = NULL,
    @StoreID INT = NULL,
    @PhysicalLocation NVARCHAR(500) = NULL,
    @Department NVARCHAR(100) = NULL,
    @CostCenter NVARCHAR(50) = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @CreatedBy NVARCHAR(100),
    @SerialID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if serial number already exists
            IF EXISTS (SELECT 1 FROM SerialNumberMaster WHERE SerialNumber = @SerialNumber)
            BEGIN
                RAISERROR('Serial number already exists.', 16, 1)
                RETURN
            END
            
            -- Get Item details
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @ItemName NVARCHAR(200)
            
            SELECT 
                @ItemCode = ItemCode,
                @ItemName = ItemName
            FROM ItemMaster
            WHERE ItemID = @ItemID
            
            IF @ItemCode IS NULL
            BEGIN
                RAISERROR('Item not found.', 16, 1)
                RETURN
            END
            
            -- Get Store details if provided
            DECLARE @StoreCode NVARCHAR(50)
            DECLARE @StoreName NVARCHAR(200)
            
            IF @StoreID IS NOT NULL
            BEGIN
                SELECT 
                    @StoreCode = StoreCode,
                    @StoreName = StoreName
                FROM StoreMaster
                WHERE StoreID = @StoreID
            END
            
            -- Calculate warranty end date if period provided
            IF @WarrantyPeriodMonths IS NOT NULL AND @WarrantyStartDate IS NOT NULL
                SET @WarrantyEndDate = DATEADD(MONTH, @WarrantyPeriodMonths, @WarrantyStartDate)
            
            -- Insert manual serial number
            INSERT INTO SerialNumberMaster (
                SerialNumber, ItemID, ItemCode, ItemName, BatchNumber,
                SerialGenerationMethod, IsOwnedAsset, AssetType, AssetModel,
                AssetMake, AssetSpecifications, OwnershipStatus,
                PurchasePrice, CurrentValue, PurchaseOrderNumber, InvoiceNumber,
                InvoiceDate, VendorName, WarrantyStartDate, WarrantyEndDate,
                WarrantyPeriodMonths, ManufacturingDate, ExpiryDate, AssetTag,
                MACAddress, ComputerName, OperatingSystem, Processor, RAM, HardDisk,
                CurrentStoreID, CurrentStoreCode, CurrentStoreName, PhysicalLocation,
                Department, CostCenter, SerialStatus, IsAvailable, Remarks, CreatedBy
            )
            VALUES (
                @SerialNumber, @ItemID, @ItemCode, @ItemName, @BatchNumber,
                'Manual', @IsOwnedAsset, @AssetType, @AssetModel,
                @AssetMake, @AssetSpecifications, @OwnershipStatus,
                @PurchasePrice, @CurrentValue, @PurchaseOrderNumber, @InvoiceNumber,
                @InvoiceDate, @VendorName, @WarrantyStartDate, @WarrantyEndDate,
                @WarrantyPeriodMonths, @ManufacturingDate, @ExpiryDate, @AssetTag,
                @MACAddress, @ComputerName, @OperatingSystem, @Processor, @RAM, @HardDisk,
                @StoreID, @StoreCode, @StoreName, @PhysicalLocation,
                @Department, @CostCenter, 'Available', 1, @Remarks, @CreatedBy
            )
            
            SET @SerialID = SCOPE_IDENTITY()
            
            -- Add to history
            INSERT INTO SerialNumberHistory (
                SerialID, SerialNumber, ItemID, ItemCode,
                ActionType, ActionBy, NewStatus,
                DestinationStoreID, DestinationStoreCode,
                Remarks, ReferenceType
            )
            VALUES (
                @SerialID, @SerialNumber, @ItemID, @ItemCode,
                'Manual Add', @CreatedBy, 'Available',
                @StoreID, @StoreCode,
                'Manual serial number added. Asset Type: ' + ISNULL(@AssetType, 'N/A') + 
                ', Model: ' + ISNULL(@AssetModel, 'N/A') + 
                ', Make: ' + ISNULL(@AssetMake, 'N/A'),
                'System'
            )
            
        COMMIT TRANSACTION
        
        SELECT @SerialID AS SerialID, 'Manual serial number added successfully.' AS Message
        
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
-- STORED PROCEDURE: Assign Asset to Employee
-- =============================================
CREATE PROCEDURE [dbo].[sp_AssignAssetToEmployee]
    @SerialNumber NVARCHAR(100),
    @EmployeeID INT,
    @AssignmentType NVARCHAR(50) = 'Issue',
    @Purpose NVARCHAR(500) = NULL,
    @ExpectedReturnDate DATE = NULL,
    @PhysicalLocation NVARCHAR(500) = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @AssignedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Get serial details
            DECLARE @SerialID INT
            DECLARE @ItemID INT
            DECLARE @CurrentStatus NVARCHAR(50)
            
            SELECT 
                @SerialID = SerialID,
                @ItemID = ItemID,
                @CurrentStatus = SerialStatus
            FROM SerialNumberMaster
            WHERE SerialNumber = @SerialNumber
            
            IF @SerialID IS NULL
            BEGIN
                RAISERROR('Serial number not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus != 'Available'
            BEGIN
                RAISERROR('Asset is not available for assignment. Current status: %s', 16, 1, @CurrentStatus)
                RETURN
            END
            
            -- Get Employee details
            DECLARE @EmployeeCode NVARCHAR(50)
            DECLARE @EmployeeName NVARCHAR(200)
            DECLARE @Department NVARCHAR(100)
            
            SELECT 
                @EmployeeCode = EmployeeCode,
                @EmployeeName = EmployeeName,
                @Department = Department
            FROM EmployeeMaster
            WHERE EmployeeID = @EmployeeID
            
            -- Generate assignment number
            DECLARE @AssignmentNumber NVARCHAR(50)
            DECLARE @DateStr NVARCHAR(8) = FORMAT(GETDATE(), 'yyyyMMdd')
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(AssignmentNumber, 4) AS INT)), 0) + 1
            FROM AssetAssignmentHistory
            WHERE AssignmentNumber LIKE 'ASS-' + @DateStr + '-%'
            
            SET @AssignmentNumber = 'ASS-' + @DateStr + '-' + RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Update serial number master
            UPDATE SerialNumberMaster
            SET SerialStatus = 'Issued',
                IsAvailable = 0,
                IsAssigned = 1,
                IsIssued = 1,
                CurrentEmployeeID = @EmployeeID,
                CurrentEmployeeCode = @EmployeeCode,
                CurrentEmployeeName = @EmployeeName,
                Department = @Department,
                PhysicalLocation = ISNULL(@PhysicalLocation, PhysicalLocation),
                LastTransactionType = 'Assignment',
                LastTransactionNumber = @AssignmentNumber,
                LastTransactionDate = GETDATE(),
                ModifiedDate = GETDATE(),
                ModifiedBy = @AssignedBy
            WHERE SerialID = @SerialID
            
            -- Record assignment history
            INSERT INTO AssetAssignmentHistory (
                SerialID, SerialNumber, ItemID, ItemCode, ItemName,
                AssignmentType, AssignmentDate, AssignmentNumber,
                AssignedToType, EmployeeID, EmployeeCode, EmployeeName, Department,
                Purpose, ExpectedReturnDate, CreatedBy
            )
            SELECT 
                @SerialID, @SerialNumber, I.ItemID, I.ItemCode, I.ItemName,
                @AssignmentType, GETDATE(), @AssignmentNumber,
                'Employee', @EmployeeID, @EmployeeCode, @EmployeeName, @Department,
                @Purpose, @ExpectedReturnDate, @AssignedBy
            FROM ItemMaster I
            WHERE I.ItemID = @ItemID
            
            -- Add to serial history
            INSERT INTO SerialNumberHistory (
                SerialID, SerialNumber, ItemID, ItemCode,
                ActionType, ActionBy, PreviousStatus, NewStatus,
                EmployeeID, EmployeeCode,
                ReferenceType, ReferenceID, ReferenceNumber, Remarks
            )
            VALUES (
                @SerialID, @SerialNumber, @ItemID, (SELECT ItemCode FROM ItemMaster WHERE ItemID = @ItemID),
                'Assignment', @AssignedBy, 'Available', 'Issued',
                @EmployeeID, @EmployeeCode,
                'Assignment', @SerialID, @AssignmentNumber, @Remarks
            )
            
        COMMIT TRANSACTION
        
        SELECT 'Asset assigned to employee successfully. Assignment Number: ' + @AssignmentNumber AS Message
        
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
-- STORED PROCEDURE: Return Asset from Employee
-- =============================================
CREATE PROCEDURE [dbo].[sp_ReturnAssetFromEmployee]
    @SerialNumber NVARCHAR(100),
    @ReturnCondition NVARCHAR(50) = 'Good', -- 'Good', 'Damaged', 'Defective', 'Under Repair'
    @ReturnRemarks NVARCHAR(MAX) = NULL,
    @StoreID INT = NULL,
    @ReceivedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Get serial details
            DECLARE @SerialID INT
            DECLARE @ItemID INT
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @CurrentEmployeeID INT
            DECLARE @AssignmentID INT
            
            SELECT 
                @SerialID = SerialID,
                @ItemID = ItemID,
                @CurrentStatus = SerialStatus,
                @CurrentEmployeeID = CurrentEmployeeID
            FROM SerialNumberMaster
            WHERE SerialNumber = @SerialNumber
            
            IF @SerialID IS NULL
            BEGIN
                RAISERROR('Serial number not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus != 'Issued'
            BEGIN
                RAISERROR('Asset is not in issued status. Current status: %s', 16, 1, @CurrentStatus)
                RETURN
            END
            
            -- Get the current active assignment
            SELECT TOP 1 @AssignmentID = AssignmentID
            FROM AssetAssignmentHistory
            WHERE SerialID = @SerialID 
                AND IsActive = 1 
                AND ActualReturnDate IS NULL
            ORDER BY AssignmentDate DESC
            
            -- Get Store details if provided
            DECLARE @StoreCode NVARCHAR(50)
            DECLARE @StoreName NVARCHAR(200)
            
            IF @StoreID IS NOT NULL
            BEGIN
                SELECT 
                    @StoreCode = StoreCode,
                    @StoreName = StoreName
                FROM StoreMaster
                WHERE StoreID = @StoreID
            END
            
            -- Update serial number status based on condition
            DECLARE @NewStatus NVARCHAR(50)
            SET @NewStatus = CASE 
                WHEN @ReturnCondition = 'Good' THEN 'Available'
                WHEN @ReturnCondition = 'Damaged' THEN 'Damaged'
                WHEN @ReturnCondition = 'Defective' THEN 'Under Repair'
                ELSE 'Available'
            END
            
            UPDATE SerialNumberMaster
            SET SerialStatus = @NewStatus,
                IsAvailable = CASE WHEN @NewStatus = 'Available' THEN 1 ELSE 0 END,
                IsIssued = 0,
                IsAssigned = 0,
                CurrentEmployeeID = NULL,
                CurrentEmployeeCode = NULL,
                CurrentEmployeeName = NULL,
                CurrentStoreID = @StoreID,
                CurrentStoreCode = @StoreCode,
                CurrentStoreName = @StoreName,
                LastTransactionType = 'Return',
                LastTransactionDate = GETDATE(),
                ModifiedDate = GETDATE(),
                ModifiedBy = @ReceivedBy
            WHERE SerialID = @SerialID
            
            -- Update assignment history
            UPDATE AssetAssignmentHistory
            SET ActualReturnDate = GETDATE(),
                ReturnCondition = @ReturnCondition,
                ReturnRemarks = @ReturnRemarks,
                IsActive = 0
            WHERE AssignmentID = @AssignmentID
            
            -- Add to serial history
            INSERT INTO SerialNumberHistory (
                SerialID, SerialNumber, ItemID, ItemCode,
                ActionType, ActionBy, PreviousStatus, NewStatus,
                EmployeeID, EmployeeCode,
                DestinationStoreID, DestinationStoreCode,
                Remarks
            )
            SELECT 
                @SerialID, @SerialNumber, I.ItemID, I.ItemCode,
                'Return', @ReceivedBy, 'Issued', @NewStatus,
                @CurrentEmployeeID, E.EmployeeCode,
                @StoreID, @StoreCode,
                'Return Condition: ' + @ReturnCondition + '. ' + ISNULL(@ReturnRemarks, '')
            FROM ItemMaster I
            LEFT JOIN EmployeeMaster E ON E.EmployeeID = @CurrentEmployeeID
            WHERE I.ItemID = @ItemID
            
        COMMIT TRANSACTION
        
        SELECT 'Asset returned successfully.' AS Message
        
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
-- STORED PROCEDURE: Log Asset Maintenance
-- =============================================
CREATE PROCEDURE [dbo].[sp_LogAssetMaintenance]
    @SerialNumber NVARCHAR(100),
    @MaintenanceType NVARCHAR(50),
    @MaintenanceBy NVARCHAR(100) = NULL,
    @ServiceProvider NVARCHAR(200) = NULL,
    @ServiceCost DECIMAL(18,2) = NULL,
    @WorkOrderNumber NVARCHAR(100) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @IssuesFound NVARCHAR(MAX) = NULL,
    @ActionsTaken NVARCHAR(MAX) = NULL,
    @PartsReplaced NVARCHAR(MAX) = NULL,
    @PartsCost DECIMAL(18,2) = NULL,
    @LaborCost DECIMAL(18,2) = NULL,
    @NextMaintenanceDue DATE = NULL,
    @IsWarrantyClaim BIT = 0,
    @WarrantyClaimNumber NVARCHAR(100) = NULL,
    @Attachments NVARCHAR(500) = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @CreatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Get serial details
            DECLARE @SerialID INT
            DECLARE @ItemID INT
            
            SELECT 
                @SerialID = SerialID,
                @ItemID = ItemID
            FROM SerialNumberMaster
            WHERE SerialNumber = @SerialNumber
            
            IF @SerialID IS NULL
            BEGIN
                RAISERROR('Serial number not found.', 16, 1)
                RETURN
            END
            
            -- Insert maintenance record
            INSERT INTO AssetMaintenanceLog (
                SerialID, SerialNumber, ItemID,
                MaintenanceType, MaintenanceDate, MaintenanceBy,
                ServiceProvider, ServiceCost, WorkOrderNumber,
                Description, IssuesFound, ActionsTaken,
                PartsReplaced, PartsCost, LaborCost,
                NextMaintenanceDue, IsWarrantyClaim, WarrantyClaimNumber,
                Attachments, Remarks, CreatedBy
            )
            VALUES (
                @SerialID, @SerialNumber, @ItemID,
                @MaintenanceType, GETDATE(), @MaintenanceBy,
                @ServiceProvider, @ServiceCost, @WorkOrderNumber,
                @Description, @IssuesFound, @ActionsTaken,
                @PartsReplaced, @PartsCost, @LaborCost,
                @NextMaintenanceDue, @IsWarrantyClaim, @WarrantyClaimNumber,
                @Attachments, @Remarks, @CreatedBy
            )
            
            -- Update serial number master with maintenance info
            UPDATE SerialNumberMaster
            SET LastMaintenanceDate = GETDATE(),
                NextMaintenanceDate = @NextMaintenanceDue,
                MaintenanceIntervalMonths = CASE 
                    WHEN @NextMaintenanceDue IS NOT NULL 
                    THEN DATEDIFF(MONTH, GETDATE(), @NextMaintenanceDue) 
                    ELSE MaintenanceIntervalMonths 
                END,
                ServiceProvider = @ServiceProvider,
                ModifiedDate = GETDATE(),
                ModifiedBy = @CreatedBy
            WHERE SerialID = @SerialID
            
            -- Add to history
            INSERT INTO SerialNumberHistory (
                SerialID, SerialNumber, ItemID, ItemCode,
                ActionType, ActionBy, NewStatus,
                Remarks
            )
            SELECT 
                @SerialID, @SerialNumber, I.ItemID, I.ItemCode,
                'Maintenance', @CreatedBy, SerialStatus,
                'Maintenance performed. Type: ' + @MaintenanceType + 
                '. Cost: ' + ISNULL(CAST(@ServiceCost AS NVARCHAR), '0') +
                '. Next due: ' + ISNULL(CONVERT(NVARCHAR, @NextMaintenanceDue), 'Not Set')
            FROM ItemMaster I
            CROSS JOIN SerialNumberMaster S
            WHERE I.ItemID = @ItemID AND S.SerialID = @SerialID
            
        COMMIT TRANSACTION
        
        SELECT 'Maintenance logged successfully.' AS Message
        
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
-- STORED PROCEDURE: Get Asset Details with Full History
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAssetDetails]
    @SerialNumber NVARCHAR(100) = NULL,
    @AssetTag NVARCHAR(50) = NULL,
    @AssetType NVARCHAR(50) = NULL,
    @EmployeeID INT = NULL,
    @Department NVARCHAR(100) = NULL,
    @SerialStatus NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        S.SerialID,
        S.SerialNumber,
        S.ItemCode,
        S.ItemName,
        S.BatchNumber,
        S.SerialStatus,
        S.SerialGenerationMethod,
        S.IsOwnedAsset,
        S.AssetType,
        S.AssetModel,
        S.AssetMake,
        S.AssetSpecifications,
        S.OwnershipStatus,
        S.AssetTag,
        
        -- IT Specs
        S.MACAddress,
        S.ComputerName,
        S.OperatingSystem,
        S.Processor,
        S.RAM,
        S.HardDisk,
        
        -- Location
        S.CurrentStoreCode AS StoreCode,
        S.CurrentStoreName AS StoreName,
        S.PhysicalLocation,
        S.Department AS AssetDepartment,
        S.CostCenter,
        
        -- Assignment
        S.CurrentEmployeeCode AS AssignedToCode,
        S.CurrentEmployeeName AS AssignedToName,
        
        -- Financial
        S.PurchasePrice,
        S.CurrentValue,
        S.PurchaseOrderNumber,
        S.InvoiceNumber,
        S.InvoiceDate,
        S.VendorName,
        
        -- Warranty
        S.WarrantyStartDate,
        S.WarrantyEndDate,
        S.WarrantyPeriodMonths,
        DATEDIFF(DAY, GETDATE(), S.WarrantyEndDate) AS WarrantyDaysRemaining,
        
        -- Expiry
        S.ManufacturingDate,
        S.ExpiryDate,
        DATEDIFF(DAY, GETDATE(), S.ExpiryDate) AS DaysToExpiry,
        
        -- Maintenance
        S.LastMaintenanceDate,
        S.NextMaintenanceDate,
        S.ServiceProvider,
        DATEDIFF(DAY, GETDATE(), S.NextMaintenanceDate) AS DaysToNextMaintenance,
        
        -- Status
        S.IsAvailable,
        S.IsAssigned,
        S.IsUnderMaintenance,
        S.IsActive,
        
        -- Last Transaction
        S.LastTransactionType,
        S.LastTransactionNumber,
        S.LastTransactionDate,
        
        -- Audit
        S.CreatedDate,
        S.CreatedBy,
        S.ModifiedDate,
        S.ModifiedBy,
        S.Remarks
        
    FROM SerialNumberMaster S
    WHERE (@SerialNumber IS NULL OR S.SerialNumber = @SerialNumber)
        AND (@AssetTag IS NULL OR S.AssetTag = @AssetTag)
        AND (@AssetType IS NULL OR S.AssetType = @AssetType)
        AND (@EmployeeID IS NULL OR S.CurrentEmployeeID = @EmployeeID)
        AND (@Department IS NULL OR S.Department = @Department)
        AND (@SerialStatus IS NULL OR S.SerialStatus = @SerialStatus)
    ORDER BY S.SerialNumber
END
GO

-- =============================================
-- STORED PROCEDURE: Get Asset Assignment History
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAssetAssignmentHistory]
    @SerialNumber NVARCHAR(100) = NULL,
    @EmployeeID INT = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        A.AssignmentID,
        A.SerialNumber,
        A.ItemCode,
        A.ItemName,
        A.AssignmentType,
        A.AssignmentDate,
        A.AssignmentNumber,
        A.AssignedToType,
        A.EmployeeCode,
        A.EmployeeName,
        A.Department,
        A.Location,
        A.Purpose,
        A.ExpectedReturnDate,
        A.ActualReturnDate,
        A.ReturnCondition,
        A.ReturnRemarks,
        DATEDIFF(DAY, A.AssignmentDate, ISNULL(A.ActualReturnDate, GETDATE())) AS DaysAssigned,
        CASE 
            WHEN A.ActualReturnDate IS NULL AND A.ExpectedReturnDate < GETDATE() THEN 'Overdue'
            WHEN A.ActualReturnDate IS NULL THEN 'Active'
            ELSE 'Returned'
        END AS AssignmentStatus,
        A.CreatedBy,
        A.CreatedDate
    FROM AssetAssignmentHistory A
    WHERE (@SerialNumber IS NULL OR A.SerialNumber = @SerialNumber)
        AND (@EmployeeID IS NULL OR A.EmployeeID = @EmployeeID)
        AND (@FromDate IS NULL OR CAST(A.AssignmentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(A.AssignmentDate AS DATE) <= @ToDate)
    ORDER BY A.AssignmentDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Asset Maintenance History
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAssetMaintenanceHistory]
    @SerialNumber NVARCHAR(100) = NULL,
    @MaintenanceType NVARCHAR(50) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        M.MaintenanceID,
        M.SerialNumber,
        M.ItemCode,
        M.ItemName,
        M.MaintenanceType,
        M.MaintenanceDate,
        M.MaintenanceBy,
        M.ServiceProvider,
        M.ServiceCost,
        M.WorkOrderNumber,
        M.Description,
        M.IssuesFound,
        M.ActionsTaken,
        M.PartsReplaced,
        M.PartsCost,
        M.LaborCost,
        M.PartsCost + ISNULL(M.LaborCost, 0) AS TotalCost,
        M.NextMaintenanceDue,
        M.IsWarrantyClaim,
        M.WarrantyClaimNumber,
        M.Remarks,
        M.CreatedBy,
        M.CreatedDate
    FROM AssetMaintenanceLog M
    WHERE (@SerialNumber IS NULL OR M.SerialNumber = @SerialNumber)
        AND (@MaintenanceType IS NULL OR M.MaintenanceType = @MaintenanceType)
        AND (@FromDate IS NULL OR CAST(M.MaintenanceDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(M.MaintenanceDate AS DATE) <= @ToDate)
    ORDER BY M.MaintenanceDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Asset Summary Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAssetSummaryReport]
    @ReportType NVARCHAR(50), -- 'ByType', 'ByStatus', 'ByDepartment', 'WarrantyExpiry', 'MaintenanceDue'
    @DateRange INT = 30
AS
BEGIN
    SET NOCOUNT ON
    
    IF @ReportType = 'ByType'
    BEGIN
        SELECT 
            AssetType,
            COUNT(*) AS TotalAssets,
            SUM(CASE WHEN SerialStatus = 'Available' THEN 1 ELSE 0 END) AS Available,
            SUM(CASE WHEN SerialStatus = 'Issued' THEN 1 ELSE 0 END) AS Issued,
            SUM(CASE WHEN SerialStatus = 'Under Repair' THEN 1 ELSE 0 END) AS UnderRepair,
            SUM(CASE WHEN SerialStatus = 'Damaged' THEN 1 ELSE 0 END) AS Damaged,
            SUM(CASE WHEN WarrantyEndDate >= GETDATE() THEN 1 ELSE 0 END) AS UnderWarranty,
            SUM(CASE WHEN NextMaintenanceDate <= DATEADD(DAY, @DateRange, GETDATE()) THEN 1 ELSE 0 END) AS MaintenanceDue
        FROM SerialNumberMaster
        WHERE IsOwnedAsset = 1
        GROUP BY AssetType
        ORDER BY AssetType
    END
    
    ELSE IF @ReportType = 'ByStatus'
    BEGIN
        SELECT 
            SerialStatus,
            COUNT(*) AS TotalAssets,
            SUM(CASE WHEN IsOwnedAsset = 1 THEN 1 ELSE 0 END) AS OwnedAssets,
            AVG(PurchasePrice) AS AvgPurchasePrice,
            SUM(PurchasePrice) AS TotalValue
        FROM SerialNumberMaster
        GROUP BY SerialStatus
        ORDER BY SerialStatus
    END
    
    ELSE IF @ReportType = 'ByDepartment'
    BEGIN
        SELECT 
            ISNULL(Department, 'Unassigned') AS Department,
            COUNT(*) AS TotalAssets,
            SUM(CASE WHEN SerialStatus = 'Issued' THEN 1 ELSE 0 END) AS CurrentlyIssued,
            SUM(CASE WHEN SerialStatus = 'Available' THEN 1 ELSE 0 END) AS Available,
            SUM(CASE WHEN WarrantyEndDate >= GETDATE() THEN 1 ELSE 0 END) AS UnderWarranty,
            SUM(PurchasePrice) AS TotalValue
        FROM SerialNumberMaster
        WHERE IsOwnedAsset = 1
        GROUP BY Department
        ORDER BY TotalAssets DESC
    END
    
    ELSE IF @ReportType = 'WarrantyExpiry'
    BEGIN
        SELECT 
            SerialNumber,
            ItemName,
            AssetType,
            AssetModel,
            WarrantyStartDate,
            WarrantyEndDate,
            DATEDIFF(DAY, GETDATE(), WarrantyEndDate) AS DaysRemaining,
            CurrentEmployeeName AS AssignedTo,
            Department
        FROM SerialNumberMaster
        WHERE IsOwnedAsset = 1
            AND WarrantyEndDate IS NOT NULL
            AND WarrantyEndDate >= GETDATE()
            AND DATEDIFF(DAY, GETDATE(), WarrantyEndDate) <= @DateRange
        ORDER BY DaysRemaining ASC
    END
    
    ELSE IF @ReportType = 'MaintenanceDue'
    BEGIN
        SELECT 
            SerialNumber,
            ItemName,
            AssetType,
            AssetModel,
            LastMaintenanceDate,
            NextMaintenanceDate,
            DATEDIFF(DAY, GETDATE(), NextMaintenanceDate) AS DaysToMaintenance,
            ServiceProvider,
            CurrentEmployeeName AS AssignedTo,
            Department
        FROM SerialNumberMaster
        WHERE IsOwnedAsset = 1
            AND NextMaintenanceDate IS NOT NULL
            AND NextMaintenanceDate <= DATEADD(DAY, @DateRange, GETDATE())
        ORDER BY DaysToMaintenance ASC
    END
END
GO

-- =============================================
-- STORED PROCEDURE: Bulk Import Manual Assets
-- =============================================
CREATE PROCEDURE [dbo].[sp_BulkImportManualAssets]
    @Assets XML,
    @CreatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @InsertedCount INT = 0
            DECLARE @ErrorCount INT = 0
            
            -- Process each asset from XML
            DECLARE @SerialNumber NVARCHAR(100)
            DECLARE @ItemCode NVARCHAR(50)
            DECLARE @AssetType NVARCHAR(50)
            DECLARE @AssetModel NVARCHAR(100)
            DECLARE @AssetMake NVARCHAR(100)
            DECLARE @AssetTag NVARCHAR(50)
            DECLARE @MACAddress NVARCHAR(50)
            DECLARE @ComputerName NVARCHAR(100)
            DECLARE @PurchasePrice DECIMAL(18,2)
            DECLARE @WarrantyEndDate DATE
            DECLARE @StoreCode NVARCHAR(50)
            DECLARE @Department NVARCHAR(100)
            
            DECLARE asset_cursor CURSOR FOR
            SELECT 
                X.value('@SerialNumber', 'NVARCHAR(100)'),
                X.value('@ItemCode', 'NVARCHAR(50)'),
                X.value('@AssetType', 'NVARCHAR(50)'),
                X.value('@AssetModel', 'NVARCHAR(100)'),
                X.value('@AssetMake', 'NVARCHAR(100)'),
                X.value('@AssetTag', 'NVARCHAR(50)'),
                X.value('@MACAddress', 'NVARCHAR(50)'),
                X.value('@ComputerName', 'NVARCHAR(100)'),
                X.value('@PurchasePrice', 'DECIMAL(18,2)'),
                X.value('@WarrantyEndDate', 'DATE'),
                X.value('@StoreCode', 'NVARCHAR(50)'),
                X.value('@Department', 'NVARCHAR(100)')
            FROM @Assets.nodes('/Assets/Asset') AS T(X)
            
            OPEN asset_cursor
            FETCH NEXT FROM asset_cursor INTO @SerialNumber, @ItemCode, @AssetType, @AssetModel,
                                           @AssetMake, @AssetTag, @MACAddress, @ComputerName,
                                           @PurchasePrice, @WarrantyEndDate, @StoreCode, @Department
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get Item ID
                DECLARE @ItemID INT
                SELECT @ItemID = ItemID FROM ItemMaster WHERE ItemCode = @ItemCode
                
                IF @ItemID IS NULL
                BEGIN
                    SET @ErrorCount = @ErrorCount + 1
                    FETCH NEXT FROM asset_cursor INTO @SerialNumber, @ItemCode, @AssetType, @AssetModel,
                                                   @AssetMake, @AssetTag, @MACAddress, @ComputerName,
                                                   @PurchasePrice, @WarrantyEndDate, @StoreCode, @Department
                    CONTINUE
                END
                
                -- Get Store ID
                DECLARE @StoreID INT
                SELECT @StoreID = StoreID FROM StoreMaster WHERE StoreCode = @StoreCode
                
                -- Add the asset
                DECLARE @NewSerialID INT
                EXEC sp_AddManualSerialNumber
                    @SerialNumber = @SerialNumber,
                    @ItemID = @ItemID,
                    @IsOwnedAsset = 1,
                    @AssetType = @AssetType,
                    @AssetModel = @AssetModel,
                    @AssetMake = @AssetMake,
                    @PurchasePrice = @PurchasePrice,
                    @WarrantyEndDate = @WarrantyEndDate,
                    @AssetTag = @AssetTag,
                    @MACAddress = @MACAddress,
                    @ComputerName = @ComputerName,
                    @StoreID = @StoreID,
                    @Department = @Department,
                    @CreatedBy = @CreatedBy,
                    @SerialID = @NewSerialID OUTPUT
                
                IF @NewSerialID IS NOT NULL
                    SET @InsertedCount = @InsertedCount + 1
                ELSE
                    SET @ErrorCount = @ErrorCount + 1
                
                FETCH NEXT FROM asset_cursor INTO @SerialNumber, @ItemCode, @AssetType, @AssetModel,
                                               @AssetMake, @AssetTag, @MACAddress, @ComputerName,
                                               @PurchasePrice, @WarrantyEndDate, @StoreCode, @Department
            END
            
            CLOSE asset_cursor
            DEALLOCATE asset_cursor
            
        COMMIT TRANSACTION
        
        SELECT @InsertedCount AS InsertedCount, @ErrorCount AS ErrorCount,
               CAST(@InsertedCount AS NVARCHAR(10)) + ' assets imported successfully. ' +
               CAST(@ErrorCount AS NVARCHAR(10)) + ' errors encountered.' AS Message
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        IF CURSOR_STATUS('global', 'asset_cursor') >= 0
        BEGIN
            CLOSE asset_cursor
            DEALLOCATE asset_cursor
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_AssetTag ON SerialNumberMaster(AssetTag)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_AssetType ON SerialNumberMaster(AssetType)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_IsOwnedAsset ON SerialNumberMaster(IsOwnedAsset)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_MACAddress ON SerialNumberMaster(MACAddress)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_ComputerName ON SerialNumberMaster(ComputerName)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_Department ON SerialNumberMaster(Department)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_WarrantyEndDate ON SerialNumberMaster(WarrantyEndDate)
CREATE NONCLUSTERED INDEX IX_SerialNumberMaster_NextMaintenanceDate ON SerialNumberMaster(NextMaintenanceDate)

CREATE NONCLUSTERED INDEX IX_AssetAssignmentHistory_EmployeeID ON AssetAssignmentHistory(EmployeeID)
CREATE NONCLUSTERED INDEX IX_AssetAssignmentHistory_SerialID ON AssetAssignmentHistory(SerialID)
CREATE NONCLUSTERED INDEX IX_AssetAssignmentHistory_AssignmentDate ON AssetAssignmentHistory(AssignmentDate)

CREATE NONCLUSTERED INDEX IX_AssetMaintenanceLog_SerialID ON AssetMaintenanceLog(SerialID)
CREATE NONCLUSTERED INDEX IX_AssetMaintenanceLog_MaintenanceDate ON AssetMaintenanceLog(MaintenanceDate)

GO

PRINT 'Manual Serial Number and Asset Management system implemented successfully!'