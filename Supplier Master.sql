-- =============================================
-- DATABASE: Supplier Management System
-- DESCRIPTION: Supplier Master table and stored procedures
-- =============================================

USE [YourDatabaseName]
GO

-- =============================================
-- CREATE SUPPLIER MASTER TABLE
-- =============================================
CREATE TABLE [dbo].[SupplierMaster] (
    -- Primary Key
    [SupplierID] INT IDENTITY(1,1) NOT NULL,
    [SupplierCode] NVARCHAR(50) NOT NULL,
    [SupplierName] NVARCHAR(200) NOT NULL,
    [CompanyName] NVARCHAR(200) NULL,
    [SupplierType] NVARCHAR(50) NULL, -- e.g., 'Manufacturer', 'Distributor', 'Wholesaler', 'Retailer'
    
    -- Contact Information
    [ContactPerson] NVARCHAR(100) NULL,
    [ContactTitle] NVARCHAR(50) NULL,
    [Email] NVARCHAR(100) NULL,
    [Phone] NVARCHAR(20) NULL,
    [Mobile] NVARCHAR(20) NULL,
    [Fax] NVARCHAR(20) NULL,
    [Website] NVARCHAR(200) NULL,
    
    -- Address Information
    [AddressLine1] NVARCHAR(200) NULL,
    [AddressLine2] NVARCHAR(200) NULL,
    [City] NVARCHAR(100) NULL,
    [State] NVARCHAR(100) NULL,
    [PostalCode] NVARCHAR(20) NULL,
    [Country] NVARCHAR(100) NULL,
    
    -- Business Details
    [TaxID] NVARCHAR(50) NULL, -- GST/VAT/Tax Identification Number
    [PAN] NVARCHAR(20) NULL, -- Permanent Account Number
    [RegistrationNumber] NVARCHAR(50) NULL, -- Company Registration Number
    [PaymentTerms] NVARCHAR(100) NULL, -- e.g., 'Net 30', 'Net 60', 'COD'
    [CreditLimit] DECIMAL(18,2) NULL,
    [CreditDays] INT NULL,
    [Currency] NVARCHAR(3) NULL DEFAULT 'USD',
    
    -- Banking Information
    [BankName] NVARCHAR(100) NULL,
    [AccountNumber] NVARCHAR(50) NULL,
    [AccountType] NVARCHAR(50) NULL,
    [IFSCode] NVARCHAR(20) NULL,
    [SWIFTCode] NVARCHAR(20) NULL,
    
    -- Categorization
    [CategoryID] INT NULL,
    [CategoryName] NVARCHAR(100) NULL,
    [Industry] NVARCHAR(100) NULL,
    [SupplierRating] DECIMAL(3,2) NULL, -- Rating from 1 to 5
    
    -- Performance Metrics
    [AverageLeadTime] INT NULL, -- In days
    [QualityRating] DECIMAL(3,2) NULL,
    [DeliveryRating] DECIMAL(3,2) NULL,
    [PriceRating] DECIMAL(3,2) NULL,
    [OnTimeDeliveryPercent] DECIMAL(5,2) NULL,
    
    -- Status and Flags
    [IsActive] BIT NOT NULL DEFAULT 1,
    [IsPreferred] BIT NOT NULL DEFAULT 0,
    [IsApproved] BIT NOT NULL DEFAULT 1,
    [IsBlacklisted] BIT NOT NULL DEFAULT 0,
    [BlacklistReason] NVARCHAR(500) NULL,
    
    -- Financial Information
    [OpeningBalance] DECIMAL(18,2) NULL DEFAULT 0,
    [CurrentBalance] DECIMAL(18,2) NULL DEFAULT 0,
    [TotalPurchases] DECIMAL(18,2) NULL DEFAULT 0,
    [TotalPayments] DECIMAL(18,2) NULL DEFAULT 0,
    
    -- Dates
    [RegistrationDate] DATE NOT NULL DEFAULT GETDATE(),
    [ContractStartDate] DATE NULL,
    [ContractEndDate] DATE NULL,
    [LastOrderDate] DATE NULL,
    [LastPaymentDate] DATE NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    
    -- Audit
    [CreatedBy] NVARCHAR(100) NULL,
    [ModifiedBy] NVARCHAR(100) NULL,
    
    -- Additional Fields
    [Notes] NVARCHAR(MAX) NULL,
    [TermsAndConditions] NVARCHAR(MAX) NULL,
    [Attachments] NVARCHAR(500) NULL, -- Path to documents
    
    -- Constraints
    CONSTRAINT PK_SupplierMaster PRIMARY KEY CLUSTERED (SupplierID ASC),
    CONSTRAINT UQ_SupplierMaster_SupplierCode UNIQUE NONCLUSTERED (SupplierCode ASC),
    CONSTRAINT UQ_SupplierMaster_Email UNIQUE NONCLUSTERED (Email ASC),
    CONSTRAINT CK_SupplierMaster_SupplierRating CHECK (SupplierRating >= 1 AND SupplierRating <= 5),
    CONSTRAINT CK_SupplierMaster_QualityRating CHECK (QualityRating >= 1 AND QualityRating <= 5),
    CONSTRAINT CK_SupplierMaster_DeliveryRating CHECK (DeliveryRating >= 1 AND DeliveryRating <= 5),
    CONSTRAINT CK_SupplierMaster_PriceRating CHECK (PriceRating >= 1 AND PriceRating <= 5)
)

