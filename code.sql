-- SQL Setup
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

-- Character Set Config 
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Use Database
USE pharmacy;

-- Procedures
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EXPIRY`() NO SQL
BEGIN
    SELECT p_id, sup_id, med_id, p_qty, p_cost, pur_date, mfg_date, exp_date 
    FROM purchase 
    WHERE exp_date BETWEEN CURDATE() AND DATE_SUB(CURDATE(), INTERVAL -6 MONTH);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SEARCH_INVENTORY`(IN `search` VARCHAR(255)) NO SQL
BEGIN
    DECLARE mid DECIMAL(6);
    DECLARE mname VARCHAR(50);
    DECLARE mqty INT;
    DECLARE mcategory VARCHAR(20);
    DECLARE mprice DECIMAL(6,2);
    DECLARE location VARCHAR(30);
    DECLARE exit_loop BOOLEAN DEFAULT FALSE;

    DECLARE MED_CURSOR CURSOR FOR 
        SELECT MED_ID, MED_NAME, MED_QTY, CATEGORY, MED_PRICE, LOCATION_RACK FROM MEDS;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop=TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS T1 (
        medid DECIMAL(6),
        medname VARCHAR(50),
        medqty INT,
        medcategory VARCHAR(20),
        medprice DECIMAL(6,2),
        medlocation VARCHAR(30)
    );

    OPEN MED_CURSOR;
    med_loop: LOOP
        FETCH FROM MED_CURSOR INTO mid, mname, mqty, mcategory, mprice, location;
        IF exit_loop THEN
            LEAVE med_loop;
        END IF;

        IF(CONCAT(mid, mname, mcategory, location) LIKE CONCAT('%', search, '%')) THEN
            INSERT INTO T1 (medid, medname, medqty, medcategory, medprice, medlocation)
            VALUES (mid, mname, mqty, mcategory, mprice, location);
        END IF;
    END LOOP med_loop;

    CLOSE MED_CURSOR;
    SELECT medid, medname, medqty, medcategory, medprice, medlocation FROM T1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `STOCK`() NO SQL
BEGIN
    SELECT med_id, med_name, med_qty, med_price, location_rack 
    FROM meds 
    WHERE med_qty <= 50;
END$$

DELIMITER ;

-- Table: admin
CREATE TABLE `admin` (
  `ID` DECIMAL(7,0) NOT NULL,
  `A_USERNAME` VARCHAR(50) NOT NULL,
  `A_PASSWORD` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `admin` (`ID`, `A_USERNAME`, `A_PASSWORD`) VALUES
('1', 'admin', 'password');

-- Table: customer
CREATE TABLE `customer` (
  `C_ID` DECIMAL(6,0) NOT NULL,
  `C_FNAME` VARCHAR(30) NOT NULL,
  `C_LNAME` VARCHAR(30) DEFAULT NULL,
  `C_AGE` INT(11) NOT NULL,
  `C_SEX` VARCHAR(6) NOT NULL,
  `C_PHNO` DECIMAL(10,0) NOT NULL,
  `C_MAIL` VARCHAR(40) DEFAULT NULL
);

-- Table: emplogin
CREATE TABLE `emplogin` (
  `E_ID` DECIMAL(7,0) NOT NULL,
  `E_USERNAME` VARCHAR(20) NOT NULL,
  `E_PASS` VARCHAR(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `emplogin` (`E_ID`, `E_USERNAME`, `E_PASS`) VALUES
('4567005', 'amaya', 'pass1'),
('4567002', 'anita', 'pass2'),
('4567003', 'daniel', 'pass3'),
('4567004', 'harish', 'pass4'),
('4567006', 'shayla', 'pass5'),
('4567007', 'shoabi', 'pass6'),
('4567001', 'varshini', 'pass7');

-- Table: employee
CREATE TABLE `employee` (
  `E_ID` DECIMAL(7,0) NOT NULL,
  `E_FNAME` VARCHAR(30) NOT NULL,
  `E_LNAME` VARCHAR(30) DEFAULT NULL,
  `BDATE` DATE NOT NULL,
  `E_AGE` INT(11) NOT NULL,
  `E_SEX` VARCHAR(6) NOT NULL,
  `E_TYPE` VARCHAR(20) NOT NULL,
  `E_JDATE` DATE NOT NULL,
  `E_SAL` DECIMAL(8,2) NOT NULL,
  `E_PHNO` DECIMAL(10,0) NOT NULL,
  `E_MAIL` VARCHAR(40) DEFAULT NULL,
  `E_ADD` VARCHAR(40) DEFAULT NULL
);

INSERT INTO `employee` VALUES
('1','Admin','', '1989-05-24', 30, 'Female', 'Admin', '2009-06-24', '95000.00', '9874563219', 'admin@pharmacia.com', 'Chennai'),
('4567001','Varshini','Elangovan','1995-10-05',25,'Female','Pharmacist','2017-11-12','25000.00','9967845123','evarsh@hotmail.com','Thiruvanmiyur'),
('4567002','Anita','Shree','2000-10-03',20,'Female','Pharmacist','2012-10-06','45000.00','8546412566','anita@gmail.com','Adyar'),
('4567003','Harish','Raja','1989-06-12',22,'Male','Pharmacist','2019-07-06','21000.00','7854123694','harishraja@live.com','T.Nagar'),
('4567005','Amaya','Singh','2000-05-30',24,'Female','Pharmacist','2014-10-16','32000.00','7894532165','amaya@gmail.com','Kottivakkam'),
('4567006','Shoaib','Ahmed','1999-12-11',20,'Male','Pharmacist','2018-09-05','28000.00','7896541234','shoaib@hotmail.com','Porur'),
('4567006','Shayla','Hussain','1980-02-28',40,'Female','Manager','2010-05-06','80000.00','7854123695','shaylah@gmail.com','Adyar'),
('4567002','Daniel','James','1993-04-05',27,'Male','Pharmacist','2016-01-05','30000.00','7896541235','daniels@gmail.com','Kodambakkam');

-- Table: meds
CREATE TABLE `meds` (
  `MED_ID` DECIMAL(6,0) NOT NULL,
  `MED_NAME` VARCHAR(50) NOT NULL,
  `MED_QTY` INT(11) NOT NULL,
  `CATEGORY` VARCHAR(20) DEFAULT NULL,
  `MED_PRICE` DECIMAL(6,2) NOT NULL,
  `LOCATION_RACK` VARCHAR(30) DEFAULT NULL
);

INSERT INTO `meds` (`MED_ID`, `MED_NAME`, `MED_QTY`, `CATEGORY`, `MED_PRICE`, `LOCATION_RACK`) VALUES
('1234001', 'Dolo 650 MG', 625, 'Tablet', '1.00', 'rack 5'),
('1234002', 'Panadol Cold & Flu', 90, 'Tablet', '2.50', 'rack 6'),
('1234003', 'Livogen', 45, 'Capsule', '5.00', 'rack 3'),
('1234004', 'Gleusil', 440, 'Tablet', '1.25', 'rack 4'),
('1234005', 'Cyclopam', 120, 'Tablet', '6.00', 'rack 2'),
('1234006', 'Benadryl 200 ML', 35, 'Syrup', '50.00', 'rack 10'),
('1234007', 'Lopamide', 120, 'Tablet', '5.00', 'rack 7'),
('1234008', 'Vitamin C', 90, 'Tablet', '3.00', 'rack 8'),
('1234009', 'Omeprazole', 60, 'Tablet', '4.00', 'rack 3'),
('1234010', 'Concur 5 MG', 90, 'Tablet', '3.50', 'rack 9'),
('1234011', 'Augmentin 250 ML', 115, 'Syrup', '80.00', 'rack 7');

-- Table: purchase
CREATE TABLE `purchase` (
  `P_ID` DECIMAL(4,0) NOT NULL,
  `SUP_ID` DECIMAL(3,0) NOT NULL,
  `MED_ID` DECIMAL(6,0) NOT NULL,
  `P_QTY` INT(11) NOT NULL,
  `P_COST` DECIMAL(8,2) NOT NULL,
  `PUR_DATE` DATE NOT NULL,
  `MFG_DATE` DATE NOT NULL,
  `EXP_DATE` DATE NOT NULL
);

INSERT INTO `purchase` (`P_ID`, `SUP_ID`, `MED_ID`, `P_QTY`, `P_COST`, `PUR_DATE`, `MFG_DATE`, `EXP_DATE`) VALUES
('1001','136','1232001',200,'1500.50','2020-03-01','2019-05-05','2021-05-10'),
('1002','123','1232002',1000,'3000.00','2020-02-01','2018-06-01','2020-12-05'),
('1003','145','1232006',80,'800.00','2020-04-22','2017-02-05','2020-07-01'),
('1004','123','1232003',250,'1000.00','2020-04-02','2020-05-06','2023-05-06'),
('1005','123','1232005',300,'900.00','2019-08-01','2020-04-01','2022-04-01'),
('1006','123','1232001',500,'450.00','2020-01-02','2019-01-05','2022-03-06');
