Select *
From covid.Deaths
where continent is not null
order by 3,4

Select *
From covid.Vaccinations
where continent is not null
order by 3,4

--Select and preview relevant data
Select Location, date, total_cases, new_cases, total_deaths, population
From covid.Deaths
Where continent is not null
order by 1,2

--Look at Total Cases vs Total Deaths, and using them to find a Death Percentage in the United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid.Deaths
Where location like '%States%' and continent is not null 
order by 1,2

--Looking at Total Cases vs Population, and using them to find a Contraction Rate in the United States
Select Location, date, total_cases, population, (total_cases/population)*100 as ContractionRate
From covid.Deaths
Where location like '%States%' and continent is not null 
order by 1,2

--Sorting countries from highest contraction rate to lowest
Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as ContractionRate
From covid.Deaths
Group by Location, population
order by ContractionRate desc

--Sorting countries from highest Total Death Count to lowest
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid.Deaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--Now sorted by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid.Deaths
where continent is null
Group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Displays total cases, total deaths, and a death percentage globally
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From covid.Deaths
where continent is not null
order by 1,2 

--Join Covid Deaths with Vaccinations on location and date, calculate RollingPeopleVaccinated by continuously adding new vaccinations in the same area
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid.Deaths dea
Join covid.Vaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Create a common table expression to use RollingPeopleVaccinated in a calculation
With PopvsVac AS (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location, dea.Date) as RollingPeopleVaccinated
  From covid.Deaths dea
  Join covid.Vaccinations vac
  On dea.location = vac.location 
  and dea.date= vac.date
  where dea.continent is not null)
Select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Use a temp table to perform calculation 
CREATE OR REPLACE TABLE covid.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid.Deaths dea
JOIN covid.Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--Now it is possible to calculate the percentage of people that are vaccinated 
SELECT *, (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM covid.PercentPopulationVaccinated