GO

-- Create indexes for better performance
CREATE NONCLUSTERED INDEX IX_SupplierMaster_SupplierCode ON SupplierMaster(SupplierCode)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_SupplierName ON SupplierMaster(SupplierName)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_SupplierType ON SupplierMaster(SupplierType)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_IsActive ON SupplierMaster(IsActive)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_City ON SupplierMaster(City)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_Country ON SupplierMaster(Country)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_IsPreferred ON SupplierMaster(IsPreferred)
CREATE NONCLUSTERED INDEX IX_SupplierMaster_SupplierRating ON SupplierMaster(SupplierRating)

GO

-- =============================================
-- STORED PROCEDURE: Insert New Supplier
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertSupplier]
    @SupplierCode NVARCHAR(50),
    @SupplierName NVARCHAR(200),
    @CompanyName NVARCHAR(200) = NULL,
    @SupplierType NVARCHAR(50) = NULL,
    @ContactPerson NVARCHAR(100) = NULL,
    @ContactTitle NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Mobile NVARCHAR(20) = NULL,
    @Fax NVARCHAR(20) = NULL,
    @Website NVARCHAR(200) = NULL,
    @AddressLine1 NVARCHAR(200) = NULL,
    @AddressLine2 NVARCHAR(200) = NULL,
    @City NVARCHAR(100) = NULL,
    @State NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Country NVARCHAR(100) = NULL,
    @TaxID NVARCHAR(50) = NULL,
    @PAN NVARCHAR(20) = NULL,
    @RegistrationNumber NVARCHAR(50) = NULL,
    @PaymentTerms NVARCHAR(100) = NULL,
    @CreditLimit DECIMAL(18,2) = NULL,
    @CreditDays INT = NULL,
    @Currency NVARCHAR(3) = 'USD',
    @BankName NVARCHAR(100) = NULL,
    @AccountNumber NVARCHAR(50) = NULL,
    @AccountType NVARCHAR(50) = NULL,
    @IFSCode NVARCHAR(20) = NULL,
    @SWIFTCode NVARCHAR(20) = NULL,
    @CategoryID INT = NULL,
    @CategoryName NVARCHAR(100) = NULL,
    @Industry NVARCHAR(100) = NULL,
    @SupplierRating DECIMAL(3,2) = NULL,
    @AverageLeadTime INT = NULL,
    @QualityRating DECIMAL(3,2) = NULL,
    @DeliveryRating DECIMAL(3,2) = NULL,
    @PriceRating DECIMAL(3,2) = NULL,
    @OnTimeDeliveryPercent DECIMAL(5,2) = NULL,
    @IsActive BIT = 1,
    @IsPreferred BIT = 0,
    @IsApproved BIT = 1,
    @IsBlacklisted BIT = 0,
    @BlacklistReason NVARCHAR(500) = NULL,
    @OpeningBalance DECIMAL(18,2) = 0,
    @CurrentBalance DECIMAL(18,2) = 0,
    @RegistrationDate DATE = NULL,
    @ContractStartDate DATE = NULL,
    @ContractEndDate DATE = NULL,
    @CreatedBy NVARCHAR(100) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @TermsAndConditions NVARCHAR(MAX) = NULL,
    @Attachments NVARCHAR(500) = NULL,
    @NewSupplierID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if SupplierCode already exists
            IF EXISTS (SELECT 1 FROM SupplierMaster WHERE SupplierCode = @SupplierCode)
            BEGIN
                RAISERROR('Supplier code already exists.', 16, 1)
                RETURN
            END
            
            -- Check if Email already exists
            IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM SupplierMaster WHERE Email = @Email)
            BEGIN
                RAISERROR('Email address already exists.', 16, 1)
                RETURN
            END
            
            -- Set default registration date if not provided
            IF @RegistrationDate IS NULL
                SET @RegistrationDate = GETDATE()
            
            -- Insert new supplier
            INSERT INTO SupplierMaster (
                SupplierCode, SupplierName, CompanyName, SupplierType,
                ContactPerson, ContactTitle, Email, Phone, Mobile, Fax, Website,
                AddressLine1, AddressLine2, City, State, PostalCode, Country,
                TaxID, PAN, RegistrationNumber, PaymentTerms, CreditLimit, CreditDays, Currency,
                BankName, AccountNumber, AccountType, IFSCode, SWIFTCode,
                CategoryID, CategoryName, Industry, SupplierRating,
                AverageLeadTime, QualityRating, DeliveryRating, PriceRating, OnTimeDeliveryPercent,
                IsActive, IsPreferred, IsApproved, IsBlacklisted, BlacklistReason,
                OpeningBalance, CurrentBalance, RegistrationDate, ContractStartDate, ContractEndDate,
                CreatedBy, Notes, TermsAndConditions, Attachments
            )
            VALUES (
                @SupplierCode, @SupplierName, @CompanyName, @SupplierType,
                @ContactPerson, @ContactTitle, @Email, @Phone, @Mobile, @Fax, @Website,
                @AddressLine1, @AddressLine2, @City, @State, @PostalCode, @Country,
                @TaxID, @PAN, @RegistrationNumber, @PaymentTerms, @CreditLimit, @CreditDays, @Currency,
                @BankName, @AccountNumber, @AccountType, @IFSCode, @SWIFTCode,
                @CategoryID, @CategoryName, @Industry, @SupplierRating,
                @AverageLeadTime, @QualityRating, @DeliveryRating, @PriceRating, @OnTimeDeliveryPercent,
                @IsActive, @IsPreferred, @IsApproved, @IsBlacklisted, @BlacklistReason,
                @OpeningBalance, @CurrentBalance, @RegistrationDate, @ContractStartDate, @ContractEndDate,
                @CreatedBy, @Notes, @TermsAndConditions, @Attachments
            )
            
            SET @NewSupplierID = SCOPE_IDENTITY()
            
        COMMIT TRANSACTION
        
        SELECT @NewSupplierID AS SupplierID, 'Supplier inserted successfully.' AS Message
        
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
-- STORED PROCEDURE: Update Supplier
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateSupplier]
    @SupplierID INT,
    @SupplierCode NVARCHAR(50),
    @SupplierName NVARCHAR(200),
    @CompanyName NVARCHAR(200) = NULL,
    @SupplierType NVARCHAR(50) = NULL,
    @ContactPerson NVARCHAR(100) = NULL,
    @ContactTitle NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Mobile NVARCHAR(20) = NULL,
    @Fax NVARCHAR(20) = NULL,
    @Website NVARCHAR(200) = NULL,
    @AddressLine1 NVARCHAR(200) = NULL,
    @AddressLine2 NVARCHAR(200) = NULL,
    @City NVARCHAR(100) = NULL,
    @State NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Country NVARCHAR(100) = NULL,
    @TaxID NVARCHAR(50) = NULL,
    @PAN NVARCHAR(20) = NULL,
    @RegistrationNumber NVARCHAR(50) = NULL,
    @PaymentTerms NVARCHAR(100) = NULL,
    @CreditLimit DECIMAL(18,2) = NULL,
    @CreditDays INT = NULL,
    @Currency NVARCHAR(3) = 'USD',
    @BankName NVARCHAR(100) = NULL,
    @AccountNumber NVARCHAR(50) = NULL,
    @AccountType NVARCHAR(50) = NULL,
    @IFSCode NVARCHAR(20) = NULL,
    @SWIFTCode NVARCHAR(20) = NULL,
    @CategoryID INT = NULL,
    @CategoryName NVARCHAR(100) = NULL,
    @Industry NVARCHAR(100) = NULL,
    @SupplierRating DECIMAL(3,2) = NULL,
    @AverageLeadTime INT = NULL,
    @QualityRating DECIMAL(3,2) = NULL,
    @DeliveryRating DECIMAL(3,2) = NULL,
    @PriceRating DECIMAL(3,2) = NULL,
    @OnTimeDeliveryPercent DECIMAL(5,2) = NULL,
    @IsActive BIT = 1,
    @IsPreferred BIT = 0,
    @IsApproved BIT = 1,
    @IsBlacklisted BIT = 0,
    @BlacklistReason NVARCHAR(500) = NULL,
    @ContractStartDate DATE = NULL,
    @ContractEndDate DATE = NULL,
    @ModifiedBy NVARCHAR(100) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @TermsAndConditions NVARCHAR(MAX) = NULL,
    @Attachments NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if supplier exists
            IF NOT EXISTS (SELECT 1 FROM SupplierMaster WHERE SupplierID = @SupplierID)
            BEGIN
                RAISERROR('Supplier not found.', 16, 1)
                RETURN
            END
            
            -- Check if SupplierCode already exists for another supplier
            IF EXISTS (SELECT 1 FROM SupplierMaster WHERE SupplierCode = @SupplierCode AND SupplierID != @SupplierID)
            BEGIN
                RAISERROR('Supplier code already exists for another supplier.', 16, 1)
                RETURN
            END
            
            -- Check if Email already exists for another supplier
            IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM SupplierMaster WHERE Email = @Email AND SupplierID != @SupplierID)
            BEGIN
                RAISERROR('Email address already exists for another supplier.', 16, 1)
                RETURN
            END
            
            -- Update supplier
            UPDATE SupplierMaster SET
                SupplierCode = @SupplierCode,
                SupplierName = @SupplierName,
                CompanyName = @CompanyName,
                SupplierType = @SupplierType,
                ContactPerson = @ContactPerson,
                ContactTitle = @ContactTitle,
                Email = @Email,
                Phone = @Phone,
                Mobile = @Mobile,
                Fax = @Fax,
                Website = @Website,
                AddressLine1 = @AddressLine1,
                AddressLine2 = @AddressLine2,
                City = @City,
                State = @State,
                PostalCode = @PostalCode,
                Country = @Country,
                TaxID = @TaxID,
                PAN = @PAN,
                RegistrationNumber = @RegistrationNumber,
                PaymentTerms = @PaymentTerms,
                CreditLimit = @CreditLimit,
                CreditDays = @CreditDays,
                Currency = @Currency,
                BankName = @BankName,
                AccountNumber = @AccountNumber,
                AccountType = @AccountType,
                IFSCode = @IFSCode,
                SWIFTCode = @SWIFTCode,
                CategoryID = @CategoryID,
                CategoryName = @CategoryName,
                Industry = @Industry,
                SupplierRating = @SupplierRating,
                AverageLeadTime = @AverageLeadTime,
                QualityRating = @QualityRating,
                DeliveryRating = @DeliveryRating,
                PriceRating = @PriceRating,
                OnTimeDeliveryPercent = @OnTimeDeliveryPercent,
                IsActive = @IsActive,
                IsPreferred = @IsPreferred,
                IsApproved = @IsApproved,
                IsBlacklisted = @IsBlacklisted,
                BlacklistReason = @BlacklistReason,
                ContractStartDate = @ContractStartDate,
                ContractEndDate = @ContractEndDate,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy,
                Notes = @Notes,
                TermsAndConditions = @TermsAndConditions,
                Attachments = @Attachments
            WHERE SupplierID = @SupplierID
            
        COMMIT TRANSACTION
        
        SELECT 'Supplier updated successfully.' AS Message
        
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
-- STORED PROCEDURE: Delete Supplier (Soft Delete)
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteSupplier]
    @SupplierID INT,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Check if supplier exists
            IF NOT EXISTS (SELECT 1 FROM SupplierMaster WHERE SupplierID = @SupplierID)
            BEGIN
                RAISERROR('Supplier not found.', 16, 1)
                RETURN
            END
            
            -- Check if supplier has any active purchase orders or transactions
            -- You may want to add additional checks here based on your business rules
            
            -- Soft delete (set IsActive to 0)
            UPDATE SupplierMaster SET
                IsActive = 0,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE SupplierID = @SupplierID
            
        COMMIT TRANSACTION
        
        SELECT 'Supplier deleted successfully.' AS Message
        
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
-- STORED PROCEDURE: Get Supplier by ID
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSupplierByID]
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        SupplierID, SupplierCode, SupplierName, CompanyName, SupplierType,
        ContactPerson, ContactTitle, Email, Phone, Mobile, Fax, Website,
        AddressLine1, AddressLine2, City, State, PostalCode, Country,
        TaxID, PAN, RegistrationNumber, PaymentTerms, CreditLimit, CreditDays, Currency,
        BankName, AccountNumber, AccountType, IFSCode, SWIFTCode,
        CategoryID, CategoryName, Industry, SupplierRating,
        AverageLeadTime, QualityRating, DeliveryRating, PriceRating, OnTimeDeliveryPercent,
        IsActive, IsPreferred, IsApproved, IsBlacklisted, BlacklistReason,
        OpeningBalance, CurrentBalance, TotalPurchases, TotalPayments,
        RegistrationDate, ContractStartDate, ContractEndDate,
        LastOrderDate, LastPaymentDate, CreatedDate, ModifiedDate,
        CreatedBy, ModifiedBy, Notes, TermsAndConditions, Attachments
    FROM SupplierMaster
    WHERE SupplierID = @SupplierID
