# CS4400_phase4

## i. Instructions to setup your app  
You should use python version >= 3.4, create and start a python virtual environment with:

On MacOS and Linux:
```
python -m venv venv
source venv/bin/activate
```

On Windows:
```
python -m venv venv
env\Scripts\activate.bat
```

Install dependencies:
```
pip install -r requirements.txt
```
## ii. Instructions to run your app  
After setting up the app,
Go to the db.py file and edit the string at the top with your MySQL password and hosting port. It should look like this: conn = "mysql+pymysql://root:[YOUR SQL PASSWORD HERE]@localhost:[YOUR PORT NUMBER HERE]/restaurant_supply_express"
Then, you should be fine by running the 
```
python3 DeliveryService.py
```
Then you should be able to open the app in you local browser with the link http://localhost:5000/ 


## iii. Brief explanation of what technologies you used and how you accomplished your application
Frontend: 
HTML, CSS, AJAX, etc

Backend: 
Flask, SQLAlchemy
## iv. Explanation of how work was distributed among the team members  
Han Bao: Performed work in general aesthetics website layout, database backend support, and backend troubleshooting.

Dian Yang: Performed work in modal support, backend querying SQL commands and backend troubleshooting.

Xiang Li; Performed work in general frontend website layout, modal support, and backend querying SQL commands.

Ruoran Jia: Performed work in backend querying SQL commands.
