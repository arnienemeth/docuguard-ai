-- ============================================================
-- TEST DATA - PART 2: AnomalyResults, AlertQueue, AuditLog, ReportHistory
-- Run AFTER 02_insert_data_PART1.sql
-- ============================================================

-- ANOMALY RESULTS - Clean documents
SET IDENTITY_INSERT dbo.AnomalyResults ON;
INSERT INTO dbo.AnomalyResults (ResultId, DocumentId, StatisticalScore, RulesScore, AIReasoningScore, FinalScore, Severity, IsResolved, AIExplanation, FlaggedFields, AIConfidence, TriggeredRules, AIRecommendations) VALUES
(1, 1, 10.0, 8.0, 18.0, 12.50, 'Clean', 1, 'Invoice is within normal parameters. Amount consistent with vendor history. Standard payment terms. Valid PO reference.', '[]', 0.9600, '[]', '["No action required"]'),
(2, 2, 5.0, 6.0, 14.0, 8.30, 'Clean', 1, 'Annual cloud license renewal matches prior year. Amount within expected range. Approved by IT Director.', '[]', 0.9750, '[]', '["No action required"]'),
(3, 3, 12.0, 10.0, 22.0, 15.00, 'Clean', 1, 'Furniture purchase for office expansion. Quantity and pricing align with catalog rates. Valid PO.', '[]', 0.9400, '[]', '["No action required"]'),
(4, 4, 8.0, 5.0, 17.0, 10.20, 'Clean', 1, 'Monthly consulting retainer per existing MSA. Hours and rate match contract terms. T&E within policy.', '[]', 0.9680, '[]', '["No action required"]'),
(5, 9, 3.0, 2.0, 10.0, 5.00, 'Clean', 1, 'Standard MSA with fair terms. All required clauses present. Value within normal range for vendor category.', '[]', 0.9850, '[]', '["No action required"]'),
(6, 10, 8.0, 7.0, 18.0, 11.00, 'Clean', 1, 'Professional services agreement with standard terms. Non-compete clause is reasonable. Value appropriate for scope.', '[]', 0.9500, '[]', '["No action required"]'),
(7, 13, 10.0, 12.0, 19.0, 14.00, 'Clean', 1, 'Standard enterprise discount within tier approval limits. Margins healthy at 35-40%. 3-year commitment justifies discount.', '[]', 0.9550, '[]', '["No action required"]'),
(8, 14, 15.0, 14.0, 26.0, 18.50, 'Clean', 1, 'Competitive displacement pricing. Discounts 10-15% are within policy. All margins above 28% minimum threshold.', '[]', 0.9300, '[]', '["No action required"]');

-- ANOMALY RESULTS - Flagged documents
INSERT INTO dbo.AnomalyResults (ResultId, DocumentId, StatisticalScore, RulesScore, AIReasoningScore, FinalScore, Severity, IsResolved, AIExplanation, FlaggedFields, AIConfidence, TriggeredRules, AIRecommendations) VALUES
(9, 5, 82.0, 75.0, 78.0, 78.50, 'High', 0,
 'ALERT: This invoice from Acme Industrial Supplies shows quantity 100x higher than their 6-month average (typically 5-15 units, now 500-1000). Payment terms shortened from standard Net 30 to Net 5, creating urgency pressure. Shipping costs ($15,000) are extreme for this vendor. Total amount ($245,020) is 103x their average invoice of $2,375. No supervisor approval noted despite exceeding the $50,000 threshold.',
 '["TotalAmount","Quantity","PaymentTerms","ShippingCost"]', 0.9200,
 '["INV-002: Amount exceeds 3x vendor average","INV-001: No matching PO reference"]',
 '["Immediately verify order with department head","Cross-reference with actual inventory needs","Contact vendor to confirm order authenticity","Require VP approval before processing"]'),
