-- Create Tables

CREATE TABLE Accounts (
    Email VARCHAR(50) NOT NULL,
    First_Name VARCHAR(100) NOT NULL,
    Last_Name VARCHAR(100) NOT NULL,
    Pass VARCHAR(50) NOT NULL,

    PRIMARY KEY (Email)
);

CREATE TABLE Admins (
    Email VARCHAR(50) NOT NULL,

    PRIMARY KEY (Email),
    FOREIGN KEY (Email) REFERENCES Accounts (Email)
);

CREATE TABLE Clients (
    Email VARCHAR(50) NOT NULL,
    Phone_Number Char(12) UNIQUE NOT NULL CHECK (length(Phone_Number) = 12),
    
    PRIMARY KEY (Email),
    FOREIGN KEY (Email) REFERENCES Accounts (Email) 
);

CREATE TABLE Owners (
    Email VARCHAR(50) NOT NULL,

    PRIMARY KEY (Email),
    FOREIGN KEY (Email) REFERENCES Clients (Email)
);

CREATE TABLE Customer (
    Email VARCHAR(50) NOT NULL,
    CcNumber VARCHAR(19) UNIQUE NOT NULL CHECK (length(CcNumber) = 19),
    Cvv CHAR(3) NOT NULL CHECK (length(Cvv) = 3),
    Exp_Date DATE NOT NULL,
    Location VARCHAR(50) NOT NULL,

    PRIMARY KEY (Email),
    FOREIGN KEY (Email) REFERENCES Clients (Email)
);

CREATE TABLE Airline (
    Airline_Name VARCHAR(50) NOT NULL,
    Rating DECIMAL(2, 1) NOT NULL CHECK (Rating >= 1 AND Rating <= 5),

    PRIMARY KEY (Airline_Name)
);

CREATE TABLE Airport (
    Airport_Id CHAR(3) NOT NULL CHECK (length(Airport_Id) = 3),
    Airport_Name VARCHAR(50) UNIQUE NOT NULL,
    Time_Zone CHAR(3) NOT NULL CHECK(length(Time_Zone) = 3),
    Street VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State CHAR(2) NOT NULL CHECK(length(State) = 2),
    Zip CHAR(5) NOT NULL CHECK(length(Zip) = 5),

    PRIMARY KEY (Airport_Id),
    UNIQUE KEY (Street, City, State, Zip)
);

CREATE TABLE Flight (
    Flight_Num CHAR(5) NOT NULL,
    Airline_Name VARCHAR(50) NOT NULL,
    From_Airport CHAR(3) NOT NULL,
    To_Airport CHAR(3) NOT NULL,
    Departure_Time TIME NOT NULL,
    Arrival_Time TIME NOT NULL,
    Flight_Date DATE NOT NULL,
    Cost DECIMAL(6, 2) NOT NULL CHECK (Cost >= 0),
    Capacity INT NOT NULL CHECK (Capacity > 0),

    PRIMARY KEY (Flight_Num, Airline_Name),
    FOREIGN KEY (Airline_Name) REFERENCES Airline (Airline_Name),
    FOREIGN KEY (From_Airport) REFERENCES Airport (Airport_Id),
    FOREIGN KEY (To_Airport) REFERENCES Airport (Airport_Id),
    
    CHECK (From_Airport != To_Airport)
);

CREATE TABLE Property (
    Property_Name VARCHAR(50) NOT NULL,
    Owner_Email VARCHAR(50) NOT NULL,
    Descr VARCHAR(500) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Cost DECIMAL(6, 2) NOT NULL CHECK (Cost >= 0),
    Street VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State CHAR(2) NOT NULL CHECK(length(State) = 2),
    Zip CHAR(5) NOT NULL CHECK(length(Zip) = 5),

    PRIMARY KEY (Property_Name, Owner_Email),
    FOREIGN KEY (Owner_Email) REFERENCES Owners (Email),
    UNIQUE KEY (Street, City, State, Zip)
);

CREATE TABLE Amenity (
    Property_Name VARCHAR(50) NOT NULL,
    Property_Owner VARCHAR(50) NOT NULL,
    Amenity_Name VARCHAR(50) NOT NULL,

    PRIMARY KEY (Property_Name, Property_Owner, Amenity_Name),
    FOREIGN KEY (Property_Name, Property_Owner) REFERENCES Property (Property_Name, Owner_Email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Attraction (
    Airport CHAR(3) NOT NULL,
    Attraction_Name VARCHAR(50) NOT NULL,

    PRIMARY KEY (Airport, Attraction_Name),
    FOREIGN KEY (Airport) REFERENCES Airport (Airport_Id)
);

CREATE TABLE Review (
    Property_Name VARCHAR(50) NOT NULL,
    Owner_Email VARCHAR(50) NOT NULL,
    Customer VARCHAR(50) NOT NULL,
    Content VARCHAR(500),
    Score INT NOT NULL CHECK (Score >= 1 AND Score <= 5),

    PRIMARY KEY (Property_Name, Owner_Email, Customer),
    FOREIGN KEY (Property_Name, Owner_Email) REFERENCES Property (Property_Name, Owner_Email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Customer) REFERENCES Customer (Email)
);

CREATE TABLE Reserve (
    Property_Name VARCHAR(50) NOT NULL,
    Owner_Email VARCHAR(50) NOT NULL,
    Customer VARCHAR(50) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Num_Guests INT NOT NULL CHECK (Num_Guests > 0),
    Was_Cancelled BOOLEAN NOT NULL,

    PRIMARY KEY (Property_Name, Owner_Email, Customer),
    FOREIGN KEY (Property_Name, Owner_Email) REFERENCES Property (Property_Name, Owner_Email),
    FOREIGN KEY (Customer) REFERENCES Customer (Email),
    
    CHECK(End_Date >= Start_Date)
);

CREATE TABLE Is_Close_To (
    Property_Name VARCHAR(50) NOT NULL,
    Owner_Email VARCHAR(50) NOT NULL,
    Airport CHAR(3) NOT NULL,
    Distance INT NOT NULL CHECK (Distance >= 0),

    PRIMARY KEY (Property_Name, Owner_Email, Airport),
    FOREIGN KEY (Property_Name, Owner_Email) REFERENCES Property (Property_Name, Owner_Email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Airport) REFERENCES Airport (Airport_Id)
);

CREATE TABLE Book (
    Customer VARCHAR(50) NOT NULL,
    Flight_Num CHAR(5) NOT NULL,
    Airline_Name VARCHAR(50) NOT NULL,
    Num_Seats INT NOT NULL CHECK (Num_Seats > 0),
    Was_Cancelled BOOLEAN NOT NULL,

    PRIMARY KEY (Customer, Flight_Num, Airline_Name),
    FOREIGN KEY (Customer) REFERENCES Customer (Email),
    FOREIGN KEY (Flight_Num, Airline_Name) REFERENCES Flight (Flight_Num, Airline_Name)
);

CREATE TABLE Owners_Rate_Customers (
    Owner_Email VARCHAR(50) NOT NULL,
    Customer VARCHAR(50) NOT NULL,
    Score INT NOT NULL CHECK (Score >= 1 AND Score <= 5),

    PRIMARY KEY (Owner_Email, Customer),
    FOREIGN KEY (Owner_Email) REFERENCES Owners (Email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Customer) REFERENCES Customer (Email)
);

CREATE TABLE Customers_Rate_Owners (
    Customer VARCHAR(50) NOT NULL,
    Owner_Email VARCHAR(50) NOT NULL,
    Score INT NOT NULL CHECK (Score >= 1 AND Score <= 5),

    PRIMARY KEY (Customer, Owner_Email),
    FOREIGN KEY (Customer) REFERENCES Customer (Email),
    FOREIGN KEY (Owner_Email) REFERENCES Owners (Email) ON UPDATE CASCADE ON DELETE CASCADE
);