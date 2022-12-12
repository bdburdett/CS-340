-- Course: CS340 - Introduction to Databases
-- Assignment: Project Step 2 Draft
-- Due Date: 10/20/22
-- Canvas Group: Project Group 29 (Team MelliBurdett)
-- Members: Benjamin Burdett and Tessa Melli


-- TURN OFF COMMITS AND FOREIGN KEY CHECKS TO MINIMIZE IMPORT ERRORS
SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT=0;

-- INSERT TABLES INTO DATABASE

CREATE OR REPLACE TABLE Courses(
    course_id int AUTO_INCREMENT UNIQUE NOT NULL,
    prefix varchar(9) NOT NULL,
    code int NOT NULL,
    course_name varchar(140) NOT NULL,
    description varchar(255) NOT NULL,
    has_prereq boolean NOT NULL,
    lecture boolean NOT NULL,
    lab boolean NOT NULL,
    credit_hour int NOT NULL,
    academic_level varchar(30) NOT NULL DEFAULT "UG",
    PRIMARY KEY(course_id)
);

CREATE OR REPLACE TABLE Instructors(
    instructor_id int AUTO_INCREMENT UNIQUE NOT NULL,
    first_name varchar(30) NOT NULL,
    last_name varchar(30) NOT NULL,
    email varchar(140) NOT NULL,
    phone_number varchar(30) NOT NULL,
    address varchar(140) NOT NULL,
    PRIMARY KEY(instructor_id)
);