(10, 6, 90.0, 88.0, 86.0, 88.00, 'Critical', 0,
 'CRITICAL: Invoice from NovaParts Manufacturing (Risk Rating: C). Two titanium parts at $87,500 each is far outside their normal pricing range. The $25,000 rush fee represents 12% of the order - unusually high. No PO reference provided. Payment terms of Net 7 are abnormally short, suggesting urgency pressure. This vendor has had 2 prior anomalies this year. Combined total of $219,875 requires executive approval.',
 '["TotalAmount","UnitPrice","VendorRiskRating","PaymentTerms","POReference","RushFee"]', 0.9400,
 '["INV-002: Amount exceeds 3x vendor average","INV-003: Vendor risk rating C or below","INV-001: No PO reference"]',
 '["ESCALATE to CFO immediately","Request independent quote for titanium parts","Verify vendor capability for titanium machining","Suspend payment until full investigation"]'),
(11, 7, 98.0, 95.0, 92.0, 95.00, 'Critical', 0,
 'CRITICAL: Invoice from unregistered vendor Shady Deals Trading Co. (Risk Rating: D, NOT APPROVED). This vendor is not in the approved vendor list. Total amount of $275,000 with no supporting documentation, no PO reference, and no detailed notes. Line item descriptions are extremely vague with no deliverable specifications. Payment terms of Net 9 suggest urgency pressure. No tax charged despite being a consulting service. This invoice has multiple red flags consistent with potential fraud.',
 '["VendorApprovalStatus","TotalAmount","VendorRiskRating","LineItemDescriptions","PaymentTerms","POReference","TaxCalculation","Notes"]', 0.9700,
 '["INV-002: Amount exceeds 3x vendor average","INV-003: Vendor risk rating D","INV-001: No PO reference"]',
 '["BLOCK PAYMENT immediately","Report to Compliance team","Investigate who authorized this vendor relationship","Request all supporting documentation","Consider reporting to internal audit"]'),
(12, 8, 90.0, 95.0, 72.0, 85.00, 'Critical', 0,
 'CRITICAL: DUPLICATE INVOICE DETECTED. Invoice number INV-2026-001 was already submitted and paid on 2026-01-15 (Document #1). This is an exact duplicate with the same invoice number, vendor (Acme Industrial Supplies), line items, amounts, and PO reference. The submission date is 2026-02-22, over a month after the original. This is a classic duplicate payment attempt.',
 '["InvoiceNumber","DuplicateOf"]', 0.9900,
 '["INV-001: Duplicate invoice number detected within 12 months"]',
 '["REJECT immediately - confirmed duplicate","Notify AP Manager","Flag for audit trail","Investigate whether this was intentional or accidental"]'),
(13, 11, 95.0, 92.0, 89.0, 92.00, 'Critical', 0,
 'CRITICAL: Contract with NovaParts Manufacturing (Risk Rating: C) has multiple severe issues. Contract value of $2,500,000 is 10x typical for this vendor category. 5-year exclusive supply agreement locks Contoso into single-source dependency. Demands full upfront payment within 15 days. Auto-renewal for successive 5-year periods with no easy termination. Missing critical clauses: no confidentiality, no limitation of liability. Early termination requires paying remaining contract value in full.',
 '["ContractValue","ExclusivityClause","PaymentTerms","AutoRenewal","TermLength","MissingClauses","TerminationPenalty"]', 0.9500,
 '["CON-002: Contract value exceeds department budget by 20%+"]',
 '["REJECT contract immediately","Engage Legal for full review","Negotiate milestone-based payments","Remove exclusivity clause","Add standard protective clauses","Reduce term to 1-2 years"]'),
(14, 12, 98.0, 96.0, 94.0, 96.00, 'Critical', 0,
 'CRITICAL: Contract with unapproved vendor Shady Deals Trading Co. (Risk Rating: D). Vendor is NOT in approved vendor list. $750,000 for only 2 months of vague general advisory services is extreme. Demands immediate full payment via wire transfer before any work begins. Scope is undefined providing no deliverable accountability. Missing ALL standard clauses. This contract has characteristics consistent with potential fraud or money laundering.',
 '["VendorApprovalStatus","VendorRiskRating","ContractValue","TermLength","PaymentTerms","ScopeDefinition","MissingClauses","WireTransferPayment"]', 0.9800,
 '["CON-002: Value exceeds budget","CON-001: Missing standard clauses"]',
 '["BLOCK execution immediately","Report to Compliance and Legal","Investigate who initiated vendor relationship","Flag for potential fraud investigation","Do NOT execute any wire transfers"]'),
