-- Custom Functions, Views, and Procedures

-- --------------------------------------------------------------------------
-- Custom Functions
-- --------------------------------------------------------------------------
-- For calculating the number of seats booked on a given flight
DROP FUNCTION IF EXISTS seats_booked$

CREATE FUNCTION seats_booked (
    i_airline_name VARCHAR(50),
	i_flight_num CHAR(5)
)
RETURNS INT
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE o_num_seats INT;
	SELECT SUM(Num_Seats) FROM book WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Was_Cancelled = 0 INTO o_num_seats;
	SET o_num_seats = IFNULL(o_num_seats, 0);
    RETURN (o_num_seats);
END$


-- For determining amount spent by a flight booking
DROP FUNCTION IF EXISTS book_spent
$
CREATE FUNCTION book_spent (
	i_cost DECIMAL,
    i_flight_num CHAR(5),
    i_airline_name VARCHAR(50)
)
RETURNS DECIMAL (8,3)
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE num_full_price DECIMAL;
    DECLARE num_cancelled DECIMAL;
    DECLARE total_spent DECIMAL;
    SELECT SUM(Num_Seats) FROM book WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Was_Cancelled = 0 INTO num_full_price;
    SELECT SUM(Num_Seats) FROM book WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Was_Cancelled = 1 INTO num_cancelled;
    SET total_spent = i_cost * IFNULL(num_full_price, 0) + i_cost * 0.200 * IFNULL(num_cancelled, 0);
    RETURN (total_spent);
END $


-- For determining average rating of a property
DROP FUNCTION IF EXISTS avg_review
$
CREATE FUNCTION avg_review (
	i_property_name VARCHAR(50)
)
RETURNS DECIMAL (5,4)
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE avg_rating DECIMAL (5,4);
    DECLARE total_rating DECIMAL;
    DECLARE rating_count DECIMAL;
    SELECT SUM(Score) FROM review WHERE Property_Name = i_property_name INTO total_rating;
    SELECT COUNT(*) FROM review WHERE Property_Name = i_property_name INTO rating_count;
    SET avg_rating = total_rating / rating_count;
    RETURN (avg_rating);
END $


-- For determining number of arrival flights
DROP FUNCTION IF EXISTS arrival_count
$
CREATE FUNCTION arrival_count (
	i_airport_id CHAR(3)
)
RETURNS INTEGER
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE arrival_cnt INTEGER;
    SELECT COUNT(*) FROM flight WHERE To_Airport = i_airport_id INTO arrival_cnt;
    RETURN IFNULL(arrival_cnt, 0);
END $


-- For determining number of departure flights
DROP FUNCTION IF EXISTS departure_count
$
CREATE FUNCTION departure_count (
	i_airport_id CHAR(3)
)
RETURNS INTEGER
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE departure_cnt INTEGER;
    SELECT COUNT(*) FROM flight WHERE From_Airport = i_airport_id INTO departure_cnt;
    RETURN IFNULL(departure_cnt, 0);
END $


-- For determining average cost of departure flights
DROP FUNCTION IF EXISTS avg_departure_cost
$
CREATE FUNCTION avg_departure_cost (
	i_airport_id CHAR(3)
)
RETURNS DECIMAL (9,6)
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE total_cost DECIMAL;
    SELECT SUM(Cost) FROM flight WHERE From_Airport = i_airport_id INTO total_cost;
	RETURN (total_cost / departure_count(i_airport_id));
END $



-- For determining number of flights by airline
DROP FUNCTION IF EXISTS num_airline_flights
$
CREATE FUNCTION num_airline_flights (
	i_airline_name VARCHAR(50)
)
RETURNS INTEGER
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE num_flights INTEGER;
    SELECT COUNT(*) FROM flight WHERE Airline_Name = i_airline_name INTO num_flights;
    RETURN num_flights;
END $


-- For determining minimum flight cost by an airline
DROP FUNCTION IF EXISTS min_cost_airline
$
CREATE FUNCTION min_cost_airline (
	i_airline_name VARCHAR(50)
)
RETURNS DECIMAL (5,2)
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE min_cost DECIMAL (5,2);
    SELECT MIN(Cost) FROM flight WHERE Airline_Name = i_airline_name INTO min_cost;
    RETURN min_cost;
END $


