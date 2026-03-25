-- =============================================
-- DATABASE: Purchase Management System
-- DESCRIPTION: PR to PO workflow with multi-level approvals
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- CREATE PURCHASE REQUISITION (PR) TABLE
-- =============================================
CREATE TABLE [dbo].[PurchaseRequisition] (
    -- Primary Key
    [PRID] INT IDENTITY(1,1) NOT NULL,
    [PRNumber] NVARCHAR(50) NOT NULL,
    [PRType] NVARCHAR(50) NOT NULL, -- 'Material', 'Service', 'Capital Goods'
    [PRDate] DATE NOT NULL DEFAULT GETDATE(),
    [RequiredDate] DATE NOT NULL,
    
    -- Source Information (from Indent)
    [IndentID] INT NULL,
    [IndentNumber] NVARCHAR(50) NULL,
    
    -- Department and Requester Information
    [DepartmentID] INT NULL,
    [DepartmentName] NVARCHAR(100) NULL,
    [RequestedBy] NVARCHAR(100) NOT NULL,
    [RequestedByID] INT NULL,
    
    -- Priority and Urgency
    [Priority] NVARCHAR(20) NOT NULL DEFAULT 'Normal',
    [UrgencyReason] NVARCHAR(500) NULL,
    
    -- PR Status Workflow
    [PRStatus] NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Submitted', 'PR Approved', 'PR Rejected', 'Converted to PO'
    [PRApprovalStatus] NVARCHAR(50) NULL,
    [CurrentPRApprovalLevel] INT NULL DEFAULT 1,
    
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
    
    -- Attachments
    [Attachments] NVARCHAR(500) NULL,
    
    -- Dates
    [SubmissionDate] DATETIME NULL,
    [PRApprovalDate] DATETIME NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Audit
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    
    CONSTRAINT PK_PurchaseRequisition PRIMARY KEY CLUSTERED (PRID ASC),
    CONSTRAINT UQ_PurchaseRequisition_PRNumber UNIQUE NONCLUSTERED (PRNumber ASC)
)

GO

-- =============================================
-- CREATE PURCHASE REQUISITION DETAILS TABLE
-- =============================================
CREATE TABLE [dbo].[PurchaseRequisitionDetails] (
    [PRDetailID] INT IDENTITY(1,1) NOT NULL,
    [PRID] INT NOT NULL,
    [LineNumber] INT NOT NULL,
    
    -- Item Information
    [ItemID] INT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    
    -- Quantity and Unit
    [Quantity] DECIMAL(18,3) NOT NULL,
    [UnitOfMeasure] NVARCHAR(20) NOT NULL,
    
    -- Pricing
    [EstimatedUnitPrice] DECIMAL(18,2) NULL,
    [EstimatedAmount] DECIMAL(18,2) NOT NULL,
    [ApprovedUnitPrice] DECIMAL(18,2) NULL,
    [ApprovedAmount] DECIMAL(18,2) NULL,
    
    -- Supplier Information
    [SuggestedSupplierID] INT NULL,
    [SuggestedSupplierName] NVARCHAR(200) NULL,
    
    -- Additional Details
    [Specifications] NVARCHAR(MAX) NULL,
    [RequiredDate] DATE NULL,
    [Remarks] NVARCHAR(500) NULL,
    
    -- Status
    [IsActive] BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_PurchaseRequisitionDetails PRIMARY KEY CLUSTERED (PRDetailID ASC),
    CONSTRAINT FK_PRDetails_PurchaseRequisition FOREIGN KEY (PRID) 
        REFERENCES PurchaseRequisition(PRID) ON DELETE CASCADE
)

GO

-- =============================================
-- CREATE PR APPROVAL WORKFLOW TABLE
-- =============================================
CREATE TABLE [dbo].[PRApprovalWorkflow] (
    [ApprovalID] INT IDENTITY(1,1) NOT NULL,
    [PRID] INT NOT NULL,
    [ApprovalLevel] INT NOT NULL,
    [ApproverRole] NVARCHAR(100) NOT NULL,
    [ApproverID] INT NULL,
    [ApproverName] NVARCHAR(100) NULL,
    [ApprovalStatus] NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    [ApprovalDate] DATETIME NULL,
    [ApprovalComments] NVARCHAR(MAX) NULL,
    [ExpectedApprovalDate] DATE NULL,
    
    CONSTRAINT PK_PRApprovalWorkflow PRIMARY KEY CLUSTERED (ApprovalID ASC),
    CONSTRAINT FK_PRApprovalWorkflow_PurchaseRequisition FOREIGN KEY (PRID) 
        REFERENCES PurchaseRequisition(PRID) ON DELETE CASCADE
)

GO

