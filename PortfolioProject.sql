--select * from PortfolioProject.dbo.CovidDeaths order by date

--select * from PortfolioProject.dbo.CovidVaccinations

-------------------------------------------------------------------------------------------------------------------------------------------
--LET'S BREAK DOWN THINGS BY COUNTRY

-----------------1-------------------
select  Location, date, total_cases, new_cases, total_deaths from PortfolioProject.dbo.CovidDeaths order by 1,2 

-----------------2-------------------

--looking for Total cases vs total deaths


select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths 
--where location='india'
order by 1,2

-----------------3-------------------

--looking for total cases vs population

select  Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths 
where location='india'
order by 1,2

-----------------4-------------------

--looking at countries with highest infection rate compared to population

select  Location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths 
--where location='india'
Group by Location, population
order by PercentagePopulationInfected DESC

-----------------5-------------------

--looking for countries with highest death counts per population


select  Location, population, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
Group by location,population
Order by TotalDeathCounts DESC,population

-----------------6-------------------

--Creating stored procedure to get information for a specific country/location

DROP PROCEDURE IF EXISTS GetInformationForACountry
CREATE PROCEDURE GetInformationForACountry  @location nvarchar(40)
AS
--SQL Query for stored procedure--GetInformationForACountry

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected,
MAX((total_deaths/total_cases))*100  as DeathPercentage,  MAX(cast(total_deaths as int)) AS TotalDeathCounts
FROM PortfolioProject..CovidDeaths 
WHERE location = @Location and continent is not null
Group by Location,Population

--EXECUTION stored procedure--GetInformationForACountry

EXEC GetInformationForACountry @location='India'


-----------------------------------------------------------------------------------------------------------------------------------------------------
--LETS'S BREAK DOWN INFORMATIONS BY CONTINENETS
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Looking for continenets with highest death count
-----------------7-------------------(wrong values)

Select  continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
Group by Continent
Order by TotalDeathCounts DESC

-----------------7-------------------

Select  location, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject.dbo.CovidDeaths 
where continent is null
Group by location
Order by TotalDeathCounts DESC


-----------------------------------------------------------------------------------------------------------------------------------------------------
--LETS'S BREAK DOWN INFORMATIONS FOR WORLD
-----------------------------------------------------------------------------------------------------------------------------------------------------
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


--select * from PortfolioProject.dbo.CovidVaccinations
-----------------8-------------------

--looking for total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativeVaccination
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by  2,3

-----------------9-------------------
--Using CTE to find percentage people vaccinated


with Popvsvac ( continent, location, date, population, new_vaccination, cummulativeVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativeVaccination
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by  2,3
)
select location, max((cummulativeVaccination/population))*100 as percentagePeoplaVaccinated from Popvsvac
group by location
--select *,(cummulativeVaccination/population)*100 as percentagePeoplaVaccinated from Popvsvac

----------------------------10------------------

--Using temp table to find percentage people vaccinated

drop table if exists #PercentPeopleVaccinated
create Table #PercentPeopleVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
cummulativeVaccination numeric
)
insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativeVaccination
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by  2,3
select *,(cummulativeVaccination/population)*100 as percentagePeoplaVaccinated from #PercentPeopleVaccinated

-------------------------------------------------------------------THE END----------------------------------------------------------------------























