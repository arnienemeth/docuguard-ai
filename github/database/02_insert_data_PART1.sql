-- ============================================================
-- TEST DATA - PART 1: Employees, Vendors, Documents, Invoices, Contracts, PricingCases
-- Run AFTER 01_create_schema_AZURE.sql
-- ============================================================

-- EMPLOYEES
SET IDENTITY_INSERT dbo.Employees ON;
INSERT INTO dbo.Employees (EmployeeId, Email, FullName, Department, JobTitle, ManagerEmail) VALUES
(1,  'sarah.chen@contoso.com',      'Sarah Chen',        'Enterprise Sales',  'Senior Account Executive', 'david.park@contoso.com'),
(2,  'james.martinez@contoso.com',  'James Martinez',    'Mid-Market Sales',  'Account Manager',          'david.park@contoso.com'),
(3,  'lisa.johnson@contoso.com',    'Lisa Johnson',      'Finance',           'AP Manager',               'michael.brown@contoso.com'),
(4,  'david.park@contoso.com',      'David Park',        'Enterprise Sales',  'VP of Sales',              'ceo@contoso.com'),
(5,  'anna.kowalski@contoso.com',   'Anna Kowalski',     'Procurement',       'Procurement Specialist',   'robert.kim@contoso.com'),
(6,  'robert.kim@contoso.com',      'Robert Kim',        'Procurement',       'Director of Procurement',  'cfo@contoso.com'),
(7,  'michael.brown@contoso.com',   'Michael Brown',     'Finance',           'CFO',                      'ceo@contoso.com'),
(8,  'emily.davis@contoso.com',     'Emily Davis',       'Legal',             'Contract Manager',         'jennifer.white@contoso.com'),
(9,  'jennifer.white@contoso.com',  'Jennifer White',    'Legal',             'General Counsel',          'ceo@contoso.com'),
(10, 'tom.wilson@contoso.com',      'Tom Wilson',        'IT',                'IT Manager',               'cto@contoso.com'),
(11, 'mike.unknown@contoso.com',    'Mike Unknown',      'Enterprise Sales',  'Sales Representative',     'david.park@contoso.com'),
(12, 'alex.overcharge@contoso.com', 'Alex Overcharge',   'New Business',      'Business Development',     'david.park@contoso.com');
SET IDENTITY_INSERT dbo.Employees OFF;

-- VENDORS
SET IDENTITY_INSERT dbo.VendorMaster ON;
INSERT INTO dbo.VendorMaster (VendorId, VendorName, TaxId, Address, RiskRating, IsApproved, AvgPaymentDays, TotalSpendYTD, TotalDocumentsYTD, AnomalyCountYTD, PrimaryContact, ContactEmail) VALUES
(1, 'Acme Industrial Supplies',   '36-4821957', '1420 Industrial Blvd, Suite 300, Chicago, IL 60607',    'A', 1, 28, 106948.40,  12, 0, 'John Smith',     'billing@acme.com'),
(2, 'GlobalTech Solutions Inc.',   '77-3928461', '8900 Technology Park Dr, San Jose, CA 95134',           'A', 1, 25, 155530.00,   8, 0, 'Sarah Lee',      'invoices@globaltech.com'),
(3, 'Pinnacle Office Services',    '13-5738294', '225 Commerce Ave, Floor 12, New York, NY 10017',        'B', 1, 30, 20843.42,    5, 0, 'Mark Davis',     'ar@pinnacle.com'),
(4, 'Meridian Consulting Group',   '74-2918365', '4500 Consulting Way, Austin, TX 78701',                 'B', 1, 32, 298200.00,   6, 0, 'Lisa Wang',      'billing@meridian.com'),
(5, 'NovaParts Manufacturing',     '38-6192847', '7800 Factory Rd, Unit 5, Detroit, MI 48201',            'C', 1, 45, 219875.00,   3, 2, 'Bob Jones',      'ap@novaparts.com'),
(6, 'Shady Deals Trading Co.',     '88-0000001', '999 Questionable Lane, Nowhere, NV 89001',              'D', 0, 0,  275000.00,   1, 1, 'Unknown Contact', 'info@shadydeals.com');
SET IDENTITY_INSERT dbo.VendorMaster OFF;

