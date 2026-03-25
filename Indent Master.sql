-- =============================================
-- DATABASE: Indent Management System
-- DESCRIPTION: Indent (Purchase Requisition) tables and stored procedures with approval workflow
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- CREATE INDENT MASTER TABLE
-- =============================================
CREATE TABLE [dbo].[IndentMaster] (
    -- Primary Key
    [IndentID] INT IDENTITY(1,1) NOT NULL,
    [IndentNumber] NVARCHAR(50) NOT NULL,
    [IndentType] NVARCHAR(50) NOT NULL, -- 'Material', 'Service', 'Capital Goods'
    [IndentDate] DATE NOT NULL DEFAULT GETDATE(),
    [RequiredDate] DATE NOT NULL,
    
    -- Department and Requester Information
    [DepartmentID] INT NULL,
    [DepartmentName] NVARCHAR(100) NULL,
    [RequestedBy] NVARCHAR(100) NOT NULL,
    [RequestedByID] INT NULL,
    [RequestedByRole] NVARCHAR(50) NULL,
    
    -- Priority and Urgency
    [Priority] NVARCHAR(20) NOT NULL DEFAULT 'Normal', -- 'Urgent', 'High', 'Normal', 'Low'
    [UrgencyReason] NVARCHAR(500) NULL,
    
    -- Status and Workflow
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Submitted', 'Pending Approval', 'Approved', 'Rejected', 'Cancelled', 'Converted to PO'
    [ApprovalStatus] NVARCHAR(50) NULL, -- 'Pending Level 1', 'Pending Level 2', 'Pending Level 3', 'Fully Approved'
    [CurrentApprovalLevel] INT NULL DEFAULT 1,
    [WorkflowID] INT NULL,
    
    -- Financial Information
    [EstimatedAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [ApprovedAmount] DECIMAL(18,2) NULL,
    [Currency] NVARCHAR(3) NULL DEFAULT 'USD',
    [BudgetCode] NVARCHAR(50) NULL,
    [CostCenter] NVARCHAR(50) NULL,
    
    -- Justification and Details
    [Justification] NVARCHAR(MAX) NULL,
    [SpecialInstructions] NVARCHAR(MAX) NULL,
    [DeliveryLocation] NVARCHAR(500) NULL,
    [DeliveryTerms] NVARCHAR(500) NULL,
    
    -- Attachments and References
    [Attachments] NVARCHAR(500) NULL,
    [ReferenceNumber] NVARCHAR(100) NULL,
    [ReferenceNotes] NVARCHAR(500) NULL,
    
    -- Dates
    [SubmissionDate] DATETIME NULL,
    [ApprovalDate] DATETIME NULL,
    [CompletionDate] DATETIME NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Audit
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    
    -- Constraints
    CONSTRAINT PK_IndentMaster PRIMARY KEY CLUSTERED (IndentID ASC),
    CONSTRAINT UQ_IndentMaster_IndentNumber UNIQUE NONCLUSTERED (IndentNumber ASC)
)

GO

-- Create indexes for better performance
CREATE NONCLUSTERED INDEX IX_IndentMaster_IndentNumber ON IndentMaster(IndentNumber)
CREATE NONCLUSTERED INDEX IX_IndentMaster_Status ON IndentMaster(Status)
CREATE NONCLUSTERED INDEX IX_IndentMaster_DepartmentID ON IndentMaster(DepartmentID)
CREATE NONCLUSTERED INDEX IX_IndentMaster_RequestedBy ON IndentMaster(RequestedBy)
CREATE NONCLUSTERED INDEX IX_IndentMaster_RequiredDate ON IndentMaster(RequiredDate)
CREATE NONCLUSTERED INDEX IX_IndentMaster_IndentDate ON IndentMaster(IndentDate)
CREATE NONCLUSTERED INDEX IX_IndentMaster_Priority ON IndentMaster(Priority)

GO

-- =============================================
-- CREATE INDENT DETAILS TABLE (Line Items)
-- =============================================
CREATE TABLE [dbo].[IndentDetails] (
    -- Primary Key
    [IndentDetailID] INT IDENTITY(1,1) NOT NULL,
    [IndentID] INT NOT NULL,
    [LineNumber] INT NOT NULL,
    
    -- Item Information
    [ItemID] INT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    
    -- Quantity and Unit
    [Quantity] DECIMAL(18,3) NOT NULL,
    [UnitOfMeasure] NVARCHAR(20) NOT NULL,
    [ReceivedQuantity] DECIMAL(18,3) NULL DEFAULT 0,
    
    -- Pricing
    [EstimatedUnitPrice] DECIMAL(18,2) NULL,
    [EstimatedAmount] DECIMAL(18,2) NOT NULL,
    [ApprovedUnitPrice] DECIMAL(18,2) NULL,
    [ApprovedAmount] DECIMAL(18,2) NULL,
    
    -- Additional Details
    [Specifications] NVARCHAR(MAX) NULL,
    [PreferredSupplierID] INT NULL,
    [PreferredSupplierName] NVARCHAR(200) NULL,
    [RequiredDate] DATE NULL,
    [Remarks] NVARCHAR(500) NULL,
    
    -- Status
    [IsApproved] BIT NULL DEFAULT 0,
    [IsCancelled] BIT NOT NULL DEFAULT 0,
    [CancellationReason] NVARCHAR(500) NULL,
    
    -- Audit
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Constraints
    CONSTRAINT PK_IndentDetails PRIMARY KEY CLUSTERED (IndentDetailID ASC),
    CONSTRAINT FK_IndentDetails_IndentMaster FOREIGN KEY (IndentID) 
        REFERENCES IndentMaster(IndentID) ON DELETE CASCADE,
    CONSTRAINT UQ_IndentDetails_IndentID_LineNumber UNIQUE (IndentID, LineNumber)
)

GO

-- Create indexes for IndentDetails
CREATE NONCLUSTERED INDEX IX_IndentDetails_IndentID ON IndentDetails(IndentID)
CREATE NONCLUSTERED INDEX IX_IndentDetails_ItemCode ON IndentDetails(ItemCode)

GO

-- =============================================
-- CREATE INDENT APPROVAL WORKFLOW TABLE
-- =============================================
CREATE TABLE [dbo].[IndentApprovalWorkflow] (
    [ApprovalID] INT IDENTITY(1,1) NOT NULL,
    [IndentID] INT NOT NULL,
    [ApprovalLevel] INT NOT NULL,
    [ApproverRole] NVARCHAR(100) NOT NULL,
    [ApproverID] INT NULL,
    [ApproverName] NVARCHAR(100) NULL,
    [ApprovalStatus] NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected', 'On Hold'
    [ApprovalDate] DATETIME NULL,
    [ApprovalComments] NVARCHAR(MAX) NULL,
    [ExpectedApprovalDate] DATE NULL,
    [ReminderSent] BIT NOT NULL DEFAULT 0,
    [ReminderCount] INT NOT NULL DEFAULT 0,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    CONSTRAINT PK_IndentApprovalWorkflow PRIMARY KEY CLUSTERED (ApprovalID ASC),
    CONSTRAINT FK_IndentApprovalWorkflow_IndentMaster FOREIGN KEY (IndentID) 
        REFERENCES IndentMaster(IndentID) ON DELETE CASCADE,
    CONSTRAINT UQ_IndentApprovalWorkflow_IndentID_Level UNIQUE (IndentID, ApprovalLevel)
)

GO

-- =============================================
-- CREATE INDENT APPROVAL HISTORY TABLE
-- =============================================
CREATE TABLE [dbo].[IndentApprovalHistory] (
    [HistoryID] INT IDENTITY(1,1) NOT NULL,
    [IndentID] INT NOT NULL,
    [Action] NVARCHAR(50) NOT NULL, -- 'Submitted', 'Approved', 'Rejected', 'Cancelled', 'Modified', 'Forwarded', 'Returned'
    [ActionBy] NVARCHAR(100) NOT NULL,
    [ActionByID] INT NULL,
    [ActionDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [Comments] NVARCHAR(MAX) NULL,
    [PreviousStatus] NVARCHAR(50) NULL,
    [NewStatus] NVARCHAR(50) NULL,
    [ApprovalLevel] INT NULL,
    [IPAddress] NVARCHAR(50) NULL,
    
    CONSTRAINT PK_IndentApprovalHistory PRIMARY KEY CLUSTERED (HistoryID ASC),
    CONSTRAINT FK_IndentApprovalHistory_IndentMaster FOREIGN KEY (IndentID) 
        REFERENCES IndentMaster(IndentID) ON DELETE CASCADE
)

GO

-- Create index for Approval History
CREATE NONCLUSTERED INDEX IX_IndentApprovalHistory_IndentID ON IndentApprovalHistory(IndentID)
CREATE NONCLUSTERED INDEX IX_IndentApprovalHistory_ActionDate ON IndentApprovalHistory(ActionDate)

GO

-- =============================================
-- STORED PROCEDURE: Create New Indent
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateIndent]
    @IndentType NVARCHAR(50),
    @RequiredDate DATE,
    @DepartmentID INT = NULL,
    @DepartmentName NVARCHAR(100) = NULL,
    @RequestedBy NVARCHAR(100),
    @RequestedByID INT = NULL,
    @RequestedByRole NVARCHAR(50) = NULL,
    @Priority NVARCHAR(20) = 'Normal',
    @UrgencyReason NVARCHAR(500) = NULL,
    @EstimatedAmount DECIMAL(18,2) = 0,
    @Currency NVARCHAR(3) = 'USD',
    @BudgetCode NVARCHAR(50) = NULL,
    @CostCenter NVARCHAR(50) = NULL,
    @Justification NVARCHAR(MAX) = NULL,
    @SpecialInstructions NVARCHAR(MAX) = NULL,
    @DeliveryLocation NVARCHAR(500) = NULL,
    @DeliveryTerms NVARCHAR(500) = NULL,
    @Attachments NVARCHAR(500) = NULL,
    @ReferenceNumber NVARCHAR(100) = NULL,
    @ReferenceNotes NVARCHAR(500) = NULL,
    @CreatedBy NVARCHAR(100),
    @NewIndentID INT OUTPUT,
    @IndentNumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Generate Indent Number (Format: IND-YYYY-MM-XXXX)
            DECLARE @Year INT = YEAR(GETDATE())
            DECLARE @Month INT = MONTH(GETDATE())
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(IndentNumber, 4) AS INT)), 0) + 1
            FROM IndentMaster
            WHERE IndentNumber LIKE 'IND-' + CAST(@Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-%'
            
            SET @IndentNumber = 'IND-' + CAST(@Year AS VARCHAR(4)) + '-' + 
                                RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-' + 
                                RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Insert Indent Master
            INSERT INTO IndentMaster (
                IndentNumber, IndentType, RequiredDate, DepartmentID, DepartmentName,
                RequestedBy, RequestedByID, RequestedByRole, Priority, UrgencyReason,
                EstimatedAmount, Currency, BudgetCode, CostCenter, Justification,
                SpecialInstructions, DeliveryLocation, DeliveryTerms, Attachments,
                ReferenceNumber, ReferenceNotes, Status, CreatedBy
            )
            VALUES (
                @IndentNumber, @IndentType, @RequiredDate, @DepartmentID, @DepartmentName,
                @RequestedBy, @RequestedByID, @RequestedByRole, @Priority, @UrgencyReason,
                @EstimatedAmount, @Currency, @BudgetCode, @CostCenter, @Justification,
                @SpecialInstructions, @DeliveryLocation, @DeliveryTerms, @Attachments,
                @ReferenceNumber, @ReferenceNotes, 'Draft', @CreatedBy
            )
            
            SET @NewIndentID = SCOPE_IDENTITY()
            
            -- Add to Approval History
            INSERT INTO IndentApprovalHistory (
                IndentID, Action, ActionBy, ActionByID, Comments, NewStatus
            )
            VALUES (
                @NewIndentID, 'Created', @CreatedBy, @RequestedByID, 'Indent created in draft mode', 'Draft'
            )
            
        COMMIT TRANSACTION
        
        SELECT @NewIndentID AS IndentID, @IndentNumber AS IndentNumber, 'Indent created successfully.' AS Message
        
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
-- STORED PROCEDURE: Add Indent Details (Line Items)
-- =============================================
CREATE PROCEDURE [dbo].[sp_AddIndentDetails]
    @IndentID INT,
    @Items AS dbo.IndentItemType READONLY, -- User-defined table type
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists and is in Draft or Rejected status
            DECLARE @CurrentStatus NVARCHAR(50)
            SELECT @CurrentStatus = Status FROM IndentMaster WHERE IndentID = @IndentID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus NOT IN ('Draft', 'Rejected')
            BEGIN
                RAISERROR('Items can only be added/modified in Draft or Rejected status.', 16, 1)
                RETURN
            END
            
            -- Insert items
            INSERT INTO IndentDetails (
                IndentID, LineNumber, ItemCode, ItemName, ItemDescription,
                Quantity, UnitOfMeasure, EstimatedUnitPrice, EstimatedAmount,
                Specifications, PreferredSupplierID, PreferredSupplierName,
                RequiredDate, Remarks, CreatedDate
            )
            SELECT 
                @IndentID, LineNumber, ItemCode, ItemName, ItemDescription,
                Quantity, UnitOfMeasure, EstimatedUnitPrice, EstimatedAmount,
                Specifications, PreferredSupplierID, PreferredSupplierName,
                RequiredDate, Remarks, GETDATE()
            FROM @Items
            
            -- Update total estimated amount in Indent Master
            UPDATE IndentMaster
            SET EstimatedAmount = (
                SELECT ISNULL(SUM(EstimatedAmount), 0)
                FROM IndentDetails
                WHERE IndentID = @IndentID AND IsCancelled = 0
            ),
            ModifiedDate = GETDATE(),
            ModifiedBy = @ModifiedBy
            WHERE IndentID = @IndentID
            
        COMMIT TRANSACTION
        
        SELECT 'Indent details added successfully.' AS Message
        
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
-- STORED PROCEDURE: Submit Indent for Approval
-- =============================================
CREATE PROCEDURE [dbo].[sp_SubmitIndentForApproval]
    @IndentID INT,
    @SubmittedBy NVARCHAR(100),
    @SubmittedByID INT = NULL,
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists and has details
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @TotalItems INT
            
            SELECT @CurrentStatus = Status FROM IndentMaster WHERE IndentID = @IndentID
            SELECT @TotalItems = COUNT(*) FROM IndentDetails WHERE IndentID = @IndentID AND IsCancelled = 0
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus NOT IN ('Draft', 'Rejected')
            BEGIN
                RAISERROR('Indent cannot be submitted from current status.', 16, 1)
                RETURN
            END
            
            IF @TotalItems = 0
            BEGIN
                RAISERROR('Cannot submit indent without any items.', 16, 1)
                RETURN
            END
            
            -- Update indent status
            UPDATE IndentMaster
            SET Status = 'Pending Approval',
                ApprovalStatus = 'Pending Level 1',
                SubmissionDate = GETDATE(),
                ModifiedDate = GETDATE(),
                ModifiedBy = @SubmittedBy
            WHERE IndentID = @IndentID
            
            -- Add to approval history
            INSERT INTO IndentApprovalHistory (
                IndentID, Action, ActionBy, ActionByID, Comments, PreviousStatus, NewStatus
            )
            VALUES (
                @IndentID, 'Submitted', @SubmittedBy, @SubmittedByID, 
                @Comments, @CurrentStatus, 'Pending Approval'
            )
            
            -- Create approval workflow entries (you can customize based on approval rules)
            -- This is a sample with 2-level approval
            INSERT INTO IndentApprovalWorkflow (IndentID, ApprovalLevel, ApproverRole, ApprovalStatus)
            VALUES 
                (@IndentID, 1, 'Department Head', 'Pending'),
                (@IndentID, 2, 'Finance Manager', 'Pending')
            
        COMMIT TRANSACTION
        
        SELECT 'Indent submitted for approval successfully.' AS Message
        
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
-- STORED PROCEDURE: Approve Indent (Level-based)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ApproveIndent]
    @IndentID INT,
    @ApprovalLevel INT,
    @ApproverID INT,
    @ApproverName NVARCHAR(100),
    @ApproverRole NVARCHAR(100),
    @ApprovalComments NVARCHAR(MAX) = NULL,
    @ApprovedAmount DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists and is in pending approval status
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @CurrentApprovalLevel INT
            DECLARE @TotalLevels INT = 2 -- Can be dynamic based on business rules
            
            SELECT @CurrentStatus = Status, @CurrentApprovalLevel = CurrentApprovalLevel
            FROM IndentMaster 
            WHERE IndentID = @IndentID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus != 'Pending Approval'
            BEGIN
                RAISERROR('Indent is not in pending approval status.', 16, 1)
                RETURN
            END
            
            -- Check if this approval level is valid
            IF @ApprovalLevel != @CurrentApprovalLevel
            BEGIN
                RAISERROR('This approval level is not currently active.', 16, 1)
                RETURN
            END
            
            -- Update approval workflow
            UPDATE IndentApprovalWorkflow
            SET ApprovalStatus = 'Approved',
                ApproverID = @ApproverID,
                ApproverName = @ApproverName,
                ApprovalDate = GETDATE(),
                ApprovalComments = @ApprovalComments,
                ModifiedDate = GETDATE()
            WHERE IndentID = @IndentID AND ApprovalLevel = @ApprovalLevel
            
            -- Update indent details approval if amount is provided
            IF @ApprovedAmount IS NOT NULL
            BEGIN
                UPDATE IndentMaster
                SET ApprovedAmount = @ApprovedAmount
                WHERE IndentID = @IndentID
            END
            
            -- Check if this was the last approval level
            IF @ApprovalLevel = @TotalLevels
            BEGIN
                -- Fully approved
                UPDATE IndentMaster
                SET Status = 'Approved',
                    ApprovalStatus = 'Fully Approved',
                    ApprovalDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE IndentID = @IndentID
                
                -- Add to approval history
                INSERT INTO IndentApprovalHistory (
                    IndentID, Action, ActionBy, ActionByID, Comments, 
                    PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    @IndentID, 'Approved', @ApproverName, @ApproverID, 
                    @ApprovalComments, 'Pending Approval', 'Approved', @ApprovalLevel
                )
                
                SELECT 'Indent fully approved successfully.' AS Message
            END
            ELSE
            -- Move to next approval level
            BEGIN
                UPDATE IndentMaster
                SET CurrentApprovalLevel = @CurrentApprovalLevel + 1,
                    ApprovalStatus = 'Pending Level ' + CAST(@CurrentApprovalLevel + 1 AS VARCHAR(10)),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE IndentID = @IndentID
                
                -- Add to approval history
                INSERT INTO IndentApprovalHistory (
                    IndentID, Action, ActionBy, ActionByID, Comments, 
                    PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    @IndentID, 'Approved', @ApproverName, @ApproverID, 
                    @ApprovalComments, 'Pending Approval', 
                    'Pending Level ' + CAST(@CurrentApprovalLevel + 1 AS VARCHAR(10)), 
                    @ApprovalLevel
                )
                
                SELECT 'Indent approved. Waiting for next level approval.' AS Message
            END
            
        COMMIT TRANSACTION
        
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
-- STORED PROCEDURE: Reject Indent
-- =============================================
CREATE PROCEDURE [dbo].[sp_RejectIndent]
    @IndentID INT,
    @ApprovalLevel INT,
    @ApproverID INT,
    @ApproverName NVARCHAR(100),
    @RejectionReason NVARCHAR(MAX),
    @SendBackToDraft BIT = 0
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists
            DECLARE @CurrentStatus NVARCHAR(50)
            SELECT @CurrentStatus = Status FROM IndentMaster WHERE IndentID = @IndentID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            -- Update approval workflow
            UPDATE IndentApprovalWorkflow
            SET ApprovalStatus = 'Rejected',
                ApproverID = @ApproverID,
                ApproverName = @ApproverName,
                ApprovalDate = GETDATE(),
                ApprovalComments = @RejectionReason,
                ModifiedDate = GETDATE()
            WHERE IndentID = @IndentID AND ApprovalLevel = @ApprovalLevel
            
            -- Update indent status
            IF @SendBackToDraft = 1
            BEGIN
                UPDATE IndentMaster
                SET Status = 'Draft',
                    ApprovalStatus = NULL,
                    CurrentApprovalLevel = 1,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE IndentID = @IndentID
                
                -- Delete pending approval workflow entries
                DELETE FROM IndentApprovalWorkflow
                WHERE IndentID = @IndentID AND ApprovalStatus = 'Pending'
            END
            ELSE
            BEGIN
                UPDATE IndentMaster
                SET Status = 'Rejected',
                    ApprovalStatus = 'Rejected',
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE IndentID = @IndentID
            END
            
            -- Add to approval history
            INSERT INTO IndentApprovalHistory (
                IndentID, Action, ActionBy, ActionByID, Comments, 
                PreviousStatus, NewStatus, ApprovalLevel
            )
            VALUES (
                @IndentID, 'Rejected', @ApproverName, @ApproverID, 
                @RejectionReason, @CurrentStatus, 
                CASE WHEN @SendBackToDraft = 1 THEN 'Draft' ELSE 'Rejected' END, 
                @ApprovalLevel
            )
            
            SELECT 'Indent rejected successfully.' AS Message
            
        COMMIT TRANSACTION
        
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
-- STORED PROCEDURE: Cancel Indent
-- =============================================
CREATE PROCEDURE [dbo].[sp_CancelIndent]
    @IndentID INT,
    @CancelledBy NVARCHAR(100),
    @CancelledByID INT = NULL,
    @CancellationReason NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists
            DECLARE @CurrentStatus NVARCHAR(50)
            SELECT @CurrentStatus = Status FROM IndentMaster WHERE IndentID = @IndentID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            -- Check if indent can be cancelled (cannot cancel if already converted to PO)
            IF @CurrentStatus = 'Converted to PO'
            BEGIN
                RAISERROR('Indent cannot be cancelled as it is already converted to Purchase Order.', 16, 1)
                RETURN
            END
            
            -- Update indent status
            UPDATE IndentMaster
            SET Status = 'Cancelled',
                ModifiedDate = GETDATE(),
                ModifiedBy = @CancelledBy
            WHERE IndentID = @IndentID
            
            -- Update all pending approval workflow entries
            UPDATE IndentApprovalWorkflow
            SET ApprovalStatus = 'Cancelled',
                ModifiedDate = GETDATE()
            WHERE IndentID = @IndentID AND ApprovalStatus = 'Pending'
            
            -- Add to approval history
            INSERT INTO IndentApprovalHistory (
                IndentID, Action, ActionBy, ActionByID, Comments, 
                PreviousStatus, NewStatus
            )
            VALUES (
                @IndentID, 'Cancelled', @CancelledBy, @CancelledByID, 
                @CancellationReason, @CurrentStatus, 'Cancelled'
            )
            
            SELECT 'Indent cancelled successfully.' AS Message
            
        COMMIT TRANSACTION
        
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
-- STORED PROCEDURE: Get Indent by ID with Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetIndentByID]
    @IndentID INT
