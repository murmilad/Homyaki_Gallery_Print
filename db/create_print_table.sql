USE gallery;


CREATE TABLE `print` (
  `image_id` int(10) NOT NULL,
  `printed` int(1) DEFAULT 0,
  `print_date` datetime,
  PRIMARY KEY (`image_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
