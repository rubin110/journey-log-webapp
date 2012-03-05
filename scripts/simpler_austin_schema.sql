SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Table structure for table `checkins`
--

DROP TABLE IF EXISTS `checkins`;
CREATE TABLE `checkins` (
  `checkin_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` int(11),
  `checkpoint_id` int(11),
  `checkin_time` datetime DEFAULT NULL,
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `runner_id` (`runner_id`,`checkpoint_id`),
  KEY `index_checkins_on_checkpoint_id_and_time` (`checkpoint_id`,`checkin_time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ;

-- --------------------------------------------------------

--
-- Table structure for table `checkpoints`
--

DROP TABLE IF EXISTS `checkpoints`;
CREATE TABLE `checkpoints` (
  `checkpoint_id` int(11) NOT NULL AUTO_INCREMENT,
  `checkpoint_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checked_in_so_far` int(11) DEFAULT 0,
  PRIMARY KEY (`checkpoint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `checkpoints` (`checkpoint_id`, `checkpoint_name`) VALUES
(0, 'Registration'),
(1, 'Checkpoint 1'),
(2, 'Checkpoint 2'),
(3, 'Checkpoint 3'),
(4, 'Checkpoint 4'),
(5, 'Checkpoint 5'),
(6, 'Finish');

-- --------------------------------------------------------

--
-- Table structure for table `runners`
--

DROP TABLE IF EXISTS `runners`;
CREATE TABLE `runners` (
  `runner_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_code` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `twitter_handle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_tagged` tinyint(1) DEFAULT NULL,
  PRIMARY KEY `runner_id` (`runner_id`),
  KEY `index_runners_on_code` (`runner_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `runner_id` int(11) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagger_id` int(11) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tag_time` datetime DEFAULT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `runner_id` (`runner_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ;
