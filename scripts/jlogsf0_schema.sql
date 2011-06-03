-- phpMyAdmin SQL Dump
-- version 3.3.10
-- http://www.phpmyadmin.net
--
-- Host: mysql.onebit.me
-- Generation Time: Jun 03, 2011 at 12:38 AM
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

