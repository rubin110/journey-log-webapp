-- phpMyAdmin SQL Dump
-- version 3.3.10
-- http://www.phpmyadmin.net
--
-- Host: mysql.onebit.me
-- Generation Time: Jun 06, 2011 at 09:21 PM
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

CREATE TABLE IF NOT EXISTS `checkins` (
  `checkin_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `runner_id` varchar(255) NOT NULL,
  `checkpoint_id` int(10) unsigned NOT NULL,
  `checkin_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `device_id` varchar(255) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `ip_address` varchar(255) NOT NULL,
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`checkpoint_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=19 ;

--
-- Dumping data for table `checkins`
--

INSERT INTO `checkins` (`checkin_id`, `runner_id`, `checkpoint_id`, `checkin_time`, `device_id`, `user_agent`, `ip_address`) VALUES
(6, 'DFH798', 0, '2011-06-02 00:13:29', 'some device', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1', '50.0.92.218'),
(8, 'DFH798', 5, '2011-06-02 00:14:46', 'some device', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1', '50.0.92.218'),
(9, '12345', 1, '2011-06-02 00:21:22', 'some device', 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5', '50.0.92.218'),
(11, '12345', 0, '2011-06-02 00:23:44', 'some device', 'Mozilla/5.0 (Linux; U; Android 2.3.3; en-us; HTC Vision Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1', '208.54.5.158'),
(12, '12345', 4, '2011-06-02 00:24:21', 'some device', 'Mozilla/5.0 (Linux; U; Android 2.3.3; en-us; HTC Vision Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1', '208.54.5.158'),
(17, '12345', 8, '2011-06-02 00:38:39', 'some device', 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_1_3 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7E18 Safari/528.16', '50.0.92.218'),
(18, '', 5, '2011-06-02 21:50:19', 'some device', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1', '50.0.92.218');

-- --------------------------------------------------------

--
-- Table structure for table `checkpoints`
--

CREATE TABLE IF NOT EXISTS `checkpoints` (
  `checkpoint_id` tinyint(3) unsigned NOT NULL,
  `checkpoint_name` varchar(255) NOT NULL,
  `checkpoint_loc_lat` decimal(10,0) DEFAULT NULL,
  `checkpoint_loc_long` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`checkpoint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `checkpoints`
--

INSERT INTO `checkpoints` (`checkpoint_id`, `checkpoint_name`, `checkpoint_loc_lat`, `checkpoint_loc_long`) VALUES
(0, 'Registration', 0, 0),
(1, 'Checkpoint 1', 0, 0),
(3, 'Checkpoint 3', NULL, NULL),
(4, 'Checkpoint 4', NULL, NULL),
(5, 'Checkpoint 5', NULL, NULL),
(6, 'Checkpoint 6', NULL, NULL),
(7, 'Checkpoint 7', NULL, NULL),
(8, 'Checkpoint 8', NULL, NULL),
(10, 'Checkpoint 1A', NULL, NULL),
(11, 'Checkpoint 1B', NULL, NULL),
(20, 'Checkpoint 2A', NULL, NULL),
(21, 'Checkpoint 2B', NULL, NULL),
(100, 'Mobile Checkpoint 1', NULL, NULL),
(101, 'Mobile Checkpoint 2', NULL, NULL),
(102, 'Mobile Checkpoint 3', NULL, NULL),
(200, 'Bonus Checkpoint 1', NULL, NULL),
(201, 'Bonus Checkpoint 2', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `runners`
--

CREATE TABLE IF NOT EXISTS `runners` (
  `runner_id` varchar(255) NOT NULL,
  `player_email` varchar(255) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `is_mugshot` tinyint(1) NOT NULL,
  `time_of_mugshot` varchar(255) timestamp NOT NULL,
  `is_registered` tinyint(1) NOT NULL,
  `time_of_registration` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_tagged` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`runner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `runners`
--

INSERT INTO `runners` (`runner_id`, `player_email`, `player_name`, `is_registered`, `time_of_registration`, `is_tagged`) VALUES
('123AB', 'edrabbit2@edrabbit.com', 'Ed', '', 1, '2011-06-02 23:23:52', 0),
('123AC', '', '', '', 0, '2011-06-02 23:26:22', 0);

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE IF NOT EXISTS `tags` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` varchar(255) NOT NULL,
  `tagger_id` varchar(255) NOT NULL,
  `tag_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `loc_lat` decimal(10,0) NOT NULL,
  `loc_long` decimal(10,0) NOT NULL,
  `device_id` varchar(255) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `ip_address` varchar(255) NOT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`tagger_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=17 ;

--
-- Dumping data for table `tags`
--

INSERT INTO `tags` (`tag_id`, `runner_id`, `tagger_id`, `tag_time`, `loc_lat`, `loc_long`, `device_id`, `user_agent`, `ip_address`) VALUES
(6, '123AC', '123AB', '2011-06-03 00:10:51', 37, -122, '', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1', '50.0.92.218');