-- For determining average customer rating
DROP FUNCTION IF EXISTS customer_rating
$
CREATE FUNCTION customer_rating (
	i_customer_email VARCHAR(50)
)
RETURNS DECIMAL (5,4)
 DETERMINISTIC 
sp_main: BEGIN
    DECLARE total_rating DECIMAL;
    DECLARE rating_count DECIMAL;
    SELECT SUM(Score) FROM owners_rate_customers WHERE Customer = i_customer_email INTO total_rating;
    SELECT COUNT(*) FROM owners_rate_customers WHERE Customer = i_customer_email INTO rating_count;
    RETURN (total_rating / rating_count);
END $


-- For determining if customer is also an owner
DROP FUNCTION IF EXISTS owner_check
$
CREATE FUNCTION owner_check (
	i_customer_email VARCHAR(50)
)
RETURNS BOOLEAN
 DETERMINISTIC 
sp_main: BEGIN
	IF EXISTS(SELECT * FROM owners WHERE Email = i_customer_email)
		THEN RETURN 1;
        LEAVE sp_main;
	END IF;
    RETURN 0;
END $


-- For counting number of reserved seats
DROP FUNCTION IF EXISTS seat_count
$
CREATE FUNCTION seat_count (
	i_customer_email VARCHAR(50)
)
RETURNS INTEGER
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE seats INTEGER;
    SELECT SUM(Num_Seats) FROM book WHERE Customer = i_customer_email INTO seats;
    RETURN IFNULL(seats, 0);
END $


-- For determining average owner rating
DROP FUNCTION IF EXISTS owner_rating
$
CREATE FUNCTION owner_rating (
	i_owner_email VARCHAR(50)
)
RETURNS DECIMAL (5,4)
 DETERMINISTIC 
sp_main: BEGIN
    DECLARE total_rating DECIMAL;
    DECLARE rating_count DECIMAL;
    SELECT SUM(Score) FROM customers_rate_owners WHERE Owner_Email = i_owner_email INTO total_rating;
    SELECT COUNT(*) FROM customers_rate_owners WHERE Owner_Email = i_owner_email INTO rating_count;
    RETURN (total_rating / rating_count);
END $


-- For counting properties owned
DROP FUNCTION IF EXISTS property_count
$
CREATE FUNCTION property_count (
	i_owner_email VARCHAR(50)
)
RETURNS INTEGER
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE num_owned INTEGER;
    SELECT COUNT(*) FROM property WHERE Owner_Email = i_owner_email INTO num_owned;
    RETURN num_owned;
END $


-- For calculating average property rating
DROP FUNCTION IF EXISTS avg_property_rating
$
CREATE FUNCTION avg_property_rating (
	i_owner_email VARCHAR(50)
)
RETURNS DECIMAL (5,4)
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE total_rating DECIMAL;
    DECLARE rating_count DECIMAL;
    SELECT SUM(Score) FROM review WHERE Owner_Email = i_owner_email INTO total_rating;
    SELECT COUNT(*) FROM review WHERE Owner_Email = i_owner_email INTO rating_count;
    RETURN (total_rating / rating_count);
END $


-- For calculating reservation costs
DROP FUNCTION IF EXISTS reservation_cost
$
CREATE FUNCTION reservation_cost (
	i_property_name VARCHAR(50),
    i_owner_email VARCHAR(50),
    i_customer_email VARCHAR(50)
)
RETURNS DECIMAL (10,3)
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE duration INTEGER;
    DECLARE nightly_cost DECIMAL;
	DECLARE total_cost DECIMAL;
    SELECT (End_Date - Start_Date + 1) FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email INTO duration;
    SELECT Cost FROM property WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email INTO nightly_cost;
    SET total_cost = nightly_cost * duration;
    IF EXISTS(SELECT * FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email AND Was_Cancelled = 0)
		THEN RETURN total_cost;
        LEAVE sp_main;
	END IF;
    RETURN (total_cost * 0.2);
END $


-- For checking for overlapping reservations
DROP FUNCTION IF EXISTS overlap_check
$
CREATE FUNCTION overlap_check (
	i_customer_email VARCHAR(50),
    i_start_date DATE,
    i_end_date DATE
)
RETURNS BOOLEAN
 DETERMINISTIC 
