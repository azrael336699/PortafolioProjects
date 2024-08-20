Fuente de datos: https://ourworldindata.org/covid-deaths, actualizados hasta el 9 de julio de 2024
/* Habilidades utilizadas: Joins, CTE's, Tablas Temporales, Windows Functions, Aggregate Functions, Creación de Views, Convertir tipos de Datos
*/
--Seleccionar datos a utilizar de las tablas
SELECT location,date,total_cases,new_cases,total_deaths, population
FROM Coviddeaths
ORDER BY location,date

--Buscar los total cases vs total deaths, para ver  cuantas muertes hay en la totalidad de casos, o sea, cuantos de los enfermos mueren

SELECT location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) AS Deathpercentage, population
FROM Coviddeaths
ORDER BY location,date

--al ejecutar da un error de tipo de datos, clic derecho sobre la tabla, design, al ver el tipo de datos se ve que hay dtos numericos
--que stan como nvarchar, lo que impide hacer calculos matematicos, se va a cambiar a un tipo float, para que sean numeros muy grandes


ALTER TABLE Coviddeaths ALTER COLUMN total_cases float

--en design se ve que cambio el tipo de datos, se hace lo mismo con las demas columnas que se va a necesitar

ALTER TABLE Coviddeaths ALTER COLUMN total_deaths float

--se vuelve a intentar el calculo que nos mostro el error en el tipo de datos anteriormente, añadiendo el filtro solo para Mexico

SELECT location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) AS Deathpercentage, population
FROM Coviddeaths
WHERE location ='Mexico'
ORDER BY location,date

--ver la relacion entre la poblacion y el numero de casos
--Primero voy a cambiar el tipo de datos de total_case per million y otros valores numericos que esten como tipo nvarchar a un valor numerico float

ALTER TABLE Coviddeaths ALTER COLUMN total_cases_per_million float  
ALTER TABLE Coviddeaths ALTER COLUMN total_deaths_per_million float

SELECT location,date,total_cases,population,((total_cases/population)*100) AS Population_infected_percentage
FROM Coviddeaths
WHERE location ='Mexico'
ORDER BY location,date

--ahora quiero ver que paises tiene el mayor porcentaje de contagios segun el tamaño de su poblacion
--se pone group by porque me dio error de que esas columnas no estaban en un group by

SELECT location, MAX(total_cases)AS Highest_InfectionCount,population,(MAX((total_cases/population)*100)) AS Population_infected_percentage
FROM Coviddeaths
GROUP BY location, population
ORDER BY Population_infected_percentage DESC

--ahora lo mismo pero con el porcentaje de muertes

SELECT location, MAX(total_deaths)AS Highest_deathCount,population,(MAX((total_deaths/population)*100)) AS Population_death_percentage
FROM Coviddeaths
GROUP BY location, population
ORDER BY Population_death_percentage DESC

--Explorando los resultados, en location nos da nombres de continentes y tambien del mundo en general, hay que revisar la tabla para ver como
--salem y ver la manera de eliminarlos de la busqueda, ya que queremos ver paises solamente

SELECT*
FROM Coviddeaths

--se puede ver que en la columna continent hay valores null, parecen ser cuando hay recopilaciones de los valores de los paises de todo el continente

SELECT location, MAX(total_deaths)AS Highest_deathCount,population,(MAX((total_deaths/population)*100)) AS Population_death_percentage
FROM Coviddeaths
WHERE continent IS NOT Null
GROUP BY location, population
ORDER BY Population_death_percentage DESC

--ver los valores anteriores pero por continentes y el mundo en general (para verfificar anotamos el valor world 7051600 para comparar que sea cierto

SELECT location, MAX(total_deaths)AS Highest_deathCount,population,(MAX((total_deaths/population)*100)) AS Population_death_percentage
FROM Coviddeaths
WHERE continent IS Null
GROUP BY location, population
ORDER BY Population_death_percentage DESC

--se observa que en location aparecen valores que no son continentes, para eso se van a borrar los valores que no sean geograficos

SELECT location, MAX(total_deaths)AS Highest_deathCount,population,(MAX((total_deaths/population)*100)) AS Population_death_percentage
FROM Coviddeaths
WHERE continent IS NULL AND (location LIKE '%Europe%' OR location LIKE '%America%' OR location LIKE '%Africa%' OR location LIKE '%Asia%' OR location LIKE '%Oceania%' OR location LIKE '%World') 
GROUP BY location, population
ORDER BY Population_death_percentage DESC

--Ver el numero de total de casos nuevos y nuevas muertes cada dia en todo el mundo 

SELECT date,SUM(new_cases)as Total_new_cases, SUM(new_deaths) AS Total_new_deaths
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

--ver el numero total de casos nuevos y muertes nuevas en el mundo
SELECT SUM(new_cases)as Total_new_cases, SUM(new_deaths) AS Total_new_deaths
FROM Coviddeaths
WHERE continent IS NOT NULL

--ahora quiero ver los datos de vacunacion y como se relacionan con la tabla deaths, para eso
--hago un join, las columnas que tienen en comun son location y date

SELECT *
FROM Coviddeaths
JOIN Covid_Vaccinations AS vac
ON Coviddeaths.location = vac.location
	AND Coviddeaths.date = vac.date

--ahora quiero ver la relacion de population y los vacunados, quiero ver el continente, location, fecha, poblacion y new vaccionations
-- hay que especificar la tabla de las columnas para que no salga error porque checamos datos en mas de una tabla
--recuerda que el order by 1,2,3 es ordenar por esas columnas, se ponen los numeros en vez del nombre de las columnas continent, location y date, pero es igual

SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations 
FROM Coviddeaths
JOIN Covid_Vaccinations AS vac
ON Coviddeaths.location = vac.location
	AND Coviddeaths.date = vac.date
WHERE Coviddeaths.continent IS NOT NULL
ORDER BY 2,3

--ahora quiero saber la cantidad de vacunas totales a lo largo del tiempo por cada pais

SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY Coviddeaths.location) AS Total_Vaccinations
FROM Coviddeaths
JOIN Covid_Vaccinations AS vac
ON Coviddeaths.location = vac.location
	AND Coviddeaths.date = vac.date