-- DOCUMENTS (all 16)
SET IDENTITY_INSERT dbo.Documents ON;
INSERT INTO dbo.Documents (DocumentId, ExternalDocId, UploadDate, EmployeeId, VendorId, DocType, FileName, FileSizeKB, BlobUri, ProcessingStatus, ClassificationType, ClassificationScore, ExtractionStatus, AnomalyStatus, FinalAnomalyScore) VALUES
(1,  'INV-2026-001', '2026-01-15T09:30:00', 5, 1, 'Invoice', 'INV-2026-001.pdf', 142, 'https://contosostorage.blob.core.windows.net/documents/2026/01/procurement/invoice/INV-2026-001.pdf', 'Completed', 'Invoice', 0.9847, 'Completed', 'Clean', 12.50),
(2,  'INV-2026-002', '2026-01-22T14:15:00', 10, 2, 'Invoice', 'INV-2026-002.pdf', 156, 'https://contosostorage.blob.core.windows.net/documents/2026/01/it/invoice/INV-2026-002.pdf', 'Completed', 'Invoice', 0.9912, 'Completed', 'Clean', 8.30),
(3,  'INV-2026-003', '2026-02-03T10:45:00', 5, 3, 'Invoice', 'INV-2026-003.pdf', 138, 'https://contosostorage.blob.core.windows.net/documents/2026/02/procurement/invoice/INV-2026-003.pdf', 'Completed', 'Invoice', 0.9789, 'Completed', 'Clean', 15.00),
(4,  'INV-2026-004', '2026-02-10T16:00:00', 3, 4, 'Invoice', 'INV-2026-004.pdf', 128, 'https://contosostorage.blob.core.windows.net/documents/2026/02/finance/invoice/INV-2026-004.pdf', 'Completed', 'Invoice', 0.9856, 'Completed', 'Clean', 10.20),
(5,  'INV-2026-005', '2026-02-15T08:00:00', 5, 1, 'Invoice', 'INV-2026-005_ANOM.pdf', 148, 'https://contosostorage.blob.core.windows.net/documents/2026/02/procurement/invoice/INV-2026-005_ANOM.pdf', 'Completed', 'Invoice', 0.9734, 'Completed', 'Flagged', 78.50),
(6,  'INV-2026-006', '2026-02-18T11:30:00', 6, 5, 'Invoice', 'INV-2026-006_ANOM.pdf', 152, 'https://contosostorage.blob.core.windows.net/documents/2026/02/procurement/invoice/INV-2026-006_ANOM.pdf', 'Completed', 'Invoice', 0.9645, 'Completed', 'Flagged', 88.00),
(7,  'INV-2026-007', '2026-02-20T09:15:00', 3, 6, 'Invoice', 'INV-2026-007_ANOM.pdf', 134, 'https://contosostorage.blob.core.windows.net/documents/2026/02/finance/invoice/INV-2026-007_ANOM.pdf', 'Completed', 'Invoice', 0.8912, 'Completed', 'Flagged', 95.00),
(8,  'INV-2026-008', '2026-02-22T13:45:00', 5, 1, 'Invoice', 'INV-2026-008_ANOM_DUP.pdf', 142, 'https://contosostorage.blob.core.windows.net/documents/2026/02/procurement/invoice/INV-2026-008_ANOM_DUP.pdf', 'Completed', 'Invoice', 0.9847, 'Completed', 'Flagged', 85.00),
(9,  'CON-2026-001', '2026-01-05T10:00:00', 8, 2, 'Contract', 'CON-2026-001.pdf', 210, 'https://contosostorage.blob.core.windows.net/documents/2026/01/legal/contract/CON-2026-001.pdf', 'Completed', 'Contract', 0.9923, 'Completed', 'Clean', 5.00),
(10, 'CON-2026-002', '2026-02-01T14:30:00', 8, 4, 'Contract', 'CON-2026-002.pdf', 225, 'https://contosostorage.blob.core.windows.net/documents/2026/02/legal/contract/CON-2026-002.pdf', 'Completed', 'Contract', 0.9891, 'Completed', 'Clean', 11.00),
(11, 'CON-2026-003', '2026-02-15T09:00:00', 6, 5, 'Contract', 'CON-2026-003_ANOM.pdf', 198, 'https://contosostorage.blob.core.windows.net/documents/2026/02/procurement/contract/CON-2026-003_ANOM.pdf', 'Completed', 'Contract', 0.9456, 'Completed', 'Flagged', 92.00),
(12, 'CON-2026-004', '2026-03-01T08:30:00', 3, 6, 'Contract', 'CON-2026-004_ANOM.pdf', 164, 'https://contosostorage.blob.core.windows.net/documents/2026/03/finance/contract/CON-2026-004_ANOM.pdf', 'Completed', 'Contract', 0.8234, 'Completed', 'Flagged', 96.00),
(13, 'PRC-2026-001', '2026-01-28T11:00:00', 1, NULL, 'PricingCase', 'PRC-2026-001.pdf', 118, 'https://contosostorage.blob.core.windows.net/documents/2026/01/sales/pricingcase/PRC-2026-001.pdf', 'Completed', 'PricingCase', 0.9678, 'Completed', 'Clean', 14.00),
(14, 'PRC-2026-002', '2026-02-05T15:30:00', 2, NULL, 'PricingCase', 'PRC-2026-002.pdf', 124, 'https://contosostorage.blob.core.windows.net/documents/2026/02/sales/pricingcase/PRC-2026-002.pdf', 'Completed', 'PricingCase', 0.9712, 'Completed', 'Clean', 18.50),
(15, 'PRC-2026-003', '2026-02-20T10:00:00', 11, NULL, 'PricingCase', 'PRC-2026-003_ANOM.pdf', 120, 'https://contosostorage.blob.core.windows.net/documents/2026/02/sales/pricingcase/PRC-2026-003_ANOM.pdf', 'Completed', 'PricingCase', 0.9534, 'Completed', 'Flagged', 89.00),
(16, 'PRC-2026-004', '2026-02-25T16:45:00', 12, NULL, 'PricingCase', 'PRC-2026-004_ANOM.pdf', 116, 'https://contosostorage.blob.core.windows.net/documents/2026/02/sales/pricingcase/PRC-2026-004_ANOM.pdf', 'Completed', 'PricingCase', 0.9123, 'Completed', 'Flagged', 91.00);
SET IDENTITY_INSERT dbo.Documents OFF;

