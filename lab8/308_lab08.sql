-- Name: Marissa Ratschki
-- Lab 08


DROP TABLE IF EXISTS lab8_enrollment_audit;
DROP TABLE IF EXISTS lab8_enrollments;
DROP TABLE IF EXISTS lab8_courses;
DROP TABLE IF EXISTS lab8_students;

DROP FUNCTION IF EXISTS lab8_register_student(INT, TEXT);
DROP FUNCTION IF EXISTS lab8_log_enrollment_insert();

-- CREATES
CREATE TABLE lab8_students (
    student_id INT PRIMARY KEY,
    student_name TEXT NOT NULL
);

CREATE TABLE lab8_courses (
    course_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    enrolled_count INT NOT NULL DEFAULT 0 CHECK (enrolled_count >= 0 AND enrolled_count <= capacity)
);

CREATE TABLE lab8_enrollments (
    student_id INT NOT NULL REFERENCES lab8_students(student_id),
    course_id TEXT NOT NULL REFERENCES lab8_courses(course_id),
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE lab8_enrollment_audit (
    audit_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action_type TEXT NOT NULL,
    student_id INT NOT NULL,
    course_id TEXT NOT NULL,
    action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- INSERTS
INSERT INTO lab8_students (student_id, student_name) VALUES
    (1, 'Ana'),
    (2, 'Tyler'),
    (3, 'Tyra'),
    (4, 'Megan');

INSERT INTO lab8_courses (course_id, title, capacity, enrolled_count) VALUES
    ('CMPT308', 'Database Management', 2, 0),
    ('CMPT101', 'Intro to Cybersecurity', 1, 0),
    ('CMPT200', 'Internetworking', 3, 0);

-- PART A
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'advisor_role') THEN
        CREATE ROLE advisor_role;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'registrar_role') THEN
        CREATE ROLE registrar_role;
    END IF;
END $$;

GRANT SELECT ON lab8_students, lab8_courses, lab8_enrollments TO advisor_role;

GRANT SELECT ON lab8_students, lab8_courses, lab8_enrollments TO registrar_role;
GRANT INSERT ON lab8_enrollments TO registrar_role;
GRANT UPDATE ON lab8_courses TO registrar_role;

REVOKE DELETE ON lab8_enrollments FROM registrar_role;

-- PART A privilege report
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('advisor_role', 'registrar_role')
  AND table_name IN ('lab8_students', 'lab8_courses', 'lab8_enrollments')
ORDER BY grantee, table_name, privilege_type;


-- PART B
CREATE OR REPLACE FUNCTION lab8_register_student(
    p_student_id INT,
    p_course_id TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_student_name TEXT;
    v_course_title TEXT;
    v_capacity INT;
    v_enrolled_count INT;
BEGIN
    -- check if student exists
    SELECT student_name
    INTO v_student_name
    FROM lab8_students
    WHERE student_id = p_student_id;

    IF NOT FOUND THEN
        RETURN 'ERROR: student ' || p_student_id || ' does not exist.';
    END IF;

    -- check if course exists
    SELECT title, capacity, enrolled_count
    INTO v_course_title, v_capacity, v_enrolled_count
    FROM lab8_courses
    WHERE course_id = p_course_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN 'ERROR: course ' || p_course_id || ' does not exist.';
    END IF;

    -- check if student is already enrolled
    IF EXISTS (
        SELECT 1
        FROM lab8_enrollments
        WHERE student_id = p_student_id
          AND course_id = p_course_id
    ) THEN
        RETURN 'ERROR: ' || v_student_name || ' is already enrolled in ' || p_course_id || '.';
    END IF;

    -- check if course still has room
    IF v_enrolled_count >= v_capacity THEN
        RETURN 'ERROR: course ' || p_course_id || ' is full.';
    END IF;

    -- if all checks succeed insert enrollment and update count
    INSERT INTO lab8_enrollments (student_id, course_id)
    VALUES (p_student_id, p_course_id);

    UPDATE lab8_courses
    SET enrolled_count = enrolled_count + 1
    WHERE course_id = p_course_id;

    RETURN 'SUCCESS: enrolled ' || v_student_name || ' in ' || p_course_id || ' - ' || v_course_title || '.';
END;
$$;

-- PART B tests
-- successful enrollment
SELECT lab8_register_student(1, 'CMPT308') AS result;

-- duplicate enrollment attempt
SELECT lab8_register_student(1, 'CMPT308') AS result;

-- student not found attempt
SELECT lab8_register_student(99, 'CMPT308') AS result;


-- PART C
CREATE OR REPLACE FUNCTION lab8_log_enrollment_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lab8_enrollment_audit (
        action_type,
        student_id,
        course_id,
        action_time
    )
    VALUES (
        'INSERT',
        NEW.student_id,
        NEW.course_id,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER lab8_enrollment_insert_audit_trg
AFTER INSERT ON lab8_enrollments
FOR EACH ROW
EXECUTE FUNCTION lab8_log_enrollment_insert();

-- PART C tests
-- successful enrollment after trigger creation
SELECT lab8_register_student(2, 'CYBR101') AS result;

-- course full attempt
SELECT lab8_register_student(3, 'CYBR101') AS result;

-- audit table report after trigger test
SELECT audit_id, action_type, student_id, course_id, action_time
FROM lab8_enrollment_audit
ORDER BY action_time, audit_id;


-- PART D
-- enrollment list
SELECT
    s.student_name,
    e.course_id,
    c.title AS course_title,
    e.enrolled_at
FROM lab8_enrollments e
JOIN lab8_students s
    ON e.student_id = s.student_id
JOIN lab8_courses c
    ON e.course_id = c.course_id
ORDER BY e.enrolled_at, s.student_name, e.course_id;

-- seats remaining
SELECT
    course_id,
    title,
    capacity,
    enrolled_count,
    capacity - enrolled_count AS seats_remaining
FROM lab8_courses
ORDER BY course_id;

-- audit log report
SELECT
    audit_id,
    action_type,
    student_id,
    course_id,
    action_time
FROM lab8_enrollment_audit
ORDER BY action_time, audit_id;

-- privilege report
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('advisor_role', 'registrar_role')
  AND table_name IN ('lab8_students', 'lab8_courses', 'lab8_enrollments')
ORDER BY grantee, table_name, privilege_type;