AS
BEGIN
    SET NOCOUNT ON
    
    -- Get Indent Master
    SELECT 
        IndentID, IndentNumber, IndentType, IndentDate, RequiredDate,
        DepartmentID, DepartmentName, RequestedBy, RequestedByID, RequestedByRole,
        Priority, UrgencyReason, Status, ApprovalStatus, CurrentApprovalLevel,
        EstimatedAmount, ApprovedAmount, Currency, BudgetCode, CostCenter,
        Justification, SpecialInstructions, DeliveryLocation, DeliveryTerms,
        Attachments, ReferenceNumber, ReferenceNotes,
        SubmissionDate, ApprovalDate, CompletionDate, CreatedDate, ModifiedDate,
        CreatedBy, ModifiedBy
    FROM IndentMaster
    WHERE IndentID = @IndentID
    
    -- Get Indent Details
    SELECT 
        IndentDetailID, IndentID, LineNumber, ItemID, ItemCode, ItemName,
        ItemDescription, Quantity, UnitOfMeasure, ReceivedQuantity,
        EstimatedUnitPrice, EstimatedAmount, ApprovedUnitPrice, ApprovedAmount,
        Specifications, PreferredSupplierID, PreferredSupplierName,
        RequiredDate, Remarks, IsApproved, IsCancelled
    FROM IndentDetails
    WHERE IndentID = @IndentID AND IsCancelled = 0
    ORDER BY LineNumber
    
    -- Get Approval Workflow
    SELECT 
        ApprovalID, ApprovalLevel, ApproverRole, ApproverID, ApproverName,
        ApprovalStatus, ApprovalDate, ApprovalComments, ExpectedApprovalDate,
        ReminderSent, ReminderCount
    FROM IndentApprovalWorkflow
    WHERE IndentID = @IndentID
    ORDER BY ApprovalLevel
    
    -- Get Approval History
    SELECT TOP 20
        HistoryID, Action, ActionBy, ActionByID, ActionDate,
        Comments, PreviousStatus, NewStatus, ApprovalLevel
    FROM IndentApprovalHistory
    WHERE IndentID = @IndentID
    ORDER BY ActionDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Indents (with filters)
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetIndents]
    @Status NVARCHAR(50) = NULL,
    @DepartmentID INT = NULL,
    @RequestedBy NVARCHAR(100) = NULL,
    @Priority NVARCHAR(20) = NULL,
    @IndentType NVARCHAR(50) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @ApprovalStatus NVARCHAR(50) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortBy NVARCHAR(50) = 'IndentDate',
    @SortOrder NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    DECLARE @SQL NVARCHAR(MAX)
    
    SET @SQL = '
    SELECT 
        I.IndentID, I.IndentNumber, I.IndentType, I.IndentDate, I.RequiredDate,
        I.DepartmentName, I.RequestedBy, I.Priority, I.Status, I.ApprovalStatus,
        I.EstimatedAmount, I.ApprovedAmount, I.Currency,
        COUNT(*) OVER() AS TotalRecords,
        (SELECT COUNT(*) FROM IndentDetails WHERE IndentID = I.IndentID AND IsCancelled = 0) AS TotalItems,
        (
            SELECT COUNT(*) 
            FROM IndentApprovalWorkflow 
            WHERE IndentID = I.IndentID AND ApprovalStatus = ''Approved''
        ) AS ApprovedLevels,
        (
            SELECT COUNT(*) 
            FROM IndentApprovalWorkflow 
            WHERE IndentID = I.IndentID
        ) AS TotalLevels
    FROM IndentMaster I
    WHERE 
        (@Status IS NULL OR I.Status = @Status)
        AND (@DepartmentID IS NULL OR I.DepartmentID = @DepartmentID)
        AND (@RequestedBy IS NULL OR I.RequestedBy = @RequestedBy)
        AND (@Priority IS NULL OR I.Priority = @Priority)
        AND (@IndentType IS NULL OR I.IndentType = @IndentType)
        AND (@ApprovalStatus IS NULL OR I.ApprovalStatus = @ApprovalStatus)
        AND (@FromDate IS NULL OR CAST(I.IndentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(I.IndentDate AS DATE) <= @ToDate)
    ORDER BY ' + QUOTENAME(@SortBy) + ' ' + @SortOrder + '
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY'
    
    EXEC sp_executesql @SQL,
        N'@Status NVARCHAR(50), @DepartmentID INT, @RequestedBy NVARCHAR(100), 
          @Priority NVARCHAR(20), @IndentType NVARCHAR(50), @FromDate DATE, @ToDate DATE,
          @ApprovalStatus NVARCHAR(50), @Offset INT, @PageSize INT',
        @Status, @DepartmentID, @RequestedBy, @Priority, @IndentType, 
        @FromDate, @ToDate, @ApprovalStatus, @Offset, @PageSize
END
GO

-- =============================================
-- STORED PROCEDURE: Get Pending Approvals for User
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPendingApprovalsForUser]
    @ApproverRole NVARCHAR(100),
    @ApproverID INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    
    SELECT 
        I.IndentID, I.IndentNumber, I.IndentType, I.IndentDate, I.RequiredDate,
        I.DepartmentName, I.RequestedBy, I.Priority, I.EstimatedAmount,
        I.Currency, I.Justification,
        W.ApprovalLevel, W.ApproverRole, W.ExpectedApprovalDate,
        COUNT(*) OVER() AS TotalRecords,
        (SELECT COUNT(*) FROM IndentDetails WHERE IndentID = I.IndentID AND IsCancelled = 0) AS TotalItems
    FROM IndentMaster I
    INNER JOIN IndentApprovalWorkflow W ON I.IndentID = W.IndentID
    WHERE I.Status = 'Pending Approval'
        AND W.ApprovalStatus = 'Pending'
        AND W.ApproverRole = @ApproverRole
        AND (W.ApproverID IS NULL OR W.ApproverID = @ApproverID OR @ApproverID IS NULL)
    ORDER BY I.Priority DESC, I.IndentDate ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
