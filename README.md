# Superstore Sales Analysis — SQL Project (2015–2018)

*End-to-end relational database design and SQL analytics on the Kaggle Superstore dataset, built entirely in SQL Server *

> **Disclaimer:** Dataset sourced from Kaggle (Superstore Sales) for educational and portfolio purposes only.

---

## Introduction

Retailers sit on years of transactional data — orders, customers, products, shipping — but that data is only as useful as the questions you can ask of it. For this project, I took the raw Superstore dataset (2015–2018, ~10K order-line records) and rebuilt it as a normalized relational database in SQL Server, then used SQL exclusively — no Power BI, no Excel dashboard — to answer real business questions: who are our best customers, which categories drive revenue, where are we winning or losing regionally, and how consistent is our fulfillment?

The goal was to demonstrate that meaningful, decision-ready analysis doesn't require a visualization layer — it can live entirely in well-structured queries, views, and stored procedures that any analyst or engineer can call on demand.

---

## Methodology

**1. Data Ingestion**
The raw dataset arrived as a single flat Excel file with 17 columns (`Order_ID`, `Order_Date`, `Ship_Date`, `Ship_Mode`, `Customer_ID`, `Customer_Name`, `Segment`, `Country`, `City`, `State`, `Postal_Code`, `Region`, `Product_ID`, `Category`, `Sub_Category`, `Product_Name`, `Sales`). This was loaded into SQL Server as a staging table.

**2. Schema Normalization**
To eliminate redundancy and enforce data integrity, the flat table was decomposed into a 3NF-style schema of five tables:
- `Customers` (Customer_ID, Customer_Name, Segment)
- `Products` (Product_ID, Product_Name, Category, Sub_Category)
- `Location` (Postal_Code, Country, State, City, Region)
- `Orders` (Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID FK, Postal_Code FK)
- `Order_Details` (Order_ID FK, Product_ID FK, Sales)

This mirrors how a production OLTP system would actually store this data — customers and products aren't repeated per transaction, and location data is normalized rather than duplicated on every order row.

**3. Analysis Layer**
With the schema in place, I wrote a progressively advanced set of SQL queries to extract insights, using:
- `INNER JOIN` to reconstruct order-level detail across the five tables
- `GROUP BY` / `HAVING` / aggregate functions (`SUM`, `AVG`, `COUNT`) for category, region, and customer rollups
- `CASE` statements for conditional bucketing (e.g., shipping speed tiers)
- Subqueries and CTEs for multi-step logic (e.g., ranking customers before filtering)
- Window functions (`RANK()`, `ROW_NUMBER()`, `AVG() OVER()`) for top-N and running comparisons without collapsing detail
- Views to expose reusable, pre-joined datasets for repeat querying
- Stored procedures to parameterize recurring reports (e.g., "top N customers by year")

---

## Key Findings

| Metric | Value |
|---|---|
| Total Sales | $241,979,929.24 |
| Total Customers | 793 |
| Total Products | 1,894 |
| Customer coverage | 100% — every customer has ordered at least once |
| Product coverage | 100% — every product has been sold at least once |

**Top customer:** Sean Miller (SM-20320) generated $2.68M in sales — well ahead of the next closest customer, Tamara Chand ($2.04M). The top 10 customers span a fairly tight band of $1.3M–$2.7M, suggesting a genuine "power buyer" segment rather than one outlier.

**Category performance:** Technology leads at $94.7M, followed by Furniture ($80.3M) and Office Supplies ($77.3M) — a relatively even three-way split, with Technology only ~15% ahead of the lowest category.

**Sub-category concentration:** Phones ($37.9M) and Chairs ($34.8M) alone account for a disproportionate share of revenue relative to the other top sub-categories (Storage, Binders, Tables), indicating these two lines carry outsized weight within their parent categories.

**Regional split:** West ($76.8M) and East ($70.7M) are the strongest regions; Central ($52.7M) and South ($41.6M) trail meaningfully — the South generates roughly half of what the West does.

**State-level spread is extreme:** California ($48.6M) and New York ($32.8M) alone approach a third of total company sales, while North Dakota ($98K), West Virginia ($129K), and Maine ($136K) are each three orders of magnitude smaller. This isn't a gentle long tail — it's a handful of states carrying the business.

