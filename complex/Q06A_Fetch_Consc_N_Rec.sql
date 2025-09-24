-- Finding N consecutive records where temperature is below zero. And table has a primary key.
DROP TABLE IF EXISTS WEATHER;
CREATE TABLE WEATHER
(
  ID int PRIMARY KEY,
  CITY varchar(6) NOT NULL,
  TEMP int NOT NULL,
  DAY date NOT NULL
);
DELETE FROM WEATHER;

INSERT INTO WEATHER
VALUES 
(1, 'London', -1, '2021-01-01'),
(2, 'London', -2, '2021-01-02'),
(3, 'London', 4, '2021-01-03'),
(4, 'London', 1, '2021-01-04'),
(5, 'London', -2, '2021-01-05'),
(6, 'London', -5, '2021-01-06'),
(7, 'London', -7, '2021-01-07'),
(8, 'London', 5, '2021-01-08'),
(9, 'London', -20, '2021-01-09'),
(10, 'London', 20, '2021-01-10'),
(11, 'London', 22, '2021-01-11'),
(12, 'London', -1, '2021-01-12'),
(13, 'London', -2, '2021-01-13'),
(14, 'London', -2, '2021-01-14'),
(15, 'London', -4, '2021-01-15'),
(16, 'London', -9, '2021-01-16'),
(17, 'London', 0, '2021-01-17'),
(18, 'London', -10, '2021-01-18'),
(19, 'London', -11, '2021-01-19'),
(20, 'London', -12, '2021-01-20'),
(21, 'London', -11, '2021-01-21');


WITH CTE_GRP AS 
(SELECT 
  * 
  , ROW_NUMBER() OVER(ORDER BY ID) AS RN
  , ID-(ROW_NUMBER() OVER(ORDER BY ID)) AS DIFF
FROM WEATHER
WHERE TEMP < 0)

, CTE_CONS AS (
SELECT 
  *
  , COUNT(1) OVER(PARTITION BY DIFF) AS CONS_COUNT
FROM CTE_GRP)

SELECT CITY, DAY, TEMP FROM CTE_CONS WHERE CONS_COUNT=3;