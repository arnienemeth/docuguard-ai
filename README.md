# 🛡️ DocuGuard AI — Enterprise Document Intelligence & Anomaly Detection

> An AI-powered agentic solution built on the Microsoft technology stack, using **Microsoft Copilot Studio** as the central orchestration layer. The platform automatically detects anomalies in invoices, contracts, and pricing cases, then takes action — sending alerts via email and Slack when warning signs are identified.

![Microsoft Copilot Studio](https://img.shields.io/badge/Microsoft-Copilot_Studio-blue?logo=microsoft)
![Azure SQL](https://img.shields.io/badge/Azure-SQL_Database-0078D4?logo=microsoftazure)
![Power Automate](https://img.shields.io/badge/Power-Automate-0066FF?logo=powerautomate)
![Power Apps](https://img.shields.io/badge/Power-Apps-742774?logo=powerapps)
![Azure Blob Storage](https://img.shields.io/badge/Azure-Blob_Storage-0078D4?logo=microsoftazure)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Anomaly Detection Engine](#anomaly-detection-engine)
- [Project Structure](#project-structure)
- [Setup Guide](#setup-guide)
- [Database Schema](#database-schema)
- [Test Data](#test-data)
- [Copilot Studio Configuration](#copilot-studio-configuration)
- [Power Automate Flows](#power-automate-flows)
- [Power Apps Portal](#power-apps-portal)
- [Demo Scenarios](#demo-scenarios)
- [Screenshots](#screenshots)
- [Roadmap](#roadmap)
- [Author](#author)

---

## Overview

Organizations process thousands of business documents daily — invoices, contracts, and pricing cases. Hidden anomalies such as duplicate invoices, unauthorized vendors, extreme pricing discounts, and unfavorable contract terms can cost millions. Manual review doesn't scale.

**DocuGuard AI** solves this by providing:

- 🤖 **AI-Powered Chatbot** — Natural language interface for querying documents, investigating anomalies, and triggering actions
- 🔍 **Anomaly Detection** — Three-stage detection pipeline (statistical + business rules + AI reasoning) that catches suspicious patterns
- 📧 **Automated Alerts** — Real-time email and Slack notifications when anomalies are detected
- 📊 **Management Portal** — Power Apps dashboard with color-coded document status and anomaly scores
- 🗄️ **Enterprise Data Layer** — Azure SQL Database with comprehensive schema for documents, vendors, anomaly results, and audit logging

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                         │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐ │
│  │  Copilot     │  │  Power Apps  │  │  Microsoft Teams    │ │
│  │  Studio      │  │  Portal      │  │  (Channel Deploy)   │ │
│  │  Chatbot     │  │              │  │                     │ │
│  └──────┬───────┘  └──────┬───────┘  └─────────┬───────────┘ │
└─────────┼─────────────────┼────────────────────┼─────────────┘
          │                 │                    │
┌─────────┼─────────────────┼────────────────────┼─────────────┐
│         │        ORCHESTRATION LAYER           │             │
│  ┌──────┴──────────────────┴────────────────────┴──────────┐ │
│  │              Power Automate Cloud Flows                  │ │
│  │  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐  │ │
│  │  │ Email Alert  │  │ Slack Alert   │  │ Report Gen   │  │ │
│  │  │ Flow         │  │ Flow          │  │ Flow         │  │ │
│  │  └──────────────┘  └───────────────┘  └──────────────┘  │ │
│  └─────────────────────────┬────────────────────────────────┘ │
└────────────────────────────┼─────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────┐
│                    INTELLIGENCE LAYER                         │
│  ┌─────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │ Azure AI        │  │ Azure Anomaly  │  │ Azure OpenAI │  │
│  │ Document        │  │ Detector       │  │ GPT-4o       │  │
│  │ Intelligence    │  │                │  │              │  │
│  └─────────────────┘  └────────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │ Azure SQL       │  │ Azure Blob     │  │ Dataverse    │  │
│  │ Database        │  │ Storage        │  │              │  │
│  │ (Serverless)    │  │ (Documents)    │  │              │  │
│  └─────────────────┘  └────────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **AI & Chatbot** | Microsoft Copilot Studio | Conversational AI agent with plugins, topics, and generative AI |
| **AI Services** | Azure OpenAI (GPT-4o) | Contextual reasoning, natural language explanations |
| **AI Services** | Azure AI Document Intelligence | PDF extraction and document classification |
| **AI Services** | Azure Anomaly Detector | Statistical anomaly detection on time-series data |
| **Application** | Power Apps (Canvas) | Document management portal with dashboard |
| **Automation** | Power Automate | Event-driven workflows for alerts and reporting |
| **Database** | Azure SQL Database (Serverless) | Primary relational data store |
| **Storage** | Azure Blob Storage | Raw document file storage (PDFs) |
| **Communication** | Slack (Webhooks) | Real-time team alert notifications |
| **Communication** | Exchange Online / Outlook | Formal email alert notifications |
| **Identity** | Microsoft Entra ID | SSO authentication and RBAC |

---

## Features

### 🤖 AI Chatbot (Copilot Studio)
- Natural language queries against live SQL data
- Anomaly investigation with AI-generated explanations
- Vendor risk analysis with risk ratings and spend data
- Proactive action suggestions (escalate, block payment, investigate)
- Direct integration with Power Automate for automated actions
- Multi-turn conversation context management

### 🔍 Anomaly Detection Engine
- **Stage 1: Statistical Analysis** — Azure Anomaly Detector identifies outliers against historical baselines
- **Stage 2: Business Rules** — Deterministic rules for duplicate detection, threshold breaches, vendor risk
- **Stage 3: AI Reasoning** — GPT-4o contextual analysis with confidence scoring and natural language explanations

### 📧 Automated Alerting
- **Email alerts** — HTML-formatted anomaly notifications with severity, document details, and recommended actions
- **Slack alerts** — Real-time channel notifications for team awareness
- **Severity-based routing** — Critical → Slack + Email + Teams; High → Slack + Email; Medium → Email only

### 📊 Power Apps Portal
- Document gallery with color-coded anomaly status (Red = Flagged, Green = Clean)
- Live dashboard metrics (Total documents, Clean, Flagged, Pending counts)
- Document detail view with all metadata
- Connected to Azure SQL via direct connector

---

## Anomaly Detection Engine

The system uses a three-stage pipeline with a weighted composite scoring model:

```
Final Score = (Statistical × 0.35) + (Rules × 0.30) + (AI Reasoning × 0.35)
```

| Severity | Score Range | Action |
|----------|------------|--------|
| 🔴 Critical | ≥ 85 | Immediate block + Slack + Email + Teams escalation |
| 🟠 High | 70–84 | Slack + Email notification, manual review required |
| 🟡 Medium | 50–69 | Email notification |
| 🔵 Low | 30–49 | In-app notification only |
| ✅ Clean | < 30 | No action, logged for audit |

### Business Rules Implemented

| Rule ID | Rule Name | Condition | Severity |
|---------|-----------|-----------|----------|
| INV-001 | Duplicate Invoice Detection | Invoice number + vendor exists in past 12 months | Critical |
| INV-002 | Amount Threshold Breach | Invoice total exceeds 3x vendor's 6-month average | High |
| INV-003 | Vendor Risk Escalation | Invoice from vendor with risk rating C or D | High |
| CON-001 | Expiring Contract Alert | Contract expiration within 60 days, no renewal | Medium |
| CON-002 | Value Threshold Exceeded | Contract value exceeds department budget by 20%+ | High |
| PRC-001 | Below-Margin Pricing | Proposed price yields margin below 15% minimum | Critical |
| PRC-002 | Competitive Undercut Alert | Proposed price 30%+ below competitor benchmark | Medium |

---

## Project Structure

```
docuguard-ai/
│
├── README.md                              # This file
├── docs/
│   └── Copilot_Studio_AI_Agentic_Solution.docx  # Full project documentation
│
├── database/
│   ├── 01_create_schema_AZURE.sql         # Azure SQL table creation (10 tables)
│   ├── 02_insert_data_PART1.sql           # Test data: employees, vendors, documents
│   └── 03_insert_data_PART2.sql           # Test data: anomaly results, alerts, audit log
│
├── documents/
│   ├── invoices/
│   │   ├── INV-2026-001.pdf               # Normal invoice — Acme Industrial
│   │   ├── INV-2026-002.pdf               # Normal invoice — GlobalTech
│   │   ├── INV-2026-003.pdf               # Normal invoice — Pinnacle Office
│   │   ├── INV-2026-004.pdf               # Normal invoice — Meridian Consulting
│   │   ├── INV-2026-005_ANOM.pdf          # ⚠ ANOMALY: 100x quantity, short terms
│   │   ├── INV-2026-006_ANOM.pdf          # ⚠ ANOMALY: High-risk vendor, extreme price
│   │   ├── INV-2026-007_ANOM.pdf          # ⚠ ANOMALY: Unapproved vendor, possible fraud
│   │   └── INV-2026-008_ANOM_DUP.pdf      # ⚠ ANOMALY: Duplicate of INV-2026-001
│   ├── contracts/
│   │   ├── CON-2026-001.pdf               # Normal contract — GlobalTech MSA
│   │   ├── CON-2026-002.pdf               # Normal contract — Meridian PSA
│   │   ├── CON-2026-003_ANOM.pdf          # ⚠ ANOMALY: $2.5M exclusive, upfront payment
│   │   └── CON-2026-004_ANOM.pdf          # ⚠ ANOMALY: Unapproved vendor, vague scope
│   └── pricing_cases/
│       ├── PRC-2026-001.pdf               # Normal pricing case — standard discount
│       ├── PRC-2026-002.pdf               # Normal pricing case — competitive displacement
│       ├── PRC-2026-003_ANOM.pdf          # ⚠ ANOMALY: 75% discount, 3% margin
│       └── PRC-2026-004_ANOM.pdf          # ⚠ ANOMALY: Price ABOVE list price
│
├── copilot-studio/
│   ├── agent-instructions.md              # Copilot Studio agent persona & instructions
│   └── knowledge-sources.md               # Knowledge source configuration guide
│
├── power-automate/
│   ├── email-alert-flow.md                # Email alert flow configuration
│   └── slack-alert-flow.md                # Slack alert flow configuration
│
├── power-apps/
│   └── portal-configuration.md            # Power Apps portal setup guide
│
└── screenshots/
    └── (add your screenshots here)
```

---

## Setup Guide

### Prerequisites
- Azure subscription (free trial works)
- Microsoft 365 account with Power Platform access
- Microsoft Copilot Studio license (trial available)
- Slack workspace (for Slack alert integration)

### Step 1: Azure SQL Database

1. Create an Azure SQL Database (Serverless, General Purpose)
   - Server name: `docuguard-sql-server`
   - Database name: `DocuGuardAI`
   - Compute: Serverless, Gen5, 1 vCore
   - Backup: Locally-redundant
   
2. Configure networking:
   - Public endpoint enabled
   - Allow Azure services access
   - Add your client IP

3. Run the SQL scripts in order:
```bash
# 1. Create all tables and indexes
01_create_schema_AZURE.sql

# 2. Load reference data (employees, vendors, documents, invoices, contracts)
02_insert_data_PART1.sql

# 3. Load anomaly results, alerts, audit log, report history
03_insert_data_PART2.sql
```

4. Verify with:
```sql
SELECT 'Documents' AS T, COUNT(*) AS Rows FROM dbo.Documents UNION ALL
SELECT 'Invoices', COUNT(*) FROM dbo.Invoices UNION ALL
SELECT 'AnomalyResults', COUNT(*) FROM dbo.AnomalyResults UNION ALL
SELECT 'VendorMaster', COUNT(*) FROM dbo.VendorMaster;
-- Expected: Documents=16, Invoices=8, AnomalyResults=16, VendorMaster=6
```

### Step 2: Azure Blob Storage

1. Create a Storage Account (Standard, LRS)
2. Create a container named `documents`
3. Upload all 16 PDFs to `documents/2026/uploads/`

### Step 3: Copilot Studio Agent

1. Go to [copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)
2. Create new agent named "DocuGuard AI"
3. Paste the agent instructions (see `copilot-studio/agent-instructions.md`)
4. Add Azure SQL as knowledge source — connect 6 tables:
   - Documents, Invoices, Contracts, PricingCases, AnomalyResults, VendorMaster
5. Add Power Automate flows as Tools (see Step 4)

### Step 4: Power Automate Flows

**Email Alert Flow:**
1. Trigger: "When an agent calls the flow"
2. Inputs: DocumentId, AlertTitle, AlertMessage, Severity, RecipientEmail
3. Action: Send an email (V2) with HTML template
4. Response: Confirm email sent

**Slack Alert Flow:**
1. Trigger: "When an agent calls the flow"
2. Inputs: DocumentId, AlertTitle, AlertMessage, Severity
3. Action: Post message (V2) to Slack channel
4. Response: Confirm Slack message posted

### Step 5: Power Apps Portal

1. Create Canvas App from data source (Azure SQL — Documents table)
2. Add VendorMaster, AnomalyResults, Employees as additional data sources
3. Customize header, gallery layout, and color-coded status fields

---

## Database Schema

### Entity Relationship Overview

```
Employees ──────────┐
                     │ (EmployeeId)
VendorMaster ───┐   ├──→ Documents ──→ AnomalyResults
                │   │         │              │
                │   │         ├──→ Invoices   ├──→ AlertQueue
                │   │         ├──→ Contracts  │
                │(VendorId)   ├──→ PricingCases
                └───┘         │
                              └──→ AuditLog
                              
ReportHistory (standalone - tracks generated reports)
```

### Tables Summary

| Table | Rows | Purpose |
|-------|------|---------|
| Employees | 12 | System users who upload and review documents |
| VendorMaster | 6 | Vendor registry with risk ratings (A through D) |
| Documents | 16 | Master document registry with processing status |
| Invoices | 8 | Parsed invoice data with line items (JSON) |
| Contracts | 4 | Contract terms, clauses, and party information |
| PricingCases | 4 | Pricing requests with discount and margin analysis |
| AnomalyResults | 16 | AI detection output with three-stage scoring |
| AlertQueue | 8 | Notification tracking and escalation management |
| AuditLog | 16 | Complete audit trail of all system actions |
| ReportHistory | 4 | Generated report tracking |

---

## Test Data

### Document Distribution

| Type | Normal | Anomalous | Total |
|------|--------|-----------|-------|
| Invoices | 4 | 4 | 8 |
| Contracts | 2 | 2 | 4 |
| Pricing Cases | 2 | 2 | 4 |
| **Total** | **8** | **8** | **16** |

### Anomaly Scenarios

| Document | Anomaly Type | Score | Severity |
|----------|-------------|-------|----------|
| INV-2026-005 | Abnormal quantity (100x normal), short payment terms | 78.5 | High |
| INV-2026-006 | High-risk vendor (C-rated), extreme unit pricing | 88.0 | Critical |
| INV-2026-007 | Unapproved vendor, vague descriptions, possible fraud | 95.0 | Critical |
| INV-2026-008 | Duplicate invoice number (copy of INV-2026-001) | 85.0 | Critical |
| CON-2026-003 | $2.5M exclusive deal, upfront payment, missing clauses | 92.0 | Critical |
| CON-2026-004 | Unapproved vendor, $750K for 2 months, vague scope | 96.0 | Critical |
| PRC-2026-003 | 75% discount, 3% margin (min is 15%), weak justification | 89.0 | Critical |
| PRC-2026-004 | Proposed price 400-500% ABOVE list price | 91.0 | Critical |

### Vendor Risk Profiles

| Vendor | Risk Rating | Approved | Anomaly Count |
|--------|------------|----------|---------------|
| Acme Industrial Supplies | A (Low) | ✅ Yes | 0 |
| GlobalTech Solutions Inc. | A (Low) | ✅ Yes | 0 |
| Pinnacle Office Services | B (Medium) | ✅ Yes | 0 |
| Meridian Consulting Group | B (Medium) | ✅ Yes | 0 |
| NovaParts Manufacturing | C (High) | ✅ Yes | 2 |
| Shady Deals Trading Co. | D (Critical) | ❌ No | 1 |

---

## Copilot Studio Configuration

### Agent Identity
- **Name:** DocuGuard AI
- **Persona:** Professional, precise, proactive enterprise document intelligence assistant
- **AI Model:** GPT-4o via Azure OpenAI (temperature 0.3 for consistent responses)

### Knowledge Sources
- Azure SQL Database (6 tables connected directly)
- Generative AI answers enabled for contextual reasoning

### Tools (Power Automate Flows)
- DocuGuard - Send Anomaly Alert Email
- DocuGuard - Send Slack Alert

### Sample Interactions

**Query:** "Which vendors have the highest risk rating?"
**Response:** Identifies Shady Deals Trading Co. (Risk: D, unapproved) with $275K spend and recommends escalation.

**Query:** "Have any duplicate invoices been detected?"
**Response:** Flags Document #8 as duplicate of INV-2026-001, originally paid Jan 15, resubmitted Feb 22.

**Query:** "Send an anomaly alert email about INV-2026-007"
**Response:** Triggers Power Automate flow, sends formatted HTML email with anomaly details.

---

## Power Automate Flows

### Flow 1: Anomaly Alert Email
```
Trigger: When an agent calls the flow
  → Inputs: DocumentId, AlertTitle, AlertMessage, Severity, RecipientEmail
  → Action: Send an email (V2) with HTML template
  → Response: Confirmation message
```

### Flow 2: Slack Alert
```
Trigger: When an agent calls the flow
  → Inputs: DocumentId, AlertTitle, AlertMessage, Severity
  → Action: Post message (V2) to #all-docuguard-alerts channel
  → Response: Confirmation message
```

### Alert Routing Logic

| Severity | Channels | Max Latency | Recipients |
|----------|----------|-------------|------------|
| 🔴 Critical (≥85) | Slack + Email + Teams | Immediate | Dept Head + VP + Compliance |
| 🟠 High (70–84) | Slack + Email | < 5 min | Dept Reviewer + Manager |
| 🟡 Medium (50–69) | Email only | < 15 min | Assigned Reviewer |
| 🔵 Low (30–49) | In-app only | Next session | Document Uploader |

---

## Power Apps Portal

### Features
- Live document gallery connected to Azure SQL
- Color-coded anomaly status (🔴 Flagged / 🟢 Clean / ⚪ Pending)
- Document detail view with all metadata fields
- Search functionality across all documents
- Dashboard metrics (Total, Clean, Flagged, Pending counts)

---

## Demo Scenarios

Use these test scenarios to demonstrate the system:

### Scenario 1: Vendor Risk Investigation
```
User: "Which vendors have the highest risk rating?"
→ Chatbot identifies Shady Deals Trading Co. (Risk D)
→ Shows spend data, anomaly history, approval status
→ Recommends freezing payments and due-diligence review
```

### Scenario 2: Duplicate Invoice Detection
```
User: "Have any duplicate invoices been detected?"
→ Chatbot finds INV-2026-001 submitted twice
→ Shows original (Jan 15, paid) vs duplicate (Feb 22)
→ Recommends immediate rejection
```

### Scenario 3: Critical Anomaly Alert
```
User: "Send an alert about INV-2026-007 to compliance@contoso.com"
→ Chatbot triggers Power Automate email flow
→ Formatted HTML email sent with anomaly details
→ Confirmation returned to user
```

### Scenario 4: Pricing Case Review
```
User: "Are there any pricing cases with extreme discounts?"
→ Chatbot identifies PRC-2026-003 (75% discount, 3% margin)
→ Explains policy violation (15% margin minimum)
→ Recommends rejection and VP Sales review
```

### Scenario 5: Contract Risk Assessment
```
User: "Show me anomalous contracts"
→ Chatbot identifies CON-2026-003 ($2.5M exclusive) and CON-2026-004 ($750K fraud risk)
→ Detailed explanation of missing clauses, unfavorable terms
→ Recommends legal review and blocking execution
```

---

## Screenshots

> Add screenshots to the `screenshots/` folder:
> - `01-copilot-chatbot-query.png` — Chatbot answering vendor risk query
> - `02-copilot-duplicate-detection.png` — Duplicate invoice detection
> - `03-email-alert.png` — Email alert received
> - `04-slack-alert.png` — Slack channel notification
> - `05-azure-sql-tables.png` — Azure SQL query editor with data
> - `06-blob-storage.png` — Azure Blob Storage with uploaded PDFs
> - `07-power-automate-flows.png` — Power Automate flow overview
> - `08-power-apps-portal.png` — Power Apps document portal

---

## Roadmap

- [x] Azure SQL Database (Serverless) — 10 tables + test data
- [x] Azure Blob Storage — 16 PDF documents uploaded
- [x] Copilot Studio AI Agent — connected to SQL, answering queries
- [x] Power Automate Email Flow — triggered by chatbot
- [x] Power Automate Slack Flow — channel notifications
- [x] Power Apps Portal — basic document gallery with status
- [ ] Custom Topics in Copilot Studio (report requests, alert management)
- [ ] Azure AI Document Intelligence (PDF extraction pipeline)
- [ ] PowerPoint report generation (Azure Functions)
- [ ] Advanced Power Apps portal (upload form, detail panels)
- [ ] Teams channel deployment
- [ ] Scheduled flows (weekly reports, contract expiration monitor)
- [ ] Dataverse sync for enhanced Power Platform integration

---

## Skills Demonstrated

- **Microsoft Copilot Studio** — Agent design, custom instructions, knowledge sources, plugin architecture
- **Azure SQL Database** — Schema design, serverless configuration, stored procedures, indexing
- **Azure Blob Storage** — Container management, hierarchical document storage
- **Power Automate** — Event-driven flows, Copilot integration, multi-channel notifications
- **Power Apps** — Canvas app development, SQL Server connectors, dynamic UI
- **AI/ML Architecture** — Multi-stage anomaly detection pipeline design
- **Solution Architecture** — End-to-end enterprise system design across Microsoft stack
- **Slack Integration** — Webhook-based alerting with rich message formatting

---

## Author

**Ing. Arnold Németh** — Smart Solutions

- Microsoft Power Platform & Azure AI Solutions
- LinkedIn: [Add your LinkedIn URL]
- GitHub: [Add your GitHub URL]

---

## License

This project is provided for educational and demonstration purposes. All company names, document data, and scenarios are fictional.
