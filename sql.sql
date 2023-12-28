-- tablo yapısı dökülüyor foxv.fx-storge
CREATE TABLE IF NOT EXISTS `fx-storge` (
  `owner` varchar(50) DEFAULT NULL,
  `id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- foxv.fx-storge: ~20 rows (yaklaşık) tablosu için veriler indiriliyor
INSERT INTO `fx-storge` (`owner`, `id`) VALUES
	(NULL, 2),
	(NULL, 3),
	(NULL, 1),
	(NULL, 4),
	(NULL, 5),
	(NULL, 6),
	(NULL, 7),
	(NULL, 8),
	(NULL, 9),
	(NULL, 10),
	(NULL, 11),
	(NULL, 12),
	(NULL, 13),
	(NULL, 14),
	(NULL, 15),
	(NULL, 16),
	(NULL, 17),
	(NULL, 18),
	(NULL, 19),
	(NULL, 20);

