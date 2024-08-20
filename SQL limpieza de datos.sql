--Limpieza de datos con SQL Queries

SELECT*
FROM Nashville_housing
--estandarizar columna SaleDate, ya que esta en un formato que parece incluir horas,minutos,segundos, y solo quiero fecha estandar
--clic derecho en la base de datos, design, y se ve que efectivamente esta columna estan con Data Type datetime, queremos solo date

SELECT SaleDate, CAST(SaleDate AS date) 
FROM Nashville_housing
--se ve que ya lo convierte al formato de fecha date,  ahora hay que reemplazar esos valores en la columna SalesDate

ALTER TABLE Nashville_housing
ALTER COLUMN SaleDate date

--al intentar usar UPDATE no corregia el tipo de datos, pero usar la funcion anterior evito la necesidad deusar CAST para convertir al tipo 
--de datos que se queria y luego usar la funcion UPDATE para reemplazar los valores de la columna SaleDate

--Ahora hay que trabajar en la columna PropertyAdress
---La busqueda de abajo la escribi para ver los valores nulos que habia en todas las columnas, pero en el tutorial se enfoca en la
---columna  propertyadress nada mas
SELECT *
FROM Nashville_housing
WHERE [UniqueID ] IS NULL OR
	ParcelID IS NULL OR
	LandUse IS NULL OR
	PropertyAddress IS NULL OR
	SaleDate IS NULL OR
	SalePrice IS NULL OR
	LegalReference IS NULL OR
	SoldAsVacant IS NULL OR
	OwnerName IS NULL OR 
	OwnerAddress IS NULL OR
	Acreage IS NULL OR
	TaxDistrict IS NULL OR
	LandValue IS NULL OR
	BuildingValue IS NULL OR
	TotalValue IS NULL OR
	YearBuilt IS NULL OR
	Bedrooms IS NULL OR
	FullBath IS NULL OR
	HalfBath IS NULL
--ahora si solo ver la columna propertyaddress
SELECT *
FROM Nashville_housing
WHERE PropertyAddress IS NULL
--hay varios valores null en esa columna, ahora hay que ver todas las columnas ordenandolas por parcelid, ya que hay relacion entre eso y la columna
--porpertyaddress
SELECT ParcelID, PropertyAddress
FROM Nashville_housing
ORDER BY ParcelID
--se ve que la fila 44 y 45 el parcelid es el mismo(015 14 0 060.00), y en esas filas la propertyaddress es la misma, por lo que se va a buscar que 
--en las filas donde el parcelid sea el mismo, si en property adress hay nul, se ponga el valor del property adress de un parcelid identico
-- ya que en los valores de propertyaddres que son null, se ve que el parcel id es identico a uno que si tiene direccion
--Ver cuantos valores parcelid se repiten
SELECT ParcelID, COUNT(ParcelID) AS repetidos, PropertyAddress
FROM Nashville_housing
group by ParcelID, PropertyAddress
ORDER BY ParcelID
--se observa que por alguna razon desconocida, los valores que salen repetidos dos veces siempre tienen la misma propertyadress, pero
--donde property adress sale null, siempre aparece un  par de parcel id iguales, que no se contaron como repetidos, y en un de ellos
--la property addres es null y el otro si la tiene, como en la fila 151 y 152 
SELECT ParcelID, COUNT(ParcelID) AS repetidos, PropertyAddress
FROM Nashville_housing
where PropertyAddress is null
group by ParcelID, PropertyAddress
ORDER BY ParcelID
--se hace una busqueda para ver solo los valores donde property adress es null, y buscando los  parcel id con los de la busqueda anterior, todos coinciden
--y todos tienen un valor de parcelid en la fila previa o pesterior iguales, por lo que es seguro decir que siempre si un parcel id es repetido, 
--debe tener la misma property address

