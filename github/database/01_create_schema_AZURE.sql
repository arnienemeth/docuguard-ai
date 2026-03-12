-- ============================================================
-- COPILOT STUDIO AI AGENTIC SOLUTION
-- Schema Creation - Azure SQL Compatible
-- ============================================================

-- Drop tables if they exist (reverse dependency order)
DROP TABLE IF EXISTS dbo.ReportHistory;
DROP TABLE IF EXISTS dbo.AlertQueue;
DROP TABLE IF EXISTS dbo.AuditLog;
DROP TABLE IF EXISTS dbo.AnomalyResults;
DROP TABLE IF EXISTS dbo.PricingCases;
DROP TABLE IF EXISTS dbo.Contracts;
DROP TABLE IF EXISTS dbo.Invoices;
DROP TABLE IF EXISTS dbo.Documents;
DROP TABLE IF EXISTS dbo.VendorMaster;
DROP TABLE IF EXISTS dbo.Employees;

-- TABLE 1: Employees
CREATE TABLE dbo.Employees (
    EmployeeId          INT IDENTITY(1,1) PRIMARY KEY,
    AzureADObjectId     NVARCHAR(128)   NULL,
    Email               NVARCHAR(256)   NOT NULL,
    FullName            NVARCHAR(256)   NOT NULL,
    Department          NVARCHAR(128)   NOT NULL,
    JobTitle            NVARCHAR(256)   NULL,
    ManagerEmail        NVARCHAR(256)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_Employees_Email ON dbo.Employees(Email);

-- TABLE 2: VendorMaster
CREATE TABLE dbo.VendorMaster (
    VendorId            INT IDENTITY(1,1) PRIMARY KEY,
    VendorName          NVARCHAR(256)   NOT NULL,
    TaxId               NVARCHAR(20)    NULL,
    Address             NVARCHAR(512)   NULL,
    Country             NVARCHAR(64)    NOT NULL DEFAULT 'US',
    RiskRating          CHAR(1)         NOT NULL DEFAULT 'B',
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

CREATE INDEX IX_VendorMaster_RiskRating ON dbo.VendorMaster(RiskRating);
CREATE INDEX IX_VendorMaster_Name ON dbo.VendorMaster(VendorName);

-- TABLE 3: Documents
CREATE TABLE dbo.Documents (
    DocumentId          INT IDENTITY(1,1) PRIMARY KEY,
    ExternalDocId       NVARCHAR(64)    NOT NULL,
    UploadDate          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    EmployeeId          INT             NOT NULL,
    VendorId            INT             NULL,
    DocType             NVARCHAR(32)    NOT NULL,
    FileName            NVARCHAR(512)   NOT NULL,
    FileSizeKB          INT             NULL,
    BlobUri             NVARCHAR(1024)  NULL,
    ProcessingStatus    NVARCHAR(32)    NOT NULL DEFAULT 'Uploaded',
    ClassificationType  NVARCHAR(64)    NULL,
    ClassificationScore DECIMAL(5,4)    NULL,
    ExtractionStatus    NVARCHAR(32)    NULL,
    AnomalyStatus       NVARCHAR(32)    NOT NULL DEFAULT 'Pending',
    FinalAnomalyScore   DECIMAL(5,2)    NULL,
    ReviewedBy          INT             NULL,
    ReviewedAt          DATETIME2       NULL,
    Notes               NVARCHAR(MAX)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Documents_DocType CHECK (DocType IN ('Invoice', 'Contract', 'PricingCase')),
    CONSTRAINT CK_Documents_ProcessingStatus CHECK (ProcessingStatus IN ('Uploaded', 'Processing', 'Completed', 'Failed')),
    CONSTRAINT CK_Documents_AnomalyStatus CHECK (AnomalyStatus IN ('Pending', 'Clean', 'Flagged', 'Resolved'))
);

CREATE INDEX IX_Documents_DocType ON dbo.Documents(DocType);
CREATE INDEX IX_Documents_AnomalyStatus ON dbo.Documents(AnomalyStatus);
CREATE INDEX IX_Documents_UploadDate ON dbo.Documents(UploadDate DESC);
CREATE INDEX IX_Documents_VendorId ON dbo.Documents(VendorId);
CREATE INDEX IX_Documents_EmployeeId ON dbo.Documents(EmployeeId);
CREATE UNIQUE INDEX UX_Documents_ExternalDocId ON dbo.Documents(ExternalDocId);

-- TABLE 4: Invoices
CREATE TABLE dbo.Invoices (
    InvoiceId           INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    VendorId            INT             NOT NULL,
    InvoiceNumber       NVARCHAR(64)    NOT NULL,
    InvoiceDate         DATE            NOT NULL,
    DueDate             DATE            NOT NULL,
    PaymentTerms        NVARCHAR(32)    NULL,
    Currency            CHAR(3)         NOT NULL DEFAULT 'USD',
    SubtotalAmount      DECIMAL(18,2)   NOT NULL,
    TaxAmount           DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalAmount         DECIMAL(18,2)   NOT NULL,
    LineItems           NVARCHAR(MAX)   NULL,
    POReference         NVARCHAR(64)    NULL,
    PaymentStatus       NVARCHAR(32)    NOT NULL DEFAULT 'Pending',
    ApprovedBy          INT             NULL,
    ApprovedAt          DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Invoices_PaymentStatus CHECK (PaymentStatus IN ('Pending', 'Approved', 'Paid', 'Rejected', 'OnHold'))
);

CREATE INDEX IX_Invoices_VendorId ON dbo.Invoices(VendorId);
CREATE INDEX IX_Invoices_InvoiceDate ON dbo.Invoices(InvoiceDate DESC);
CREATE INDEX IX_Invoices_DueDate ON dbo.Invoices(DueDate);
CREATE INDEX IX_Invoices_DocumentId ON dbo.Invoices(DocumentId);

-- TABLE 5: Contracts
CREATE TABLE dbo.Contracts (
    ContractId          INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    VendorId            INT             NOT NULL,
    ContractNumber      NVARCHAR(64)    NOT NULL,
    ContractType        NVARCHAR(64)    NOT NULL,
    EffectiveDate       DATE            NOT NULL,
    ExpirationDate      DATE            NOT NULL,
    ContractValue       DECIMAL(18,2)   NOT NULL,
    Currency            CHAR(3)         NOT NULL DEFAULT 'USD',
    AutoRenewal         BIT             NOT NULL DEFAULT 0,
    RenewalTermMonths   INT             NULL,
    Parties             NVARCHAR(MAX)   NULL,
    KeyClauses          NVARCHAR(MAX)   NULL,
    TerminationNoticeDays INT           NULL DEFAULT 30,
    Status              NVARCHAR(32)    NOT NULL DEFAULT 'Active',
    RenewalInitiated    BIT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Contracts_Status CHECK (Status IN ('Draft', 'Active', 'Expiring', 'Expired', 'Terminated'))
);

CREATE INDEX IX_Contracts_VendorId ON dbo.Contracts(VendorId);
CREATE INDEX IX_Contracts_ExpirationDate ON dbo.Contracts(ExpirationDate);
CREATE INDEX IX_Contracts_Status ON dbo.Contracts(Status);
CREATE INDEX IX_Contracts_DocumentId ON dbo.Contracts(DocumentId);

-- TABLE 6: PricingCases
CREATE TABLE dbo.PricingCases (
    CaseId              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    CaseNumber          NVARCHAR(64)    NOT NULL,
    RequestorName       NVARCHAR(256)   NOT NULL,
    Department          NVARCHAR(128)   NOT NULL,
    SubmitDate          DATE            NOT NULL,
    Products            NVARCHAR(MAX)   NOT NULL,
    TotalListPrice      DECIMAL(18,2)   NOT NULL,
    TotalProposedPrice  DECIMAL(18,2)   NOT NULL,
    AvgDiscountPercent  DECIMAL(5,2)    NULL,
    MinMarginPercent    DECIMAL(5,2)    NULL,
    Justification       NVARCHAR(MAX)   NULL,
    ApprovalStatus      NVARCHAR(32)    NOT NULL DEFAULT 'Pending',
    ApprovedBy          INT             NULL,
    ApprovedAt          DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_PricingCases_ApprovalStatus CHECK (ApprovalStatus IN ('Pending', 'Approved', 'Rejected', 'Escalated'))
);

CREATE INDEX IX_PricingCases_Department ON dbo.PricingCases(Department);
CREATE INDEX IX_PricingCases_ApprovalStatus ON dbo.PricingCases(ApprovalStatus);
CREATE INDEX IX_PricingCases_DocumentId ON dbo.PricingCases(DocumentId);

-- TABLE 7: AnomalyResults
CREATE TABLE dbo.AnomalyResults (
    ResultId            INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId          INT             NOT NULL,
    DetectionTimestamp  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    StatisticalScore    DECIMAL(5,2)    NULL,
    StatisticalDetails  NVARCHAR(MAX)   NULL,
    RulesScore          DECIMAL(5,2)    NULL,
    TriggeredRules      NVARCHAR(MAX)   NULL,
    RulesDetails        NVARCHAR(MAX)   NULL,
    AIReasoningScore    DECIMAL(5,2)    NULL,
    AIExplanation       NVARCHAR(MAX)   NULL,
    AIRecommendations   NVARCHAR(MAX)   NULL,
    AIConfidence        DECIMAL(5,4)    NULL,
    FinalScore          DECIMAL(5,2)    NOT NULL,
    Severity            NVARCHAR(16)    NOT NULL,
    FlaggedFields       NVARCHAR(MAX)   NULL,
    RiskCategory        NVARCHAR(32)    NULL,
    IsResolved          BIT             NOT NULL DEFAULT 0,
    ResolvedBy          INT             NULL,
    ResolvedAt          DATETIME2       NULL,
    ResolutionNotes     NVARCHAR(MAX)   NULL,
    ResolutionAction    NVARCHAR(64)    NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_AnomalyResults_Severity CHECK (Severity IN ('Critical', 'High', 'Medium', 'Low', 'Clean'))
);

CREATE INDEX IX_AnomalyResults_DocumentId ON dbo.AnomalyResults(DocumentId);
CREATE INDEX IX_AnomalyResults_Severity ON dbo.AnomalyResults(Severity);
CREATE INDEX IX_AnomalyResults_FinalScore ON dbo.AnomalyResults(FinalScore DESC);
CREATE INDEX IX_AnomalyResults_IsResolved ON dbo.AnomalyResults(IsResolved);

-- TABLE 8: AuditLog
CREATE TABLE dbo.AuditLog (
    LogId               BIGINT IDENTITY(1,1) PRIMARY KEY,
    Timestamp           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId              INT             NULL,
    UserEmail           NVARCHAR(256)   NULL,
    Action              NVARCHAR(128)   NOT NULL,
    EntityType          NVARCHAR(64)    NOT NULL,
    EntityId            INT             NULL,
    Details             NVARCHAR(MAX)   NULL,
    IPAddress           NVARCHAR(45)    NULL,
    UserAgent           NVARCHAR(512)   NULL,
    SessionId           NVARCHAR(128)   NULL,
    Source              NVARCHAR(64)    NOT NULL DEFAULT 'WebPortal',
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_AuditLog_Timestamp ON dbo.AuditLog(Timestamp DESC);
CREATE INDEX IX_AuditLog_UserId ON dbo.AuditLog(UserId);
CREATE INDEX IX_AuditLog_EntityType_EntityId ON dbo.AuditLog(EntityType, EntityId);
CREATE INDEX IX_AuditLog_Action ON dbo.AuditLog(Action);

-- TABLE 9: AlertQueue
CREATE TABLE dbo.AlertQueue (
    AlertId             INT IDENTITY(1,1) PRIMARY KEY,
    AnomalyResultId     INT             NOT NULL,
    DocumentId          INT             NOT NULL,
    Severity            NVARCHAR(16)    NOT NULL,
    AlertTitle          NVARCHAR(512)   NOT NULL,
    AlertMessage        NVARCHAR(MAX)   NOT NULL,
    Channels            NVARCHAR(256)   NOT NULL,
    Recipients          NVARCHAR(MAX)   NULL,
    Status              NVARCHAR(32)    NOT NULL DEFAULT 'Pending',
    SentAt              DATETIME2       NULL,
    AcknowledgedBy      INT             NULL,
    AcknowledgedAt      DATETIME2       NULL,
    EscalationLevel     INT             NOT NULL DEFAULT 0,
    NextEscalationAt    DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_AlertQueue_Status CHECK (Status IN ('Pending', 'Sent', 'Acknowledged', 'Resolved', 'Escalated', 'Dismissed'))
);

CREATE INDEX IX_AlertQueue_Status ON dbo.AlertQueue(Status);
CREATE INDEX IX_AlertQueue_Severity ON dbo.AlertQueue(Severity);
CREATE INDEX IX_AlertQueue_DocumentId ON dbo.AlertQueue(DocumentId);

-- TABLE 10: ReportHistory
CREATE TABLE dbo.ReportHistory (
    ReportId            INT IDENTITY(1,1) PRIMARY KEY,
    ReportType          NVARCHAR(64)    NOT NULL,
    ReportTitle         NVARCHAR(512)   NOT NULL,
    RequestedBy         INT             NULL,
    RequestSource       NVARCHAR(64)    NOT NULL DEFAULT 'Scheduled',
    Parameters          NVARCHAR(MAX)   NULL,
    FileBlobUri         NVARCHAR(1024)  NULL,
    FileFormat          NVARCHAR(16)    NOT NULL DEFAULT 'PPTX',
    GenerationStatus    NVARCHAR(32)    NOT NULL DEFAULT 'Pending',
    GenerationTimeMs    INT             NULL,
    DistributedTo       NVARCHAR(MAX)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt         DATETIME2       NULL
);
