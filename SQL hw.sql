USE sakila;

-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.
SELECT * FROM actor 
WHERE first_name IS NOT NULL AND last_name IS NOT NULL;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT *, CONCAT(UPPER(first_name) ,' ', UPPER(last_name)) as `Actor Name` FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id as `ID number`, first_name AS `first name`, last_name AS `last name` FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor ADD middle_name VARCHAR(45) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor MODIFY middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS `Last Name #` FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS `Last Name #` FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'WILLIAMS' AND first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 
	CASE 
		WHEN first_name = "HARPO"
			THEN "GROUCHO"
		ELSE "MUCHO GROUCHO"
	END
WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;
SHOW CREATE TABLE sakila.address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.staff_id,first_name,last_name, sum(amount) AS "Total Payment" FROM payment
JOIN staff ON staff.staff_id = payment.staff_id
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, count(actor_id) AS "Number of Actor" FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id) AS "Number of Inventory" 
FROM film f
JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.film_id
HAVING title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.customer_id, c.first_name, c.last_name, sum(p.amount) AS "Total Payment" 
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE title LIKE "Q%" OR title LIKE "K%" 
AND language_id = 
(SELECT language_id FROM `language` 
WHERE name = "English");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.first_name, a.last_name FROM actor a
WHERE a.actor_id IN 
	(SELECT fa.actor_id FROM film_actor fa
	WHERE fa.film_id IN
		(SELECT f.film_id FROM film f
		WHERE f.title = "Alone Trip")
	);


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email FROM customer c
JOIN address a ON c.address_id = a.address_id
	JOIN city cy ON cy.city_id = a.city_id
		JOIN country ct ON ct.country_id = cy.country_id
			WHERE ct.country = 'Canada';
  
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
	JOIN category cg ON cg.category_id = fc.category_id
		WHERE cg.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(r.rental_id) AS "Number of Rental" FROM film f
JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
		GROUP BY f.title
		ORDER BY count(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, sum(p.amount) AS "Store Revenue" FROM payment p
	LEFT JOIN customer c ON p.customer_id = c.customer_id
		RIGHT JOIN store s ON s.store_id = c.store_id
			GROUP BY s.store_id
			ORDER BY sum(p.amount);

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, ct.country FROM store s
	JOIN address a ON s.address_id = a.address_id
		JOIN city c ON c.city_id = a.city_id
			JOIN country ct ON c.country_id = ct.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ca.`name`, sum(p.amount) AS "Revenue" FROM category ca
	JOIN film_category fc ON fc.category_id = ca.category_id
		JOIN inventory i ON i.film_id = fc.film_id
			JOIN rental r ON r.inventory_id = i.inventory_id
				JOIN payment p ON r.rental_id = p.rental_id
                GROUP BY ca.`name`
                ORDER BY sum(p.amount) DESC
                LIMIT 5;
           

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres AS
SELECT ca.`name`, sum(p.amount) AS "Revenue" FROM category ca
	JOIN film_category fc ON fc.category_id = ca.category_id
		JOIN inventory i ON i.film_id = fc.film_id
			JOIN rental r ON r.inventory_id = i.inventory_id
				JOIN payment p ON r.rental_id = p.rental_id
                GROUP BY ca.`name`
                ORDER BY sum(p.amount) DESC
                LIMIT 5;
                                
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_Five_Genres;
 
 
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five_Genres;
 
                
                
