create database netflix;

--data cleaning
--check data types
alter table netflix_titles
alter column release_year int;

alter table netflix_titles
alter column date_added date;

--remove duplicates
with cte as (
	select *,
	ROW_NUMBER() over(
	partition by title, [type], release_year
	order by show_id) as rn
	from netflix_titles
)
delete from cte where rn > 1;

--handle missing values
update netflix_titles
set country = 'unkown'
where country is null or country = ' ';

update netflix_titles
set listed_in = 'unkown'
where listed_in is null or listed_in = ' ';

update netflix_titles
set director = 'unkown'
where director is null;

update netflix_titles
set [cast] = 'unkown'
where [cast] is null;

--create a cleaned table
select show_id, [type], title, director, [cast], country, date_added, 
release_year, rating, duration, listed_in as genre, [description]
into NetflixCleaned
from netflix_titles;

--analysis queries
--movies vs tv shows count
select [type], count(*) as total
from NetflixCleaned
group by [type];

--titles added by year 
select year(date_added) as year_added, count(*) as total
from NetflixCleaned
where date_added is not null
group by year(date_added)
order by year_added;

--top 10 countries by number of titles
select top 10 country, count(*) as total
from NetflixCleaned
where country != 'unkown'
group by country
order by total desc;

--rating distribution
select rating, count(*) as total
from NetflixCleaned
group by rating
order by total desc;

--top 10 directors
select director, count(*) as total
from NetflixCleaned
where director != 'unkown'
group by director
order by total desc;

--genre popularity
select genre, count(*) as total 
from NetflixCleaned
group by genre
order by total desc;

--average release year by type
select [type], avg(release_year) as avg_release_year
from NetflixCleaned
group by [type];

--recently added titles
select title, [type], country, date_added
from NetflixCleaned
where date_added >= DATEADD(year, -5, GETDATE())
order by date_added desc;

--longest duration movies
select top 10 title, duration, release_year
from NetflixCleaned
where [type]='Movie' and duration like '%min'
order by cast(replace(duration, 'min', ' ') as int) desc;

--tv shows with most seasons
select top 10 title, duration
from NetflixCleaned
where [type] = 'TV show' and duration like '%season%'
order by cast(replace(replace(duration, 'season', ' '), 's', ' ') as int) desc;


