-- =============================================================
-- F1 DATABASE - COMPLETE SETUP SCRIPT (FIXED)
-- Single file containing: Schema + Data + Triggers/Procedures
-- Just open this file in MySQL Workbench and click Execute!
-- =============================================================

-- Drop and create database
DROP DATABASE IF EXISTS f1_db;
CREATE DATABASE f1_db;
USE f1_db;

-- =============================================================
-- PART 1: CREATE TABLES (Your Original Schema)
-- =============================================================

CREATE TABLE TEAM (
    Team_ID INT PRIMARY KEY,
    Team_Name VARCHAR(255) NOT NULL,
    Nationality VARCHAR(255)
);

CREATE TABLE DRIVER (
    Driver_ID INT PRIMARY KEY,
    First_Name VARCHAR(255) NOT NULL,
    Last_Name VARCHAR(255) NOT NULL,
    DOB DATE,
    Team_ID INT,
    FOREIGN KEY (Team_ID) REFERENCES TEAM(Team_ID)
);

CREATE TABLE CIRCUIT (
    Circuit_ID INT PRIMARY KEY,
    Circuit_Name VARCHAR(255) NOT NULL,
    Location VARCHAR(255)
);

CREATE TABLE RACE (
    Race_ID INT PRIMARY KEY,
    Race_Name VARCHAR(255) NOT NULL,
    Venue VARCHAR(255),
    Year INT,
    Circuit_ID INT NOT NULL,
    FOREIGN KEY (Circuit_ID) REFERENCES CIRCUIT(Circuit_ID)
);

CREATE TABLE STATUS (
    Status_ID INT PRIMARY KEY,
    Status_description VARCHAR(255) NOT NULL
);

CREATE TABLE RESULT (
    Result_ID INT PRIMARY KEY,
    Position INT,
    Grid INT,
    Points FLOAT NOT NULL DEFAULT 0,
    Race_ID INT NOT NULL,
    Driver_ID INT NOT NULL,
    Team_ID INT NOT NULL,
    Status_ID INT NOT NULL,
    FOREIGN KEY (Race_ID) REFERENCES RACE(Race_ID),
    FOREIGN KEY (Driver_ID) REFERENCES DRIVER(Driver_ID),
    FOREIGN KEY (Team_ID) REFERENCES TEAM(Team_ID),
    FOREIGN KEY (Status_ID) REFERENCES STATUS(Status_ID)
);

CREATE VIEW DRIVER_DETAILS AS
SELECT
    Driver_ID,
    First_Name,
    Last_Name,
    DOB,
    Team_ID,
    TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age
FROM DRIVER;

SELECT 'Tables created successfully! ✅' AS Status;

-- =============================================================
-- PART 2: INSERT DATA (Realistic F1 2024 Data)
-- =============================================================

-- Insert Teams
INSERT INTO TEAM (Team_ID, Team_Name, Nationality) VALUES
(1, 'Red Bull Racing', 'Austrian'),
(2, 'Mercedes', 'German'),
(3, 'Ferrari', 'Italian'),
(4, 'McLaren', 'British'),
(5, 'Aston Martin', 'British'),
(6, 'Alpine', 'French'),
(7, 'Williams', 'British'),
(8, 'RB (AlphaTauri)', 'Italian'),
(9, 'Kick Sauber', 'Swiss'),
(10, 'Haas', 'American');

-- Insert Drivers
INSERT INTO DRIVER (Driver_ID, First_Name, Last_Name, DOB, Team_ID) VALUES
(1, 'Max', 'Verstappen', '1997-09-30', 1),
(2, 'Sergio', 'Perez', '1990-01-26', 1),
(3, 'Lewis', 'Hamilton', '1985-01-07', 2),
(4, 'George', 'Russell', '1998-02-15', 2),
(5, 'Charles', 'Leclerc', '1997-10-16', 3),
(6, 'Carlos', 'Sainz', '1994-09-01', 3),
(7, 'Lando', 'Norris', '1999-11-13', 4),
(8, 'Oscar', 'Piastri', '2001-04-06', 4),
(9, 'Fernando', 'Alonso', '1981-07-29', 5),
(10, 'Lance', 'Stroll', '1998-10-29', 5),
(11, 'Pierre', 'Gasly', '1996-02-07', 6),
(12, 'Esteban', 'Ocon', '1996-09-17', 6),
(13, 'Alex', 'Albon', '1996-03-23', 7),
(14, 'Logan', 'Sargeant', '2000-12-31', 7),
(15, 'Yuki', 'Tsunoda', '2000-05-11', 8),
(16, 'Daniel', 'Ricciardo', '1989-07-01', 8),
(17, 'Valtteri', 'Bottas', '1989-08-28', 9),
(18, 'Zhou', 'Guanyu', '1999-05-30', 9),
(19, 'Kevin', 'Magnussen', '1992-10-05', 10),
(20, 'Nico', 'Hulkenberg', '1987-08-19', 10);

