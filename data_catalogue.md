# Data Catalogue — Gold Layer (`og_gold`)

## Overview

The Gold Layer is the business-ready, analytics-facing layer of the data warehouse. It is modelled as a **Star Schema** consisting of two dimension views and one fact view. All views in this layer are derived from cleaned and integrated data in the Silver Layer, combining records from both CRM and ERP source systems.

The Gold Layer is the single source of truth for all reporting, dashboards, and stakeholder analysis.

---

## Views

### 1. `og_gold.dim_customers`

**Purpose:** Master dimension for all customer information. Each row represents one unique, active customer. Data is integrated from three Silver Layer sources — CRM customer records, ERP customer demographics, and ERP location data — to produce a single, clean customer profile.

| Column Name       | Data Type | Description                                                                                                                                                                                               |
| ----------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `customer_key`    | INT       | Surrogate key — system-generated unique integer assigned to each customer. Used as the primary join key across the data model. Not sourced from any system; generated at query time using `ROW_NUMBER()`. |
| `customer_id`     | INT       | Natural key from the CRM system. The internal numeric ID that identifies the customer in the source CRM.                                                                                                  |
| `customer_number` | VARCHAR   | Business-facing alphanumeric customer identifier from the CRM (e.g. `AW-00001`). Used in customer-facing communications and reporting.                                                                    |
| `first_name`      | VARCHAR   | Customer's first name, sourced from CRM.                                                                                                                                                                  |
| `last_name`       | VARCHAR   | Customer's last name, sourced from CRM.                                                                                                                                                                   |
| `country`         | VARCHAR   | Country of residence, sourced from ERP location data.                                                                                                                                                     |
| `marital_status`  | VARCHAR   | Customer's marital status (e.g. `Married`, `Single`), sourced from CRM.                                                                                                                                   |
| `gender`          | VARCHAR   | Customer's gender. Derived column: CRM is the master source; ERP gender is used as a fallback if CRM value is `N/A`. If both are unavailable, defaults to `N/A`.                                          |
| `birth_date`      | DATE      | Customer's date of birth, sourced from ERP demographic data.                                                                                                                                              |
| `create_date`     | DATE      | Date the customer record was originally created in the CRM system.                                                                                                                                        |

**Source Tables:** `og_silver.crm_cust_info`, `og_silver.erp_cust_AZ12`, `og_silver.erp_loc_A101`

---

### 2. `og_gold.dim_products`

**Purpose:** Master dimension for all current, active products. Each row represents one product that is currently sold (historical/retired products are excluded). Data is integrated from CRM product records and ERP product category data.

> **Note:** Only products without an end date (`prd_end_dt IS NULL`) are included. This ensures the dimension reflects the active product catalogue only, filtering out any historically versioned product records.

| Column Name          | Data Type | Description                                                                                                                                                                                                    |
| -------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `product_key`        | INT       | Surrogate key — system-generated unique integer assigned to each product. Used as the primary join key across the data model. Generated using `ROW_NUMBER()` ordered by product start date and product number. |
| `product_id`         | INT       | Natural key from the CRM system. The internal numeric ID that identifies the product in the source CRM.                                                                                                        |
| `product_number`     | VARCHAR   | Alphanumeric product identifier from CRM (e.g. `BK-M68B-38`). Used in order records and cross-system references.                                                                                               |
| `product_name`       | VARCHAR   | Full descriptive name of the product, sourced from CRM.                                                                                                                                                        |
| `category_id`        | VARCHAR   | Alphanumeric identifier linking the product to its category, used to join with ERP product category data.                                                                                                      |
| `category`           | VARCHAR   | High-level product category (e.g. `Bikes`, `Accessories`), sourced from ERP category data.                                                                                                                     |
| `sub_category`       | VARCHAR   | More granular product grouping within the category (e.g. `Mountain Bikes`, `Helmets`), sourced from ERP category data.                                                                                         |
| `maintenance`        | VARCHAR   | Indicates whether the product requires maintenance. Sourced from ERP category data (e.g. `Yes`, `No`).                                                                                                         |
| `product_cost`       | INT       | Standard cost to manufacture or acquire the product, in currency units. Sourced from CRM.                                                                                                                      |
| `product_line`       | VARCHAR   | The product line or range the product belongs to (e.g. `Road`, `Mountain`, `Touring`). Sourced from CRM.                                                                                                       |
| `product_start_date` | DATE      | The date from which the current version of the product became active. Sourced from CRM.                                                                                                                        |

