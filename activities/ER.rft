{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Klesk Data Model (Markdown Schema)\
\
## \uc0\u55357 \u56633  Customer\
- **CustomerNumber** (PK): Unique customer identifier\
- **CustomerName**: Full name of the customer\
\
---\
\
## \uc0\u55357 \u56633  ParentDivision\
- **CustomerNumber** (PK, FK \uc0\u8594  Customer.CustomerNumber): Link to customer\
- **Parent**: Parent company name\
- **Division**: Internal or industry business division\
- **Notes**: Comments or hierarchy notes\
\
---\
\
## \uc0\u55357 \u56633  Part\
- **PartNumber** (PK): Internal part or item number\
- **PartDescription**: Description or alternate part label\
\
---\
\
## \uc0\u55357 \u56633  OrderSummary\
- **CustNbr** (FK \uc0\u8594  Customer.CustomerNumber)\
- **PartNumber** (FK \uc0\u8594  Part.PartNumber)\
- **TotalRevenue**: Revenue total for part-customer pair\
- **#Orders**: Number of orders\
- **#Parts**: Total quantity\
- **AvgRev/Part**: Avg revenue per part\
- **RevenueCode**: Industry segment (e.g., Energy, Aerospace)\
- **ProductCode**: Product group (e.g., Diaphragm, Casting)\
- **PrimaryWorkCenter**: Work center associated with production\
\
---\
\
## \uc0\u55357 \u56633  SHIP310_SalesDetail\
- **CustNbr** (FK \uc0\u8594  Customer.CustomerNumber)\
- **PartNumber** (FK \uc0\u8594  Part.PartNumber)\
- **Invoice#** (PK Composite): Invoice ID\
- **InvoiceDate**: Date of invoice\
- **SalesOrder**: Internal sales order reference\
- **ShipQty**: Quantity shipped\
- **SalesAmt**: Sales revenue on invoice\
\
---\
\
## \uc0\u55357 \u56633  MSOL_ContractRates\
- **ItemNumber** (FK \uc0\u8594  Part.PartNumber)\
- **Material%**: Material percentage of total cost\
- **ConversionCost**: Machining or processing cost\
- **Index**: Cost index used (e.g., Metal index)\
- **ForecastDates**: Projected unit cost per forecast window\
\
---\
\
## \uc0\u55357 \u56633  PricingAgreement\
- **PartNumber** (FK \uc0\u8594  Part.PartNumber)\
- **Description**: Part label\
- **EAU**: Estimated Annual Usage\
- **LeadTime**: Lead time in days\
- **MOQ**: Minimum order quantity\
- **FirmPriceTerm**: Contract length in years\
- **FVA**: Fixed Value Add component\
- **MaterialCost**: Material cost basis\
\
---\
\
## \uc0\u55357 \u56633  PlatinumStandard_GM\
- **PartNumber** (FK \uc0\u8594  Part.PartNumber)\
- **CurrentFVA**: Current fixed value add\
- **ProposedFVA**: Proposed FVA change\
- **Volume**: Forecasted volume\
- **COGS**: Cost of goods sold\
- **GrossMargin**: Profitability metric\
- **ForecastedRevenue**: Expected revenue\
\
---\
\
## \uc0\u55357 \u56633  CostAnalysis_Contract\
- **RowLabel** (PK): Row or unit identifier (may align with PartNumber)\
- **MaterialType**: Havar, Titanium, etc.\
- **Supplier**: Vendor or external partner\
- **MarketIndex**: Metal/material index\
- **AvgCost/LB**: Historical material cost per pound\
- **Volume**: Volume projection\
- **UnitPrice**: Selling price\
- **Forecast12M**: 12-month revenue or cost projection\
- **GrossMargin**: Profitability %}