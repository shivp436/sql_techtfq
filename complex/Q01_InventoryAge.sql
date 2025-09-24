-- Create table
CREATE TABLE Inv (
    ID VARCHAR(10),
    Qty INT,
    Delta INT,
    Move VARCHAR(20),
    Stamp DATETIME
);

-- Insert data
INSERT INTO Inv 
(ID, Qty, Delta, Move, Stamp) 
VALUES
('TR0013', 278, 99, 'OutBound', '2020-05-25 00:25'),
('TR0012', 377, 31, 'InBound', '2020-05-24 22:00'),
('TR0011', 346, 1, 'OutBound', '2020-05-24 15:01'),
('TR0010', 346, 1, 'OutBound', '2020-05-23 05:00'),
('TR0009', 348, 102, 'InBound', '2020-04-25 18:00'),
('TR0008', 246, 43, 'InBound', '2020-04-25 02:00'),
('TR0007', 203, 2, 'OutBound', '2020-02-25 09:00'),
('TR0006', 205, 129, 'OutBound', '2020-02-18 07:00'),
('TR0005', 334, 1, 'OutBound', '2020-02-18 08:00'),
('TR0004', 335, 27, 'OutBound', '2020-01-29 05:00'),
('TR0003', 362, 120, 'InBound', '2019-12-31 02:00'),
('TR0002', 242, 8, 'OutBound', '2019-05-22 00:50'),
('TR0001', 250, 250, 'InBound', '2019-05-20 00:45');

--SELECT * FROM Inv ORDER BY Stamp;

--------------------
-- CALCULATE CUM INBOUND 
--------------------

-- SELECT
--   *
--   , SUM(Delta) OVER(ORDER BY Stamp) AS CUM_QTY
-- FROM INV
-- WHERE Move='InBound';

WITH CTE_TOT_OB AS (
SELECT SUM(Delta) AS OB FROM Inv WHERE Move='OutBound')

, CTE_MAX_DATE AS (SELECT MAX(Stamp) AS Max_Date FROM Inv)

, CTE_CUM_REM_QTY AS (SELECT 
  I.Delta AS InBound_Qty
  --, I.Stamp
  , DATEDIFF(DAY, I.STAMP, (SELECT Max_Date FROM CTE_MAX_DATE)) AS Age
  , SUM(Delta) OVER(ORDER BY Stamp) AS Cum_IB_Qty
  , C.OB AS Tot_OB_Qty
  , CASE
      WHEN (SUM(Delta) OVER(ORDER BY Stamp)) - C.OB <= 0 THEN 0
      ELSE (SUM(Delta) OVER(ORDER BY Stamp)) - C.OB
    END AS Cum_Rem_Qty
FROM Inv AS I 
LEFT JOIN CTE_TOT_OB AS C
  ON 1=1
WHERE Move = 'InBound')

, CTE_REM_QTY AS (
SELECT
  *
  , CASE
      WHEN LAG(Cum_Rem_Qty) OVER(ORDER BY Cum_Rem_Qty) > 0 THEN InBound_Qty
      ELSE Cum_Rem_Qty
    END AS Rem_Qty
  , CASE
      WHEN Age BETWEEN 0 AND 90 THEN '0-90 DAYS'
      WHEN Age BETWEEN 91 AND 180 THEN '91-180 DAYS'
      WHEN Age BETWEEN 181 AND 270 THEN '181-270 DAYS'
      WHEN Age BETWEEN 271 AND 360 THEN '271-360 DAYS'
      ELSE '365+ DAYS'
    END AS Age_Bucket
FROM CTE_CUM_REM_QTY)


, CTE_PIVOT_AGG AS (
SELECT 
  'Remaining Qty - PIVOT' AS Age_Bucket
  , [0-90 DAYS]
  , [91-180 DAYS]
  , [181-270 DAYS]
  , [271-360 DAYS]
FROM (
  SELECT Age_Bucket, Rem_Qty FROM CTE_REM_QTY
) AS SourceTable
PIVOT (
  SUM(Rem_Qty) FOR Age_Bucket IN 
  ([0-90 DAYS], [91-180 DAYS], [181-270 DAYS], [271-360 DAYS])
) AS PivotTable)

SELECT * FROM CTE_PIVOT_AGG UNION ALL
SELECT 
    'Remaining Qty - CASE & SUM' AS Age_Bucket,
    SUM(CASE WHEN Age_Bucket = '0-90 DAYS'     THEN Rem_Qty ELSE 0 END) AS [0-90 DAYS],
    SUM(CASE WHEN Age_Bucket = '91-180 DAYS'   THEN Rem_Qty ELSE 0 END) AS [91-180 DAYS],
    SUM(CASE WHEN Age_Bucket = '181-270 DAYS'  THEN Rem_Qty ELSE 0 END) AS [181-270 DAYS],
    SUM(CASE WHEN Age_Bucket = '271-360 DAYS'  THEN Rem_Qty ELSE 0 END) AS [271-360 DAYS]
FROM CTE_REM_QTY;




