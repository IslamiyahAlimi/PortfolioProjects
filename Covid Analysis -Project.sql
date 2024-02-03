SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Selection of Data i will be Using for this project
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at the total cases VS the total death
--Shows the likelyhood of dying if one contact Covid 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at total cases VS population
--This will show the total number of people who got affected by Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as affected_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at the Country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighInfectionCount, MAX(total_cases/population)*100 as affected_population_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY affected_population_percentage DESC

--Showing Countries with highest death count per population

SELECT location, population, MAX(CAST(total_deaths as int)) as MaxDeathRate
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
GROUP BY Location, Population
ORDER BY MaxDeathRate DESC

--Showing Countries with highest death count per population percentage

SELECT Location, population, MAX(total_deaths) as MaxDeathRate, MAX(total_deaths/total_cases)*100 as highest_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
GROUP BY Location, Population
ORDER BY highest_death_percentage DESC

--Breaking it down by Continent
--CAST Function i used here is to convert to integer to give accurate result

SELECT Continent, MAX(CAST(total_deaths as int)) as MaxDeathRate
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
GROUP BY Continent
ORDER BY MaxDeathRate DESC


--GLOBAL NUMBERS
--The total number of cases across the World

SELECT SUM (new_cases)as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS total_death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE Continent is   NOT NULL
ORDER BY 1,2

--Using the Vaccination Table
SELECT *
FROM PortfolioProject..CovidVaccinations

--Joining Tables Together
SELECT *
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date

--Total Population Vs Total Vaccination
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent is NOT NULL
   ORDER BY 2,3

   --The Total New_Vaccinations
   SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
   SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent is NOT NULL
   ORDER BY 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
   SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent is NOT NULL

-- ORDER BY 2,3
)

Select *, (RollingPeopleVaccination/population)* 100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccination numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
   SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
-- WHERE DEA.continent is NOT NULL

-- ORDER BY 2,3

Select *, (RollingPeopleVaccination/population)* 100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create view PercentPopulationVaccinated as 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
   SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent is NOT NULL

-- ORDER BY 2,3

select *
From PercentPopulationVaccinated