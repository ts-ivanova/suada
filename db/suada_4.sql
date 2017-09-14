-- MySQL dump 10.13  Distrib 5.5.53, for debian-linux-gnu (x86_64)
--
-- Host: 10.1.1.220    Database: suada_4
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
-- Table structure for table `COORDINATE`
--

DROP TABLE IF EXISTS `COORDINATE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COORDINATE` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(128) DEFAULT NULL,
  `StationID` int(11) NOT NULL,
  `InstrumentID` int(11) NOT NULL,
  `Altitude` float DEFAULT NULL,
  `Longitude` float DEFAULT NULL,
  `Latitude` float DEFAULT NULL,
  PRIMARY KEY (`ID`,`StationID`),
  KEY `fk_COORDINATE_INSTRUMENT(ID)` (`InstrumentID`),
  KEY `fk_COORDINATE_STATION(ID)` (`StationID`),
  CONSTRAINT `fk_COORDINATE_INSTRUMENT?ID?` FOREIGN KEY (`InstrumentID`) REFERENCES `INSTRUMENT` (`ID`),
  CONSTRAINT `fk_COORDINATE_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1434 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GNSS_IN`
--

DROP TABLE IF EXISTS `GNSS_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GNSS_IN` (
  `SensorID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ZTD` double NOT NULL,
  `Sigma_ZTD` double DEFAULT NULL,
  `Gradient_N` double DEFAULT NULL,
  `Gradient_E` double DEFAULT NULL,
  `Sigma_Grad_N` double DEFAULT NULL,
  `Sigma_Grad_E` double DEFAULT NULL,
  PRIMARY KEY (`SensorID`,`Datetime`),
  CONSTRAINT `fk_GNSS_IN_SENSOR?ID?` FOREIGN KEY (`SensorID`) REFERENCES `SENSOR` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GNSS_OUT`
--

DROP TABLE IF EXISTS `GNSS_OUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GNSS_OUT` (
  `StationID` int(11) NOT NULL,
  `SourceGpsID` int(11) NOT NULL,
  `SourceMetID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IWV` float DEFAULT NULL,
  `IWV_N` float DEFAULT NULL,
  `IWV_E` float DEFAULT NULL,
  `Sigma_IWV` float DEFAULT NULL,
  `IWV_500` float DEFAULT NULL,
  `Sigma_IWV_500` float DEFAULT NULL,
  `Pressure` float NOT NULL,
  `Temperature` float DEFAULT NULL,
  `Precipitation` float DEFAULT NULL,
  `ZTD` float DEFAULT NULL,
  `ZHD` float DEFAULT NULL,
  `ZWD` float DEFAULT NULL,
  `PE` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`Datetime`,`SourceGpsID`,`SourceMetID`),
  KEY `fk_GNSS_OUT_SOURCE_MET(ID)` (`SourceMetID`),
  KEY `fk_GNSS_OUT_SOURCE_GNSS(ID)` (`SourceGpsID`),
  CONSTRAINT `fk_GNSS_OUT_SOURCE_GNSS?ID?` FOREIGN KEY (`SourceGpsID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_GNSS_OUT_SOURCE_MET?ID?` FOREIGN KEY (`SourceMetID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_GNSS_OUT_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GRACE`
--

DROP TABLE IF EXISTS `GRACE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GRACE` (
  `StationID` int(11) NOT NULL DEFAULT '0',
  `Date` date NOT NULL DEFAULT '0000-00-00',
  `R_300` double DEFAULT NULL,
  `R_500` double DEFAULT NULL,
  `R_700` double DEFAULT NULL,
  PRIMARY KEY (`StationID`,`Date`),
  CONSTRAINT `fk_GRACE_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
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
  `AccessLevel` int(11) NOT NULL,
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
  `SensorID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `PBL` float DEFAULT NULL,
  `Sigma_PBL` float DEFAULT NULL,
  PRIMARY KEY (`SensorID`,`Datetime`),
  CONSTRAINT `fk_LIDAR_SENSOR?ID?` FOREIGN KEY (`SensorID`) REFERENCES `SENSOR` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LOG`
--

DROP TABLE IF EXISTS `LOG`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LOG` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `Type` int(11) NOT NULL,
  `ID_User` int(11) DEFAULT NULL,
  `Note` blob,
  `Date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  KEY `ID_User` (`ID_User`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `NWP_IN_1D`
--

DROP TABLE IF EXISTS `NWP_IN_1D`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `NWP_IN_1D` (
  `SensorID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Pressure` float NOT NULL,
  `Temperature` float DEFAULT NULL,
  `Latitude` float DEFAULT NULL,
  `Longitude` float DEFAULT NULL,
  `Altitude` float DEFAULT NULL,
  `ZHD` float DEFAULT NULL,
  `PBL` float DEFAULT NULL,
  `Precipitation` float DEFAULT NULL,
  PRIMARY KEY (`SensorID`,`Datetime`),
  CONSTRAINT `fk_MODEL_SURFACE_SENSOR?ID?` FOREIGN KEY (`SensorID`) REFERENCES `SENSOR` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `NWP_IN_3D`
--

DROP TABLE IF EXISTS `NWP_IN_3D`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `NWP_IN_3D` (
  `SensorID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Level` int(11) NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Pressure` float NOT NULL,
  `Temperature` float DEFAULT NULL,
  `Latitude` float DEFAULT NULL,
  `Longitude` float DEFAULT NULL,
  `Height` float DEFAULT NULL,
  `WV_Mixing_ratio` float DEFAULT NULL,
  PRIMARY KEY (`SensorID`,`Datetime`,`Level`),
  CONSTRAINT `fk_MODEL_PROFILE_SENSOR?ID?` FOREIGN KEY (`SensorID`) REFERENCES `SENSOR` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `NWP_OUT`
--

DROP TABLE IF EXISTS `NWP_OUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `NWP_OUT` (
  `StationID` int(11) NOT NULL,
  `SourceModID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IWV` float DEFAULT NULL,
  `IWV_500_Swiss` float DEFAULT NULL,
  `IWV_500_Profile` float DEFAULT NULL,
  `IWV_Max_Height` float DEFAULT NULL,
  `PE` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`SourceModID`,`Datetime`),
  KEY `fk_MODEL_PROCESSED_SOURCE_MET(ID)` (`SourceModID`),
  CONSTRAINT `fk_MODEL_PROCESSED_SOURCE_MET?ID?` FOREIGN KEY (`SourceModID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_MODEL_PROCESSED_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RADIOSONDE_IN`
--

DROP TABLE IF EXISTS `RADIOSONDE_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RADIOSONDE_IN` (
  `SensorID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Pressure` float NOT NULL,
  `Temperature` float DEFAULT NULL,
  `Dew_Point` float DEFAULT NULL,
  `Wind_Dir` float DEFAULT NULL,
  `Wind_Speed` float DEFAULT NULL,
  `Rel_Hum` float DEFAULT NULL,
  `Height` float DEFAULT NULL,
  `MixR` float DEFAULT NULL,
  PRIMARY KEY (`SensorID`,`Datetime`,`Pressure`),
  CONSTRAINT `fk_RADIOSONDE_IN_SENSOR?ID?` FOREIGN KEY (`SensorID`) REFERENCES `SENSOR` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RADIOSONDE_IN_IWV`
--

DROP TABLE IF EXISTS `RADIOSONDE_IN_IWV`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RADIOSONDE_IN_IWV` (
  `StationID` int(11) NOT NULL,
  `SourceID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IWV` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`SourceID`,`Datetime`),
  KEY `fk_RADIOSONDE_IN_IWV_SOURCE_MET(ID)` (`SourceID`),
  CONSTRAINT `fk_RADIOSONDE_IN_IWV_SOURCE_MET?ID?` FOREIGN KEY (`SourceID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_RADIOSONDE_IN_IWV_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RADIOSONDE_OUT`
--

DROP TABLE IF EXISTS `RADIOSONDE_OUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RADIOSONDE_OUT` (
  `StationID` int(11) NOT NULL,
  `SourceRadID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IWV` float DEFAULT NULL,
  `Sigma_IWV` float DEFAULT NULL,
  `IWV_External` float DEFAULT NULL,
  `IWV_500_Profile` float DEFAULT NULL,
  `IWV_500_Swiss` float DEFAULT NULL,
  `IWV_500_Swiss_External` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`SourceRadID`,`Datetime`),
  KEY `fk_RADIOSONDE_OUT_SOURCE_MET(ID)` (`SourceRadID`),
  CONSTRAINT `fk_RADIOSONDE_OUT_SOURCE_MET?ID?` FOREIGN KEY (`SourceRadID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_RADIOSONDE_OUT_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RCM`
--

DROP TABLE IF EXISTS `RCM`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RCM` (
  `StationID` int(11) NOT NULL,
  `SourceModID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IWV` float DEFAULT NULL,
  `Pressure` float DEFAULT NULL,
  `Temperature` float DEFAULT NULL,
  `Precipitation` float DEFAULT NULL,
  `Soil_Moist` float DEFAULT NULL,
  PRIMARY KEY (`StationID`,`SourceModID`,`Datetime`),
  KEY `fk_GCM_SOURCE_MET(ID)` (`SourceModID`),
  CONSTRAINT `fk_GCM_SOURCE_MET?ID?` FOREIGN KEY (`SourceModID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_NGCM_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SENSOR`
--

DROP TABLE IF EXISTS `SENSOR`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SENSOR` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SourceID` int(11) NOT NULL,
  `StationID` int(11) NOT NULL,
  PRIMARY KEY (`ID`,`SourceID`,`StationID`),
  KEY `fk_SENSOR_STATION(ID)` (`StationID`),
  KEY `fk_SENSOR_SOURCE(ID)` (`SourceID`),
  CONSTRAINT `fk_SENSOR_SOURCE?ID?` FOREIGN KEY (`SourceID`) REFERENCES `SOURCE` (`ID`),
  CONSTRAINT `fk_SENSOR_STATION?ID?` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`),
  CONSTRAINT `fk_SENSOR_STATION_ID` FOREIGN KEY (`StationID`) REFERENCES `STATION` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1160 DEFAULT CHARSET=latin1;
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
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;
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
  `Country` varchar(2) DEFAULT NULL,
  `Note` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SYNOP`
--

DROP TABLE IF EXISTS `SYNOP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SYNOP` (
  `SensorID` int(11) NOT NULL,
  `Datetime` datetime NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Pressure` float NOT NULL,
  `Temperature` float DEFAULT NULL,
  `Humidity` float DEFAULT NULL,
  `Cloud` int(11) DEFAULT NULL,
  `Wind_Dir` float DEFAULT NULL,
  `Wind_Speed` float DEFAULT NULL,
  `Precipitation_6h` float DEFAULT NULL,
  `Precipitation_12h` float DEFAULT NULL,
  `Precipitation_24h` float DEFAULT NULL,
  `Phenomena` int(11) DEFAULT NULL,
  `Past_Phenomena_1` int(11) DEFAULT NULL,
  `Past_Phenomena_2` int(11) DEFAULT NULL,
  PRIMARY KEY (`SensorID`,`Datetime`),
  CONSTRAINT `fk_SYNOP_SENSOR?ID?` FOREIGN KEY (`SensorID`) REFERENCES `SENSOR` (`ID`)
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
  `Timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Access` int(11) DEFAULT NULL,
  `note` varchar(10000) DEFAULT NULL,
  `Pwd` blob NOT NULL,
  `Username` varchar(32) NOT NULL,
  `Surname` varchar(32) DEFAULT NULL,
  `Cookie` blob,
  `Firstname` varchar(32) DEFAULT NULL,
  `Address` varchar(128) DEFAULT NULL,
  `Phone` varchar(32) DEFAULT NULL,
  `ID` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-09-14 11:12:15
