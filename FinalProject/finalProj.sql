-- Name: Marissa Ratschki
-- CMPT 308 Final Project
-- Cybersecurity Club Membership and Budget Tool

DROP TABLE IF EXISTS budget_transactions;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS members;

--CREATE TABLES
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    major TEXT,
    class_year TEXT,
    member_role TEXT NOT NULL CHECK (member_role IN ('board', 'general'))
);

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    event_name TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('workshop', 'ctf', 'panel', 'meeting', 'review', 'social')),
    event_date DATE NOT NULL,
    location TEXT,
    description TEXT
);

CREATE TABLE attendance (
    member_id INT NOT NULL REFERENCES members(member_id),
    event_id INT NOT NULL REFERENCES events(event_id),
    attended_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (member_id, event_id)
);

CREATE TABLE budget_transactions (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('income', 'expense')),
    category TEXT NOT NULL,
    description TEXT,
    event_id INT NULL REFERENCES events(event_id)
);


-- INDEXES
CREATE INDEX idx_attendance_event_id
ON attendance(event_id);

CREATE INDEX idx_budget_transactions_event_id
ON budget_transactions(event_id);

--INSERT MEMBERS
INSERT INTO members VALUES
    (1, 'Autumn', 'Eagan', 'autumn.eagan@marist.edu', 'Cybersecurity', 'Senior', 'board'),
    (2, 'Tyler', 'Langley', 'tyler.langley@marist.edu', 'Cybersecurity', 'Senior', 'general'),
    (3, 'Ana', 'June', 'ana.june@marist.edu', 'Computer Science', 'Junior', 'general'),
    (4, 'Megan', 'Scott', 'megan.scott@marist.edu', 'Information Systems', 'Junior', 'board'),
    (5, 'John', 'Shelby', 'john.shelby@marist.edu', 'Cybersecurity', 'Sophomore', 'general'),
    (6, 'Lucy', 'Ting', 'lucy.ting@marist.edu', 'Cybersecurity', 'Freshman', 'general'),
    (7, 'Artyom', 'Amosov', 'artyom.amosov@marist.edu', 'Computer Science', 'Sophomore', 'general');


-- INSERT EVENTS
INSERT INTO events VALUES
    (1, 'HackTheBox Workshop', 'workshop', '2026-03-03', 'Dyson 1036', 'Beginner-friendly HackTheBox practice night.'),
    (2, 'Alumni Cybersecurity Panel', 'panel', '2026-03-15', 'HC 0006', 'Alumni discuss cybersecurity careers and internships.'),
    (3, 'Spring CTF Practice', 'ctf', '2026-01-26', 'Dyson 1036', 'Practice CTF challenges.'),
    (4, 'Internetworking Review', 'review', '2026-04-12', 'Dyson 1036', 'Review session for networking concepts');

-- INSERT ATTENDANCE
INSERT INTO attendance VALUES
    (1, 1, '2026-03-03 18:35'),
    (2, 1, '2026-03-03 18:37'),
    (3, 1, '2026-03-03 18:40'),
    (5, 1, '2026-03-03 18:42'),

    (1, 2, '2026-03-15 18:30'),
    (3, 2, '2026-03-15 18:32'),
    (4, 2, '2026-03-15 18:34'),
    (6, 2, '2026-03-15 18:36'),

    (2, 3, '2026-01-26 18:31'),
    (5, 3, '2026-01-26 18:33'),

    (1, 4, '2026-04-12 18:29'),
    (2, 4, '2026-04-12 18:30'),
    (3, 4, '2026-04-12 18:32'),
    (4, 4, '2026-04-12 18:33'),
    (5, 4, '2026-04-12 18:35');

-- INSERT TRANSACTIONS
INSERT INTO budget_transactions VALUES
    (1, '2026-01-20', 300.00, 'income', 'funding', 'SGA spring allocation', NULL),
    (2, '2026-01-26', 100.00, 'expense', 'competition', 'CTF practice platform fee', 3),
    (3, '2026-03-03', 46.25, 'expense', 'food', 'Pizza for HackTheBox workshop', 1),
    (4, '2026-03-15', 25.00, 'expense', 'food', 'Snacks for alumni panel', 2),
    (5, '2026-03-20', 80.00, 'income', 'dues', 'Spring member dues collected', NULL),
    (6, '2026-04-12', 35.00, 'expense', 'supplies', 'Whiteboard markers for review session', 4),
    (7, '2026-04-15', 125.00, 'income', 'fundraising', 'Pie a Professor fundraiser', NULL);

-- Query 1: Basic filter query for listing board members
SELECT
    member_id,
    first_name,
    last_name,
    major,
    class_year,
    member_role
FROM members
WHERE member_role = 'board'
ORDER BY last_name, first_name;

-- Query 2: Join for showing attendance at the HackTheBox event
SELECT
    e.event_name,
    e.event_date,
    m.first_name || ' ' || m.last_name AS member_name,
    a.attended_at
FROM attendance a
JOIN members m
    ON a.member_id = m.member_id
JOIN events e
    ON a.event_id = e.event_id
WHERE e.event_name = 'HackTheBox Workshop'
ORDER BY member_name;

-- Query 3: Join query for listing event related expenses
SELECT
    bt.transaction_date,
    e.event_name,
    bt.category,
    bt.amount,
    bt.description
FROM budget_transactions bt
JOIN events e
    ON bt.event_id = e.event_id
WHERE bt.transaction_type = 'expense'
ORDER BY bt.transaction_date;

-- Query 4: Query for counting attendance per event
SELECT
    e.event_id,
    e.event_name,
    e.event_date,
    COUNT(a.member_id) AS attendance_count
FROM events e
LEFT JOIN attendance a
    ON e.event_id = a.event_id
GROUP BY e.event_id, e.event_name, e.event_date
ORDER BY e.event_date;

-- Query 5: Subquery for finding members without attendance records

SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    m.member_role
FROM members m
WHERE NOT EXISTS (
    SELECT 1
    FROM attendance a
    WHERE a.member_id = m.member_id
)
ORDER BY m.last_name, m.first_name;

-- Query 6: Query for calculating total income, expenses, and current balance
SELECT
    SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE -amount END) AS current_balance
FROM budget_transactions;