/* ROCKBUSTER PROJECT */
-- FILM RENTAL ANALYSIS --

-- DATE: 2024-06-03



-- Descriptive statistics for relevant fields
SELECT COUNT(DISTINCT F.film_id) AS film_count,
       MODE() WITHIN GROUP (ORDER BY E.name) AS top_genre,
       MODE() WITHIN GROUP (ORDER BY F.rating) AS top_rating,
       ROUND(AVG(F.rental_rate), 2) AS avg_rental_cost,
       ROUND(AVG(F.rental_duration)) AS avg_rental_duration,
       MODE() WITHIN GROUP (ORDER BY G.name) AS top_language,
       COUNT(DISTINCT A.customer_id) AS customer_count,
       COUNT(DISTINCT J.country_id) AS country_count,
       ROUND(SUM(K.amount)) AS total_revenue
  FROM customer a
       JOIN rental b
	 ON a.customer_id = b.customer_id
       JOIN inventory c
	 ON b.inventory_id = c.inventory_id
       JOIN film_category d
	 ON c.film_id = d.film_id
       JOIN category e
	 ON d.category_id = e.category_id
       JOIN film f
	 ON c.film_id = f.film_id       
       JOIN language g
	 ON f.language_id = g.language_id
       JOIN address h
	 ON a.address_id = h.address_id
       JOIN city i
	 ON h.city_id = i.city_id
       JOIN country j
	 ON i.country_id = j.country_id
       JOIN payment k
	 ON b.rental_id = k.rental_id
;


-- Highest revenue films
SELECT d.title AS film,
       SUM(a.amount) AS revenue
  FROM payment a
       JOIN rental b
	 ON a.rental_id = b.rental_id
       JOIN inventory c
	 ON b.inventory_id = c.inventory_id
       JOIN film d
	 ON c.film_id = d.film_id
 GROUP BY d.title
 ORDER BY revenue DESC
 LIMIT 10
;


-- Lowest revenue films
SELECT d.title AS film,
       SUM(a.amount) AS revenue
  FROM payment a
       JOIN rental b
	 ON a.rental_id = b.rental_id
       JOIN inventory c
	 ON b.inventory_id = c.inventory_id
       JOIN film d
	 ON c.film_id = d.film_id
 GROUP BY d.title
 ORDER BY revenue
 LIMIT 10
;


-- Average rental days for all videos
SELECT AVG(EXTRACT(DAY FROM (return_date - rental_date))) AS avg_rental_days
  FROM rental
;


-- Number of customers per country
SELECT d.country, COUNT(*) as cnt_customers
  FROM customer a
       JOIN address b
	 ON a.address_id = b.address_id
       JOIN city c
	 ON b.city_id = c.city_id
       JOIN country d
	 ON c.country_id = d.country_id
 GROUP BY d.country
 ORDER BY cnt_customers DESC
;


-- Highest-value customers based on total revenue
SELECT c.first_name, c.last_name, f.country,
       SUM(a.amount) AS total_revenue,
       ROUND(AVG(EXTRACT(DAY FROM (b.return_date - b.rental_date)))) AS avg_rental_days
  FROM payment a
       JOIN rental b
	 ON a.rental_id = b.rental_id
       JOIN customer c
	 ON b.customer_id = c.customer_id
       JOIN address d
	 ON c.address_id = d.address_id
       JOIN city e
	 ON d.city_id = e.city_id
       JOIN country f
	 ON e.country_id = f.country_id
 GROUP BY c.first_name, c.last_name, f.country
 ORDER BY total_revenue DESC
 LIMIT 10
;


