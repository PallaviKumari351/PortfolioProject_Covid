SELECT *
FROM MyProject..CovidDeaths 
WHERE Continent is NOT NULL
ORDER BY 3,4

SELECT Location,date, total_cases,total_deaths,population
FROM MyProject..CovidDeaths 
WHERE Continent is NOT NULL
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS
SELECT Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM MyProject..CovidDeaths 
WHERE Continent is NOT NULL
ORDER BY 1,2

SELECT Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM MyProject..CovidDeaths 
WHERE Location ='India'
AND 
Continent is NOT NULL
ORDER BY 1,2

--TOTAL CASES VS TOTAL POPULATION
SELECT Location,date, total_cases,Population, (total_cases/population)*100 as PercentagePopulationInfected
--WHERE Location ='India'
FROM MyProject..CovidDeaths 
WHERE Continent is NOT NULL
ORDER BY 1,2

--LOOKING FOR COUNTRIES WITH HIGHEST INFECTION RATE
SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, Population, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM MyProject..CovidDeaths 
--WHERE Location ='India'
WHERE Continent is NOT NULL
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT WITH RESPECT TO POPULATION - BY LOCATION
SELECT Location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount -- DATATYPE OF total_deaths is nVARCHAR
FROM MyProject..CovidDeaths 
--WHERE Location ='India'
WHERE Continent is NOT NULL -- AT MANY PLACES IN TABLE CONTINENT NAME COME INTO THE LOCATION COLUMN AND CONTINENT IS NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC

----COUNTRIES WITH HIGHEST DEATH COUNT WITH RESPECT TO POPULATION - BY LOCATION
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount -- DATATYPE OF total_deaths is nVARCHAR
FROM MyProject..CovidDeaths 
--WHERE Location ='India'
WHERE Continent is NOT NULL -- AT MANY PLACES IN TABLE CONTINENT NAME COME INTO THE LOCATION COLUMN AND CONTINENT IS NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

SELECT Location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount -- DATATYPE OF total_deaths is nVARCHAR
FROM MyProject..CovidDeaths 
--WHERE Location ='India'
WHERE Continent is NULL 
GROUP BY Location
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS INT)) AS DeathPercentage,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM MyProject..CovidDeaths 
WHERE Continent is NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS INT)) AS DeathPercentage,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM MyProject..CovidDeaths 
WHERE Continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


--TOTAL POPULATION vs VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination

FROM MyProject..CovidDeaths dea
JOIN MyProject..CovidVaccinations vac
   ON dea.location=vac.location
   And dea.date=vac.date
WHERE dea.continent is NOT NULL 
--AND dea.location ='India'
order BY 2,3


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination

FROM MyProject..CovidDeaths dea
JOIN MyProject..CovidVaccinations vac
   ON dea.location=vac.location
   And dea.date=vac.date
WHERE dea.continent is NOT NULL 
--AND dea.location ='India'
order BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_percent_population
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyProject..CovidDeaths dea
Join MyProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select*
from PercentPopulationVaccinated