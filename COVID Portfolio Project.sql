

select 
location
,date
,total_cases
,new_cases
,total_deaths
,population
from ProjectFolder.dbo.COVID_DEATHS
order by 1,2


--Looking at total cases vs total deaths
--Shows likelihood of dying if you contracted COVID in the United States
select 
location
,date
,total_cases
,total_deaths
,(total_deaths/total_cases)*100 as DeathPercentage
from ProjectFolder.dbo.COVID_DEATHS
where location like '%states%'
order by 1,2;


--Looking at total cases vs. population 
--Shows what percentage the population got COVID in the US

select 
location
,date
,population
,total_cases
,(total_cases/population)*100 as PercentofPopulationInfected
from ProjectFolder.dbo.COVID_DEATHS
--where location like '%states%'
order by 1,2;


--Looking at countries with the highest infection rate comparted to population 
select 
location
,population
,MAX(total_cases) as HighestInfectionCount
,MAX(total_cases/population)*100 as PercentofPopulationInfected
from ProjectFolder.dbo.COVID_DEATHS
group by location,population 
order by PercentofPopulationInfected desc;


--Showing continents with the highest death count per population
select 
continent
,MAX(total_deaths) as totaldeathcount
from ProjectFolder.dbo.COVID_DEATHS
where continent IS NOT NULL
group by continent
order by totaldeathcount desc;


--Global Numbers
select 
date
,SUM(new_cases) as TotalGlobalCases
,SUM(cast(new_deaths as int)) as TotalGlobalDeaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercetantage
from ProjectFolder.dbo.COVID_DEATHS
where continent IS NOT NULL
and new_cases <> 0
group by date
order by 1,2;



--Looking at total population vs vaccinations 
select 
a.continent
,a.location
,a.date
,a.population
,b.new_vaccinations
,SUM(CAST(b.new_vaccinations as float)) OVER (Partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from ProjectFolder.dbo.COVID_DEATHS a
join ProjectFolder.dbo.COVID_VACCINATIONS b
	on a.location = b.location 
	and a.date = b.date 
where a.continent IS NOT NULL
order by 2,3

--USE CTE for above
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select 
a.continent
,a.location
,a.date
,a.population
,b.new_vaccinations
,SUM(CAST(b.new_vaccinations as float)) OVER (Partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from ProjectFolder.dbo.COVID_DEATHS a
join ProjectFolder.dbo.COVID_VACCINATIONS b
	on a.location = b.location 
	and a.date = b.date 
where a.continent IS NOT NULL
--order by 2,3
)
select
*
,(RollingPeopleVaccinated/population)*100
from PopvsVac



--Creating view to store data for visualizations 
DROP VIEW PercentPopulationVaccinated

USE ProjectFolder
GO
Create View dbo.PercentPopulationVaccinated 
as 
select 
	a.continent
	,a.location
	,a.date
	,a.population
	,b.new_vaccinations
	,SUM(CAST(b.new_vaccinations as float)) OVER (Partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from ProjectFolder.dbo.COVID_DEATHS a
join ProjectFolder.dbo.COVID_VACCINATIONS b 
on a.location = b.location 
and a.date = b.date 
where a.continent IS NOT NULL
--order by 2,3



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
,location nvarchar(255)
,date datetime
,population numeric 
,new_vaccinations numeric
,RollingPeopleVaccinated numeric 
)

INSERT INTO #PercentPopulationVaccinated
select 
	a.continent
	,a.location
	,a.date
	,a.population
	,b.new_vaccinations
	,SUM(CAST(b.new_vaccinations as float)) OVER (Partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from ProjectFolder.dbo.COVID_DEATHS a
join ProjectFolder.dbo.COVID_VACCINATIONS b 
on a.location = b.location 
and a.date = b.date 
where a.continent IS NOT NULL
--order by 2,3


select
*
,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated






































































select top 1000 *
from OlympicProject.dbo.athlete_events$


select top 100 *
from OlympicProject.dbo.noc_regions$



--1) How many olympics games have been held?
select 
COUNT(DISTINCT(Games)) as CountofGames
from OlympicProject.dbo.athlete_events$

--2) List down all Olympics games held so far
select 
DISTINCT Games
,year
from OlympicProject.dbo.athlete_events$
order by year desc

--3) Mention the total no of nations who participated in each olympics game?
select
distinct games
,COUNT(NOC) over (partition by games) as Nations 
from OlympicProject.dbo.athlete_events$
order by games asc

--correct query below
with all_countries as
        (select games, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;

--4) Which year saw the highest and lowest no of countries participating in olympics 
with count_max_low_NOC as 
(
select 
year
,COUNT(DISTINCT(NOC)) as distinctnations
from OlympicProject.dbo.athlete_events$
group by year
order by year desc

)
select
distinct year
,MAX(distinctnations) as MaxNations
,MIN(distinctnations) as LowNations
from count_max_low_NOC
group by year 
order by year desc 


