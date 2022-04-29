DROP TABLE IF EXISTS `enrolled_inventory`;
CREATE TABLE `enrolled_inventory` (
  `cn` varchar(100) NOT NULL,
  `dttime` datetime NOT NULL DEFAULT NOW(),
  `inventory` mediumblob NOT NULL,
  PRIMARY KEY (`cn`,`dttime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

grant FILE on *.* to ttymgr@localhost;
