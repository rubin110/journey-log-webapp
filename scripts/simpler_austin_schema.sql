SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Table structure for table `checkins`
--

DROP TABLE IF EXISTS `checkins`;
CREATE TABLE `checkins` (
  `runner_id` char(5) COLLATE utf8_unicode_ci NOT NULL,
  `checkpoint_id` char(5) COLLATE utf8_unicode_ci NOT NULL,
  `checked_in_earlier` int(11) NOT NULL DEFAULT 0,
  `checkin_time` datetime NOT NULL,
  PRIMARY KEY (`runner_id`,`checkpoint_id`),
  KEY `index_checkins_on_checkpoint_id_and_time` (`checkpoint_id`,`checkin_time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ;

-- --------------------------------------------------------

--
-- Table structure for table `checkpoints`
--

DROP TABLE IF EXISTS `checkpoints`;
CREATE TABLE `checkpoints` (
  `checkpoint_id` char(5) COLLATE utf8_unicode_ci NOT NULL,
  `checkpoint_order` int(11) NOT NULL,
  `checkpoint_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checked_in_so_far` int(11) NOT NULL DEFAULT 0,
  `first_checkin_at` datetime DEFAULT NULL,
  `first_runner` char(5) DEFAULT NULL,
  `most_recent_checkin_at` datetime DEFAULT NULL,
  `most_recent_runner` char(5) DEFAULT NULL,
  PRIMARY KEY (`checkpoint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `checkpoints` (`checkpoint_id`, `checkpoint_order`, `checkpoint_name`) VALUES
(substring(MD5(RAND()), -5), 0, 'Registration'),
(substring(MD5(RAND()), -5), 1, 'Checkpoint 1'),
(substring(MD5(RAND()), -5), 2, 'Checkpoint 2'),
(substring(MD5(RAND()), -5), 3, 'Checkpoint 3'),
(substring(MD5(RAND()), -5), 4, 'Checkpoint 4'),
(substring(MD5(RAND()), -5), 5, 'Checkpoint 5'),
(substring(MD5(RAND()), -5), 6, 'Finish');
UPDATE checkpoints SET checkpoint_id = UPPER(checkpoint_id);

-- --------------------------------------------------------

--
-- Table structure for table `runners`
--

DROP TABLE IF EXISTS `runners`;
CREATE TABLE `runners` (
  `runner_id` char(5) COLLATE utf8_unicode_ci NOT NULL,
  `player_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `player_twitter_handle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hashed_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_tagged` tinyint(1) DEFAULT 0,
  `num_tagged` int(11) DEFAULT 0,
  `created_at` datetime NOT NULL,
  PRIMARY KEY `runner_id` (`runner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `runner_id` char(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagger_id` char(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tag_time` datetime DEFAULT NULL,
  PRIMARY KEY (`runner_id`),
  KEY `index_tags_on_tagger` (`tagger_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ;
