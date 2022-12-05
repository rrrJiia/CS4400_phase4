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
    try:
        ret = cursor.callproc(procedure_name, args)
        raw_connection.commit()
        return ret
    except Exception as err:
        print("Something went wrong: {}".format(err))
        return None


def display_view(view_name):
    return connection.execute("SELECT * FROM {}".format(view_name))


#######################################################
# Main Pages
#######################################################
@app.route("/")
@app.route("/home")
def home():
    return render_template("account.html", current_date=current_date, homebar=2, username=username,
                           adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)


@app.route("/about")
def about():
    return render_template("about.html", homebar=1, username=username)


@app.route("/account")
def account():
    if username == '':
        return redirect(url_for('home'))
    q = text(
        "SELECT A.Email as Email, First_Name, Last_Name, Pass, Phone_Number, CcNumber, Cvv, Exp_date, Location FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN customer AS K ON C.Email = K.Email WHERE A.Email=\'{0}\'".format(
            username))
    userdata = connection.execute(q)
    return render_template("account.html", userdata=userdata, current_date=current_date, homebar=2, username=username,
                           adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)


@app.route("/login", methods=['GET', 'POST'])
def login():
    global username
    if username != "":
        return redirect(url_for('account'))
    global adminAccess
    global ownerAccess
    global customerAccess
    form = LoginForm()
    if form.validate_on_submit():
        email = form.email.data
        password = form.password.data
        q = text("SELECT * FROM accounts WHERE Email=\'{0}\' AND Pass=\'{1}\'".format(email, password))
        result = connection.execute(q)
        if result.rowcount != 0:
            q = text("SELECT * FROM admins WHERE Email=\'{0}\'".format(email))
            result = connection.execute(q)
            adminAccess = True if result.rowcount != 0 else False
            q = text("SELECT * FROM owners WHERE Email=\'{0}\'".format(email))
            result = connection.execute(q)
            ownerAccess = True if result.rowcount != 0 else False
            q = text("SELECT * FROM customer WHERE Email=\'{0}\'".format(email))
            result = connection.execute(q)
            customerAccess = True if result.rowcount != 0 else False
            username = email
            return redirect(url_for('account'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')
    return render_template("login.html", homebar=-1, username=username, form=form)


@app.route("/register", methods=['GET', 'POST'])
def register():
    global registrationType
    if registrationType == '':
        registrationType = 'customer'
    form = RegistrationForm()
    if form.validate_on_submit():
        email = request.form['email']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        password = request.form['password']
        phone_number = request.form['phone_number']
        card = request.form['card']
        cvv = request.form['cvv']
        exp = request.form['exp']
        location = request.form['location']
        if registrationType == 'customer':
            if card and cvv and exp and location:
                q = text(
                    "call register_customer(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\',\'{6}\',\'{7}\',\'{8}\')".format(
                        email, first_name, last_name, password, phone_number, card, cvv, exp, location))
            else:
                flash('Not all fields filled out!')
                registrationType = ''
                return redirect(url_for('register'))
        elif registrationType == 'owner':
            q = text(
                "call register_owner(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\')".format(email, first_name, last_name,
                                                                                          password, phone_number))
        else:
            flash('Something went wrong :(')
            return redirect(url_for('register'))
        try:
            results = connection.execute(q)
            connection.execute('commit')
            result = results.first()[0]
            if result == 1:
                flash(f'{registrationType} account created for {form.email.data}! Please login.')
                registrationType = ''
                return redirect(url_for('login'))
            else:
                flash(str(result))
        except Exception as e:
            flash(e)
    else:
        flash('Please enter valid info.')
    registrationType = ''
    return render_template("register.html", homebar=-1, username=username, form=form)


#######################################################
# Customer Access
#######################################################
@app.route("/my_bookings")
def my_bookings():
    if not customerAccess:
        return redirect(url_for('account'))
    q = text(
        'SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND ((Flight_Date < \'{1}\') OR (Flight_Date = \'{1}\' AND Was_Cancelled = 1))'.format(
            username, current_date))
    past_bookings = connection.execute(q)
    q = text(
        'SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND Flight_Date = \'{1}\' AND Was_Cancelled = 0'.format(
            username, current_date))
    today_bookings = connection.execute(q)
    q = text('SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND Flight_Date > \'{1}\''.format(username,
                                                                                                              current_date))
    future_bookings = connection.execute(q)
    return render_template("customer/my_bookings.html", past_bookings=past_bookings, today_bookings=today_bookings,
                           future_bookings=future_bookings, homebar=3, username=username, pageSelect='my_bookings',
                           adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)


@app.route("/my_reservations")
def my_reservations():
    if not customerAccess:
        return redirect(url_for('account'))
    q = text(
        "SELECT * FROM customers_rate_owners AS O RIGHT OUTER JOIN reserve AS R ON R.Owner_Email = O.Owner_Email AND R.Customer = O.Customer LEFT OUTER JOIN property AS P ON R.Owner_Email = P.Owner_Email AND R.Property_Name = P.Property_Name WHERE R.Customer=\'{0}\' AND ((End_Date < \'{1}\') OR (\'{1}\' BETWEEN Start_Date AND End_Date AND Was_Cancelled = 1))".format(
            username, current_date))
    past_reservations = connection.execute(q)
    q = text(
        "SELECT * FROM customers_rate_owners AS O RIGHT OUTER JOIN reserve AS R ON R.Owner_Email = O.Owner_Email AND R.Customer = O.Customer LEFT OUTER JOIN property AS P ON R.Owner_Email = P.Owner_Email AND R.Property_Name = P.Property_Name WHERE R.Customer=\'{0}\' AND \'{1}\' BETWEEN Start_Date AND End_Date AND Was_Cancelled = 0".format(
            username, current_date))
    current_reservation = connection.execute(q)
    q = text(
        "SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND Start_Date > \'{1}\'".format(username,
                                                                                                             current_date))
    future_reservations = connection.execute(q)
    return render_template("customer/my_reservations.html", past_reservations=past_reservations,
                           current_reservation=current_reservation, future_reservations=future_reservations, homebar=3,
                           username=username, pageSelect='my_reservations', adminAccess=adminAccess,
                           customerAccess=customerAccess, ownerAccess=ownerAccess)


@app.route("/book")
def book():
    if not customerAccess:
        return redirect(url_for('account'))
    q = text(
        "SELECT * FROM view_flight AS V JOIN flight AS F ON airline=Airline_Name AND flight_id=Flight_Num WHERE F.Flight_Date > \'{0}\'".format(
            current_date))
    flight_view = connection.execute(q)
    return render_template("customer/book.html", table_data=flight_view, homebar=3, username=username,
                           pageSelect='book', adminAccess=adminAccess, customerAccess=customerAccess,
                           ownerAccess=ownerAccess)


@app.route("/reserve")
def reserve():
    if not customerAccess:
        return redirect(url_for('account'))
    start = ""
    end = ""
    guests = ""
    try:
        start = request.args['start_intr']
        end = request.args['end_intr']
        guests = request.args['desired_guests']
        if (start != "" and end != "" and guests != ""):
            q = text(
                "SELECT * FROM view_properties WHERE capacity_check(Property_Name, Owner_Email, \'{0}\', \'{1}\', {2})".format(
                    start, end, guests))
        else:
            raise KeyError()
    except KeyError:
        q = text("SELECT * FROM view_properties")
    property_view = connection.execute(q)
    return render_template("customer/reserve.html", start=start, end=end, guests=guests, table_data=property_view,
                           homebar=3, username=username, pageSelect='reserve', adminAccess=adminAccess,
                           customerAccess=customerAccess, ownerAccess=ownerAccess)


#######################################################
# Owner Access
#######################################################
@app.route("/my_properties", methods=['GET', 'POST'])
def my_properties():
    if not ownerAccess:
        return redirect(url_for('account'))
    form = AddPropertyForm()
    state_names = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY',
                   'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND',
                   'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY', 'DC',
                   'AS', 'GU', 'MP', 'PR', 'UM', 'VI']
    form.state.choices = [states for states in state_names]
    if request.method == 'POST':
        if form.validate_on_submit():
            property_name = request.form['property_name']
            description = request.form['description']
            capacity = request.form['capacity']
            cost = request.form['cost']
            street = request.form['street']
            city = request.form['city']
            state = request.form['state']
            zipcode = request.form['zipcode']
            nearest_airport_id = request.form['nearest_airport_id']
            dist_to_airport = request.form['dist_to_airport']
            if nearest_airport_id:
                if not dist_to_airport:
                    flash('Please enter the distance to the nearest airport.')
                    return redirect(url_for('my_properties'))
                else:
                    q = text(
                        "CALL add_property(\'{0}\', \'{1}\', \'{2}\', {3}, {4}, \'{5}\', \'{6}\', \'{7}\', \'{8}\', \'{9}\', {10})".format(
                            property_name, username, description, capacity, cost, street, city, state, zipcode,
                            nearest_airport_id, dist_to_airport))
            else:
                q = text(
                    "CALL add_property(\'{0}\', \'{1}\', \'{2}\', {3}, {4}, \'{5}\', \'{6}\', \'{7}\', \'{8}\', null, null)".format(
                        property_name, username, description, capacity, cost, street, city, state, zipcode))
            try:
                results = connection.execute(q)
                connection.execute('commit')
                result = results.first()[0]
                if result == 1:
                    flash('Property Added Successfully!')
                    return redirect(url_for('my_properties'))
                else:
                    flash(str(result))
            except Exception as e:
                flash(e)
        else:
            flash('Please enter valid info.')
            print(form.errors)
    q = text("SELECT * FROM view_properties NATURAL JOIN property WHERE Owner_Email=\'{0}\'".format(username))
    properties_view = connection.execute(q)
    return render_template("owner/my_properties.html", form=form, table_data=properties_view, homebar=3,
                           username=username, pageSelect='my_properties', adminAccess=adminAccess,
                           customerAccess=customerAccess, ownerAccess=ownerAccess)


#######################################################
# Administrative Access
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
# Popup Boxes
#######################################################
@app.route("/flight_details", methods=['GET', 'POST'])
def flight_details():
    if request.method == 'POST':
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        timekeeper = request.form['timekeeper']
        tableType = request.form['tableType']
        q = text(
            "SELECT * FROM flight JOIN view_flight ON Flight_Num=flight_id AND Airline_Name=airline WHERE Airline_Name = \'{0}\' AND Flight_Num = {1}".format(
                airline_name, flight_num))
        flightDetails = connection.execute(q)
        removable = True if "Future" in timekeeper else False
    else:
        return redirect(url_for('view_flights'))
    return jsonify({'htmlresponse': render_template('popups/flight_details.html', removable=removable,
                                                    table_data=flightDetails, tableType=tableType)})


@app.route("/booking_details", methods=['GET', 'POST'])
def booking_details():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text(
            "SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND Airline_Name=\'{1}\' AND Flight_Num=\'{2}\'".format(
                customer_id, airline_name, flight_num))
        bookingDetails = connection.execute(q)
    else:
        return redirect(url_for('my_bookings'))
    return jsonify(
        {'htmlresponse': render_template('popups/flight_details.html', table_data=bookingDetails, tableType='1')})


@app.route("/reservation_details", methods=['GET', 'POST'])
def reservation_details():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        tableType = 2
        if request.form['viewType'] == '1':
            tableType = 1
        elif request.form['viewType'] == '3':
            tableType = 3
        else:
            tableType = 2
        q = text(
            "SELECT * FROM review AS O RIGHT OUTER JOIN reserve AS R ON R.Customer = O.Customer AND R.Owner_Email = O.Owner_Email AND R.Property_Name = O.Property_Name JOIN property AS P ON R.Property_Name = P.Property_Name AND R.Owner_Email = P.Owner_Email WHERE R.Customer=\'{0}\' AND R.Property_Name=\'{1}\' AND R.Owner_Email=\'{2}\'".format(
                customer_id, property_name, owner_id))
        reservationDetails = connection.execute(q)
        q = text("SELECT * FROM amenity WHERE Property_Name=\'{0}\' AND Property_Owner=\'{1}\'".format(property_name,
                                                                                                       owner_id))
        property_amenities = connection.execute(q)
        q = text("SELECT * FROM is_close_to WHERE Property_Name=\'{0}\' AND Owner_Email=\'{1}\'".format(property_name,
                                                                                                        owner_id))
        near_airport = connection.execute(q)
    else:
        return redirect(url_for('my_reservations'))
    return jsonify({'htmlresponse': render_template('popups/property_details.html',
                                                    property_amenities=property_amenities, near_airport=near_airport,
                                                    table_data=reservationDetails, tableType=tableType)})


@app.route("/property_details", methods=['GET', 'POST'])
def property_details():
    if request.method == 'POST':
        owner_id = request.form['owner_id']
        property_name = request.form['property_name']
        tableType = 0 if request.form['viewType'] == '0' else 2
        q = text("CALL view_individual_property_reservations(\'{0}\', \'{1}\')".format(property_name, owner_id))
        connection.execute(q)
        connection.execute('commit')
        q = text(
            "SELECT * FROM property NATURAL JOIN view_properties WHERE Property_Name=\'{0}\' AND Owner_Email=\'{1}\'".format(
                property_name, owner_id))
        propertyDetails = connection.execute(q)
        q = text(
            "SELECT * FROM view_individual_property_reservations NATURAL JOIN reserve LEFT OUTER JOIN owners_rate_customers AS R ON customer_email = R.Customer WHERE Was_Cancelled = 0 AND End_Date < \'{0}\'".format(
                current_date))
        table_data_past = connection.execute(q)
        q = text(
            "SELECT * FROM view_individual_property_reservations NATURAL JOIN reserve WHERE Was_Cancelled = 0 AND \'{0}\' BETWEEN Start_Date AND End_Date".format(
                current_date))
        table_data_current = connection.execute(q)
        q = text(
            "SELECT * FROM view_individual_property_reservations NATURAL JOIN reserve WHERE Was_Cancelled = 0 AND Start_Date > \'{0}\'".format(
                current_date))
        table_data_future = connection.execute(q)
        q = text("SELECT * FROM amenity WHERE Property_Name=\'{0}\' AND Property_Owner=\'{1}\'".format(property_name,
                                                                                                       owner_id))
        property_amenities = connection.execute(q)
        q = text("SELECT * FROM is_close_to WHERE Property_Name=\'{0}\' AND Owner_Email=\'{1}\'".format(property_name,
                                                                                                        owner_id))
        near_airport = connection.execute(q)
    else:
        return redirect(url_for('my_reservations'))
    return jsonify({'htmlresponse': render_template('popups/property_details.html',
                                                    property_amenities=property_amenities, near_airport=near_airport,
                                                    table_data=propertyDetails, table_data_past=table_data_past,
                                                    table_data_current=table_data_current,
                                                    table_data_future=table_data_future, tableType=tableType)})


@app.route("/reserve_form", methods=['GET', 'POST'])
def reserve_property():
    if request.method == 'GET':
        form = ReservationForm()
        form.owner_email.data = request.args['owner_id']
        form.property_name.data = request.args['property_name']
        form.current_date.data = current_date
        form.customer_email.data = username

        q = text("SELECT cost FROM property WHERE Property_Name = \'{}\' AND Owner_Email = \'{}\'".format(
            request.args['property_name'], request.args['owner_id']
        ))
        cost = [row[0] for row in connection.execute(q)][0]

        return jsonify({'htmlresponse': render_template('popups/reserve_form.html', form=form, cost=cost)})
    elif request.method == 'POST':
        property_name = request.form['property_name']
        owner_email = request.form['owner_email']
        customer_email = username
        start_date = request.form['start_date']
        end_date = request.form['end_date']
        num_guests = request.form['num_guests']

        q = text("CALL reserve_property(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', \'{6}\')".format(
            property_name, owner_email, customer_email, start_date, end_date, num_guests, current_date
        ))
        connection.execute(q)
        connection.execute('commit')
        return redirect(url_for('reserve'))

    else:
        return redirect(url_for('reserve'))


@app.route("/book_form", methods=['GET', 'POST'])
def book_flight():
    if request.method == 'GET':
        form = BookingForm()
        form.airline_name.data = request.args['airline_name']
        form.flight_num.data = request.args['flight_num']
        form.current_date.data = current_date
        form.customer_email.data = username

        q = text("SELECT cost FROM flight WHERE Airline_Name = \'{0}\' AND Flight_Num = \'{1}\'".format(
            request.args['airline_name'], request.args['flight_num']
        ))
        cost = [row[0] for row in connection.execute(q)][0]
        return jsonify({'htmlresponse': render_template('popups/book_form.html', form=form, cost=cost)})

    elif request.method == 'POST':
        customer_email = username
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        num_seats = request.form['num_seats']

        q = text("CALL book_flight(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\')".format(
            customer_email, flight_num, airline_name, num_seats, current_date
        ))
        connection.execute(q)
        connection.execute('commit')
        return redirect(url_for('book'))

    else:
        return redirect(url_for('book'))


#######################################################
# Function Calls
#######################################################
def getCurrentDate():
    global current_date
    current_date = date.today()
    print(current_date)
    return current_date


@app.route("/logout")
def logout():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    username = ''
    adminAccess = False
    ownerAccess = False
    customerAccess = False
    return redirect(url_for('home'))


@app.route("/set_system_date", methods=['GET', 'POST'])
def set_system_date():
    global current_date
    if request.method == 'POST':
        desired_date = request.form['set_date']
        q = text("CALL process_date(\'{0}\')".format(desired_date))
        connection.execute(q)
        connection.execute('commit')
        current_date = desired_date
    return redirect(url_for('account'))


@app.route("/remove_flight", methods=['GET', 'POST'])
def remove_flight():
    if request.method == 'POST':
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text("CALL remove_flight({0}, \'{1}\', \'{2}\')".format(flight_num, airline_name, current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('view_flights'))


@app.route("/cancel_booking", methods=['GET', 'POST'])
def cancel_booking():
    if request.method == 'POST':
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text("CALL cancel_flight_booking(\'{0}\', {1}, \'{2}\', \'{3}\')".format(username, flight_num, airline_name,
                                                                                     current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('my_bookings'))


@app.route("/cancel_reservation", methods=['GET', 'POST'])
def cancel_reservation():
    if request.method == 'POST':
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        customer_id = request.form['customer_id']
        q = text("CALL cancel_property_reservation(\'{0}\', \'{1}\', \'{2}\', \'{3}\')".format(property_name, owner_id,
                                                                                               customer_id,
                                                                                               current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('my_reservations'))


@app.route("/remove_property", methods=['GET', 'POST'])
def remove_property():
    if request.method == 'POST':
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        q = text("CALL remove_property(\'{0}\', \'{1}\', \'{2}\')".format(property_name, owner_id, current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('my_properties'))


@app.route("/owner_rates_customer", methods=['GET', 'POST'])
def owner_rates_customer():
    if request.method == 'POST':
        owner_id = request.form['owner_id']
        customer_id = request.form['customer_id']
        rating = request.form['rating']
        q = text("CALL owner_rates_customer(\'{0}\', \'{1}\', {2}, \'{3}\')".format(owner_id, customer_id, rating,
                                                                                    current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('my_properties'))


@app.route("/customer_rates_owner", methods=['GET', 'POST'])
def customer_rates_owner():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        owner_id = request.form['owner_id']
        rating = request.form['rating']
        q = text("CALL customer_rates_owner(\'{0}\', \'{1}\', {2}, \'{3}\')".format(customer_id, owner_id, rating,
                                                                                    current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('my_reservations'))


@app.route("/customer_review_property", methods=['GET', 'POST'])
def customer_review_property():
    if request.method == 'POST':
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        customer_id = request.form['customer_id']
        content = request.form['content']
        rating = request.form['rating']
        q = text("CALL customer_review_property(\'{0}\', \'{1}\', \'{2}\', \'{3}\', {4}, \'{5}\')".format(property_name,
                                                                                                          owner_id,
                                                                                                          customer_id,
                                                                                                          content,
                                                                                                          rating,
                                                                                                          current_date))
        connection.execute(q)
        connection.execute('commit')
    return redirect(url_for('my_reservations'))


@app.route("/remove_owner", methods=['GET', 'POST'])
def remove_owner():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    q = text("CALL remove_owner(\'{0}\')".format(username))
    try:
        results = connection.execute(q)
        connection.execute('commit')
        result = results.first()[0]
        if result == 1:
            flash('Owner\'s account has been removed.')
            messages1 = 'Owner\'s account has been removed.'
        else:
            flash(str(result))
            messages1 = str(result)
            return redirect(url_for('account'), messages1)
    except Exception as e:
        flash(e)
        messages1 = str(e)
        return redirect(url_for('account'), messages1)
    q = text("SELECT * FROM accounts WHERE Email=\'{0}\'".format(username))
    result = connection.execute(q)
    if result.rowcount != 0:
        q = text("SELECT * FROM admins WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        adminAccess = True if result.rowcount != 0 else False
        q = text("SELECT * FROM owners WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        ownerAccess = True if result.rowcount != 0 else False
        q = text("SELECT * FROM customer WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        customerAccess = True if result.rowcount != 0 else False
        return redirect(url_for('account'), messages1)
    else:
        username = ''
        adminAccess = False
        ownerAccess = False
        customerAccess = False
    return redirect(url_for('home'))


@app.route("/register_owner")
def register_owner():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    if not customerAccess:
        return redirect(url_for('register'))
    q = text("SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email=C.Email WHERE A.Email=\'{0}\'".format(
        username))
    result = connection.execute(q)
    for row in result:
        q = text("CALL register_owner(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\')".format(username, row.First_Name,
                                                                                           row.Last_Name, row.Pass,
                                                                                           row.Phone_Number))
        result = connection.execute(q)
        connection.execute('commit')
    q = text("SELECT * FROM accounts WHERE Email=\'{0}\'".format(username))
    result = connection.execute(q)
    if result.rowcount != 0:
        q = text("SELECT * FROM admins WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        adminAccess = True if result.rowcount != 0 else False
        q = text("SELECT * FROM owners WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        ownerAccess = True if result.rowcount != 0 else False
        q = text("SELECT * FROM customer WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        customerAccess = True if result.rowcount != 0 else False
        return redirect(url_for('account'))
    else:
        username = ''
        adminAccess = False
        ownerAccess = False
        customerAccess = False
    return redirect(url_for('home'))


@app.route("/set_registration_type", methods=['GET', 'POST'])
def set_registration_type():
    global registrationType
    registrationType = request.form['registrationType']
    return 'success'


#######################################################
# Testing
#######################################################
@app.route("/testing", methods=['GET', 'POST'])
def testing():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    username = 'webadmin@gmail.com'
    adminAccess = True
    ownerAccess = True
    customerAccess = True
    return redirect(url_for('account'))


#######################################################
# Run App
#######################################################
getCurrentDate()

if __name__ == '__main__':
    app.run(debug=True)
