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
  `checkin_time` datetime NOT NULL,
  `device_id` varchar(255) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `ip_address` varchar(255) NOT NULL,
  PRIMARY KEY (`checkin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `checkins`
--


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
  `mugshot_url` varchar(255) NOT NULL,
  `is_registered` tinyint(1) NOT NULL,
  `time_of_registration` datetime NOT NULL,
  `is_tagged` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`runner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



