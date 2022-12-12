-- Course: CS340 - Introduction to Databases
-- Assignment: Project Step 3 Draft
-- Due Date: 10/27/22
-- Canvas Group: Project Group 29 (Team MelliBurdett)
-- Members: Benjamin Burdett and Tessa Melli


-- COURSES (create, read, update, delete)

-- add a new course
INSERT INTO Courses
(
    prefix,
    code,
    course_name,
    description,
    has_prereq,
    lecture,
    lab,
    credit_hour,
    academic_level
)
VALUES
(
    :prefixInput,
    :codeInput,
    :course_nameInput,
    :descriptionInput,
    :has_prereqInput,
    :lectureInput,
    :labInput,
    :credit_hourInput,
    :academic_levelInput
);

-- display all course data
SELECT
  course_id AS 'ID',
  prefix AS 'Prefix',
  code AS 'Code',
  course_name AS 'Course Name',
  description AS 'Course Description',
  has_prereq AS 'Has a Prereq?',
  lecture AS 'Lecture Component',
  lab AS 'Lab Component',
  credit_hour AS 'Credit Hour',
  academic_level AS 'Academic Level'
FROM Courses;

-- Get course info for dropdown to update course data
SELECT
  course_id AS 'ID',
  CONCAT(prefix, code) AS 'Course Code',
  course_name AS 'Course Name'
FROM Courses;

-- update course data
UPDATE Courses
SET
  prefix = :prefixInput,
  code = :codeInput,
  course_name = :course_nameInput,
  description = :descriptionInput,
  has_prereq = :has_prereqInput,
  lecture = :lectureInput,
  lab = :labInput,
  credit_hour = :credit_hourInput,
  academic_level = :academic_levelInput
WHERE course_id = :course_id_from_dropdownInput;

-- delete a course
DELETE FROM Courses
WHERE course_id = :course_id_from_dropdownInput;


-- INSTRUCTORS (create, read, update)

-- Add a new instructor
INSERT INTO Instructors
(
    first_name,
    last_name,
    email,
    phone_number,
    address
)
VALUES
(
    :first_nameInput,
    :last_nameInput,
    :emailInput,
    :phone_numberInput,
    :addressInput
);

-- Display all instructor details
SELECT
  instructor_id AS 'ID',
  first_name AS 'First Name',
  last_name AS 'Last Name',
  email AS 'Email',
  phone_number AS 'Phone Number',
  address AS 'Address'
FROM Instructors;

-- Get instructor info for dropdown to update instructor details
SELECT
  instructor_id AS 'ID',
  CONCAT(last_name, ', ', first_name) AS 'Instructor Name'
FROM Instructors;

-- Update instructor details
UPDATE Instructors SET
    first_name = :first_nameInput,
    last_name = :last_nameInput,
    email = :emailInput,
    phone_number = :phone_numberInput,
    address = :addressInput
WHERE instructor_id = :instructor_id_from_dropdownInput


-- STUDENTS (create, read, update)

-- Add a new student
INSERT INTO Students
(
    degree_type,
    first_name,
    last_name,
    email,
    phone_number,
    address
)
VALUES
(
    :degree_typeInput,
    :first_nameInput,
    :last_nameInput,
    :emailInput,
    :phone_numberInput,
    :addressInput
);

-- Display all student details
SELECT
  student_id AS 'ID',
  degree_type AS 'Degree Type',
  first_name AS 'First Name',
  last_name AS 'Last Name',
  email AS 'Email',
  phone_number AS 'Phone Number',
  address AS 'Address'
FROM Students;

-- Get student info for dropdown to enroll a student in a section
SELECT
  student_id AS 'Student ID',
  CONCAT(last_name, ', ', first_name) AS 'Student Name'
FROM Students;

-- Update student details
UPDATE Students SET
    first_name = :first_nameInput,
    last_name = :last_nameInput,
    email = :emailInput,
    phone_number = :phone_numberInput,
    address = :addressInput
WHERE student_id = :student_id_from_dropdownInput;


-- MAJORS (create, read, update)

-- Add a new major
INSERT INTO Majors
(
    major_name,
    abbreviation,
    description
)
VALUES
(
    :major_nameInput,
    :abbreviationInput,
    :descriptionInput
);

-- Display all major details
SELECT
  major_id AS 'ID',
  abbreviation AS 'Abbreviation',
  major_name AS 'Major Name',
  description AS 'Description'
FROM Majors;

-- Get major info for dropdown to update majors
SELECT
  major_id AS 'ID',
  CONCAT (major_name, ' (', abbreviation, ')') AS 'Major Name (abbr)'
FROM Majors;

-- Update major details
UPDATE Majors SET
    major_name = :major_nameInput,
    abbreviation = :abbreviationInput,
    description = :descriptionInput
