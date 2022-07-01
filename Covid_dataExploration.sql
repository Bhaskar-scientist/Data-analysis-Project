--select *
--from fristDatabase..covidvaccine
--order by 3,4

select *
from fristDatabase..deathcovid
order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from fristDatabase..deathcovid
order by 1,2

--Looking total cases vs total deaths

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from fristDatabase..deathcovid
where location like '%states%'
order by 1,2

select Location,date,total_cases,population, (total_cases/population)*100 as people_percentage
from fristDatabase..deathcovid
where location like '%india%'
order by 1,2

--Loooking at countries with highest infection rate compared to poplution

select Location, Population,Max(total_cases) as highestInfectionCount,Max((total_cases/population))*100 as 
 PercentPopulationInfected
 From fristDatabase..deathcovid
 --where location like '%states%'
 group by Location,population
 order by 1,2

 select Location, Population,date,Max(total_cases) as highestInfectionCount,Max((total_cases/population))*100 as 
 PercentPopulationInfected
 From fristDatabase..deathcovid
 --where location like '%states%'
 group by Location,population,date
 order by 1,2


 select Location,Max(cast(total_deaths as int)) as TotalDeathCount
 From fristDatabase..deathcovid
 --where location like '%states%'
 where continent is not null
 group by Location
 order by TotalDeathCount desc

 -- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

 select continent,Max(cast(total_deaths as int)) as TotalDeathCount
 From fristDatabase..deathcovid
 --where location like '%states%'
 where continent is not null
 group by continent
 order by TotalDeathCount desc


 select location,Max(cast(total_deaths as int)) as TotalDeathCount
 From fristDatabase..deathcovid
 --where location like '%states%'
 where continent is null and location not in ('World','European Union','International')
 group by location
 order by TotalDeathCount desc


--Global Numbers

select date,Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths,(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Death_Percentage
from fristDatabase..deathcovid
where continent is not null
Group by date
order by 1,2

select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths,(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Death_Percentage
from fristDatabase..deathcovid
where continent is not null
--Group by date
order by 1,2


--covid Vaccinations
select*
from fristDatabase..covidvaccine

select*
from fristDatabase..deathcovid dea
join fristDatabase..covidvaccine vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location,
	dea.Date) as RollingPeopleVaccinated
from fristDatabase..deathcovid dea
join fristDatabase..covidvaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From fristDatabase..deathcovid dea
Join fristDatabase..covidvaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From fristDatabase..deathcovid dea
Join fristDatabase..covidvaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