--Para hacer que el propertyaddress donde hay null se complete con el valor del parcel id que si tiene address, se tiene que ahcer un join
--con la misma tabla, o sea un self join,  <> quiere decir no es igual a

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress
FROM Nashville_housing AS T1
JOIN Nashville_housing AS T2 
	ON T1.ParcelID= T2.ParcelID
	AND T1.[UniqueID ]<> T2.[UniqueID ]
--Se dice el join donde el parcel id es el mismo, pero que no son de la misma fila, por eso se puso el and T1 uniqueid no sea igual al de T2
--pero se observa que me muestra valores nulos en property adress en t1 y t2, pero los parcel id en ambas son iguales, y asi no se puede reemplazar
--los valores null con la direccion correspondiente al parcel id, entonces agregamos una condicion  where para ver solo los null de una tabka

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress
FROM Nashville_housing AS T1
JOIN Nashville_housing AS T2 
	ON T1.ParcelID= T2.ParcelID
	AND T1.[UniqueID ]<> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

--AHORA SI se ve que el parcel id de t1 es null, pero para el mismo parcel id en t2 si tiene un valor en propertyadress, entonces
--ya es posible reemplazar el valor null con el valor correspondiente

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress, ISNULL(T1.PropertyAddress,T2.PropertyAddress)
FROM Nashville_housing AS T1
JOIN Nashville_housing AS T2 
	ON T1.ParcelID= T2.ParcelID
	AND T1.[UniqueID ]<> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL
--Se creo una columna con el isnull, donde si en t1.propertyaddress sale un valor null, da el valor de T2.propertyadress
--falta hacer que se reemplace el valor en t1 donde hay valores nulos

UPDATE T1
SET PropertyAddress= ISNULL(T1.PropertyAddress,T2.PropertyAddress)
	FROM Nashville_housing AS T1
	JOIN Nashville_housing AS T2 
		ON T1.ParcelID= T2.ParcelID
		AND T1.[UniqueID ]<> T2.[UniqueID ]
--Quitamos la parte de select de la instruccion anterior porque no necesitamos ver esas columnas, solo queremos actualizar los valores
--que son nulos en t1, lo cual se consiguio con la instruccion anterior 
SELECT*
FROM Nashville_housing
WHERE PropertyAddress IS NULL
--buscamos valores nulos en nashville_housing en la columna PropertyAdress y verificamos que ya no sale nada

--Ahora piden separar la columna property address para obtener separado la direccion,  y ciudad y estado con otras columnas

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) AS Address
FROM Nashville_housing
--la coma sale en el resultado, y nosotros queremos el resultado sin la coma, se le pone un menos uno despuesde charindex, 
--ya que esa funcion solo nos dice la posicion donde esta la coma dentro de la cadena de caracteres
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) AS Address, CHARINDEX(',',PropertyAddress)
FROM Nashville_housing
--procedemos a quitar la coma de nuestro resultado
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
FROM Nashville_housing
--ahora hay que sacar la ciudad de esa misma columna property address
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))AS City
FROM Nashville_housing
--EN SUBTRING par City, la posocion de inicio es + posicion despues de la coma, y se ua LEN para decirle a SUBSTRING el numero de caracteres
--a extraer, o sea le decimos el de la longitud de la columna, en SQL server es necesario especificar, en my sql podria ir sin LEN

--Hay que agregar las columnas que acabamos de obtener en la busqueda a la tabla
ALTER TABLE Nashville_housing
ADD Property_SplitAdress nvarchar(255)                       

UPDATE Nashville_housing
SET Property_SplitAdress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_housing
ADD Property_SplitCity nvarchar(255)

UPDATE Nashville_housing
SET Property_SplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--verificamos que se crearon las columnas y se llenaron con los datos requeridos, todo ok y pasamos a obtener el estado de la columna owneradress

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM Nashville_housing
--vemos que da lo que esta a la izquierda de la primera coma, entonces acomodamos para que nos de los resultados en orden de primero adress, city y al final state

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
		PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
		PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM Nashville_housing

