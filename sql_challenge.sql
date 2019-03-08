-- 1a. Display the first and last names of all actors from the table actor.
select 
	first_name ,
    last_name
from sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select 
	CONCAT(first_name,' ',last_name) AS `Actor Name`

from sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select 
	actor_id ,
    first_name ,
    last_name
    
from sakila.actor
where first_name = 'JOE';


-- 2b. Find all actors whose last name contain the letters GEN:
select 
	actor_id ,
    first_name ,
    last_name
    
from sakila.actor
where last_name LIKE '%GEN%';
 
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select 
	actor_id ,
    first_name ,
    last_name
    
from sakila.actor
where last_name LIKE '%LI%'
order by 
	last_name ,
	first_name;
 
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select 
	country_id ,
    country
from sakila.country
where country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE sakila.actor
ADD COLUMN description BLOB NULL AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE sakila.actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select 
    last_name ,
    count(*) as `actor_count`
from sakila.actor
group by 
	last_name ;
    
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select 
    last_name ,
    count(*) as `actor_count`
from sakila.actor
group by 
	last_name
having count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update sakila.actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

select 
	*
from sakila.actor 
where last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update sakila.actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- 
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select 
	s.first_name ,
    s.last_name ,
    a.address ,
    c.city 
    
from sakila.staff as s
	inner join sakila.address as a 
		on a.address_id = s.address_id
	inner join sakila.city as c
		on c.city_id = a.city_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select 
	CONCAT(s.first_name, ' ', s.last_name) AS `staff_name` ,
    sum(p.amount) as `total_amount`    
from sakila.staff as s
	inner join sakila.payment as p
		on p.staff_id = s.staff_id
where p.payment_date between '2005-08-01' and '2005-08-31'
group by CONCAT(s.first_name, ' ', s.last_name) ; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select 
	f.title ,
    count(fa.actor_id) as `actor_count`
from sakila.film as f
	inner join  sakila.film_actor as fa 
		on fa.film_id =  f.film_id
group by f.title;
	
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select 
	f.title ,
	count(i.inventory_id) as `inventory_count`
from sakila.inventory as i
	inner join sakila.film as f 
		on f.film_id = i.film_id
where f.title = 'Hunchback Impossible'
group by f.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select 
	c.first_name ,
    c.last_name ,
	sum(p.amount) as `total_amount`
from sakila.customer as c
	inner join sakila.payment as p 
		on p.customer_id = c.customer_id
group by 	
	c.first_name ,
	c.last_name 
order by last_name;
 
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select
	f.title
from sakila.film as f
WHERE f.film_id IN (select f2.film_id from sakila.film as f2 where left(f2.title, 1) IN ('K', 'Q'));
-- 
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select
	a.*
from sakila.actor as a
where a.actor_id IN (select actor_id from sakila.film_actor as fa inner join sakila.film as f on f.film_id = fa.film_id where f.title = 'ALONE TRIP');

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select 
	c.first_name ,
    c.last_name ,
    c.email
from sakila.customer as c
	inner join sakila.address as a 
		on a.address_id = c.address_id
	inner join sakila.city as cy
		on cy.city_id = a.city_id
    inner join sakila.country as cnt
		on cnt.country_id = cy.country_id
where cnt.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select 
	f.* ,
    c.name as `category`
from sakila.film as f 
	inner join sakila.film_category as fc 
		on fc.film_id = f.film_id
	inner join sakila.category as c
		on c.category_id = fc.category_id
	where c.category_id IN (5, 8);
 
-- 7e. Display the most frequently rented movies in descending order.
select 
	f.title ,
	count(r.rental_id) as `rental count` 
from sakila.rental as r 
	inner join sakila.inventory as i 
		on i.inventory_id = r.inventory_id 
	inner join sakila.film as f 
		on f.film_id = i.film_id
group by f.title
order by count(r.rental_id) desc;
 
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select 
	s.store_id ,
    sum(p.amount) AS `revenue`
from sakila.payment as p
	inner join sakila.staff	as s 
		on s.staff_id = p.staff_id 
	inner join sakila.store as st 
		on st.store_id = s.store_id
group by 
	s.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
select
	s.store_id ,
    c.city ,
    cty.country
from sakila.store as s 
	inner join sakila.address as a 
		on a.address_id = s.address_id
	inner join sakila.city as c
		on c.city_id = a.city_id
	inner join sakila.country as cty
		on cty.country_id = c.country_id;
-- 
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select 
  c.name as `film_category` ,
  sum(p.amount) as `total_revenue`
from sakila.payment as p
	inner join sakila.rental as r
		on r.rental_id = p.rental_id
	inner join sakila.inventory as i
		on i.inventory_id = r.inventory_id
	inner join sakila.film_category as fc
		on fc.film_id = i.film_id
	inner join sakila.category as c
		on c.category_id = fc.category_id
group by    
	c.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `vw_top_5_genre_by_rev` AS
select 
  c.name as `film_category` ,
  sum(p.amount) as `total_revenue`
from sakila.payment as p
	inner join sakila.rental as r
		on r.rental_id = p.rental_id
	inner join sakila.inventory as i
		on i.inventory_id = r.inventory_id
	inner join sakila.film_category as fc
		on fc.film_id = i.film_id
	inner join sakila.category as c
		on c.category_id = fc.category_id
group by    
	c.name
order by sum(p.amount) desc
limit 5;
 
-- 8b. How would you display the view that you created in 8a?
select 
	*
from sakila.vw_top_5_genre_by_rev;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `sakila`.`vw_top_5_genre_by_rev`;
