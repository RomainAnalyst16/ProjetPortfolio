-- explorary Data Analysis

select *
from layoffs_staging2
;

select country, avg(funds_raised_millions)
from layoffs_staging2
GROUP BY country
order by 1;

with avg_raised_country as
(select country, avg(funds_raised_millions) as avg_funds
from layoffs_staging2
group by country
order by 2 desc), Country_funds_rank as
(select *,
RANK() over(ORDER BY avg_funds desc) as Ranking1
from avg_raised_country
where avg_funds is not null)

Select *
from Country_funds_rank
where Ranking1 <= 5
;



select max(total_laid_off) , max(percentage_laid_off)
from layoffs_staging2; 

select * 
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;


select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging2;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select * 
from layoffs_staging2;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

select company, AVG(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;



select substring(`date`, 1, 7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `Month`
order by 1 asc
;

with Rolling_Total as
(
select substring(`date`, 1, 7) as `Month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `Month`
order by 1 asc
)
select `Month`, total_off,
sum(total_off) over(order by `Month`) as rolling_total
from Rolling_Total;


select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc
;

With Company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), Company_Year_Rank as
(select *, 
DENSE_RANK() over(PARTITION BY years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
)

select *
from Company_Year_Rank
where Ranking <= 5
;
















































