select * 
from PortfolioProject..CovidMorts
where continent is not null
order by 3,4



--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using 


select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidMorts
order by 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contrat covid in your country 
select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage
from PortfolioProject..CovidMorts
where location like '%France%'
order by 1,2



-- Looking at Total Cases vs Population 
--Shows what percentage of population got covid

select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 as PercentageofPopulationInfected
from PortfolioProject..CovidMorts
where location like '%France%'
order by 1,2 asc



-- Looking at countries with Highest Infection Rate compared to Population

select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 as PercentageofPopulationInfected
from PortfolioProject..CovidMorts
--where location like '%France%'
group by location, population
order by PercentageofPopulationInfected desc


-- Showing the Countries with the Highest Death Count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidMorts
where continent is not null 
group by location
order by TotalDeathCount desc



select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidMorts
group by location
order by TotalDeathCount desc



select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidMorts
group by continent
order by TotalDeathCount desc



-- Global Numbers
 select SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(nullif(cast(new_cases as float),0))*100 as TotalDeathPercentage
from PortfolioProject..CovidMorts
--where location like '%France%'
where continent is not null
--group by date
order by 1,2

select *
from PortfolioProject..CovidMorts mor
Join PortfolioProject..CovidVaccins vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null

-- Looking at total population vs vaccinations

select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
from PortfolioProject..CovidMorts mor
Join PortfolioProject..CovidVaccins vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
order by 2,3


select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by mor.location order by mor.location, mor.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidMorts mor
Join PortfolioProject..CovidVaccins vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(select mor.continent, mor.location, mor.date, cast(mor.population as bigint), cast(vac.new_vaccinations as bigint), SUM(cast(vac.new_vaccinations as bigint)) over(partition by mor.location order by mor.location, mor.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidMorts mor
Join PortfolioProject..CovidVaccins vac
	on mor.location = vac.location
	and mor.date = vac.date
--order by 2,3
)
Select *, (cast(nullif(RollingPeopleVaccinated,0)as decimal)/cast(nullif(Population,0)as decimal)) *100
from PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population bigint,
New_vaccinations bigint,
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by mor.location order by mor.location, mor.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidMorts mor
Join PortfolioProject..CovidVaccins vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/nullif(Population,0))*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualization

Create view PercentofPopulationVaccinated as
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by mor.location order by mor.location, mor.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidMorts mor
Join PortfolioProject..CovidVaccins vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2,3






