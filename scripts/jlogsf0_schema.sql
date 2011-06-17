-- MySQL dump 10.13  Distrib 5.1.54, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: jlogsf0
-- ------------------------------------------------------
-- Server version	5.1.54-1ubuntu4

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
-- Table structure for table `checkins`
--

DROP TABLE IF EXISTS `checkins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `checkins` (
  `checkin_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checkpoint_id` int(11) DEFAULT NULL,
  `checkin_time` datetime DEFAULT NULL,
  `device_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `is_valid` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`checkpoint_id`),
  KEY `checkin_id` (`checkin_id`),
  KEY `index_checkins_on_checkin_time_and_checkpoint_id_and_is_valid` (`checkin_time`,`checkpoint_id`,`is_valid`),
  KEY `index_checkins_on_checkpoint_id_and_checkin_time_and_is_valid` (`checkpoint_id`,`checkin_time`,`is_valid`),
  KEY `index_checkins_on_checkpoint_id` (`checkpoint_id`),
  KEY `index_checkins_on_lat` (`lat`),
  KEY `index_checkins_on_lng` (`lng`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checkins`
--

LOCK TABLES `checkins` WRITE;
/*!40000 ALTER TABLE `checkins` DISABLE KEYS */;
/*!40000 ALTER TABLE `checkins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `checkpoints`
--

DROP TABLE IF EXISTS `checkpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `checkpoints` (
  `checkpoint_id` int(11) DEFAULT NULL,
  `checkpoint_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checkpoint_loc_lat` float DEFAULT NULL,
  `checkpoint_loc_long` float DEFAULT NULL,
  `is_mobile` tinyint(1) DEFAULT '0',
  `is_bonus` tinyint(1) DEFAULT '0',
  `checkpoint_position` int(11) DEFAULT NULL,
  KEY `checkpoint_id` (`checkpoint_id`),
  KEY `index_checkpoints_on_checkpoint_loc_lat` (`checkpoint_loc_lat`),
  KEY `index_checkpoints_on_checkpoint_loc_long` (`checkpoint_loc_long`),
  KEY `index_checkpoints_on_checkpoint_position` (`checkpoint_position`),
  KEY `index_checkpoints_on_is_mobile_and_is_bonus` (`is_mobile`,`is_bonus`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checkpoints`
--

LOCK TABLES `checkpoints` WRITE;
/*!40000 ALTER TABLE `checkpoints` DISABLE KEYS */;
/*!40000 ALTER TABLE `checkpoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runners`
--

DROP TABLE IF EXISTS `runners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `runners` (
  `runner_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_mugshot` tinyint(1) DEFAULT NULL,
  `time_of_mugshot` datetime DEFAULT NULL,
  `is_registered` tinyint(1) DEFAULT NULL,
  `time_of_registration` datetime DEFAULT NULL,
  `is_tagged` tinyint(1) DEFAULT NULL,
  KEY `index_runners_on_is_tagged` (`is_tagged`),
  KEY `runner_id` (`runner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runners`
--

LOCK TABLES `runners` WRITE;
/*!40000 ALTER TABLE `runners` DISABLE KEYS */;
/*!40000 ALTER TABLE `runners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20110531221201'),('20110531221315'),('20110531221431'),('20110602000000'),('20110615000000'),('20110615000001'),('20110615000002');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagger_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tag_time` datetime DEFAULT NULL,
  `loc_lat` float DEFAULT NULL,
  `loc_long` float DEFAULT NULL,
  `loc_addr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `device_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`tagger_id`),
  KEY `index_tags_on_loc_lat` (`loc_lat`),
  KEY `index_tags_on_loc_long` (`loc_long`),
  KEY `tag_id` (`tag_id`),
  KEY `index_tags_on_tagger_id_and_runner_id` (`tagger_id`,`runner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-06-17  8:09:37
