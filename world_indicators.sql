CREATE DATABASE IF NOT EXISTS DEVELOPMENT_INDICATORS;

USE DEVELOPMENT_INDICATORS;

CREATE TABLE IF NOT EXISTS CountryData (
    CountryCode VARCHAR(255),
    ShortName VARCHAR(255),
    TableName VARCHAR(255),
    LongName VARCHAR(255),
    Alpha2Code VARCHAR(2),
    CurrencyUnit VARCHAR(255),
    SpecialNotes TEXT,
    Region VARCHAR(255),
    IncomeGroup VARCHAR(255),
    Wb2Code VARCHAR(10),
    NationalAccountsBaseYear VARCHAR(255),
    NationalAccountsReferenceYear VARCHAR(255),
    SnaPriceValuation VARCHAR(255),
    LendingCategory VARCHAR(255),
    OtherGroups VARCHAR(255),
    SystemOfNationalAccounts VARCHAR(255),
    AlternativeConversionFactor VARCHAR(255),
    PppSurveyYear VARCHAR(255),
    BalanceOfPaymentsManualInUse VARCHAR(255),
    ExternalDebtReportingStatus VARCHAR(255),
    SystemOfTrade VARCHAR(255),
    GovernmentAccountingConcept VARCHAR(255),
    ImfDataDisseminationStandard VARCHAR(255),
    LatestPopulationCensus VARCHAR(255),
    LatestHouseholdSurvey VARCHAR(255),
    SourceOfMostRecentIncomeAndExpenditureData VARCHAR(255),
    VitalRegistrationComplete VARCHAR(255),
    LatestAgriculturalCensus VARCHAR(255),
    LatestIndustrialData VARCHAR(255),
    LatestTradeData VARCHAR(255),
    LatestWaterWithdrawalData VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS IndicatorsData (
    CountryName VARCHAR(255),
    CountryCode VARCHAR(255),
    IndicatorName VARCHAR(255),
    IndicatorCode VARCHAR(50),
    Year INT,
    Value DECIMAL(10, 7)
);

CREATE TABLE IF NOT EXISTS EconomicIndicators (
    SeriesCode VARCHAR(50),
    Topic VARCHAR(255),
    IndicatorName VARCHAR(255),
    ShortDefinition TEXT,
    LongDefinition TEXT,
    UnitOfMeasure VARCHAR(50),
    Periodicity VARCHAR(50),
    BasePeriod VARCHAR(50),
    OtherNotes TEXT,
    AggregationMethod VARCHAR(255),
    LimitationsAndExceptions TEXT,
    NotesFromOriginalSource TEXT,
    GeneralComments TEXT,
    Source TEXT,
    StatisticalConceptAndMethodology TEXT,
    DevelopmentRelevance TEXT,
    RelatedSourceLinks TEXT,
    OtherWebLinks TEXT,
    RelatedIndicators TEXT,
    LicenseType VARCHAR(50)
);

-- I used the LOAD DATA LOCAL INFILE to import the 500k rows because it takes too long in import wizard
LOAD DATA LOCAL INFILE 'C:/Users/admin/Downloads/Indicators.csv/Indicators.csv'
INTO TABLE indicatorsdata
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM indicatorsdata;
SELECT * FROM countrydata;
SELECT * FROM economicindicators;

SELECT CountryName, CountryCode, IndicatorName
FROM IndicatorsData;

-- 1. Exploring Data
-- Retrieving the values of CountryName for all countries
SELECT DISTINCT CountryName
FROM IndicatorsData;
               
-- Grouping and counting records by region
SELECT Region, COUNT(*) AS Count
FROM CountryData
GROUP BY Region
ORDER BY 2 DESC;

-- Philippines Data               
SELECT * FROM IndicatorsData WHERE CountryName = "Philippines";

-- Information for the countries from the year of 2000
SELECT * FROM IndicatorsData WHERE Year = "2000";

-- Selecting by year and country
SELECT Value FROM IndicatorsData WHERE Year >=1990 AND CountryName = "Russian Federation";

-- Selecting by year and multiple country name
SELECT * FROM IndicatorsData WHERE Year >1999 AND CountryName IN ('Central African Republic', 'Rwanda');

-- 2. Union Details for Chile of 2010 and Peru of 2011 together
SELECT * FROM IndicatorsData WHERE (CountryName = "Chile" AND Year=2010) UNION SELECT * FROM IndicatorsData
WHERE (CountryName = "Peru" AND Year=2011);

-- 3. IndicatorName for the countries not started with the letter 'P' and arranged the list as the most recent comes first, then by name in order
SELECT * FROM IndicatorsData WHERE CountryName NOT LIKE 'P%' ORDER BY YEAR DESC, IndicatorName;

-- 4. Calculating the average value of urban population
SELECT AVG(Value) FROM IndicatorsData WHERE IndicatorName = 'Urban population';

-- 5. The lowest GDP per capita in 2013
SELECT CountryName, Value
FROM IndicatorsData
WHERE IndicatorName = 'GDP per capita (current US$)' 
AND Year = 2013
AND Value = (
    SELECT MIN(Value)
    FROM IndicatorsData
    WHERE IndicatorName = 'GDP per capita (current US$)' 
    AND Year = 2013
);

-- 6. Displaying the countries with the highest GDP per capita in 2009
SELECT * FROM IndicatorsData WHERE IndicatorName='GDP per capita (current US$)' AND Year= 2009
ORDER BY Value DESC
LIMIT 10;

-- 7. Comparing Life expectancy at birth max values for Russian Federation, Bolivia, United States, Nigeria and India from 2012 inclusive
SELECT CountryName, MAX(Value)
FROM IndicatorsData
WHERE IndicatorName= 'Life expectancy at birth, total (years)'
AND CountryName IN (
'Russian Federation', 'Bolivia',
'United States', 'Nigeria', 'India'
)
AND Year>=2012
GROUP BY CountryName;

-- 8. Death rate in Latin America
SELECT * FROM IndicatorsData
WHERE IndicatorName='Death rate, crude (per 1,000 people)'
AND CountryName LIKE 'Latin America%'
ORDER BY Value ASC;

-- 9. Sum of hospital beds
SELECT SUM(Value) FROM IndicatorsData WHERE IndicatorName = 'Hospital beds (per 1,000 people)';

-- 10. Fertility rate in Bolivia
SELECT IndicatorsData.*, EconomicIndicators.LongDefinition
FROM IndicatorsData
LEFT JOIN EconomicIndicators 
ON IndicatorsData.IndicatorName  = EconomicIndicators.IndicatorName
WHERE IndicatorsData.IndicatorName LIKE 'Fertility rate%' AND CountryName ='Bolivia';
                
-- 11. CO2 emissions in the world
SELECT IndicatorsData.*, EconomicIndicators.LongDefinition FROM IndicatorsData
LEFT JOIN EconomicIndicators ON IndicatorsData.IndicatorName  = EconomicIndicators.IndicatorName
WHERE IndicatorsData.IndicatorName LIKE 'CO2%'
AND CountryName ='World'
ORDER BY Year DESC
LIMIT 10;

-- 12. Average FDI Net Inflows as a Percentage of GDP by Region
SELECT c.Region, AVG(i.Value) AS AvgFDIInflowsPercentage
FROM IndicatorsData i
INNER JOIN CountryData c ON i.CountryCode = c.CountryCode
WHERE i.IndicatorName = 'Foreign direct investment, net inflows (% of GDP)'
GROUP BY c.Region;

-- 13. Countries with the Highest Adolescent Fertility Rate in 1960
SELECT i.CountryName, i.Value AS AdolescentFertilityRate
FROM IndicatorsData i
WHERE i.IndicatorName = 'Adolescent fertility rate (births per 1,000 women ages 15-19)' AND i.Year = 1960
ORDER BY i.Value DESC
LIMIT 10;

-- 14. The total population of each region in 2010
SELECT c.Region, SUM(i.Value) AS TotalPopulation
FROM IndicatorsData i
INNER JOIN CountryData c ON i.CountryCode = c.CountryCode
WHERE i.IndicatorName = 'Population, total' AND i.Year = 2010
GROUP BY c.Region;

-- 15. The country with the highest inflation rate (CPI) in 2008
SELECT i.CountryName, i.Value AS InflationRate
FROM IndicatorsData i
WHERE i.IndicatorName = 'Inflation, consumer prices (annual %)' AND i.Year = 2008
ORDER BY i.Value DESC
LIMIT 1;

-- 16. Countries with the highest life expectancy in Europe & Central Asia for 2000
SELECT i.CountryName, i.Value AS LifeExpectancy
FROM IndicatorsData i
INNER JOIN CountryData c ON i.CountryCode = c.CountryCode
WHERE i.IndicatorName = 'Life expectancy at birth, total (years)' AND i.Year = 2000
AND c.Region = 'Europe & Central Asia'
ORDER BY i.Value DESC
LIMIT 10;

-- 17. Sum of foreign direct investment (net inflows) as a percentage of GDP by region in 2010
SELECT c.Region, SUM(i.Value) AS TotalFDI
FROM IndicatorsData i
INNER JOIN CountryData c ON i.CountryCode = c.CountryCode
WHERE i.IndicatorName = 'Foreign direct investment, net inflows (% of GDP)' AND i.Year = 2010
GROUP BY c.Region;

-- 18. Growth rate of population in South Asia from 2010 to 2020
SELECT i.CountryName, (MAX(i.Value) - MIN(i.Value)) / MIN(i.Value) * 100 AS PopulationGrowthRate
FROM IndicatorsData i
INNER JOIN CountryData c ON i.CountryCode = c.CountryCode
WHERE i.IndicatorName = 'Population, total' AND i.Year BETWEEN 2010 AND 2020
AND c.Region = 'South Asia'
GROUP BY i.CountryName;

-- 19. Top 10 Countries by GDP Growth Rate from 2010 to 2020
SELECT i.CountryName, 
       (MAX(i.Value) - MIN(i.Value)) / MIN(i.Value) * 100 AS GDPGrowthRate
FROM IndicatorsData i
WHERE i.IndicatorName = 'GDP growth (annual %)' AND i.Year BETWEEN 2010 AND 2020
GROUP BY i.CountryName
ORDER BY GDPGrowthRate DESC
LIMIT 10;

-- 10. Countries with the Lowest and Highest Fertility Rates in 2005
-- Lowest Fertility Rate
SELECT i.CountryName, i.Value AS FertilityRate
FROM IndicatorsData i
WHERE i.IndicatorName = 'Fertility rate, total (births per woman)' AND i.Year = 2005
ORDER BY i.Value ASC
LIMIT 1;
-- Highest Fertility Rate
SELECT i.CountryName, i.Value AS FertilityRate
FROM IndicatorsData i
WHERE i.IndicatorName = 'Fertility rate, total (births per woman)' AND i.Year = 2005
ORDER BY i.Value DESC
LIMIT 1;