(15, 15, 92.0, 90.0, 85.0, 89.00, 'Critical', 0,
 'CRITICAL: Pricing case with extreme discounts far below policy limits. Average discount of 74.8% across all products - standard max is 25%. Minimum margin of 3% is far below the 15% floor. Justification is vague with no supporting evidence. Total proposed revenue of $24,400 vs $97,000 list price results in $72,600 revenue loss.',
 '["DiscountPercent","MarginPercent","Justification","RequestorHistory","RevenueImpact"]', 0.9300,
 '["PRC-001: Below-margin pricing","PRC-002: Extreme discounts exceed tier thresholds"]',
 '["REJECT pricing case","Require documented customer churn evidence","Escalate to VP Sales for review","Propose maximum 25% discount alternative"]'),
(16, 16, 95.0, 88.0, 90.0, 91.00, 'Critical', 0,
 'CRITICAL: Pricing case proposes prices ABOVE list price which is highly unusual and potentially indicates customer overcharging. Basic Cloud Package proposed at $25,000 vs $5,000 list price (400% markup). Standard Support proposed at $12,000 vs $2,000 list price (500% markup). Margins of 85-90% are abnormally high. Justification claims premium pricing for expedited setup but no expedited service exists in the product catalog.',
 '["ProposedPrice","MarginPercent","PriceVsListPrice","Justification","ProductCatalogMismatch"]', 0.9600,
 '["PRC-002: Proposed price exceeds list price"]',
 '["REJECT immediately","Investigate intent - error or deliberate overcharging","Verify correct product codes and pricing","Escalate to Sales Operations"]');
SET IDENTITY_INSERT dbo.AnomalyResults OFF;

-- ALERT QUEUE
SET IDENTITY_INSERT dbo.AlertQueue ON;
INSERT INTO dbo.AlertQueue (AlertId, AnomalyResultId, DocumentId, Severity, AlertTitle, AlertMessage, Channels, Recipients, Status, SentAt, EscalationLevel, NextEscalationAt) VALUES
(1, 9, 5, 'High', 'High-Risk Invoice: Abnormal quantities from Acme Industrial',
 'Invoice INV-2026-005 from Acme Industrial Supplies flagged with anomaly score 78.5. Quantities are 100x vendor average. Payment terms shortened to Net 5. Total: $245,020.00.',
 'Slack,Email', '["robert.kim@contoso.com","anna.kowalski@contoso.com"]', 'Sent', '2026-02-15T08:05:00', 0, '2026-02-15T12:05:00'),
(2, 10, 6, 'Critical', 'CRITICAL: High-risk vendor invoice with extreme pricing',
 'Invoice INV-2026-006 from NovaParts Manufacturing (Risk: C) flagged with anomaly score 88.0. Titanium parts at $87,500 each with $25K rush fee. No PO. Total: $219,875.',
 'Slack,Email,Teams', '["michael.brown@contoso.com","robert.kim@contoso.com","jennifer.white@contoso.com"]', 'Sent', '2026-02-18T11:35:00', 1, '2026-02-18T15:35:00'),
(3, 11, 7, 'Critical', 'CRITICAL: Unapproved vendor - potential fraud indicators',
 'Invoice INV-2026-007 from UNAPPROVED vendor Shady Deals Trading Co. (Risk: D). Vague descriptions, no PO, no documentation. Total: $275,000. POSSIBLE FRAUD.',
 'Slack,Email,Teams,InApp', '["michael.brown@contoso.com","jennifer.white@contoso.com","ceo@contoso.com"]', 'Escalated', '2026-02-20T09:20:00', 2, '2026-02-20T13:20:00'),
(4, 12, 8, 'Critical', 'CRITICAL: Duplicate invoice detected - INV-2026-001',
 'Duplicate invoice INV-2026-001 from Acme Industrial detected. Original paid on 2026-01-15. Duplicate submitted 2026-02-22. Exact match on all fields. Amount: $2,375.20.',
 'Slack,Email', '["lisa.johnson@contoso.com","anna.kowalski@contoso.com"]', 'Sent', '2026-02-22T13:50:00', 0, '2026-02-22T17:50:00'),
