DROP TABLE IF EXISTS `enrolled_cnx_history`;
CREATE TABLE `enrolled_cnx_history` (
  `cn` varchar(100) NOT NULL,
  `dttime` datetime NOT NULL DEFAULT NOW(),
  `step` text NOT NULL,
  `detail` text NOT NULL,
  PRIMARY KEY (`cn`,`dttime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

