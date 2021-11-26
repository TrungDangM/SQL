USE brainstation;
SHOW TABLES;

SHOW COLUMNS 
FROM campaign;

SHOW COLUMNS 
FROM category;

SHOW COLUMNS 
FROM country;

SHOW COLUMNS 
FROM currency;

SELECT *
FROM currency;

SHOW COLUMNS 
FROM sub_category;

# Exploring campaign table
SELECT *
FROM campaign
LIMIT 10;
# 15000 rows

SELECT *
FROM campaign
LIMIT 10;
campaign
# How many project ?
SELECT COUNT(id)
FROM campaign;
# 15000 id, because id is premary key = not replicate

# How many distinct subcategory, country, and currency
SELECT 
COUNT(DISTINCT sub_category_id)  as subidnb, 
COUNT(DISTINCT country_id) as countrynb,
COUNT(DISTINCT currency_id) as currencynb
FROM campaign;

# launched date and deadline date (datetime)
SELECT launched as ldate,
deadline as ddate
FROM campaign
ORDER BY ldate DESC
LIMIT 10;

SELECT launched as ldate,
deadline as ddate
FROM campaign
ORDER BY ldate ASC
LIMIT 10;
# the year span is between 2009 to 2018
# it seems date the date column only contain date with the format yyyy-mm-dd 
# we have to change that
# it seems that the duration for one project is within a year..
#to check , we can look for record where launchedyear and deadlineyear is different

SELECT *
FROM campaign
WHERE launched BETWEEN '2010-01-01'AND '2010-12-31';

SELECT DISTINCT(YEAR(launched)) as launchedyears
FROM campaign
ORDER BY launchedyears;
# 2009 to 2018

SELECT DISTINCT(YEAR(deadline)) as deadlineyears
FROM campaign
ORDER BY deadlineyears;
# 2009 to 2018

SELECT COUNT(*)
FROM campaign
WHERE YEAR(launched) = YEAR(deadline);
# 13923 rows

SELECT COUNT(*)
FROM campaign;
# 15000 rows

#There is about 1000 records that years are different.
SELECT COUNT(*)
FROM campaign
WHERE YEAR(launched) <> YEAR(deadline);
# 1077 rows

SELECT *
FROM campaign
WHERE YEAR(launched) <> YEAR(deadline);
# should be recalculated in nb of days.

SELECT id,  DATEDIFF(deadline, launched) as daynb, goal, pledged, backers, outcome
FROM campaign
ORDER BY daynb DESC
LIMIT 20 ;
# the max duration is 91-92 days

SELECT id,  DATEDIFF(deadline, launched) as daynb, goal, pledged, backers, outcome
FROM campaign
ORDER BY daynb ASC
LIMIT 20 ;
# the min duration is 1 day

SELECT goal
FROM campaign
order by goal DESC
LIMIT 10;
# so far we dont know about the currency

SELECT COUNT(backers) as cnt, outcome
FROM campaign
GROUP BY outcome
order by cnt DESC;

# to see how many classes in the class attribute (outcome), also the distribution of these classes
SELECT outcome, COUNT(outcome)
FROM campaign
GROUP BY (outcome);

# Category table
SELECT *
FROM category;
# there is 15 categories

SELECT *
FROM country;
# 23 countries codes

SELECT *
FROM currency;
# 14 currencies codes

SELECT COUNT(*)
FROM sub_category;
# 159 subcategories
SELECT *
FROM sub_category
LIMIT 10;
# that link with category_id


# To see what country which have the highest number of successful campains 
SELECT country.id, country.name, COUNT(campaign.country_id)
FROM campaign, country
WHERE campaign.country_id =  country.id
AND campaign.outcome = "successful"
GROUP BY country_id
ORDER BY COUNT(campaign.country_id) DESC;

# To see what country which have the highest number of campaigns that failed
SELECT country.id, country.name, COUNT(campaign.country_id)
FROM campaign, country
WHERE campaign.country_id =  country.id
AND campaign.outcome = "failed"
GROUP BY country_id
ORDER BY COUNT(campaign.country_id) DESC;

# We are now interested only in USA campaigns, we want to see the succefull rate of the campaigns in USA

SELECT outcome AS outcome_USA, COUNT(outcome)
FROM campaign
WHERE country_id = 2
GROUP BY outcome;

SELECT COUNT(country_id)
FROM campaign
WHERE country_id = 2;

# Query all the data related to USA

SELECT *
FROM campaign
WHERE country_id = 2;
# Currency_id is not important
# goal, pledged, backers are important attribute
# outcome is class attribute
# we have to join sub_category with category
# see how many sub_catergory in the US data

SELECT count(*), sub.name
FROM campaign AS camp, sub_category AS sub
WHERE sub.id = camp.sub_category_id
AND camp.country_id = 2
GROUP BY camp.sub_category_id
ORDER BY COUNT(*) DESC;

# product design and documentary is the most popular

SELECT count(*), sub.name
FROM campaign AS camp, sub_category AS sub
WHERE sub.id = camp.sub_category_id
AND camp.country_id = 2
AND sub.name = "Games"
GROUP BY camp.sub_category_id;
# only 81 project related to games

