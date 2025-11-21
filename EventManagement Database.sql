-- SETUP: DATABASE AND TABLES
DROP DATABASE IF EXISTS SmartEventDB;
CREATE DATABASE SmartEventDB;
USE SmartEventDB;

-- 2. Venues Table
CREATE TABLE Venues (
    venue_id INT PRIMARY KEY AUTO_INCREMENT,
    venue_name VARCHAR(100),
    location VARCHAR(100),
    capacity INT
);

-- 3. Organizers Table
CREATE TABLE Organizers (
    organizer_id INT PRIMARY KEY AUTO_INCREMENT,
    organizer_name VARCHAR(100),
    contact_email VARCHAR(100),
    phone_number VARCHAR(20)
);

-- 1. Events Table
CREATE TABLE Events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    event_name VARCHAR(150),
    event_date DATETIME,
    venue_id INT,
    organizer_id INT,
    ticket_price DECIMAL(10, 2),
    total_seats INT,
    available_seats INT,
    FOREIGN KEY (venue_id) REFERENCES Venues(venue_id),
    FOREIGN KEY (organizer_id) REFERENCES Organizers(organizer_id)
);

-- 4. Attendees Table
CREATE TABLE Attendees (
    attendee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(20)
);

-- 5. Tickets Table
CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    attendee_id INT,
    booking_date DATE,
    status ENUM('Confirmed', 'Cancelled', 'Pending'),
    FOREIGN KEY (event_id) REFERENCES Events(event_id),
    FOREIGN KEY (attendee_id) REFERENCES Attendees(attendee_id),
    -- Constraint mentioned in Point 6: Ensure attendees cannot book same event multiple times
    UNIQUE (event_id, attendee_id)
);

-- 6. Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT,
    amount_paid DECIMAL(10, 2),
    payment_status ENUM('Success', 'Failed', 'Pending'),
    payment_date DATETIME,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

-- SEED DATA (Populating tables for Testing)
-- Insert Venues
INSERT INTO Venues (venue_name, location, capacity) VALUES 
('Grand Hall', 'New York', 500),
('Tech Arena', 'San Francisco', 200),
('City Park', 'Chicago', 1000),
('Open Air Theater', 'Austin', 300);

-- Insert Organizers
INSERT INTO Organizers (organizer_name, contact_email, phone_number) VALUES 
('Global Events Co', 'contact@globalevents.com', '123-456-7890'),
('Tech World', 'info@techworld.org', '987-654-3210'),
('Music Fest Inc', 'hello@musicfest.com', '555-666-7777');

-- Insert Events (Including dates in December for Point 3)
INSERT INTO Events (event_name, event_date, venue_id, organizer_id, ticket_price, total_seats, available_seats) VALUES 
('Tech Summit 2025', '2025-12-15 09:00:00', 2, 2, 200.00, 200, 150),
('Winter Jazz Fest', '2025-12-20 18:00:00', 1, 3, 50.00, 500, 50), 
('Startup Bootcamp', '2025-11-25 10:00:00', 2, 2, 100.00, 200, 100), 
('Art Expo', '2026-01-10 11:00:00', 3, 1, 20.00, 1000, 990),
('Mega Concert', '2025-12-30 20:00:00', 4, 3, 150.00, 300, 0);    

-- Insert Attendees (Including one with extra spaces for Point 10 and NULL email)
INSERT INTO Attendees (name, email, phone_number) VALUES 
('Alice Johnson', 'alice@example.com', '111-222-3333'),
('  Bob Smith  ', 'bob@example.com', '444-555-6666'), 
('Charlie Brown', NULL, '777-888-9999'),              
('Diana Prince', 'diana@example.com', '000-111-2222'),
('Evan Wright', 'evan@example.com', '333-222-1111');

-- Insert Tickets (Confirmed, Pending, Cancelled)
INSERT INTO Tickets (event_id, attendee_id, booking_date, status) VALUES 
(1, 1, '2025-11-18', 'Confirmed'),
(1, 2, '2025-11-19', 'Confirmed'),
(2, 1, '2025-11-20', 'Confirmed'), 
(2, 3, '2025-11-20', 'Pending'),
(3, 4, '2025-11-21', 'Confirmed'),
(5, 1, '2025-11-15', 'Cancelled');

-- Insert Payments
INSERT INTO Payments (ticket_id, amount_paid, payment_status, payment_date) VALUES 
(1, 200.00, 'Success', '2025-11-18 10:30:00'),
(2, 200.00, 'Success', '2025-11-19 14:20:00'),
(3, 50.00, 'Success', '2025-11-20 09:15:00'),
(4, 0.00, 'Pending', NULL),
(5, 100.00, 'Failed', '2025-11-21 11:00:00'),
(6, 0.00, 'Failed', '2025-11-15 10:00:00');

-- SOLUTIONS TO TASKS

-- 1. Implement CRUD Operations (Low Weightage)
-- Add Event
INSERT INTO Events (event_name, event_date, venue_id, organizer_id, ticket_price, total_seats, available_seats) 
VALUES ('New Year Gala', '2025-12-31 22:00:00', 1, 1, 300.00, 500, 500);
-- Update Event
SET SQL_SAFE_UPDATES = 0;
UPDATE Events SET ticket_price = 250.00 WHERE event_name = 'Tech Summit 2025';
SET SQL_SAFE_UPDATES = 1;
-- Delete Event (Note: Would require deleting FK dependencies first in real scenario)
DELETE FROM Events WHERE event_name = 'Art Expo' AND event_id NOT IN (SELECT event_id FROM Tickets); 
-- Search Event
SELECT * FROM Events WHERE event_name LIKE '%Jazz%';

-- 2. Use SQL Clauses (WHERE, HAVING, LIMIT) (Low Weightage)
-- Get upcoming events happening in a specific city (Joined for location)
SELECT e.event_name, v.location 
FROM Events e 
JOIN Venues v ON e.venue_id = v.venue_id 
WHERE v.location = 'New York' AND e.event_date > NOW();
-- Retrieve top 5 highest revenue-generating events (Calculation based on paid tickets)
SELECT e.event_name, SUM(p.amount_paid) as total_revenue
FROM Events e
JOIN Tickets t ON e.event_id = t.event_id
JOIN Payments p ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id
ORDER BY total_revenue DESC
LIMIT 5;
-- Find attendees who booked tickets in the last 7 days
SELECT DISTINCT a.name 
FROM Attendees a
JOIN Tickets t ON a.attendee_id = t.attendee_id
WHERE t.booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);

-- 3. Apply SQL Operators (AND, OR, NOT) (Medium Weightage)
-- Retrieve events scheduled in December AND have more than 50% available seats
SELECT event_name, event_date, available_seats, total_seats
FROM Events
WHERE MONTH(event_date) = 12 
  AND available_seats > (total_seats * 0.5);
-- List attendees who have booked a ticket OR have a pending payment
SELECT DISTINCT a.name
FROM Attendees a
JOIN Tickets t ON a.attendee_id = t.attendee_id
LEFT JOIN Payments p ON t.ticket_id = p.ticket_id
WHERE t.status = 'Confirmed' OR p.payment_status = 'Pending';
-- Identify events that are NOT fully booked
SELECT event_name 
FROM Events 
WHERE NOT available_seats = 0;

-- 4. Sorting & Grouping Data (ORDER BY, GROUP BY) (Medium Weightage)
-- Sort events by date in ascending order
SELECT * FROM Events ORDER BY event_date ASC;
-- Count the number of attendees per event
SELECT e.event_name, COUNT(t.ticket_id) as attendee_count
FROM Events e
LEFT JOIN Tickets t ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_name;
-- Show the total revenue generated per event
SELECT e.event_name, COALESCE(SUM(p.amount_paid), 0) as generated_revenue
FROM Events e
LEFT JOIN Tickets t ON e.event_id = t.event_id
LEFT JOIN Payments p ON t.ticket_id = p.ticket_id AND p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name;

-- 5. Use Aggregate Functions (SUM, AVG, MAX, MIN, COUNT) (High Weightage)
-- Calculate total revenue from all events
SELECT SUM(amount_paid) as Grand_Total_Revenue FROM Payments WHERE payment_status = 'Success';
-- Find the event with the highest number of attendees
SELECT e.event_name, COUNT(t.ticket_id) as total_attendees
FROM Events e
JOIN Tickets t ON e.event_id = t.event_id
GROUP BY e.event_id
ORDER BY total_attendees DESC
LIMIT 1;
-- Compute the average ticket price across all events
SELECT AVG(ticket_price) as average_price FROM Events;

