# ----------------------Sources Cited ------------------------------#
'''
Scope: Most of the routes and their subsequent functions were inspired 
by the starter code. Connecting to the database was also followed
step by step and other imports on the app.py page.

Originality: We used the following guide provided by the CS 340 staff
for the starter code to this project and built off of it. At the point
we are now, roughly 95% I would consider our own version of the 
starter and really tried to make it custom with the UI styling.

Dates utilized: 09/21/22 - 12/6/22

Source: https://github.com/osu-cs340-ecampus/flask-starter-app 
'''
# ------------------------------------------------------------------#


from flask import Flask, render_template, json, redirect, request
from flask_mysqldb import MySQL
import os
import database.db_connector as db

app = Flask(__name__)

# create a connection to database
db_connection = db.connect_to_database()
db_connection.ping(True)

# Routes
@app.route('/', methods=["POST", "GET"])
def index():
    return render_template("index.html", title='OSU Course Scheduler')

@app.route('/courses.html', methods=["POST", "GET"])
def courses():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Course")
        # grab user form inputs
        prefix = request.form["prefix"]
        code = request.form["code"]
        course_name = request.form["course_name"]
        description = request.form["description"]
        has_prereq = request.form["has_prereq"]
        lecture = request.form["lecture"]
        lab = request.form["lab"]
        credit_hour = request.form["credit_hour"]
        academic_level = request.form["academic_level"]

        # insert data from form into DB
        query1 = "INSERT INTO Courses (prefix, code, course_name, description, has_prereq, lecture, lab, credit_hour, academic_level) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
        cur = db_connection.cursor()
        cur.execute(query1, (prefix, code, course_name, description, has_prereq, lecture, lab, credit_hour, academic_level))
        db_connection.commit()

        # redirect back to courses page
        return redirect("/courses.html")

    if request.method == "GET":
        query = "SELECT course_id, prefix, code, course_name, description, CASE WHEN has_prereq = 0 THEN 'No' WHEN has_prereq = 1 THEN 'Yes' ELSE 'N/A' END AS has_prereq, CASE WHEN lecture = 0 THEN 'No' WHEN lecture = 1 THEN 'Yes' ELSE 'N/A' END AS lecture, CASE WHEN lab = 0 THEN 'No' WHEN lab = 1 THEN 'Yes' ELSE 'N/A' END AS lab, credit_hour, academic_level FROM Courses;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("courses.html", courses=results, title='Courses')

# pass the 'id' value of that course on button click (see HTML) via the route
@app.route("/delete_course/<int:id>")
def delete_course(id):
    # delete the row where the course_id matches
    query = "DELETE FROM Courses WHERE course_id = '%s';"
    cur = db_connection.cursor()
    cur.execute(query, (id,))
    db_connection.commit()

    # redirect back to courses page
    return redirect("/courses.html")

@app.route('/edit_course.html/<int:id>', methods=["POST", "GET"])
def edit_course(id):
    if request.method == "GET":
        # mySQL query to grab the info of the course with our passed id
        query = "SELECT * FROM Courses WHERE course_id = %s;" % (id)
        cur = db_connection.cursor()
        cur.execute(query)
        data = cur.fetchall()

        # render edit_course page passing our query data to the edit_course template
        return render_template("edit_course.html", data=data, title='Edit Course')
    
    # meat and potatoes of our update functionality
    if request.method == "POST":
        # fire off if user clicks the 'Edit Course' button
        request.form.get("Edit_Course")
        # grab user form inputs
        id = request.form["course_id"]
        prefix = request.form["prefix"]
        code = request.form["code"]
        course_name = request.form["course_name"]
        description = request.form["description"]
        has_prereq = request.form["has_prereq"]
        lecture = request.form["lecture"]
        lab = request.form["lab"]
        credit_hour = request.form["credit_hour"]
        academic_level = request.form["academic_level"]

        # no null inputs
        query = "UPDATE Courses SET Courses.prefix = %s, Courses.code = %s, Courses.course_name = %s, Courses.description = %s, Courses.has_prereq = %s, Courses.lecture = %s, Courses.lab = %s, Courses.credit_hour = %s, Courses.academic_level = %s WHERE Courses.course_id = %s;" 
        cur = db_connection.cursor()
        cur.execute(query, (prefix, code, course_name, description, has_prereq, lecture, lab, credit_hour, academic_level, id))
        db_connection.commit()

        # redirect back to people page after we execute the update query
        return redirect("/courses.html")

@app.route('/sections.html', methods=["POST", "GET"])
def sections():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Section")
        # grab user form inputs
        course_id = request.form["course_id"]
        instructor_id = request.form["instructor_id"]
        enrollment_cap = request.form["enrollment_cap"]

        # insert data from form into DB
        query1 = "INSERT INTO Sections (course_id, instructor_id, enrollment_cap) VALUES (%s, %s, %s)"
        cur = db_connection.cursor()
        cur.execute(query1, (course_id, instructor_id, enrollment_cap))
        db_connection.commit()

        # redirect back to courses page
        return redirect("/sections.html")

    if request.method == "GET":
        query = "SELECT s.section_id AS section_id, CONCAT(c.prefix, c.code, '-', s.section_id) AS section_code, c.course_name AS course_name, CONCAT(i.last_name, ', ', i.first_name) AS instructor_name, s.enrollment_cap AS enrollment_cap FROM Sections AS s INNER JOIN Courses AS c USING (course_id) LEFT JOIN Instructors AS i USING (instructor_id);"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()

        query2 = "SELECT course_id, CONCAT(prefix, code, ': ', course_name) AS course FROM Courses;"
        cursor2 = db.execute_query(db_connection=db_connection, query=query2)
        result2 = cursor2.fetchall()

        query3 = "SELECT instructor_id, CONCAT(last_name, ', ', first_name) AS instructor_name FROM Instructors;"
        cursor3 = db.execute_query(db_connection=db_connection, query=query3)
        result3 = cursor3.fetchall()

        return render_template("sections.html", sections=results, courses=result2, instructors=result3, title='Sections')

# pass the 'id' value of that section on button click (see HTML) via the route
@app.route("/delete_section/<int:id>")
def delete_section(id):
    # delete the row where the section_id matches
    query = "DELETE FROM Sections WHERE section_id = '%s';"
    cur = db_connection.cursor()
    cur.execute(query, (id,))
    db_connection.commit()

    # redirect back to sections page
    return redirect("/sections.html")

@app.route('/edit_section.html/<int:id>', methods=["POST", "GET"])
def edit_section(id):
    if request.method == "GET":
        # mySQL query to grab the info of the section with our passed id
        query = "SELECT * FROM Sections WHERE section_id = %s;" % (id)
        cur = db_connection.cursor()
        cur.execute(query)
        data = cur.fetchall()

        # render edit_course page passing our query data to the edit_course template
        return render_template("edit_section.html", data=data, title='Edit Section')
    
    # meat and potatoes of our update functionality
    if request.method == "POST":
        # fire off if user clicks the 'Edit Section' button
        request.form.get("Edit_Section")
        # grab user form inputs
        id = request.form["section_id"]
        course_id = request.form["course_id"]
        instructor_id = request.form["instructor_id"]
        enrollment_cap = request.form["enrollment_cap"]
       
        # no null inputs
        query = "UPDATE Sections SET Sections.course_id = %s, Sections.instructor_id = %s, Sections.enrollment_cap = %s WHERE Sections.section_id = %s;" 
        cur = db_connection.cursor()
        cur.execute(query, (course_id, instructor_id, enrollment_cap, id))
        db_connection.commit()

        # redirect back to sections page after we execute the update query
        return redirect("/sections.html")

    # redirect back to courses page
    return redirect("/sections.html")

@app.route('/instructors.html', methods=["POST", "GET"])
def instructors():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Instructor")
        # grab user form inputs
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        email = request.form["email"]
        phone_number = request.form["phone_number"]
        address = request.form["address"]

        # insert data from form into DB
        query1 = "INSERT INTO Instructors (first_name, last_name, email, phone_number, address) VALUES (%s, %s, %s, %s, %s)"
        cur = db_connection.cursor()
        cur.execute(query1, (first_name, last_name, email, phone_number, address))
        db_connection.commit()

        # redirect back to courses page
        return redirect("/instructors.html")

    if request.method == "GET":
        query = "SELECT * FROM Instructors;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("instructors.html", instructors=results, title='Instructors')

# pass the 'id' value of that instructor on button click (see HTML) via the route
@app.route("/delete_instructor/<int:id>")
def delete_instructor(id):
    # delete the row where the instructor_id matches
    query = "DELETE FROM Instructors WHERE instructor_id = '%s';"
    cur = db_connection.cursor()
    cur.execute(query, (id,))
    db_connection.commit()

    # redirect back to courses page
    return redirect("/instructors.html")

@app.route('/edit_instructor.html/<int:id>', methods=["POST", "GET"])
def edit_instructor(id):
    if request.method == "GET":
        # mySQL query to grab the info of the course with our passed id
        query = "SELECT * FROM Instructors WHERE instructor_id = %s;" % (id)
        cur = db_connection.cursor()
        cur.execute(query)
        data = cur.fetchall()

        # render edit_course page passing our query data to the edit_course template
        return render_template("edit_instructor.html", data=data, title='Edit Instructor')
    
    # meat and potatoes of our update functionality
    if request.method == "POST":
        # fire off if user clicks the 'Edit Instructors' button
        request.form.get("Edit_Instructor")
        # grab user form inputs
        id = request.form["instructor_id"]
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        email = request.form["email"]
        phone_number = request.form["phone_number"]
        address = request.form["address"]

        # no null inputs
        query = "UPDATE Instructors SET Instructors.first_name = %s, Instructors.last_name = %s, Instructors.email = %s, Instructors.phone_number = %s, Instructors.address = %s WHERE Instructors.instructor_id = %s;" 
        cur = db_connection.cursor()
        cur.execute(query, (first_name, last_name, email, phone_number, address, id))
        db_connection.commit()

        # redirect back to instructors page after we execute the update query
        return redirect("/instructors.html")

    # redirect back to courses page
    return redirect("/instructors.html")

@app.route('/students.html', methods=["POST", "GET"])
def students():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Students")
        # grab user form inputs
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        email = request.form["email"]
        phone_number = request.form["phone_number"]
        address = request.form["address"]

        # insert data from form into DB
        query2 = "INSERT INTO Students (first_name, last_name, email, phone_number, address) VALUES (%s, %s, %s, %s, %s)"
        cur = db_connection.cursor()
        cur.execute(query2, (first_name, last_name, email, phone_number, address))
        db_connection.commit()

        # redirect back to courses page
        return redirect("/students.html")

    if request.method == "GET":
        query = "SELECT * FROM Students;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("students.html", students=results, title='Students')

@app.route('/edit_student.html/<int:id>', methods=["POST", "GET"])
def edit_student(id):
    if request.method == "GET":
        # mySQL query to grab the info of the student with our passed id
        query = "SELECT * FROM Students WHERE student_id = %s;" % (id)
        cur = db_connection.cursor()
        cur.execute(query)
        data = cur.fetchall()

        # render edit_course page passing our query data to the edit_course template
        return render_template("edit_student.html", data=data, title='Edit Student')
    
    # meat and potatoes of our update functionality
    if request.method == "POST":
        # fire off if user clicks the 'Edit Student' button
        request.form.get("Edit_Student")
        # grab user form inputs
        id = request.form["student_id"]
        degree_type = request.form["degree_type"]
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        email = request.form["email"]
        phone_number = request.form["phone_number"]
        address = request.form["address"]

        # no null inputs
        query = "UPDATE Students SET Students.first_name = %s, Students.last_name = %s, Students.email = %s, Students.phone_number = %s, Students.address = %s WHERE Students.student_id = %s;" 
        cur = db_connection.cursor()
        cur.execute(query, (first_name, last_name, email, phone_number, address, id))
        db_connection.commit()

        # redirect back to students page after we execute the update query
        return redirect("/students.html")

    # redirect back to courses page
    return redirect("/students.html")

@app.route('/majors.html', methods=["POST", "GET"])
def majors():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Major")
        # grab user form inputs
        major_name = request.form["major_name"]
        abbreviation = request.form["abbreviation"]
        description = request.form["description"]

        # insert data from form into DB
        query1 = "INSERT INTO Majors (major_name, abbreviation, description) VALUES (%s, %s, %s)"
        cur = db_connection.cursor()
        cur.execute(query1, (major_name, abbreviation, description))
        db_connection.commit()

        # redirect back to courses page
        return redirect("/majors.html")

    if request.method == "GET":
        query = "SELECT * FROM Majors;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("majors.html", majors=results, title='Majors')

@app.route('/edit_major.html/<int:id>', methods=["POST", "GET"])
def edit_major(id):
    if request.method == "GET":
        # mySQL query to grab the info of the major with our passed id
        query = "SELECT * FROM Majors WHERE major_id = %s;" % (id)
        cur = db_connection.cursor()
        cur.execute(query)
        data = cur.fetchall()

        # render edit_major page passing our query data to the edit_major template
        return render_template("edit_major.html", data=data, title='Edit Major')
    
    # meat and potatoes of our update functionality
    if request.method == "POST":
        # fire off if user clicks the 'Edit Major' button
        request.form.get("Edit_Major")
        # grab user form inputs
        id = request.form["major_id"]
        major_name = request.form["major_name"]
        abbreviation = request.form["abbreviation"]
        description = request.form["description"]
       
        # no null inputs
        query = "UPDATE Majors SET Majors.major_name = %s, Majors.abbreviation = %s, Majors.description = %s WHERE Majors.major_id = %s;" 
        cur = db_connection.cursor()
        cur.execute(query, (major_name, abbreviation, description, id))
        db_connection.commit()

        # redirect back to majors page after we execute the update query
        return redirect("/majors.html")

    # redirect back to majors page
    return redirect("/majors.html")