-- Total sales, revenue, and average rental days by region
WITH
region_cte AS (
SELECT CASE
       WHEN f.country IN ('Thailand', 'Indonesia', 'Bangladesh', 'Oman', 'Cambodia', 'Sri Lanka', 'Brunei',
			  'South Korea', 'Saudi Arabia', 'North Korea', 'Azerbaijan', 'Afghanistan', 'India',
			  'Iran', 'Vietnam', 'Israel', 'Malaysia', 'Kuwait', 'Japan', 'Philippines', 'Iraq',
			  'Turkey', 'China', 'Armenia', 'Pakistan', 'Yemen', 'Turkmenistan', 'United Arab Emirates',
			  'Myanmar', 'Nepal', 'Kazakstan', 'Hong Kong', 'Russian Federation', 'Bahrain', 'Taiwan') THEN 'Asia'
       WHEN f.country IN ('Cameroon', 'Egypt', 'Chad', 'Algeria', 'Gambia', 'South Africa', 'Senegal', 'Kenya',
			  'Zambia', 'Madagascar', 'Nigeria', 'Mozambique', 'Ethiopia', 'Angola', 'Tunisia', 'Sudan',
			  'Morocco', 'Malawi', 'Tanzania', 'Congo, The Democratic Republic of the', 'Runion') THEN 'Africa'
       WHEN f.country IN ('Faroe Islands', 'Italy', 'Czech Republic', 'Sweden', 'United Kingdom', 'Germany',
			  'Finland', 'Ukraine', 'Liechtenstein', 'Latvia', 'Greece', 'France', 'Estonia', 'Slovakia',
			  'Switzerland', 'Hungary', 'Belarus', 'Netherlands', 'Romania', 'Austria', 'Lithuania', 'Spain',
			  'Bulgaria', 'Moldova', 'Poland', 'Holy See (Vatican City State)', 'Yugoslavia') THEN 'Europe'
WHEN f.country IN ('Venezuela', 'Dominican Republic', 'Canada', 'Colombia', 'Saint Vincent and the Grenadines',
			  'Argentina', 'Puerto Rico', 'Chile', 'Peru', 'United States', 'Ecuador', 'Paraguay', 'Brazil',
			  'Bolivia', 'Mexico', 'Virgin Islands, U.S.', 'Anguilla', 'Greenland', 'French Guiana') THEN 'America'
       WHEN f.country IN ('Nauru', 'Tuvalu', 'New Zealand', 'Australia', 'Tonga', 'American Samoa', 'French Polynesia') THEN 'Oceania'
       END AS region,
       a.amount, b.rental_date, b.return_date
  FROM payment a
       JOIN rental b
	 ON a.rental_id = b.rental_id
       JOIN customer c
	 ON b.customer_id = c.customer_id
       JOIN address d
	 ON c.address_id = d.address_id
       JOIN city e
	 ON d.city_id = e.city_id
       JOIN country f
	 ON e.country_id = f.country_id
)

SELECT region,
       COUNT(*) as total_rentals,
       SUM(amount) AS total_revenue,
       ROUND(AVG(EXTRACT(DAY FROM (return_date - rental_date)))) AS avg_rental_days
  FROM region_cte
 GROUP BY region
 ORDER BY total_rentals DESC
;


-- Total sales, revenue, and average rental days by country
SELECT f.country,
       COUNT(*) as total_rentals,
       SUM(a.amount) AS total_revenue,
       ROUND(AVG(EXTRACT(DAY FROM (return_date - rental_date)))) AS avg_rental_days
  FROM payment a
       JOIN rental b
	 ON a.rental_id = b.rental_id
       JOIN customer c
	 ON b.customer_id = c.customer_id
       JOIN address d
	 ON c.address_id = d.address_id
       JOIN city e
	 ON d.city_id = e.city_id
       JOIN country f
	 ON e.country_id = f.country_id
 GROUP BY f.country
 ORDER BY total_rentals DESC
;