-- INVOICES
SET IDENTITY_INSERT dbo.Invoices ON;
INSERT INTO dbo.Invoices (InvoiceId, DocumentId, VendorId, InvoiceNumber, InvoiceDate, DueDate, PaymentTerms, SubtotalAmount, TaxAmount, TotalAmount, POReference, PaymentStatus, LineItems) VALUES
(1, 1, 1, 'INV-2026-001', '2026-01-15', '2026-02-14', 'Net 30', 2195.00, 180.20, 2375.20, 'PO-2026-0042', 'Paid',
 '[{"desc":"Industrial Grade Fasteners (Box of 1000)","qty":5,"price":245.00,"tax":8.5},{"desc":"High-Tensile Steel Bolts M12","qty":10,"price":89.50,"tax":8.5},{"desc":"Shipping & Handling","qty":1,"price":75.00,"tax":0}]'),
(2, 2, 2, 'INV-2026-002', '2026-01-22', '2026-02-21', 'Net 30', 32300.00, 3230.00, 35530.00, 'PO-2026-0058', 'Paid',
 '[{"desc":"Cloud Infrastructure License (Annual)","qty":1,"price":24000.00,"tax":10},{"desc":"Premium Support Package","qty":1,"price":4800.00,"tax":10},{"desc":"Data Migration Service","qty":1,"price":3500.00,"tax":10}]'),
