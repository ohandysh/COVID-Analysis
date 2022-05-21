
--Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract COVID in your country 

SELECT location, date, total_cases, total_deaths,ROUND((total_deaths/total_cases)*100, 4) AS death_percentage
  FROM CovidDeaths cd
 WHERE location LIKE 'South Korea'
 ORDER BY 1,2;
 

-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 4) AS confirmed_percentage
  FROM CovidDeaths cd
 WHERE location LIKE 'South Korea'
 ORDER BY 1,2;
 

-- Looking at countries with HIGHEST INFECTION RATE compared to population

SELECT location, population, MAX(total_cases) as HighesstInfectionCNT, ROUND(MAX(total_cases/population),4)*100 AS PercentPopulation
  FROM CovidDeaths cd
 GROUP BY location, population
 ORDER BY PercentPopulation DESC;

-- Looking at countries with Highest Death Count per Population

SELECT location, population, MAX(total_deaths) as HighesstDeathsCNT, ROUND(MAX(total_deaths/population),4)*100 AS PercentPopulation
  FROM CovidDeaths cd
 GROUP BY location, population
 ORDER BY PercentPopulation DESC;
 
-- Let's Break things down by country


SELECT location, MAX(CAST(total_deaths AS INT))
  FROM CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location
 ORDER BY location;

-- Let's Break things down by continent

SELECT continent, MAX(CAST(total_deaths AS INT))
  FROM CovidDeaths
 WHERE continent <> ''
 GROUP BY continent
 ORDER BY continent;
 
 
-- Looking at continents with the highest death count per population

SELECT continent, (MAX(total_deaths)/population) AS HighestDeathCNTByPopulation
  FROM CovidDeaths
 GROUP BY continent, population;


-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_death, 
	   ROUND(SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float))*100,4) AS DeathPercentage
  FROM CovidDeaths
 WHERE new_cases <> 0
 GROUP BY date
 ORDER BY 1,2


-- Looking at total population v vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
  FROM CovidDeaths cd
  JOIN CovidVaccinations cv
    ON cd.location = cv.location
   AND cd.date = cv. date
 WHERE cd.continent <> '' AND cv.new_vaccinations <> ''
 ORDER BY 2,3;


SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CONVERT(FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollupPeopleVaccinated
  FROM CovidDeaths cd
  JOIN CovidVaccinations cv
    ON cd.location = cv.location
   AND cd.date = cv.date
 WHERE cd.continent <> '' AND cv.new_vaccinations <> ''
 ORDER BY 2,3;

-- USE CTE

  WITH Pop_Vac (continent, location, date, population, new_vaccinations, RollupPeopleVaccinated)
    AS (SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CONVERT(FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollupPeopleVaccinated
  FROM CovidDeaths cd
  JOIN CovidVaccinations cv
    ON cd.location = cv.location
   AND cd.date = cv.date
 WHERE cd.continent <> '' AND cv.new_vaccinations <> '' 
 ) 
SELECT *, (RollupPeopleVaccinated/population)*100 AS VaccinatedPercentage
  FROM Pop_Vac;
 
 
 -- TEMP TABLE
 
 DROP TABLE IF EXISTS PercentPopulationVaccinated
 
CREATE TABLE PercentPopulationVaccinated 
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date	 DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollupPeopleVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CONVERT(FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollupPeopleVaccinated
  FROM CovidDeaths cd
  JOIN CovidVaccinations cv
    ON cd.location = cv.location
   AND cd.date = cv.date
 WHERE cd.continent <> '' AND cv.new_vaccinations <> ''
SELECT *, (RollupPeopleVaccinated/population)*100 AS VaccinatedPercentage
  FROM PercentPopulationVaccinated;
 
 
 
-- CREATING VIEW to store data for later visualizations
 
 CREATE VIEW PercentPopulationVaccinatedTemp AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CONVERT(FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollupPeopleVaccinated
  FROM CovidDeaths cd
  JOIN CovidVaccinations cv
    ON cd.location = cv.location
   AND cd.date = cv.date
 WHERE cd.continent <> '' AND cv.new_vaccinations <> ''
 
 
 
 SELECT * 
   FROM PercentPopulationVaccinatedTemp