sp_main: BEGIN
    IF EXISTS(SELECT * FROM reserve WHERE Customer = i_customer_email AND Was_Cancelled = 0 AND NOT ((Start_Date < i_start_date AND End_Date < i_start_date) OR (Start_Date > i_end_date AND End_Date > i_end_date)))
		THEN RETURN TRUE;
        LEAVE sp_main;
	END IF;
    RETURN FALSE;
END $


-- For checking for capacity conflicts in reservations
DROP FUNCTION IF EXISTS capacity_check
$
CREATE FUNCTION capacity_check (
	i_property_name VARCHAR(50),
    i_owner_email VARCHAR(50),
    i_start_date DATE,
    i_end_date DATE,
    i_num_guests INTEGER
)
RETURNS BOOLEAN
 DETERMINISTIC 
sp_main: BEGIN
	DECLARE max_guests INTEGER;
    DECLARE total_guests INTEGER;
    DECLARE this_date DATE;
    SELECT Capacity FROM property WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email INTO max_guests;
    SET this_date = i_start_date;
	lp_dates: LOOP
		IF (this_date > i_end_date)
			THEN LEAVE lp_dates;
		END IF;
        SELECT SUM(Num_Guests) FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Was_Cancelled = 0 AND this_date BETWEEN Start_Date AND End_Date INTO total_guests;
        SET total_guests = IFNULL(total_guests, 0);
        IF (max_guests < (total_guests + i_num_guests))
			THEN RETURN FALSE;
            LEAVE sp_main;
		END IF;
        SET this_date = DATE_ADD(this_date, INTERVAL 1 DAY);
	END LOOP lp_dates;
    RETURN TRUE;
END $


-- --------------------------------------------------------------------------
-- End Custom Functions Section
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
-- Stored Procedures
-- --------------------------------------------------------------------------
-- ID: 1a
-- Name: register_customer
drop procedure if exists register_customer;
$
create procedure register_customer (
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12),
    in i_cc_number varchar(19),
    in i_cvv char(3),
    in i_exp_date date,
    in i_location varchar(50)
) 
sp_main: begin
    IF i_email NOT IN (SELECT Email FROM accounts) AND i_phone_number NOT IN (SELECT Phone_Number FROM clients) AND i_cc_number NOT IN (SELECT CcNumber FROM customer)
		THEN INSERT INTO accounts (Email, First_Name, Last_Name, Pass) VALUES (i_email, i_first_name, i_last_name, i_password);
		INSERT INTO clients (Email, Phone_Number) VALUES (i_email, i_phone_number);
		INSERT INTO customer (Email, CcNumber, Cvv, Exp_Date, Location) VALUES (i_email, i_cc_number, i_cvv, i_exp_date, i_location);
        select 1;
        LEAVE sp_main;
	END IF;
    IF (i_email, i_first_name, i_last_name, i_password) IN (SELECT Email, First_Name, Last_Name, Pass FROM accounts) AND i_email NOT IN (SELECT Email FROM clients) AND i_phone_number NOT IN (SELECT Phone_Number FROM clients) AND i_cc_number NOT IN (SELECT CcNumber FROM customer)
		THEN INSERT INTO clients (Email, Phone_Number) VALUES (i_email, i_phone_number);
		INSERT INTO customer (Email, CcNumber, Cvv, Exp_Date, Location) VALUES (i_email, i_cc_number, i_cvv, i_exp_date, i_location);
		select 1;
        LEAVE sp_main;
	END IF;
    IF (i_email, i_first_name, i_last_name, i_password) IN (SELECT Email, First_Name, Last_Name, Pass FROM accounts) AND (i_email, i_phone_number) IN (SELECT Email, Phone_Number FROM clients) AND i_cc_number NOT IN (SELECT CcNumber FROM customer)
		THEN INSERT INTO customer (Email, CcNumber, Cvv, Exp_Date, Location) VALUES (i_email, i_cc_number, i_cvv, i_exp_date, i_location);
        select 1;
        LEAVE sp_main;
    END IF;
    if i_email IN (SELECT Email FROM accounts)
		then select concat(i_email, ' is already in use. Please use the login or register with another email address.');
	end if;
    if i_phone_number IN (SELECT Phone_Number FROM clients)
		then select concat(i_phone_number, ' is already in use. Please register with another phone number.');
	end if;
    if i_cc_number IN (SELECT CcNumber FROM customer)
		then select concat(i_cc_number, ' is already in use. Please register with another credit card.');
	end if;
    select concat('Sorry. We cannot register your customer\'s account.');
