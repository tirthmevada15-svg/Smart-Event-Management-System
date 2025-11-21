# Smart-Event-Management-System
## 📌 Overview

This project contains a complete MySQL database setup for a smart event management system called **SmartEventDB**. It includes database creation, table definitions, constraints, seed data, and solutions to SQL tasks categorized by complexity.

The system manages:

* Venues
* Organizers
* Events
* Attendees
* Tickets
* Payments

It also demonstrates SQL concepts such as CRUD operations, joins, grouping, aggregations, subqueries, window functions, and more.

---

## 🗂️ Database Structure

### **1. Venues Table**

Stores event venue information.

* venue_id (PK)
* venue_name
* location
* capacity

### **2. Organizers Table**

Contains event organizer details.

* organizer_id (PK)
* organizer_name
* contact_email
* phone_number

### **3. Events Table**

Stores event data linked to venues and organizers.

* event_id (PK)
* event_name
* event_date
* venue_id (FK → Venues)
* organizer_id (FK → Organizers)
* ticket_price
* total_seats
* available_seats

### **4. Attendees Table**

Contains attendee personal information.

* attendee_id (PK)
* name
* email
* phone_number

### **5. Tickets Table**

Tracks ticket bookings and ensures no attendee books the same event twice.

* ticket_id (PK)
* event_id (FK → Events)
* attendee_id (FK → Attendees)
* booking_date
* status (Confirmed/Pending/Cancelled)
* UNIQUE(event_id, attendee_id)

### **6. Payments Table**

Handles ticket payment statuses.

* payment_id (PK)
* ticket_id (FK → Tickets)
* amount_paid
* payment_status
* payment_date

---

## 🧪 Seed Data

The database includes initial entries for:

* 4 venues
* 3 organizers
* 5 events
* 5 attendees
* 6 tickets
* 6 payments

This enables realistic testing for all SQL queries.

---

## 🧩 SQL Tasks & Solutions

This project demonstrates multiple categories of SQL operations.

### ✔ **1. CRUD Operations**

Includes INSERT, UPDATE, DELETE, and search queries.

### ✔ **2. SQL Clauses (WHERE, HAVING, LIMIT)**

Retrieves filtered data such as upcoming events, top revenue events, and recent attendees.

### ✔ **3. SQL Operators (AND, OR, NOT)**

Applies logical conditions to get meaningful insights.

### ✔ **4. Sorting & Grouping (ORDER BY, GROUP BY)**

Generates event lists, attendee counts, and revenue reports.

### ✔ **5. Aggregate Functions (SUM, AVG, MAX, MIN, COUNT)**

Performs calculations like total revenue and average prices.

### ✔ **6. Join Operations (INNER, LEFT, RIGHT)**

Links multiple tables to extract combined information.

### ✔ **7. Subqueries**

Includes nested queries to find above-average events, multi-event attendees, etc.

### ✔ **8. Date & Time Functions**

Uses MONTH(), DATEDIFF(), DATE_FORMAT(), etc.

### ✔ **9. String Functions**

Uses UPPER(), TRIM(), COALESCE() for text processing.

### ✔ **10. Window Functions**

Implements ranking, cumulative sums, and running totals.

### ✔ **11. CASE Expressions**

Categorizes events and payment statuses.

