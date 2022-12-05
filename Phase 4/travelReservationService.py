from typing import Iterable
from application import app
from db import *
from flask import render_template, url_for, flash, redirect, request, jsonify
from forms import BookingForm, RegistrationForm, LoginForm, ReservationForm, ScheduleFlightForm, AddPropertyForm
from datetime import date

current_date = '1999-01-01'

username = ''
adminAccess = True
customerAccess = True
ownerAccess = True
registrationType = ''


def call_stored_procedure(procedure_name, args):
    args = ','.join(args)
    q = text("CALL {}({})".format(procedure_name, args))
    print(q)
    try:
        results = connection.execute(q)
        connection.execute('commit')
        result = results.first()[0]
        if result == 1:
            flash('Property Added Successfully!')
        return result
    except Exception as err:
        print("Something went wrong: {}".format(err))
        return None


def display_view(view_name):
    return connection.execute("SELECT * FROM {}".format(view_name))


#######################################################
# Main Pages
#######################################################
@app.route("/", methods=['GET', 'POST'])
@app.route("/home", methods=['GET', 'POST'])
def run_procedure():
    if request.method == 'POST':
        args = []
        for key in request.form:
            if key == 'procedure':
                procedure = request.form[key]
            else:
                if request.form[key] != '':
                    if request.form[key].isnumeric():
                        args.append(request.form[key])
                    else:
                        args.append('\''+request.form[key]+'\'')
        print(procedure)
        print(args)
        call_stored_procedure(procedure, args)

    return render_template("run_procedure.html")


#######################################################
# Views
#######################################################

@app.route("/view_owners")
def view_owners():
    tmp = display_view("display_owner_view")
    return render_template("view/view_owners.html", table_data=tmp, homebar=3, username=username,
                           pageSelect='view_owners', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)

@app.route("/view_employees")
def view_employees():
    tmp = display_view("display_employee_view")
    return render_template("view/view_employees.html", table_data=tmp, homebar=3, username=username,
                           pageSelect='view_employee', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)

@app.route("/view_pilots")
def view_pilots():
    tmp = display_view("display_pilot_view")
    return render_template("view/view_pilots.html", table_data=tmp, homebar=3, username=username,
                           pageSelect='view_pilots', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)
@app.route("/view_locations")
def view_locations():
    tmp = display_view("display_location_view")
    return render_template("view/view_locations.html", table_data=tmp, homebar=3, username=username,
                           pageSelect='view_locations', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)
@app.route("/view_ingredients")
def view_ingredients():
    tmp = display_view("display_ingredient_view")
    return render_template("view/view_ingredients.html", table_data=tmp, homebar=3, username=username,
                           pageSelect='view_ingredients', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)
@app.route("/view_services")
def view_services():
    tmp = display_view("display_service_view")
    return render_template("view/view_services.html", table_data=tmp, homebar=3, username=username,
                           pageSelect='view_services', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)




#######################################################
# Function Calls
#######################################################
def getCurrentDate():
    global current_date
    current_date = date.today()
    print(current_date)
    return current_date


#######################################################
# Run App
#######################################################
getCurrentDate()

if __name__ == '__main__':
    app.run(debug=True)
