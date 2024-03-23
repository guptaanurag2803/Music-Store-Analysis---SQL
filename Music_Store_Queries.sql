-- Q1. Who is the senior most employee based on job title?as

SELECT first_name, last_name, title
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2. Which countries have the most invoices?

SELECT billing_country, COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC
LIMIT 1;

-- Q3. What are top 3 values of total of invoices?

SELECT total
FROM invoice
GROUP BY total
ORDER BY total DESC
LIMIT 3;

-- Q4. Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals

SELECT billing_city, sum(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

-- Q5. Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money

SELECT c.customer_id, c.first_name, c.last_name, sum(total) AS customer_total
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY customer_total DESC
LIMIT 1;

-- Q6. Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting WITH A

SELECT distinct c.email, c.first_name, c.last_name
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN customer c ON i.customer_id = c.customer_id
WHERE t.genre_id IN (SELECT genre_id
				 FROM genre
				 WHERE name LIKE 'Rock')
ORDER BY c.email;

-- Q5. Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands

SELECT ar.artist_id, ar.name, COUNT(ar.artist_id) AS track_count
FROM track t
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
WHERE t.genre_id IN (SELECT genre_id
				   FROM genre
				   WHERE name LIKE 'Rock')
GROUP BY ar.artist_id, ar.name
ORDER BY track_count DESC
LIMIT 10;

-- Q9. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length WITH the
-- longest songs listed first

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT avg(milliseconds)
					 FROM track)
ORDER BY milliseconds DESC;

-- Q10. Find how much amount spent by each customer ON artists? Write a query to return
-- customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

												   
-- Q11. We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres

WITH cte AS
	(SELECT i.billing_country country, g.name genre_name, t.genre_id genre_id, COUNT(t.genre_id) AS genre_count
	FROM invoice i
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY i.billing_country, g.name, t.genre_id)
SELECT country, genre_id, genre_name, genre_count
FROM cte WHERE
(country, genre_count) IN (SELECT country, max(genre_count)
						FROM cte
						GROUP BY country)
ORDER BY 1

-- Q12. . Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount

WITH cte AS
	(SELECT i.billing_country country, i.customer_id, sum(il.unit_price * il.quantity) AS spent
	FROM invoice i
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	GROUP BY country, i.customer_id)
SELECT cte.country, cte.customer_id, c.first_name, c.last_name, cte.spent
FROM cte
JOIN customer c ON cte.customer_id = c.customer_id
WHERE (cte.country, cte.spent) IN (SELECT country, max(spent)
									   FROM cte
									   GROUP BY country)
ORDER BY cte.country 