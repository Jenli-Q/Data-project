# Check the number of rows imported: 25480
SELECT COUNT(*)
FROM listings;

# Get table info
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'listings';

# Check Duplicates: 25480 - No duplicates found
SELECT COUNT(DISTINCT id)
FROM listings;

# Set id column as primary key 
ALTER TABLE listings 
ADD PRIMARY KEY(id);

# Get the number of inactive listings - 3517
SELECT COUNT(id) AS inactive_listings
FROM listings 
WHERE availability_365 = 0 AND number_of_reviews = 0;

# Get the number of active listings - 21963
SELECT COUNT(id) AS active_listings
FROM listings 
WHERE NOT (availability_365 = 0 AND number_of_reviews = 0);

# Create a new table with active listings only
CREATE TABLE active_listings AS
SELECT *
FROM listings
WHERE NOT (availability_365 = 0 AND number_of_reviews = 0);

# Check active listings - 21963
SELECT COUNT(id)
FROM active_listings;

# Get the number of hosts - 13813
SELECT COUNT(DISTINCT host_id) AS total_host
FROM active_listings;

# Get the number of listings per host
SELECT DISTINCT host_id, host_name, calculated_host_listings_count AS num_listings
FROM active_listings
ORDER BY num_listings DESC;

# Get the number of hosts who have more than 1 property - 2352, 2352/13813 = 17.03%
SELECT SUM(IF(num_listings > 1,1,0)) AS num_more_than_1, 
	ROUND(SUM(IF(num_listings > 1,1,0))/COUNT(*)*100, 2) AS percentage
FROM (
	SELECT DISTINCT host_id, host_name, calculated_host_listings_count AS num_listings
	FROM active_listings
	) AS distinct_host;

# Get the number of areas with listings - 38
SELECT COUNT(DISTINCT neighbourhood) AS num_area
FROM active_listings;

# Get the average price - 343.76
SELECT ROUND(AVG(price),2) AS average_price
FROM active_listings;

# Get the number of listings per area - Sydney 5043
SELECT neighbourhood, COUNT(id) AS num_listing, ROUND(avg(price),2) AS average_price
FROM active_listings
GROUP BY neighbourhood
ORDER BY num_listing DESC;

# Get the number of listings of each room type - Most common/Most expensive: Entire
SELECT room_type, COUNT(id) AS num_listings, 
ROUND(
	COUNT(id) / (SELECT COUNT(id)
				FROM active_listings) * 100, 2) AS percentage,
ROUND(avg(price), 2) AS average_price
FROM active_listings
GROUP BY room_type
ORDER BY num_listings DESC;

# Get the price by area and room type - Pittwater,Entire home/apt, 1008
SELECT neighbourhood AS suburb, room_type, ROUND(AVG(price),0) AS average_price
FROM active_listings
GROUP BY suburb, room_type
ORDER BY average_price DESC;

# Get the average price of Entire home/apt by areas - Pittwater 1008
SELECT neighbourhood, room_type,
ROUND(avg(price), 0) AS average_price
FROM active_listings
WHERE room_type = "Entire Home/apt"
GROUP BY neighbourhood
ORDER BY average_price DESC;

# Get the average price of Hotel room by areas - Sutherland Shire: 489
SELECT neighbourhood, room_type,
ROUND(avg(price), 0) AS average_price
FROM active_listings
WHERE room_type = "Hotel room"
GROUP BY neighbourhood
ORDER BY average_price DESC;

# Get the average price of Private room by areas - Pittwater 375
SELECT neighbourhood, room_type,
ROUND(avg(price), 0) AS average_price
FROM active_listings
WHERE room_type = "Private room"
GROUP BY neighbourhood
ORDER BY average_price DESC;

# Get the average price of Shared room by areas - Strathfield 586
SELECT neighbourhood, room_type,
ROUND(avg(price), 0) AS average_price
FROM active_listings
WHERE room_type = "Shared room"
GROUP BY neighbourhood
ORDER BY average_price DESC;

# Get night range and average price - More than 1 month 39%
SELECT night_range, COUNT(id) AS num_listings, 
	ROUND(
	COUNT(id) / (SELECT COUNT(id)
				FROM active_listings) * 100, 2) AS percentage,
ROUND(AVG(price), 0) AS average_price
FROM (
	SELECT id, minimum_nights, 
	CASE WHEN minimum_nights BETWEEN 0 AND 7 THEN "1 week"
		WHEN minimum_nights BETWEEN 8 AND 14 THEN "2 weeks"
		WHEN minimum_nights BETWEEN 15 AND 21 THEN "3 weeks"
		WHEN minimum_nights BETWEEN 22 AND 28 THEN "4 weeks"
		ELSE "more than 1 month" END AS night_range,
	price
	FROM active_listings
	) AS sub_active_listings
GROUP BY night_range
ORDER BY night_range;