(5, 13, 11, 'Critical', 'CRITICAL: Extreme contract terms - NovaParts exclusive supply',
 'Contract CON-2026-003 with NovaParts (Risk: C). $2.5M exclusive 5-year deal. Full upfront payment. Missing standard clauses. Heavily unfavorable terms.',
 'Slack,Email,Teams', '["jennifer.white@contoso.com","michael.brown@contoso.com","robert.kim@contoso.com"]', 'Sent', '2026-02-15T09:10:00', 1, '2026-02-15T13:10:00'),
(6, 14, 12, 'Critical', 'CRITICAL: Unapproved vendor contract - potential fraud',
 'Contract CON-2026-004 with UNAPPROVED Shady Deals Trading Co. (Risk: D). $750K for 2 months of vague advisory. Immediate wire payment. POSSIBLE FRAUD.',
 'Slack,Email,Teams,InApp', '["jennifer.white@contoso.com","michael.brown@contoso.com","ceo@contoso.com"]', 'Escalated', '2026-03-01T08:35:00', 2, '2026-03-01T12:35:00'),
(7, 15, 15, 'Critical', 'CRITICAL: Extreme pricing discounts - 75% average discount',
 'Pricing case PRC-2026-003 proposes 74.8% average discount. Margins of 3-5% are far below 15% minimum. Revenue impact: -$72,600. Weak justification.',
 'Slack,Email,Teams', '["david.park@contoso.com","michael.brown@contoso.com"]', 'Sent', '2026-02-20T10:05:00', 0, '2026-02-20T14:05:00'),
(8, 16, 16, 'Critical', 'CRITICAL: Pricing above list price - possible overcharging',
 'Pricing case PRC-2026-004 proposes 428% markup over list price. $37,000 proposed vs $7,000 list. Possible customer overcharging or data entry error.',
 'Slack,Email', '["david.park@contoso.com","sarah.chen@contoso.com"]', 'Sent', '2026-02-25T16:50:00', 0, '2026-02-25T20:50:00');
SET IDENTITY_INSERT dbo.AlertQueue OFF;

-- AUDIT LOG
INSERT INTO dbo.AuditLog (Timestamp, UserId, UserEmail, Action, EntityType, EntityId, Details, Source) VALUES
('2026-01-15T09:30:00', 5, 'anna.kowalski@contoso.com', 'Upload', 'Document', 1, '{"filename":"INV-2026-001.pdf","docType":"Invoice"}', 'WebPortal'),
('2026-01-15T09:30:45', NULL, NULL, 'Process', 'Document', 1, '{"step":"AIDocumentIntelligence","status":"Completed","confidence":0.9847}', 'PowerAutomate'),
('2026-01-15T09:31:20', NULL, NULL, 'AnomalyCheck', 'Document', 1, '{"score":12.5,"severity":"Clean"}', 'PowerAutomate'),
('2026-01-22T14:15:00', 10, 'tom.wilson@contoso.com', 'Upload', 'Document', 2, '{"filename":"INV-2026-002.pdf","docType":"Invoice"}', 'WebPortal'),
('2026-02-15T08:00:00', 5, 'anna.kowalski@contoso.com', 'Upload', 'Document', 5, '{"filename":"INV-2026-005_ANOM.pdf","docType":"Invoice"}', 'WebPortal'),
('2026-02-15T08:00:50', NULL, NULL, 'Process', 'Document', 5, '{"step":"AIDocumentIntelligence","status":"Completed","confidence":0.9734}', 'PowerAutomate'),
('2026-02-15T08:01:30', NULL, NULL, 'AnomalyCheck', 'Document', 5, '{"score":78.5,"severity":"High","triggeredRules":["INV-002","INV-001"]}', 'PowerAutomate'),
('2026-02-15T08:02:00', NULL, NULL, 'AlertSent', 'AlertQueue', 1, '{"channels":["Slack","Email"],"recipients":["robert.kim@contoso.com"]}', 'PowerAutomate'),
('2026-02-20T09:15:00', 3, 'lisa.johnson@contoso.com', 'Upload', 'Document', 7, '{"filename":"INV-2026-007_ANOM.pdf","docType":"Invoice"}', 'WebPortal'),
('2026-02-20T09:16:00', NULL, NULL, 'AnomalyCheck', 'Document', 7, '{"score":95.0,"severity":"Critical","triggeredRules":["INV-002","INV-003","INV-001"]}', 'PowerAutomate'),
('2026-02-20T09:16:30', NULL, NULL, 'AlertSent', 'AlertQueue', 3, '{"channels":["Slack","Email","Teams","InApp"],"severity":"Critical","escalated":true}', 'PowerAutomate'),
('2026-02-20T09:45:00', 7, 'michael.brown@contoso.com', 'View', 'Document', 7, '{"action":"ViewAnomalyDetails","source":"CopilotChat"}', 'CopilotChat'),
('2026-02-20T10:00:00', 11, 'mike.unknown@contoso.com', 'Upload', 'Document', 15, '{"filename":"PRC-2026-003_ANOM.pdf","docType":"PricingCase"}', 'WebPortal'),
('2026-02-25T16:45:00', 12, 'alex.overcharge@contoso.com', 'Upload', 'Document', 16, '{"filename":"PRC-2026-004_ANOM.pdf","docType":"PricingCase"}', 'WebPortal'),
('2026-03-01T08:30:00', 3, 'lisa.johnson@contoso.com', 'Upload', 'Document', 12, '{"filename":"CON-2026-004_ANOM.pdf","docType":"Contract"}', 'WebPortal'),
('2026-03-01T08:35:00', NULL, NULL, 'AlertSent', 'AlertQueue', 6, '{"channels":["Slack","Email","Teams","InApp"],"severity":"Critical","escalated":true}', 'PowerAutomate');