-- Insert Circuits
INSERT INTO CIRCUIT (Circuit_ID, Circuit_Name, Location) VALUES
(1, 'Bahrain International Circuit', 'Bahrain'),
(2, 'Jeddah Corniche Circuit', 'Saudi Arabia'),
(3, 'Albert Park Circuit', 'Australia'),
(4, 'Suzuka Circuit', 'Japan'),
(5, 'Shanghai International Circuit', 'China'),
(6, 'Miami International Autodrome', 'USA'),
(7, 'Autodromo Enzo e Dino Ferrari', 'Italy'),
(8, 'Circuit de Monaco', 'Monaco'),
(9, 'Circuit de Barcelona-Catalunya', 'Spain'),
(10, 'Circuit Gilles Villeneuve', 'Canada'),
(11, 'Red Bull Ring', 'Austria'),
(12, 'Silverstone Circuit', 'United Kingdom'),
(13, 'Hungaroring', 'Hungary'),
(14, 'Circuit de Spa-Francorchamps', 'Belgium'),
(15, 'Autodromo Nazionale di Monza', 'Italy');

-- Insert Status
INSERT INTO STATUS (Status_ID, Status_description) VALUES
(1, 'Finished'),
(2, 'Accident'),
(3, 'Collision'),
(4, 'Engine'),
(5, 'Gearbox'),
(6, 'Transmission'),
(7, 'Clutch'),
(8, 'Hydraulics'),
(9, 'Electrical'),
(10, 'Disqualified'),
(11, '+1 Lap'),
(12, '+2 Laps'),
(13, 'Spun off'),
(14, 'Retired'),
(15, 'Did not start');

-- Insert Races (2024 Season)
INSERT INTO RACE (Race_ID, Race_Name, Venue, Year, Circuit_ID) VALUES
(1, 'Bahrain Grand Prix', 'Sakhir', 2024, 1),
(2, 'Saudi Arabian Grand Prix', 'Jeddah', 2024, 2),
(3, 'Australian Grand Prix', 'Melbourne', 2024, 3),
(4, 'Japanese Grand Prix', 'Suzuka', 2024, 4),
(5, 'Chinese Grand Prix', 'Shanghai', 2024, 5);

-- Insert Results (First 5 races, 20 drivers each = 100 results)
-- RACE 1: Bahrain GP
INSERT INTO RESULT (Result_ID, Race_ID, Driver_ID, Team_ID, Status_ID, Position, Grid, Points) VALUES
(1, 1, 1, 1, 1, 1, 1, 25),
(2, 1, 2, 1, 1, 2, 2, 18),
(3, 1, 5, 3, 1, 3, 3, 15),
(4, 1, 6, 3, 1, 4, 4, 12),
(5, 1, 7, 4, 1, 5, 6, 10),
(6, 1, 4, 2, 1, 6, 5, 8),
(7, 1, 3, 2, 1, 7, 7, 6),
(8, 1, 9, 5, 1, 8, 8, 4),
(9, 1, 8, 4, 1, 9, 10, 2),
(10, 1, 10, 5, 1, 10, 9, 1),
(11, 1, 11, 6, 1, 11, 11, 0),
(12, 1, 12, 6, 1, 12, 12, 0),
(13, 1, 13, 7, 1, 13, 13, 0),
(14, 1, 14, 7, 1, 14, 14, 0),
(15, 1, 15, 8, 1, 15, 15, 0),
(16, 1, 16, 8, 1, 16, 16, 0),
(17, 1, 17, 9, 1, 17, 17, 0),
(18, 1, 18, 9, 1, 18, 18, 0),
(19, 1, 19, 10, 1, 19, 19, 0),
(20, 1, 20, 10, 2, NULL, 20, 0);

-- RACE 2: Saudi Arabian GP
INSERT INTO RESULT (Result_ID, Race_ID, Driver_ID, Team_ID, Status_ID, Position, Grid, Points) VALUES
(21, 2, 1, 1, 1, 1, 1, 25),
(22, 2, 2, 1, 1, 2, 3, 18),
(23, 2, 5, 3, 1, 3, 2, 15),
(24, 2, 7, 4, 1, 4, 5, 12),
(25, 2, 9, 5, 1, 5, 4, 10),
(26, 2, 4, 2, 1, 6, 6, 8),
(27, 2, 8, 4, 1, 7, 7, 6),
(28, 2, 6, 3, 1, 8, 8, 4),
(29, 2, 3, 2, 1, 9, 9, 2),
(30, 2, 10, 5, 1, 10, 10, 1),
(31, 2, 11, 6, 1, 11, 11, 0),
(32, 2, 12, 6, 1, 12, 12, 0),
(33, 2, 13, 7, 1, 13, 13, 0),
(34, 2, 14, 7, 3, NULL, 14, 0),
(35, 2, 15, 8, 1, 14, 15, 0),
(36, 2, 16, 8, 1, 15, 16, 0),
(37, 2, 17, 9, 1, 16, 17, 0),
(38, 2, 18, 9, 1, 17, 18, 0),
(39, 2, 19, 10, 1, 18, 19, 0),
(40, 2, 20, 10, 1, 19, 20, 0);

-- RACE 3: Australian GP (Sainz wins!)
INSERT INTO RESULT (Result_ID, Race_ID, Driver_ID, Team_ID, Status_ID, Position, Grid, Points) VALUES
(41, 3, 6, 3, 1, 1, 3, 25),
(42, 3, 5, 3, 1, 2, 2, 18),
(43, 3, 7, 4, 1, 3, 4, 15),
(44, 3, 8, 4, 1, 4, 5, 12),
(45, 3, 2, 1, 1, 5, 6, 10),
(46, 3, 4, 2, 1, 6, 7, 8),
(47, 3, 9, 5, 1, 7, 8, 6),
(48, 3, 3, 2, 1, 8, 9, 4),
(49, 3, 10, 5, 1, 9, 10, 2),
(50, 3, 11, 6, 1, 10, 11, 1),
(51, 3, 1, 1, 14, NULL, 1, 0),
(52, 3, 12, 6, 1, 11, 12, 0),
(53, 3, 13, 7, 1, 12, 13, 0),
(54, 3, 14, 7, 1, 13, 14, 0),
(55, 3, 15, 8, 1, 14, 15, 0),
(56, 3, 16, 8, 1, 15, 16, 0),
(57, 3, 17, 9, 1, 16, 17, 0),
(58, 3, 18, 9, 1, 17, 18, 0),
(59, 3, 19, 10, 1, 18, 19, 0),
(60, 3, 20, 10, 1, 19, 20, 0);

-- RACE 4: Japanese GP
INSERT INTO RESULT (Result_ID, Race_ID, Driver_ID, Team_ID, Status_ID, Position, Grid, Points) VALUES
(61, 4, 1, 1, 1, 1, 1, 26),
(62, 4, 2, 1, 1, 2, 2, 18),
(63, 4, 6, 3, 1, 3, 3, 15),
(64, 4, 5, 3, 1, 4, 4, 12),
(65, 4, 7, 4, 1, 5, 5, 10),
(66, 4, 4, 2, 1, 6, 6, 8),
(67, 4, 8, 4, 1, 7, 7, 6),
(68, 4, 9, 5, 1, 8, 8, 4),
(69, 4, 3, 2, 1, 9, 9, 2),
(70, 4, 11, 6, 1, 10, 10, 1),
(71, 4, 10, 5, 1, 11, 11, 0),
(72, 4, 12, 6, 1, 12, 12, 0),
(73, 4, 13, 7, 1, 13, 13, 0),
(74, 4, 14, 7, 1, 14, 14, 0),
(75, 4, 15, 8, 1, 15, 15, 0),
(76, 4, 16, 8, 1, 16, 16, 0),
(77, 4, 17, 9, 1, 17, 17, 0),
(78, 4, 18, 9, 1, 18, 18, 0),
(79, 4, 19, 10, 5, NULL, 19, 0),
(80, 4, 20, 10, 1, 19, 20, 0);

-- RACE 5: Chinese GP
INSERT INTO RESULT (Result_ID, Race_ID, Driver_ID, Team_ID, Status_ID, Position, Grid, Points) VALUES
(81, 5, 1, 1, 1, 1, 1, 25),
(82, 5, 7, 4, 1, 2, 3, 18),
(83, 5, 2, 1, 1, 3, 2, 15),
(84, 5, 8, 4, 1, 4, 5, 12),
(85, 5, 4, 2, 1, 5, 4, 10),
(86, 5, 5, 3, 1, 6, 6, 8),
(87, 5, 9, 5, 1, 7, 7, 6),
(88, 5, 6, 3, 1, 8, 8, 4),
(89, 5, 3, 2, 1, 9, 9, 2),
(90, 5, 10, 5, 1, 10, 10, 1),
(91, 5, 11, 6, 1, 11, 11, 0),
(92, 5, 12, 6, 1, 12, 12, 0),
(93, 5, 13, 7, 1, 13, 13, 0),
(94, 5, 14, 7, 1, 14, 14, 0),
(95, 5, 15, 8, 1, 15, 15, 0),
(96, 5, 16, 8, 1, 16, 16, 0),
(97, 5, 17, 9, 1, 17, 17, 0),
(98, 5, 18, 9, 1, 18, 18, 0),
(99, 5, 19, 10, 1, 19, 19, 0),
(100, 5, 20, 10, 1, 20, 20, 0);

SELECT 'Data inserted successfully! ✅' AS Status;

-- =============================================================
-- PART 3: TRIGGERS, PROCEDURES, FUNCTIONS
-- =============================================================

-- Create audit log table
CREATE TABLE AUDIT_LOG (
    Log_ID INT PRIMARY KEY AUTO_INCREMENT,
    Table_Name VARCHAR(50),
    Action VARCHAR(50),
    Record_ID INT,
    Old_Value TEXT,
    New_Value TEXT,
    Changed_By VARCHAR(100),
    Changed_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

-- =============================================================
-- STORED PROCEDURES (6 Total - All needed by Streamlit app)
-- =============================================================

-- Procedure 1: Get Driver Statistics
CREATE PROCEDURE GetDriverStats(IN p_driver_id INT)
BEGIN
    SELECT
        CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver_Name,
        D.DOB,
        TIMESTAMPDIFF(YEAR, D.DOB, CURDATE()) AS Age,
        T.Team_Name AS Current_Team,
        COUNT(R.Result_ID) AS Total_Races,
        SUM(R.Points) AS Total_Points,
        SUM(CASE WHEN R.Position = 1 THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN R.Position <= 3 THEN 1 ELSE 0 END) AS Podiums,
        MIN(R.Position) AS Best_Finish,
        ROUND(AVG(R.Position), 2) AS Avg_Position
    FROM DRIVER D
    LEFT JOIN TEAM T ON D.Team_ID = T.Team_ID
    LEFT JOIN RESULT R ON D.Driver_ID = R.Driver_ID
    WHERE D.Driver_ID = p_driver_id
    GROUP BY D.Driver_ID, D.First_Name, D.Last_Name, D.DOB, T.Team_Name;
END$$

-- Procedure 2: Get Race Results
CREATE PROCEDURE GetRaceResults(IN p_race_id INT)
BEGIN
    SELECT
        RES.Position,
        CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver_Name,
        T.Team_Name,
        RES.Grid AS Starting_Position,
        RES.Points,
        S.Status_description AS Status
    FROM RESULT RES
    JOIN DRIVER D ON RES.Driver_ID = D.Driver_ID
    JOIN TEAM T ON RES.Team_ID = T.Team_ID
    JOIN STATUS S ON RES.Status_ID = S.Status_ID
    WHERE RES.Race_ID = p_race_id
    ORDER BY 
        CASE WHEN RES.Position IS NULL THEN 1 ELSE 0 END,
        RES.Position;
END$$

-- Procedure 3: Get Championship Standings
CREATE PROCEDURE GetChampionshipStandings(IN p_year INT)
BEGIN
    SELECT
        CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver_Name,
        T.Team_Name,
        SUM(RES.Points) AS Total_Points,
        SUM(CASE WHEN RES.Position = 1 THEN 1 ELSE 0 END) AS Wins,
        COUNT(RES.Result_ID) AS Races
    FROM DRIVER D
    JOIN RESULT RES ON D.Driver_ID = RES.Driver_ID
    JOIN TEAM T ON RES.Team_ID = T.Team_ID
    JOIN RACE RA ON RES.Race_ID = RA.Race_ID
    WHERE RA.Year = p_year
    GROUP BY D.Driver_ID, D.First_Name, D.Last_Name, T.Team_Name
    ORDER BY Total_Points DESC;
END$$

-- Procedure 4: Add Driver (FIXED - used by Streamlit)
CREATE PROCEDURE AddDriver(
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_dob DATE,
    IN p_team_id INT
)
BEGIN
    DECLARE v_new_id INT;
    
    -- Get next available ID
    SELECT COALESCE(MAX(Driver_ID), 0) + 1 INTO v_new_id FROM DRIVER;
    
    INSERT INTO DRIVER (Driver_ID, First_Name, Last_Name, DOB, Team_ID)
    VALUES (v_new_id, p_first_name, p_last_name, p_dob, p_team_id);
    
    SELECT v_new_id AS New_Driver_ID,
           CONCAT('Driver ', p_first_name, ' ', p_last_name, ' added successfully!') AS Message;
END$$

-- Procedure 5: Get Team Performance (FIXED - used by Streamlit)
CREATE PROCEDURE GetTeamPerformance(IN p_team_id INT)
BEGIN
    SELECT
        T.Team_Name,
        T.Nationality,
        COUNT(DISTINCT R.Race_ID) AS Races_Participated,
        SUM(R.Points) AS Total_Points,
        SUM(CASE WHEN R.Position = 1 THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN R.Position <= 3 THEN 1 ELSE 0 END) AS Podiums,
        COUNT(DISTINCT R.Driver_ID) AS Different_Drivers_Used
    FROM TEAM T
    LEFT JOIN RESULT R ON T.Team_ID = R.Team_ID
    WHERE T.Team_ID = p_team_id
    GROUP BY T.Team_ID, T.Team_Name, T.Nationality;
END$$

-- Procedure 6: Add Race Result (FIXED - used by Streamlit)
CREATE PROCEDURE AddRaceResult(
    IN p_race_id INT,
    IN p_driver_id INT,
    IN p_team_id INT,
    IN p_status_id INT,
    IN p_position INT,
    IN p_grid INT,
    IN p_points FLOAT
)
BEGIN
    DECLARE v_new_id INT;
    
    -- Get next available ID
    SELECT COALESCE(MAX(Result_ID), 0) + 1 INTO v_new_id FROM RESULT;
    
    INSERT INTO RESULT (Result_ID, Race_ID, Driver_ID, Team_ID, Status_ID, Position, Grid, Points)
    VALUES (v_new_id, p_race_id, p_driver_id, p_team_id, p_status_id, p_position, p_grid, p_points);
    
    SELECT v_new_id AS New_Result_ID,
           'Race result added successfully!' AS Message;
END$$

-- =============================================================
-- FUNCTIONS (6 Total - All needed by Streamlit app)
-- =============================================================

-- Function 1: Get Driver Total Points
CREATE FUNCTION GetDriverTotalPoints(p_driver_id INT)
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_points FLOAT;
    SELECT COALESCE(SUM(Points), 0) INTO v_total_points
    FROM RESULT WHERE Driver_ID = p_driver_id;
    RETURN v_total_points;
END$$

-- Function 2: Count Driver Wins
CREATE FUNCTION CountDriverWins(p_driver_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_wins INT;
    SELECT COUNT(*) INTO v_wins
    FROM RESULT WHERE Driver_ID = p_driver_id AND Position = 1;
    RETURN v_wins;
END$$

-- Function 3: Get Driver Age
CREATE FUNCTION GetDriverAge(p_driver_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_age INT;
    DECLARE v_dob DATE;
    SELECT DOB INTO v_dob FROM DRIVER WHERE Driver_ID = p_driver_id;
    IF v_dob IS NOT NULL THEN
        SET v_age = TIMESTAMPDIFF(YEAR, v_dob, CURDATE());
    ELSE
        SET v_age = 0;
    END IF;
    RETURN v_age;
END$$

-- Function 4: Get Best Finish (ADDED - needed by Streamlit)
CREATE FUNCTION GetBestFinish(p_driver_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_best INT;
    SELECT MIN(Position) INTO v_best
    FROM RESULT
    WHERE Driver_ID = p_driver_id AND Position IS NOT NULL;
    RETURN COALESCE(v_best, 0);
END$$

-- Function 5: Get Team Total Points (ADDED - needed by Streamlit)
CREATE FUNCTION GetTeamTotalPoints(p_team_id INT)
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_points FLOAT;
    SELECT COALESCE(SUM(Points), 0) INTO v_total_points
    FROM RESULT WHERE Team_ID = p_team_id;
    RETURN v_total_points;
END$$

-- Function 6: Count Team Wins (ADDED - needed by Streamlit)
CREATE FUNCTION CountTeamWins(p_team_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_wins INT;
    SELECT COUNT(*) INTO v_wins
    FROM RESULT WHERE Team_ID = p_team_id AND Position = 1;
    RETURN v_wins;
END$$

-- =============================================================
-- TRIGGERS (3 Total)
-- =============================================================

-- Trigger 1: Log New Driver
CREATE TRIGGER LogNewDriver
AFTER INSERT ON DRIVER
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_LOG (Table_Name, Action, Record_ID, New_Value, Changed_By)
    VALUES ('DRIVER', 'INSERT', NEW.Driver_ID, 
            CONCAT('Name: ', NEW.First_Name, ' ', NEW.Last_Name), USER());
END$$

-- Trigger 2: Prevent Driver Deletion
CREATE TRIGGER PreventDriverDeletion
BEFORE DELETE ON DRIVER
FOR EACH ROW
BEGIN
    DECLARE v_result_count INT;
    SELECT COUNT(*) INTO v_result_count FROM RESULT WHERE Driver_ID = OLD.Driver_ID;
    IF v_result_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete driver with existing race results';
    END IF;
END$$

-- Trigger 3: Validate Result Positions
CREATE TRIGGER ValidateResultPositions
BEFORE INSERT ON RESULT
FOR EACH ROW
BEGIN
    IF NEW.Grid < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Grid position cannot be negative';
    END IF;
    
    IF NEW.Position IS NOT NULL AND NEW.Position < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Final position cannot be negative';
    END IF;
    
    IF NEW.Points < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Points cannot be negative';
    END IF;
END$$

DELIMITER ;


SELECT First_Name, Last_Name
FROM DRIVER
WHERE Driver_ID NOT IN (
    SELECT DISTINCT Driver_ID
    FROM RESULT
    WHERE Points > 0
);

-- =============================================================
-- VERIFICATION & TESTING
-- =============================================================

SELECT '✅ F1 Database Setup Complete!' AS Status;
SELECT 'Schema + Data + 6 Procedures + 6 Functions + 3 Triggers' AS Components;

-- Show all database objects
SHOW PROCEDURE STATUS WHERE Db = DATABASE();
SHOW FUNCTION STATUS WHERE Db = DATABASE();
SHOW TRIGGERS;






















-- STEP 1: Show BEFORE state

SELECT COUNT(*) AS Total_Drivers FROM DRIVER;
SELECT COUNT(*) AS Audit_Entries FROM AUDIT_LOG;

-- STEP 2: Add a new driver (trigger will fire automatically)
INSERT INTO DRIVER (Driver_ID, First_Name, Last_Name, DOB, Team_ID)
VALUES (23, 'Test', 'Driver', '2000-01-03', 3);

-- STEP 3: Show AFTER state

SELECT COUNT(*) AS Total_Drivers FROM DRIVER;
SELECT COUNT(*) AS Audit_Entries FROM AUDIT_LOG;

-- STEP 4: Show what the trigger created
SELECT * FROM AUDIT_LOG WHERE Record_ID = 21;

-- STEP 5: Clean up
DELETE FROM DRIVER WHERE Driver_ID = 21;
use f1_db;
show tables;

CALL GetDriverStats(4);
CALL GetRaceResults(1);
CALL GetChampionshipStandings(2024);

delete from driver where Driver_ID=1 ;
show tables;
select * from driver;

