-- phpMyAdmin SQL Dump
-- version 3.3.10
-- http://www.phpmyadmin.net
--
-- Host: mysql.onebit.me
-- Generation Time: Jun 01, 2011 at 11:59 PM
-- Server version: 5.1.39
-- PHP Version: 5.2.17

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `jlogsf0`
--

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
  `time_of_registration` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `is_tagged` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`runner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `runners`
--


