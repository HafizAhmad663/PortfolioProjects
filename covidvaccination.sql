SELECT *
FROM CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to use 

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--Looking at Total_Cases vs Tota_Deaths
Select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPerentage
from CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--Looking at Total_Cases vs Popution
--Shows wht percentage of population got covid

 Select location, date, total_cases, population,  (total_cases/population)*100 as CasesPerentage
from CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2

-- Countries with highest infected rate over population

Select location,MAX(total_cases) AS max_total_cases, population,  (MAX(total_cases)/population)*100 as CasesPerentage
from CovidDeaths
where continent is not null
Group BY location,population
--having location like '%pakistan%'
order by CasesPerentage

-- Showing Countries with HiGHEST Death Rate Over Population
-- People died over population 

Select location,MAX(cast(total_deaths as int)) AS max_total_deaths
from CovidDeaths
where continent is not null
Group BY location
order by max_total_deaths desc

-- Let's Break things about CONTINENTS

Select location,MAX(cast(total_deaths as int)) AS max_total_deaths
from CovidDeaths
where continent is null
Group BY location
order by max_total_deaths desc


Select continent,MAX(cast(total_deaths as int)) AS max_total_deaths
from CovidDeaths
where continent is not null
Group BY continent
order by max_total_deaths desc

-- Global Deaths Number Over Population

SELECT
    SUM(cast(total_deaths as int)) AS total_deaths,
    SUM(population) AS total_population,
    (SUM(cast(total_deaths as int)) / SUM(population)) * 100 AS death_rate_per_100
FROM CovidDeaths
order by 1,2

-- Global Deaths over Cases

SELECT
   SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100
FROM CovidDeaths
where continent is not null
ORDER BY 1,2


					/* WORKING ON NEW TABLE FROM DATABASE
							PROJECT_POTFOLIO.DBO.COVIDVACCINES */

/*Calculating Total Population vs Vaccinations*/

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
Order By dea.location, dea.date
) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccines vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null

order by 2,3


-- WITH CTE

WITH PopvsVac( continent,location,date,population,vaccination,RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccines vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null
 --order by 2,3
)
SELECT *, (RollingPeopleVaccination/population) * 100 as VaccinatedPercentage
FROM PopvsVac	


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentVaccinatedPopultion
create table #PercentVaccinatedPopultion
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
vaccination numeric,
RollingPeopleVaccination numeric
)

insert into #PercentVaccinatedPopultion
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccines vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
--where dea.continent is not null
 --order by 2,3

select *,(RollingPeopleVaccination/population)*100 
from #PercentVaccinatedPopultion

--Creatng View for Later Visuaization

CREATE VIEW PercentVaccinatedPopulation as
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccines vac
	on dea.location = vac.location
	and 
	dea.date = vac.date

SELECT *
FROM PercentVaccinatedPopulation