**Average order value is drifting down:** $245.71 (2015) → $223.57 (2016) → $236.85 (2017) → $221.62 (2018). Despite total revenue growth over the period, per-order value has softened rather than trended upward.

**Shipping consistency:** Fulfillment is stable at ~3 days average across most states, but Washington D.C., Maine, and Wyoming average 5 days, and West Virginia averages 2 — worth flagging since D.C./Maine/Wyoming are also lower-revenue states, raising the question of whether slower shipping is a cause or simply a symptom of lower order density in those regions.

---

## Insights

- **Revenue concentration is the central risk.** A small number of customers and a small number of states are doing most of the work. This is efficient in the short term but fragile — losing even 2–3 top accounts or underperforming in California/New York would materially move total revenue.
- **Category balance is healthier than it looks at first glance.** No single category dominates, but within categories, revenue is concentrated in specific sub-categories (Phones, Chairs), meaning category-level health is really being carried by a few product lines.
- **Regional imbalance (South/Central lagging) is an opportunity, not just a gap.** Since South and Central together still generate over $94M, even modest share gains there (closing part of the distance to East/West) would be additive rather than requiring new markets.
- **Declining average order value alongside overall growth** suggests volume is doing more work than basket size — worth understanding whether that's driven by discounting, product mix shift toward lower-priced Sub-Categories, or more transactional (lower-Segment) customers entering the base.
- **The shipping delay in D.C., Maine, and Wyoming correlating with low sales volume** could point to a logistics/carrier coverage gap in low-density states rather than a systemic fulfillment issue — this is a testable, not just observed, pattern.
- **Full customer and product coverage (no dead SKUs, no lapsed customers)** is a genuinely positive signal — the catalog isn't bloated with unsold inventory, and the customer base isn't carrying dormant accounts, at least within this dataset's window.

---

## Actionable Recommendations

1. **Protect and grow the top-10 customer relationships** — these ~10 accounts represent a disproportionate share of revenue; a dedicated account-management or loyalty motion for this tier reduces concentration risk and likely has a high ROI.
2. **Investigate the Phones and Chairs sub-categories specifically**, not just Technology and Furniture broadly — inventory planning, promotions, and supplier negotiations should be sized around these two lines given their outsized share.
3. **Run a targeted regional push in South and Central**, using the West/East go-to-market approach as a template — even a 10–15% lift in these regions would meaningfully close the gap to $70M+ territory.
4. **Audit the low-revenue, high-shipping-time states (D.C., Maine, Wyoming)** to determine whether carrier/logistics setup is limiting sales, or whether low sales are simply making these routes less prioritized — this determines whether the fix is operational or commercial.
5. **Investigate the year-over-year decline in average order value** — segment it by Category, Segment, and Discount (if available in the source data) to see whether it's a pricing/discounting trend or a genuine shift toward smaller basket purchases.
6. **Package the top-N and regional reports as stored procedures** (already built) so Sales and Finance teams can self-serve this analysis by year or quarter without needing a new SQL script each time.

---

## Approaches Used

- Relational schema design (normalization from a flat file into 5 linked tables)
- SQL Server as the RDBMS
- INNER JOIN across a 5-table schema for order reconstruction
- Aggregate analysis (GROUP BY, HAVING, SUM/AVG/COUNT) for category, region, and state rollups
- CASE statements for conditional segmentation (e.g., shipping-day buckets)
- Subqueries and CTEs for layered, readable multi-step logic
- Window functions for top-N ranking and comparative averages without losing row-level detail
- Views for reusable, analyst-friendly joined datasets
- Stored procedures for parameterized, repeatable reporting

---

## Conclusion

This project shows that a well-normalized schema plus disciplined SQL — joins, aggregates, window functions, views, and stored procedures — can deliver the same decision-ready insight a dashboard tool would, without leaving the database layer. The Superstore data reveals a business with healthy top-line growth ($242M across 2015–2018) and full utilization of its customer and product base, but with real concentration risk in its top customers and top-performing states, softening average order value, and a regional imbalance between the West/East and South/Central corridors. The recommendations above are all directly queryable and repeatable through the stored procedures and views built as part of this project — meaning the next quarter's numbers can be re-run in seconds, not rebuilt from scratch.

