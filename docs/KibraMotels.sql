CREATE TABLE IF NOT EXISTS `kibra-motels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roomid` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `date` varchar(255) NOT NULL,
  `pdata` varchar(255) NOT NULL,
  `invoiceseen` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `kibra-motels-business` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `motel` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `money` float NOT NULL,
  `roomprice` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `kibra-motels-cache` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rid` text NOT NULL,
  `citizenid` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
