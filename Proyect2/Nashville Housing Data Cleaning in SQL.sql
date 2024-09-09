SELECT * FROM PortafolioProyect..NashvilleHousing


-- Standardize date format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortafolioProyect..NashvilleHousing

UPDATE PortafolioProyect..NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE PortafolioProyect..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortafolioProyect..NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-- Populate Propery Addrees date

SELECT PropertyAddress, ParcelID, [UniqueID ]
FROM PortafolioProyect..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortafolioProyect..NashvilleHousing a
JOIN PortafolioProyect..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortafolioProyect..NashvilleHousing a
JOIN PortafolioProyect..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortafolioProyect..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertySlipAddress, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS PropertySlipCity
FROM PortafolioProyect..NashvilleHousing

ALTER TABLE PortafolioProyect..NashvilleHousing
ADD PropertySlipAddress NVARCHAR(255);

UPDATE PortafolioProyect..NashvilleHousing
SET PropertySlipAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE PortafolioProyect..NashvilleHousing
ADD PropertySlipCity NVARCHAR(255);

UPDATE PortafolioProyect..NashvilleHousing
SET PropertySlipCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM PortafolioProyect..NashvilleHousing

SELECT 
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
FROM PortafolioProyect..NashvilleHousing

ALTER TABLE PortafolioProyect..NashvilleHousing
ADD OwerSlipAddress NVARCHAR(255);

UPDATE PortafolioProyect..NashvilleHousing
SET OwerSlipAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)


ALTER TABLE PortafolioProyect..NashvilleHousing
ADD OwerSlipCity NVARCHAR(255);

UPDATE PortafolioProyect..NashvilleHousing
SET OwerSlipCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)


ALTER TABLE PortafolioProyect..NashvilleHousing
ADD OwerSlipState NVARCHAR(255);

UPDATE PortafolioProyect..NashvilleHousing
SET OwerSlipState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortafolioProyect..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM PortafolioProyect..NashvilleHousing

UPDATE PortafolioProyect..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-- Remove Deletes

SELECT * FROM PortafolioProyect..NashvilleHousing

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num	
FROM PortafolioProyect..NashvilleHousing
--ORDER BY [UniqueID ]
)
DELETE 
FROM RowNumCTE
WHERE Row_Num > 1

SELECT *
FROM RowNumCTE
WHERE Row_Num > 1


-- Delete Unsed Columns

SELECT * FROM PortafolioProyect..NashvilleHousing

ALTER TABLE PortafolioProyect..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate