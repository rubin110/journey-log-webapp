-- phpMyAdmin SQL Dump
-- version 3.3.10
-- http://www.phpmyadmin.net
--
-- Host: mysql.onebit.me
-- Generation Time: Jun 02, 2011 at 12:12 AM
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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `checkins`
--