GO

-- =============================================
-- STORED PROCEDURE: Update Indent (Modify After Rejection)
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateIndent]
    @IndentID INT,
    @RequiredDate DATE = NULL,
    @Priority NVARCHAR(20) = NULL,
    @UrgencyReason NVARCHAR(500) = NULL,
    @Justification NVARCHAR(MAX) = NULL,
    @SpecialInstructions NVARCHAR(MAX) = NULL,
    @DeliveryLocation NVARCHAR(500) = NULL,
    @DeliveryTerms NVARCHAR(500) = NULL,
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists and is in Draft or Rejected status
            DECLARE @CurrentStatus NVARCHAR(50)
            SELECT @CurrentStatus = Status FROM IndentMaster WHERE IndentID = @IndentID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus NOT IN ('Draft', 'Rejected')
            BEGIN
                RAISERROR('Indent can only be updated in Draft or Rejected status.', 16, 1)
                RETURN
            END
            
            -- Update indent master
            UPDATE IndentMaster
            SET RequiredDate = ISNULL(@RequiredDate, RequiredDate),
                Priority = ISNULL(@Priority, Priority),
                UrgencyReason = ISNULL(@UrgencyReason, UrgencyReason),
                Justification = ISNULL(@Justification, Justification),
                SpecialInstructions = ISNULL(@SpecialInstructions, SpecialInstructions),
                DeliveryLocation = ISNULL(@DeliveryLocation, DeliveryLocation),
                DeliveryTerms = ISNULL(@DeliveryTerms, DeliveryTerms),
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE IndentID = @IndentID
            
            -- Add to approval history
            INSERT INTO IndentApprovalHistory (
                IndentID, Action, ActionBy, Comments, PreviousStatus, NewStatus
            )
            VALUES (
                @IndentID, 'Modified', @ModifiedBy, 'Indent updated after rejection', 
                @CurrentStatus, @CurrentStatus
            )
            
            SELECT 'Indent updated successfully.' AS Message
            
        COMMIT TRANSACTION
        
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
-- STORED PROCEDURE: Get Indent Summary Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetIndentSummaryReport]
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @DepartmentID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        -- Summary by Status
        Status,
        COUNT(*) AS TotalIndents,
        SUM(EstimatedAmount) AS TotalEstimatedAmount,
        SUM(ApprovedAmount) AS TotalApprovedAmount,
        AVG(EstimatedAmount) AS AvgIndentValue
    FROM IndentMaster
    WHERE (@FromDate IS NULL OR CAST(IndentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(IndentDate AS DATE) <= @ToDate)
        AND (@DepartmentID IS NULL OR DepartmentID = @DepartmentID)
    GROUP BY Status
    
    -- Summary by Department
    SELECT 
        DepartmentName,
        COUNT(*) AS TotalIndents,
        SUM(CASE WHEN Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedIndents,
        SUM(CASE WHEN Status = 'Pending Approval' THEN 1 ELSE 0 END) AS PendingIndents,
        SUM(CASE WHEN Status = 'Rejected' THEN 1 ELSE 0 END) AS RejectedIndents,
        SUM(EstimatedAmount) AS TotalEstimatedAmount,
        SUM(ApprovedAmount) AS TotalApprovedAmount
    FROM IndentMaster
    WHERE (@FromDate IS NULL OR CAST(IndentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(IndentDate AS DATE) <= @ToDate)
        AND (@DepartmentID IS NULL OR DepartmentID = @DepartmentID)
    GROUP BY DepartmentName
    
    -- Summary by Priority
    SELECT 
        Priority,
        COUNT(*) AS TotalIndents,
        AVG(DATEDIFF(DAY, IndentDate, RequiredDate)) AS AvgLeadTime,
        SUM(EstimatedAmount) AS TotalEstimatedAmount
    FROM IndentMaster
    WHERE (@FromDate IS NULL OR CAST(IndentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(IndentDate AS DATE) <= @ToDate)
        AND (@DepartmentID IS NULL OR DepartmentID = @DepartmentID)
    GROUP BY Priority
    
    -- Monthly Trend
    SELECT 
        YEAR(IndentDate) AS [Year],
        MONTH(IndentDate) AS [Month],
        COUNT(*) AS TotalIndents,
        SUM(EstimatedAmount) AS TotalEstimatedAmount,
        SUM(ApprovedAmount) AS TotalApprovedAmount
    FROM IndentMaster
    WHERE (@FromDate IS NULL OR CAST(IndentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(IndentDate AS DATE) <= @ToDate)
        AND (@DepartmentID IS NULL OR DepartmentID = @DepartmentID)
    GROUP BY YEAR(IndentDate), MONTH(IndentDate)
    ORDER BY YEAR(IndentDate) DESC, MONTH(IndentDate) DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Convert Indent to Purchase Order
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvertIndentToPO]
    @IndentID INT,
    @PONumber NVARCHAR(50),
    @ConvertedBy NVARCHAR(100),
    @ConvertedByID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists and is approved
            DECLARE @CurrentStatus NVARCHAR(50)
            SELECT @CurrentStatus = Status FROM IndentMaster WHERE IndentID = @IndentID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus != 'Approved'
            BEGIN
                RAISERROR('Only approved indents can be converted to Purchase Orders.', 16, 1)
                RETURN
            END
            
            -- Update indent status
            UPDATE IndentMaster
            SET Status = 'Converted to PO',
                ReferenceNumber = @PONumber,
                CompletionDate = GETDATE(),
                ModifiedDate = GETDATE(),
                ModifiedBy = @ConvertedBy
            WHERE IndentID = @IndentID
            
            -- Add to approval history
            INSERT INTO IndentApprovalHistory (
                IndentID, Action, ActionBy, ActionByID, Comments, 
                PreviousStatus, NewStatus
            )
            VALUES (
                @IndentID, 'Converted to PO', @ConvertedBy, @ConvertedByID, 
                'Converted to Purchase Order: ' + @PONumber, 
                'Approved', 'Converted to PO'
            )
            
            SELECT 'Indent converted to Purchase Order successfully.' AS Message
            
        COMMIT TRANSACTION
        
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
-- CREATE USER-DEFINED TABLE TYPE for Indent Items
-- =============================================
CREATE TYPE [dbo].[IndentItemType] AS TABLE (
    LineNumber INT NOT NULL,
    ItemCode NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(200) NOT NULL,
    ItemDescription NVARCHAR(500) NULL,
    Quantity DECIMAL(18,3) NOT NULL,
    UnitOfMeasure NVARCHAR(20) NOT NULL,
    EstimatedUnitPrice DECIMAL(18,2) NULL,
    EstimatedAmount DECIMAL(18,2) NOT NULL,
    Specifications NVARCHAR(MAX) NULL,
    PreferredSupplierID INT NULL,
    PreferredSupplierName NVARCHAR(200) NULL,
    RequiredDate DATE NULL,
    Remarks NVARCHAR(500) NULL
)
GO

PRINT 'Indent Management tables and stored procedures created successfully!'