end $


-- ID: 1b
-- Name: register_owner
drop procedure if exists register_owner;
$
create procedure register_owner (
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12)
) 
sp_main: begin
    IF i_email NOT IN (SELECT Email FROM accounts) AND i_phone_number NOT IN (SELECT Phone_Number FROM clients)
		THEN INSERT INTO accounts (Email, First_Name, Last_Name, Pass) VALUES (i_email, i_first_name, i_last_name, i_password);
		INSERT INTO clients (Email, Phone_Number) VALUES (i_email, i_phone_number);
		INSERT INTO owners (Email) VALUES (i_email);
        select 1;
        LEAVE sp_main;
	END IF;
    IF (i_email, i_first_name, i_last_name, i_password) IN (SELECT Email, First_Name, Last_Name, Pass FROM accounts) AND i_email NOT IN (SELECT Email FROM clients) AND i_phone_number NOT IN (SELECT Phone_Number FROM clients)
		THEN INSERT INTO clients (Email, Phone_Number) VALUES (i_email, i_phone_number);
		INSERT INTO owners (Email) VALUES (i_email);
        select 1;
		LEAVE sp_main;
	END IF;
    IF (i_email, i_first_name, i_last_name, i_password) IN (SELECT Email, First_Name, Last_Name, Pass FROM accounts) AND (i_email, i_phone_number) IN (SELECT Email, Phone_Number FROM clients) AND i_email NOT IN (SELECT Email FROM owners)
		THEN INSERT INTO owners (Email) VALUES (i_email);
        select 1;
        LEAVE sp_main;
    END IF;
    if i_email IN (SELECT Email FROM accounts)
		then select concat(i_email, ' is already in use. Please use the login or register with another email address.');
	end if;
    if i_phone_number IN (SELECT Phone_Number FROM clients)
		then select concat(i_phone_number, ' is already in use. Please register with another phone number.');
	end if;
    select concat('Sorry. We cannot register your owner\'s account.');
end $



-- ID: 1c
-- Name: remove_owner
drop procedure if exists remove_owner;
$
create procedure remove_owner ( 
    in i_owner_email varchar(50)
)
sp_main: begin
    IF i_owner_email NOT IN (SELECT Email FROM owners)
		THEN select concat(i_owner_email, ' doesn\'t exist. This can\'t be right.'); LEAVE sp_main;
	END IF;
	IF i_owner_email IN (SELECT Owner_Email FROM property)
		THEN select concat('You have properties listed. Please delete properties first before deleting the account.'); LEAVE sp_main;
	END IF;
    IF i_owner_email IN (SELECT Email FROM customer)
		THEN DELETE FROM owners WHERE Email = i_owner_email;
        select 1;
        LEAVE sp_main;
	END IF;
	DELETE FROM owners WHERE Email = i_owner_email;
	DELETE FROM clients WHERE Email = i_owner_email;
	DELETE FROM accounts WHERE Email = i_owner_email;
    select 1;
end $



-- ID: 2a
-- Name: schedule_flight
drop procedure if exists schedule_flight;
$
create procedure schedule_flight (
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_from_airport char(3),
    in i_to_airport char(3),
    in i_departure_time time,
    in i_arrival_time time,
    in i_flight_date date,
    in i_cost decimal(6, 2),
    in i_capacity int,
    in i_current_date date
)
sp_main: begin
    IF i_from_airport = i_to_airport
		THEN select concat('The flight cannot have the same to_airport and from_airport '); LEAVE sp_main;
	END IF;
    IF i_flight_date <= i_current_date
		THEN select concat('The flight date must be in the future '); LEAVE sp_main;
	END IF;
    IF (i_airline_name, i_flight_num) IN (SELECT Airline_Name, Flight_Num FROM flight)
		THEN select concat(i_airline_name, ' ', i_flight_num, ' is alreay exists.'); LEAVE sp_main;
	END IF;
    IF i_airline_name NOT IN (SELECT Airline_Name FROM airline) OR i_from_airport NOT IN (SELECT Airport_Id FROM airport) OR i_to_airport NOT IN (SELECT Airport_Id FROM airport)
		THEN select concat(i_from_airport, ' or ', i_to_airport, ' airport doesn\'t exist.'); LEAVE sp_main;
	END IF;
    INSERT INTO flight (Flight_Num, Airline_Name, From_Airport, To_Airport, Departure_Time, Arrival_Time, Flight_Date, Cost, Capacity)
		VALUES (i_flight_num, i_airline_name, i_from_airport, i_to_airport, i_departure_time, i_arrival_time, i_flight_date, i_cost, i_capacity);
        select 1;