END
GO

-- =============================================
-- STORED PROCEDURE: Get All Suppliers (with filters)
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAllSuppliers]
    @IsActive BIT = NULL,
    @SupplierType NVARCHAR(50) = NULL,
    @IsPreferred BIT = NULL,
    @IsApproved BIT = NULL,
    @Country NVARCHAR(100) = NULL,
    @City NVARCHAR(100) = NULL,
    @CategoryID INT = NULL,
    @SearchTerm NVARCHAR(200) = NULL,
    @MinRating DECIMAL(3,2) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortBy NVARCHAR(50) = 'SupplierName',
    @SortOrder NVARCHAR(4) = 'ASC'
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    DECLARE @SQL NVARCHAR(MAX)
    
    -- Build dynamic SQL for sorting
    SET @SQL = '
    SELECT 
        SupplierID, SupplierCode, SupplierName, CompanyName, SupplierType,
        ContactPerson, Email, Phone, Mobile,
        City, State, Country,
        SupplierRating, IsActive, IsPreferred, IsApproved,
        CreditLimit, CurrentBalance,
        COUNT(*) OVER() AS TotalRecords
    FROM SupplierMaster
    WHERE 
        (@IsActive IS NULL OR IsActive = @IsActive)
        AND (@SupplierType IS NULL OR SupplierType = @SupplierType)
        AND (@IsPreferred IS NULL OR IsPreferred = @IsPreferred)
        AND (@IsApproved IS NULL OR IsApproved = @IsApproved)
        AND (@Country IS NULL OR Country = @Country)
        AND (@City IS NULL OR City = @City)
        AND (@CategoryID IS NULL OR CategoryID = @CategoryID)
        AND (@MinRating IS NULL OR SupplierRating >= @MinRating)
        AND (@SearchTerm IS NULL OR 
            SupplierCode LIKE ''%'' + @SearchTerm + ''%'' OR 
            SupplierName LIKE ''%'' + @SearchTerm + ''%'' OR
            CompanyName LIKE ''%'' + @SearchTerm + ''%'' OR
            ContactPerson LIKE ''%'' + @SearchTerm + ''%'' OR
            Email LIKE ''%'' + @SearchTerm + ''%'')
    ORDER BY ' + QUOTENAME(@SortBy) + ' ' + @SortOrder + '
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY'
    
    EXEC sp_executesql @SQL,
        N'@IsActive BIT, @SupplierType NVARCHAR(50), @IsPreferred BIT, @IsApproved BIT,
          @Country NVARCHAR(100), @City NVARCHAR(100), @CategoryID INT,
          @SearchTerm NVARCHAR(200), @MinRating DECIMAL(3,2),
          @Offset INT, @PageSize INT',
        @IsActive, @SupplierType, @IsPreferred, @IsApproved,
        @Country, @City, @CategoryID, @SearchTerm, @MinRating,
        @Offset, @PageSize
