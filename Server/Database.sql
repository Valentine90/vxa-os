-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 13-Jan-2021 às 17:02
-- Versão do servidor: 10.4.17-MariaDB
-- versão do PHP: 8.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `vxaos_db`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  -- A senha é criptografada no formato de hash MD5, com valor fixo
  -- de hash de 128 bits expresso em 32 caracteres
  `password` varchar(32) NOT NULL,
  `email` varchar(50) NOT NULL,
  `group` tinyint(11) NOT NULL DEFAULT 0,
  `creation_date` bigint(20) NOT NULL,
  `vip_time` bigint(20) NOT NULL,
  `cash` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `accounts`
--

INSERT INTO `accounts` (`id`, `username`, `password`, `email`, `group`, `creation_date`, `vip_time`, `cash`) VALUES
(1, 'admin', '21232f297a57a5a743894a0e4a801fc3', 'admin@vxaos.com', 2, 1610553107, 1611417561, '0'),
(2, 'lola', 'fceeb9b9d469401fe558062c4bd25954', 'lola@vxaos.com', 0, 1610553127, 1610553152, '0');

-- --------------------------------------------------------

--
-- Estrutura da tabela `account_friends`
--

CREATE TABLE `account_friends` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `account_friends`
--

INSERT INTO `account_friends` (`id`, `account_id`, `name`) VALUES
(1, 2, 'Admin'),
(2, 1, 'Lola');

-- --------------------------------------------------------

--
-- Estrutura da tabela `actors`
--