end $



-- ID: 2b
-- Name: remove_flight
drop procedure if exists remove_flight;
$
create procedure remove_flight ( 
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
) 
sp_main: begin
    IF EXISTS(SELECT * FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Flight_Date > i_current_date)
		THEN DELETE FROM book WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num;
        DELETE FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num;
	END IF;
end $



-- ID: 3a
-- Name: book_flight
drop procedure if exists book_flight;
$
create procedure book_flight (
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_num_seats int,
    in i_current_date date
)
sp_main: begin
    IF NOT EXISTS(SELECT * FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Flight_Date > i_current_date)
		THEN LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Flight_Num = F.Flight_Num AND B.Airline_Name = F.Airline_Name WHERE B.Customer = i_customer_email AND NOT (B.Airline_Name = i_airline_name AND B.Flight_Num = i_flight_num) AND B.Was_Cancelled = 0 AND F.Flight_Date IN (SELECT Flight_Date FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num))
		THEN LEAVE sp_main;
	END IF;
    IF NOT EXISTS(SELECT * FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND i_num_seats <= (capacity - seats_booked(Airline_Name, Flight_Num)))
		THEN LEAVE sp_main;
	END IF;
	IF EXISTS(SELECT * FROM book WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Customer = i_customer_email AND Was_Cancelled = 1)
		THEN LEAVE sp_main;
	END IF;
	IF EXISTS(SELECT * FROM book WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Customer = i_customer_email AND Was_Cancelled = 0)
		THEN UPDATE book SET Num_Seats = Num_Seats + i_num_seats WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Customer = i_customer_email;
        LEAVE sp_main;
	END IF;
    INSERT INTO book (Customer, Flight_Num, Airline_Name, Num_Seats, Was_Cancelled) VALUES (i_customer_email, i_flight_num, i_airline_Name, i_num_seats, 0);
end $


-- ID: 3b
-- Name: cancel_flight_booking
drop procedure if exists cancel_flight_booking;
$
create procedure cancel_flight_booking ( 
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
)
sp_main: begin
    IF NOT EXISTS(SELECT * FROM book WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Customer = i_customer_email AND Was_Cancelled = 0)
		THEN LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM flight WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Flight_Date > i_current_date)
		THEN UPDATE book SET Was_Cancelled = 1 WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Customer = i_customer_email;
	END IF;
end $



-- ID: 3c
-- Name: view_flight
create or replace view view_flight (
    flight_id,
    flight_date,
    airline,
    destination,
    seat_cost,
    num_empty_seats,
    total_spent
) as 
SELECT Flight_Num, Flight_Date, Airline_Name, To_Airport, Cost, Capacity - seats_booked(Airline_Name, Flight_Num), book_spent(Cost, Flight_Num, Airline_Name) FROM flight
$

-- ID: 4a
-- Name: add_property
drop procedure if exists add_property;
$
create procedure add_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_description varchar(500),
    in i_capacity int,
    in i_cost decimal(6, 2),
    in i_street varchar(50),
    in i_city varchar(50),
    in i_state char(2),
    in i_zip char(5),
    in i_nearest_airport_id char(3),
    in i_dist_to_airport int
) 
sp_main: begin
    IF EXISTS(SELECT * FROM property WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email)
		THEN select concat(i_property_name, ' ', i_owner_email, ' is alreay exists.'); LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM property WHERE Street = i_street AND City = i_city AND State = i_state AND Zip = i_zip)
		THEN select concat( i_street, ', ', i_city, ', ',  i_state, ' ', i_zip, ' has existed. Please add your own property'); LEAVE sp_main;
	END IF;
    INSERT INTO property (Property_Name, Owner_Email, Descr, Capacity, Cost, Street, City, State, Zip) VALUES (i_property_name, i_owner_email, i_description, i_capacity, i_cost, i_street, i_city, i_state, i_zip);
    IF NOT EXISTS(SELECT * FROM airport WHERE Airport_Id = i_nearest_airport_id)
		THEN select concat('Airport doesn\'t exist. Your property has been added without the nearest airport.'); LEAVE sp_main;
	END IF;
    IF i_dist_to_airport >= 0
		THEN INSERT INTO is_close_to (Property_Name, Owner_Email, Airport, Distance) VALUES (i_property_name, i_owner_email, i_nearest_airport_id, i_dist_to_airport);
	END IF;   
    IF i_dist_to_airport < 0
		then select concat('Distance to airport must be greater than zero.');
	end if;
    select 1;
