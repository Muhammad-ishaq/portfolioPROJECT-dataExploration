
-- creating a project using Covid data around the world

select * from covid_data_coviddeaths
order by 3,4;

select * from covid_data_covidvaccinations
order by 3,4;

select location, date, total_cases, total_deaths, population from covid_data_coviddeaths order by 1,2;

-- looking at total cases vs total deaths%age

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deaths_percentage from covid_data_coviddeaths
 order by 1,2;
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deaths_percentage from covid_data_coviddeaths
where location like '%afgh%' order by 1,2;

-- looking at total cases vs total population >> %age of population got covid
select location, date, population,total_cases, (total_cases/population)*100 as effected_population from covid_data_coviddeaths
where location like '%afgh%' order by 1,2;

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_inf_count, max((total_cases/population))*100 as effected_population
from covid_data_coviddeaths
group by location,population order by effected_population desc;

-- countries with highest death count compared to population
select location, population, sum(total_deaths)as total_death_count from covid_data_coviddeaths
group by location,population ;

-- Total deaths per continent
select continent,  sum(total_deaths)as total_death_count from covid_data_coviddeaths
group by continent order by total_death_count desc ;

-- Global Numbers
select sum(total_deaths) as total_deaths,sum(new_deaths) as total_deaths_2  from covid_data_coviddeaths ;

-- vaccinations >> Now joining BOTH THE tables
select * from covid_data_covidvaccinations
join covid_data_coviddeaths on 
covid_data_coviddeaths.date=covid_data_covidvaccinations.date
and covid_data_coviddeaths.location=covid_data_covidvaccinations.location
;

-- total population vs vaccination

select covid_data_covidvaccinations.location,covid_data_coviddeaths.population,covid_data_covidvaccinations.total_vaccinations 
from covid_data_covidvaccinations
join covid_data_coviddeaths on 
covid_data_coviddeaths.date=covid_data_covidvaccinations.date
and covid_data_coviddeaths.location=covid_data_covidvaccinations.location
;

select covid_data_covidvaccinations.continent, covid_data_coviddeaths.location, covid_data_coviddeaths.date, covid_data_coviddeaths.population,
covid_data_covidvaccinations.total_vaccinations, covid_data_covidvaccinations.new_vaccinations from
covid_data_coviddeaths join covid_data_covidvaccinations on 
covid_data_coviddeaths.location=covid_data_covidvaccinations.location
and covid_data_coviddeaths.date=covid_data_covidvaccinations.date
order by 2,3;
 
 -- using total_rolling_up func on the base of location column
 
 select covid_data_covidvaccinations.continent, covid_data_coviddeaths.location , covid_data_coviddeaths.date, covid_data_coviddeaths.population,
covid_data_covidvaccinations.total_vaccinations, covid_data_covidvaccinations.new_vaccinations, sum(covid_data_covidvaccinations.new_vaccinations)
over (partition by covid_data_coviddeaths.location order by covid_data_coviddeaths.location,covid_data_coviddeaths.date) As RollUp_vacc from
covid_data_coviddeaths join covid_data_covidvaccinations on 
covid_data_coviddeaths.location = covid_data_covidvaccinations.location
and covid_data_coviddeaths.date = covid_data_covidvaccinations.date
order by 2,3; -- won't show any results because no records of vaccination was available till that time

-- use of CTE

with popul_vacc( continent,location, date,population,total_vaccinations,new_vaccinations,RollUp_vacc)
as
(select covid_data_covidvaccinations.continent, covid_data_coviddeaths.location , covid_data_coviddeaths.date, covid_data_coviddeaths.population,
covid_data_covidvaccinations.total_vaccinations, covid_data_covidvaccinations.new_vaccinations, sum(covid_data_covidvaccinations.new_vaccinations)
over (partition by covid_data_coviddeaths.location order by covid_data_coviddeaths.location,covid_data_coviddeaths.date) As RollUp_vacc from
covid_data_coviddeaths join covid_data_covidvaccinations on 
covid_data_coviddeaths.location = covid_data_covidvaccinations.location
and covid_data_coviddeaths.date = covid_data_covidvaccinations.date
)
select * from popul_vacc;

-- USE OF TEMP TABLE
Drop table if exists PERCENT_POPU_VACC;
create temporary table PERCENT_POPU_VACC
( CONTINENT nvarchar(255),
LOCATION nvarchar(255),
DATE datetime,
POPULATION numeric,
total_vaccinations numeric,
new_vaccinations numeric,
RollUp_vacc numeric);
INSERT INTO
PERCENT_POPU_VACC(select covid_data_covidvaccinations.continent, covid_data_coviddeaths.location , covid_data_coviddeaths.date, covid_data_coviddeaths.population,
covid_data_covidvaccinations.total_vaccinations, covid_data_covidvaccinations.new_vaccinations, sum(covid_data_covidvaccinations.new_vaccinations)
over (partition by covid_data_coviddeaths.location order by covid_data_coviddeaths.location,covid_data_coviddeaths.date) As RollUp_vacc from
covid_data_coviddeaths join covid_data_covidvaccinations on 
covid_data_coviddeaths.location = covid_data_covidvaccinations.location
and covid_data_coviddeaths.date = covid_data_covidvaccinations.date);
select * from PERCENT_POPU_VACC;
 
-- creating a view to store data for later visualizations >> total deaths per continent


create view visual_data as 
select continent,  sum(total_deaths)as total_death_count from covid_data_coviddeaths
group by continent order by total_death_count desc ;



















