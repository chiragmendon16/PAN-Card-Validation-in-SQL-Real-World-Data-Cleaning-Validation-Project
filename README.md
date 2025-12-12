📌 PAN Card Validation in SQL — Real-World Data Cleaning & Validation Project
This project demonstrates a complete end-to-end data validation pipeline built entirely in SQL and PL/pgSQL to clean, standardize, and validate Indian Permanent Account Numbers (PAN). The system handles real-world data issues—missing values, duplicates, inconsistent formatting—and applies strict rule-based logic using custom functions and regex to classify each PAN as Valid or Invalid.

Through a combination of data cleaning, pattern recognition, sequence detection, and validation checks, the project replicates a real-world data quality workflow used in analytics and ETL environments. A final summary report provides a clear breakdown of valid, invalid, and incomplete PAN entries, showcasing practical SQL skills and clean project structuring suitable for production-grade data pipelines.

🔹 1. Data Cleaning & Preprocessing
The raw dataset undergoes several essential data-quality steps:
✅ Cleaning Tasks Performed

Removed missing / null PAN entries
Identified and eliminated duplicate rows
Standardized formatting using:
TRIM() → removed leading/trailing spaces
UPPER() → ensured consistent uppercase

Created a clean staging table:
pan_numbers_dataset_cleaned

🧹 Example SQL Snippet
CREATE TABLE pan_numbers_dataset_cleaned AS
SELECT DISTINCT UPPER(TRIM(pan_number)) AS pan_number
FROM stg_pan_numbers_dataset
WHERE pan_number IS NOT NULL
  AND TRIM(pan_number) <> '';

🔹 2. PAN Format Validation Rules
A PAN is valid only if it meets all the following conditions:
✔ Format Requirement
AAAAA9999A
  1–5 → Uppercase alphabets
  6–9 → Digits
  10 → Uppercase alphabet
  Regex used:
^[A-Z]{5}[0-9]{4}[A-Z]$

✔ Additional Business Rules
No adjacent repeating alphabets (e.g., AABCD ❌)
No adjacent repeating digits (e.g., 1123 ❌)
First 5 letters cannot be a straight sequence (e.g., ABCDE, LMNOP ❌)
Digits cannot be a straight sequence (e.g., 1234, 4567 ❌)

✔ Valid Example
AHGVE1276F

🔹 3. SQL Logic & Functions Used
The project uses PL/pgSQL functions to detect patterns that regex cannot catch.
🧠 Custom Functions Implemented
1️⃣ Detect adjacent repetition
fn_check_adjacent_repetition(p_str text)
Returns TRUE if any two consecutive characters are identical.

2️⃣ Detect sequential characters
fn_check_sequence(p_str text)
Returns TRUE if characters form a straight sequence (A→B→C, 1→2→3, etc.)

🏗 Validation Pipeline
Cleaned data stored in
  pan_numbers_dataset_cleaned

Validation rules applied using:
  Regex
  fn_check_adjacent_repetition()
  fn_check_sequence()

Output view created:
  vw_valid_invalid_pans

Final summary generated using a CTE.

📘 Example Validation Join
SELECT cln.pan_number,
       CASE WHEN vld.pan_number IS NULL
            THEN 'Invalid PAN'
            ELSE 'Valid PAN'
       END AS status
FROM cte_cleaned_pan cln
LEFT JOIN cte_valid_pan vld
       ON vld.pan_number = cln.pan_number;

🔹 4. Summary Report

The SQL pipeline produces a final summary showing:

Metric	Value
Total Records Processed	- replace with your result
Valid PANs - replace with your result
Invalid PANs - replace with your result
Missing / Incomplete PANs	- replace with your result

📊 Summary Query Used
WITH cte AS (
    SELECT
        (SELECT COUNT(*) FROM stg_pan_numbers_dataset) AS total_processed_records,
        COUNT(*) FILTER (WHERE vw.status = 'Valid PAN') AS total_valid_pans,
        COUNT(*) FILTER (WHERE vw.status = 'Invalid PAN') AS total_invalid_pans
    FROM vw_valid_invalid_pans vw
)
SELECT total_processed_records,
       total_valid_pans,
       total_invalid_pans,
       total_processed_records - (total_valid_pans + total_invalid_pans)
           AS missing_incomplete_pans
FROM cte;

🎯 Results (Sample — Replace With Your Actual Values)
Result - Sample Number
Records Processed	- 12,500
Valid PANs - 8,790
Invalid PANs - 3,420
Missing / Incomplete - 290

🧠 Skills Demonstrated
Advanced SQL (CTEs, regex, validation rules)
PL/pgSQL function creation
Real-world data cleaning & preprocessing
Pattern recognition through procedural logic
Rule-based dataset validation
Building reusable SQL pipelines for data quality checks
Writing clean, structured project documentation















