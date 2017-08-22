DROP TABLE IF EXISTS `tb_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_count` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'id',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '索引',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='记录开始的时候';
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `tb_openid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_openid` (
  `openid` bigint(11) NOT NULL DEFAULT '0' COMMENT 'openid',
  `uid` int(11) NOT NULL DEFAULT '0' COMMENT 'uid',
  PRIMARY KEY (`openid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='openid';
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `tb_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_user` (
  `uid` int(10) NOT NULL DEFAULT '0' COMMENT 'uid',
  `nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '昵称',
  `sex` int(10) NOT NULL DEFAULT '0' COMMENT '性别',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;