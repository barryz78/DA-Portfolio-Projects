Select *
From portfolio..CovidDeaths
where continent is not null
order by 3,4

Select *
From portfolio..CovidVaccinations
order by 3,4

--Select data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as ContractionRate
From portfolio..CovidDeaths
-- Where location like '%states%'
order by 1,2

--Looking at Countries with highest infection ratre compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as ContractionRate
From portfolio..CovidDeaths
Group by Location, population
order by ContractionRate desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--See it by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From portfolio..CovidDeaths
where continent is not null
order by 1,2 

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location, 
dea.Date) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3


--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location, 
dea.Date) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location, 
dea.Date) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Create View to store data for later visualization
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location, 
dea.Date) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated