--  TABLE CREATION //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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


-- DATA INSERTION ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
INSERT INTO Students VALUES
(29, 'Mila', 'CMPT-423', 2026),
(57, 'John', 'CMPT-308', 2027),
(48, 'Julia', 'CMPT-466', 2026),
(25, 'Artyom', 'CMPT-308', 2026),
(34, 'Lucy', 'CMPT-307', 2028),
(55, 'Tyler', 'CMPT-466', 2026);

INSERT INTO Courses VALUES
('CMPT-423', 'Hacking and Pentesting', 3),
('CMPT-308', 'Database Management', 4),
('CMPT-466', 'Special Topics', 4),
('CMPT-307', 'Internetworking', 4);

INSERT INTO Enrollments VALUES
(55, 'CMPT-308', 'Fall 2025', 'A'),
(29, 'CMPT-466', 'Fall 2025', 'B'),
(57, 'CMPT-466', 'Spring 2025', NULL),
(48, 'CMPT-308', 'Spring 2025', NULL),
(57, 'CMPT-307', 'Fall 2026', 'B'),
(25, 'CMPT-308', 'Spring 2026', 'B'),
(34, 'CMPT-466', 'Spring 2025', 'A'),
(55, 'CMPT-307', 'Spring 2025', 'B');



-- QUERIES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- projection
SELECT student_id, name
FROM Students;

-- selection
SELECT *
FROM Students
WHERE major = 'CMPT-308';

-- multiple conditions
SELECT *
FROM Courses
WHERE credits >= 3;

-- like 
SELECT *
FROM Students
WHERE name LIKE 'M%';

-- NULL check
SELECT *
FROM Enrollments
WHERE grade IS NULL;

-- ORDER BY
SELECT *
FROM Students
ORDER BY class_year, name;
