--Data Cleaning

Select * 
FROM PortfolioProject.dbo.NashvilleHousing
order by [UniqueID ]

-- making standard date format

Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
ADD  SaleDateConverted date;

Update PortfolioProject.dbo.NashvilleHousing
SET Saledateconverted = CONVERT(date,SaleDate)

--- populate null poperty address data

Select h.ParcelID,h.PropertyAddress,v.ParcelID,v.PropertyAddress,ISNULL(h.PropertyAddress , v.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as h
join PortfolioProject.dbo.NashvilleHousing as v
ON h.ParcelID = v.ParcelID
AND h.[UniqueID ] <> v.[UniqueID ]
where h.PropertyAddress is null

update h
SET PropertyAddress = ISNULL(h.PropertyAddress , v.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as h
join PortfolioProject.dbo.NashvilleHousing as v
ON h.ParcelID = v.ParcelID
AND h.[UniqueID ] <> v.[UniqueID ]
where h.PropertyAddress is null

--- breaking PropertyAddress in PropertySplitAddress and PropertySplitCity

Select SUBSTRING(PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
ADD  PropertySplitAddress nvarchar(225);


Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(225);


Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))


--- Another Method for breaking OwnerAddress in OwnerSplitAddress ,OwnerSplitCity,OwnerSplitState

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),PARSENAME(REPLACE(OwnerAddress,',','.'),2),PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(225);


Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(225);


Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(225);


Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


---- select y to yes and n to No in SoldAsVacant


select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by  SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
 , Case when SoldAsVacant = 'Y' Then 'Yes'
        when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =  Case when SoldAsVacant = 'Y' Then 'Yes'
        when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END

---- delete duplicate values

WITH RowNUmCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
              ORDER BY 
               uniqueID
        ) row_num
     FROM 
         PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM RowNUmCTE
WHERE row_num > 1;

-- delete Unwanted columns

Select *
FROM PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,SaleDate,TaxDistrict