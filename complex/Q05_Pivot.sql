-----------------
-- TABLE CREATION
-----------------


/*
-- Step 1: Create Table
CREATE TABLE SalesData (
    SalesDate DATE,
    CustomerID VARCHAR(20),
    Amount DECIMAL(10,2)
);

-- Step 2: Insert Data
INSERT INTO SalesData (SalesDate, CustomerID, Amount) VALUES
('2021-01-01', 'Cust-1', 50.00),
('2021-01-02', 'Cust-1', 50.00),
('2021-01-03', 'Cust-1', 50.00),
('2021-01-01', 'Cust-2', 100.00),
('2021-01-02', 'Cust-2', 100.00),
('2021-01-03', 'Cust-2', 100.00),
('2021-02-01', 'Cust-2', -100.00),
('2021-02-02', 'Cust-2', -100.00),
('2021-02-03', 'Cust-2', -100.00),
('2021-03-01', 'Cust-3', 1.00),
('2021-04-01', 'Cust-3', 1.00),
('2021-05-01', 'Cust-3', 1.00),
('2021-06-01', 'Cust-3', 1.00),
('2021-07-01', 'Cust-3', -1.00),
('2021-08-01', 'Cust-3', -1.00),
('2021-09-01', 'Cust-3', -1.00),
('2021-10-01', 'Cust-3', -1.00),
('2021-11-01', 'Cust-3', -1.00),
('2021-12-01', 'Cust-3', -1.00);

*/

-- SELECT FORMAT(SalesDate, 'MMM-yy') AS SalesMonth, CustomerID, Amount
-- FROM SalesData;

WITH 
CTE_PIVOT AS (
	SELECT *
	FROM
	(
		SELECT
			CustomerID
			, FORMAT(SalesDate, 'MMM-yy') AS SalesMonth
			, CAST(Amount AS INT) AS Amount
		FROM SalesData
	) AS SourceTable
	PIVOT
	(
		SUM(Amount) FOR
		SalesMonth IN
		([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) AS PivotTable

	UNION

	SELECT *
	FROM
	(
		SELECT
			'Total' AS CustomerID
			, FORMAT(SalesDate, 'MMM-yy') AS SalesMonth
			, CAST(Amount AS INT) AS Amount
		FROM SalesData
	) AS SourceTable
	PIVOT
	(
		SUM(Amount) FOR
		SalesMonth IN
		([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) AS PivotTable
)

SELECT 
	CustomerID
	, COALESCE([Jan-21], 0) AS [Jan-21]
	, COALESCE([Feb-21], 0) AS [Feb-21]
	, COALESCE([Mar-21], 0) AS [Mar-21]
	, COALESCE([Apr-21], 0) AS [Apr-21]
	, COALESCE([May-21], 0) AS [May-21]
	, COALESCE([Jun-21], 0) AS [Jun-21]
	, COALESCE([Jul-21], 0) AS [Jul-21]
	, COALESCE([Aug-21], 0) AS [Aug-21]
	, COALESCE([Sep-21], 0) AS [Sep-21]
	, COALESCE([Oct-21], 0) AS [Oct-21]
	, COALESCE([Nov-21], 0) AS [Nov-21]
	, COALESCE([Dec-21], 0) AS [Dec-21]
	, (COALESCE([Jan-21], 0)
		+ COALESCE([Feb-21], 0)
		+ COALESCE([Mar-21], 0)
		+ COALESCE([Apr-21], 0)
		+ COALESCE([May-21], 0)
		+ COALESCE([Jun-21], 0)
		+ COALESCE([Jul-21], 0)
		+ COALESCE([Aug-21], 0)
		+ COALESCE([Sep-21], 0)
		+ COALESCE([Oct-21], 0)
		+ COALESCE([Nov-21], 0)
		+ COALESCE([Dec-21], 0)
	) AS Total
FROM CTE_PIVOT;