**Source Tables:** `og_silver.crm_prd_info`, `og_silver.erp_prx_cat_G1V2`

---

### 3. `og_gold.fact_sales`

**Purpose:** Central fact table capturing all individual sales transactions. Each row represents one line item on a sales order. This table links to both dimension views via surrogate keys and stores all measurable sales metrics used for analysis (revenue, quantity, pricing).

| Column Name     | Data Type | Description                                                                                                                 |
| --------------- | --------- | --------------------------------------------------------------------------------------------------------------------------- |
| `order_number`  | VARCHAR   | Unique identifier for the sales order (e.g. `SO43659`). One order may contain multiple line items (rows). Sourced from CRM. |
| `customer_key`  | INT       | Foreign key referencing `dim_customers.customer_key`. Identifies which customer placed the order.                           |
| `product_key`   | INT       | Foreign key referencing `dim_products.product_key`. Identifies which product was ordered.                                   |
| `order_date`    | DATE      | Date the sales order was placed by the customer.                                                                            |
| `shipping_date` | DATE      | Date the order was shipped to the customer.                                                                                 |
| `due_date`      | DATE      | Date the order was due to be delivered to the customer.                                                                     |
| `sales_amount`  | INT       | Total sales revenue for the line item, in currency units. Represents the actual amount charged.                             |
| `quantity`      | INT       | Number of units of the product ordered on this line item.                                                                   |
| `price`         | INT       | Unit price of the product at the time of the order, in currency units.                                                      |

**Source Tables:** `og_silver.crm_sales_details`, `og_gold.dim_customers`, `og_gold.dim_products`

---

## Data Model Diagram

```
                    ┌─────────────────────┐
                    │   dim_customers     │
                    │─────────────────────│
                    │ customer_key (PK)   │
                    │ customer_id         │
                    │ customer_number     │
                    │ first_name          │
                    │ last_name           │
                    │ country             │
                    │ marital_status      │
                    │ gender              │
                    │ birth_date          │
                    │ create_date         │
                    └──────────┬──────────┘
                               │
                               │ customer_key
                               │
┌───────────────────┐    ┌─────▼──────────────┐
│   dim_products    │    │    fact_sales       │
│───────────────────│    │────────────────────│
│ product_key (PK)  ├────► product_key (FK)   │
│ product_id        │    │ customer_key (FK)   │
│ product_number    │    │ order_number        │
│ product_name      │    │ order_date          │
│ category_id       │    │ shipping_date       │
│ category          │    │ due_date            │
│ sub_category      │    │ sales_amount        │
│ maintenance       │    │ quantity            │
│ product_cost      │    │ price               │
│ product_line      │    └─────────────────────┘
│ product_start_date│
└───────────────────┘
```

---

## Source System Reference

| Source Table        | System | Description                                            |
| ------------------- | ------ | ------------------------------------------------------ |
| `crm_cust_info`     | CRM    | Core customer demographics and identifiers             |
| `crm_prd_info`      | CRM    | Product catalogue with cost, line, and lifecycle dates |
| `crm_sales_details` | CRM    | Individual sales order line items                      |
| `erp_cust_AZ12`     | ERP    | Supplementary customer data: birth date and gender     |
| `erp_loc_A101`      | ERP    | Customer location / country data                       |
| `erp_prx_cat_G1V2`  | ERP    | Product category and sub-category hierarchy            |
