from sqlalchemy.sql.schema import UniqueConstraint
from application import app
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, MetaData, text
from sqlalchemy_utils import database_exists, create_database

conn = "mysql+pymysql://test:1234@localhost:3306/restaurant_supply_express"
engine = create_engine(conn, echo=True, pool_recycle=1800)

metadata_obj = MetaData()

app.config['SECRET_KEY'] = 'ContinueCounterReset'
app.config['SQLALCHEMY_DATABASE_URI'] = conn
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
db = SQLAlchemy(app, metadata=metadata_obj)

# Connect to the database
connection = engine.connect()
raw_connection = engine.raw_connection()
cursor = raw_connection.cursor()
a = connection.execute("SELECT * FROM {}".format('display_service_view'))
ret = cursor.callproc('add_owner', ['lfibonacci5', 'Leonardo', 'Fibonacci', '144 Golden Ratio Spiral', '1170-01-01'])
raw_connection.commit()
