-- Создание таблицы Classes
CREATE TABLE Classes (
    class VARCHAR(100) NOT NULL,
    type ENUM('Racing', 'Street') NOT NULL,
    country VARCHAR(100) NOT NULL,
    numDoors INT NOT NULL,
    engineSize DECIMAL(3, 1) NOT NULL, -- размер двигателя в литрах
    weight INT NOT NULL,                -- вес автомобиля в килограммах
    PRIMARY KEY (class)
);
-- Создание таблицы Cars
CREATE TABLE Cars (
    name VARCHAR(100) NOT NULL,
    class VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    PRIMARY KEY (name),
    FOREIGN KEY (class) REFERENCES Classes(class)
);
-- Создание таблицы Races
CREATE TABLE Races (
    name VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    PRIMARY KEY (name)
);
-- Создание таблицы Results
CREATE TABLE Results (
    car VARCHAR(100) NOT NULL,
    race VARCHAR(100) NOT NULL,
    position INT NOT NULL,
    PRIMARY KEY (car, race),
    FOREIGN KEY (car) REFERENCES Cars(name),
    FOREIGN KEY (race) REFERENCES Races(name)
);