WHERE Coviddeaths.continent IS NOT NULL
ORDER BY 2,3

--se observa que me da la suma del total de las vacunas de cada pais en cada fila, pero quiero que me vaya sumando las vacunas segun la fecha que se
--van vacunando, no ver el total de vacunas en cada pais desde la fila uno

SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY Coviddeaths.location ORDER BY Coviddeaths.date ) AS Accumulated_Vaccinations
FROM Coviddeaths
JOIN Covid_Vaccinations AS vac
ON Coviddeaths.location = vac.location
	AND Coviddeaths.date = vac.date
WHERE Coviddeaths.continent IS NOT NULL
ORDER BY 2,3

--ahora quiero ver el porcentaje de la poblacion vacunada

SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY Coviddeaths.location ORDER BY Coviddeaths.date ) AS Accumulated_Vaccinations,
	((Accumulated_Vaccinations/Coviddeaths.population)*100)
FROM Coviddeaths
JOIN Covid_Vaccinations AS vac
ON Coviddeaths.location = vac.location
	AND Coviddeaths.date = vac.date
WHERE Coviddeaths.continent IS NOT NULL
ORDER BY 2,3

--lo anterior da error porque no puedes hacer calculos con otro calculo que ya hiciste previemaente o algo asi, teiens que
--usar una cte o una tabla temporal, lo que prefieras

---cte necesito la tabla anterior para despues hacer un calculo

WITH Population_vaccinated AS (
	SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY Coviddeaths.location ORDER BY Coviddeaths.date ) AS Accumulated_Vaccinations
	FROM Coviddeaths
	JOIN Covid_Vaccinations AS vac
	ON Coviddeaths.location = vac.location
		AND Coviddeaths.date = vac.date
	WHERE Coviddeaths.continent IS NOT NULL
	-- si dejas  esto de order by da error ORDER BY 2,3
	)
	SELECT *,((Accumulated_Vaccinations/population)*100)AS Percentage_Population_vaccinations--aqui no es necesario poner de que tabla, ya que estas buscando solo en una tabla, no en dos o mas
	FROM Population_vaccinated
	ORDER BY 2,3

	--Con una tabla temporal

	DROP TABLE IF EXISTS #PopulationvsVaccination

	CREATE TABLE #PopulationvsVaccination(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population nvarchar (255),
	New_vaccinations float,
	Accumulated_Vaccinations float
	)

	INSERT INTO #PopulationvsVaccination	
	
	SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY Coviddeaths.location ORDER BY Coviddeaths.date ) AS Accumulated_Vaccinations
	FROM Coviddeaths
	JOIN Covid_Vaccinations AS vac
	ON Coviddeaths.location = vac.location
		AND Coviddeaths.date = vac.date
	WHERE Coviddeaths.continent IS NOT NULL

	SELECT *,((Accumulated_Vaccinations/population)*100) AS Percentage_Population_vaccinations
	FROM #PopulationvsVaccination

	--Crear Views para visualizaciones posteriores

	CREATE VIEW Percentage_Population_Vaccinated AS
	SELECT Coviddeaths.continent,Coviddeaths.location,Coviddeaths.date, Coviddeaths.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY Coviddeaths.location ORDER BY Coviddeaths.date ) AS Accumulated_Vaccinations
	FROM Coviddeaths
	JOIN Covid_Vaccinations AS vac
	ON Coviddeaths.location = vac.location
		AND Coviddeaths.date = vac.date
	WHERE Coviddeaths.continent IS NOT NULL

	SELECT *
	FROM Percentage_Population_Vaccinated