END
GO

-- =============================================
-- STORED PROCEDURE: Update Supplier Financials
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateSupplierFinancials]
    @SupplierID INT,
    @PurchaseAmount DECIMAL(18,2) = NULL,
    @PaymentAmount DECIMAL(18,2) = NULL,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @CurrentTotalPurchases DECIMAL(18,2)
            DECLARE @CurrentTotalPayments DECIMAL(18,2)
            DECLARE @CurrentBalance DECIMAL(18,2)
            
            -- Get current financials
            SELECT 
                @CurrentTotalPurchases = ISNULL(TotalPurchases, 0),
                @CurrentTotalPayments = ISNULL(TotalPayments, 0),
                @CurrentBalance = ISNULL(CurrentBalance, 0)
            FROM SupplierMaster
            WHERE SupplierID = @SupplierID
            
            IF @CurrentTotalPurchases IS NULL
            BEGIN
                RAISERROR('Supplier not found.', 16, 1)
                RETURN
            END
            
            -- Update financials
            UPDATE SupplierMaster SET
                TotalPurchases = @CurrentTotalPurchases + ISNULL(@PurchaseAmount, 0),
                TotalPayments = @CurrentTotalPayments + ISNULL(@PaymentAmount, 0),
                CurrentBalance = @CurrentBalance + ISNULL(@PurchaseAmount, 0) - ISNULL(@PaymentAmount, 0),
                LastOrderDate = CASE WHEN @PurchaseAmount > 0 THEN GETDATE() ELSE LastOrderDate END,
                LastPaymentDate = CASE WHEN @PaymentAmount > 0 THEN GETDATE() ELSE LastPaymentDate END,
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE SupplierID = @SupplierID
            
        COMMIT TRANSACTION
        
        SELECT 'Supplier financials updated successfully.' AS Message
        
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
-- STORED PROCEDURE: Update Supplier Ratings
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateSupplierRatings]
    @SupplierID INT,
    @QualityRating DECIMAL(3,2) = NULL,
    @DeliveryRating DECIMAL(3,2) = NULL,
    @PriceRating DECIMAL(3,2) = NULL,
    @OnTimeDeliveryPercent DECIMAL(5,2) = NULL,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            DECLARE @OverallRating DECIMAL(3,2)
            
            -- Calculate overall rating if any rating is provided
            IF @QualityRating IS NOT NULL OR @DeliveryRating IS NOT NULL OR @PriceRating IS NOT NULL
            BEGIN
                DECLARE @Q DECIMAL(3,2) = ISNULL(@QualityRating, 0)
                DECLARE @D DECIMAL(3,2) = ISNULL(@DeliveryRating, 0)
                DECLARE @P DECIMAL(3,2) = ISNULL(@PriceRating, 0)
                DECLARE @Count INT = 0
                
                IF @QualityRating IS NOT NULL SET @Count = @Count + 1
                IF @DeliveryRating IS NOT NULL SET @Count = @Count + 1
                IF @PriceRating IS NOT NULL SET @Count = @Count + 1
                
                IF @Count > 0
                    SET @OverallRating = (@Q + @D + @P) / @Count
            END
            
            -- Update ratings
            UPDATE SupplierMaster SET
                QualityRating = ISNULL(@QualityRating, QualityRating),
                DeliveryRating = ISNULL(@DeliveryRating, DeliveryRating),
                PriceRating = ISNULL(@PriceRating, PriceRating),
                OnTimeDeliveryPercent = ISNULL(@OnTimeDeliveryPercent, OnTimeDeliveryPercent),
                SupplierRating = ISNULL(@OverallRating, SupplierRating),
                ModifiedDate = GETDATE(),
                ModifiedBy = @ModifiedBy
            WHERE SupplierID = @SupplierID
            
        COMMIT TRANSACTION
        
        SELECT 'Supplier ratings updated successfully.' AS Message
        
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
-- STORED PROCEDURE: Get Top Performing Suppliers
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetTopSuppliers]
    @TopCount INT = 10,
    @SortBy NVARCHAR(50) = 'TotalPurchases' -- TotalPurchases, SupplierRating, OnTimeDeliveryPercent
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @SQL NVARCHAR(MAX)
    
    SET @SQL = '
    SELECT TOP(@TopCount)
        SupplierID, SupplierCode, SupplierName, CompanyName,
        SupplierType, ContactPerson, Email, Phone,
        City, Country, SupplierRating, QualityRating,
        DeliveryRating, PriceRating, OnTimeDeliveryPercent,
        TotalPurchases, CurrentBalance, IsPreferred,
        IsActive, IsApproved
    FROM SupplierMaster
    WHERE IsActive = 1 AND IsApproved = 1
    ORDER BY ' + QUOTENAME(@SortBy) + ' DESC'
    
    EXEC sp_executesql @SQL, N'@TopCount INT', @TopCount
