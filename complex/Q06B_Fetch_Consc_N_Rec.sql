-- Finding N consecutive records where temperature is below zero. And table has NO primary key.
DROP TABLE IF EXISTS WEATHER;
CREATE TABLE WEATHER
(
  CITY varchar(6) NOT NULL,
  TEMP int NOT NULL
);
DELETE FROM WEATHER;

INSERT INTO WEATHER
VALUES 
('London', -1),
('London', -2),
('London', 4),
('London', 1),
('London', -2),
('London', -5),
('London', -7),
('London', 5),
('London', -20),
('London', 20),
('London', 22),
('London', -1),
('London', -2),
('London', -2),
('London', -4),
('London', -9),
('London', 0),
('London', -10),
('London', -11),
('London', -12),
('London', -11);

WITH CTE_ID AS
(SELECT 
  * 
  , ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS ID
FROM WEATHER)

, CTE_RN AS (
  SELECT
    *
    , ROW_NUMBER() OVER(ORDER BY ID) AS RN
    , ID-(ROW_NUMBER() OVER(ORDER BY ID)) AS DIFF
  FROM CTE_ID
  WHERE TEMP < 0
)

, CTE_CONS AS (
  SELECT
    *
    , COUNT(1) OVER(PARTITION BY DIFF) AS COUNT_CONS
  FROM CTE_RN
)

SELECT
  ID, CITY, TEMP
FROM CTE_CONS
WHERE COUNT_CONS = 3;