CREATE OR REPLACE TABLE Sections(
    section_id int AUTO_INCREMENT UNIQUE NOT NULL,
    course_id int NOT NULL,
    instructor_id int NOT NULL,
    enrollment_cap int NOT NULL,
    PRIMARY KEY(section_id),
    FOREIGN KEY(course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY(instructor_id) REFERENCES Instructors(instructor_id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Students(
    student_id int AUTO_INCREMENT UNIQUE NOT NULL,
    degree_type varchar(30) NOT NULL DEFAULT "UG",
    first_name varchar(30) NOT NULL,
    last_name varchar(30) NOT NULL,
    email varchar(140) NOT NULL,
    phone_number varchar(30) NOT NULL,
    address varchar(140) NOT NULL,
    PRIMARY KEY(student_id)
);

CREATE OR REPLACE TABLE Majors(
    major_id int AUTO_INCREMENT UNIQUE NOT NULL,
    major_name varchar(30) NOT NULL,
    abbreviation varchar(10) NOT NULL,
    description varchar(255) NOT NULL,
    PRIMARY KEY(major_id)
);

CREATE OR REPLACE TABLE Students_Majors(
    declaration_id int AUTO_INCREMENT UNIQUE NOT NULL,
    student_id int NOT NULL,
    major_id int NOT NULL,
    PRIMARY KEY(declaration_id),
    FOREIGN KEY(student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY(major_id) REFERENCES Majors(major_id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Students_Sections(
    enrollment_id int AUTO_INCREMENT UNIQUE NOT NULL,
    student_id int NOT NULL,
    section_id int NOT NULL,
    PRIMARY KEY(enrollment_id),
    FOREIGN KEY(student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY(section_id) REFERENCES Sections(section_id) ON DELETE CASCADE
);


-- INSERT DATA INTO COURSES TABLE

INSERT INTO Courses (
    prefix, code, course_name, description, has_prereq, lecture, lab, credit_hour, academic_level
)
VALUES
(
    "CS",
    340,
    "INTRODUCTION TO DATABASES",
    "Design and implementation of relational databases",
    TRUE,
    TRUE,
    FALSE,
    4,
    "UG"
),
(
    "MTH",
    251,
    "DIFFERENTIAL CALCULUS",
    "Differential calculus for engineers and scientists",
    TRUE,
    TRUE,
    FALSE,
    4,
    "UG"
),
(
    "BI",
    103,
    "HUMAN BIOLOGY",
    "Introduction to the biology of humans",
    FALSE,
    TRUE,
    TRUE,
    4,
    "UG"
),
(
    "SOC",
    438,
    "WELFARE AND SOCIAL SERVICES",
    "Analysis of forces affecting welfare and social service systems",
    FALSE,
    TRUE,
    FALSE,
    4,
    "UG"
),
(
    "NUTR",
    235,
    "SCIENCE OF FOODS",
    "Composition, functional properties, and structure of foods",
    TRUE,
    TRUE,
    FALSE,
    4,
    "UG"
);

-- INSERT DATA INTO INSTRUCTORS TABLE

INSERT INTO Instructors (
    first_name, last_name, email, phone_number, address
)
VALUES
(
    "Heidi",
    "Freund",
    "freundh@FauxSU.edu",
    "111-222-3333",
    "393 East St., Antelope, OR 97001"
),
(
    "Darach",
    "Kowalski",
    "kowalskid@FauxSU.edu",
    "(204) 402-2040",
    "599 Snake Hill Court, Canyon City, OR 97820"
),
(
    "Juma",
    "Keyes",
    "keyesj@FauxSU.edu",
    "1234567890",
    "774 Penn St, Portland, OR 97231"
),
(
    "Sylvi",
    "Garnett",
    "garnetts@FauxSU.edu",
    "908-675-3412",
    "737 Macaroni Road, Gaston, OR 97119"
),
(
    "Adriene",
    "Angioli",
    "angiolia@FauxSU.edu",
    "(444) 555-6666",
    "404 Forest Dr, Walterville, OR 97478"
);

-- INSERT DATA INTO SECTIONS TABLE

INSERT INTO Sections (
    course_id, instructor_id, enrollment_cap
)
VALUES
(
    (SELECT course_id FROM Courses WHERE code = 103),
    (SELECT instructor_id FROM Instructors WHERE email = "freundh@FauxSU.edu"),
    50
),
(
    (SELECT course_id FROM Courses WHERE code = 438),
    (SELECT instructor_id FROM Instructors WHERE email = "angiolia@FauxSU.edu"),
    25
),
(
    (SELECT course_id FROM Courses WHERE code = 103),
    (SELECT instructor_id FROM Instructors WHERE email = "kowalskid@FauxSU.edu"),
    50
),
(
    (SELECT course_id FROM Courses WHERE code = 251),
    (SELECT instructor_id FROM Instructors WHERE email = "garnetts@FauxSU.edu"),
    75
),
(
    (SELECT course_id FROM Courses WHERE code = 340),
    (SELECT instructor_id FROM Instructors WHERE email = "garnetts@FauxSU.edu"),
    30
);

-- INSERT DATA INTO STUDENTS TABLE

INSERT INTO Students (
    degree_type, first_name, last_name, email, phone_number, address
)
VALUES
(
    "UG",
    "Ramiro",
    "Sydney",
    "sydneyr@FauxSU.edu",
    "121-232-3434",
    "75 South Somerset St., Cloverdale, OR 97112"
),
(
    "UG",
    "David",
    "Mofty",
    "moftyd@FauxSU.edu",
    "(101) 111-0000",
    "177 Leeton Ridge Street, Salem, OR 97303"
),
(
    "UG",
    "Kelcey",
    "Thomas",
    "thomask@FauxSU.edu",
    "(989) 898-9988",
    "18 Lake Avenue, Swisshome, OR 97480"
),
(
    "UG",
    "Wallace",
    "Strand",
    "strandw@FauxSU.edu",
    "6758489403",
    "602 Bald Hill Ave., Bend, OR 97707"
),
(
    "UG",
    "Flora",
    "Borst",
    "borstf@FauxSU.edu",
    "238-932-0982",
    "316 Plumb Branch Drive, Gold Beach, OR 97444"
);

-- INSERT DATA INTO MAJORS TABLE

INSERT INTO Majors (
    major_name, abbreviation, description
)
VALUES
(
    "Physics",
    "PHYS",
    "Study of classical and modern theories of matter and energy"
),
(
    "Finance",
    "FIN",
    "Study of financial theories and how they apply in the business world"
),
(
    "Computer Science",
    "CS",
    "Study of computers and programming languages"
),
(
    "History",
    "HIS",
    "Study of past events and eras"
),
(
    "Biological Sciences",
    "BIO",
    "Study of function and characteristics of living organisms"
);


-- INSERT DATA INTO STUDENT_MAJORS INTERSECTION TABLE

INSERT INTO Students_Majors (
    student_id, major_id
)
VALUES
(
    (SELECT student_id FROM Students WHERE email = "moftyd@FauxSU.edu"),
    (SELECT major_id FROM Majors WHERE major_name = "Computer Science")
),
(
    (SELECT student_id FROM Students WHERE email = "strandw@FauxSU.edu"),
    (SELECT major_id FROM Majors WHERE major_name = "Physics")
),
(
    (SELECT student_id FROM Students WHERE email = "strandw@FauxSU.edu"),
    (SELECT major_id FROM Majors WHERE major_name = "Finance")
),
(
    (SELECT student_id FROM Students WHERE email = "sydneyr@FauxSU.edu"),
    (SELECT major_id FROM Majors WHERE major_name = "Physics")
),
(
    (SELECT student_id FROM Students WHERE email = "borstf@FauxSU.edu"),
    (SELECT major_id FROM Majors WHERE major_name = "History")
),
(
    (SELECT student_id FROM Students WHERE email = "thomask@FauxSU.edu"),
    (SELECT major_id FROM Majors WHERE major_name = "Finance")
);

-- INSERT DATA INTO STUDENT_SECTIONS INTERSECTION TABLE

INSERT INTO Students_Sections (
    student_id, section_id
)
VALUES
(
    (SELECT student_id FROM Students WHERE email = "thomask@FauxSU.edu"),
    (SELECT section_id FROM Sections WHERE section_id = 4)
),
(
    (SELECT student_id FROM Students WHERE email = "moftyd@FauxSU.edu"),
    (SELECT section_id FROM Sections WHERE section_id = 2)
),
(
    (SELECT student_id FROM Students WHERE email = "moftyd@FauxSU.edu"),
    (SELECT section_id FROM Sections WHERE section_id = 1)
),
(
    (SELECT student_id FROM Students WHERE email = "borstf@FauxSU.edu"),
    (SELECT section_id FROM Sections WHERE section_id = 2)
),
(
    (SELECT student_id FROM Students WHERE email = "borstf@FauxSU.edu"),
    (SELECT section_id FROM Sections WHERE section_id = 3)
);

-- TEST THAT TABLES WERE CREATED
DESCRIBE Courses;
DESCRIBE Sections;
DESCRIBE Instructors;
DESCRIBE Students;
DESCRIBE Majors;
DESCRIBE Students_Majors;
DESCRIBE Students_Sections;

-- TEST THAT THE DATA WAS INPUT CORRECTLY
SELECT * FROM Courses;
SELECT * FROM Sections;
SELECT * FROM Instructors;
SELECT * FROM Students;
SELECT * FROM Majors;
SELECT * FROM Students_Majors;
SELECT * FROM Students_Sections;

-- TURN ON COMMITS AND FOREIGN KEY CHECKS TO MINIMIZE IMPORT ERRORS
SET FOREIGN_KEY_CHECKS=1;
COMMIT;