end $


-- ID: 4b
-- Name: remove_property
drop procedure if exists remove_property;
$
create procedure remove_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_current_date date
)
sp_main: begin
    IF EXISTS(SELECT * FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND (i_current_date BETWEEN Start_Date AND END_DATE) AND Was_Cancelled = 0)
		THEN LEAVE sp_main;
	END IF;
    DELETE FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email;
    DELETE FROM property WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email;
end $



-- ID: 5a
-- Name: reserve_property
drop procedure if exists reserve_property;
$
create procedure reserve_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_start_date date,
    in i_end_date date,
    in i_num_guests int,
    in i_current_date date
)
sp_main: begin
    IF EXISTS(SELECT * FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email)
		THEN LEAVE sp_main;
	END IF;
    IF (i_current_date >= i_start_date)
		THEN LEAVE sp_main;
	END IF;
    IF overlap_check(i_customer_email, i_start_date, i_end_date)
		THEN LEAVE sp_main;
	END IF;
    IF NOT capacity_check(i_property_name, i_owner_email, i_start_date, i_end_date, i_num_guests)
		THEN LEAVE sp_main;
	END IF;
    INSERT INTO reserve (Property_Name, Owner_Email, Customer, Start_Date, End_Date, Num_Guests, Was_Cancelled)
		VALUES (i_property_name, i_owner_email, i_customer_email, i_start_date, i_end_date, i_num_guests, 0);
end $



-- ID: 5b
-- Name: cancel_property_reservation
drop procedure if exists cancel_property_reservation;
$
create procedure cancel_property_reservation (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_current_date date
)
sp_main: begin
    IF NOT EXISTS(SELECT * FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email AND i_current_date < Start_Date AND Was_Cancelled = 0)
		THEN LEAVE sp_main;
	END IF;
    UPDATE reserve SET Was_Cancelled = 1 WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email;
end $



-- ID: 5c
-- Name: customer_review_property
drop procedure if exists customer_review_property;
$
create procedure customer_review_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_content varchar(500),
    in i_score int,
    in i_current_date date
)
sp_main: begin
    IF NOT (1 <= i_score AND i_score <= 5)
		THEN LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM review WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email)
		THEN LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND Customer = i_customer_email AND Was_Cancelled = 0 AND i_current_date >= Start_Date)
		THEN INSERT INTO review (Property_Name, Owner_Email, Customer, Content, Score) VALUES (i_property_name, i_owner_email, i_customer_email, i_content, i_score);
	END IF;
end $



-- ID: 5d
-- Name: view_properties
create or replace view view_properties (
    property_name, 
    owner_email,
    average_rating_score, 
    description, 
    address, 
    capacity, 
    cost_per_night
) as 
SELECT Property_Name, Owner_email, avg_review(property_name), Descr, CONCAT(Street, ', ', City, ', ', State, ', ', Zip), Capacity, Cost FROM property
$

-- ID: 5e
-- Name: view_individual_property_reservations
drop procedure if exists view_individual_property_reservations;
$
create procedure view_individual_property_reservations (
    in i_property_name varchar(50),
    in i_owner_email varchar(50)
)
sp_main: begin
    drop table if exists view_individual_property_reservations;
    create table view_individual_property_reservations (
        property_name varchar(50),
        start_date date,
        end_date date,
        customer_email varchar(50),
        customer_phone_num char(12),
        total_booking_cost decimal(6,2),
        rating_score int,
        review varchar(500)
    ) as 
    SELECT R.Property_Name AS property_name, Start_Date AS start_date, End_Date AS end_date, R.Customer AS customer_email, (SELECT Phone_Number FROM clients WHERE Email = R.Customer) AS customer_phone_num, reservation_cost(R.Property_Name, R.Owner_Email, R.Customer) AS total_booking_cost, Score AS rating_score, Content AS review FROM reserve AS R LEFT OUTER JOIN review AS V ON R.Property_Name = V.Property_Name AND R.Owner_Email = V.Owner_Email AND R.Customer = V.Customer
		WHERE R.Property_Name = i_property_name AND R.Owner_Email = i_owner_email;
