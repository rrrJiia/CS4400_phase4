# Program Support

This project was created for the Final Project Phase of CS 4400 - Intro to Database Systems taught by Dr. Mark Moss at Georgia Institute of Technology. The goal of the project was to take an existing MySQL database and create a front-end website to support the database and realize the true value of the database. Our project makes use of the standard frontend tools (HTML, CSS, Javascript, AJAX, Bootstrap, etc.) and popular server-database ORM tools (Flask, SQLAlchemy) to make it possible. We hope you enjoy the website!


# Install instructions
Using python version >= 3.4, create and start a python virtual environment (this prevents conflicts with system wide python packages):

*On MacOS and Linux:*
```
python -m venv venv
source venv/bin/activate
```

*On Windows:*
```
python -m venv venv
env\Scripts\activate.bat
```

Install dependencies:
```
pip install -r requirements.txt
```

# Running instructions

Go to the db.py file in and edit the conn string at the top with your MySQL password and hosting port. It should look like this:
```conn = "mysql+pymysql://root:[YOUR PASSWORD HERE]@localhost:[YOUR PORT UMBER HERE]/travel_reservation_service"```

Open up your MySQL Workbench and start a SQL server.

For a clean start, please run ```DROP DATABASE IF EXISTS travel_reservation_service;``` in MySQL before running the instructions below. The website will only setup the database for you if it does not already exist.

If you have everything installed properly, you should be able to run it just by doing:
```python3 travelReservationService.py```

And then go to a browser and type in http://localhost:5000/ and it should take you to the website


# Logging In as Web Administrator

There is a special web administrator account created on every fresh boot. The credentials are below, and you can also shortcut login by editing the URL and going to /testing page.

Username: webadmin@gmail.com

Password: ContinueCounterReset


# Team Members

Neil Barry - Undergraduate ISyE - Performed work in general aesthetics and database backend support, as well as full troubleshooting and bug hunting.

Owen Cardwell - Undergraduate CS | Math - Performed work in WTForms, modal support, and backend querying SQL commands.

Raymond Jia - Undergraduate ECE - Performed work in general website layout, database backend setup, modal support, and backend querying SQL commands.

Sara (Xinyue) Ma - Graduate QCF - Performed work in WTForms and backend querying SQL commands, as well as setting up error messages in SQL and corresponding flash messages on website pages.
