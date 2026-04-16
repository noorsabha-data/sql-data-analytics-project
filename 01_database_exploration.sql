/*
===============================================================================
Script: Database Exploration & Metadata Profiling
===============================================================================
Purpose:
    This script provides a comprehensive overview of the database structure
    and metadata to support data discovery, analysis, and ETL development.

    It helps:
    - Identify all tables and schemas
    - Inspect column-level metadata
    - Understand data types and structure
    - Estimate table sizes and row counts

System Views Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
    - sys.tables, sys.schemas
    - sys.partitions (row counts)

Usage:
    - Run the full script for complete database exploration
    - Modify filters to focus on specific schemas or tables

Notes:
    - Row counts are approximate (based on partitions)
    - Excludes system tables where applicable
    - Can be extended to include indexes and constraints
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'DATABASE EXPLORATION STARTED';
PRINT '================================================';

-- ============================================================
-- 1. LIST ALL TABLES (WITH SCHEMA)
-- ============================================================

PRINT '1. Listing all user tables';

SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;


-- ============================================================
-- 2. COLUMN METADATA FOR ALL TABLES
-- ============================================================

PRINT '2. Column metadata overview';

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;


-- ============================================================
-- 3. COLUMN METADATA FOR A SPECIFIC TABLE
-- ============================================================

PRINT '3. Inspecting table: gold.dim_customers';

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
ORDER BY ORDINAL_POSITION;


-- ============================================================
-- 4. APPROXIMATE ROW COUNT PER TABLE
-- ============================================================

PRINT '4. Table row counts (approximate)';

SELECT 
    s.name AS schema_name,
    t.name AS table_name,
    SUM(p.rows) AS row_count
FROM sys.tables t
JOIN sys.schemas s 
    ON t.schema_id = s.schema_id
JOIN sys.partitions p 
    ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)   -- heap or clustered index only
GROUP BY s.name, t.name
ORDER BY row_count DESC;


-- ============================================================
-- 5. TABLE SIZE ANALYSIS (KB)
-- ============================================================

PRINT '5. Table size analysis';

SELECT 
    s.name AS schema_name,
    t.name AS table_name,
    SUM(p.rows) AS row_count,
    SUM(a.total_pages) * 8 AS total_size_kb,
    SUM(a.used_pages) * 8 AS used_size_kb,
    SUM(a.data_pages) * 8 AS data_size_kb
FROM sys.tables t
JOIN sys.schemas s 
    ON t.schema_id = s.schema_id
JOIN sys.indexes i 
    ON t.object_id = i.object_id
JOIN sys.partitions p 
    ON i.object_id = p.object_id 
   AND i.index_id = p.index_id
JOIN sys.allocation_units a 
    ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
  AND i.index_id <= 1
GROUP BY s.name, t.name
ORDER BY row_count DESC;


-- ============================================================
-- 6. DATA TYPE DISTRIBUTION (OPTIONAL ANALYSIS)
-- ============================================================

PRINT '6. Data type distribution across database';

SELECT 
    DATA_TYPE,
    COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY DATA_TYPE
ORDER BY column_count DESC;


PRINT '================================================';
PRINT 'DATABASE EXPLORATION COMPLETED';
PRINT '================================================';