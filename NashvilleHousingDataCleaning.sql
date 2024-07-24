/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM NashvileHousing

---------------------------------------------------------------------------------------

-- Standrdize Date Format

SELECT SaleDateConverted, Convert(date,SaleDate)
FROM NashvileHousing

Alter Table NashvileHousing
Add SaleDateConverted Date ;

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


--Populate Property Address Data

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvileHousing a
JOIN NashvileHousing b
	on a.ParcelID = b.ParcelID
	and
	a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvileHousing a
JOIN NashvileHousing b
	on a.ParcelID = b.ParcelID
	and
	a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select *
from NashvileHousing
--where PropertyAddress is null


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- Beaking out Address into Individual Columns (Street, City, State) 

Select *
from NashvileHousing

Select 
substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1),
   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) - 1)
from NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitStreet VARCHAR(255), PropertySplitCity VARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitStreet = substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvileHousing
ADD OwnerSplitStreet VARCHAR(255), OwnerSplitCity VARCHAR(255), OwnerSplitState VARCHAR(255);


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvileHousing

Update NashvileHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from NashvileHousing


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- Change Y and N in YES and NO inn "Sold as Vacant" feild 

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvileHousing
group by SoldAsVacant

Select 
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
from NashvileHousing

Update NashvileHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END

Select *
From NashvileHousing

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDateConverted,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From NashvileHousing

)

Select *
From RowNumCTE
Where row_num > 1
order by ParcelID

--Delete 
--From RowNumCTE
--Where row_num > 1


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

Select *
From NashvileHousing
	
ALTER TABLE NashvileHousing
DROP COLUMN PropertyAddress,OwnerAddress