-- =============================================
-- CREATE PURCHASE ORDER (PO) TABLE
-- =============================================
CREATE TABLE [dbo].[PurchaseOrder] (
    -- Primary Key
    [POID] INT IDENTITY(1,1) NOT NULL,
    [PONumber] NVARCHAR(50) NOT NULL,
    [POType] NVARCHAR(50) NOT NULL,
    [PODate] DATE NOT NULL DEFAULT GETDATE(),
    [RequiredDate] DATE NOT NULL,
    [DeliveryDate] DATE NULL,
    
    -- Source Information (from PR)
    [PRID] INT NULL,
    [PRNumber] NVARCHAR(50) NULL,
    [IndentID] INT NULL,
    [IndentNumber] NVARCHAR(50) NULL,
    
    -- Supplier Information
    [SupplierID] INT NOT NULL,
    [SupplierName] NVARCHAR(200) NOT NULL,
    [SupplierCode] NVARCHAR(50) NULL,
    [SupplierContactPerson] NVARCHAR(100) NULL,
    [SupplierEmail] NVARCHAR(100) NULL,
    [SupplierPhone] NVARCHAR(20) NULL,
    
    -- Shipping and Delivery
    [ShippingAddress] NVARCHAR(500) NULL,
    [BillingAddress] NVARCHAR(500) NULL,
    [DeliveryTerms] NVARCHAR(500) NULL,
    [ShippingMethod] NVARCHAR(100) NULL,
    
    -- Financial Information
    [TotalAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [TaxAmount] DECIMAL(18,2) NULL DEFAULT 0,
    [DiscountAmount] DECIMAL(18,2) NULL DEFAULT 0,
    [NetAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [Currency] NVARCHAR(3) NULL DEFAULT 'USD',
    [ExchangeRate] DECIMAL(10,4) NULL DEFAULT 1,
    
    -- Payment Terms
    [PaymentTerms] NVARCHAR(100) NULL,
    [PaymentMethod] NVARCHAR(50) NULL,
    [AdvancePayment] DECIMAL(18,2) NULL DEFAULT 0,
    
    -- PO Status Workflow
    [POStatus] NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Submitted', 'PO Approved', 'PO Rejected', 'Issued', 'Acknowledged', 'In Progress', 'Completed', 'Cancelled'
    [POApprovalStatus] NVARCHAR(50) NULL,
    [CurrentPOApprovalLevel] INT NULL DEFAULT 1,
    
    -- Approval Information
    [ApprovedBy] NVARCHAR(100) NULL,
    [ApprovalDate] DATETIME NULL,
    [RejectionReason] NVARCHAR(500) NULL,
    
    -- Dates
    [IssuedDate] DATETIME NULL,
    [AcknowledgedDate] DATETIME NULL,
    [CompletionDate] DATETIME NULL,
    [CancelledDate] DATETIME NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Audit
    [CreatedBy] NVARCHAR(100) NOT NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    [CancelledBy] NVARCHAR(100) NULL,
    [CancellationReason] NVARCHAR(500) NULL,
    
    -- Attachments
    [Attachments] NVARCHAR(500) NULL,
    [TermsAndConditions] NVARCHAR(MAX) NULL,
    [SpecialInstructions] NVARCHAR(MAX) NULL,
    
    CONSTRAINT PK_PurchaseOrder PRIMARY KEY CLUSTERED (POID ASC),
    CONSTRAINT UQ_PurchaseOrder_PONumber UNIQUE NONCLUSTERED (PONumber ASC),
    CONSTRAINT FK_PurchaseOrder_PurchaseRequisition FOREIGN KEY (PRID) 
        REFERENCES PurchaseRequisition(PRID)
)

GO

-- =============================================
-- CREATE PURCHASE ORDER DETAILS TABLE
-- =============================================
CREATE TABLE [dbo].[PurchaseOrderDetails] (
    [PODetailID] INT IDENTITY(1,1) NOT NULL,
    [POID] INT NOT NULL,
    [LineNumber] INT NOT NULL,
    
    -- Source Information
    [PRDetailID] INT NULL,
    [PRID] INT NULL,
    
    -- Item Information
    [ItemID] INT NULL,
    [ItemCode] NVARCHAR(50) NOT NULL,
    [ItemName] NVARCHAR(200) NOT NULL,
    [ItemDescription] NVARCHAR(500) NULL,
    
    -- Quantity and Unit
    [OrderedQuantity] DECIMAL(18,3) NOT NULL,
    [ReceivedQuantity] DECIMAL(18,3) NULL DEFAULT 0,
    [AcceptedQuantity] DECIMAL(18,3) NULL DEFAULT 0,
    [RejectedQuantity] DECIMAL(18,3) NULL DEFAULT 0,
    [UnitOfMeasure] NVARCHAR(20) NOT NULL,
    
    -- Pricing
    [UnitPrice] DECIMAL(18,2) NOT NULL,
    [DiscountPercent] DECIMAL(5,2) NULL DEFAULT 0,
    [DiscountAmount] DECIMAL(18,2) NULL DEFAULT 0,
    [TaxRate] DECIMAL(5,2) NULL DEFAULT 0,
    [TaxAmount] DECIMAL(18,2) NULL DEFAULT 0,
    [LineTotal] DECIMAL(18,2) NOT NULL,
    
    -- Delivery Information
    [RequiredDate] DATE NULL,
    [PromisedDate] DATE NULL,
    [ActualDeliveryDate] DATE NULL,
    
    -- Additional Details
    [Specifications] NVARCHAR(MAX) NULL,
    [Remarks] NVARCHAR(500) NULL,
    
    -- Status
    [LineStatus] NVARCHAR(50) NULL DEFAULT 'Pending', -- 'Pending', 'Partially Received', 'Completed', 'Cancelled'
    
    CONSTRAINT PK_PurchaseOrderDetails PRIMARY KEY CLUSTERED (PODetailID ASC),
    CONSTRAINT FK_PODetails_PurchaseOrder FOREIGN KEY (POID) 
        REFERENCES PurchaseOrder(POID) ON DELETE CASCADE
)

GO

-- =============================================
-- CREATE PO APPROVAL WORKFLOW TABLE
-- =============================================
CREATE TABLE [dbo].[POApprovalWorkflow] (
    [ApprovalID] INT IDENTITY(1,1) NOT NULL,
    [POID] INT NOT NULL,
    [ApprovalLevel] INT NOT NULL,
    [ApproverRole] NVARCHAR(100) NOT NULL,
    [ApproverID] INT NULL,
    [ApproverName] NVARCHAR(100) NULL,
    [ApprovalStatus] NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    [ApprovalDate] DATETIME NULL,
    [ApprovalComments] NVARCHAR(MAX) NULL,
    [ExpectedApprovalDate] DATE NULL,
    
    CONSTRAINT PK_POApprovalWorkflow PRIMARY KEY CLUSTERED (ApprovalID ASC),
    CONSTRAINT FK_POApprovalWorkflow_PurchaseOrder FOREIGN KEY (POID) 
        REFERENCES PurchaseOrder(POID) ON DELETE CASCADE
)

GO

-- =============================================
-- CREATE PURCHASE HISTORY TABLE (Audit Trail)
-- =============================================
CREATE TABLE [dbo].[PurchaseHistory] (
    [HistoryID] INT IDENTITY(1,1) NOT NULL,
    [TransactionType] NVARCHAR(20) NOT NULL, -- 'PR', 'PO'
    [TransactionID] INT NOT NULL,
    [TransactionNumber] NVARCHAR(50) NOT NULL,
    [Action] NVARCHAR(50) NOT NULL,
    [ActionBy] NVARCHAR(100) NOT NULL,
    [ActionByID] INT NULL,
    [ActionDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [Comments] NVARCHAR(MAX) NULL,
    [PreviousStatus] NVARCHAR(50) NULL,
    [NewStatus] NVARCHAR(50) NULL,
    [ApprovalLevel] INT NULL,
    [IPAddress] NVARCHAR(50) NULL,
    
    CONSTRAINT PK_PurchaseHistory PRIMARY KEY CLUSTERED (HistoryID ASC)
)

GO

-- Create indexes for performance
CREATE NONCLUSTERED INDEX IX_PurchaseRequisition_PRNumber ON PurchaseRequisition(PRNumber)
CREATE NONCLUSTERED INDEX IX_PurchaseRequisition_PRStatus ON PurchaseRequisition(PRStatus)
CREATE NONCLUSTERED INDEX IX_PurchaseRequisition_IndentID ON PurchaseRequisition(IndentID)
CREATE NONCLUSTERED INDEX IX_PurchaseOrder_PONumber ON PurchaseOrder(PONumber)
CREATE NONCLUSTERED INDEX IX_PurchaseOrder_POStatus ON PurchaseOrder(POStatus)
CREATE NONCLUSTERED INDEX IX_PurchaseOrder_PRID ON PurchaseOrder(PRID)
CREATE NONCLUSTERED INDEX IX_PurchaseOrder_SupplierID ON PurchaseOrder(SupplierID)

GO

-- =============================================
-- STORED PROCEDURE: Convert Indent to PR
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvertIndentToPR]
    @IndentID INT,
    @ConvertedBy NVARCHAR(100),
    @ConvertedByID INT = NULL,
    @NewPRID INT OUTPUT,
    @PRNumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if indent exists and is approved
            DECLARE @IndentStatus NVARCHAR(50)
            DECLARE @IndentNumber NVARCHAR(50)
            DECLARE @IndentType NVARCHAR(50)
            DECLARE @RequiredDate DATE
            DECLARE @DepartmentID INT
            DECLARE @DepartmentName NVARCHAR(100)
            DECLARE @RequestedBy NVARCHAR(100)
            DECLARE @RequestedByID INT
            DECLARE @Priority NVARCHAR(20)
            DECLARE @UrgencyReason NVARCHAR(500)
            DECLARE @EstimatedAmount DECIMAL(18,2)
            DECLARE @ApprovedAmount DECIMAL(18,2)
            DECLARE @Currency NVARCHAR(3)
            DECLARE @BudgetCode NVARCHAR(50)
            DECLARE @CostCenter NVARCHAR(50)
            DECLARE @Justification NVARCHAR(MAX)
            DECLARE @SpecialInstructions NVARCHAR(MAX)
            DECLARE @DeliveryLocation NVARCHAR(500)
            DECLARE @DeliveryTerms NVARCHAR(500)
            DECLARE @Attachments NVARCHAR(500)
            
            SELECT 
                @IndentStatus = Status,
                @IndentNumber = IndentNumber,
                @IndentType = IndentType,
                @RequiredDate = RequiredDate,
                @DepartmentID = DepartmentID,
                @DepartmentName = DepartmentName,
                @RequestedBy = RequestedBy,
                @RequestedByID = RequestedByID,
                @Priority = Priority,
                @UrgencyReason = UrgencyReason,
                @EstimatedAmount = EstimatedAmount,
                @ApprovedAmount = ApprovedAmount,
                @Currency = Currency,
                @BudgetCode = BudgetCode,
                @CostCenter = CostCenter,
                @Justification = Justification,
                @SpecialInstructions = SpecialInstructions,
                @DeliveryLocation = DeliveryLocation,
                @DeliveryTerms = DeliveryTerms,
                @Attachments = Attachments
            FROM IndentMaster
            WHERE IndentID = @IndentID
            
            IF @IndentStatus IS NULL
            BEGIN
                RAISERROR('Indent not found.', 16, 1)
                RETURN
            END
            
            IF @IndentStatus != 'Approved'
            BEGIN
                RAISERROR('Only approved indents can be converted to PR.', 16, 1)
                RETURN
            END
            
            -- Generate PR Number (Format: PR-YYYY-MM-XXXX)
            DECLARE @Year INT = YEAR(GETDATE())
            DECLARE @Month INT = MONTH(GETDATE())
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(PRNumber, 4) AS INT)), 0) + 1
            FROM PurchaseRequisition
            WHERE PRNumber LIKE 'PR-' + CAST(@Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-%'
            
            SET @PRNumber = 'PR-' + CAST(@Year AS VARCHAR(4)) + '-' + 
                            RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-' + 
                            RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Create PR from Indent
            INSERT INTO PurchaseRequisition (
                PRNumber, PRType, RequiredDate, IndentID, IndentNumber,
                DepartmentID, DepartmentName, RequestedBy, RequestedByID,
                Priority, UrgencyReason, EstimatedAmount, ApprovedAmount,
                Currency, BudgetCode, CostCenter, Justification,
                SpecialInstructions, DeliveryLocation, DeliveryTerms,
                Attachments, PRStatus, CreatedBy
            )
            VALUES (
                @PRNumber, @IndentType, @RequiredDate, @IndentID, @IndentNumber,
                @DepartmentID, @DepartmentName, @RequestedBy, @RequestedByID,
                @Priority, @UrgencyReason, @EstimatedAmount, @ApprovedAmount,
                @Currency, @BudgetCode, @CostCenter, @Justification,
                @SpecialInstructions, @DeliveryLocation, @DeliveryTerms,
                @Attachments, 'Draft', @ConvertedBy
            )
            
            SET @NewPRID = SCOPE_IDENTITY()
            
            -- Copy Indent Details to PR Details
            INSERT INTO PurchaseRequisitionDetails (
                PRID, LineNumber, ItemID, ItemCode, ItemName, ItemDescription,
                Quantity, UnitOfMeasure, EstimatedUnitPrice, EstimatedAmount,
                ApprovedUnitPrice, ApprovedAmount, Specifications,
                SuggestedSupplierID, SuggestedSupplierName, RequiredDate, Remarks
            )
            SELECT 
                @NewPRID, LineNumber, ItemID, ItemCode, ItemName, ItemDescription,
                Quantity, UnitOfMeasure, EstimatedUnitPrice, EstimatedAmount,
                ApprovedUnitPrice, ApprovedAmount, Specifications,
                PreferredSupplierID, PreferredSupplierName, RequiredDate, Remarks
            FROM IndentDetails
            WHERE IndentID = @IndentID AND IsCancelled = 0
            
            -- Update Indent status
            UPDATE IndentMaster
            SET Status = 'Converted to PR',
                ReferenceNumber = @PRNumber,
                CompletionDate = GETDATE(),
                ModifiedDate = GETDATE(),
                ModifiedBy = @ConvertedBy
            WHERE IndentID = @IndentID
            
            -- Add to purchase history
            INSERT INTO PurchaseHistory (
                TransactionType, TransactionID, TransactionNumber, Action, 
                ActionBy, ActionByID, Comments, PreviousStatus, NewStatus
            )
            VALUES (
                'PR', @NewPRID, @PRNumber, 'Created from Indent', 
                @ConvertedBy, @ConvertedByID, 
                'PR created from Indent: ' + @IndentNumber,
                NULL, 'Draft'
            )
            
        COMMIT TRANSACTION
        
        SELECT @NewPRID AS PRID, @PRNumber AS PRNumber, 'PR created successfully from Indent.' AS Message
        
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
-- STORED PROCEDURE: Submit PR for Approval
-- =============================================
CREATE PROCEDURE [dbo].[sp_SubmitPRForApproval]
    @PRID INT,
    @SubmittedBy NVARCHAR(100),
    @SubmittedByID INT = NULL,
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if PR exists and is in Draft status
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @PRNumber NVARCHAR(50)
            DECLARE @TotalItems INT
            
            SELECT @CurrentStatus = PRStatus, @PRNumber = PRNumber
            FROM PurchaseRequisition
            WHERE PRID = @PRID
            
            SELECT @TotalItems = COUNT(*)
            FROM PurchaseRequisitionDetails
            WHERE PRID = @PRID AND IsActive = 1
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('PR not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus NOT IN ('Draft', 'PR Rejected')
            BEGIN
                RAISERROR('PR cannot be submitted from current status.', 16, 1)
                RETURN
            END
            
            IF @TotalItems = 0
            BEGIN
                RAISERROR('Cannot submit PR without any items.', 16, 1)
                RETURN
            END
            
            -- Update PR status
            UPDATE PurchaseRequisition
            SET PRStatus = 'Submitted',
                PRApprovalStatus = 'Pending Level 1',
                CurrentPRApprovalLevel = 1,
                SubmissionDate = GETDATE(),
                ModifiedDate = GETDATE(),
                ModifiedBy = @SubmittedBy
            WHERE PRID = @PRID
            
            -- Create approval workflow (customize based on amount thresholds)
            DECLARE @EstimatedAmount DECIMAL(18,2)
            SELECT @EstimatedAmount = EstimatedAmount FROM PurchaseRequisition WHERE PRID = @PRID
            
            -- Configure approval levels based on amount
            IF @EstimatedAmount <= 10000
            BEGIN
                -- Low value: Single level approval
                INSERT INTO PRApprovalWorkflow (PRID, ApprovalLevel, ApproverRole, ApprovalStatus)
                VALUES (@PRID, 1, 'Department Head', 'Pending')
            END
            ELSE IF @EstimatedAmount <= 50000
            BEGIN
                -- Medium value: Two level approval
                INSERT INTO PRApprovalWorkflow (PRID, ApprovalLevel, ApproverRole, ApprovalStatus)
                VALUES 
                    (@PRID, 1, 'Department Head', 'Pending'),
                    (@PRID, 2, 'Finance Manager', 'Pending')
            END
            ELSE
            BEGIN
                -- High value: Three level approval
                INSERT INTO PRApprovalWorkflow (PRID, ApprovalLevel, ApproverRole, ApprovalStatus)
                VALUES 
                    (@PRID, 1, 'Department Head', 'Pending'),
                    (@PRID, 2, 'Finance Manager', 'Pending'),
                    (@PRID, 3, 'Director', 'Pending')
            END
            
            -- Add to purchase history
            INSERT INTO PurchaseHistory (
                TransactionType, TransactionID, TransactionNumber, Action, 
                ActionBy, ActionByID, Comments, PreviousStatus, NewStatus
            )
            VALUES (
                'PR', @PRID, @PRNumber, 'Submitted for Approval', 
                @SubmittedBy, @SubmittedByID, @Comments, 
                @CurrentStatus, 'Submitted'
            )
            
        COMMIT TRANSACTION
        
        SELECT 'PR submitted for approval successfully.' AS Message
        
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
-- STORED PROCEDURE: Approve PR
-- =============================================
CREATE PROCEDURE [dbo].[sp_ApprovePR]
    @PRID INT,
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
            
            -- Check if PR exists and is in submitted status
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @CurrentApprovalLevel INT
            DECLARE @PRNumber NVARCHAR(50)
            DECLARE @TotalLevels INT
            
            SELECT 
                @CurrentStatus = PRStatus, 
                @CurrentApprovalLevel = CurrentPRApprovalLevel,
                @PRNumber = PRNumber
            FROM PurchaseRequisition
            WHERE PRID = @PRID
            
            SELECT @TotalLevels = COUNT(*)
            FROM PRApprovalWorkflow
            WHERE PRID = @PRID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('PR not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus != 'Submitted'
            BEGIN
                RAISERROR('PR is not in submitted status.', 16, 1)
                RETURN
            END
            
            -- Check if this approval level is valid
            IF @ApprovalLevel != @CurrentApprovalLevel
            BEGIN
                RAISERROR('This approval level is not currently active.', 16, 1)
                RETURN
            END
            
            -- Update approval workflow
            UPDATE PRApprovalWorkflow
            SET ApprovalStatus = 'Approved',
                ApproverID = @ApproverID,
                ApproverName = @ApproverName,
                ApprovalDate = GETDATE(),
                ApprovalComments = @ApprovalComments
            WHERE PRID = @PRID AND ApprovalLevel = @ApprovalLevel
            
            -- Update PR with approved amount if provided
            IF @ApprovedAmount IS NOT NULL
            BEGIN
                UPDATE PurchaseRequisition
                SET ApprovedAmount = @ApprovedAmount
                WHERE PRID = @PRID
            END
            
            -- Check if this was the last approval level
            IF @ApprovalLevel = @TotalLevels
            BEGIN
                -- Fully approved
                UPDATE PurchaseRequisition
                SET PRStatus = 'PR Approved',
                    PRApprovalStatus = 'Fully Approved',
                    PRApprovalDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE PRID = @PRID
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PR', @PRID, @PRNumber, 'PR Approved', 
                    @ApproverName, @ApproverID, @ApprovalComments, 
                    'Submitted', 'PR Approved', @ApprovalLevel
                )
                
                SELECT 'PR fully approved successfully.' AS Message
            END
            ELSE
            -- Move to next approval level
            BEGIN
                UPDATE PurchaseRequisition
                SET CurrentPRApprovalLevel = @CurrentApprovalLevel + 1,
                    PRApprovalStatus = 'Pending Level ' + CAST(@CurrentApprovalLevel + 1 AS VARCHAR(10)),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE PRID = @PRID
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PR', @PRID, @PRNumber, 'Approved', 
                    @ApproverName, @ApproverID, @ApprovalComments, 
                    'Submitted', 'Pending Level ' + CAST(@CurrentApprovalLevel + 1 AS VARCHAR(10)), 
                    @ApprovalLevel
                )
                
                SELECT 'PR approved. Waiting for next level approval.' AS Message
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
-- STORED PROCEDURE: Reject PR
-- =============================================
CREATE PROCEDURE [dbo].[sp_RejectPR]
    @PRID INT,
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
            
            -- Check if PR exists
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @PRNumber NVARCHAR(50)
            
            SELECT @CurrentStatus = PRStatus, @PRNumber = PRNumber
            FROM PurchaseRequisition
            WHERE PRID = @PRID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('PR not found.', 16, 1)
                RETURN
            END
            
            -- Update approval workflow
            UPDATE PRApprovalWorkflow
            SET ApprovalStatus = 'Rejected',
                ApproverID = @ApproverID,
                ApproverName = @ApproverName,
                ApprovalDate = GETDATE(),
                ApprovalComments = @RejectionReason
            WHERE PRID = @PRID AND ApprovalLevel = @ApprovalLevel
            
            -- Update PR status
            IF @SendBackToDraft = 1
            BEGIN
                UPDATE PurchaseRequisition
                SET PRStatus = 'Draft',
                    PRApprovalStatus = NULL,
                    CurrentPRApprovalLevel = 1,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE PRID = @PRID
                
                -- Delete pending approval workflow entries
                DELETE FROM PRApprovalWorkflow
                WHERE PRID = @PRID AND ApprovalStatus = 'Pending'
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PR', @PRID, @PRNumber, 'Rejected (Sent Back)', 
                    @ApproverName, @ApproverID, @RejectionReason, 
                    @CurrentStatus, 'Draft', @ApprovalLevel
                )
                
                SELECT 'PR rejected and sent back to draft.' AS Message
            END
            ELSE
            BEGIN
                UPDATE PurchaseRequisition
                SET PRStatus = 'PR Rejected',
                    PRApprovalStatus = 'Rejected',
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE PRID = @PRID
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PR', @PRID, @PRNumber, 'Rejected', 
                    @ApproverName, @ApproverID, @RejectionReason, 
                    @CurrentStatus, 'PR Rejected', @ApprovalLevel
                )
                
                SELECT 'PR rejected successfully.' AS Message
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
-- STORED PROCEDURE: Convert PR to PO
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvertPRToPO]
    @PRID INT,
    @SupplierID INT,
    @SupplierName NVARCHAR(200),
    @SupplierCode NVARCHAR(50) = NULL,
    @SupplierContactPerson NVARCHAR(100) = NULL,
    @SupplierEmail NVARCHAR(100) = NULL,
    @SupplierPhone NVARCHAR(20) = NULL,
    @ShippingAddress NVARCHAR(500) = NULL,
    @BillingAddress NVARCHAR(500) = NULL,
    @DeliveryTerms NVARCHAR(500) = NULL,
    @ShippingMethod NVARCHAR(100) = NULL,
    @PaymentTerms NVARCHAR(100) = NULL,
    @PaymentMethod NVARCHAR(50) = NULL,
    @AdvancePayment DECIMAL(18,2) = 0,
    @TaxAmount DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @Currency NVARCHAR(3) = 'USD',
    @ExchangeRate DECIMAL(10,4) = 1,
    @TermsAndConditions NVARCHAR(MAX) = NULL,
    @SpecialInstructions NVARCHAR(MAX) = NULL,
    @ConvertedBy NVARCHAR(100),
    @ConvertedByID INT = NULL,
    @NewPOID INT OUTPUT,
    @PONumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if PR exists and is approved
            DECLARE @PRStatus NVARCHAR(50)
            DECLARE @PRNumber NVARCHAR(50)
            DECLARE @RequiredDate DATE
            DECLARE @TotalAmount DECIMAL(18,2)
            
            SELECT 
                @PRStatus = PRStatus, 
                @PRNumber = PRNumber,
                @RequiredDate = RequiredDate,
                @TotalAmount = ISNULL(ApprovedAmount, EstimatedAmount)
            FROM PurchaseRequisition
            WHERE PRID = @PRID
            
            IF @PRStatus IS NULL
            BEGIN
                RAISERROR('PR not found.', 16, 1)
                RETURN
            END
            
            IF @PRStatus != 'PR Approved'
            BEGIN
                RAISERROR('Only approved PRs can be converted to PO.', 16, 1)
                RETURN
            END
            
            -- Generate PO Number (Format: PO-YYYY-MM-XXXX)
            DECLARE @Year INT = YEAR(GETDATE())
            DECLARE @Month INT = MONTH(GETDATE())
            DECLARE @Sequence INT
            
            SELECT @Sequence = ISNULL(MAX(CAST(RIGHT(PONumber, 4) AS INT)), 0) + 1
            FROM PurchaseOrder
            WHERE PONumber LIKE 'PO-' + CAST(@Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-%'
            
            SET @PONumber = 'PO-' + CAST(@Year AS VARCHAR(4)) + '-' + 
                            RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-' + 
                            RIGHT('0000' + CAST(@Sequence AS VARCHAR(4)), 4)
            
            -- Calculate Net Amount
            DECLARE @NetAmount DECIMAL(18,2)
            SET @NetAmount = @TotalAmount + @TaxAmount - @DiscountAmount
            
            -- Create PO
            INSERT INTO PurchaseOrder (
                PONumber, POType, RequiredDate, PRID, PRNumber,
                SupplierID, SupplierName, SupplierCode, SupplierContactPerson,
                SupplierEmail, SupplierPhone, ShippingAddress, BillingAddress,
                DeliveryTerms, ShippingMethod, TotalAmount, TaxAmount,
                DiscountAmount, NetAmount, Currency, ExchangeRate,
                PaymentTerms, PaymentMethod, AdvancePayment, TermsAndConditions,
                SpecialInstructions, POStatus, CreatedBy
            )
            SELECT
                @PONumber, PRType, @RequiredDate, @PRID, @PRNumber,
                @SupplierID, @SupplierName, @SupplierCode, @SupplierContactPerson,
                @SupplierEmail, @SupplierPhone, @ShippingAddress, @BillingAddress,
                @DeliveryTerms, @ShippingMethod, @TotalAmount, @TaxAmount,
                @DiscountAmount, @NetAmount, @Currency, @ExchangeRate,
                @PaymentTerms, @PaymentMethod, @AdvancePayment, @TermsAndConditions,
                @SpecialInstructions, 'Draft', @ConvertedBy
            FROM PurchaseRequisition
            WHERE PRID = @PRID
            
            SET @NewPOID = SCOPE_IDENTITY()
            
            -- Copy PR Details to PO Details
            INSERT INTO PurchaseOrderDetails (
                POID, LineNumber, PRDetailID, PRID, ItemID, ItemCode,
                ItemName, ItemDescription, OrderedQuantity, UnitOfMeasure,
                UnitPrice, DiscountPercent, DiscountAmount, TaxRate, TaxAmount, LineTotal,
                RequiredDate, Specifications, Remarks
            )
            SELECT
                @NewPOID, LineNumber, PRDetailID, @PRID, ItemID, ItemCode,
                ItemName, ItemDescription, Quantity, UnitOfMeasure,
                ISNULL(ApprovedUnitPrice, EstimatedUnitPrice), 0, 0, 0, 0,
                ISNULL(ApprovedAmount, EstimatedAmount), RequiredDate,
                Specifications, Remarks
            FROM PurchaseRequisitionDetails
            WHERE PRID = @PRID AND IsActive = 1
            
            -- Update PR status
            UPDATE PurchaseRequisition
            SET PRStatus = 'Converted to PO',
                ModifiedDate = GETDATE(),
                ModifiedBy = @ConvertedBy
            WHERE PRID = @PRID
            
            -- Add to purchase history
            INSERT INTO PurchaseHistory (
                TransactionType, TransactionID, TransactionNumber, Action, 
                ActionBy, ActionByID, Comments, PreviousStatus, NewStatus
            )
            VALUES (
                'PO', @NewPOID, @PONumber, 'Created from PR', 
                @ConvertedBy, @ConvertedByID, 
                'PO created from PR: ' + @PRNumber,
                NULL, 'Draft'
            )
            
        COMMIT TRANSACTION
        
        SELECT @NewPOID AS POID, @PONumber AS PONumber, 'PO created successfully from PR.' AS Message
        
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
-- STORED PROCEDURE: Submit PO for Approval
-- =============================================
CREATE PROCEDURE [dbo].[sp_SubmitPOForApproval]
    @POID INT,
    @SubmittedBy NVARCHAR(100),
    @SubmittedByID INT = NULL,
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if PO exists and is in Draft status
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @PONumber NVARCHAR(50)
            DECLARE @NetAmount DECIMAL(18,2)
            
            SELECT @CurrentStatus = POStatus, @PONumber = PONumber, @NetAmount = NetAmount
            FROM PurchaseOrder
            WHERE POID = @POID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('PO not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus NOT IN ('Draft', 'PO Rejected')
            BEGIN
                RAISERROR('PO cannot be submitted from current status.', 16, 1)
                RETURN
            END
            
            -- Update PO status
            UPDATE PurchaseOrder
            SET POStatus = 'Submitted',
                POApprovalStatus = 'Pending Level 1',
                CurrentPOApprovalLevel = 1,
                ModifiedDate = GETDATE(),
                ModifiedBy = @SubmittedBy
            WHERE POID = @POID
            
            -- Create approval workflow based on amount
            IF @NetAmount <= 50000
            BEGIN
                -- Low value: Single level approval
                INSERT INTO POApprovalWorkflow (POID, ApprovalLevel, ApproverRole, ApprovalStatus)
                VALUES (@POID, 1, 'Purchase Manager', 'Pending')
            END
            ELSE IF @NetAmount <= 200000
            BEGIN
                -- Medium value: Two level approval
                INSERT INTO POApprovalWorkflow (POID, ApprovalLevel, ApproverRole, ApprovalStatus)
                VALUES 
                    (@POID, 1, 'Purchase Manager', 'Pending'),
                    (@POID, 2, 'Finance Controller', 'Pending')
            END
            ELSE
            BEGIN
                -- High value: Three level approval
                INSERT INTO POApprovalWorkflow (POID, ApprovalLevel, ApproverRole, ApprovalStatus)
                VALUES 
                    (@POID, 1, 'Purchase Manager', 'Pending'),
                    (@POID, 2, 'Finance Controller', 'Pending'),
                    (@POID, 3, 'CEO', 'Pending')
            END
            
            -- Add to purchase history
            INSERT INTO PurchaseHistory (
                TransactionType, TransactionID, TransactionNumber, Action, 
                ActionBy, ActionByID, Comments, PreviousStatus, NewStatus
            )
            VALUES (
                'PO', @POID, @PONumber, 'Submitted for Approval', 
                @SubmittedBy, @SubmittedByID, @Comments, 
                @CurrentStatus, 'Submitted'
            )
            
        COMMIT TRANSACTION
        
        SELECT 'PO submitted for approval successfully.' AS Message
        
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
-- STORED PROCEDURE: Approve PO
-- =============================================
CREATE PROCEDURE [dbo].[sp_ApprovePO]
    @POID INT,
    @ApprovalLevel INT,
    @ApproverID INT,
    @ApproverName NVARCHAR(100),
    @ApproverRole NVARCHAR(100),
    @ApprovalComments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if PO exists and is in submitted status
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @CurrentApprovalLevel INT
            DECLARE @PONumber NVARCHAR(50)
            DECLARE @TotalLevels INT
            
            SELECT 
                @CurrentStatus = POStatus, 
                @CurrentApprovalLevel = CurrentPOApprovalLevel,
                @PONumber = PONumber
            FROM PurchaseOrder
            WHERE POID = @POID
            
            SELECT @TotalLevels = COUNT(*)
            FROM POApprovalWorkflow
            WHERE POID = @POID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('PO not found.', 16, 1)
                RETURN
            END
            
            IF @CurrentStatus != 'Submitted'
            BEGIN
                RAISERROR('PO is not in submitted status.', 16, 1)
                RETURN
            END
            
            -- Check if this approval level is valid
            IF @ApprovalLevel != @CurrentApprovalLevel
            BEGIN
                RAISERROR('This approval level is not currently active.', 16, 1)
                RETURN
            END
            
            -- Update approval workflow
            UPDATE POApprovalWorkflow
            SET ApprovalStatus = 'Approved',
                ApproverID = @ApproverID,
                ApproverName = @ApproverName,
                ApprovalDate = GETDATE(),
                ApprovalComments = @ApprovalComments
            WHERE POID = @POID AND ApprovalLevel = @ApprovalLevel
            
            -- Check if this was the last approval level
            IF @ApprovalLevel = @TotalLevels
            BEGIN
                -- Fully approved
                UPDATE PurchaseOrder
                SET POStatus = 'PO Approved',
                    POApprovalStatus = 'Fully Approved',
                    ApprovedBy = @ApproverName,
                    ApprovalDate = GETDATE(),
                    IssuedDate = GETDATE(),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE POID = @POID
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PO', @POID, @PONumber, 'PO Approved', 
                    @ApproverName, @ApproverID, @ApprovalComments, 
                    'Submitted', 'PO Approved', @ApprovalLevel
                )
                
                SELECT 'PO fully approved and issued successfully.' AS Message
            END
            ELSE
            -- Move to next approval level
            BEGIN
                UPDATE PurchaseOrder
                SET CurrentPOApprovalLevel = @CurrentApprovalLevel + 1,
                    POApprovalStatus = 'Pending Level ' + CAST(@CurrentApprovalLevel + 1 AS VARCHAR(10)),
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE POID = @POID
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PO', @POID, @PONumber, 'Approved', 
                    @ApproverName, @ApproverID, @ApprovalComments, 
                    'Submitted', 'Pending Level ' + CAST(@CurrentApprovalLevel + 1 AS VARCHAR(10)), 
                    @ApprovalLevel
                )
                
                SELECT 'PO approved. Waiting for next level approval.' AS Message
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
-- STORED PROCEDURE: Reject PO
-- =============================================
CREATE PROCEDURE [dbo].[sp_RejectPO]
    @POID INT,
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
            
            -- Check if PO exists
            DECLARE @CurrentStatus NVARCHAR(50)
            DECLARE @PONumber NVARCHAR(50)
            
            SELECT @CurrentStatus = POStatus, @PONumber = PONumber
            FROM PurchaseOrder
            WHERE POID = @POID
            
            IF @CurrentStatus IS NULL
            BEGIN
                RAISERROR('PO not found.', 16, 1)
                RETURN
            END
            
            -- Update approval workflow
            UPDATE POApprovalWorkflow
            SET ApprovalStatus = 'Rejected',
                ApproverID = @ApproverID,
                ApproverName = @ApproverName,
                ApprovalDate = GETDATE(),
                ApprovalComments = @RejectionReason
            WHERE POID = @POID AND ApprovalLevel = @ApprovalLevel
            
            -- Update PO status
            IF @SendBackToDraft = 1
            BEGIN
                UPDATE PurchaseOrder
                SET POStatus = 'Draft',
                    POApprovalStatus = NULL,
                    CurrentPOApprovalLevel = 1,
                    RejectionReason = @RejectionReason,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE POID = @POID
                
                -- Delete pending approval workflow entries
                DELETE FROM POApprovalWorkflow
                WHERE POID = @POID AND ApprovalStatus = 'Pending'
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PO', @POID, @PONumber, 'Rejected (Sent Back)', 
                    @ApproverName, @ApproverID, @RejectionReason, 
                    @CurrentStatus, 'Draft', @ApprovalLevel
                )
                
                SELECT 'PO rejected and sent back to draft.' AS Message
            END
            ELSE
            BEGIN
                UPDATE PurchaseOrder
                SET POStatus = 'PO Rejected',
                    POApprovalStatus = 'Rejected',
                    RejectionReason = @RejectionReason,
                    ModifiedDate = GETDATE(),
                    ModifiedBy = @ApproverName
                WHERE POID = @POID
                
                -- Add to purchase history
                INSERT INTO PurchaseHistory (
                    TransactionType, TransactionID, TransactionNumber, Action, 
                    ActionBy, ActionByID, Comments, PreviousStatus, NewStatus, ApprovalLevel
                )
                VALUES (
                    'PO', @POID, @PONumber, 'Rejected', 
                    @ApproverName, @ApproverID, @RejectionReason, 
                    @CurrentStatus, 'PO Rejected', @ApprovalLevel
                )
                
                SELECT 'PO rejected successfully.' AS Message
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
-- STORED PROCEDURE: Get PR with Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPRByID]
    @PRID INT
