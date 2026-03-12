-- ============================================================
-- COPILOT STUDIO AI AGENTIC SOLUTION
-- Database Schema Creation Script
-- Target: Microsoft SQL Server 2022 / Azure SQL
-- ============================================================
-- Run this script FIRST to create all tables, indexes, and constraints.
-- Then run 02_insert_test_data.sql to populate with dummy data.
-- ============================================================

-- Create database (skip if using Azure SQL where DB already exists)
-- CREATE DATABASE DocuGuardAI;
-- GO
-- USE DocuGuardAI;
-- GO

-- ============================================================
-- TABLE 1: Employees (users who upload documents)
-- ============================================================
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
GO

CREATE TABLE dbo.Employees (
    EmployeeId          INT IDENTITY(1,1) PRIMARY KEY,
    AzureADObjectId     NVARCHAR(128)   NULL,           -- Azure AD integration
    Email               NVARCHAR(256)   NOT NULL,
    FullName            NVARCHAR(256)   NOT NULL,
    Department          NVARCHAR(128)   NOT NULL,
    JobTitle            NVARCHAR(256)   NULL,
    ManagerEmail        NVARCHAR(256)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE UNIQUE INDEX UX_Employees_Email ON dbo.Employees(Email);
GO

-- ============================================================
-- TABLE 2: VendorMaster (supplier/vendor reference data)
-- ============================================================
IF OBJECT_ID('dbo.VendorMaster', 'U') IS NOT NULL DROP TABLE dbo.VendorMaster;
GO

CREATE TABLE dbo.VendorMaster (
    VendorId            INT IDENTITY(1,1) PRIMARY KEY,
    VendorName          NVARCHAR(256)   NOT NULL,
    TaxId               NVARCHAR(20)    NULL,
    Address             NVARCHAR(512)   NULL,
    Country             NVARCHAR(64)    NOT NULL DEFAULT 'US',
    RiskRating          CHAR(1)         NOT NULL DEFAULT 'B',    -- A=Low, B=Medium, C=High, D=Critical
    IsApproved          BIT             NOT NULL DEFAULT 1,
    AvgPaymentDays      INT             NULL,
    TotalSpendYTD       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalDocumentsYTD   INT             NOT NULL DEFAULT 0,
    AnomalyCountYTD     INT             NOT NULL DEFAULT 0,
    PrimaryContact      NVARCHAR(256)   NULL,
    ContactEmail        NVARCHAR(256)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_VendorMaster_RiskRating CHECK (RiskRating IN ('A', 'B', 'C', 'D'))
);
GO

CREATE INDEX IX_VendorMaster_RiskRating ON dbo.VendorMaster(RiskRating);
CREATE INDEX IX_VendorMaster_Name ON dbo.VendorMaster(VendorName);
GO

-- ============================================================
-- TABLE 3: Documents (master document registry)
-- ============================================================
IF OBJECT_ID('dbo.Documents', 'U') IS NOT NULL DROP TABLE dbo.Documents;
GO

CREATE TABLE dbo.Documents (
    DocumentId          INT IDENTITY(1,1) PRIMARY KEY,
    ExternalDocId       NVARCHAR(64)    NOT NULL,       -- e.g., INV-2026-001, CON-2026-001
    UploadDate          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    EmployeeId          INT             NOT NULL,
    VendorId            INT             NULL,
    DocType             NVARCHAR(32)    NOT NULL,       -- Invoice, Contract, PricingCase
    FileName            NVARCHAR(512)   NOT NULL,
    FileSizeKB          INT             NULL,
    BlobUri             NVARCHAR(1024)  NULL,           -- Azure Blob Storage URI
    ProcessingStatus    NVARCHAR(32)    NOT NULL DEFAULT 'Uploaded',  -- Uploaded, Processing, Completed, Failed
    ClassificationType  NVARCHAR(64)    NULL,           -- AI-classified doc type
    ClassificationScore DECIMAL(5,4)    NULL,           -- Confidence 0.0000 - 1.0000
    ExtractionStatus    NVARCHAR(32)    NULL,           -- Pending, Completed, Failed
    AnomalyStatus       NVARCHAR(32)    NOT NULL DEFAULT 'Pending',  -- Pending, Clean, Flagged, Resolved
    FinalAnomalyScore   DECIMAL(5,2)   NULL,           -- 0.00 - 100.00
    ReviewedBy          INT             NULL,
    ReviewedAt          DATETIME2       NULL,
    Notes               NVARCHAR(MAX)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_Documents_DocType CHECK (DocType IN ('Invoice', 'Contract', 'PricingCase')),
    CONSTRAINT CK_Documents_ProcessingStatus CHECK (ProcessingStatus IN ('Uploaded', 'Processing', 'Completed', 'Failed')),
    CONSTRAINT CK_Documents_AnomalyStatus CHECK (AnomalyStatus IN ('Pending', 'Clean', 'Flagged', 'Resolved'))
);
GO

CREATE INDEX IX_Documents_DocType ON dbo.Documents(DocType);
CREATE INDEX IX_Documents_AnomalyStatus ON dbo.Documents(AnomalyStatus);
CREATE INDEX IX_Documents_UploadDate ON dbo.Documents(UploadDate DESC);
CREATE INDEX IX_Documents_VendorId ON dbo.Documents(VendorId);
CREATE INDEX IX_Documents_EmployeeId ON dbo.Documents(EmployeeId);
CREATE UNIQUE INDEX UX_Documents_ExternalDocId ON dbo.Documents(ExternalDocId);
GO

-- ============================================================
-- TABLE 4: Invoices (parsed invoice data)
-- ============================================================
IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL DROP TABLE dbo.Invoices;
GO

CREATE TABLE dbo.Invoices (
    InvoiceId           INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    VendorId            INT             NOT NULL,
    InvoiceNumber       NVARCHAR(64)    NOT NULL,
    InvoiceDate         DATE            NOT NULL,
    DueDate             DATE            NOT NULL,
    PaymentTerms        NVARCHAR(32)    NULL,           -- Net 30, Net 60, etc.
    Currency            CHAR(3)         NOT NULL DEFAULT 'USD',
    SubtotalAmount      DECIMAL(18,2)   NOT NULL,
    TaxAmount           DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalAmount         DECIMAL(18,2)   NOT NULL,
    LineItems           NVARCHAR(MAX)   NULL,           -- JSON array of line items
    POReference         NVARCHAR(64)    NULL,
    PaymentStatus       NVARCHAR(32)    NOT NULL DEFAULT 'Pending',  -- Pending, Approved, Paid, Rejected
    ApprovedBy          INT             NULL,
    ApprovedAt          DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_Invoices_PaymentStatus CHECK (PaymentStatus IN ('Pending', 'Approved', 'Paid', 'Rejected', 'OnHold'))
);
GO

CREATE INDEX IX_Invoices_VendorId ON dbo.Invoices(VendorId);
CREATE INDEX IX_Invoices_InvoiceDate ON dbo.Invoices(InvoiceDate DESC);
CREATE INDEX IX_Invoices_DueDate ON dbo.Invoices(DueDate);
CREATE INDEX IX_Invoices_DocumentId ON dbo.Invoices(DocumentId);
GO

-- ============================================================
-- TABLE 5: Contracts (parsed contract data)
-- ============================================================
IF OBJECT_ID('dbo.Contracts', 'U') IS NOT NULL DROP TABLE dbo.Contracts;
GO

CREATE TABLE dbo.Contracts (
    ContractId          INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    VendorId            INT             NOT NULL,
    ContractNumber      NVARCHAR(64)    NOT NULL,
    ContractType        NVARCHAR(64)    NOT NULL,       -- MSA, PSA, NDA, Supply, etc.
    EffectiveDate       DATE            NOT NULL,
    ExpirationDate      DATE            NOT NULL,
    ContractValue       DECIMAL(18,2)   NOT NULL,
    Currency            CHAR(3)         NOT NULL DEFAULT 'USD',
    AutoRenewal         BIT             NOT NULL DEFAULT 0,
    RenewalTermMonths   INT             NULL,
    Parties             NVARCHAR(MAX)   NULL,           -- JSON: parties involved
    KeyClauses          NVARCHAR(MAX)   NULL,           -- JSON: extracted key clauses
    TerminationNoticeDays INT           NULL DEFAULT 30,
    Status              NVARCHAR(32)    NOT NULL DEFAULT 'Active',  -- Draft, Active, Expiring, Expired, Terminated
    RenewalInitiated    BIT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_Contracts_Status CHECK (Status IN ('Draft', 'Active', 'Expiring', 'Expired', 'Terminated'))
);
GO

CREATE INDEX IX_Contracts_VendorId ON dbo.Contracts(VendorId);
CREATE INDEX IX_Contracts_ExpirationDate ON dbo.Contracts(ExpirationDate);
CREATE INDEX IX_Contracts_Status ON dbo.Contracts(Status);
CREATE INDEX IX_Contracts_DocumentId ON dbo.Contracts(DocumentId);
GO

-- ============================================================
-- TABLE 6: PricingCases (pricing case requests)
-- ============================================================
IF OBJECT_ID('dbo.PricingCases', 'U') IS NOT NULL DROP TABLE dbo.PricingCases;
GO

CREATE TABLE dbo.PricingCases (
    CaseId              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    CaseNumber          NVARCHAR(64)    NOT NULL,
    RequestorName       NVARCHAR(256)   NOT NULL,
    Department          NVARCHAR(128)   NOT NULL,
    SubmitDate          DATE            NOT NULL,
    Products            NVARCHAR(MAX)   NOT NULL,       -- JSON array of products with pricing
    TotalListPrice      DECIMAL(18,2)   NOT NULL,
    TotalProposedPrice  DECIMAL(18,2)   NOT NULL,
    AvgDiscountPercent  DECIMAL(5,2)    NULL,
    MinMarginPercent    DECIMAL(5,2)    NULL,
    Justification       NVARCHAR(MAX)   NULL,
    ApprovalStatus      NVARCHAR(32)    NOT NULL DEFAULT 'Pending',  -- Pending, Approved, Rejected, Escalated
    ApprovedBy          INT             NULL,
    ApprovedAt          DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_PricingCases_ApprovalStatus CHECK (ApprovalStatus IN ('Pending', 'Approved', 'Rejected', 'Escalated'))
);
GO

CREATE INDEX IX_PricingCases_Department ON dbo.PricingCases(Department);
CREATE INDEX IX_PricingCases_ApprovalStatus ON dbo.PricingCases(ApprovalStatus);
CREATE INDEX IX_PricingCases_DocumentId ON dbo.PricingCases(DocumentId);
GO

-- ============================================================
-- TABLE 7: AnomalyResults (AI-generated anomaly detection)
-- ============================================================
IF OBJECT_ID('dbo.AnomalyResults', 'U') IS NOT NULL DROP TABLE dbo.AnomalyResults;
GO

CREATE TABLE dbo.AnomalyResults (
    ResultId            INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    DetectionTimestamp  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    -- Stage 1: Statistical
    StatisticalScore    DECIMAL(5,2)    NULL,           -- 0-100
    StatisticalDetails  NVARCHAR(MAX)   NULL,           -- JSON

    -- Stage 2: Business Rules
    RulesScore          DECIMAL(5,2)    NULL,           -- 0-100
    TriggeredRules      NVARCHAR(MAX)   NULL,           -- JSON array of rule IDs
    RulesDetails        NVARCHAR(MAX)   NULL,           -- JSON

    -- Stage 3: AI Reasoning
    AIReasoningScore    DECIMAL(5,2)    NULL,           -- 0-100
    AIExplanation       NVARCHAR(MAX)   NULL,           -- Natural language explanation
    AIRecommendations   NVARCHAR(MAX)   NULL,           -- JSON array of recommended actions
    AIConfidence        DECIMAL(5,4)    NULL,           -- 0.0000 - 1.0000

    -- Final composite
    FinalScore          DECIMAL(5,2)    NOT NULL,       -- Weighted composite: (Stat*0.35 + Rules*0.30 + AI*0.35)
    Severity            NVARCHAR(16)    NOT NULL,       -- Critical, High, Medium, Low, Clean
    FlaggedFields       NVARCHAR(MAX)   NULL,           -- JSON array of field names
    RiskCategory        NVARCHAR(32)    NULL,

    -- Resolution
    IsResolved          BIT             NOT NULL DEFAULT 0,
    ResolvedBy          INT             NULL,
    ResolvedAt          DATETIME2       NULL,
    ResolutionNotes     NVARCHAR(MAX)   NULL,
    ResolutionAction    NVARCHAR(64)    NULL,           -- Approved, Rejected, Escalated, FalsePositive

    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_AnomalyResults_Severity CHECK (Severity IN ('Critical', 'High', 'Medium', 'Low', 'Clean'))
);
GO

CREATE INDEX IX_AnomalyResults_DocumentId ON dbo.AnomalyResults(DocumentId);
CREATE INDEX IX_AnomalyResults_Severity ON dbo.AnomalyResults(Severity);
CREATE INDEX IX_AnomalyResults_FinalScore ON dbo.AnomalyResults(FinalScore DESC);
CREATE INDEX IX_AnomalyResults_IsResolved ON dbo.AnomalyResults(IsResolved);

-- Columnstore index for fast analytical queries
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_AnomalyResults_Analytics
    ON dbo.AnomalyResults (FinalScore, Severity, IsResolved, DetectionTimestamp);
GO

-- ============================================================
-- TABLE 8: AuditLog (comprehensive audit trail)
-- ============================================================
IF OBJECT_ID('dbo.AuditLog', 'U') IS NOT NULL DROP TABLE dbo.AuditLog;
GO

CREATE TABLE dbo.AuditLog (
    LogId               BIGINT IDENTITY(1,1) PRIMARY KEY,
    Timestamp           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId              INT             NULL,
    UserEmail           NVARCHAR(256)   NULL,
    Action              NVARCHAR(128)   NOT NULL,       -- Upload, Process, Flag, Resolve, View, Export, etc.
    EntityType          NVARCHAR(64)    NOT NULL,       -- Document, Invoice, Contract, PricingCase, AnomalyResult
    EntityId            INT             NULL,
    Details             NVARCHAR(MAX)   NULL,           -- JSON with action-specific details
    IPAddress           NVARCHAR(45)    NULL,
    UserAgent           NVARCHAR(512)   NULL,
    SessionId           NVARCHAR(128)   NULL,
    Source              NVARCHAR(64)    NOT NULL DEFAULT 'WebPortal',  -- WebPortal, CopilotChat, PowerAutomate, API
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_AuditLog_Timestamp ON dbo.AuditLog(Timestamp DESC);
CREATE INDEX IX_AuditLog_UserId ON dbo.AuditLog(UserId);
CREATE INDEX IX_AuditLog_EntityType_EntityId ON dbo.AuditLog(EntityType, EntityId);
CREATE INDEX IX_AuditLog_Action ON dbo.AuditLog(Action);
GO

-- ============================================================
-- TABLE 9: AlertQueue (notification/alert management)
-- ============================================================
IF OBJECT_ID('dbo.AlertQueue', 'U') IS NOT NULL DROP TABLE dbo.AlertQueue;
GO

CREATE TABLE dbo.AlertQueue (
    AlertId             INT IDENTITY(1,1) PRIMARY KEY,
    AnomalyResultId     INT             NOT NULL,
    DocumentId          INT             NOT NULL,
    Severity            NVARCHAR(16)    NOT NULL,
    AlertTitle          NVARCHAR(512)   NOT NULL,
    AlertMessage        NVARCHAR(MAX)   NOT NULL,
    Channels            NVARCHAR(256)   NOT NULL,       -- Comma-separated: Slack,Email,Teams,InApp
    Recipients          NVARCHAR(MAX)   NULL,           -- JSON array of recipient emails/channels
    Status              NVARCHAR(32)    NOT NULL DEFAULT 'Pending',  -- Pending, Sent, Acknowledged, Resolved, Escalated
    SentAt              DATETIME2       NULL,
    AcknowledgedBy      INT             NULL,
    AcknowledgedAt      DATETIME2       NULL,
    EscalationLevel     INT             NOT NULL DEFAULT 0,  -- 0=initial, 1=manager, 2=VP, 3=COO
    NextEscalationAt    DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_AlertQueue_Status CHECK (Status IN ('Pending', 'Sent', 'Acknowledged', 'Resolved', 'Escalated', 'Dismissed'))
);
GO

CREATE INDEX IX_AlertQueue_Status ON dbo.AlertQueue(Status);
CREATE INDEX IX_AlertQueue_Severity ON dbo.AlertQueue(Severity);
CREATE INDEX IX_AlertQueue_DocumentId ON dbo.AlertQueue(DocumentId);
GO

-- ============================================================
-- TABLE 10: ReportHistory (generated reports tracking)
-- ============================================================
IF OBJECT_ID('dbo.ReportHistory', 'U') IS NOT NULL DROP TABLE dbo.ReportHistory;
GO

CREATE TABLE dbo.ReportHistory (
    ReportId            INT IDENTITY(1,1) PRIMARY KEY,
    ReportType          NVARCHAR(64)    NOT NULL,       -- WeeklyHealth, AnomalySummary, VendorRisk, InvoiceAnalytics, etc.
    ReportTitle         NVARCHAR(512)   NOT NULL,
    RequestedBy         INT             NULL,
    RequestSource       NVARCHAR(64)    NOT NULL DEFAULT 'Scheduled',  -- Scheduled, CopilotChat, Manual
    Parameters          NVARCHAR(MAX)   NULL,           -- JSON: date range, filters, etc.
    FileBlobUri         NVARCHAR(1024)  NULL,           -- Azure Blob URI of generated report
    FileFormat          NVARCHAR(16)    NOT NULL DEFAULT 'PPTX',
    GenerationStatus    NVARCHAR(32)    NOT NULL DEFAULT 'Pending',  -- Pending, Generating, Completed, Failed
    GenerationTimeMs    INT             NULL,
    DistributedTo       NVARCHAR(MAX)   NULL,           -- JSON array of recipient emails
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt         DATETIME2       NULL
);
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- SP: Get document summary with anomaly info
IF OBJECT_ID('dbo.sp_GetDocumentSummary', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetDocumentSummary;
GO

CREATE PROCEDURE dbo.sp_GetDocumentSummary
    @DocumentId INT = NULL,
    @DocType NVARCHAR(32) = NULL,
    @AnomalyStatus NVARCHAR(32) = NULL,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.DocumentId,
        d.ExternalDocId,
        d.DocType,
        d.FileName,
        d.UploadDate,
        d.ProcessingStatus,
        d.AnomalyStatus,
        d.FinalAnomalyScore,
        e.FullName AS UploadedBy,
        e.Department,
        v.VendorName,
        v.RiskRating AS VendorRiskRating,
        ar.FinalScore AS AnomalyScore,
        ar.Severity AS AnomalySeverity,
        ar.AIExplanation,
        ar.IsResolved
    FROM dbo.Documents d
    LEFT JOIN dbo.Employees e ON d.EmployeeId = e.EmployeeId
    LEFT JOIN dbo.VendorMaster v ON d.VendorId = v.VendorId
    LEFT JOIN dbo.AnomalyResults ar ON d.DocumentId = ar.DocumentId
    WHERE (@DocumentId IS NULL OR d.DocumentId = @DocumentId)
      AND (@DocType IS NULL OR d.DocType = @DocType)
      AND (@AnomalyStatus IS NULL OR d.AnomalyStatus = @AnomalyStatus)
      AND (@DateFrom IS NULL OR CAST(d.UploadDate AS DATE) >= @DateFrom)
      AND (@DateTo IS NULL OR CAST(d.UploadDate AS DATE) <= @DateTo)
    ORDER BY d.UploadDate DESC;
END;
GO

-- SP: Get anomaly dashboard metrics
IF OBJECT_ID('dbo.sp_GetAnomalyDashboard', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAnomalyDashboard;
GO

CREATE PROCEDURE dbo.sp_GetAnomalyDashboard
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Summary counts
    SELECT
        COUNT(*) AS TotalDocuments,
        SUM(CASE WHEN AnomalyStatus = 'Clean' THEN 1 ELSE 0 END) AS CleanDocuments,
        SUM(CASE WHEN AnomalyStatus = 'Flagged' THEN 1 ELSE 0 END) AS FlaggedDocuments,
        SUM(CASE WHEN AnomalyStatus = 'Resolved' THEN 1 ELSE 0 END) AS ResolvedDocuments,
        SUM(CASE WHEN AnomalyStatus = 'Pending' THEN 1 ELSE 0 END) AS PendingDocuments
    FROM dbo.Documents
    WHERE (@DateFrom IS NULL OR CAST(UploadDate AS DATE) >= @DateFrom)
      AND (@DateTo IS NULL OR CAST(UploadDate AS DATE) <= @DateTo);

    -- Severity distribution
    SELECT 
        ar.Severity,
        COUNT(*) AS Count,
        AVG(ar.FinalScore) AS AvgScore
    FROM dbo.AnomalyResults ar
    JOIN dbo.Documents d ON ar.DocumentId = d.DocumentId
    WHERE (@DateFrom IS NULL OR CAST(d.UploadDate AS DATE) >= @DateFrom)
      AND (@DateTo IS NULL OR CAST(d.UploadDate AS DATE) <= @DateTo)
    GROUP BY ar.Severity
    ORDER BY 
        CASE ar.Severity 
            WHEN 'Critical' THEN 1 
            WHEN 'High' THEN 2 
            WHEN 'Medium' THEN 3 
            WHEN 'Low' THEN 4 
            WHEN 'Clean' THEN 5 
        END;

    -- Top flagged vendors
    SELECT TOP 5
        v.VendorName,
        v.RiskRating,
        COUNT(*) AS FlaggedCount,
        AVG(ar.FinalScore) AS AvgAnomalyScore
    FROM dbo.AnomalyResults ar
    JOIN dbo.Documents d ON ar.DocumentId = d.DocumentId
    JOIN dbo.VendorMaster v ON d.VendorId = v.VendorId
    WHERE ar.Severity IN ('Critical', 'High')
    GROUP BY v.VendorName, v.RiskRating
    ORDER BY COUNT(*) DESC;
END;
GO

-- SP: Get vendor risk summary
IF OBJECT_ID('dbo.sp_GetVendorRiskSummary', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetVendorRiskSummary;
GO

CREATE PROCEDURE dbo.sp_GetVendorRiskSummary
    @VendorId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.VendorId,
        v.VendorName,
        v.RiskRating,
        v.IsApproved,
        v.TotalSpendYTD,
        v.TotalDocumentsYTD,
        v.AnomalyCountYTD,
        COUNT(DISTINCT d.DocumentId) AS TotalDocuments,
        SUM(CASE WHEN d.DocType = 'Invoice' THEN 1 ELSE 0 END) AS InvoiceCount,
        SUM(CASE WHEN d.DocType = 'Contract' THEN 1 ELSE 0 END) AS ContractCount,
        SUM(CASE WHEN d.AnomalyStatus = 'Flagged' THEN 1 ELSE 0 END) AS ActiveFlags,
        AVG(ar.FinalScore) AS AvgAnomalyScore,
        MAX(ar.FinalScore) AS MaxAnomalyScore
    FROM dbo.VendorMaster v
    LEFT JOIN dbo.Documents d ON v.VendorId = d.VendorId
    LEFT JOIN dbo.AnomalyResults ar ON d.DocumentId = ar.DocumentId
    WHERE (@VendorId IS NULL OR v.VendorId = @VendorId)
    GROUP BY v.VendorId, v.VendorName, v.RiskRating, v.IsApproved,
             v.TotalSpendYTD, v.TotalDocumentsYTD, v.AnomalyCountYTD
    ORDER BY v.RiskRating DESC, AvgAnomalyScore DESC;
END;
GO

PRINT '========================================';
PRINT 'Schema creation completed successfully!';
PRINT '========================================';
PRINT 'Tables created: 10';
PRINT 'Stored procedures created: 3';
PRINT '';
PRINT 'Next step: Run 02_insert_test_data.sql';
GO
