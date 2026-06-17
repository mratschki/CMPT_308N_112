-- Name: Marissa Ratschki
-- Lab 05
-- Data reloaded using CREATE and INSERT scripts from lab 04

DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Students;

--CREATES
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    major VARCHAR(50) NOT NULL,
    class_year INT NOT NULL
);

CREATE TABLE Courses (
    course_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0)
);

CREATE TABLE Enrollments (
    student_id INT,
    course_id VARCHAR(10),
    term VARCHAR(20) NOT NULL,
    grade VARCHAR(2),

    PRIMARY KEY (student_id, course_id, term),

    FOREIGN KEY (student_id)
        REFERENCES Students(student_id),

    FOREIGN KEY (course_id)
        REFERENCES Courses(course_id)
);

--INSERTS
INSERT INTO Students VALUES
    (29, 'Mila', 'Cybersecurity', 2026),
    (57, 'John', 'Cybersecurity', 2027),
    (48, 'Julia', 'Computer Science', 2026),
    (25, 'Artyom', 'Cybersecurity', 2026),
    (34, 'Lucy', 'Information Systems', 2028),
    (55, 'Tyler', 'Computer Science', 2026);

INSERT INTO Courses VALUES
    ('CMPT308', 'Database Management', 4),
    ('CYBR210', 'Network Security', 3),
    ('CMPT307', 'Internetworking', 4),
    ('CMPT466', 'Special Topics', 4);

INSERT INTO Enrollments VALUES
    (29, 'CMPT308', '2026SP', 'A'),
    (57, 'CMPT308', '2026SP', 'B'),
    (57, 'CYBR210', '2026SP', 'A'),
    (48, 'CYBR210', '2026SP', 'B'),
    (25, 'CMPT308', '2026SP', 'B'),
    (55, 'CMPT307', '2025FA', 'A');

-- A1
SELECT student_id, name
FROM Students
WHERE student_id IN (
    SELECT student_id
    FROM Enrollments
    WHERE course_id = 'CMPT308'
      AND term = '2026SP'
)
ORDER BY student_id;


-- A2
SELECT c.course_id, c.title
FROM Courses c
WHERE EXISTS (
    SELECT 1
    FROM Enrollments e
    WHERE e.course_id = c.course_id
      AND e.term = '2026SP'
)
ORDER BY c.course_id;


-- A3
SELECT s.student_id, s.name
FROM Students s
WHERE NOT EXISTS (
    SELECT 1
    FROM Enrollments e
    WHERE e.student_id = s.student_id
      AND e.term = '2026SP'
)
ORDER BY s.student_id;

-- A4
SELECT student_id
FROM Enrollments
WHERE course_id = 'CMPT308'
  AND term = '2026SP'

UNION

SELECT student_id
FROM Enrollments
WHERE course_id = 'CYBR210'
  AND term = '2026SP'

ORDER BY student_id;

-- A5
SELECT student_id
FROM Enrollments
WHERE course_id = 'CMPT308'
  AND term = '2026SP'

INTERSECT

SELECT student_id
FROM Enrollments
WHERE course_id = 'CYBR210'
  AND term = '2026SP'

ORDER BY student_id;

-- A6
SELECT student_id
FROM Enrollments
WHERE course_id = 'CMPT308'
  AND term = '2026SP'

EXCEPT

SELECT student_id
FROM Enrollments
WHERE course_id = 'CYBR210'
  AND term = '2026SP'

ORDER BY student_id;