(3, 3, 3, 'INV-2026-003', '2026-02-03', '2026-03-05', 'Net 30', 19249.70, 1593.72, 20843.42, 'PO-2026-0071', 'Approved',
 '[{"desc":"Office Chair - Ergonomic Executive","qty":15,"price":499.99,"tax":8.5},{"desc":"Standing Desk - Adjustable 60in","qty":15,"price":749.99,"tax":8.5},{"desc":"Delivery & Assembly","qty":1,"price":500.00,"tax":0}]'),
(4, 4, 4, 'INV-2026-004', '2026-02-10', '2026-03-12', 'Net 30', 48200.00, 0.00, 48200.00, 'MSA-2025-089', 'Approved',
 '[{"desc":"Strategic Consulting - Phase 1 (160 hrs)","qty":160,"price":275.00,"tax":0},{"desc":"Travel & Expenses (Jan 2026)","qty":1,"price":4200.00,"tax":0}]'),
(5, 5, 1, 'INV-2026-005', '2026-02-15', '2026-02-20', 'Net 5', 227000.00, 18020.00, 245020.00, NULL, 'OnHold',
 '[{"desc":"Industrial Grade Fasteners (Box of 1000)","qty":500,"price":245.00,"tax":8.5},{"desc":"High-Tensile Steel Bolts M12","qty":1000,"price":89.50,"tax":8.5},{"desc":"Expedited Overnight Shipping","qty":1,"price":15000.00,"tax":0}]'),
(6, 6, 5, 'INV-2026-006', '2026-02-18', '2026-02-25', 'Net 7', 205000.00, 14875.00, 219875.00, NULL, 'OnHold',
 '[{"desc":"Custom Machined Parts - Titanium Grade 5","qty":2,"price":87500.00,"tax":8.5},{"desc":"Quality Assurance Certification","qty":1,"price":5000.00,"tax":0},{"desc":"Rush Processing Fee","qty":1,"price":25000.00,"tax":0}]'),
(7, 7, 6, 'INV-2026-007', '2026-02-20', '2026-03-01', 'Net 9', 275000.00, 0.00, 275000.00, NULL, 'OnHold',
 '[{"desc":"Consulting Services - Strategic Advisory","qty":1,"price":150000.00,"tax":0},{"desc":"Market Research Report","qty":1,"price":75000.00,"tax":0},{"desc":"Implementation Support","qty":1,"price":50000.00,"tax":0}]'),
(8, 8, 1, 'INV-2026-001', '2026-02-22', '2026-03-24', 'Net 30', 2195.00, 180.20, 2375.20, 'PO-2026-0042', 'OnHold',
 '[{"desc":"Industrial Grade Fasteners (Box of 1000)","qty":5,"price":245.00,"tax":8.5},{"desc":"High-Tensile Steel Bolts M12","qty":10,"price":89.50,"tax":8.5},{"desc":"Shipping & Handling","qty":1,"price":75.00,"tax":0}]');
SET IDENTITY_INSERT dbo.Invoices OFF;

-- CONTRACTS
SET IDENTITY_INSERT dbo.Contracts ON;
INSERT INTO dbo.Contracts (ContractId, DocumentId, VendorId, ContractNumber, ContractType, EffectiveDate, ExpirationDate, ContractValue, AutoRenewal, RenewalTermMonths, TerminationNoticeDays, Status, Parties, KeyClauses) VALUES
(1, 9, 2, 'CON-2026-001', 'Master Service Agreement', '2026-01-01', '2026-12-31', 120000.00, 1, 12, 30, 'Active',
 '["Contoso Corporation","GlobalTech Solutions Inc."]',
 '["Scope of Services","Compensation - Net 30","Term - 12 months","Confidentiality - 2 years","Limitation of Liability"]'),
