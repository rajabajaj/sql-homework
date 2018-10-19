#1a. Display the first and last names of all actors from the table `actor`.


Use sakila;

Select first_name, last_name 
from actor;


#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

Select 
concat(first_name, ' ' , last_name) As Actor_Name 
from actor;



#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

Select actor_id,first_name,last_name
From actor 
Where first_name = "joe";


# 2b. Find all actors whose last name contain the letters `GEN`:

Select * From actor
Where last_name like '%GEN%';


# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:


Select * from actor
Where last_name like '%LI%'
Order by last_name,first_name;


#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

Select country_id,country 
From country
Where country IN ('Afghanistan', 'Bangladesh', 'China');



#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

Alter table actor
Add column description blob;


#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

Alter table actor
Drop column description;



#4a. List the last names of actors, as well as how many actors have that last name.


Select count(actor_id), last_name
From actor
Group by last_name;


# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

Select count(actor_id),last_name
From actor
Group by last_name
Having count(actor_id) >=2
Order by count(actor_id) desc;



#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record


Update  actor
Set first_name ='HARPO' 
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';


#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

Update  actor
Set first_name ='GROUCHO'
Where first_name = 'HARPO';


# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

CREATE TABLE IF NOT EXISTS
 `address` (
 `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `address` varchar(50) NOT NULL,
 `address2` varchar(50) DEFAULT NULL,
 `district` varchar(20) NOT NULL,
 `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) DEFAULT NULL,
 `phone` varchar(20) NOT NULL,
 `location` geometry NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`address_id`),
 KEY `idx_fk_city_id` (`city_id`),
 SPATIAL KEY `idx_location` (`location`),
 CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`))
                                           




# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

Select first_name,last_name,address
From staff left join address 
On staff.address_id = address.address_id;



#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

Select staff.first_name, staff.last_name, staff.staff_id, Sum(payment.amount) As total_amount_rung
From staff right join payment 
On staff.staff_id = payment.staff_id
Where payment.payment_date like'2005-08%'
Group by payment.staff_id;




#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.


Select film.title, Count(film_actor.actor_id) As  Number_of_Actors
From film 
Join film_actor
On film.film_id = film_actor.film_id
Group by film.title;


#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?


Select film.title,Count(inventory.inventory_id)
From film 
inner join inventory
On film.film_id = inventory.film_id
Where title = 'Hunchback Impossible';

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
#Total amount paid](Images/total_payment.png)

Select  customer.first_name,customer.last_name,Sum(payment.amount) As total_paid
From customer right join payment 
On customer.customer_id = payment.customer_id
Group by customer.first_name,customer.last_name
Order by customer.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

Select title From film
Where language_id  IN(
                                     Select language_id 
								     From language 
									 Where name = 'English') 
								     and (title like 'K%') or (title like 'Q%');








#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

 
 Select first_name, last_name 
 From actor
 Where actor_id in (Select actor_id 
                                 From film_actor
                                 Where film_id in (
                                                       Select film_id From film
                                                       Where title = 'Alone Trip'));



#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

Select last_name,first_name, email 
From customer 
inner join address
On customer.address_id = address.address_id
inner join  city 
On address.city_id = city.city_id
inner join country
On city.country_id = country.country_id
Where country = 'Canada';




#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.


# Join Query

Select title From film
Join film_category
On film.film_id = film_category.film_id
Join category
On film_category.category_id = category.category_id
Where category.name ='Family'; 



#Sub-Query
Select title 
From film
Where film_id IN
                        (Select film_id 
                         From film_category
					     Where category_id IN
                                                         (Select category_id 
														   From category
													                           Where name ='Family'));





#7e. Display the most frequently rented movies in descending order.


Select title , Count(rental.inventory_id) As times_rented
From film 
Join inventory
On film.film_id = inventory.film_id 
Join rental
On inventory.inventory_id= rental.inventory_id
Group by title
Order by times_rented desc, title asc;



#7f. Write a query to display how much business, in dollars, each store brought in.



Select store.store_id, Sum(amount) As sum_amount_perstore
From store 
Join staff
On store.store_id = staff.store_id
Join payment
On staff.staff_id = payment.staff_id
Group by store.store_id;



#7g. Write a query to display for each store its store ID, city, and country.


Select store_id,city,country
From store  s 
Join address a
On s.address_id = a.address_id
Join city c
On a.city_id = c.city_id
Join country cn
On c.country_id = cn.country_id;



#7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

Select name,sum(payment.amount) As revenue_gross
From category
Join film_category
On category.category_id = film_category.category_id
Join inventory
On inventory.film_id = film_category.film_id 
Join rental
On inventory.inventory_id =rental.inventory_id
Join payment
On payment.rental_id = rental.rental_id
Group by name
Order by revenue_gross desc 
Limit 5;




# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

Drop view if exists top_revenue_genres;
Create view top_revenue_genres As


Select name,sum(payment.amount) As revenue_gross
From category
Join film_category
On category.category_id = film_category.category_id
Join inventory
On inventory.film_id = film_category.film_id 
Join rental
On inventory.inventory_id =rental.inventory_id
Join payment
On payment.rental_id = rental.rental_id
Group by name
Order by revenue_gross desc 
Limit 5;



# 8b. How would you display the view that you created in 8a?


Select * From top_revenue_genres;




#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.


Drop  view top_revenue_genres;