end $



-- ID: 6a
-- Name: customer_rates_owner
drop procedure if exists customer_rates_owner;
$
create procedure customer_rates_owner (
    in i_customer_email varchar(50),
    in i_owner_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main: begin
    IF NOT (1 <= i_score AND i_score <= 5)
		THEN LEAVE sp_main;
	END IF;
	IF EXISTS(SELECT * FROM customers_rate_owners WHERE Customer = i_customer_email AND Owner_Email = i_owner_email)
		THEN LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM reserve WHERE Owner_Email = i_owner_email AND Customer = i_customer_email AND Was_Cancelled = 0 AND i_current_date >= Start_Date)
		THEN INSERT INTO customers_rate_owners (Customer, Owner_Email, Score) VALUES (i_customer_email, i_owner_email, i_score);
	END IF;
end $



-- ID: 6b
-- Name: owner_rates_customer
drop procedure if exists owner_rates_customer;
$
create procedure owner_rates_customer (
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main: begin
    IF NOT (1 <= i_score AND i_score <= 5)
		THEN LEAVE sp_main;
	END IF;
	IF EXISTS(SELECT * FROM owners_rate_customers WHERE Owner_Email = i_owner_email AND Customer = i_customer_email)
		THEN LEAVE sp_main;
	END IF;
    IF EXISTS(SELECT * FROM reserve WHERE Owner_Email = i_owner_email AND Customer = i_customer_email AND Was_Cancelled = 0 AND i_current_date >= Start_Date)
		THEN INSERT INTO owners_rate_customers (Owner_Email, Customer, Score) VALUES (i_owner_email, i_customer_email, i_score);
	END IF;
end $



-- ID: 7a
-- Name: view_airports
create or replace view view_airports (
    airport_id, 
    airport_name, 
    time_zone, 
    total_arriving_flights, 
    total_departing_flights, 
    avg_departing_flight_cost
) as 
SELECT Airport_Id, Airport_Name, Time_Zone, arrival_count(Airport_Id), departure_count(Airport_Id), avg_departure_cost(Airport_Id) FROM airport
$

-- Name: view_airports_condensed
create or replace view view_airports_condensed (
    airport_id, 
    airport_name, 
    time_zone, 
    address
) as 
SELECT Airport_Id, Airport_Name, Time_Zone, CONCAT(Street, ', ', City, ', ', State, ', ', Zip) FROM airport$

-- ID: 7b
-- Name: view_airlines
create or replace view view_airlines (
    airline_name, 
    rating, 
    total_flights, 
    min_flight_cost
) as 
SELECT Airline_Name, Rating, num_airline_flights(Airline_Name), min_cost_airline(Airline_Name) FROM airline$

-- ID: 8a
-- Name: view_customers
create or replace view view_customers (
    customer_name, 
    avg_rating, 
    location, 
    is_owner, 
    total_seats_purchased
) as 
SELECT CONCAT(First_Name, ' ', Last_Name), customer_rating(C.Email), Location, owner_check(A.Email), seat_count(C.Email) FROM customer AS C INNER JOIN accounts AS A ON C.Email = A.Email ORDER BY First_Name ASC
$

-- ID: 8b
-- Name: view_owners
create or replace view view_owners (
    owner_name, 
    avg_rating, 
    num_properties_owned, 
    avg_property_rating
) as 
SELECT CONCAT(First_Name, ' ', Last_Name), owner_rating(O.Email), property_count(O.Email), avg_property_rating(O.Email) FROM owners AS O INNER JOIN accounts AS A ON O.Email = A.Email ORDER BY First_Name ASC
$

-- ID: 9a
-- Name: process_date
drop procedure if exists process_date;
$
create procedure process_date (
    in i_current_date date
)
sp_main: begin
    SET SQL_SAFE_UPDATES=0;
    UPDATE customer AS C
    SET Location = IFNULL((SELECT A.State FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num LEFT OUTER JOIN airport AS A ON F.To_Airport = A.Airport_Id WHERE F.Flight_Date = i_current_date AND B.Customer = C.Email AND B.Was_Cancelled = 0), Location);
end $