-- 7. Implement Joins (High Weightage)
-- INNER JOIN: Event details with venue information
SELECT e.event_name, e.event_date, v.venue_name, v.location
FROM Events e
INNER JOIN Venues v ON e.venue_id = v.venue_id;
-- LEFT JOIN: Attendees who booked a ticket but did not complete payment
SELECT a.name, t.ticket_id, p.payment_status
FROM Attendees a
JOIN Tickets t ON a.attendee_id = t.attendee_id
LEFT JOIN Payments p ON t.ticket_id = p.ticket_id
WHERE p.payment_id IS NULL OR p.payment_status != 'Success';
-- RIGHT JOIN: Events without any attendees
SELECT e.event_name
FROM Tickets t
RIGHT JOIN Events e ON t.event_id = e.event_id
WHERE t.ticket_id IS NULL;

SELECT a.name, t.ticket_id
FROM Attendees a
LEFT JOIN Tickets t ON a.attendee_id = t.attendee_id
WHERE t.ticket_id IS NULL
UNION
SELECT a.name, t.ticket_id
FROM Attendees a
RIGHT JOIN Tickets t ON a.attendee_id = t.attendee_id
WHERE a.attendee_id IS NULL;

-- 8. Use Subqueries (High Weightage)
-- Find events that generated revenue above the average ticket sales
SELECT event_name 
FROM Events e
WHERE (SELECT SUM(amount_paid) 
       FROM Payments p 
       JOIN Tickets t ON p.ticket_id = t.ticket_id 
       WHERE t.event_id = e.event_id) > 
      (SELECT AVG(amount_paid) FROM Payments WHERE payment_status = 'Success');
-- Identify attendees who have booked tickets for multiple events
SELECT name 
FROM Attendees 
WHERE attendee_id IN (
    SELECT attendee_id 
    FROM Tickets 
    GROUP BY attendee_id 
    HAVING COUNT(DISTINCT event_id) > 1
);

-- Retrieve organizers who have managed more than 3 events
SELECT organizer_name 
FROM Organizers 
WHERE organizer_id IN (
    SELECT organizer_id 
    FROM Events 
    GROUP BY organizer_id 
    HAVING COUNT(event_id) > 3
);

-- 9. Implement Date & Time Functions (High Weightage)
-- Extract the month from event_date
SELECT event_name, MONTHNAME(event_date) as event_month FROM Events;

-- Calculate number of days remaining for an upcoming event
SELECT event_name, DATEDIFF(event_date, CURDATE()) as days_remaining 
FROM Events 
WHERE event_date > CURDATE();

-- Format payment_date as YYYY-MM-DD HH:MM:SS
SELECT payment_id, DATE_FORMAT(payment_date, '%Y-%m-%d %H:%i:%s') as formatted_date 
FROM Payments;

-- 10. Use String Manipulation Functions (High Weightage)
-- Convert all organizer names to uppercase
SELECT UPPER(organizer_name) FROM Organizers;

SELECT name as original, TRIM(name) as cleaned_name FROM Attendees;
-- Replace NULL email fields with "Not Provided"
SELECT name, COALESCE(email, 'Not Provided') as email_status FROM Attendees;

-- 11. Implement Window Functions (Very High Weightage)
-- Rank events based on total revenue earned
SELECT 
    e.event_name, 
    SUM(p.amount_paid) as revenue,
    RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) as revenue_rank
FROM Events e
JOIN Tickets t ON e.event_id = t.event_id
JOIN Payments p ON t.ticket_id = p.ticket_id
GROUP BY e.event_id, e.event_name;
-- Display the cumulative sum of ticket sales (ordered by payment date)
SELECT 
    payment_date, 
    amount_paid,
    SUM(amount_paid) OVER (ORDER BY payment_date) as cumulative_sales
FROM Payments
WHERE payment_status = 'Success';
-- Show the running total of attendees registered per event (ordered by booking date)
SELECT 
    e.event_name,
    t.booking_date,
    COUNT(t.attendee_id) OVER (PARTITION BY e.event_id ORDER BY t.booking_date) as running_total_attendees
FROM Events e
JOIN Tickets t ON e.event_id = t.event_id;

-- 12. Apply SQL CASE Expressions (Very High Weightage)
-- Categorize events based on ticket sales (Demand)
SELECT 
    event_name,
    available_seats,
    total_seats,
    CASE 
        WHEN available_seats < (0.2 * total_seats) THEN 'High Demand'
        WHEN available_seats BETWEEN (0.2 * total_seats) AND (0.5 * total_seats) THEN 'Moderate Demand'
        ELSE 'Low Demand'
    END as demand_category
FROM Events;
-- Assign payment statuses
SELECT 
    payment_id, 
    payment_status as original_status,
    CASE 
        WHEN payment_status = 'Success' THEN 'Successful'
        WHEN payment_status = 'Failed' THEN 'Failed'
        ELSE 'Pending'
    END as status_label
FROM Payments;