CREATE TABLE `actors` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `slot_id` tinyint(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `character_name` varchar(60) NOT NULL,
  `character_index` tinyint(11) NOT NULL,
  `face_name` varchar(60) NOT NULL,
  `face_index` tinyint(11) NOT NULL,
  `class_id` smallint(11) NOT NULL,
  `sex` tinyint(11) NOT NULL,
  `level` smallint(11) NOT NULL,
  `exp` int(11) NOT NULL,
  `hp` int(11) NOT NULL,
  `mp` int(11) NOT NULL,
  `mhp` int(11) NOT NULL,
  `mmp` int(11) NOT NULL,
  `atk` int(11) NOT NULL,
  `def` int(11) NOT NULL,
  `int` int(11) NOT NULL,
  `res` int(11) NOT NULL,
  `agi` int(11) NOT NULL,
  `luk` int(11) NOT NULL,
  `points` smallint(11) NOT NULL,
  `guild_id` int(11) NOT NULL DEFAULT 0,
  `revive_map_id` smallint(11) NOT NULL,
  `revive_x` smallint(11) NOT NULL,
  `revive_y` smallint(11) NOT NULL,
  `map_id` smallint(11) NOT NULL,
  `x` smallint(11) NOT NULL,
  `y` smallint(11) NOT NULL,
  `direction` tinyint(11) NOT NULL,
  `gold` int(11) NOT NULL DEFAULT 0,
  `online` tinyint(11) NOT NULL DEFAULT 0,
  `creation_date` bigint(20) NOT NULL,
  `last_login` bigint(20) NOT NULL,
  `comment` text NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actors`
--

INSERT INTO `actors` (`id`, `account_id`, `slot_id`, `name`, `character_name`, `character_index`, `face_name`, `face_index`, `class_id`, `sex`, `level`, `exp`, `hp`, `mp`, `mhp`, `mmp`, `atk`, `def`, `int`, `res`, `agi`, `luk`, `points`, `guild_id`, `revive_map_id`, `revive_x`, `revive_y`, `map_id`, `x`, `y`, `direction`, `gold`, `online`, `creation_date`, `last_login`, `comment`) VALUES
(1, 1, 0, 'Admin', 'Charset01', 0, 'Charset01', 0, 1, 0, 3, 251, 562, 41, 562, 41, 35, 16, 10, 10, 20, 15, 5, 1, 1, 14, 3, 1, 21, 12, 2, 135, 0, 1610553113, 1610553586, ''),
(2, 2, 0, 'Lola', 'Charset04', 4, 'Charset04', 4, 2, 1, 1, 0, 682, 46, 682, 46, 22, 14, 11, 12, 35, 15, 10, 0, 1, 21, 12, 1, 20, 13, 2, 0, 0, 1610553138, 1610553152, '');

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_armors`
--

CREATE TABLE `actor_armors` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `armor_id` smallint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_equips`
--

CREATE TABLE `actor_equips` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `slot_id` tinyint(11) NOT NULL,
  `equip_id` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_equips`
--

INSERT INTO `actor_equips` (`id`, `actor_id`, `slot_id`, `equip_id`) VALUES
(1, 1, 0, 1),
(2, 1, 1, 46),
(3, 1, 2, 26),
(4, 1, 3, 1),
(5, 1, 4, 57),
(6, 1, 5, 54),
(7, 1, 6, 61),
(8, 1, 7, 62),
(9, 1, 8, 63),
(10, 2, 0, 7),
(11, 2, 1, 0),
(12, 2, 2, 0),
(13, 2, 3, 1),
(14, 2, 4, 0),
(15, 2, 5, 0),
(16, 2, 6, 0),
(17, 2, 7, 0),
(18, 2, 8, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_hotbars`
--

CREATE TABLE `actor_hotbars` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `slot_id` tinyint(11) NOT NULL,
  `type` tinyint(11) NOT NULL DEFAULT 0,
  `item_id` smallint(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_hotbars`
--

INSERT INTO `actor_hotbars` (`id`, `actor_id`, `slot_id`, `type`, `item_id`) VALUES
(1, 1, 0, 2, 26),
(2, 1, 1, 1, 1),
(3, 1, 2, 2, 51),
(4, 1, 3, 2, 53),
(5, 1, 4, 2, 70),
(6, 1, 5, 2, 80),
(7, 1, 6, 2, 85),
(8, 1, 7, 2, 127),
(9, 1, 8, 2, 128),
(10, 2, 0, 0, 0),
(11, 2, 1, 0, 0),
(12, 2, 2, 0, 0),
(13, 2, 3, 0, 0),
(14, 2, 4, 0, 0),
(15, 2, 5, 0, 0),
(16, 2, 6, 0, 0),
(17, 2, 7, 0, 0),
(18, 2, 8, 0, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_items`
--

CREATE TABLE `actor_items` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `item_id` smallint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_items`
--

INSERT INTO `actor_items` (`id`, `actor_id`, `item_id`, `amount`) VALUES
(1, 1, 1, 4),
(2, 1, 17, 1),
(3, 1, 7, 2),
(4, 1, 18, 50),
(5, 1, 20, 1),
(6, 1, 24, 50),
(7, 1, 22, 1),
(8, 1, 21, 1),
(9, 1, 19, 1),
(10, 1, 4, 5);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_quests`
--

CREATE TABLE `actor_quests` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `quest_id` smallint(11) NOT NULL,
  `state` tinyint(11) NOT NULL,
  `kills` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_quests`
--

INSERT INTO `actor_quests` (`id`, `actor_id`, `quest_id`, `state`, `kills`) VALUES
(1, 1, 0, 1, 0),
(2, 1, 1, 0, 5);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_self_switches`
--

CREATE TABLE `actor_self_switches` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `map_id` smallint(11) NOT NULL,
  `event_id` smallint(11) NOT NULL,
  `ch` varchar(1) NOT NULL,
  `value` tinyint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_self_switches`
--

INSERT INTO `actor_self_switches` (`id`, `actor_id`, `map_id`, `event_id`, `ch`, `value`) VALUES
(1, 1, 1, 25, 'A', 1),
(2, 1, 1, 1, 'A', 1),
(3, 1, 1, 17, 'A', 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_skills`
--

CREATE TABLE `actor_skills` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `skill_id` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_skills`
--

INSERT INTO `actor_skills` (`id`, `actor_id`, `skill_id`) VALUES
(1, 1, 80),
(2, 2, 85),
(3, 1, 26),
(4, 1, 51),
(5, 1, 53),
(6, 1, 70),
(7, 1, 85),
(8, 1, 127),
(9, 1, 128);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_switches`
--

CREATE TABLE `actor_switches` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `switch_id` smallint(11) NOT NULL,
  `value` tinyint(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_switches`
--

INSERT INTO `actor_switches` (`id`, `actor_id`, `switch_id`, `value`) VALUES
(1, 1, 1, 0),
(2, 1, 2, 0),
(3, 1, 3, 0),
(4, 1, 4, 0),
(5, 1, 5, 0),
(6, 1, 6, 0),
(7, 1, 7, 0),
(8, 1, 8, 0),
(9, 1, 9, 0),
(10, 1, 10, 0),
(11, 1, 11, 0),
(12, 1, 12, 0),
(13, 1, 13, 0),
(14, 1, 14, 0),
(15, 1, 15, 0),
(16, 1, 16, 0),
(17, 1, 17, 0),
(18, 1, 18, 0),
(19, 1, 19, 0),
(20, 1, 20, 0),
(21, 1, 21, 0),
(22, 1, 22, 0),
(23, 1, 23, 0),
(24, 1, 24, 0),
(25, 1, 25, 0),
(26, 1, 26, 0),
(27, 1, 27, 0),
(28, 1, 28, 0),
(29, 1, 29, 0),
(30, 1, 30, 0),
(31, 1, 31, 0),
(32, 1, 32, 0),
(33, 1, 33, 0),
(34, 1, 34, 0),
(35, 1, 35, 0),
(36, 1, 36, 0),
(37, 1, 37, 0),
(38, 1, 38, 0),
(39, 1, 39, 0),
(40, 1, 40, 0),
(41, 1, 41, 0),
(42, 1, 42, 0),
(43, 1, 43, 0),
(44, 1, 44, 0),
(45, 1, 45, 0),
(46, 1, 46, 0),
(47, 1, 47, 0),
(48, 1, 48, 0),
(49, 1, 49, 0),
(50, 1, 50, 0),
(51, 1, 51, 0),
(52, 1, 52, 0),
(53, 1, 53, 0),
(54, 1, 54, 0),
(55, 1, 55, 0),
(56, 1, 56, 0),
(57, 1, 57, 0),
(58, 1, 58, 0),
(59, 1, 59, 0),
(60, 1, 60, 0),
(61, 1, 61, 0),
(62, 1, 62, 0),
(63, 1, 63, 0),
(64, 1, 64, 0),
(65, 1, 65, 0),
(66, 1, 66, 0),
(67, 1, 67, 0),
(68, 1, 68, 0),
(69, 1, 69, 0),
(70, 1, 70, 0),
(71, 1, 71, 0),
(72, 1, 72, 0),
(73, 1, 73, 0),
(74, 1, 74, 0),
(75, 1, 75, 0),
(76, 1, 76, 0),
(77, 1, 77, 0),
(78, 1, 78, 0),
(79, 1, 79, 0),
(80, 1, 80, 0),
(81, 1, 81, 0),
(82, 1, 82, 0),
(83, 1, 83, 0),
(84, 1, 84, 0),
(85, 1, 85, 0),
(86, 1, 86, 0),
(87, 1, 87, 0),
(88, 1, 88, 0),
(89, 1, 89, 0),
(90, 1, 90, 0),
(91, 1, 91, 0),
(92, 1, 92, 0),
(93, 1, 93, 0),
(94, 1, 94, 0),
(95, 1, 95, 0),
(96, 1, 96, 0),
(97, 1, 97, 0),
(98, 1, 98, 0),
(99, 1, 99, 0),
(100, 1, 100, 0),
(101, 2, 1, 0),
(102, 2, 2, 0),
(103, 2, 3, 0),
(104, 2, 4, 0),
(105, 2, 5, 0),
(106, 2, 6, 0),
(107, 2, 7, 0),
(108, 2, 8, 0),
(109, 2, 9, 0),
(110, 2, 10, 0),
(111, 2, 11, 0),
(112, 2, 12, 0),
(113, 2, 13, 0),
(114, 2, 14, 0),
(115, 2, 15, 0),
(116, 2, 16, 0),
(117, 2, 17, 0),
(118, 2, 18, 0),
(119, 2, 19, 0),
(120, 2, 20, 0),
(121, 2, 21, 0),
(122, 2, 22, 0),
(123, 2, 23, 0),
(124, 2, 24, 0),
(125, 2, 25, 0),
(126, 2, 26, 0),
(127, 2, 27, 0),
(128, 2, 28, 0),
(129, 2, 29, 0),
(130, 2, 30, 0),
(131, 2, 31, 0),
(132, 2, 32, 0),
(133, 2, 33, 0),
(134, 2, 34, 0),
(135, 2, 35, 0),
(136, 2, 36, 0),
(137, 2, 37, 0),
(138, 2, 38, 0),
(139, 2, 39, 0),
(140, 2, 40, 0),
(141, 2, 41, 0),
(142, 2, 42, 0),
(143, 2, 43, 0),
(144, 2, 44, 0),
(145, 2, 45, 0),
(146, 2, 46, 0),
(147, 2, 47, 0),
(148, 2, 48, 0),
(149, 2, 49, 0),
(150, 2, 50, 0),
(151, 2, 51, 0),
(152, 2, 52, 0),
(153, 2, 53, 0),
(154, 2, 54, 0),
(155, 2, 55, 0),
(156, 2, 56, 0),
(157, 2, 57, 0),
(158, 2, 58, 0),
(159, 2, 59, 0),
(160, 2, 60, 0),
(161, 2, 61, 0),
(162, 2, 62, 0),
(163, 2, 63, 0),
(164, 2, 64, 0),
(165, 2, 65, 0),
(166, 2, 66, 0),
(167, 2, 67, 0),
(168, 2, 68, 0),
(169, 2, 69, 0),
(170, 2, 70, 0),
(171, 2, 71, 0),
(172, 2, 72, 0),
(173, 2, 73, 0),
(174, 2, 74, 0),
(175, 2, 75, 0),
(176, 2, 76, 0),
(177, 2, 77, 0),
(178, 2, 78, 0),
(179, 2, 79, 0),
(180, 2, 80, 0),
(181, 2, 81, 0),
(182, 2, 82, 0),
(183, 2, 83, 0),
(184, 2, 84, 0),
(185, 2, 85, 0),
(186, 2, 86, 0),
(187, 2, 87, 0),
(188, 2, 88, 0),
(189, 2, 89, 0),
(190, 2, 90, 0),
(191, 2, 91, 0),
(192, 2, 92, 0),
(193, 2, 93, 0),
(194, 2, 94, 0),
(195, 2, 95, 0),
(196, 2, 96, 0),
(197, 2, 97, 0),
(198, 2, 98, 0),
(199, 2, 99, 0),
(200, 2, 100, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_variables`
--

CREATE TABLE `actor_variables` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `variable_id` smallint(11) NOT NULL,
  `value` smallint(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_variables`
--

INSERT INTO `actor_variables` (`id`, `actor_id`, `variable_id`, `value`) VALUES
(1, 1, 1, 0),
(2, 1, 2, 0),
(3, 1, 3, 0),
(4, 1, 4, 0),
(5, 1, 5, 0),
(6, 1, 6, 0),
(7, 1, 7, 0),
(8, 1, 8, 0),
(9, 1, 9, 0),
(10, 1, 10, 0),
(11, 1, 11, 0),
(12, 1, 12, 0),
(13, 1, 13, 0),
(14, 1, 14, 0),
(15, 1, 15, 0),
(16, 1, 16, 0),
(17, 1, 17, 0),
(18, 1, 18, 0),
(19, 1, 19, 0),
(20, 1, 20, 0),
(21, 1, 21, 0),
(22, 1, 22, 0),
(23, 1, 23, 0),
(24, 1, 24, 0),
(25, 1, 25, 0),
(26, 1, 26, 0),
(27, 1, 27, 0),
(28, 1, 28, 0),
(29, 1, 29, 0),
(30, 1, 30, 0),
(31, 1, 31, 0),
(32, 1, 32, 0),
(33, 1, 33, 0),
(34, 1, 34, 0),
(35, 1, 35, 0),
(36, 1, 36, 0),
(37, 1, 37, 0),
(38, 1, 38, 0),
(39, 1, 39, 0),
(40, 1, 40, 0),
(41, 1, 41, 0),
(42, 1, 42, 0),
(43, 1, 43, 0),
(44, 1, 44, 0),
(45, 1, 45, 0),
(46, 1, 46, 0),
(47, 1, 47, 0),
(48, 1, 48, 0),
(49, 1, 49, 0),
(50, 1, 50, 0),
(51, 1, 51, 0),
(52, 1, 52, 0),
(53, 1, 53, 0),
(54, 1, 54, 0),
(55, 1, 55, 0),
(56, 1, 56, 0),
(57, 1, 57, 0),
(58, 1, 58, 0),
(59, 1, 59, 0),
(60, 1, 60, 0),
(61, 1, 61, 0),
(62, 1, 62, 0),
(63, 1, 63, 0),
(64, 1, 64, 0),
(65, 1, 65, 0),
(66, 1, 66, 0),
(67, 1, 67, 0),
(68, 1, 68, 0),
(69, 1, 69, 0),
(70, 1, 70, 0),
(71, 1, 71, 0),
(72, 1, 72, 0),
(73, 1, 73, 0),
(74, 1, 74, 0),
(75, 1, 75, 0),
(76, 1, 76, 0),
(77, 1, 77, 0),
(78, 1, 78, 0),
(79, 1, 79, 0),
(80, 1, 80, 0),
(81, 1, 81, 0),
(82, 1, 82, 0),
(83, 1, 83, 0),
(84, 1, 84, 0),
(85, 1, 85, 0),
(86, 1, 86, 0),
(87, 1, 87, 0),
(88, 1, 88, 0),
(89, 1, 89, 0),
(90, 1, 90, 0),
(91, 1, 91, 0),
(92, 1, 92, 0),
(93, 1, 93, 0),
(94, 1, 94, 0),
(95, 1, 95, 0),
(96, 1, 96, 0),
(97, 1, 97, 0),
(98, 1, 98, 0),
(99, 1, 99, 0),
(100, 1, 100, 0),
(101, 2, 1, 0),
(102, 2, 2, 0),
(103, 2, 3, 0),
(104, 2, 4, 0),
(105, 2, 5, 0),
(106, 2, 6, 0),
(107, 2, 7, 0),
(108, 2, 8, 0),
(109, 2, 9, 0),
(110, 2, 10, 0),
(111, 2, 11, 0),
(112, 2, 12, 0),
(113, 2, 13, 0),
(114, 2, 14, 0),
(115, 2, 15, 0),
(116, 2, 16, 0),
(117, 2, 17, 0),
(118, 2, 18, 0),
(119, 2, 19, 0),
(120, 2, 20, 0),
(121, 2, 21, 0),
(122, 2, 22, 0),
(123, 2, 23, 0),
(124, 2, 24, 0),
(125, 2, 25, 0),
(126, 2, 26, 0),
(127, 2, 27, 0),
(128, 2, 28, 0),
(129, 2, 29, 0),
(130, 2, 30, 0),
(131, 2, 31, 0),
(132, 2, 32, 0),
(133, 2, 33, 0),
(134, 2, 34, 0),
(135, 2, 35, 0),
(136, 2, 36, 0),
(137, 2, 37, 0),
(138, 2, 38, 0),
(139, 2, 39, 0),
(140, 2, 40, 0),
(141, 2, 41, 0),
(142, 2, 42, 0),
(143, 2, 43, 0),
(144, 2, 44, 0),
(145, 2, 45, 0),
(146, 2, 46, 0),
(147, 2, 47, 0),
(148, 2, 48, 0),
(149, 2, 49, 0),
(150, 2, 50, 0),
(151, 2, 51, 0),
(152, 2, 52, 0),
(153, 2, 53, 0),
(154, 2, 54, 0),
(155, 2, 55, 0),
(156, 2, 56, 0),
(157, 2, 57, 0),
(158, 2, 58, 0),
(159, 2, 59, 0),
(160, 2, 60, 0),
(161, 2, 61, 0),
(162, 2, 62, 0),
(163, 2, 63, 0),
(164, 2, 64, 0),
(165, 2, 65, 0),
(166, 2, 66, 0),
(167, 2, 67, 0),
(168, 2, 68, 0),
(169, 2, 69, 0),
(170, 2, 70, 0),
(171, 2, 71, 0),
(172, 2, 72, 0),
(173, 2, 73, 0),
(174, 2, 74, 0),
(175, 2, 75, 0),
(176, 2, 76, 0),
(177, 2, 77, 0),
(178, 2, 78, 0),
(179, 2, 79, 0),
(180, 2, 80, 0),
(181, 2, 81, 0),
(182, 2, 82, 0),
(183, 2, 83, 0),
(184, 2, 84, 0),
(185, 2, 85, 0),
(186, 2, 86, 0),
(187, 2, 87, 0),
(188, 2, 88, 0),
(189, 2, 89, 0),
(190, 2, 90, 0),
(191, 2, 91, 0),
(192, 2, 92, 0),
(193, 2, 93, 0),
(194, 2, 94, 0),
(195, 2, 95, 0),
(196, 2, 96, 0),
(197, 2, 97, 0),
(198, 2, 98, 0),
(199, 2, 99, 0),
(200, 2, 100, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `actor_weapons`
--

CREATE TABLE `actor_weapons` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `weapon_id` smallint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `actor_weapons`
--

INSERT INTO `actor_weapons` (`id`, `actor_id`, `weapon_id`, `amount`) VALUES
(1, 1, 13, 1),
(2, 1, 31, 1),
(3, 1, 49, 1),
(4, 1, 3, 1),
(5, 1, 61, 1),
(6, 1, 62, 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `banks`
--

CREATE TABLE `banks` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `gold` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `banks`
--

INSERT INTO `banks` (`id`, `account_id`, `gold`) VALUES
(1, 1, 5),
(2, 2, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `bank_armors`
--

CREATE TABLE `bank_armors` (
  `id` int(11) NOT NULL,
  `bank_id` int(11) NOT NULL,
  `armor_id` smallint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `bank_items`
--

CREATE TABLE `bank_items` (
  `id` int(11) NOT NULL,
  `bank_id` int(11) NOT NULL,
  `item_id` smallint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `bank_items`
--

INSERT INTO `bank_items` (`id`, `bank_id`, `item_id`, `amount`) VALUES
(1, 1, 1, 5);

-- --------------------------------------------------------

--
-- Estrutura da tabela `bank_weapons`
--

CREATE TABLE `bank_weapons` (
  `id` int(11) NOT NULL,
  `bank_id` int(11) NOT NULL,
  `weapon_id` smallint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `ban_list`
--

CREATE TABLE `ban_list` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  -- Em regra, endereços IPv6, sucessor do IPv4, têm até 45 caracteres
  `ip` varchar(45) NOT NULL,
  `time` bigint(20) NOT NULL,
  `ban_date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `configs`
--

CREATE TABLE `configs` (
  `id` int(11) NOT NULL,
  `titlesite` text NOT NULL,
  `cashname` text NOT NULL,
  `maxrank` int(11) NOT NULL,
  `maxrankguild` int(11) NOT NULL,
  `maxitemstore` int(11) NOT NULL,
  `downloadlink` text NOT NULL,
  `discount` text NOT NULL,
  `languages` text NOT NULL,
  `langdefault` text NOT NULL,
  `ipserver` text NOT NULL,
  `portserver` int(11) NOT NULL,
  `maxnews` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `configs`
--

INSERT INTO `configs` (`id`, `titlesite`, `cashname`, `maxrank`, `maxrankguild`, `maxitemstore`, `downloadlink`, `discount`, `languages`, `langdefault`, `ipserver`, `portserver`, `maxnews`) VALUES
(1, 'VX Ace-OS Site Beta v2', 'Diamantes', 30, 30, 50, '../file/VXAOS.exe', '20', 'ptBR,enUS', 'ptBR', '127.0.0.1', 5000, 10);

-- --------------------------------------------------------

--
-- Estrutura da tabela `distributor`
--

CREATE TABLE `distributor` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `item_id` smallint(11) NOT NULL,
  `kind` tinyint(11) NOT NULL,
  `amount` smallint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guilds`
--

CREATE TABLE `guilds` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `leader` varchar(20) NOT NULL,
  `notice` text NOT NULL DEFAULT '',
  `description` text NOT NULL DEFAULT '',
  `flag` text NOT NULL,
  `creation_date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `guilds`
--

INSERT INTO `guilds` (`id`, `name`, `leader`, `notice`, `description`, `flag`, `creation_date`) VALUES
(1, 'Fenix', 'Admin', 'Notícias aqui.', '', '2,14,14,14,14,14,255,14,255,2,14,14,14,14,14,255,255,255,2,14,14,14,14,14,255,255,14,14,14,14,14,14,255,255,14,14,14,14,14,14,255,255,14,14,14,2,14,14,255,2,255,255,255,255,2,14,2,255,255,255,255,255,255,2', 1610553216);

-- --------------------------------------------------------

--
-- Estrutura para tabela `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` text NOT NULL,
  `content` text NOT NULL,
  `date` text NOT NULL,
  `writer` text NOT NULL,
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Fazendo dump de dados para tabela `news`
--

INSERT INTO `news` (`id`, `title`, `content`, `date`, `writer`, `type`) VALUES
(2, 'Balancing Changes', '<p><img src=\"https://static.tibia.com/images/global/letters/letter_martel_S.gif\" />ince their release, the Soul War hunting grounds have been adjusted several times to curb their massive profitability, both in terms of loot and experience. Still, even after these changes, they were highly lucrative!</p>\r\n\r\n<p>After the&nbsp;<img src=\"https://static.tibia.com/images/news/balancingnews_abacuscalculations_250x214.png\" style=\"float:right; height:214px; width:250px\" />vocation adjustments last November, these hunting grounds have become even more profitable than before, both in terms of loot and XP. In order to address this, we have decided to make these hunting grounds more challenging while also tweaking two spells, which have overall proven to be too strong in hunts.</p>\r\n\r\n<p>The knight&#39;s Chivalrous Challenge will now only chain up to 3 creatures, instead of previously 5. The sorcerer&#39;s Expose Weakness will increase the sensitivity of hit creatures now to a slightly lesser degree.</p>\r\n\r\n<p>In the Soul War hunting grounds, every creature can now walk across every field. The phantoms in these hunting grounds, with the exception of the hazardous phantoms in Ebb and Flow, receive a new chain spell, which has a range of 7 fields and deals more damage to targets later in the chain. Up to four players can be struck by this spell, i.e. the initial target and three additional ones. The chance for the spell to trigger is highest in the Furious Crater and the Rotten Wastelands, while it is lowest in Ebb and Flow, with the chance for it triggering in Claustrophobic Inferno and Mirrored Nightmare lying in the middle.</p>\r\n\r\n<p>These changes will be implemented<strong>&nbsp;</strong>next week,&nbsp;<strong>Tuesday, March 9</strong>. We will of course monitor the situation and look at the effects of the changes. Further adjustments are possible if we deem them necessary.</p>\r\n\r\n<p>See you in Tibia,<br />\r\nYour Community Managers</p>\r\n', '1615390473', 'admi', 2),
(3, 'Podium of Renown', '<p><img src=\"https://static.tibia.com/images/global/letters/letter_martel_D.gif\" />o you possess more mounts than you could ever ride into battle? Do you own so many outfits that it is hard for you to choose which one to wear? Or do you simply have a few that you are particularly proud of?</p>\r\n\r\n<p>Then you might want to show them off in your own four walls: With the&nbsp;<strong>podium of renown</strong>, which has been added to the Store today, you can exhibit any mount or outfit of yours at home.</p>\r\n\r\n<p><img src=\"https://static.tibia.com/images/news/banner_podium_goldenborder.jpg\" style=\"height:200px; width:549px\" /></p>\r\n\r\n<p>You may either only display a mount or an outfit (whose addons can be configured as well), or both at the same time. It is also possible to choose between the male and female version of an outfit. The podium whereupon mount and outfit rest can be rotated and even hidden. Moreover, it has an illumination effect which can be switched on and off. The same mount and outfit can be exhibited on several podiums at the same time and can also be displayed when currently used by the owner.</p>\r\n\r\n<p>We hope you enjoy this new deco item,<br />\r\nYour Community Managers</p>\r\n', '1615392008', 'admin', 1),
(4, 'Double XP and Double Skill Weekend', '<p><img src=\"https://static.tibia.com/images/global/letters/letter_martel_A.gif\" />re&nbsp;<img src=\"https://static.tibia.com/images/news/doublexpnskill_small.png\" style=\"float:right; height:215px; width:250px\" />you looking for an opportunity to level up and improve your skills? A double XP and double skill weekend is coming! So sharpen your weapons and stock up your potions, a weekend full of excessive monster slaughtering is waiting for you!</p>\r\n\r\n<p>Between the server saves of&nbsp;<strong>March 05</strong>&nbsp;and&nbsp;<strong><strong>March&nbsp;</strong>08</strong>,&nbsp;all monsters will yield twice the usual amount of experience points, and your skill training, including magic level, will advance twice as fast. The skill progress when training offline will also be doubled.</p>\r\n\r\n<p>Have fun,<br />\r\nYour Community Managers</p>\r\n', '1615392226', 'admin', 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `payment_voucher`
--

CREATE TABLE `payment_voucher` (
  `id` int(11) NOT NULL,
  `account_id` text NOT NULL,
  `date` bigint(20) NOT NULL,
  `amount` text NOT NULL,
  `img` text NOT NULL,
  `reader` int(11) NOT NULL,
  `okay` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `payment_voucher`
--

INSERT INTO `payment_voucher` (`id`, `account_id`, `date`, `amount`, `img`, `reader`, `okay`) VALUES
(1, 'admin', 1607207840, '1000', '16072078405fcc0ba06ee13.png', 1, 1),
(2, 'admin', 1607208416, '1000', '16072084165fcc0de0a9425.png', 1, 1),
(3, 'admin', 1607208426, '1000', '16072084265fcc0dea7a8e4.png', 1, 1),
(4, 'admin', 1607209695, '5000', '16072096955fcc12dfafdb9.png', 1, 1),
(5, 'admin', 1607210023, '9000', '16072100235fcc142739d27.png', 1, 1),
(6, 'nietore', 1607213196, '111111', '16072131965fcc208c1cb39.jpg', 1, 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `records`
--

CREATE TABLE `records` (
  `id` int(11) NOT NULL,
  `text` text NOT NULL,
  `date` text NOT NULL,
  `account_id` int(11) NOT NULL,
  `purchase_id` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `store`
--

CREATE TABLE `store` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `name` text NOT NULL,
  `description` text NOT NULL,
  `price` text NOT NULL,
  `img` text NOT NULL,
  `amount` text NOT NULL,
  `purchased` text NOT NULL,
  `item_id` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `store`
--

INSERT INTO `store` (`id`, `category`, `name`, `description`, `price`, `img`, `amount`, `purchased`, `item_id`) VALUES
(1, 2, 'Restauração de Atributoss', 'Restauração de Atributoss', '300', '16072174785fcc3146e717b.png', '12', '', ''),
(2, 3, 'Restauração de Atributos', 'Restauração de Atributos', '3000', '16072174785fcc3146e717b.png', '1', '', ''),
(3, 3, 'Restauração de Atributos', 'Restauração de Atributos', '3000', '16072174785fcc3146e717b.png', '1', '', ''),
(4, 3, 'Restauração de Atributos', 'Restauração de Atributos', '3000', '16072174785fcc3146e717b.png', '1', '', ''),
(5, 3, 'Restauração de Atributos', 'Restauração de Atributos', '3000', '16072174785fcc3146e717b.png', '1', '', ''),
(6, 1, '7 Dias de VIP', '7 Dias de VIP', '700', '16072209215fcc3eb9bd7af.png', '7', '', ''),
(7, 1, '30 dias de VIP', '<ol>\r\n	<li>Bobinho</li>\r\n	<li>Bobao</li>\r\n</ol>\r\n', '2800', '16072237935fcc49f195fe5.png', '30', '', ''),
(8, 2, 'Porção de Vida', '<p>Po&ccedil;&atilde;o grande que aumenta o HP M&aacute;x.<br />\r\nAumenta bastante o HP M&aacute;x por 500 segundos, e recupera 5% do HP.</p>\r\n', '50', '16075594955fd16947d84ae.png', '100', '', '1');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `account_friends`
--
ALTER TABLE `account_friends`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account_id` (`account_id`);

--
-- Índices para tabela `actors`
--
ALTER TABLE `actors`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account_id` (`account_id`);

--
-- Índices para tabela `actor_armors`
--
ALTER TABLE `actor_armors`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_equips`
--
ALTER TABLE `actor_equips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_hotbars`
--
ALTER TABLE `actor_hotbars`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_items`
--
ALTER TABLE `actor_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_quests`
--
ALTER TABLE `actor_quests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_self_switches`
--
ALTER TABLE `actor_self_switches`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_skills`
--
ALTER TABLE `actor_skills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_switches`
--
ALTER TABLE `actor_switches`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_variables`
--
ALTER TABLE `actor_variables`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `actor_weapons`
--
ALTER TABLE `actor_weapons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actor_id` (`actor_id`);

--
-- Índices para tabela `banks`
--
ALTER TABLE `banks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account_id` (`account_id`);

--
-- Índices para tabela `bank_armors`
--
ALTER TABLE `bank_armors`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bank_id` (`bank_id`);

--
-- Índices para tabela `bank_items`
--
ALTER TABLE `bank_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bank_id` (`bank_id`);

--
-- Índices para tabela `bank_weapons`
--
ALTER TABLE `bank_weapons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bank_id` (`bank_id`);

--
-- Índices para tabela `ban_list`
--
ALTER TABLE `ban_list`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `configs`
--
ALTER TABLE `configs`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `distributor`
--
ALTER TABLE `distributor`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `guilds`
--
ALTER TABLE `guilds`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `payment_voucher`
--
ALTER TABLE `payment_voucher`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `records`
--
ALTER TABLE `records`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `store`
--
ALTER TABLE `store`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `account_friends`
--
ALTER TABLE `account_friends`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `actors`
--
ALTER TABLE `actors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `actor_armors`
--
ALTER TABLE `actor_armors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `actor_equips`
--
ALTER TABLE `actor_equips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de tabela `actor_hotbars`
--
ALTER TABLE `actor_hotbars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de tabela `actor_items`
--
ALTER TABLE `actor_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de tabela `actor_quests`
--
ALTER TABLE `actor_quests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `actor_self_switches`
--
ALTER TABLE `actor_self_switches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `actor_skills`
--
ALTER TABLE `actor_skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `actor_switches`
--
ALTER TABLE `actor_switches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=201;

--
-- AUTO_INCREMENT de tabela `actor_variables`
--
ALTER TABLE `actor_variables`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=201;

--
-- AUTO_INCREMENT de tabela `actor_weapons`
--
ALTER TABLE `actor_weapons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `banks`
--
ALTER TABLE `banks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `bank_armors`
--
ALTER TABLE `bank_armors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `bank_items`
--
ALTER TABLE `bank_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `bank_weapons`
--
ALTER TABLE `bank_weapons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `ban_list`
--
ALTER TABLE `ban_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `configs`
--
ALTER TABLE `configs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

--
-- AUTO_INCREMENT de tabela `distributor`
--
ALTER TABLE `distributor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `guilds`
--
ALTER TABLE `guilds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `payment_voucher`
--
ALTER TABLE `payment_voucher`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `records`
--
ALTER TABLE `records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `store`
--
ALTER TABLE `store`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
