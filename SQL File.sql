Create database if not exists music_store_sales;
use music_store_sales;

-- QUESTION SET 1

-- Q1: Who is the senior most employee based on job title? 

select * from employee;

select * from employee
order by levels desc 
limit 1 ;

insert into employee (employee_id,	last_name,	first_name,	title, levels ,address,	city,
	state,	country,	postal_code,email) 
    value (9,"Madan","Mohan","Senior General Manager","L7",	"1008 Vrinda Ave MT",
	"Edmonton","AB","Canada","T5K 2N1","madan.mohan@chinookcorp.com");
    
select * from employee 
order by levels desc
limit 1 ;

-- Q2: Which countries have the most Invoices? 
select * from invoice;

select billing_country , count(invoice_id) as Total_invoice
from invoice 
group by 1
order by 2 desc 
limit 1;

select billing_country, count(billing_country) as Invoice_Count 
from invoice 
group by billing_country
order by Invoice_Count desc;

-- Q3: Which countries have the 2nd most Invoices? 
select billing_country, count(billing_country) as Invoice_Count 
from invoice 
group by billing_country
order by Invoice_Count desc
limit 1 offset 1;

-- Q3: What are top 3 values of total invoice? 
select * from invoice;

select total , invoice_id 
from invoice
order by total desc
limit 3;

select total from invoice
group by total
order by total desc
limit 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city , sum(total) as total_sales
from invoice 
group by 1
order by 2 desc
limit 1;

select * from invoice;

select billing_city, sum(total) as total_sales
from invoice 
group by billing_city
order by total_sales desc 
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select * from customer ;

select c.customer_id , c.first_name , c.last_name , sum(i.total) as total_spent
from customer c
join invoice i on i.customer_id = c.customer_id
group by 1,2,3
order by 4 desc 
limit 1;

select c.customer_id , c.first_name, c.last_name, sum(invoice.total) as total_sales
from customer c
join invoice on c.customer_id = invoice.customer_id
group by c.customer_id , c.first_name , c.last_name
order by total_sales desc
limit 1;

-- Question set 2

-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A. 
select * from customer ;
select c.email, c.first_name , c.last_name , g.name from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line inv on inv.invoice_id = i.invoice_id
join track t on t.track_id = inv.track_id
join genre g on g.genre_id = t.genre_id
where g.name = "Rock"
order by 1;

select distinct c.email, c.first_name , c.last_name, g.name from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line inv on inv.invoice_id = i.invoice_id
join track t on t.track_id = inv.track_id
join genre g on g.genre_id = t.genre_id
where g.name like "Rock"
order by c.email;

select distinct c.email as email, c.first_name , c.last_name from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line inv on inv.invoice_id = i.invoice_id
where track_id in ( 
					select t.track_id from track t
                    join genre g on g.genre_id = t.genre_id
                    where g.name like "Rock")
order by c.email desc;

-- Q2.Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands. 

select * from track;
select a.artist_id, a.name , count(t.track_id) as total_tracks  from artist a 
join album2 al on al.artist_id = a.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name like "Rock"
group by a.artist_id, a.name
order by total_tracks desc 
limit 10;


SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id , artist.name 
ORDER BY number_of_songs DESC
LIMIT 10;


-- Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. 

select * from track ;
select name , milliseconds from track 
where milliseconds > ( select avg(milliseconds) as avg_milli from track)
order by milliseconds desc;

-- Question set 3
-- Q1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
-- first find top selling artist and then use this artist to find top spending customer for this artist.

with best_selling_artist as 
(select a.artist_id , a.name , sum(inv.unit_price * inv.quantity) as total_sales from artist a
join album2 al on a.artist_id = al.artist_id
join track t on t.album_id = al.album_id
join invoice_line inv on inv.track_id = t.track_id
group by 1,2
order by total_sales desc
limit 1)
select c.first_name , c.last_name , bsa.name , sum(inv.unit_price * inv.quantity) as Amount_spent from customer c 
join invoice i on i.customer_id =c.customer_id
join invoice_line inv on inv.invoice_id = i.invoice_id 
join track t on t.track_id = inv.track_id
join album2 al on al.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1,2,3
order by amount_spent desc
limit 5;

-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres. 

with popular_genre as (
select c.country , g.name , count(inv.quantity) as Quantuity_sold , 
row_number() over (partition by c.country order by count(inv.quantity) desc) as row_no 
from  invoice i
join customer c on c.customer_id = i.customer_id
join  invoice_line inv on inv.invoice_id = i.invoice_id
join track t on t.track_id = inv.track_id
join genre g on g.genre_id = t.genre_id 
group by 1,2
order by 1 asc , 3 desc)
select * from popular_genre 
where row_no <=1;


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;



select customer_id , country , 
row_number() over ( order by customer_id ) as row_no 
from customer;