WHERE major_id = :major_id_from_dropdownInput;

-- SECTIONS (create, read, update)

-- Get course info for dropdown to add or update a section
SELECT
  course_id AS 'ID',
  CONCAT(prefix, code) AS 'Course Code',
  course_name AS 'Course Name'
FROM Courses;

-- Get instructor info for dropdown to add or update a section
SELECT
  instructor_id AS 'ID',
  CONCAT(last_name, ', ', first_name) AS 'Instructor Name'
FROM Instructors;

-- Add a new section
INSERT INTO Sections (
    course_id,
    instructor_id,
    enrollment_cap
)
VALUES (
    :course_id_from_dropdownInput,
    :instructor_id_from_dropdownInput,
    :enrollment_capInput
);

-- Display section details
SELECT
  s.section_id AS 'ID',
  CONCAT(c.prefix, c.code, '-', s.section_id) AS ' CoSectionde',
  c.course_name AS 'Course Name',
  CONCAT(i.last_name, ', ', i.first_name) AS 'Instructor Name',
  s.enrollment_cap AS 'Enrollment Cap'
FROM Sections AS s
INNER JOIN Courses AS c USING (course_id)
INNER JOIN Instructors AS i USING (instructor_id);

-- Get section info for dropdown to update a section
SELECT
  s.section_id AS 'ID',
  CONCAT(c.prefix, c.code, '-', s.section_id) AS 'Section Code',
  c.course_name AS 'Course Name'
FROM Sections AS s
INNER JOIN Courses AS c USING (course_id);

-- Update section details
UPDATE Sections SET
    course_id = :course_id_from_dropdownInput,
    instructor_id = :instructor_id_from_dropdownInput,
    enrollment_cap = :enrollment_capInput
WHERE section_id = :section_id_from_dropdownInput;


-- STUDENTS_SECTIONS (create, read, delete)

-- Get student info for dropdown to enroll a student in a section or cancel an enrollment
SELECT
  student_id AS 'Student ID',
  CONCAT(last_name, ', ', first_name) AS 'Student Name'
FROM Students;

-- Get section info for dropdown to enroll a student in a section or cancel an enrollment
SELECT
  s.section_id AS 'Section ID',
  CONCAT(c.prefix, c.code, '-', s.section_id) AS 'Section Code',
  c.course_name AS 'Course Name'
FROM Sections AS s
INNER JOIN Courses AS c USING (course_id);

-- Enroll a student into a section (add)
INSERT INTO Students_Sections
(
    student_id,
    section_id
)
VALUES (
  :student_id_from_dropdownInput,
  :section_id_from_dropdownInput
);

-- Display enrollment details
SELECT
  ss.enrollment_id AS "Enrollment ID",
  st.student_id AS "Student ID",
  CONCAT(st.last_name, ', ', st.first_name) AS "Student Name",
  CONCAT(c.prefix, c.code, '-', se.section_id) AS "Section Code"
FROM Students_Sections AS ss
INNER JOIN Students AS st USING (student_id)
INNER JOIN Sections AS se USING (section_id)
INNER JOIN Courses AS c USING (course_id);

-- Cancel an enrollment (delete)
DELETE FROM Students_Sections
WHERE section_id = :course_id_from_dropdownInput
AND student_id = :student_id_from_dropdownInput;


-- STUDENTS_MAJORS (create, read, update, delete)

-- Get student info for dropdown to declare or undeclare a major
SELECT
  student_id AS 'Student ID',
  CONCAT(last_name, ', ', first_name) AS 'Student Name'
FROM Students;

-- Get major info for dropdown to declare or undeclare a major
SELECT
  major_id AS 'Major ID',
  CONCAT (major_name, ' (', abbreviation, ')') AS 'Major Name (abbr)'
FROM Majors;

-- Declare a major for a student (add)
INSERT INTO Students_Majors
(
    student_id,
    major_id
)
VALUES
(
    :student_id_from_dropdownInput,
    :major_id_from_dropdownInput
);

-- Display major declaration details
SELECT
  sm.declaration_id AS "Major Declaration ID",
  st.student_id AS 'Student ID',
  CONCAT(st.last_name, ', ', st.first_name) AS 'Student Name',
  m.major_id AS 'Major ID',
  CONCAT (m.major_name, ' (', m.abbreviation, ')') AS 'Major Name (abbr)'
FROM Students_Majors AS sm
INNER JOIN Students AS st USING (student_id)
INNER JOIN Majors AS m USING (major_id);

-- Undeclare a major (delete)
DELETE FROM Students_Majors
WHERE student_id = :student_id_from_dropdownInput
AND major_id = :major_id_from_dropdownInput;
