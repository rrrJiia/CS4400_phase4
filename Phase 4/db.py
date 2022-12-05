from sqlalchemy.sql.schema import UniqueConstraint
from application import app
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, MetaData, text
from sqlalchemy_utils import database_exists, create_database

conn = "mysql+pymysql://root:12344321@localhost:3306/restaurant_supply_express"
engine = create_engine(conn, echo=True, pool_recycle=1800)

metadata_obj = MetaData()

app.config['SECRET_KEY'] = 'ContinueCounterReset'
app.config['SQLALCHEMY_DATABASE_URI'] = conn
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
db = SQLAlchemy(app, metadata=metadata_obj)

# Connect to the database
connection = engine.connect()


