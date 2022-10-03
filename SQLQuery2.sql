select *
from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from Portfolioproject..CovidVaccinations
--order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 'Death Percentage'
from Portfolioproject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 'Case Percentage'
from Portfolioproject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,MAX(total_cases) 'HighestInfectionCount',MAX(total_cases/population)*100 'Percentageofpeopleinfected'
from Portfolioproject..CovidDeaths
where continent is not null
group by location,population
order by Percentageofpeopleinfected desc

--Showing countries with highest Death count as per population

select location,population,MAX(cast(total_deaths as int)) 'Death Count'
from Portfolioproject..CovidDeaths
where continent is not null
group by location,population
order by 3 desc

--Showing continent with highest Death count

select continent,MAX(cast(total_deaths as int)) 'Death Count'
from Portfolioproject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Global numbers

select SUM(new_cases) 'total_cases',SUM(cast(new_deaths as int)) 'total_deaths', 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from Portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1,2


--looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
'RollingPeopleVaccinated'

from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
'RollingPeopleVaccinated'
--(RollingPeopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac 
order by 2,3


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
'RollingPeopleVaccinated'
--(RollingPeopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated 


--Creating view to store data for later visualization
drop view if exists PercentPopulationVaccinated
go
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
'RollingPeopleVaccinated'
--(RollingPeopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated