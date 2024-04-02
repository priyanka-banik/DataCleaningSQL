select * from dbo.NashvilleHousing

--standardise date format
select SaleDateConverted--, convert(date, SaleDate) 
from dbo.NashvilleHousing

Alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

--populate property address data
select PropertyAddress from dbo.NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a --mention alias not the actual table name while updating
set propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--breaking out the address into individual column (address, city, state)
 select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as address,
 substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as city
 from dbo.NashvilleHousing

 Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity =  substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
select * from dbo.NashvilleHousing

--Remove duplicates
with RowNumCTE AS(
select *, ROW_NUMBER() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by uniqueid
				 ) row_num
				 from dbo.NashvilleHousing
				 --order by parcelid
				 )

delete from RowNumCTE 
WHERE row_num >1 

select *  FROM RowNumCTE 
WHERE row_num >1 
order by PropertyAddress


--delete unused columns
alter table dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate