from sqlalchemy.sql.schema import UniqueConstraint
from application import app
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, MetaData, text
from sqlalchemy_utils import database_exists, create_database

conn = "mysql+pymysql://root:12344321@localhost:3306/travel_reservation_service"
engine = create_engine(conn, echo=True, pool_recycle=1800)

metadata_obj = MetaData()

app.config['SECRET_KEY'] = 'ContinueCounterReset'
app.config['SQLALCHEMY_DATABASE_URI'] = conn
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
db = SQLAlchemy(app, metadata=metadata_obj)

#######################################################
# Database Setup
#######################################################
def sql_script_reader(path, conn, delim):
    file = open(path,'r')
    q = ''
    for line in file:
        if not line.startswith('--') and line.strip('\n'):
            q += line.strip('\n')
            if q.endswith(delim):
                try:
                    if delim != ';':
                        q = q.strip(delim)
                    conn.execute(text(q))
                    conn.execute("commit")
                except:
                    print('Invalid Command')
                finally:
                    q = ''
    return

# Check if database already exists
dbExists = database_exists(engine.url)

# Create the database if it doesn't already exist
if not dbExists:
    create_database(engine.url)

# Connect to the database
connection = engine.connect()

# Create the schema, stored procedures, views, and functions if database didn't already exist
# Also populate the database with appropriate data
if not dbExists:
    sql_script_reader('schema.sql', connection, ';')
    sql_script_reader('stored_procedures.sql', connection, '$')
    sql_script_reader('populate_data.sql', connection, ';')

# Add a web administrator to the database if not already exists
q = text("SELECT * FROM accounts WHERE Email=\'webadmin@gmail.com\'")
result = connection.execute(q)
if result.rowcount == 0:
    q = text('INSERT INTO Accounts (Email, First_Name, Last_Name, Pass) VALUES (\'webadmin@gmail.com\', \'Web\', \'Admin\', \'ContinueCounterReset\')')
    connection.execute(q)
    connection.execute("commit")
    q = text('INSERT INTO Admins (Email) VALUES (\'webadmin@gmail.com\')')
    connection.execute(q)
    connection.execute("commit")
    q = text('CALL register_customer(\'webadmin@gmail.com\', \'Web\', \'Admin\', \'ContinueCounterReset\', \'999-999-9999\', \'9999 9999 9999 9999\', \'999\', \'2040-01-01\', \'USA\')')
    connection.execute(q)
    connection.execute("commit")
    q = text('CALL register_owner(\'webadmin@gmail.com\', \'Web\', \'Admin\', \'ContinueCounterReset\', \'999-999-9999\')')
    connection.execute(q)
    connection.execute("commit")