--vemos que funciona, asi que creamos nuevas columnas y llenamos con los valores que obtuvimos en la instruccion anterior

ALTER TABLE Nashville_housing
ADD Owner_SplitAddress nvarchar(255)
UPDATE Nashville_housing
SET Owner_SplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_housing
ADD Owner_SplitCity nvarchar(255)
UPDATE Nashville_housing
SET Owner_SplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_housing
ADD Owner_SplitState nvarchar(255)
UPDATE Nashville_housing
SET Owner_SplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
--Para que funcione la ejecucion de la query, primero hay que ejecutar la parte de crear las columnas, y despues el update, si le das seleccionar todo
--va a mostrar error, creo que entonces seria mejor primero escribir las partes de creaccion de todas las columnas y luego todas las update
SELECT*
FROM Nashville_housing
--comprobamos que se añadieron las columnas y todo ok, comprobamos que la columna sold as vacant solo tenga los valores yes o no

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM Nashville_housing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant
--vemos que hay valores que no corresponden con o que queremos, asi que modificamos las N por No y las Y por Yes

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM Nashville_housing
--VEMOS QUE FUNCIONA, AHORA HAY QUE ACTUALIZAR CON LOS DATOS NUEVOS

UPDATE Nashville_housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END

--verificamos que haya cambiado a solo no y yes, todo ok

---Eliminar Duplicados

--Ahora buscamos duplicados, para este ejemplo ignoramos el uniqueid, querems buscar filas donde el ParcelID, propertyaddress, saleprice, saledate
--y legal reference sean iguales, para eso usamos la funcion de ventana ROW_Number, sirve para enumerar filas, y aqui usamos eso para que 
--enumere  las filas  pero con el partition by decimos que enumere de acuerdo a los parametros de las columnas, o sea que si en un momento
--alguna fila tiene datos exactamente iguales, a esa fila le dara un numero 2, y es ahi  donde vemos que hay cosas repetidas

SELECT*,
	ROW_NUMBER() OVER
	(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS RomNumber
FROM Nashville_housing
ORDER BY ParcelID
--Necesitamos usar la funcion ventana para identificar los valores rownumber mayores a 1, pero no se puede usar where or having en funciones de ventana
--por lo cual hay que usar un CTE, recuerda que al crear un CTE es como si crearas una tabla temporal 
WITH Duplicates AS(
		SELECT*,
	ROW_NUMBER() OVER
	(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS RowNumber
	FROM Nashville_housing
	)
--llemamos Duplicates a la query anterior para poder usar un where para encontrar lo que queremos
SELECT *
FROM Duplicates
WHERE RowNumber>1
ORDER BY ParcelID
--el resultado es los numeros 2 en RowNumber, lo que representa que son filas repetidas, las cuales no deseamos en el ejemplo, procedemos a eliminarlas

WITH Duplicates AS(
		SELECT*,
	ROW_NUMBER() OVER
	(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS RowNumber
	FROM Nashville_housing
	)
DELETE 
FROM Duplicates
WHERE RowNumber>1
--Verificamos que se hayan borrado los 2, todo ok

---BORRAR LAS COLUMNAS QUE NO NECESITAMOS
--Hay que borrar las columnas que dividimos( Propertyaddres y owneradress, ya que son mas utiles divididas que en conjunto
--Recuerda que no es recomendable borrar columnas en las bases de datos originales, pero para este ejemplo se hara porque no quiero hacer una copia
--de la base de datos

ALTER TABLE Nashville_housing
DROP COLUMN PropertyAddress

ALTER TABLE Nashville_housing
DROP COLUMN OwnerAddress
--Verificamos que se borraron, se verifica y listo.

SELECT*
FROM Nashville_housing
--se ve que hay un error de nombre en Property_SplitAdress, falta una d para que en inglés este correcto, corregimos

EXEC sp_rename'Nashville_housing.Property_SplitAdress', 'Property_SplitAddress', 'COLUMN'
--verificamos que se cambio el nombre, todo ok