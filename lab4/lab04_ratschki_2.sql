-- Name: Marissa Ratschki
-- Date: 2-27-26
-- Lab 04
-- Data reloaded using CREATE and INSERT scripts from lab 02

DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Courses;

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    major VARCHAR(50),
    class_year INT
);

CREATE TABLE Courses (
    course_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(100),
    credits INT CHECK (credits > 0)
);

CREATE TABLE Enrollments (
    student_id INT,
    course_id VARCHAR(10),
    term VARCHAR(10),
    grade VARCHAR(2),

    PRIMARY KEY (student_id, course_id, term),

    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);


--INSERTS

-- Students
INSERT INTO Students VALUES
(29, 'Mila', 'CS', 2026),
(57, 'John', 'CS', 2027),
(48, 'Julia', 'DS', 2026),
(25, 'Artyom', 'CS', 2026),
(34, 'Lucy', 'DS', 2028),
(55, 'Tyler', 'CS', 2026);

-- Courses
INSERT INTO Courses VALUES
('CMPT308', 'Database Management', 4),
('CMPT307', 'Internetworking', 4),
('CMPT423', 'Hacking and Pentesting', 3),
('CMPT466', 'Special Topics', 4),
('CMPT450', 'Independent Study', 3); 

-- Enrollments (2026SP data)
INSERT INTO Enrollments VALUES
(29, 'CMPT308', '2026SP', 'A'),
(57, 'CMPT308', '2026SP', 'B'),
(48, 'CMPT307', '2026SP', 'A'),
(25, 'CMPT308', '2026SP', 'B'),
(34, 'CMPT423', '2026SP', 'A'),
(55, 'CMPT307', '2026SP', 'B');


--joins
SELECT s.name, e.course_id
FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.term = '2026SP';


-- a1
SELECT s.name, e.course_id
FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.term = '2026SP';


-- SELECT s.name, c.title, e.term
FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id
INNER JOIN Courses c
ON e.course_id = c.course_id
WHERE e.term = '2026SP';

-- a3
SELECT c.course_id, c.title, COUNT(e.student_id) AS enrollments
FROM Courses c
LEFT JOIN Enrollments e
ON c.course_id = e.course_id
AND e.term = '2026SP'
GROUP BY c.course_id, c.title
ORDER BY c.course_id;



-- b1
SELECT major, COUNT(*) AS num_students
FROM Students
GROUP BY major
ORDER BY num_students DESC;



-- b2 
SELECT c.course_id, c.title, COUNT(*) AS num_enrollments
FROM Courses c
JOIN Enrollments e
ON c.course_id = e.course_id
WHERE e.term = '2026SP'
GROUP BY c.course_id, c.title;

-- b3
SELECT course_id, COUNT(*) AS num_enrollments
FROM Enrollments
WHERE term = '2026SP'
GROUP BY course_id
HAVING COUNT(*) >= 3;



-- c1
SELECT name
FROM Students
WHERE student_id IN (
    SELECT student_id
    FROM Enrollments
    WHERE course_id = 'CMPT308'
    AND term = '2026SP'
);


-- c2
SELECT course_id, title
FROM Courses c
WHERE EXISTS (
    SELECT *
    FROM Enrollments e
    WHERE e.course_id = c.course_id
    AND e.term = '2026SP'
);


-- c3
SELECT s.name
FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.term = '2026SP'
GROUP BY s.student_id, s.name
HAVING COUNT(*) >= 2;


-- d1 
SELECT student_id, name
FROM Students
WHERE major = 'CS'

UNION

SELECT student_id, name
FROM Students
WHERE major = 'DS';



-- D2
SELECT student_id, name
FROM Students
WHERE major = 'CS'

EXCEPT

SELECT s.student_id, s.name
FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.course_id = 'CMPT308'
AND e.term = '2026SP';