AS
BEGIN
    SET NOCOUNT ON
    
    -- Get PR Master
    SELECT * FROM PurchaseRequisition WHERE PRID = @PRID
    
    -- Get PR Details
    SELECT * FROM PurchaseRequisitionDetails WHERE PRID = @PRID AND IsActive = 1
    
    -- Get PR Approval Workflow
    SELECT * FROM PRApprovalWorkflow WHERE PRID = @PRID ORDER BY ApprovalLevel
    
    -- Get Purchase History
    SELECT TOP 20 * FROM PurchaseHistory 
    WHERE TransactionType = 'PR' AND TransactionID = @PRID
    ORDER BY ActionDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get PO with Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPOByID]
    @POID INT
AS
BEGIN
    SET NOCOUNT ON
    
    -- Get PO Master
    SELECT * FROM PurchaseOrder WHERE POID = @POID
    
    -- Get PO Details
    SELECT * FROM PurchaseOrderDetails WHERE POID = @POID
    
    -- Get PO Approval Workflow
    SELECT * FROM POApprovalWorkflow WHERE POID = @POID ORDER BY ApprovalLevel
    
    -- Get Purchase History
    SELECT TOP 20 * FROM PurchaseHistory 
    WHERE TransactionType = 'PO' AND TransactionID = @POID
    ORDER BY ActionDate DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Pending PO Approvals
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPendingPOApprovals]
    @ApproverRole NVARCHAR(100),
    @ApproverID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        PO.POID, PO.PONumber, PO.PODate, PO.RequiredDate,
        PO.SupplierName, PO.TotalAmount, PO.NetAmount,
        PO.POStatus, PO.POApprovalStatus,
        W.ApprovalLevel, W.ApproverRole,
        PR.PRNumber,
        (SELECT COUNT(*) FROM PurchaseOrderDetails WHERE POID = PO.POID) AS TotalItems
    FROM PurchaseOrder PO
    INNER JOIN POApprovalWorkflow W ON PO.POID = W.POID
    LEFT JOIN PurchaseRequisition PR ON PO.PRID = PR.PRID
    WHERE PO.POStatus = 'Submitted'
        AND W.ApprovalStatus = 'Pending'
        AND W.ApproverRole = @ApproverRole
        AND (W.ApproverID IS NULL OR W.ApproverID = @ApproverID OR @ApproverID IS NULL)
    ORDER BY PO.Priority DESC, PO.PODate ASC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Purchase Summary Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPurchaseSummaryReport]
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    -- PR Summary
    SELECT 
        'PR Summary' AS ReportType,
        COUNT(*) AS TotalCount,
        SUM(CASE WHEN PRStatus = 'PR Approved' THEN 1 ELSE 0 END) AS ApprovedCount,
        SUM(CASE WHEN PRStatus = 'Submitted' THEN 1 ELSE 0 END) AS PendingCount,
        SUM(CASE WHEN PRStatus = 'PR Rejected' THEN 1 ELSE 0 END) AS RejectedCount,
        SUM(EstimatedAmount) AS TotalEstimatedAmount,
        SUM(ApprovedAmount) AS TotalApprovedAmount
    FROM PurchaseRequisition
    WHERE (@FromDate IS NULL OR CAST(PRDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(PRDate AS DATE) <= @ToDate)
    
    -- PO Summary
    SELECT 
        'PO Summary' AS ReportType,
        COUNT(*) AS TotalCount,
        SUM(CASE WHEN POStatus = 'PO Approved' THEN 1 ELSE 0 END) AS ApprovedCount,
        SUM(CASE WHEN POStatus = 'Submitted' THEN 1 ELSE 0 END) AS PendingCount,
        SUM(CASE WHEN POStatus = 'PO Rejected' THEN 1 ELSE 0 END) AS RejectedCount,
        SUM(CASE WHEN POStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedCount,
        SUM(TotalAmount) AS TotalAmount,
        SUM(NetAmount) AS TotalNetAmount
    FROM PurchaseOrder
    WHERE (@FromDate IS NULL OR CAST(PODate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(PODate AS DATE) <= @ToDate)
    
    -- Top Suppliers by PO Value
    SELECT TOP 10
        SupplierName,
        COUNT(*) AS TotalPOs,
        SUM(NetAmount) AS TotalPurchaseValue,
        AVG(NetAmount) AS AveragePOValue
    FROM PurchaseOrder
    WHERE POStatus IN ('PO Approved', 'Completed')
        AND (@FromDate IS NULL OR CAST(PODate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(PODate AS DATE) <= @ToDate)
    GROUP BY SupplierName
    ORDER BY TotalPurchaseValue DESC
END
GO

PRINT 'Purchase Requisition to Purchase Order workflow tables and stored procedures created successfully!'