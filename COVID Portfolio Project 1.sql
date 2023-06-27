SELECT *
FROM PortfolioProject1.CovidDeaths cd 
ORDER BY 3, 4

/*SELECT *
FROM PortfolioProject1.CovidVaccinations cv
ORDER BY 3, 4*/
 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.CovidDeaths cd 
ORDER BY 1,2


/* looking AT total cases vs total deaths
 * shows likelihood of dying if you contract covid in your country*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.CovidDeaths cd 
ORDER BY 1,2


/* looking AT total cases vs population
 * shows what percentage of population got covid*/

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1.CovidDeaths cd 
WHERE location LIKE '%states%'
ORDER BY 1,2


/* looking at countries with highest infection rate compared to population*/

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1.CovidDeaths cd 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

/* showing countries with highest death count per population*/

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM PortfolioProject1.CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/*showing continents with highest death count*/

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM PortfolioProject1.CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

/* Global numbers */

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1.CovidDeaths cd 
/*WHERE location LIKE '%states%'*/
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

/* looking at total population vs vaccinations */

SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1.CovidDeaths dea
JOIN PortfolioProject1.CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


/* use CTE */
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1.CovidDeaths dea
JOIN PortfolioProject1.CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
/*ORDER BY 2, 3*/
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

/* temp table */

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
`Date` DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1.CovidDeaths dea
JOIN PortfolioProject1.CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
/*ORDER BY 2, 3*/

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated

/* creating view to store data for later visualizations*/

CREATE VIEW MyFirstView
AS
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM PortfolioProject1.CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

SELECT * 
FROM MyFirstView
