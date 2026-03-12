# Power Apps Portal — Configuration Guide

## Overview

The DocuGuard Portal is a Canvas App that provides a document management dashboard connected to Azure SQL Database. It displays all documents with color-coded anomaly statuses and detail views.

## Setup

### Step 1: Create the App
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Click **Apps** → **"Start with data"**
3. Select your SQL Server connection → **Documents** table
4. Power Apps auto-generates a gallery + detail view

### Step 2: Add Data Sources
Add these additional tables via **Add data** → SQL Server connector:
- VendorMaster
- AnomalyResults
- Employees

### Step 3: Customize Header
- Change the header text to: `"DocuGuard AI — Document Management Portal"`
- Set header background: `ColorValue("#1B2A4A")`

### Step 4: Gallery Configuration
Set the gallery Items property to:
```
SortByColumns(Documents, "UploadDate", SortOrder.Descending)
```

Configure gallery fields:
- **Primary text:** ExternalDocId
- **Subtitle:** DocType
- **Body:** AnomalyStatus

### Step 5: Color-Coded Status
Apply this formula to the AnomalyStatus label Color property:
```
If(
    ThisItem.AnomalyStatus = "Flagged", ColorValue("#D83B01"),
    ThisItem.AnomalyStatus = "Clean", ColorValue("#107C10"),
    ColorValue("#666666")
)
```

### Step 6: Dashboard Metrics
Add text labels with these formulas:
- Total: `"Total: " & CountRows(Documents)`
- Clean: `"✓ Clean: " & CountIf(Documents, AnomalyStatus = "Clean")`
- Flagged: `"⚠ Flagged: " & CountIf(Documents, AnomalyStatus = "Flagged")`
- Pending: `"⏳ Pending: " & CountIf(Documents, AnomalyStatus = "Pending")`

## Color Scheme

| Element | Color | Hex Code |
|---------|-------|----------|
| Header background | Navy | #1B2A4A |
| Accent / links | Microsoft Blue | #0078D4 |
| Clean status | Green | #107C10 |
| Flagged status | Red/Orange | #D83B01 |
| Pending status | Gray | #666666 |
| Light background | Light Gray | #F2F2F2 |
