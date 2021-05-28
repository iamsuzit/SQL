Select *
From PortfolioProjectx..CovidDeaths
Order by 3,4

Select *
From PortfolioProjectx..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProjectx..CovidVaccinations
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectx..CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths (Death percentage of the people who died that had Covid) 
Select location, date, total_cases, total_deaths, 
round(((total_deaths/total_cases)*100), 4) as DeathPercentage
From PortfolioProjectx..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Total cases vs Population
Select location, date, population,total_cases,  
round(((total_cases/population)*100), 4) as InfectedPopulation
From PortfolioProjectx..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount,  
MAX(round(((total_cases/population)*100), 4)) as InfectedPopulation
From PortfolioProjectx..CovidDeaths
Group by location, population
Order by InfectedPopulation desc

--Countries with the highest death rate per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectx..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Result by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectx..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Continents with the highest death count per population
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectx..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers by new cases
Select date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
From PortfolioProjectx..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
From PortfolioProjectx..CovidDeaths
Where continent is not null
Order by 1,2

--Total population vs vaccination per day
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Convert(int, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProjectx..CovidDeaths dea
Join PortfolioProjectx..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
Order by 2,3
 
 --Using CTE
With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingVaxCount)
 as (
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Convert(int, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProjectx..CovidDeaths dea
Join PortfolioProjectx..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
)
Select *, (RollingVaxCount/Population)*100 as Percentage
From PopvsVax


--Temp table
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaxCount numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Convert(int, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProjectx..CovidDeaths dea
Join PortfolioProjectx..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date

Select *, (RollingVaxCount/Population)*100 as Percentage
From #PercentPopulationVaccinated

--Creating View to store data for Vizualizations
Create View PercentPopulationVax as 
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Convert(int, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProjectx..CovidDeaths dea
Join PortfolioProjectx..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null

Select * 
From PercentPopulationVax