END
GO

-- =============================================
-- STORED PROCEDURE: Get Suppliers with Expiring Contracts
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetExpiringContracts]
    @DaysThreshold INT = 30
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        SupplierID, SupplierCode, SupplierName, CompanyName,
        ContactPerson, Email, Phone,
        ContractStartDate, ContractEndDate,
        DATEDIFF(DAY, GETDATE(), ContractEndDate) AS DaysRemaining,
        SupplierRating, IsPreferred
    FROM SupplierMaster
    WHERE IsActive = 1 
        AND ContractEndDate IS NOT NULL
        AND ContractEndDate >= GETDATE()
        AND DATEDIFF(DAY, GETDATE(), ContractEndDate) <= @DaysThreshold
    ORDER BY DaysRemaining ASC
END
GO

-- =============================================
-- STORED PROCEDURE: Get Supplier Summary Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSupplierSummaryReport]
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        COUNT(*) AS TotalSuppliers,
        SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveSuppliers,
        SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS InactiveSuppliers,
        SUM(CASE WHEN IsPreferred = 1 AND IsActive = 1 THEN 1 ELSE 0 END) AS PreferredSuppliers,
        SUM(CASE WHEN IsApproved = 0 THEN 1 ELSE 0 END) AS PendingApproval,
        SUM(CASE WHEN IsBlacklisted = 1 THEN 1 ELSE 0 END) AS BlacklistedSuppliers,
        AVG(CASE WHEN IsActive = 1 THEN SupplierRating ELSE NULL END) AS AvgRating,
        AVG(CASE WHEN IsActive = 1 THEN QualityRating ELSE NULL END) AS AvgQualityRating,
        AVG(CASE WHEN IsActive = 1 THEN DeliveryRating ELSE NULL END) AS AvgDeliveryRating,
        AVG(CASE WHEN IsActive = 1 THEN PriceRating ELSE NULL END) AS AvgPriceRating,
        AVG(OnTimeDeliveryPercent) AS AvgOnTimeDelivery,
        SUM(TotalPurchases) AS TotalPurchasesValue,
        SUM(CurrentBalance) AS TotalOutstandingBalance,
        COUNT(DISTINCT Country) AS CountriesCount,
        COUNT(DISTINCT City) AS CitiesCount,
        COUNT(DISTINCT SupplierType) AS SupplierTypesCount
    FROM SupplierMaster
