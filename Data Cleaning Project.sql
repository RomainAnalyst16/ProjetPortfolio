-- Data Cleaning

select *
from layoffs;

-- 1. Remove duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove any columns 


create table layoffs_staging
like layoffs;


select *
from layoffs_staging;

insert layoffs_staging
select * 
from layoffs;


-- 1. Remove duplicates 

select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num >1;

select *
from layoffs_staging
where company = 'Casper';

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
delete
from duplicate_cte
where row_num >1;



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2
where row_num > 1;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete 
from layoffs_staging2
where row_num > 1;


-- 2. Standardize the Data = findings issues and fixing it

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
;

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';


select distinct country, trim(Trailing '.'from country)
from layoffs_staging2
order by 1
;

update layoffs_staging2
set country = trim(Trailing '.'from country)
where country like 'United States%';

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter TABLE layoffs_staging2
modify COLUMN `date` DATE;

select *
from layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company like 'Bally%';


update layoffs_staging2
set industry = null
where industry = '';


SELECT t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null  
and t2.industry is not null;

select *
from layoffs_staging2;



-- 4. Remove any columns


select *
from layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off is null;

select *
from layoffs_staging2;

alter table layoffs_staging2
drop COLUMN row_num;





