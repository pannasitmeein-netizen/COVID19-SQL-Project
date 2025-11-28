-- Showing the Whole Data File

SELECT 
*
from
coviddeaths
order by location, date


SELECT 
*
from
covidvaccinations 
order by location, date



-- "Total Cases vs Total Deaths" Table (Death_Percentage)
-- How likely of dying if you are infected in Thailand

select 
location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage
from
coviddeaths
where total_deaths is not null and location like '%thai%'
order by location, date



-- Total Cases vs Population
-- How much percentage of population got infected in Thailand

select 
location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as Infected_Percentage
from
coviddeaths
where total_deaths is not null and location like '%thai%'
order by location, date



-- Comparison of Infection Rate in Each country

select 
location, 
max(total_cases) as Total_case_in_the_country, 
max(population) as Population, 
max(total_cases/population)*100 as Infected_Percentage
from
coviddeaths
where continent is not null
group by location
order by Infected_Percentage desc



-- Comparison of Total Death per Population in Each Country

select
location,
max(total_deaths) as Total_Death
from
coviddeaths
WHERE location not in ('World','Europe','North America','European Union','South America','Africa','Asia')
group by location
order by Total_Death desc



-- Total Deaths Based on Continent

select
continent,
max(total_deaths) as Total_Death
from
coviddeaths
WHERE continent <> '' and continent is not null 
group by continent
order by Total_Death desc



-- Global Case, Death, and Death Percentage

select 
sum(new_cases) as Total_cases,
sum(new_deaths) as Total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as Death_Percentage
from
coviddeaths
where continent <> '' and continent is not null



-- Calculating the Aggregrated Number of Vaccination on Each Date
-- Using CTE in order to use the calculated variable/ window function to calculate aggregrated sum

With Vaccinated_Population as (
SELECT 
code.continent,
code.location,
code.date,
code.population,
cova.new_vaccinations,
sum(cova.new_vaccinations) over (partition by code.location order by code.location, code.date) as Aggregrated_Vaccination
FROM 
coviddeaths code
inner join covidvaccinations cova 
on code.location = cova.location and code.date = cova.date
where trim(code.continent) <> '' and code.continent is not null
)
SELECT *, (aggregrated_vaccination/population)*100 as Vaccination_Percentage
FROM Vaccinated_Population
where aggregrated_vaccination <> 0
ORDER BY location, date



-- Creating View for Visualization in Tableau
-- 1. Percentage of Population that got vaccination

create view Population_Vaccinated_Percentage as 
With Vaccinated_Population as (
SELECT 
code.continent,
code.location,
code.date,
code.population,
cova.new_vaccinations,
sum(cova.new_vaccinations) over (partition by code.location order by code.location, code.date) as Aggregrated_Vaccination
FROM 
coviddeaths code
inner join covidvaccinations cova 
on code.location = cova.location and code.date = cova.date
where trim(code.continent) <> '' and code.continent is not null
)
SELECT *, (aggregrated_vaccination/population)*100 as Vaccination_Percentage
FROM Vaccinated_Population
where aggregrated_vaccination <> 0

-- 2. Percentage of People who get infected in each country

create view Percentage_of_Infection as 
select 
location, 
max(total_cases) as Total_case_in_the_country, 
max(population) as Population, 
max(total_cases/population)*100 as Infected_Percentage
from
coviddeaths
where continent is not null
group by location
order by Infected_Percentage desc

-- 3. Thailand Death Percentage

create view Thailand_Death_Percentage as 
select 
location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage
from
coviddeaths
where total_deaths is not null and location like '%thai%'
order by location, date

-- 4. Thailand Infection Percentage

create view Thailand_Infection_Percentage as 
select 
location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as Infected_Percentage
from
coviddeaths
where total_deaths is not null and location like '%thai%'
order by location, date

-- 5. Deaths based on each Continent

create view Death_by_Continent as 
select
continent,
max(total_deaths) as Total_Death
from
coviddeaths
WHERE continent <> '' and continent is not null 
group by continent
order by Total_Death desc