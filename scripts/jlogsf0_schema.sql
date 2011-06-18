-- phpMyAdmin SQL Dump
-- version 3.3.10
-- http://www.phpmyadmin.net
--
-- Host: mysql.onebit.me
-- Generation Time: Jun 17, 2011 at 11:58 PM
-- Server version: 5.1.39
-- PHP Version: 5.2.17

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `jlogsf0`
--

-- --------------------------------------------------------

--
-- Table structure for table `checkins`
--

DROP TABLE IF EXISTS `checkins`;
CREATE TABLE `checkins` (
  `checkin_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checkpoint_id` int(11) DEFAULT NULL,
  `checkin_time` datetime DEFAULT NULL,
  `device_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lng` double DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `is_valid` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`checkpoint_id`),
  KEY `index_checkins_on_checkpoint_id` (`checkpoint_id`),
  KEY `index_checkins_on_checkpoint_id_and_checkin_time_and_is_valid` (`checkpoint_id`,`checkin_time`,`is_valid`),
  KEY `index_checkins_on_checkin_time_and_checkpoint_id_and_is_valid` (`checkin_time`,`checkpoint_id`,`is_valid`),
  KEY `index_checkins_on_lat` (`lat`),
  KEY `index_checkins_on_lng` (`lng`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=12 ;

--
-- Dumping data for table `checkins`
--


-- --------------------------------------------------------

--
-- Table structure for table `checkpoints`
--

DROP TABLE IF EXISTS `checkpoints`;
CREATE TABLE `checkpoints` (
  `checkpoint_id` int(11) DEFAULT NULL,
  `checkpoint_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checkpoint_loc_lat` double DEFAULT NULL,
  `checkpoint_loc_long` double DEFAULT NULL,
  `is_mobile` tinyint(1) DEFAULT '0',
  `is_bonus` tinyint(1) DEFAULT '0',
  `checkpoint_position` int(11) DEFAULT NULL,
  KEY `checkpoint_id` (`checkpoint_id`),
  KEY `index_checkpoints_on_checkpoint_position` (`checkpoint_position`),
  KEY `index_checkpoints_on_checkpoint_loc_lat` (`checkpoint_loc_lat`),
  KEY `index_checkpoints_on_checkpoint_loc_long` (`checkpoint_loc_long`),
  KEY `index_checkpoints_on_is_mobile_and_is_bonus` (`is_mobile`,`is_bonus`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `checkpoints`
--

INSERT INTO `checkpoints` (`checkpoint_id`, `checkpoint_name`, `checkpoint_loc_lat`, `checkpoint_loc_long`, `is_mobile`, `is_bonus`, `checkpoint_position`) VALUES
(0, 'Registration', 0, 0, 0, 0, 0),
(3, 'Checkpoint 3', NULL, NULL, 0, 0, 3),
(4, 'Checkpoint 4', NULL, NULL, 0, 0, 4),
(5, 'Checkpoint 5', NULL, NULL, 0, 0, 5),
(6, 'Checkpoint 6', NULL, NULL, 0, 0, 6),
(7, 'Checkpoint 7', NULL, NULL, 0, 0, 7),
(10, 'Checkpoint 1A', NULL, NULL, 0, 0, 1),
(11, 'Checkpoint 1B', NULL, NULL, 0, 0, 1),
(20, 'Checkpoint 2A', NULL, NULL, 0, 0, 2),
(21, 'Checkpoint 2B', NULL, NULL, 0, 0, 2),
(100, 'Mobile Checkpoint 1', NULL, NULL, 1, 0, NULL),
(101, 'Mobile Checkpoint 2', NULL, NULL, 1, 0, NULL),
(102, 'Mobile Checkpoint 3', NULL, NULL, 1, 0, NULL),
(200, 'Bonus Checkpoint 1', NULL, NULL, 0, 1, NULL),
(201, 'Bonus Checkpoint 2', NULL, NULL, 0, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `runners`
--

DROP TABLE IF EXISTS `runners`;
CREATE TABLE `runners` (
  `runner_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_mugshot` tinyint(1) DEFAULT NULL,
  `time_of_mugshot` datetime DEFAULT NULL,
  `is_registered` tinyint(1) DEFAULT NULL,
  `time_of_registration` datetime DEFAULT NULL,
  `is_tagged` tinyint(1) DEFAULT NULL,
  KEY `runner_id` (`runner_id`),
  KEY `index_runners_on_is_tagged` (`is_tagged`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `runners`
--


-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagger_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tag_time` datetime DEFAULT NULL,
  `loc_lat` double(11,8) DEFAULT NULL,
  `loc_long` double(11,8) DEFAULT NULL,
  `loc_addr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `device_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`tagger_id`),
  KEY `tag_id` (`tag_id`),
  KEY `index_tags_on_tagger_id_and_runner_id` (`tagger_id`,`runner_id`),
  KEY `index_tags_on_loc_lat` (`loc_lat`),
  KEY `index_tags_on_loc_long` (`loc_long`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=12 ;

--
-- Dumping data for table `tags`
--


