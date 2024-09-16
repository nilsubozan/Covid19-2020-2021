BULK INSERT dbo.CovidVaccinations
FROM '/var/opt/mssql/data/CovidDeaths2.csv'
WITH 
(
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are using
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY [location],[date]

--Total Cases Vs Total Deaths in the United States
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths WHERE location like '%states%'
and continent IS NOT NULL
ORDER BY [location],[date]

--Changing the data types to achieve desired outcomes
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population FLOAT;

--Looking at the total cases vs Population in the United States
SELECT location, date, total_cases,population, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY [location],[date]

--Looking at Countries with highest infection rate
SELECT
location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location],[population],date
order by infection_rate DESC

--Showing the countries with the highest death count
SELECT
location, MAX(total_deaths) as totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location]
order by totalDeathCount DESC

--Continents with highest death count
SELECT location, MAX(total_deaths) as totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
and location not in ('World','European Union', 'International')
Group by location
ORDER by totalDeathCount DESC


--Global Numbers

--TotalCases,TotalDeaths, Deathpercentage per day
SELECT date, sum(new_cases) as TotalCases,
sum(new_deaths) as TotalDeaths,
(sum(new_deaths)/sum(new_cases))*100 As DeathPercentagePerDay
 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group BY date
ORDER BY 1


--Overall Global Results
SELECT sum(new_cases) as TotalCases,
sum(new_deaths) as TotalDeaths,
(sum(new_deaths)/sum(new_cases))*100 As DeathPercentagePerDay
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1


--Covid Vaccinations Table
--Total Population Vs Vaccinations

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER(PARTITION BY CD.location ORDER BY CD.date)
AS rolling_people_vaccinated
FROM
PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV 
ON CV.location=CD.location and CV.date=CD.date
WHERE CD.continent IS NOT NULL
order by 2,3


--Total number of vaccinations per Country

WITH PopVsVac AS (
    SELECT 
        CD.continent, 
        CD.location, 
        CD.date, 
        CD.population, 
        CV.new_vaccinations,
        SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths CD
    JOIN 
        PortfolioProject..CovidVaccinations CV 
    ON 
        CV.location = CD.location AND CV.date = CD.date
    WHERE 
        CD.continent IS NOT NULL
)

SELECT 
    continent, 
    location, 
    MAX(rolling_people_vaccinated) AS total_number_of_vaccinations
FROM 
    PopVsVac
GROUP BY 
    continent, location, population
ORDER BY 
    continent,location;




-- Vaccination/Population
WITH PopVsVac AS (
    SELECT 
        CD.continent, 
        CD.location, 
        CD.date, 
        CD.population, 
        CV.new_vaccinations,
        SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths CD
    JOIN 
        PortfolioProject..CovidVaccinations CV 
    ON 
        CV.location = CD.location AND CV.date = CD.date
    WHERE 
        CD.continent IS NOT NULL
)

SELECT 
    continent, 
    location,
    date,
    population,
    new_vaccinations,
    rolling_people_vaccinated,
    (rolling_people_vaccinated / population) * 100 AS vaccination_rate
FROM 
    PopVsVac
ORDER BY 
    continent, location, date;


-- Creating view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
        CD.continent, 
        CD.location, 
        CD.date, 
        CD.population, 
        CV.new_vaccinations,
        SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths CD
    JOIN 
        PortfolioProject..CovidVaccinations CV 
    ON 
        CV.location = CD.location AND CV.date = CD.date
    WHERE 
        CD.continent IS NOT NULL


SELECT * FROM PercentPopulationVaccinated