-- Total revenue, sales, and average rental days by genre
SELECT e.name AS genre,
       COUNT(*) as total_rentals,
       SUM(a.amount) AS total_revenue,
       ROUND(AVG(EXTRACT(DAY FROM (b.return_date - b.rental_date)))) AS avg_rental_days
  FROM payment a
       JOIN rental b
	 ON a.rental_id = b.rental_id
       JOIN inventory c
	 ON b.inventory_id = c.inventory_id
       JOIN film_category d
	 ON c.film_id = d.film_id
       JOIN category e
	 ON d.category_id = e.category_id
 GROUP BY e.name
 ORDER BY total_rentals DESC
;


-- Tableau visualizations data
SELECT b.rental_id, c.first_name AS customer_first_name, c.last_name AS customer_last_name,
       CASE
       WHEN f.country IN ('Thailand', 'Indonesia', 'Bangladesh', 'Oman', 'Cambodia', 'Sri Lanka', 'Brunei',
			  'South Korea', 'Saudi Arabia', 'North Korea', 'Azerbaijan', 'Afghanistan', 'India',
			  'Iran', 'Vietnam', 'Israel', 'Malaysia', 'Kuwait', 'Japan', 'Philippines', 'Iraq',
			  'Turkey', 'China', 'Armenia', 'Pakistan', 'Yemen', 'Turkmenistan', 'United Arab Emirates',
			  'Myanmar', 'Nepal', 'Kazakstan', 'Hong Kong', 'Russian Federation', 'Bahrain', 'Taiwan') THEN 'Asia'
       WHEN f.country IN ('Cameroon', 'Egypt', 'Chad', 'Algeria', 'Gambia', 'South Africa', 'Senegal', 'Kenya',
			  'Zambia', 'Madagascar', 'Nigeria', 'Mozambique', 'Ethiopia', 'Angola', 'Tunisia', 'Sudan',
			  'Morocco', 'Malawi', 'Tanzania', 'Congo, The Democratic Republic of the', 'Runion') THEN 'Africa'
       WHEN f.country IN ('Faroe Islands', 'Italy', 'Czech Republic', 'Sweden', 'United Kingdom', 'Germany',
			  'Finland', 'Ukraine', 'Liechtenstein', 'Latvia', 'Greece', 'France', 'Estonia', 'Slovakia',
			  'Switzerland', 'Hungary', 'Belarus', 'Netherlands', 'Romania', 'Austria', 'Lithuania', 'Spain',
			  'Bulgaria', 'Moldova', 'Poland', 'Holy See (Vatican City State)', 'Yugoslavia') THEN 'Europe'
       WHEN f.country IN ('Venezuela', 'Dominican Republic', 'Canada', 'Colombia', 'Saint Vincent and the Grenadines',
			  'Argentina', 'Puerto Rico', 'Chile', 'Peru', 'United States', 'Ecuador', 'Paraguay', 'Brazil',
			  'Bolivia', 'Mexico', 'Virgin Islands, U.S.', 'Anguilla', 'Greenland', 'French Guiana') THEN 'America'
       WHEN f.country IN ('Nauru', 'Tuvalu', 'New Zealand', 'Australia', 'Tonga', 'American Samoa', 'French Polynesia') THEN 'Oceania'
       END AS region,
       f.country AS country, h.title AS film_title, h.rating AS film_rating, j.name AS genre, a.amount AS paid_amount,
       ROUND(AVG(EXTRACT(DAY FROM (b.return_date - b.rental_date)))) AS rental_duration
  FROM payment a
       JOIN rental b
         ON a.rental_id = b.rental_id
       JOIN customer c
	 ON b.customer_id = c.customer_id
       JOIN address d
	 ON c.address_id = d.address_id
       JOIN city e
	 ON d.city_id = e.city_id
       JOIN country f
	 ON e.country_id = f.country_id
       JOIN inventory g
	 ON b.inventory_id = g.inventory_id
       JOIN film h
	 ON g.film_id = h.film_id
       JOIN film_category i
	 ON h.film_id = i.film_id
       JOIN category j
	 ON i.category_id = j.category_id
 GROUP BY b.rental_id, c.first_name, c.last_name, f.country, h.title, h.rating, j.name, a.amount
;
