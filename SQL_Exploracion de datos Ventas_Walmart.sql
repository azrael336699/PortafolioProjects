
--El objetivo principal de este proyecto es obtener información sobre los datos de ventas de Walmart para comprender los diferentes factores que afectan a las ventas de las 
--diferentes sucursales.

--Acerca de los datos
--El conjunto de datos se obtuvo del concurso de previsión de ventas de Kaggle Walmart. Este conjunto de datos contiene transacciones de ventas de tres sucursales diferentes 
--de Walmart, ubicadas en Mandalay, Yangon y Naypyitaw, respectivamente. Los datos contienen 17 columnas y 1000 filas

--Habilidades empleadas: Añadir columnas, actualizar datos, cambiar tipo de datos, añadir restricciones, añadir llave primaria, uso de aggregate functions, windows functions,
--uso de expresiones comunes de tabla, uso de funciones de fecha y uso de CASES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Cambiamos los tipos de datos,ya que de donde importamos todo esta en tipo string, ponemos una restriccion para valores nulos y añadimos llave primaria en Invoice ID

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [Invoice ID] varchar(50) NOT NULL;
--Se ejecuta lo anterior antes de agregar la primary key, sino da error ya que no se puede añadir a columnas que permiten valores nulos
ALTER TABLE [walmart].[dbo].[Sales]
ADD PRIMARY KEY ( [Invoice ID])

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Branch varchar(5) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN City varchar(50) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [Customer type] varchar(30) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Gender varchar(30) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [Product line] varchar(50) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [Unit price] decimal(10,2) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Quantity int NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [Tax 5%] decimal(10,2) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Total decimal(10,2)NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Date date NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Time time(0) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN cogs decimal(10,2) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [gross margin percentage] decimal(10,2) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN [gross income] decimal(10,2) NOT NULL;

ALTER TABLE [walmart].[dbo].[Sales]
ALTER COLUMN Rating decimal(10,1) NOT NULL;

--Ahora responderemos a las preguntas que desean responder los encargados

--------------------------------------------------------------------------------------------------------------------
--Preguntas Genericas-----------------------------------------------------------------------------------------------
--¿Cuantas ciudades unicas hay en los datos?
SELECT DISTINCT City
FROM Sales
--Tenemos 3: Naypytaw, Yangon y Mandalay

--¿En que ciudad esta cada rama?
SELECT DISTINCT Branch, City
FROM Sales
ORDER BY Branch
--La rama A esta en Yangon, la B en Mandalay y la C en Naypytaw

--Acerca del producto-------------------------------------------------------------------------------------------------------------------
--¿Cuantas lineas de producto unicos hay en los datos?
SELECT DISTINCT [Product line]
FROM Sales
--Existen 6: Fashion accessories, Health and beauty, Electronic accessories, Food and beverages, Sports and travel y Home and lifestyle

--¿Cual es el tipo de pago más comun?
SELECT DISTINCT(Payment),COUNT(Payment) AS Frecuencia
FROM Sales
GROUP BY Payment
--El mas comun es Ewallet con 345 usos

--¿Cual es la linea de productos quá más vende?
SELECT DISTINCT([Product line]),COUNT([Product line]) AS Frecuencia
FROM Sales
GROUP BY [Product line]
ORDER BY COUNT([Product line]) DESC
--Fashion accesories vende con mas frecuencia

--¿Cual es el ingreso total por cada mes?
--Creamos una columna llamada Month, ya que puede ser util para analisis futuros o para las visualizaciones 
ALTER TABLE [walmart].[dbo].[Sales]
ADD [Month of sale] varchar(20);
--Ahora obtenemos el mes de la columna Date y lo guardamos en la columna recien creada
SELECT Date, DATENAME(MONTH,Date)
FROM Sales
UPDATE [walmart].[dbo].[Sales]
SET [Month of sale]= DATENAME(MONTH,Date)
--Procedemos a ver en qué mes hay más ingresos
SELECT [Month of sale],SUM(Total) 
FROM Sales
GROUP BY [Month of sale]
ORDER BY SUM(Total) DESC
--Enero es el mes con más ingresos con $116292.11

--¿Qué mes tiene el mayor COGS (Cost Of Goods sold)?
SELECT [Month of sale],SUM(cogs) 
FROM Sales
GROUP BY [Month of sale]
ORDER BY SUM(cogs) DESC
--Enero con $110754.16

--¿Qué linea de producto tiene el mayor ingreso?
SELECT DISTINCT([Product line]),SUM(Total)
FROM Sales
GROUP BY [Product line]
ORDER BY SUM(Total) DESC
--Food and beverages con $56144.96

