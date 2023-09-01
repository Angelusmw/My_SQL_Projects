/*
Cancer Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM SQLPortfolioProject..[number-of-deaths-by-cause]
ORDER BY 1

--Determining the number of null values in the Code column

SELECT COUNT(*) AS Missing_code
FROM SQLPortfolioProject..[number-of-deaths-by-cause]
WHERE Code IS NULL

--Replacing Null Values with Underscore in the Code column

UPDATE SQLPortfolioProject..[number-of-deaths-by-cause]
SET Code = '_'
WHERE Code IS NULL

--Calculating the proportion of deaths linked to cancer in the US for individual years

SELECT Entity, Code, Year, [Deaths - Neoplasms - Sex: Both - Age: All Ages (Number)] / ([Deaths - Neoplasms - Sex: Both - Age: All Ages (Number)] + [Number of executions (Amnesty International)] + [Deaths - Meningitis - Sex: Both - Age: All Ages (Number)] + [Deaths - Alzheimer's disease and other dementias - Sex: Both - A] + [Deaths - Parkinson's disease - Sex: Both - Age: All Ages (Number] + [Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N] + [Deaths - Drowning - Sex: Both - Age: All Ages (Number)] + [Deaths - Malaria - Sex: Both - Age: All Ages (Number)] + [Deaths - Interpersonal violence - Sex: Both - Age: All Ages (Num] + [Deaths - HIV/AIDS - Sex: Both - Age: All Ages (Number)] + [Deaths - Drug use disorders - Sex: Both - Age: All Ages (Number)] + [Deaths - Tuberculosis - Sex: Both - Age: All Ages (Number)] + [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] + [Deaths - Lower respiratory infections - Sex: Both - Age: All Age] + [Deaths - Neonatal disorders - Sex: Both - Age: All Ages (Number)] + [Deaths - Alcohol use disorders - Sex: Both - Age: All Ages (Numb] + [Deaths - Self-harm - Sex: Both - Age: All Ages (Number)] + [Deaths - Exposure to forces of nature - Sex: Both - Age: All Age] + [Deaths - Diarrheal diseases - Sex: Both - Age: All Ages (Number)] + [Deaths - Environmental heat and cold exposure - Sex: Both - Age:] + [Deaths - Conflict and terrorism - Sex: Both - Age: All Ages (Num] + [Deaths - Diabetes mellitus - Sex: Both - Age: All Ages (Number)] + [Deaths - Chronic kidney disease - Sex: Both - Age: All Ages (Num] + [Deaths - Poisonings - Sex: Both - Age: All Ages (Number)] + [Deaths - Protein-energy malnutrition - Sex: Both - Age: All Ages] + [Terrorism (deaths)] + [Deaths - Road injuries - Sex: Both - Age: All Ages (Number)] + [Deaths - Chronic respiratory diseases - Sex: Both - Age: All Age] + [Deaths - Cirrhosis and other chronic liver diseases - Sex: Both ] + [Deaths - Digestive diseases - Sex: Both - Age: All Ages (Number)] + [Deaths - Fire, heat, and hot substances - Sex: Both - Age: All A] + [Deaths - Acute hepatitis - Sex: Both - Age: All Ages (Number)]) * 100 AS Percerntage_of_Cancer_Related_Deaths
FROM SQLPortfolioProject..[number-of-deaths-by-cause]
WHERE Entity like '%states%'
ORDER BY 2 asc

-- Countries with highest cancer-related death rates for all ages

SELECT Entity, MAX([Deaths - Neoplasms - Sex: Both - Age: All Ages (Rate)]) AS HighestCancerRelatedDeathRate
FROM SQLPortfolioProject..[cancer-death-rates-by-age]
GROUP BY Entity
ORDER BY HighestCancerRelatedDeathRate DESC

--Year with the highest liver cancer deaths globally 

SELECT Year, SUM([Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]) AS TotalLiverCancerDeaths
FROM SQLPortfolioProject..[total-cancer-deaths-by-type]
GROUP BY Year
ORDER BY TotalLiverCancerDeaths DESC

--Countries and regions with the highest bladder cancer deaths globally 

SELECT Entity, SUM([Deaths - Bladder cancer - Sex: Both - Age: All Ages (Number)]) AS TotalBladderCancerDeaths
FROM SQLPortfolioProject..[total-cancer-deaths-by-type]
GROUP BY Entity
ORDER BY TotalBladderCancerDeaths DESC

--DALYs (Disability-Adjusted Life Years) for liver cancer vs liver cancer deaths 

SELECT dea.Entity, dea.Code, dea.Year, dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)], dalys.[DALYs (Disability-Adjusted Life Years) - Liver cancer - Sex: Bot]
, SUM(dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]) OVER (PARTITION BY dea.Entity ORDER BY dea.Entity, dea.Year) as RollingDeaths
FROM SQLPortfolioProject..[total-cancer-deaths-by-type] dea
JOIN SQLPortfolioProject..[disease-burden-rates-by-cancer] DALYs
	ON dea.Entity = DALYs.Entity
	AND dea.Year = DALYs.Year
WHERE dea.Year IS NOT NULL
ORDER BY 1

-- Using CTE to perform Calculation on Partition By in previous query

WITH DeathsvsDALYs
AS
(
SELECT dea.Entity, dea.Code, dea.Year, dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)], dalys.[DALYs (Disability-Adjusted Life Years) - Liver cancer - Sex: Bot]
, SUM(dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]) OVER (PARTITION BY dea.Entity ORDER BY dea.Entity, dea.Year) as RollingDeaths
FROM SQLPortfolioProject..[total-cancer-deaths-by-type] dea
JOIN SQLPortfolioProject..[disease-burden-rates-by-cancer] DALYs
	ON dea.Entity = DALYs.Entity
	AND dea.Year = DALYs.Year
WHERE dea.Year IS NOT NULL
--ORDER BY 1
)
SELECT *, ([Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]/RollingDeaths)*100 AS PercentageRollingDeaths
FROM DeathsvsDALYs


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentRollingDeaths
CREATE TABLE #PercentRollingDeaths
(
Entity nvarchar(255),
Year nvarchar(255),
Date datetime,
[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)] numeric,
[DALYs (Disability-Adjusted Life Years) - Liver cancer - Sex: Bot] numeric,
RollingDeaths numeric
)

INSERT INTO #PercentRollingDeaths
SELECT dea.Entity, dea.Code, dea.Year, dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)], dalys.[DALYs (Disability-Adjusted Life Years) - Liver cancer - Sex: Bot]
, SUM(dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]) OVER (PARTITION BY dea.Entity ORDER BY dea.Entity, dea.Year) as RollingDeaths
FROM SQLPortfolioProject..[total-cancer-deaths-by-type] dea
JOIN SQLPortfolioProject..[disease-burden-rates-by-cancer] DALYs
	ON dea.Entity = DALYs.Entity
	AND dea.Year = DALYs.Year
WHERE dea.Year IS NOT NULL
--ORDER BY 1

SELECT *, ([Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]/RollingDeaths)*100 AS PercentageRollingDeaths
FROM #PercentRollingDeaths

-- Creating View to store data for later visualizations

CREATE VIEW PercentRollingDeaths AS
SELECT dea.Entity, dea.Code, dea.Year, dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)], dalys.[DALYs (Disability-Adjusted Life Years) - Liver cancer - Sex: Bot]
, SUM(dea.[Deaths - Liver cancer - Sex: Both - Age: All Ages (Number)]) OVER (PARTITION BY dea.Entity ORDER BY dea.Entity, dea.Year) as RollingDeaths
FROM SQLPortfolioProject..[total-cancer-deaths-by-type] dea
JOIN SQLPortfolioProject..[disease-burden-rates-by-cancer] DALYs
	ON dea.Entity = DALYs.Entity
	AND dea.Year = DALYs.Year
WHERE dea.Year IS NOT NULL