(2, 10, 4, 'CON-2026-002', 'Professional Services Agreement', '2026-02-01', '2027-01-31', 250000.00, 0, NULL, 30, 'Active',
 '["Contoso Corporation","Meridian Consulting Group"]',
 '["Scope of Services","Compensation - Net 30","Term - 12 months","Confidentiality - 2 years","Non-Compete - 12 months"]'),
(3, 11, 5, 'CON-2026-003', 'Exclusive Supply Agreement', '2026-02-15', '2031-02-14', 2500000.00, 1, 60, 0, 'Active',
 '["Contoso Corporation","NovaParts Manufacturing"]',
 '["Exclusive Supply - all product lines","Full Upfront Payment - 15 days","5-year term - auto-renew 5 years","NO confidentiality clause","NO limitation of liability"]'),
(4, 12, 6, 'CON-2026-004', 'Consulting Agreement', '2026-03-01', '2026-04-30', 750000.00, 0, NULL, 0, 'Active',
 '["Contoso Corporation","Shady Deals Trading Co."]',
 '["Vague general advisory services","Immediate full payment via wire","2-month term only","MISSING: confidentiality, IP, liability, termination"]');
SET IDENTITY_INSERT dbo.Contracts OFF;

-- PRICING CASES
SET IDENTITY_INSERT dbo.PricingCases ON;
INSERT INTO dbo.PricingCases (CaseId, DocumentId, CaseNumber, RequestorName, Department, SubmitDate, TotalListPrice, TotalProposedPrice, AvgDiscountPercent, MinMarginPercent, ApprovalStatus, Justification, Products) VALUES
(1, 13, 'PRC-2026-001', 'Sarah Chen', 'Enterprise Sales', '2026-01-28', 62000.00, 53300.00, 14.0, 35.0, 'Approved',
 'Strategic account expansion. Customer renewing 3-year commitment with volume discount consistent with enterprise tier.',
 '[{"name":"Enterprise Cloud Suite - Annual","id":"ECS-001","list":50000,"proposed":42500,"margin":35},{"name":"Premium Support Add-On","id":"PSA-001","list":12000,"proposed":10800,"margin":40}]'),
(2, 14, 'PRC-2026-002', 'James Martinez', 'Mid-Market Sales', '2026-02-05', 162000.00, 141550.00, 12.6, 28.0, 'Approved',
 'Competitive displacement. Customer evaluating migration from competitor. 10-15% discount. Margins above 28% threshold.',
 '[{"name":"Manufacturing ERP License","id":"MFG-ERP-01","list":85000,"proposed":72250,"margin":28},{"name":"Implementation Services","id":"IMP-200","list":60000,"proposed":54000,"margin":30},{"name":"Annual Maintenance","id":"MNT-001","list":17000,"proposed":15300,"margin":45}]'),
(3, 15, 'PRC-2026-003', 'Mike Unknown', 'Enterprise Sales', '2026-02-20', 97000.00, 24400.00, 74.8, 3.0, 'Escalated',
 'Customer threatening to leave. Need maximum discount to retain.',
 '[{"name":"Enterprise Cloud Suite - Annual","id":"ECS-001","list":50000,"proposed":15000,"margin":5},{"name":"Premium Support Add-On","id":"PSA-001","list":12000,"proposed":2400,"margin":3},{"name":"Data Analytics Module","id":"DAM-001","list":35000,"proposed":7000,"margin":4}]'),
(4, 16, 'PRC-2026-004', 'Alex Overcharge', 'New Business', '2026-02-25', 7000.00, 37000.00, -428.6, 85.0, 'Escalated',
 'New customer onboarding. Premium pricing for expedited setup.',
 '[{"name":"Basic Cloud Package","id":"BCP-001","list":5000,"proposed":25000,"margin":85},{"name":"Standard Support","id":"SS-001","list":2000,"proposed":12000,"margin":90}]');
SET IDENTITY_INSERT dbo.PricingCases OFF;