@app.route('/students_majors.html', methods=["POST", "GET"])
def students_majors():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Students_Majors")
        # grab user form inputs
        student_id = request.form["student_id"]
        major_id = request.form["major_id"]

        # insert data from form into DB
        query1 = "INSERT INTO Students_Majors (student_id, major_id) VALUES (%s, %s)"
        cur = db_connection.cursor()
        cur.execute(query1, (student_id, major_id))
        db_connection.commit()

        # redirect back to students_majors page
        return redirect("/students_majors.html")

    if request.method == "GET":
        query = "SELECT sm.declaration_id AS declaration_id, CONCAT(st.last_name, ', ', st.first_name) AS student, CONCAT (m.major_name, ' (', m.abbreviation, ')') AS major FROM Students_Majors AS sm INNER JOIN Students AS st USING (student_id) INNER JOIN Majors AS m USING (major_id);"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()

        query2 = "SELECT student_id, CONCAT(last_name, ', ', first_name) AS student_name FROM Students;"
        cursor2 = db.execute_query(db_connection=db_connection, query=query2)
        result2 = cursor2.fetchall()

        query3 = "SELECT major_id, CONCAT(major_name, ' (', abbreviation, ')') AS major_name FROM Majors;"
        cursor3 = db.execute_query(db_connection=db_connection, query=query3)
        result3 = cursor3.fetchall()

        return render_template("students_majors.html", students_majors=results, students=result2, majors=result3, title='Students Majors')

# pass the 'id' value of that students_majors on button click (see HTML) via the route
@app.route("/delete_students_majors/<int:id>")
def delete_students_majors(id):
    # delete the row where the declaration_id matches
    query = "DELETE FROM Students_Majors WHERE declaration_id = '%s';"
    cur = db_connection.cursor()
    cur.execute(query, (id,))
    db_connection.commit()

    # redirect back to students_majors page
    return redirect("/students_majors.html")

@app.route('/students_sections.html', methods=["POST", "GET"])
def students_sections():
    if request.method == "POST":
        # fire off if user presses the Add button
        request.form.get("Add_Students_Sections")
        # grab user form inputs
        student_id = request.form["student_id"]
        section_id = request.form["section_id"]

        # insert data from form into DB
        query1 = "INSERT INTO Students_Sections (student_id, section_id) VALUES (%s, %s)"
        cur = db_connection.cursor()
        cur.execute(query1, (student_id, section_id))
        db_connection.commit()

        # redirect back to students_sections page
        return redirect("/students_sections.html")

    if request.method == "GET":
        query = "SELECT ss.enrollment_id AS enrollment_id, CONCAT(st.last_name, ', ', st.first_name) AS student_name, CONCAT(c.prefix, c.code, '-', se.section_id) AS section_code FROM Students_Sections AS ss INNER JOIN Students AS st USING (student_id) INNER JOIN Sections AS se USING (section_id) INNER JOIN Courses AS c USING (course_id);"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()

        query2 = "SELECT student_id, CONCAT(last_name, ', ', first_name) AS student_name FROM Students;"
        cursor2 = db.execute_query(db_connection=db_connection, query=query2)
        result2 = cursor2.fetchall()

        query3 = "SELECT s.section_id AS section_id, CONCAT(c.prefix, c.code, '-', s.section_id) AS section FROM Sections AS s INNER JOIN Courses AS c USING (course_id);"
        cursor3 = db.execute_query(db_connection=db_connection, query=query3)
        result3 = cursor3.fetchall()

        return render_template("students_sections.html", students_sections=results, students=result2, sections=result3, title='Students Sections')

# pass the 'id' value of that students_sections on button click (see HTML) via the route
@app.route("/delete_students_sections/<int:id>")
def delete_students_sections(id):
    # delete the row where the declaration_id matches
    query = "DELETE FROM Students_Sections WHERE enrollment_id = '%s';"
    cur = db_connection.cursor()
    cur.execute(query, (id,))
    db_connection.commit()

    # redirect back to students_sections page
    return redirect("/students_sections.html")


# Listener
if __name__ == "__main__":

    #Start the app on port 3000, it will be different once hosted
    app.run(port=45111, debug=True)


# run on flip1 server:
# gunicorn -w 4 -b 0.0.0.0:45111 -D wsgi:app -D

# restart:
# pkill -u burdetbe gunicorn

# activate virtual environment
# source ./venv/bin/activate

# deactivate the virtual environment
# deactivate