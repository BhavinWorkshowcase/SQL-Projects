create database Air_Cargo_Data;
use Air_Cargo_Data;


-- Q1 show ER digram
alter table customer 
add primary key (customer_id);

alter table passengers_on_flights
modify seat_num varchar(10) primary key;

alter table passengers_on_flights 
add foreign key fk_customer_id(customer_id) references customer(customer_id);

alter table routes
modify route_id int primary key;

alter table passengers_on_flights 
add foreign key fk_route_id(route_id) references routes(route_id);

UPDATE ticket_details
SET p_date = STR_TO_DATE(p_date, '%d-%m-%Y');

alter table ticket_details
modify p_date date primary key;

alter table ticket_details 
add foreign key fk_customer_id(customer_id) references customer(customer_id);


/* Q2. Write a query to create a route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport,
 destination_airport, aircraft_id, and distance_miles. Implement the check constraint for the flight number and unique constraint for the
 route_id fields. Also, make sure that the distance miles field is greater than 0.*/
 
create table route_details as select * from routes where 1=0;
 
alter table route_details 
modify flight_num int check(length(flight_num) = 4),
modify route_id int unique key ;

alter table route_details
modify distance_miles float check(distance_miles >0) ;

desc route_details;

-- Q3 Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. 
-- Take data from the passengers_on_flights table.

select customer_id , route_id from passengers_on_flights 
where route_id between 1 and 25 
order by route_id;

-- Q4 Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.

select count(*) as No_of_passengers , class_id , sum(no_of_tickets * Price_per_ticket) as total_sales
from ticket_details 
where class_id = "Bussiness"
group by 2;

-- Q5 Write a query to display the full name of the customer by extracting the first name and last name from the customer table.

select concat(first_name," ",last_name) as full_name from customer 
order by full_name;

-- Q6.Write a query to extract the customers who have registered and booked a ticket. 
-- Use data from the customer and ticket_details tables.

select c.customer_id , c.first_name , c.last_name , t.no_of_tickets from customer c
join ticket_details t on t.customer_id = c.customer_id
where t.brand is not null
group by 1,2,3,4
order by 1;

-- Q7 Write a query to identify the customer’s first name and
-- last name based on their customer ID and brand (Emirates) from the ticket_details table.

select t.customer_id , c.first_name , c.last_name , t.brand from customer c
join ticket_details t on t.customer_id = c.customer_id
where t.brand = "Emirates"
order by 1;

-- Q8 Write a query to identify the customers who have travelled 
-- by Economy Plus class using Group By and Having clause on the passengers_on_flights table. 

select customer_id , seat_num , class_id from passengers_on_flights
group by 1,2,3
having class_id = "Economy Plus";

-- Q9 Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.
 
select sum(no_of_tickets*Price_per_ticket) as total_revenew ,if(sum(no_of_tickets*Price_per_ticket) > 10000 , "revenue has crossed 10000" , "revenue has not crossed 10000") as Revenew_Status
from ticket_details;

-- Q10 Write a query to create and grant access to a new user to perform operations on a database.

-- Create a new user and set a password
CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'YourStrongPassword';

-- Grant all privileges on a specific database
GRANT ALL PRIVILEGES ON YourDatabase.* TO 'new_user'@'localhost';

-- Make sure the changes take effect
FLUSH PRIVILEGES;

-- Q11 Write a query to find the maximum ticket price for each class using window functions on the ticket_details table. 

with Max_price_ticket as 
(select class_id , price_per_ticket, row_number() over (partition by class_id order by price_per_ticket desc) as row_no 
from ticket_details)
select * from Max_price_ticket 
where row_no = 1;

-- method 2
select class_id , price_per_ticket, max(Price_per_ticket) over (partition by class_id order by price_per_ticket desc) as row_no 
from ticket_details;


-- Q12.	Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of 
-- the passengers_on_flights table.

select * from passengers_on_flights where route_id = 4;

create index per_index_route_id on passengers_on_flights(route_id);

select * from passengers_on_flights where route_id = 4;

-- Q13. For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.

EXPLAIN
SELECT *
FROM passengers_on_flights
WHERE route_id = 4;

-- Q14.	Write a query to calculate the total price of all tickets booked by a customer across
-- different aircraft IDs using rollup function. 


select customer_id , aircraft_id , sum(no_of_tickets * Price_per_ticket) as Ticket_price from ticket_details 
group by 1,2 with rollup;

-- 15.	Write a query to create a view with only business class customers along with the brand of airlines. 

create view business_class_customers as
select t.customer_id , c.first_name, c.last_name, t.class_id ,t.brand  
from customer c 
join ticket_details t on t.customer_id = c.customer_id 
where t.class_id = "Bussiness"
order by t.class_id;

select * from business_class_customers;

 
-- Q16.	Write a query to create a stored
-- procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.

delimiter //
create procedure routes_with_dis_more_then_2000 ()
begin 
select * from routes 
where distance_miles > 2000;
End //
delimiter ;

call routes_with_dis_more_then_2000();


-- Q17. Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. 
-- The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, 
-- and long-distance travel (LDT) for >6500.

delimiter // 

create procedure travelled_distance()
begin
select route_id, 
distance_miles,
case 
when distance_miles >=0 AND distance_miles <= 2000 then "short distance travel (SDT)"
when distance_miles >2000 AND distance_miles <= 6500 then "intermediate distance travel (IDT)"
when distance_miles > 6500 then "long-distance travel (LDT)"
end as x
from routes;
end //

delimiter ;

call travelled_distance();

-- 18.Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for
-- the specific class using a stored function in stored procedure on the ticket_details table. 
-- Condition: 
-- If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No


-- created a function using IF  else clause 
delimiter //

create function extract_complimentary_services(class_id varchar(30)) 
returns varchar(50)
begin	
	declare complimentary_services varchar(30);

	if class_id = "Business" and "Economy Plus" then 
	set complimentary_services = "YES";
    
	else set complimentary_services = "NO";
    end if ;
    
    return complimentary_services;
end //

delimiter ;

-- created a procedure that uses the above fucntion 
delimiter //

create procedure check_comp_service() 
begin
select p_date , customer_id , class_id , extract_complimentary_services(class_id) as c_s
from ticket_details;
end //

delimiter ;

-- calling the procedure 
call check_comp_service() ;
 
 
 
 -- Method 2 
 
 -- created a function using case when and then
 
 DELIMITER //

CREATE FUNCTION GetComplimentaryServices(class_id VARCHAR(30)) 
RETURNS VARCHAR(3)
BEGIN
    RETURN 
        CASE 
            WHEN class_id IN ('Business', 'Economy Plus') THEN 'Yes'
            ELSE 'No'
        END;
END //

DELIMITER ;

-- created a procedure with the above function 
DELIMITER //

CREATE PROCEDURE GetTicketDetailsWithComplimentaryServices()
BEGIN
    SELECT 
        p_date,
        customer_id,
        class_id,
        GetComplimentaryServices(class_id) AS complimentary_services
    FROM ticket_details;
END //

DELIMITER ;


-- calling the procedure :

call GetTicketDetailsWithComplimentaryServices()