# Checking: searching game Id from sub_category
SELECT sub.id, count(*)
FROM campaign AS camp, sub_category AS sub
WHERE sub.id = camp.sub_category_id
AND camp.country_id = 2
AND sub.name = 'Games';
# id for games is 13

# How to join two table category and campaign so that the campaign table contain one
# more column of category
# subtract date launch and deadline

SELECT *
FROM sub_category, category
WHERE sub_category.category_id = category.id
LIMIT 20;

SELECT name, COUNT(*)
FROM sub_category
GROUP BY category_id;
# joining category and sub_category relations 
SELECT *
FROM  category JOIN sub_category
WHERE sub_category.category_id = category.id;
# make sense, there is 159 rows

# joining with campaign  table

SELECT *
FROM campaign JOIN sub_category JOIN category
WHERE campaign.sub_category_id = sub_category.id
AND sub_category.category_id = category.id;
# successful @!!

#try to subtract date

SELECT id, name, TIMESTAMPDIFF(DAY,launched,deadline) AS Days
FROM campaign;

SELECT 
campaign.id, 
campaign.name AS ProjectName,
category.id AS CategoryID,
category.name AS CategoryName,
campaign.sub_category_id AS SubCategoryId,
sub_category.name AS SubCategoryName,
TIMESTAMPDIFF(DAY,campaign.launched,campaign.deadline) AS days,
campaign.goal,
campaign.pledged,
campaign.backers,
campaign.outcome
FROM campaign JOIN sub_category JOIN category
WHERE campaign.sub_category_id = sub_category.id
AND sub_category.category_id = category.id
AND campaign.country_id = 2;
# 11649 rows

SELECT name,backers, outcome
FROM campaign
WHERE backers > 20000;

SELECT count(*)
FROM campaign
WHERE  country_id =2
AND outcome =  'successful';

SELECT max(days), min(days), avg(days)
FROM campaign
WHERE  country_id =2
AND outcome =  'successful';

SELECT count(*)
FROM campaign
WHERE  country_id =2
AND outcome =  'failed';
# 6075 

SELECT 
campaign.id, 
category.id AS CategoryID,
category.name AS CategoryName,
campaign.sub_category_id AS SubCategoryId,
sub_category.name AS SubCategoryName,
campaign.goal,
campaign.pledged,
campaign.backers,
TIMESTAMPDIFF(DAY,campaign.launched,campaign.deadline) AS days,
campaign.outcome
FROM campaign JOIN sub_category JOIN category
WHERE campaign.sub_category_id = sub_category.id
AND sub_category.category_id = category.id
AND campaign.country_id = 2
AND (campaign.outcome = "successful" OR campaign.outcome = "failed")
ORDER BY campaign.id;
# 10440 rows

# if we want to include all outcomes, and all countries
SELECT 
campaign.id AS id,
campaign.name AS ProjectName,
campaign.country_id AS countryid,
country.name AS countryname,
category.id AS CategoryID,
category.name AS CategoryName,
campaign.sub_category_id AS SubCategoryId,
sub_category.name AS SubCategoryName,
campaign.goal AS goal,
currency.name AS currency,
campaign.pledged AS pledged,
campaign.backers AS backers,
TIMESTAMPDIFF(DAY,campaign.launched,campaign.deadline) AS days,
campaign.outcome AS Outcomes
FROM campaign JOIN sub_category JOIN category JOIN country JOIN currency
WHERE campaign.sub_category_id = sub_category.id
AND sub_category.category_id = category.id
AND campaign.country_id = country.id
AND campaign.currency_id = currency.id
ORDER BY campaign.id;
# 15000 rows
















SELECT COUNT(*)
FROM campaign
WHERE country_id = 2
AND (outcome =  "successful" OR outcome =  "failed" OR outcome =  "canceled" );
# 11528


SELECT 
campaign.id, 
category.id AS CategoryID,
category.name AS CategoryName,
campaign.sub_category_id AS SubCategoryId,
sub_category.name AS SubCategoryName,
campaign.goal,
campaign.pledged,
campaign.backers,
TIMESTAMPDIFF(DAY,campaign.launched,campaign.deadline) AS days,
campaign.outcome
FROM campaign JOIN sub_category JOIN category
WHERE campaign.sub_category_id = sub_category.id
AND sub_category.category_id = category.id
AND campaign.country_id = 2
AND goal >= 10000
AND (campaign.outcome = "successful" OR campaign.outcome = "failed")
ORDER BY campaign.id;
# 3909 rows

SELECT 
campaign.id, 
category.id AS CategoryID,
category.name AS CategoryName,
campaign.sub_category_id AS SubCategoryId,
sub_category.name AS SubCategoryName,
campaign.goal,
campaign.pledged,
campaign.backers,
TIMESTAMPDIFF(DAY,campaign.launched,campaign.deadline) AS days,
campaign.outcome
FROM campaign JOIN sub_category JOIN category
WHERE campaign.sub_category_id = sub_category.id
AND sub_category.category_id = category.id
AND campaign.country_id = 2
AND goal < 10000
AND (campaign.outcome = "successful" OR campaign.outcome = "failed")
ORDER BY campaign.id;
# 6531 rows



