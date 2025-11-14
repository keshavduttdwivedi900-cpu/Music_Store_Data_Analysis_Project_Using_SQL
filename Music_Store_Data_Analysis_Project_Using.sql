--Q1: Who is the senior most employee based on job title ?
SELECT * FROM EMPLOYEE;

SELECT * 
FROM EMPLOYEE
ORDER BY levels desc
LIMIT 1

--Q2:Which countries have the most Invoices?


SELECT COUNT(*) as c,billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c  desc 
LIMIT 1

--Q3:What are the top 3 values of total invoice
SELECT * FROM INVOICE;

select total

from invoice
GROUP BY total
order by total desc
limit 3

--4)Which city has the best customers?We would like to throw a
--promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals
select * from invoice 

select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total desc
limit 1

--Q5:Who is the best customer?
--The customer who has spent the most money money will be declared
--the best customer.Write a query that returns the person who has 
--spent the most money
SELECT * FROM customer;
select * from invoice ;


SELECT c.customer_id ,concat(first_name,' ',last_name),SUM(i.total) as total
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id,concat(first_name,'',last_name)
ORDER BY total desc
limit 1

--Question SET2 - Moderate
--Q1: Write query to return the email,first name,last name,&Genre
--of all Rock Music listeners.Return your list order alphabetically
--by email starting with A
select * from customer
select * from invoice
select * from invoice_line
select * from track

SELECT DISTINCT email,first_name,last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
     SELECT track_id FROM track
	 JOIN genre ON track.genre_id = genre.genre_id
	 WHERE genre.name LIKE 'ROCK'
)
ORDER BY email;

--OR

SELECT DISTINCT 
    c.email,
    c.first_name,
    c.last_name,
    g.name AS genre
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

--Let's invite the artist who have written the most rock music in
--our dataset.Write a query that returns the Artist name and total 
--track count of the top 10 rock bands
SELECT * FROM Artist
SELECT * FROM Album
SELECT * FROM Track

SELECT artist.artist_id,artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'ROCK'
GROUP BY artist.artist_id
ORDER BY number_of_songS DESC
LIMIT 10;

--OR

SELECT 
    a.artist_id,
    a.name AS artist_name,
    COUNT(*) AS total_rock_tracks
FROM track t
JOIN album al 
    ON al.album_id = t.album_id
JOIN artist a 
    ON a.artist_id = al.artist_id
JOIN genre g 
    ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_rock_tracks DESC
LIMIT 10;

--Q3:Return all the track names that have a song length longer than the 
--average song length.Return the name and milliseconds for each track.
--Order by the song length with the longest songs listed first.

SELECT * FROM TRACK;


SELECT name,milliseconds
FROM track
where milliseconds > (
      SELECT AVG(milLiseconds) AS avg_track_length
	  FROM track)
Order BY milLiseconds DESC;

--Question Set 3 - Advance
--Q1: Find how much amount spent by each customer on artists?
--Write a query to return customer name,artist name and total spent

WITH best_selling_artist AS (
     SELECT artist.artist_id AS artist_id,artist.name AS artist_name,
	 SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	 FROM invoice_line
	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN album ON album.album_id = track.album_id
	 JOIN artist ON artist.artist_id = album.artist_id
	 GROUP BY 1
	 ORDER BY 3 DESC
	 LIMIT 1
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
Order by 5 DESC;


--Q2) We want to find out the most popular music Genre for each country.
--We detremine the most popular genre as the genre with the highest amount of
--purchase .Write a query that returns each country along with the top genre
--.For countries where the maximum number of purchases is shared return all 
--genres.

WITH popular_genre AS
(     
     SELECT COUNT(invoice_line.quantity) AS purchases,customer.country,genre.name,genre.genre_id,
	 ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
	 FROM invoice_line
	 JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	 JOIN customer ON customer.customer_id = invoice.customer_id
	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN genre ON genre.genre_id = track.genre_id
	 GROUP BY 2,3,4
	 ORDER BY 2 ASC , 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


--Method 2

WITH RECURSIVE
     sales_per_country AS(
          SELECT COUNT(*) AS purchases_per_genre,customer.country,genre.name,genre.genre_id
		  FROM invoice_line
		  JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		  JOIN customer ON customer.customer_id = invoice.customer_id
		  JOIN track ON track.track_id = invoice_line.track_id
		  JOIN genre ON genre.genre_id = track.genre_id
		  GROUP BY 2,3,4
		  ORDER BY 2
	 ),
	 max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number,country
	     FROM sales_per_country
		 Group by 2
		 ORDER BY 2)

SELECT sales_per_country.*
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number

--or
WITH sales_per_country AS (
    SELECT 
        COUNT(*) AS purchases_per_genre,
        customer.country,
        genre.name AS genre_name,
        genre.genre_id
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
),

max_genre_per_country AS (
    SELECT 
        country,
        MAX(purchases_per_genre) AS max_genre_number
    FROM sales_per_country
    GROUP BY country
)

SELECT 
    s.*
FROM sales_per_country s
JOIN max_genre_per_country m 
    ON s.country = m.country
   AND s.purchases_per_genre = m.max_genre_number
ORDER BY s.country;

--Q3:Write a query that determines the customer that has spent the most on music
-- for each country.Write a query that return the country along
--with the top customer and how much they spent.For countries where 
--the top amount spent is shared ,provide all customers who spent this amount
SELECT * FROM Invoiceline
SELECT * FROM Invoice
SELECT * FROM  Customer

WITH RECURSIVE 
     customer_with_country AS (
          SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		  FROM invoice
		  GROUP BY 1,2,3,4
		  ORDER BY 1,5 DESC),

	 country_max_spending AS(
	      SELECT billing_country,MAX(total_spending) AS max_spending
		  FROM customer_with_country
		  GROUP BY billing_country)

SELECT cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

--OR
WITH customer_with_country AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country
),

country_max_spending AS (
    SELECT 
        billing_country,
        MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)

SELECT 
    cc.billing_country,
    cc.total_spending,
    cc.first_name,
    cc.last_name,
    cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
    ON cc.billing_country = ms.billing_country
   AND cc.total_spending = ms.max_spending
ORDER BY cc.billing_country;

--OR

WITH Customer_with_country AS (
         SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
		 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total)DESC) AS RowNo
		 FROM invoice
		 JOIN customer ON customer.customer_id = invoice.customer_id
		 Group by 1,2,3,4
		 Order by 4 ASC,5 DESC)
SELECT * FROM Customer_with_country WHERE RowNo <= 1






































