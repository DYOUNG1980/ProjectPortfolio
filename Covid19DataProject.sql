Select *
From Portfolio_Project..[Covid Deaths]
Order By 3,4


--Select * 
--From Portfolio_Project..[Covid Vaccinations]
--Order By 3,4

-- Lets select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..[Covid Deaths]
Order by 1,2

-- Looking at Total Case Vs Total Deaths
-- Displays Likelyhood of Death from Infection of Covid-19

Select location, date, total_cases, population, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..[Covid Deaths]
Where location like '%Kingdom%'
Order by 1,2

-- Looking at Total Cases Vs Total Population of Each Country

Select location, date, total_cases, population, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..[Covid Deaths]
-- Where location like '%Kingdom%'
Order by 1,2

-- Looking at countries with the highest Infection Rate

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as Infection_Percentage
From Portfolio_Project..[Covid Deaths]
-- Where location like '%Kingdom%'
Group by location, population
Order by 4 DESC

-- Showing countries with the highest death rate per population

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(total_deaths/population)*100 as Death_Percentage
From Portfolio_Project..[Covid Deaths]
-- Where location like '%Kingdom%'
Where continent is not null
Group by location
Order by 2 DESC;

-- LETS BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project..[Covid Deaths]
-- Where location like '%Kingdom%'
Where continent is not null 
Group by continent
Order by 2 desc

-- Showing the continents with the highest death count per poulation

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project..[Covid Deaths]
-- Where location like '%Kingdom%'
Where continent is not null
Group by continent
Order by 2 DESC;

-- Looking at Global Cases

Select SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as NewDeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..[Covid Deaths]
-- Where location like '%Kingdom%'
Where continent is not null
--Group by date
Order by 1,2

-- Joining Covid Deaths and Vaccinations Tables together
-- Looking at Total Population Vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..[Covid Deaths] dea
Join Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- Use CTE to calculate Country Vaccination Rate

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..[Covid Deaths] dea
Join Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table
Drop Table if exists  #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..[Covid Deaths] dea
Join Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPeopleVaccinated

-- Creating View to store data for later visualizations

Create View PercentPeopleVaccinated1 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..[Covid Deaths] dea
Join Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	Select *
	From PercentPeopleVaccinated1