-- REPORT HISTORY
INSERT INTO dbo.ReportHistory (ReportType, ReportTitle, RequestedBy, RequestSource, Parameters, GenerationStatus, GenerationTimeMs, CompletedAt, FileBlobUri) VALUES
('WeeklyHealth', 'Weekly Document Health Report - Week 3, Jan 2026', NULL, 'Scheduled',
 '{"weekStart":"2026-01-13","weekEnd":"2026-01-19","departments":"all"}', 'Completed', 4200, '2026-01-20T07:00:04',
 'https://contosostorage.blob.core.windows.net/reports/2026/01/WeeklyHealth_W3_2026.pptx'),
('WeeklyHealth', 'Weekly Document Health Report - Week 4, Jan 2026', NULL, 'Scheduled',
 '{"weekStart":"2026-01-20","weekEnd":"2026-01-26","departments":"all"}', 'Completed', 3800, '2026-01-27T07:00:04',
 'https://contosostorage.blob.core.windows.net/reports/2026/01/WeeklyHealth_W4_2026.pptx'),
('AnomalySummary', 'February Anomaly Summary Report', 7, 'CopilotChat',
 '{"dateFrom":"2026-02-01","dateTo":"2026-02-28","severity":"all"}', 'Completed', 6500, '2026-03-01T10:15:07',
 'https://contosostorage.blob.core.windows.net/reports/2026/03/AnomalySummary_Feb2026.pptx'),
('VendorRisk', 'NovaParts Manufacturing - Risk Assessment', 6, 'CopilotChat',
 '{"vendorId":5,"vendorName":"NovaParts Manufacturing"}', 'Completed', 3200, '2026-02-19T14:30:03',
 'https://contosostorage.blob.core.windows.net/reports/2026/02/VendorRisk_NovaParts.pptx');

-- VERIFICATION
SELECT 'Employees' AS TableName, COUNT(*) AS Rows FROM dbo.Employees UNION ALL
SELECT 'VendorMaster', COUNT(*) FROM dbo.VendorMaster UNION ALL
SELECT 'Documents', COUNT(*) FROM dbo.Documents UNION ALL
SELECT 'Invoices', COUNT(*) FROM dbo.Invoices UNION ALL
SELECT 'Contracts', COUNT(*) FROM dbo.Contracts UNION ALL
SELECT 'PricingCases', COUNT(*) FROM dbo.PricingCases UNION ALL
SELECT 'AnomalyResults', COUNT(*) FROM dbo.AnomalyResults UNION ALL
SELECT 'AlertQueue', COUNT(*) FROM dbo.AlertQueue UNION ALL
SELECT 'AuditLog', COUNT(*) FROM dbo.AuditLog UNION ALL
SELECT 'ReportHistory', COUNT(*) FROM dbo.ReportHistory
ORDER BY TableName;
