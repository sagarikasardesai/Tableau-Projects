select * from "covidDeaths"."CovidDeaths_1" order by 1,2;

--mortality rates on daily, monthly and yearly basis
--DeathVsCases, Mortality, Positive cases for each day for each country
select location,continent,date,
       round((total_deaths::decimal/total_cases::decimal)*100::numeric,2) as deathVsCases_percent,
       round((total_deaths::decimal/population::decimal)*100::numeric,7) as mortality_rate,
       round((total_cases::decimal/population::decimal)*100::numeric,4) as positive_cases_percent
from "covidDeaths"."CovidDeaths_1"
where continent is not null
order by 1,3;

--highest Total cases vs Total deaths for each month for each country
with a as (select location, extract(month from date_trunc('month', date)) as month,
       extract(year from date_trunc('year', date)) as year,
       max(total_deaths) as monthly_deaths,
       max(total_cases)monthly_cases,continent, population
from "covidDeaths"."CovidDeaths_1"
group by 2,1,3,6,7)
select a.location,a.continent,a.month, a.year, a.monthly_deaths, a.monthly_cases,
              round((a.monthly_deaths::decimal/a.monthly_cases::decimal)*100::numeric,2) as deathVsCases_percent,
              round((a.monthly_cases::decimal/a.population::decimal)*100::numeric,4) as positive_cases_percent,
              round((a.monthly_deaths::decimal/population::decimal)*100::numeric,7) as mortality_rate
from a
where a.continent is not null
order by 1,4,3;

--highest Total cases vs Total deaths for each year
with a as (select location,
       extract(year from date_trunc('year', date)) as year,
       max(total_deaths) as yearly_deaths,
       max(total_cases)yearly_cases, population, continent
from "covidDeaths"."CovidDeaths_1"
group by 2,1,5,6)
select a.location, a.year, a.yearly_deaths, a.yearly_cases,
              round((a.yearly_deaths::decimal/a.yearly_cases::decimal)*100::numeric,2) as deathVsCases_percent,
              round((a.yearly_deaths::decimal/a.population::decimal)*100::numeric,4) as mortality_rate,
              round((a.yearly_cases::decimal/a.population::decimal)*100::numeric,2) as positive_cases_percent
from a
where a.continent is not null
order by 1,2;

--Countries with highest infection rate compared to population
select location, population, max(total_cases) as MaxInfectionCases,
       round(100*max(total_cases)::decimal/population::decimal,4) as infectionRate
from "covidDeaths"."CovidDeaths_1"
where continent is not null
group by 1,2
order by 4 desc;

--Continents with their infection count
select continent,max(total_cases::decimal) as MaxCases
from "covidDeaths"."CovidDeaths_1"
where continent is not null
group by 1
order by 2 desc;

--Countries with highest death count compared to population
select location, population, max(total_deaths) as MaxDeathCases,
       round(100*max(total_deaths)::decimal/population::decimal,4) as DeathRate
from "covidDeaths"."CovidDeaths_1"
where continent is not null
group by 1,2
order by 3 desc;

--Continents with their death count
select continent,max(total_deaths::decimal) as MaxDeathCases
from "covidDeaths"."CovidDeaths_1"
where continent is not null
group by 1
order by 2 desc;

--highest monthly global numbers recorded
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
       round(100*SUM(new_deaths::decimal)/SUM(New_Cases::decimal),3) as DeathPercentage
From "covidDeaths"."CovidDeaths_1"
where continent is not null
order by 1,2;

--total vaccinations vs populations
with A (continent,location,date, population,new_vac,rolling_vacs) as
(select dea.continent as continent, dea.location as location, dea.date as date,
       dea.population::decimal as population, vac.new_vaccinations::decimal as new_vac,
       sum(vac.new_vaccinations::int) over (partition by dea.location order by dea.location,dea.date) as rolling_vacs
       from "covidVaccinations"."CovidVaccinations_1" vac
    join "covidDeaths"."CovidDeaths_1" dea
        on dea.location = vac.location and dea.date = vac.date
       where dea.continent is not null
       order by 2,3)
select * , 100*(rolling_vacs/population) as percent from A;

--creating view for visualisation
create view popVacPercent as
    (select dea.continent as continent, dea.location as location, dea.date as date,
       dea.population::decimal as population, vac.new_vaccinations::decimal as new_vac,
       sum(vac.new_vaccinations::int) over (partition by dea.location order by dea.location,dea.date) as rolling_vacs
       from "covidVaccinations"."CovidVaccinations_1" vac
    join "covidDeaths"."CovidDeaths_1" dea
        on dea.location = vac.location and dea.date = vac.date
       where dea.continent is not null
       order by 2,3)

