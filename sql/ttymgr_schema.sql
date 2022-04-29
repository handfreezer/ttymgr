DROP TABLE IF EXISTS `enrolled`;
CREATE TABLE `enrolled` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cn` varchar(100) NOT NULL,
  `ip` varchar(16) NOT NULL,
  `serial` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `enrolled_uniq_cn` (`cn`),
  UNIQUE KEY `enrolled_uniq_ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `ovpn_status`;
CREATE TABLE `ovpn_status` (
  `id` int(10) unsigned NOT NULL,
  `cn` varchar(100) NOT NULL DEFAULT 'not_defined.labs.ulukai.net',
  `ip` varchar(16) NOT NULL,
  `last_seen` datetime NOT NULL,
  `serial` varchar(100) NOT NULL DEFAULT 'not_defined',
  UNIQUE KEY `ovpn_status_uniq_cn_ip` (`cn`,`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