--¿Qué ciudad tiene el mayor ingreso?
SELECT City, SUM(Total)
FROM Sales
GROUP BY City
ORDER BY SUM(Total) DESC
--Naypyitaw con $110568.86

--¿Qué linea de producto colecta más impuestos?
SELECT [Product line], SUM([Tax 5%])
FROM Sales
GROUP BY [Product line]
ORDER BY SUM([Tax 5%]) DESC
--Food and beverages con $2673.68

--Buscar cada línea de producto y añadir una columna a la línea de productos que muestra "Bueno", "Malo". Bueno si sus ventas son mayores que la media
--Primero buscamos el promedio de ventas por cada linea de producto, esto no es necesario pero se quiere comprobar que los valores sean correctos
select [Product line],AVG(Total)
from Sales
GROUP BY [Product line]
--Ahora calculamos el promedio de venta por cada linea de producto, y hacemos la comparación para cada venta registrada, y la clasificamos como buena o mala según corresponda
SELECT *,
CASE
	WHEN Total>= AVG(Total)OVER(PARTITION BY [Product line] ) THEN 'Good Sale'
	ELSE 'Bad Sale'
END AS [Good or Bad Sale]
FROM Sales
--Comparamos los resultados de good o bad con los promedios calculdos primero, y se observa que se hizo correctamente 

--Ahora, falta crear una columna para añadir permanentemente la busqueda anterior a la tabla, primero creamos la nueva columna
ALTER TABLE [walmart].[dbo].[Sales]
ADD [Good or Bad Sale] varchar(20);
--A continuación, hay que llenar la nueva columna con los datos correspondientes, usamos un cte porque UPDATE no permite las funciones de ventana
WITH cte AS
(SELECT [Product line],Total,[Invoice ID],
CASE
	WHEN Total>= AVG(Total)OVER(PARTITION BY [Product line] ) THEN 'Good Sale'
	ELSE 'Bad Sale'
END AS [Good or Bad Sale]
FROM Sales
)
UPDATE [walmart].[dbo].[Sales]
SET Sales.[Good or Bad Sale] = cte.[Good or Bad Sale]
FROM cte
WHERE Sales.[Invoice ID]= cte.[Invoice ID]
--Es importante añadir la primary key para que aplique el CASE en cada fila de la tabla sales y del cte a fin de que el UPDATE sea correcto

--¿Qué rama vendió más productos que el promedio de productos vendidos totales?
SELECT Branch, SUM(Quantity)
FROM Sales
GROUP BY Branch
HAVING SUM(Quantity) > (SELECT (SUM(Quantity))/COUNT(DISTINCT Branch)  FROM Sales)
--Solo la rama A esta arriba del promedio con 1859 unidades vendidas

--¿Cuál es la línea de productos más común por género?
--Primero revisamos cuantos generos distintos hay en los datos
SELECT DISTINCT Gender
FROM Sales
--Después procedemos a buscar la linea más comun segun los generos encontrados
SELECT [Product line],COUNT(Gender)AS Male
FROM Sales
WHERE Gender= 'Male'
GROUP BY [Product line]
ORDER BY COUNT(Gender) DESC
SELECT [Product line],COUNT(Gender)AS Female
FROM Sales
WHERE Gender= 'Female'
GROUP BY [Product line]
ORDER BY COUNT(Gender) DESC
--Para los hombres la más comun es Health and beauty con 88, y las mujeres fashion accesories con 96

--¿Cuál es la calificación media de cada línea de productos?
SELECT [Product line], AVG(Rating)
FROM Sales
GROUP BY [Product line]
ORDER BY AVG(Rating) DESC

-----Acerca de las ventas----------------------------------------------------------------------------------------------------
--Número de ventas realizadas en cada momento del día por día
--Para eso vamos a crear una columna nueva que clasifique la hora de venta por morning, afternoon y evening, para el dia de 0 a 12, tarde de 12:01 a 18, y noche de 18:01 en adelante
ALTER TABLE [walmart].[dbo].[Sales]
ADD [Time of Sale] varchar(15);

--Creamos el case para clasificar la hora de venta
SELECT Time,
CASE
	WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN Time BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
	ELSE 'Evening'
