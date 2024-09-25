CREATE DATABASE IF NOT EXISTS MENTAL_DISORDER;

USE MENTAL_DISORDER;
SELECT * from `mental-illness-prevalence`;

CREATE TABLE IF NOT EXISTS `mental-illness-prevalence` (
    `Entity` VARCHAR(100),
    `Code` VARCHAR(5),
    `Year` INT,
    `Schizophrenia disorders` FLOAT,
    `Depressive disorders` FLOAT,
    `Anxiety disorders` FLOAT,
    `Bipolar disorders` FLOAT,
    `Eating disorders` FLOAT,
    PRIMARY KEY (`Entity`, `Year`)
);

CREATE TABLE IF NOT EXISTS `mental-illness-burden` (
    `Entity` VARCHAR(100),
    `Code` VARCHAR(5),
    `Year` INT,
    `DALYs rate Depressive disorders` FLOAT,
    `DALYs rate Schizophrenia` FLOAT,
    `DALYs rate Bipolar disorder` FLOAT,
    `DALYs rate Eating disorders` FLOAT,
    `DALYs rate Anxiety disorders` FLOAT,
    PRIMARY KEY (`Entity`, `Year`)
);

-- 1. What is the average prevalence of Schizophrenia disorders over the years for each country.
SELECT Entity, AVG(`Schizophrenia disorders`) AS Avg_Schizophrenia_Prevalence
FROM `mental-illness-prevalence`
GROUP BY Entity
ORDER BY Avg_Schizophrenia_Prevalence DESC;

-- 2. Find the total DALYs rate for all mental disorders combined for each country in a given year, and sort by total rate.
SELECT Entity, Year, 
       (SUM(`DALYs rate Depressive disorders`) + SUM(`DALYs rate Schizophrenia`) + 
        SUM(`DALYs rate Bipolar disorder`) + SUM(`DALYs rate Eating disorders`) + 
        SUM(`DALYs rate Anxiety disorders`)) AS Total_DALYs_Rate
FROM `mental-illness-burden`
GROUP BY Entity, Year
ORDER BY Total_DALYs_Rate DESC;

-- 3. Identify the year with the highest prevalence of Depressive disorders for each country.
WITH MaxDepressive AS (
    SELECT Entity, MAX(`Depressive disorders`) AS Max_Depressive
    FROM `mental-illness-prevalence`
    GROUP BY Entity
)
SELECT m.Entity, m.Year, m.`Depressive disorders`
FROM `mental-illness-prevalence` m
JOIN MaxDepressive d ON m.Entity = d.Entity AND m.`Depressive disorders` = d.Max_Depressive;

-- 4. Compare the average DALYs rate of Anxiety disorders and Depressive disorders for each country.
SELECT Entity, 
       AVG(`DALYs rate Anxiety disorders`) AS Avg_Anxiety_DALYs,
       AVG(`DALYs rate Depressive disorders`) AS Avg_Depressive_DALYs
FROM `mental-illness-burden`
GROUP BY Entity;

-- 5. Identify the countries where the prevalence of Bipolar disorders has decreased over the years.
-- Subquery to find the year with the minimum Bipolar disorder prevalence for each entity
WITH MinBipolarDisorder AS (
    SELECT Entity, MIN(`Bipolar disorders`) AS Min_Bipolar_Disorder
    FROM `mental-illness-prevalence`
    GROUP BY Entity
),
MinYear AS (
    SELECT P.Entity, MIN(P.Year) AS Min_Year
    FROM `mental-illness-prevalence` P
    JOIN MinBipolarDisorder MBD ON P.Entity = MBD.Entity AND P.`Bipolar disorders` = MBD.Min_Bipolar_Disorder
    GROUP BY P.Entity
)
SELECT Entity, Min_Year
FROM MinYear;

-- 6. Find the year with the lowest DALYs rate for Eating disorders for all countries combined.
SELECT Year, MIN(`DALYs rate Eating disorders`) AS Min_Eating_DALYs_Rate
FROM `mental-illness-burden`
GROUP BY Year
ORDER BY Min_Eating_DALYs_Rate ASC
LIMIT 1;

-- 7. Determine the average prevalence of Anxiety disorders over the years for countries with a DALYs rate for Anxiety disorders greater than 400.
SELECT P.Entity, AVG(P.`Anxiety disorders`) AS Avg_Anxiety_Prevalence
FROM `mental-illness-prevalence` P
JOIN `mental-illness-burden` D ON P.Entity = D.Entity AND P.Year = D.Year
WHERE D.`DALYs rate Anxiety disorders` > 400
GROUP BY P.Entity;

-- 8. Compare the prevalence of Depressive disorders in 1990 and 1991 for each country.
SELECT P1.Entity, P1.`Depressive disorders` AS Depressive_1990, P2.`Depressive disorders` AS Depressive_2010
FROM `mental-illness-prevalence` P1
JOIN `mental-illness-prevalence` P2 ON P1.Entity = P2.Entity
WHERE P1.Year = 1990 AND P2.Year = 2010;

-- 9. Calculate the percentage change in the prevalence of Depressive disorders from 1990 to 2010 for each country.
SELECT P1990.Entity,
       ((P2019.`Depressive disorders` - P1990.`Depressive disorders`) / P1990.`Depressive disorders`) * 100 AS Percentage_Change
FROM `mental-illness-prevalence` P1990
JOIN `mental-illness-prevalence` P2019 ON P1990.Entity = P2019.Entity
WHERE P1990.Year = 1990 AND P2019.Year = 2019;

-- 10. Identify the country with the highest average prevalence of Depressive disorders over the entire dataset.
SELECT Entity, AVG(`Depressive disorders`) AS Avg_Depressive_Prevalence
FROM `mental-illness-prevalence`
GROUP BY Entity
ORDER BY Avg_Depressive_Prevalence DESC
LIMIT 1;

-- 5. Find the correlation between the prevalence of Schizophrenia disorders and the DALYs rate for Schizophrenia disorders over the years.
SELECT P.Year, P.`Schizophrenia disorders`, D.`DALYs rate Schizophrenia`
FROM `mental-illness-prevalence` P
JOIN `mental-illness-burden` D ON P.Entity = D.Entity AND P.Year = D.Year
WHERE P.Entity = 'Philippines';