/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths$
--Where location like '%states%'
----where location = 'World'
--Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select continent, sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc 


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












--select the data that we are going to use
select continent, location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;


-- looking at total_deaths vs total_cases
-- shows liklihood of a person dying 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths$
where location like '%pak%'  
order by 1,2;

-- total_cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as death_percentage
from PortfolioProject..CovidDeaths$
where location like '%india%'
and continent is not null
order by 1,2;


-- looking at countries with the higest infection rate comapred with the population
Select location, MAX(total_cases) as total_cases, MAX(population) as population,
       MAX((total_cases/population))*100 as infection_percentage	   
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
Order by 4 DESC;

-- Countries with the highest death count as per population
Select continent, MAX(cast(total_deaths as int)) as total_deaths	   
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by 2 DESC;



-- Continent with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as total_deaths	   
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by 2 DESC;


-- Death percentage across the world
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
       (SUM(cast(new_deaths as int))/ sum(new_cases))*100 as death_percentage	   
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
Order by 1;


-- Total population vs Total vaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
	   vacc.new_vaccinations, SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER 
	   (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
	   as CummulativeVacc
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccination$ vacc
	 ON deaths.location = vacc.location
	 AND deaths.date = vacc.date
WHERE deaths.continent is not null
order by 2,3;



-- using CTE(Common Table Expression)
WITH PopvsVac (continent, location, date, population, new_vaccinations, CummulativeVacc)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
	   vacc.new_vaccinations, SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER 
	   (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
	   as CummulativeVacc
	   --, (CummulativeVacc/population)*100 as percentage_of_population_vaccinated
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccination$ vacc
	 ON deaths.location = vacc.location
	 AND deaths.date = vacc.date
WHERE deaths.continent is not null
--order by 2,3
)
select *,(CummulativeVacc/population)*100 
from PopvsVac




-- using TEMP Table
DROP TABLE IF EXISTS temp_table
CREATE TABLE temp_table
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
cummulativevaccinations numeric
)

insert into temp_table
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
	   vacc.new_vaccinations, SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER 
	   (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
	   as CummulativeVacc
	   --, (CummulativeVacc/population)*100 as percentage_of_population_vaccinated
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccination$ vacc
	 ON deaths.location = vacc.location
	 AND deaths.date = vacc.date
--WHERE deaths.continent is not null
--order by 2,3

SELECT *, (cummulativevaccinations/Population)*100 
FROM temp_table


-- Creating view to store data for visulaization
CREATE VIEW DeathsPerContinent AS
Select continent, MAX(cast(total_deaths as int)) as total_deaths	   
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
--Order by 2 DESC;

select * 
from DeathsPerContinent