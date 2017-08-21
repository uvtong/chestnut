DROP TABLE IF EXISTS `tb_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_count` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'id',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '索引',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='记录开始的时候';
/*!40101 SET character_set_client = @saved_cs_client */;
