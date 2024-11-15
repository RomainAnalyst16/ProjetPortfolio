Select * 
from PortfolioProject..NashVilleHousing



-- Standardize Date Format


Select SaleDate, convert(Date,SaleDate)
from PortfolioProject..NashVilleHousing

Update NashVilleHousing
Set SaleDate = convert(Date,SaleDate)

Alter table NashVilleHousing
Add SaleDateConverted Date;

Update NashVilleHousing
Set SaleDateConverted = convert(Date,SaleDate)


-- Populate Property Adress data

Select * 
from PortfolioProject..NashVilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing a
join PortfolioProject.dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing a
join PortfolioProject.dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




-- breaking out Address into Individual Columns (Address, city, State)

Select PropertyAddress 
from PortfolioProject..NashVilleHousing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject..NashVilleHousing

Alter table NashVilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashVilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table NashVilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashVilleHousing
Set PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


Select * 
from PortfolioProject..NashVilleHousing



Select OwnerAddress 
from PortfolioProject..NashVilleHousing

Select 
PARSENAME(replace(OwnerAddress, ',','.') ,3)
, PARSENAME(replace(OwnerAddress, ',','.') ,2)
, PARSENAME(replace(OwnerAddress, ',','.') ,1)
from PortfolioProject..NashVilleHousing


Alter table NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashVilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.') ,3)

Alter table NashVilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashVilleHousing
Set OwnerSplitCity  = PARSENAME(replace(OwnerAddress, ',','.') ,2)

Alter table NashVilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashVilleHousing
Set OwnerSplitState  = PARSENAME(replace(OwnerAddress, ',','.') ,1)


-- Change Y and N to Yes and No in "sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashVilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashVilleHousing

Update NashVilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end




-- Remove Duplicates

with RowNumCTE as(
Select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from PortfolioProject..NashVilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress


-- Delete unused Columns


Select * 
from PortfolioProject..NashVilleHousing

alter table PortfolioProject..NashVilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table PortfolioProject..NashVilleHousing
drop column SaleDate

