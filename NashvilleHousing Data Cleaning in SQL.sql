----CLEANING DATA IN SQL QUERIES
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----FORMATTING DATE COLUMN---


SELECT Saledate, CONVERT(date, Saledate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(date, Saledate)


---or--

ALTER TABLE NashvilleHousing
Add SalesDate2 Date;

UPDATE NashvilleHousing
SET SalesDate2=CONVERT(date, Saledate)


SELECT Salesdate2
FROM PortfolioProject.dbo.NashvilleHousing

-----Populate NULL property addresses

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID ----using parcelID one can see PARCELID's which have similar property addresses,then these can be used to populate missing addresses

----Self join the table, to see all TABLES 


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ] ----it joins where the parcel id is the same but different rows, the uniqueid ensures they are different rows even though they have similar parcelid
----b.PorfolioProject table shows only where there is data, the nulls are not included. it shows data where a.parcel.id = b. parcel ID and the unique IDS are different

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress----SHOWS WHERE A.PROPERTYADDRESS there are nulls in the A table That needs to be updated AND  b.propertyaddresses which have similar parcelIDS that are not NULL
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ] 
WHERE a.PropertyAddress is null

---Use ISNULL to a see AND fill up a.property addresses which are nulls


SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)----if a.propertyAddress is null, populate it with b.propertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ] 
	WHERE a.PropertyAddress is null

---ISNULL output shows the data which would be used to fill up the missing null values in a.propertyaddress
---the table is updated with this new output below

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)---The null values in main Property Address field in the original table is replaced with the a.PropertyADDRESS USING ISNULL
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


----Rerun and check if there are still Null values in a.property, this tests the update

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)----if a.propertyAddress is null, populate it with b.propertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ] 
WHERE a.PropertyAddress is null

----Check original table
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

----Breaking out address into Individual Column(address,city,column)
 

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

---substring breaks the address from the first character to where the comma ends
SELECT
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress))as Address  ----The substring selects the propertyAddress column, starting from its 1st position and ending where the comma stops
FROM PortfolioProject.dbo.NashvilleHousing----------the CHARINDEX is used to search for specific value which is the the comma, the substring starts from the first position and ends where there is a comma

---the charindex is numeric and to remove comma, 1 can be subtracted, THE CODE BELOW SHOWS THE TOTAL CHARACTER NUMBERS USING CHAR INDEX
SELECT
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress))as Address,---The substring selects the propertyAddress column, starting from its 1st position and ending where the comma stops
CHARINDEX(',', PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress) -1)as Address---going one behind the comma
---CHARINDEX(',', PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress) -1)as Address,
SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress)+1,LEN(PropertyAddress))as Address----The substring starts characters after the comma and  ends at the full length of the propertyaddress i.e the last character of the propertyaddress
FROM PortfolioProject.dbo.NashvilleHousing

----Updating the tables with the substrings data
ALTER TABLE NashvilleHousing
Add SplitPropertyAddress nvarchar(255);

UPDATE NashvilleHousing
SET SplitPropertyAddress= SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress) -1)

ALTER TABLE NashvilleHousing
Add CityPropertyAddress nvarchar(255);

UPDATE NashvilleHousing
SET CityPropertyAddress=SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress)+1,LEN(PropertyAddress))


----Viewing updated tables
SELECT SplitPropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT CityPropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

----Separating the OwnerAddress

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.') ,1) ---Parsename for retrieving four-part string with dots, the commas are converted to dots with REPLACE
FROM PortfolioProject.dbo.NashvilleHousing ---Parsename counts from the back, therefore the integer 1 starts backwards, to correct this, count from bottom as in the code below

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.') ,3), PARSENAME(REPLACE(OwnerAddress,',', '.') ,2), PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing



----Updating the table with the parsename
ALTER TABLE NashvilleHousing
Add SplitOwnerAddress nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerAddress= PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

ALTER TABLE NashvilleHousing
Add CityOwnerAddress nvarchar(255);

