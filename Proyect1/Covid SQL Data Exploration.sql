SELECT * FROM PortafolioProyect..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

SELECT * FROM PortafolioProyect..CovidVaccinations
ORDER BY 3, 4


--Selecion de datos que voy a usar

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProyect..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


--Mirar el total cases vs total deaths
--Muestra la probabilidad de morir por covid en un pais
SELECT location, date, total_cases, total_deaths, (total_deaths/nullif(total_cases, 0))*100 AS DeathPercentage
FROM PortafolioProyect..CovidDeaths
WHERE location like '%arg%' AND continent is not null
ORDER BY 1, 2


--Mirar el total de casos vs la poblacion
--Muestra el porcentage de la pobalcion que tuvo covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM PortafolioProyect..CovidDeaths
WHERE location like '%arg%' AND continent is not null
ORDER BY 1, 2


--Paises con la taza de contraccion mas alta comparado con la poblacion

SELECT location, population, MAX(total_cases) AS HiguestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortafolioProyect..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HiguestInfectionCount DESC


--Continentes con el mayor numero de muertes por poblacion

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortafolioProyect..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC


--Paises con el mayor numero de muertes por poblacion

SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM PortafolioProyect..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC


--Numeros globales

SELECT date, SUM(new_cases) AS CasesGlobal, SUM(new_deaths) AS DeathGlobal, SUM(new_deaths)/SUM(nullif (new_cases, 0))*100 AS PercentageGlobal
FROM PortafolioProyect..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Union de tablas

SELECT * 
FROM PortafolioProyect..CovidDeaths dea
JOIN PortafolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


--Poblacion total vs Poblacion total de vacunados

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS  Rolling_People_Vaccionated
FROM PortafolioProyect..CovidDeaths dea
JOIN PortafolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE  dea.continent is not null AND dea.location = 'argentina'
ORDER BY 2, 3


--USE CTR

WITH PopvsVac (continent, location, date, population, New_Vaccinations, Rolling_People_Vaccionated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS  Rolling_People_Vaccionated
FROM PortafolioProyect..CovidDeaths dea
JOIN PortafolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE  dea.continent is not null
)
SELECT *, (Rolling_People_Vaccionated/population)*100
FROM PopvsVac


--Tabla Temporal

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccionated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS  Rolling_People_Vaccionated
FROM PortafolioProyect..CovidDeaths dea
JOIN PortafolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE  dea.continent is not null

SELECT *, (Rolling_People_Vaccionated/population)*100
FROM #PercentPopulationVaccinated


--Creacion de vista para almacenar datos
DROP VIEW IF exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS  Rolling_People_Vaccionated
FROM PortafolioProyect..CovidDeaths dea
JOIN PortafolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE  dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated