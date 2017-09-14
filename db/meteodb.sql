-- MySQL dump 10.13  Distrib 5.5.53, for debian-linux-gnu (x86_64)
--
-- Host: 10.1.1.220    Database: meteodb
-- ------------------------------------------------------
-- Server version	5.1.69-0ubuntu0.11.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `CLIMATE_IN`
--

DROP TABLE IF EXISTS `CLIMATE_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CLIMATE_IN` (
  `Station_SourceID` int(11) NOT NULL DEFAULT '0',
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `IWV` double DEFAULT NULL,
  `Pressure` double DEFAULT NULL,
  `Temperature` double DEFAULT NULL,
  PRIMARY KEY (`Station_SourceID`,`Datetime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `COORDINATE`
--

DROP TABLE IF EXISTS `COORDINATE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COORDINATE` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Altitude` float DEFAULT NULL,
  `Longitude` float DEFAULT NULL,
  `Latitude` float DEFAULT NULL,
  `InstrumentID` int(11) NOT NULL,
  `StationID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_COORDINATE_InstrumentID` (`InstrumentID`),
  KEY `fk_COORDINATE_StationID` (`StationID`),
  CONSTRAINT `fk_COORDINATE_InstrumentID` FOREIGN KEY (`InstrumentID`) REFERENCES `INSTRUMENT` (`ID`),
  CONSTRAINT `fk_COORDINATE_StationID` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1424 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `FIELD_DEFINITION`
--

DROP TABLE IF EXISTS `FIELD_DEFINITION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FIELD_DEFINITION` (
  `FieldName` varchar(32) NOT NULL DEFAULT '',
  `Description` varchar(128) DEFAULT NULL,
  `Units` varchar(8) DEFAULT NULL,
  `UserVisible` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`FieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `FIGURES`
--

DROP TABLE IF EXISTS `FIGURES`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FIGURES` (
  `Date_Start` date DEFAULT NULL,
  `Date_End` date DEFAULT NULL,
  `Figure` longblob NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Chart_Type` int(11) DEFAULT NULL,
  `Caption` varchar(200) DEFAULT NULL,
  `Description` mediumblob,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GPS_IN`
--

DROP TABLE IF EXISTS `GPS_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GPS_IN` (
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ZTD` double DEFAULT NULL,
  `Sigma_ZTD` double DEFAULT NULL,
  `Gradient_N` double DEFAULT NULL,
  `Gradient_E` double DEFAULT NULL,
  `Sigma_Grad_N` double DEFAULT NULL,
  `Sigma_Grad_E` double DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  `Station_SourceID` int(11) NOT NULL,
  PRIMARY KEY (`Station_SourceID`,`Datetime`),
  CONSTRAINT `fk_GPS_IN_Station_SourceID` FOREIGN KEY (`Station_SourceID`) REFERENCES `STATION_SOURCE` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GPS_OUT`
--

DROP TABLE IF EXISTS `GPS_OUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GPS_OUT` (
  `StationID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `IWV` double DEFAULT NULL,
  `IWV_N` double DEFAULT NULL,
  `IWV_E` double DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Pressure` float DEFAULT NULL,
  `Temperature` float DEFAULT NULL,
  `Sigma_IWV` double DEFAULT NULL,
  `Sigma_IWV_N` double DEFAULT NULL,
  `Sigma_IWV_E` double DEFAULT NULL,
  `ZTD` double DEFAULT NULL,
  `ZHD` double DEFAULT NULL,
  `ZWD` double DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  `IWV_RH` double DEFAULT NULL,
  `Sigma_IWV_RH` double DEFAULT NULL,
  `SourceGpsID` int(11) NOT NULL,
  `SourceMetID` int(11) NOT NULL,
  PRIMARY KEY (`StationID`,`Datetime`,`SourceGpsID`,`SourceMetID`),
  KEY `fk_GPS_OUT_SourceGpsID` (`SourceGpsID`),
  KEY `fk_GPS_OUT_SourceMetID` (`SourceMetID`),
  CONSTRAINT `fk_GPS_OUT_SourceGpsID` FOREIGN KEY (`SourceGpsID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_GPS_OUT_SourceMetID` FOREIGN KEY (`SourceMetID`) REFERENCES `SOURCE` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `INSTRUMENT`
--

DROP TABLE IF EXISTS `INSTRUMENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `INSTRUMENT` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(128) DEFAULT NULL,
  `TableName` varchar(48) DEFAULT NULL,
  `AccessLevel` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LIDAR`
--

DROP TABLE IF EXISTS `LIDAR`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LIDAR` (
  `Station_SourceID` int(11) NOT NULL DEFAULT '0',
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `PBL` float DEFAULT NULL,
  `Sigma_PBL` float DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Station_SourceID`,`Datetime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LOG`
--

DROP TABLE IF EXISTS `LOG`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LOG` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` int(11) NOT NULL,
  `ID_User` int(11) DEFAULT NULL,
  `Note` blob,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `fk_LOG_ID_User` (`ID_User`),
  CONSTRAINT `fk_LOG_ID_User` FOREIGN KEY (`ID_User`) REFERENCES `USERS` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MIMI`
--

DROP TABLE IF EXISTS `MIMI`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MIMI` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(50) NOT NULL DEFAULT '',
  `telephone` float DEFAULT NULL,
  PRIMARY KEY (`ID`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MODEL_IN`
--

DROP TABLE IF EXISTS `MODEL_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MODEL_IN` (
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Station_SourceID` int(11) NOT NULL,
  `Model_Pressure` double NOT NULL DEFAULT '0',
  `Ground_Pressure` double DEFAULT NULL,
  `Model_Temperature` float NOT NULL DEFAULT '0',
  `Ground_Temperature` double DEFAULT NULL,
  `Latitude` float DEFAULT NULL,
  `Longtitude` float DEFAULT NULL,
  `Model_Height` float DEFAULT NULL,
  `Terrain_Height` float DEFAULT NULL,
  `WV_Mixing_ratio` float DEFAULT NULL,
  `ZHD` double DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `PBL` float DEFAULT NULL,
  `Level` int(11) DEFAULT NULL,
  PRIMARY KEY (`Datetime`,`Station_SourceID`,`Model_Pressure`,`Model_Temperature`),
  KEY `Station_SourceID` (`Station_SourceID`),
  CONSTRAINT `MODEL_IN_ibfk_1` FOREIGN KEY (`Station_SourceID`) REFERENCES `STATION_SOURCE` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MODEL_OUT`
--

DROP TABLE IF EXISTS `MODEL_OUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MODEL_OUT` (
  `StationID` int(11) NOT NULL DEFAULT '0',
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `IWV` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`Datetime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `NADYA`
--

DROP TABLE IF EXISTS `NADYA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `NADYA` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Name` varchar(50) NOT NULL DEFAULT '',
  `Telephone` float DEFAULT NULL,
  PRIMARY KEY (`ID`,`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PROBA`
--

DROP TABLE IF EXISTS `PROBA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PROBA` (
  `ststid` int(11) DEFAULT NULL,
  `description` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RADIOSONDE_IN`
--

DROP TABLE IF EXISTS `RADIOSONDE_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RADIOSONDE_IN` (
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Pressure` float NOT NULL DEFAULT '0',
  `Temperature` float DEFAULT NULL,
  `Dew_Point` float DEFAULT NULL,
  `Wind_Dir` float DEFAULT NULL,
  `Wind_Speed` float DEFAULT NULL,
  `Rel_Hum` float DEFAULT NULL,
  `Height` float DEFAULT NULL,
  `MixR` float DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  `Station_SourceID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Station_SourceID`,`Datetime`,`Pressure`),
  CONSTRAINT `RADIOSONDE_IN_ibfk_1` FOREIGN KEY (`Station_SourceID`) REFERENCES `STATION_SOURCE` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RADIOSONDE_IN_IWV`
--

DROP TABLE IF EXISTS `RADIOSONDE_IN_IWV`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RADIOSONDE_IN_IWV` (
  `StationID` int(11) NOT NULL DEFAULT '0',
  `SourceID` int(11) NOT NULL DEFAULT '0',
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `IWV` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`Datetime`,`SourceID`),
  KEY `SourceID` (`SourceID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RADIOSONDE_OUT`
--

DROP TABLE IF EXISTS `RADIOSONDE_OUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RADIOSONDE_OUT` (
  `StationID` int(11) NOT NULL DEFAULT '0',
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `IWV_WAYOM` float DEFAULT NULL,
  `IWV` float DEFAULT NULL,
  `sigma_iwv` double DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  `IWV_RH` double DEFAULT NULL,
  `Sigma_IWV_RH` double DEFAULT NULL,
  `SourceRadID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`SourceRadID`,`Datetime`,`StationID`),
  KEY `StationID` (`StationID`),
  CONSTRAINT `RADIOSONDE_OUT_ibfk_1` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`),
  CONSTRAINT `RADIOSONDE_OUT_ibfk_2` FOREIGN KEY (`SourceRadID`) REFERENCES `SOURCE` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SOURCE`
--

DROP TABLE IF EXISTS `SOURCE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SOURCE` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(128) DEFAULT NULL,
  `Email` varchar(64) DEFAULT NULL,
  `Phone` varchar(64) DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `STATION`
--

DROP TABLE IF EXISTS `STATION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `STATION` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(128) DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `STATION_SOURCE`
--

DROP TABLE IF EXISTS `STATION_SOURCE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `STATION_SOURCE` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SourceID` int(11) NOT NULL,
  `StationID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `StationID` (`StationID`),
  KEY `SourceID` (`SourceID`),
  CONSTRAINT `STATION_SOURCE_ibfk_1` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`),
  CONSTRAINT `STATION_SOURCE_ibfk_2` FOREIGN KEY (`SourceID`) REFERENCES `SOURCE` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=309 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SYNOP`
--

DROP TABLE IF EXISTS `SYNOP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SYNOP` (
  `Datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Pressure` float DEFAULT NULL,
  `Temperature` float DEFAULT NULL,
  `Humidity` float DEFAULT NULL,
  `Note` varchar(10000) DEFAULT NULL,
  `Station_SourceID` int(11) NOT NULL,
  `Cloud` int(11) DEFAULT NULL,
  `Wind_Dir` float DEFAULT NULL,
  `Wind_Speed` float DEFAULT NULL,
  `Precipitation_6h` float DEFAULT NULL,
  `Precipitation_12h` float DEFAULT NULL,
  `Precipitation_24h` float DEFAULT NULL,
  `Phenomena` int(11) DEFAULT NULL,
  `Past_Phenomena_1` int(11) DEFAULT NULL,
  `Past_Phenomena_2` int(11) DEFAULT NULL,
  PRIMARY KEY (`Station_SourceID`,`Datetime`),
  CONSTRAINT `fk_SYNOP_Station_SourceID` FOREIGN KEY (`Station_SourceID`) REFERENCES `STATION_SOURCE` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `USERS`
--

DROP TABLE IF EXISTS `USERS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `USERS` (
  `Email` varchar(64) NOT NULL,
  `Institution` varchar(128) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Access` int(11) DEFAULT NULL,
  `note` varchar(10000) DEFAULT NULL,
  `Pwd` blob NOT NULL,
  `Username` varchar(32) NOT NULL,
  `Surname` varchar(32) DEFAULT NULL,
  `Cookie` blob,
  `Firstname` varchar(32) DEFAULT NULL,
  `Address` varchar(128) DEFAULT NULL,
  `Phone` varchar(32) DEFAULT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Email` (`Email`),
  UNIQUE KEY `Username` (`Username`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authors`
--

DROP TABLE IF EXISTS `authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authors` (
  `author_id` int(11) NOT NULL AUTO_INCREMENT,
  `author_last` varchar(50) DEFAULT NULL,
  `author_first` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`author_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `basic_commands`
--

DROP TABLE IF EXISTS `basic_commands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `basic_commands` (
  `command` varchar(200) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biliana`
--

DROP TABLE IF EXISTS `biliana`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biliana` (
  `userid` int(11) DEFAULT NULL,
  `name` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evgenia`
--

DROP TABLE IF EXISTS `evgenia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evgenia` (
  `id` int(11) NOT NULL DEFAULT '0',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(30) NOT NULL DEFAULT '',
  `telephone` float DEFAULT NULL,
  PRIMARY KEY (`id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marto`
--

DROP TABLE IF EXISTS `marto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marto` (
  `book_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `description` text,
  `genre` enum('novel','poetry','drama') DEFAULT NULL,
  `publisher_id` int(11) DEFAULT NULL,
  `pub_year` varchar(4) DEFAULT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`book_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-09-14 11:13:44