END
GO

-- =============================================
-- STORED PROCEDURE: Get Suppliers by Performance Category
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSuppliersByPerformance]
    @PerformanceCategory NVARCHAR(20) -- 'Excellent', 'Good', 'Average', 'Poor'
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        SupplierID, SupplierCode, SupplierName,
        SupplierRating, QualityRating, DeliveryRating,
        PriceRating, OnTimeDeliveryPercent,
        TotalPurchases, IsPreferred
    FROM SupplierMaster
    WHERE IsActive = 1
    AND (
        (@PerformanceCategory = 'Excellent' AND SupplierRating >= 4.5)
        OR (@PerformanceCategory = 'Good' AND SupplierRating >= 3.5 AND SupplierRating < 4.5)
        OR (@PerformanceCategory = 'Average' AND SupplierRating >= 2.5 AND SupplierRating < 3.5)
        OR (@PerformanceCategory = 'Poor' AND SupplierRating < 2.5)
    )
    ORDER BY SupplierRating DESC
END
GO

-- =============================================
-- STORED PROCEDURE: Bulk Insert Suppliers
-- =============================================
CREATE PROCEDURE [dbo].[sp_BulkInsertSuppliers]
    @Suppliers XML,
    @CreatedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
            
            -- Insert suppliers from XML
            INSERT INTO SupplierMaster (
                SupplierCode, SupplierName, CompanyName, SupplierType,
                ContactPerson, Email, Phone, Mobile,
                AddressLine1, City, State, Country,
                TaxID, PaymentTerms, CreditLimit, Currency,
                IsActive, IsApproved, CreatedBy
            )
            SELECT
                X.value('@SupplierCode', 'NVARCHAR(50)'),
                X.value('@SupplierName', 'NVARCHAR(200)'),
                X.value('@CompanyName', 'NVARCHAR(200)'),
                X.value('@SupplierType', 'NVARCHAR(50)'),
                X.value('@ContactPerson', 'NVARCHAR(100)'),
                X.value('@Email', 'NVARCHAR(100)'),
                X.value('@Phone', 'NVARCHAR(20)'),
                X.value('@Mobile', 'NVARCHAR(20)'),
                X.value('@AddressLine1', 'NVARCHAR(200)'),
                X.value('@City', 'NVARCHAR(100)'),
                X.value('@State', 'NVARCHAR(100)'),
                X.value('@Country', 'NVARCHAR(100)'),
                X.value('@TaxID', 'NVARCHAR(50)'),
                X.value('@PaymentTerms', 'NVARCHAR(100)'),
                X.value('@CreditLimit', 'DECIMAL(18,2)'),
                X.value('@Currency', 'NVARCHAR(3)'),
                1,
                1,
                @CreatedBy
            FROM @Suppliers.nodes('/Suppliers/Supplier') AS T(X)
            
            DECLARE @InsertedCount INT = @@ROWCOUNT
            
        COMMIT TRANSACTION
        
        SELECT CONVERT(NVARCHAR(10), @InsertedCount) + ' suppliers inserted successfully.' AS Message
        
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

PRINT 'Supplier Master table and stored procedures created successfully!'