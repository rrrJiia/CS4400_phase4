from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, DateField, DecimalField, IntegerField, SelectField, TextAreaField
from wtforms.fields.datetime import TimeField
from wtforms.validators import DataRequired, Length, Email, EqualTo, Optional
from datetime import datetime


class RegistrationForm(FlaskForm):
    first_name = StringField('First Name', validators=[DataRequired(), Length(max=50)])
    last_name = StringField('Last Name', validators=[DataRequired(), Length(max=50)])
    email = StringField('Email', validators=[DataRequired(), Email(), Length(max=50)])
    password = PasswordField('Password', validators=[DataRequired(), Length(max=50)])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    phone_number = StringField('Phone Number', validators=[DataRequired(), Length(12)])
    card = StringField('Credit Card Number', validators=[Optional(), Length(19)])
    cvv = StringField('CVV', validators=[Optional(), Length(3)])
    exp = DateField('Expiration Date', format='%Y-%m-%d', default = datetime.today())
    location = StringField('Location', validators=[Optional(), Length(max=50)])
    submit = SubmitField('Register')

class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class ScheduleFlightForm(FlaskForm):
    flight_num = StringField('Flight Number', validators=[DataRequired(), Length(max=5)])
    airline_name = SelectField('Airline Name', validators=[DataRequired(), Length(max=50)])
    from_airport = StringField('From Airport', validators=[DataRequired(), Length(3)])
    to_airport = StringField('To Airport', validators=[DataRequired(), Length(3)])
    departure_time = TimeField('Departure Time', format='%H:%M', validators=[DataRequired()])
    arrival_time = TimeField('Arrival Time', format='%H:%M', validators=[DataRequired()])
    flight_date = DateField('Flight Date', format='%Y-%m-%d', validators=[DataRequired()])
    cost = DecimalField('Cost Per Person', places=2, validators=[DataRequired()])
    capacity = IntegerField('Capacity', validators=[DataRequired()])
    current_date = StringField('Current Date', render_kw = {'disabled': 'disabled'})
    submit = SubmitField('Schedule')

class AddPropertyForm(FlaskForm):
    property_name = StringField('Property Name', validators=[DataRequired(), Length(max=50)])
    description = TextAreaField('Description', validators=[DataRequired(), Length(max=500)])
    capacity = IntegerField('Capacity', validators=[DataRequired()])
    cost = DecimalField('Cost', places=2, validators=[DataRequired()])
    street = StringField('Street', validators=[DataRequired(), Length(max=50)])
    city = StringField('City', validators=[DataRequired(), Length(max=50)])
    state = SelectField('State', validators=[DataRequired(), Length(2)])
    zipcode = StringField('Zip', validators=[DataRequired(), Length(5)])
    nearest_airport_id = StringField('Nearest Airport', validators=[Optional(), Length(3)])
    dist_to_airport = IntegerField('Distance to Airport', validators=[Optional()])
    submit = SubmitField('Add Property')

class ReservationForm(FlaskForm):
    property_name = StringField('Property Name', render_kw = {'readonly': "readonly"})
    owner_email = StringField('Owner Email', render_kw = {'readonly': "readonly"})
    customer_email = StringField('Customer Email', render_kw = {'disabled': 'disabled'}) 
    start_date = DateField('Start Date', format='%Y-%m-%d', default = datetime.today())
    end_date = DateField('End Date', format='%Y-%m-%d', default = datetime.today())
    num_guests = IntegerField('Number of Guests', validators=[DataRequired()])
    current_date = StringField('Current Date', render_kw = {'disabled': 'disabled'})
    submit = SubmitField('Reserve')

class BookingForm(FlaskForm):
    customer_email = StringField('Customer Email', render_kw = {'readonly': 'readonly'})
    airline_name = StringField('Airline Name', render_kw = {'readonly': 'readonly'})
    flight_num = StringField('Flight Number', render_kw = {'readonly': 'readonly'})
    num_seats = IntegerField('Number of Seats', validators=[DataRequired()])
    current_date = StringField('Current Date', render_kw = {'readonly': 'readonly'})
    submit = SubmitField('Reserve')
