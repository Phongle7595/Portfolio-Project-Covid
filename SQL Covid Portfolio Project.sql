Select*
From PortfolioProject..CovidDeaths
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4



--Select data that we are starting with

Select  location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Comparing Total Cases vs Total Deaths (to show the probability of dying if you have Covid in the US)

Select  location, date, total_cases,total_deaths, (CAST (total_deaths as decimal)/CAST (total_cases as decimal))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Comparing Total Cases vs Population (to show the probability of getting infected in the US)

Select  location, date, population,total_cases, (CAST (total_cases as float)/CAST (population as float))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to population (ordered by highest likelihood to get infected)

Select  location, population,MAX(total_cases) as MostInfectionCount, MAX((CAST (total_cases as float)/CAST (population as float)))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
group by location, population
order by InfectionPercentage desc

-- Countries with highest death count

Select  location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

-- Continent with highest death

Select  location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
group by location
order by TotalDeathCount desc

Select  continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Death Percentage sorted by each date

Select date, SUM(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
	AND new_cases is not null
Group by date
order by 1,2


Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVacRolling
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date	
Where dea.continent is not null
order by 2,3

--USE CTE in previous query to calculate population vs vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVacRolling)
as
(Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVacRolling
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date	
Where dea.continent is not null
)
Select *, (TotalPeopleVacRolling/population)*100
From PopvsVac
Where TotalPeopleVacRolling is not null

--Temp Table

Drop table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
new_vaccinations bigint,
TotalPeopleVacRolling bigint)

Insert into PercentPopulationVaccinated
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVacRolling
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date	
Where dea.continent is not null

Select *, (TotalPeopleVacRolling/population)*100
From PercentPopulationVaccinated