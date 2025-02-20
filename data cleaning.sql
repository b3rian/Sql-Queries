-- Data Cleaning in SQL
-- Steps:
-- 1. Remove duplicates
-- 2. Remove missing values/ Null values
-- 3. Remove outliers
-- 4. Correct data types
-- 5. Normalize data
-- 6. Standardize data
-- 7. Transform data
-- 8. Aggregate data
-- 9. Remove unwanted columns
-- 10. Remove unwanted rows

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;