END AS [Time of Sale]
FROM Sales
--Vemos que funciona la query, asi que ahora haceos Update con estos valores a la columna Time of Sale
WITH cte AS
(
SELECT Time,[Invoice ID],
CASE
	WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN Time BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
	ELSE 'Evening'
END AS [Time of Sale]
FROM Sales
)
UPDATE [walmart].[dbo].[Sales]
SET Sales.[Time of Sale] = cte.[Time of Sale]
FROM cte
WHERE Sales.[Invoice ID]= cte.[Invoice ID]
--Ahora es posible contar las ventas hechas en la mañana, tarde y en la noche por separado
SELECT [Time of Sale],COUNT([Time of Sale])AS Sales_Made
FROM Sales
GROUP BY [Time of Sale]
--En la mañana se hicieron 191 ventas, en la tarde 530 y en la noche 279

--¿Cuál de los tipos de clientes genera la mayor parte de los ingresos?
SELECT [Customer type],SUM(Total)AS ingresos
FROM Sales
GROUP BY [Customer type]
--Los tipo  member generan más ingresos con $164233.81 vs los tipo normal $158743.62

--¿Qué ciudad colecta más impuestos?
SELECT City,SUM([Tax 5%])AS Tax_Collected,SUM(Total)
FROM Sales
GROUP BY City
ORDER BY SUM([Tax 5%])
--Yangon y Mandalay colecten los mismos impuestos ya que la diferencia en ventas entre ellas es de solo $2

--¿Qué tipo de cliente paga más en IVA?
SELECT [Customer type],SUM([Tax 5%])AS Tax_Collected
FROM Sales
GROUP BY [Customer type]
ORDER BY SUM([Tax 5%])
--Member colecta más impuestos

----------------------------------------------------------------------------------------------------------
---Acerca del cliente-------------------------------------------------------------------------------------
--¿Cuántos tipos de clientes únicos tienen los datos?
SELECT DISTINCT[Customer type]
FROM Sales
--2:normal y member

--¿Cuántos métodos de pago únicos tiene los datos?
SELECT DISTINCT Payment
FROM Sales

--¿Cuál es el tipo de cliente más común?
SELECT [Customer type],COUNT([Customer type])
FROM Sales
GROUP BY [Customer type]
--member con 501 ventas

--¿Qué tipo de cliente compra más unidades de productos?
SELECT [Customer type],SUM(Quantity)
FROM Sales
GROUP BY [Customer type]
--el member con 2785 unidades 

-- ¿Cuál es el sexo de la mayoría de los clientes?
SELECT Gender,COUNT(Gender)
FROM Sales
GROUP BY Gender
--Las mujeres con 501 compras

--¿Cuál es la distribución por genero de las linea de productos?
SELECT [Product line], COUNT(Gender)AS Male
FROM Sales
WHERE Gender='Male'
GROUP BY [Product line]

SELECT [Product line], COUNT(Gender)AS Female
FROM Sales
WHERE Gender='Female'
GROUP BY [Product line]

--¿Qué tiempo del día dan los clientes la mayoría de las calificaciones?
SELECT [Time of Sale], COUNT(Rating)
FROM Sales
GROUP BY [Time of Sale]
--En la tarde los clientes califican más (530 calificaciones)

--¿Qué tiempo del día dan los clientes la mayoría de las calificaciones por sucursal?
SELECT Branch,[Time of Sale], COUNT(Rating)
FROM Sales
GROUP BY Branch,[Time of Sale]
ORDER BY Branch
--En todas las sucursales califican más frecuentemente durante la tarde

--¿Qué día de la semana tiene las mejores puntuaciones?
--Vamos a crear una nueva columna y añadir los dias de la semana en los cuales se realizaron las ventas
ALTER TABLE [walmart].[dbo].[Sales]
ADD [Weekday of sale] varchar(20);
--Ahora obtenemos el mes de la columna Date y lo guardamos en la columna recien creada
UPDATE [walmart].[dbo].[Sales]
SET [Weekday of sale]= DATENAME(WEEKDAY,Date)
--Procedemos a ver que dia la semana la calificacion es mayor
SELECT [Weekday of sale], AVG(Rating)
FROM Sales
GROUP BY [Weekday of sale]
ORDER BY AVG(Rating)DESC
--El lunes es el dia con mejor puntuacion promedio (7.15)
 
--¿Qué día de la semana tiene las mejores calificaciones medias por sucursal?
SELECT Branch,[Weekday of sale], AVG(Rating)
FROM Sales
GROUP BY  Branch,[Weekday of sale]
ORDER BY Branch,AVG(Rating)DESC
--En la sucursal A es el viernes con 7.31, en la B es lunes con 7.33 y en la C es el viernes con 7.27