UPDATE NashvilleHousing
SET CityOwnerAddress=PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)


ALTER TABLE NashvilleHousing
Add StateOwnerAddress nvarchar(255);

UPDATE NashvilleHousing
SET StateOwnerAddress=PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


----Change Y and N to Yes and No in the SoldAsVacant field
SELECT DISTINCT(SoldAsVacant) ---Counting all unique data in the sales vacant field
FROM PortfolioProject.dbo.NashvilleHousing


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)---Counting all unique data in the sales vacant field
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, ----Changing Y and N to Yes and No
CASE WHEN SoldAsVacant= 'Y'THEN 'Yes'
       WHEN SoldAsVacant= 'N'THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant= 'Y'THEN 'Yes'
       WHEN SoldAsVacant= 'N'THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)---Counting all unique data in the sold as vacant field to check update
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-----Removing Duplicates
SELECT *,
	ROW_NUMBER() OVER (   -----In duplicates, there might be duplicate rows, in order to uniquely separate these rows, ROW_NUMBER CAN BE USED,RANK also serves the same purpose
	PARTITION BY ParcelID,          ----ROW_NUMBER assigns sequential integers to the rows. PARTITION divides the result set, without it, one single partition is seen as the result
	             PropertyAddress,
				 SalePrice,
				 SaleDate,---- data would be partitioned by these fields, in cases where 2 or more row similar data in these fields, the rows are rank 1,2,3 or 4,depending on the number of duplicates
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

---Create CTE and use it to filter tables where there are duplicated rows

WITH RowNumCte AS(
SELECT *,
	ROW_NUMBER() OVER (   -----In duplicates, there might be duplicate rows, in order to uniquely separate these rows, ROW_NUMBER CAN BE USED,RANK also serves the same purpose
	PARTITION BY ParcelID,          ----ROW_NUMBER assigns sequential integers to the rows. PARTITION divides the result set, without it, one single partition is seen as the result
	             PropertyAddress,
				 SalePrice,
				 SaleDate,---- data would be partitioned by these fields, in cases where 2 or more row similar data in these fields, the rows are rank 1,2,3 or 4,depending on the number of duplicates
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
---ORDER BY ParcelID---ORDER BY DOES NOT WORK WITH CTE
)
Select*
from RowNumCte

--------Showing duplicates

WITH RowNumCte AS(
SELECT *,
	ROW_NUMBER() OVER (   -----In duplicates, there might be duplicate rows, in order to uniquely separate these rows, ROW_NUMBER CAN BE USED,RANK also serves the same purpose
	PARTITION BY ParcelID,          ----ROW_NUMBER assigns sequential integers to the rows. PARTITION divides the result set, without it, one single partition is seen as the result
	             PropertyAddress,
				 SalePrice,
				 SaleDate,---- data would be partitioned by these fields, in cases where 2 or more row similar data in these fields, the rows are rank 1,2,3 or 4,depending on the number of duplicates
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
---ORDER BY ParcelID---ORDER BY DOES NOT WORK WITH CTE
)
Select*
from RowNumCte
where row_num > 1

----Deleting Duplicates
WITH RowNumCte AS(
SELECT *,
	ROW_NUMBER() OVER (   -----In duplicates, there might be duplicate rows, in order to uniquely separate these rows, ROW_NUMBER CAN BE USED,RANK also serves the same purpose
	PARTITION BY ParcelID,          ----ROW_NUMBER assigns sequential integers to the rows. PARTITION divides the result set, without it, one single partition is seen as the result
	             PropertyAddress,
				 SalePrice,
				 SaleDate,---- data would be partitioned by these fields, in cases where 2 or more row similar data in these fields, the rows are rank 1,2,3 or 4,depending on the number of duplicates
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
---ORDER BY ParcelID---ORDER BY DOES NOT WORK WITH CTE
)
DELETE 
from RowNumCte
where row_num > 1

------------Deleting Unused column

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate