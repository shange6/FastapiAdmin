-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: 192.168.110.110    Database: wantong
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `app_myapp`
--

DROP TABLE IF EXISTS `app_myapp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_myapp` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '应用名称',
  `access_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '访问地址',
  `icon_url` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用图标URL',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_app_myapp_uuid` (`uuid`),
  KEY `ix_app_myapp_id` (`id`),
  KEY `ix_app_myapp_updated_id` (`updated_id`),
  KEY `ix_app_myapp_created_id` (`created_id`),
  KEY `ix_app_myapp_created_time` (`created_time`),
  KEY `ix_app_myapp_updated_time` (`updated_time`),
  KEY `ix_app_myapp_status` (`status`),
  CONSTRAINT `app_myapp_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `app_myapp_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用系统表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_myapp`
--

LOCK TABLES `app_myapp` WRITE;
/*!40000 ALTER TABLE `app_myapp` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_myapp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `apscheduler_jobs`
--

DROP TABLE IF EXISTS `apscheduler_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `apscheduler_jobs` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `next_run_time` double DEFAULT NULL,
  `job_state` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_apscheduler_jobs_next_run_time` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apscheduler_jobs`
--

LOCK TABLES `apscheduler_jobs` WRITE;
/*!40000 ALTER TABLE `apscheduler_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `apscheduler_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_demo`
--

DROP TABLE IF EXISTS `gen_demo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_demo` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `a` int DEFAULT NULL COMMENT '整数',
  `b` bigint DEFAULT NULL COMMENT '大整数',
  `c` float DEFAULT NULL COMMENT '浮点数',
  `d` tinyint(1) NOT NULL COMMENT '布尔型',
  `e` date DEFAULT NULL COMMENT '日期',
  `f` time DEFAULT NULL COMMENT '时间',
  `g` datetime DEFAULT NULL COMMENT '日期时间',
  `h` text COLLATE utf8mb4_unicode_ci COMMENT '长文本',
  `i` json DEFAULT NULL COMMENT '元数据(JSON格式)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_demo_uuid` (`uuid`),
  KEY `ix_gen_demo_created_id` (`created_id`),
  KEY `ix_gen_demo_id` (`id`),
  KEY `ix_gen_demo_status` (`status`),
  KEY `ix_gen_demo_updated_id` (`updated_id`),
  KEY `ix_gen_demo_updated_time` (`updated_time`),
  KEY `ix_gen_demo_created_time` (`created_time`),
  CONSTRAINT `gen_demo_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_demo_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='示例表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_demo`
--

LOCK TABLES `gen_demo` WRITE;
/*!40000 ALTER TABLE `gen_demo` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_demo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '表名称',
  `table_comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '表描述',
  `class_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '实体类名称',
  `package_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成功能名',
  `sub_table_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '子表关联的外键名',
  `parent_menu_id` int DEFAULT NULL COMMENT '父菜单ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_table_uuid` (`uuid`),
  KEY `ix_gen_table_status` (`status`),
  KEY `ix_gen_table_created_id` (`created_id`),
  KEY `ix_gen_table_updated_time` (`updated_time`),
  KEY `ix_gen_table_id` (`id`),
  KEY `ix_gen_table_created_time` (`created_time`),
  KEY `ix_gen_table_updated_id` (`updated_id`),
  CONSTRAINT `gen_table_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代码生成表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '列名称',
  `column_comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '列类型',
  `column_length` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列长度',
  `column_default` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列默认值',
  `is_pk` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否主键',
  `is_increment` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否自增',
  `is_nullable` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否允许为空',
  `is_unique` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否唯一',
  `python_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Python类型',
  `python_field` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Python字段名',
  `is_insert` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否为新增字段',
  `is_edit` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否编辑字段',
  `is_list` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否列表字段',
  `is_query` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否查询字段',
  `query_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '查询方式',
  `html_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '显示类型',
  `dict_type` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '字典类型',
  `sort` int NOT NULL COMMENT '排序',
  `table_id` int NOT NULL COMMENT '归属表编号',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_table_column_uuid` (`uuid`),
  KEY `ix_gen_table_column_status` (`status`),
  KEY `ix_gen_table_column_table_id` (`table_id`),
  KEY `ix_gen_table_column_created_id` (`created_id`),
  KEY `ix_gen_table_column_id` (`id`),
  KEY `ix_gen_table_column_updated_id` (`updated_id`),
  KEY `ix_gen_table_column_created_time` (`created_time`),
  KEY `ix_gen_table_column_updated_time` (`updated_time`),
  CONSTRAINT `gen_table_column_ibfk_1` FOREIGN KEY (`table_id`) REFERENCES `gen_table` (`id`) ON DELETE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代码生成表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

LOCK TABLES `gen_table_column` WRITE;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门名称',
  `order` int NOT NULL COMMENT '显示排序',
  `code` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门编码',
  `leader` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门负责人',
  `phone` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机',
  `email` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `parent_id` int DEFAULT NULL COMMENT '父级部门ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_dept_uuid` (`uuid`),
  KEY `ix_sys_dept_created_time` (`created_time`),
  KEY `ix_sys_dept_status` (`status`),
  KEY `ix_sys_dept_code` (`code`),
  KEY `ix_sys_dept_parent_id` (`parent_id`),
  KEY `ix_sys_dept_id` (`id`),
  KEY `ix_sys_dept_updated_time` (`updated_time`),
  CONSTRAINT `sys_dept_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES ('集团总公司',1,'GROUP','部门负责人','1582112620','deptadmin@example.com',NULL,1,'2fbf0747-aa1d-4203-a4a4-f3a49a3db938','0','集团总公司','2026-03-17 10:31:18','2026-03-17 10:31:18');
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_sort` int NOT NULL COMMENT '字典排序',
  `dict_label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典标签',
  `dict_value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典键值',
  `css_class` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '表格回显样式',
  `is_default` tinyint(1) NOT NULL COMMENT '是否默认（True是 False否）',
  `dict_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典类型',
  `dict_type_id` int NOT NULL COMMENT '字典类型ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_dict_data_uuid` (`uuid`),
  KEY `dict_type_id` (`dict_type_id`),
  KEY `ix_sys_dict_data_created_time` (`created_time`),
  KEY `ix_sys_dict_data_id` (`id`),
  KEY `ix_sys_dict_data_updated_time` (`updated_time`),
  KEY `ix_sys_dict_data_status` (`status`),
  CONSTRAINT `sys_dict_data_ibfk_1` FOREIGN KEY (`dict_type_id`) REFERENCES `sys_dict_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,'男','0','blue',NULL,1,'sys_user_sex',1,1,'f513a96b-2fec-4944-997d-eb3d64255be5','0','性别男','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'女','1','pink',NULL,0,'sys_user_sex',1,2,'2ffc0e82-ef0c-474d-957a-6f5c62b7a3af','0','性别女','2026-03-17 10:31:18','2026-03-17 10:31:18'),(3,'未知','2','red',NULL,0,'sys_user_sex',1,3,'c4f42dc3-482c-4034-a9a2-f7c6f46de34e','0','性别未知','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'是','1','','primary',1,'sys_yes_no',2,4,'22403539-11f0-47d8-8bad-1abef42918e1','0','是','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'否','0','','danger',0,'sys_yes_no',2,5,'0cd5e146-8543-416a-b043-afc6f8ba2835','0','否','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'启用','1','','primary',0,'sys_common_status',3,6,'c8917133-af3d-4d75-bc94-96b6eba859d5','0','启用状态','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'停用','0','','danger',0,'sys_common_status',3,7,'415b281f-3bc6-4d08-95a9-aa26972ea3b7','0','停用状态','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'通知','1','blue','warning',1,'sys_notice_type',4,8,'80953450-0cac-4836-b179-549fde5b5e59','0','通知','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'公告','2','orange','success',0,'sys_notice_type',4,9,'fa128f9b-66f8-4fd0-9b13-0ecbaca1c128','0','公告','2026-03-17 10:31:18','2026-03-17 10:31:18'),(99,'其他','0','','info',0,'sys_oper_type',5,10,'509d040d-6d7e-473d-af3b-1fe5aebb18a7','0','其他操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'新增','1','','info',0,'sys_oper_type',5,11,'1744f8d9-251d-41c4-98bf-821d677ca01e','0','新增操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'修改','2','','info',0,'sys_oper_type',5,12,'60e4e593-fa79-4999-8088-538d312cb328','0','修改操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(3,'删除','3','','danger',0,'sys_oper_type',5,13,'1465de5f-7b16-49c2-abef-12b21ad8b0ec','0','删除操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(4,'分配权限','4','','primary',0,'sys_oper_type',5,14,'9e682205-54a5-429c-96cf-4e0d5f008613','0','授权操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(5,'导出','5','','warning',0,'sys_oper_type',5,15,'23e4c6e2-cea5-4d75-88c9-33cd7e5679be','0','导出操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(6,'导入','6','','warning',0,'sys_oper_type',5,16,'6bebfaa5-e014-46e9-90d2-c9165f92c257','0','导入操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(7,'强退','7','','danger',0,'sys_oper_type',5,17,'0a046c06-9125-4a47-80e3-5fba5d919b70','0','强退操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(8,'生成代码','8','','warning',0,'sys_oper_type',5,18,'aa3cade8-a723-40ca-aa9c-91f1c06a4316','0','生成操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(9,'清空数据','9','','danger',0,'sys_oper_type',5,19,'6e1a86fe-a601-4f68-895a-580ec4d65780','0','清空操作','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'默认(Memory)','default','',NULL,1,'sys_job_store',6,20,'95e5e99c-b367-42ec-bea2-8ad90e63e4f7','0','默认分组','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'数据库(Sqlalchemy)','sqlalchemy','',NULL,0,'sys_job_store',6,21,'0390b4eb-74ad-4d6c-92a8-d7e01824a1cf','0','数据库分组','2026-03-17 10:31:18','2026-03-17 10:31:18'),(3,'数据库(Redis)','redis','',NULL,0,'sys_job_store',6,22,'9231b4ad-5c34-4003-8788-f46e883690fa','0','reids分组','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'线程池','default','',NULL,0,'sys_job_executor',7,23,'462beb8d-d5fe-4183-b72b-103121214797','0','线程池','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'进程池','processpool','',NULL,0,'sys_job_executor',7,24,'5641bd4c-7eaf-4e69-9d8a-846ecc03861d','0','进程池','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'演示函数','scheduler_test.job','',NULL,1,'sys_job_function',8,25,'eb28abf2-714d-4c29-baa5-2340416152c7','0','演示函数','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'指定日期(date)','date','',NULL,1,'sys_job_trigger',9,26,'6d4a5bff-5be1-405b-bd02-19fe2e8099ed','0','指定日期任务触发器','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'间隔触发器(interval)','interval','',NULL,0,'sys_job_trigger',9,27,'7622b3ab-a6f9-460c-bf14-fd69a6f04f74','0','间隔触发器任务触发器','2026-03-17 10:31:18','2026-03-17 10:31:18'),(3,'cron表达式','cron','',NULL,0,'sys_job_trigger',9,28,'46abd9e9-0b72-4a2b-9ea3-57277ca6f6e5','0','间隔触发器任务触发器','2026-03-17 10:31:18','2026-03-17 10:31:18'),(1,'默认(default)','default','',NULL,1,'sys_list_class',10,29,'875b52ef-2b9b-4049-bb2e-d14c15504f2c','0','默认表格回显样式','2026-03-17 10:31:18','2026-03-17 10:31:18'),(2,'主要(primary)','primary','',NULL,0,'sys_list_class',10,30,'61626058-c249-41b7-aa46-6a1544808ea6','0','主要表格回显样式','2026-03-17 10:31:18','2026-03-17 10:31:18'),(3,'成功(success)','success','',NULL,0,'sys_list_class',10,31,'6fa38dc6-e477-4fa6-bc7f-2b871c808147','0','成功表格回显样式','2026-03-17 10:31:18','2026-03-17 10:31:18'),(4,'信息(info)','info','',NULL,0,'sys_list_class',10,32,'f309e9c6-494b-400b-86e5-e2f817eb5b3b','0','信息表格回显样式','2026-03-17 10:31:18','2026-03-17 10:31:18'),(5,'警告(warning)','warning','',NULL,0,'sys_list_class',10,33,'c9477ee3-c3c8-4c56-943b-2d24d5555925','0','警告表格回显样式','2026-03-17 10:31:18','2026-03-17 10:31:18'),(6,'危险(danger)','danger','',NULL,0,'sys_list_class',10,34,'ee407f17-c4ba-4c55-bc25-ac1c9b73f3f8','0','危险表格回显样式','2026-03-17 10:31:18','2026-03-17 10:31:18');
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典名称',
  `dict_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典类型',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `dict_type` (`dict_type`),
  UNIQUE KEY `ix_sys_dict_type_uuid` (`uuid`),
  KEY `ix_sys_dict_type_updated_time` (`updated_time`),
  KEY `ix_sys_dict_type_created_time` (`created_time`),
  KEY `ix_sys_dict_type_status` (`status`),
  KEY `ix_sys_dict_type_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES ('用户性别','sys_user_sex',1,'dc51998f-0600-4f6a-8290-ea40440eccd9','0','用户性别列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('系统是否','sys_yes_no',2,'b3e348c1-6303-4c9a-af8b-eff6ab4a6250','0','系统是否列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('系统状态','sys_common_status',3,'4a348f2d-c7f2-4983-8038-355a3098be87','0','系统状态','2026-03-17 10:31:18','2026-03-17 10:31:18'),('通知类型','sys_notice_type',4,'eb110fc9-1b29-442a-9d6b-fda636807a0a','0','通知类型列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('操作类型','sys_oper_type',5,'4234c15c-cc10-4211-820d-acd8d8d48fb1','0','操作类型列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('任务存储器','sys_job_store',6,'f899a74c-dbbe-4a62-be74-ae46b87512ca','0','任务分组列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('任务执行器','sys_job_executor',7,'512e12b1-1b90-4388-b416-d2259ed7e186','0','任务执行器列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('任务函数','sys_job_function',8,'be1ee807-ab60-43a9-992c-d3a06c10dc6a','0','任务函数列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('任务触发器','sys_job_trigger',9,'bd9d8e46-b1b6-4d94-8b71-4076af1b04f7','0','任务触发器列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('表格回显样式','sys_list_class',10,'70aaab76-9549-44fb-85f6-84f59f445899','0','表格回显样式列表','2026-03-17 10:31:18','2026-03-17 10:31:18');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `type` int NOT NULL COMMENT '菜单类型(1:目录 2:菜单 3:按钮/权限 4:链接)',
  `order` int NOT NULL COMMENT '显示排序',
  `permission` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '权限标识(如:module_system:user:query)',
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '菜单图标',
  `route_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '路由名称',
  `route_path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '路由路径',
  `component_path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '组件路径',
  `redirect` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '重定向地址',
  `hidden` tinyint(1) NOT NULL COMMENT '是否隐藏(True:隐藏 False:显示)',
  `keep_alive` tinyint(1) NOT NULL COMMENT '是否缓存(True:是 False:否)',
  `always_show` tinyint(1) NOT NULL COMMENT '是否始终显示(True:是 False:否)',
  `title` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '菜单标题',
  `params` json DEFAULT NULL COMMENT '路由参数(JSON对象)',
  `affix` tinyint(1) NOT NULL COMMENT '是否固定标签页(True:是 False:否)',
  `parent_id` int DEFAULT NULL COMMENT '父菜单ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_menu_uuid` (`uuid`),
  KEY `ix_sys_menu_updated_time` (`updated_time`),
  KEY `ix_sys_menu_parent_id` (`parent_id`),
  KEY `ix_sys_menu_id` (`id`),
  KEY `ix_sys_menu_created_time` (`created_time`),
  KEY `ix_sys_menu_status` (`status`),
  CONSTRAINT `sys_menu_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `sys_menu` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=156 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES ('仪表盘',1,1,'','client','Dashboard','/dashboard',NULL,'/dashboard/workplace',0,1,1,'仪表盘','null',0,NULL,1,'41d6e7bb-48db-4489-940a-818c02f5f772','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('系统管理',1,2,NULL,'system','System','/system',NULL,'/system/menu',0,1,0,'系统管理','null',0,NULL,2,'605536d8-6aa4-4028-8ff2-20f9543a7e76','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('监控管理',1,3,NULL,'monitor','Monitor','/monitor',NULL,'/monitor/online',0,1,0,'监控管理','null',0,NULL,3,'148642ec-a391-4175-9054-93f2b14a7473','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('接口管理',1,4,NULL,'document','Common','/common',NULL,'/common/docs',0,1,0,'接口管理','null',0,NULL,4,'259a6f98-d449-4390-96a6-ae92f5536484','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('代码管理',1,5,NULL,'code','Generator','/generator',NULL,'/generator/gencode',0,1,0,'代码管理','null',0,NULL,5,'a3b16abc-c897-4e2c-be62-570568bed49e','0','代码管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('应用管理',1,6,NULL,'el-icon-ShoppingBag','Application','/application',NULL,'/application/myapp',0,1,0,'应用管理','null',0,NULL,6,'b60fe848-98fe-43b4-a643-79ba9a19e132','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('AI管理',1,7,NULL,'el-icon-ChatLineSquare','AI','/ai',NULL,'/ai/chat',0,1,0,'AI管理','null',0,NULL,7,'f0c03648-9973-4bc0-9f6d-a8b0330744d2','0','AI管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('任务管理',1,8,NULL,'el-icon-SetUp','Task','/task',NULL,'/task/job',0,1,0,'任务管理','null',0,NULL,8,'05c7b7af-681c-475e-a148-6fbbd82ac1d5','0','任务管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('案例管理',1,9,NULL,'menu','Example','/example',NULL,'/example/demo',0,1,0,'案例管理','null',0,NULL,9,'c0daf5eb-69f0-40fd-aa46-3a9283e414df','0','案例管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('工作台',2,1,'dashboard:workplace:query','el-icon-PieChart','Workplace','/dashboard/workplace','dashboard/workplace',NULL,0,1,0,'工作台','null',0,1,10,'4d6f6e2c-3a65-4929-8c1b-88d68ab9e9cf','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('菜单管理',2,1,'module_system:menu:query','menu','Menu','/system/menu','module_system/menu/index',NULL,0,1,0,'菜单管理','null',0,2,11,'c0e88680-acc4-427a-92ee-906787948f99','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('部门管理',2,2,'module_system:dept:query','tree','Dept','/system/dept','module_system/dept/index',NULL,0,1,0,'部门管理','null',0,2,12,'348e1300-d098-4906-9fba-786cbbbd3979','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('岗位管理',2,3,'module_system:position:query','el-icon-Coordinate','Position','/system/position','module_system/position/index',NULL,0,1,0,'岗位管理','null',0,2,13,'c50894ee-5cad-409d-bcef-22870ac1d82e','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('角色管理',2,4,'module_system:role:query','role','Role','/system/role','module_system/role/index',NULL,0,1,0,'角色管理','null',0,2,14,'c9c44091-8df2-4bc1-8b67-3bf5cc13457d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('用户管理',2,5,'module_system:user:query','el-icon-User','User','/system/user','module_system/user/index',NULL,0,1,0,'用户管理','null',0,2,15,'b882250e-1c83-487d-97c5-7455ab97da13','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('日志管理',2,6,'module_system:log:query','el-icon-Aim','Log','/system/log','module_system/log/index',NULL,0,1,0,'日志管理','null',0,2,16,'fc47ac4f-e917-4944-adf1-48db1a834dd5','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告管理',2,7,'module_system:notice:query','bell','Notice','/system/notice','module_system/notice/index',NULL,0,1,0,'公告管理','null',0,2,17,'14bd87a4-9b86-4342-8426-7a6b7911213f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('参数管理',2,8,'module_system:param:query','setting','Params','/system/param','module_system/param/index',NULL,0,1,0,'参数管理','null',0,2,18,'9d429445-8c82-4d96-865e-38ecc619f567','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('字典管理',2,9,'module_system:dict_type:query','dict','Dict','/system/dict','module_system/dict/index',NULL,0,1,0,'字典管理','null',0,2,19,'b3d7e744-bccd-470f-9042-5013b5b52bc0','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('在线用户',2,1,'module_monitor:online:query','el-icon-Headset','MonitorOnline','/monitor/online','module_monitor/online/index',NULL,0,1,0,'在线用户','null',0,3,20,'784e4866-ade1-4bb4-8a92-7f566a806680','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('服务器监控',2,2,'module_monitor:server:query','el-icon-Odometer','MonitorServer','/monitor/server','module_monitor/server/index',NULL,0,1,0,'服务器监控','null',0,3,21,'133068f3-8149-4c6d-9a5f-4ac7c08f419a','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('缓存监控',2,3,'module_monitor:cache:query','el-icon-Stopwatch','MonitorCache','/monitor/cache','module_monitor/cache/index',NULL,0,1,0,'缓存监控','null',0,3,22,'7e1016d0-0f68-4a55-99a7-536c8c45f8f0','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件管理',2,4,'module_monitor:resource:query','el-icon-Files','Resource','/monitor/resource','module_monitor/resource/index',NULL,0,1,0,'文件管理','null',0,3,23,'7971d2cb-d886-42cb-b246-73b366b88e88','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('Swagger文档',4,1,'module_common:docs:query','api','Docs','/common/docs','module_common/docs/index',NULL,0,1,0,'Swagger文档','null',0,4,24,'7e816328-040e-4913-ad25-2287469ab5ae','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('Redoc文档',4,2,'module_common:redoc:query','el-icon-Document','Redoc','/common/redoc','module_common/redoc/index',NULL,0,1,0,'Redoc文档','null',0,4,25,'b48eb657-0cca-46e0-badb-bd752d7d8d26','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('LangJin文档',4,3,'module_common:ljdoc:query','el-icon-Document','Ljdoc','/common/ljdoc','module_common/ljdoc/index',NULL,0,1,0,'LangJin文档','null',0,4,26,'ca209aa8-d3bc-42e9-bfef-1666b93b6664','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('代码生成',2,1,'module_generator:gencode:query','code','GenCode','/generator/gencode','module_generator/gencode/index',NULL,0,1,0,'代码生成','null',0,5,27,'79d79c89-e0ee-4af1-b63a-2a757334d743','0','代码生成','2026-03-17 10:31:18','2026-03-17 10:31:18'),('我的应用',2,1,'module_application:myapp:query','el-icon-ShoppingCartFull','MYAPP','/application/myapp','module_application/myapp/index',NULL,0,1,0,'我的应用','null',0,6,28,'f2f1aaf3-efdb-4d2a-85e2-919dd638cb00','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('AI智能助手',2,1,'module_ai:chat:query','el-icon-ChatDotRound','Chat','/ai/chat','module_ai/chat/index',NULL,0,1,0,'AI智能助手','null',0,7,29,'7bd62a24-e887-482a-9b0d-e3933de2bfbe','0','AI智能助手','2026-03-17 10:31:18','2026-03-17 10:31:18'),('会话记忆',2,2,'module_ai:chat:query','el-icon-ChatLineSquare','Memory','/ai/memory','module_ai/memory/index',NULL,0,1,0,'会话记忆','null',0,7,30,'27ec82c9-728f-4d7a-abc6-c907a28b0d10','0','会话记忆管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('调度器监控',2,1,'module_task:job:query','el-icon-DataLine','Job','/task/job','module_task/job/index',NULL,0,1,0,'调度器监控','null',0,8,31,'cd00c28c-c3f1-4b3c-87ef-875529ae9518','0','调度器监控','2026-03-17 10:31:18','2026-03-17 10:31:18'),('节点管理',2,2,'module_task:node:query','el-icon-Postcard','Node','/task/node','module_task/node/index',NULL,0,1,0,'节点管理','null',0,8,32,'8f5fb0f7-0fad-4d53-83eb-c41458593950','0','节点管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('示例管理',2,1,'module_example:demo:query','menu','Demo','/example/demo','module_example/demo/index',NULL,0,1,0,'示例管理','null',0,9,33,'9dec547e-fd74-4483-990e-22622c71283e','0','示例管理','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建菜单',3,1,'module_system:menu:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建菜单','null',0,11,34,'5c41fcaa-cad6-4e75-aa43-0d88f6de43ad','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改菜单',3,2,'module_system:menu:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改菜单','null',0,11,35,'bc6c38d5-111d-4e22-947f-4f542dbc4558','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除菜单',3,3,'module_system:menu:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除菜单','null',0,11,36,'c79f7343-2cb0-4ef6-b510-644b9b5e8dcf','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改菜单状态',3,4,'module_system:menu:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改菜单状态','null',0,11,37,'373b8592-9b79-4e7a-bb60-ca3ac3846f79','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情菜单',3,5,'module_system:menu:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情菜单','null',0,11,38,'684014f7-27e7-4639-9621-ba7b19d4c7cd','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询菜单',3,6,'module_system:menu:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询菜单','null',0,11,39,'3f43f3fb-713b-4a27-81c3-216fd845709a','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建部门',3,1,'module_system:dept:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建部门','null',0,12,40,'77f6db7d-57a7-4ba2-9f1e-0a3d58cd2bcb','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改部门',3,2,'module_system:dept:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改部门','null',0,12,41,'6ce7f6a3-bc0e-4fb5-bcc1-70181d9e8593','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除部门',3,3,'module_system:dept:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除部门','null',0,12,42,'32cd271f-1e63-40a7-8518-2cc9232f1f3e','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改部门状态',3,4,'module_system:dept:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改部门状态','null',0,12,43,'cd475a45-fde6-40ab-b71e-860feaa19658','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情部门',3,5,'module_system:dept:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情部门','null',0,12,44,'e9be8ced-4c2a-4da5-9eb0-a032e8bec7d6','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询部门',3,6,'module_system:dept:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询部门','null',0,12,45,'c97eca83-58ce-49c9-b353-b7557057b335','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建岗位',3,1,'module_system:position:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建岗位','null',0,13,46,'8c5d7aca-7d29-40e1-a272-2c3cda34e1cf','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改岗位',3,2,'module_system:position:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改岗位','null',0,13,47,'a2bfb06c-abe8-4434-9d19-27edc51ec72e','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除岗位',3,3,'module_system:position:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改岗位','null',0,13,48,'8410057b-0e5f-40f3-8ac3-96ffe6ccec2d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改岗位状态',3,4,'module_system:position:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改岗位状态','null',0,13,49,'b1d65b44-1d6f-423a-b32f-899696e5f7b0','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('岗位导出',3,5,'module_system:position:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'岗位导出','null',0,13,50,'6ccda0d9-a53e-4b4a-a654-bb672347112b','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情岗位',3,6,'module_system:position:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情岗位','null',0,13,51,'dfce4f80-9f81-4d94-97c9-ec54e68918c8','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询岗位',3,7,'module_system:position:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询岗位','null',0,13,52,'7b4fc493-2721-48c7-a9f4-ac809978da2f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建角色',3,1,'module_system:role:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建角色','null',0,14,53,'1beb40ad-811a-491f-8fab-7819f9a3132d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改角色',3,2,'module_system:role:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改角色','null',0,14,54,'bb2fc200-a235-4309-860e-f39529aa33a4','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除角色',3,3,'module_system:role:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除角色','null',0,14,55,'d169c8e9-db1f-4da3-bc85-83f9628649ab','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改角色状态',3,4,'module_system:role:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改角色状态','null',0,14,56,'47715352-d4df-488d-ac05-ab535bfeb2dc','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('角色导出',3,5,'module_system:role:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'角色导出','null',0,14,57,'d7433a8c-bb88-4659-a0da-4882cc39a5db','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情角色',3,6,'module_system:role:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情角色','null',0,14,58,'65b4d26b-dd2b-4b16-9fc3-6e88cae0c25d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询角色',3,7,'module_system:role:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询角色','null',0,14,59,'dd5556de-16da-4642-8386-eabb887508e6','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('分配权限',3,8,'module_system:role:permission',NULL,NULL,NULL,NULL,NULL,0,1,0,'分配权限','null',0,14,60,'70665e9d-e8c0-4a8c-8fe4-a2df1b003a4f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建用户',3,1,'module_system:user:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建用户','null',0,15,61,'c05e67ca-0780-49fc-9186-f65cda6e7996','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改用户',3,2,'module_system:user:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改用户','null',0,15,62,'91fe01c3-7250-4bf5-b317-c7a6816361a1','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除用户',3,3,'module_system:user:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除用户','null',0,15,63,'305465e5-8d52-4eb4-8425-6758d927415b','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改用户状态',3,4,'module_system:user:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改用户状态','null',0,15,64,'2ef26f8a-6a95-4583-83eb-af7d1a054886','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导出用户',3,5,'module_system:user:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出用户','null',0,15,65,'8689c1be-7af1-4493-b7b1-8b5c91d45b3d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导入用户',3,6,'module_system:user:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入用户','null',0,15,66,'cf7dcde2-bdd1-4dc2-aa94-fb199c77582a','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('下载用户导入模板',3,7,'module_system:user:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载用户导入模板','null',0,15,67,'1f5aa480-4bc8-4f52-99eb-fc7d68f765c6','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情用户',3,8,'module_system:user:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情用户','null',0,15,68,'27c78207-4e95-40d1-b0f8-31ebe15cda19','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询用户',3,9,'module_system:user:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询用户','null',0,15,69,'7d6c0200-9110-4b0c-9aaf-ee8952095945','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('日志删除',3,1,'module_system:log:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'日志删除','null',0,16,70,'c18ebf3f-a7e3-45fb-81a2-0e6b607be807','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('日志导出',3,2,'module_system:log:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'日志导出','null',0,16,71,'c645597b-a076-4514-8bc5-3f183591a3d3','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('日志详情',3,3,'module_system:log:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'日志详情','null',0,16,72,'464c5200-9e7d-43bf-b314-f59ed78382a9','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询日志',3,4,'module_system:log:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询日志','null',0,16,73,'971ba6de-a77b-4923-bbff-03bfd72e3e38','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告创建',3,1,'module_system:notice:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告创建','null',0,17,74,'bbfce9ea-b2b5-484e-8931-7364f68294a4','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告修改',3,2,'module_system:notice:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改用户','null',0,17,75,'2320c43b-d968-4a01-9c12-42bb1fe1860e','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告删除',3,3,'module_system:notice:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告删除','null',0,17,76,'7e696947-1953-4519-afca-11e4437de8eb','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告导出',3,4,'module_system:notice:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告导出','null',0,17,77,'00c5e4de-f138-4fb6-b960-4df51b1f0c05','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告批量修改状态',3,5,'module_system:notice:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告批量修改状态','null',0,17,78,'f6f4d456-1b9c-48b2-b89e-7719461a4092','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('公告详情',3,6,'module_system:notice:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告详情','null',0,17,79,'4a1cb17c-e757-449f-9831-7bc25ff7b551','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询公告',3,5,'module_system:notice:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询公告','null',0,17,80,'ae0504c2-ddff-4cb6-9a75-a530fdb340f6','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建参数',3,1,'module_system:param:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建参数','null',0,18,81,'3003961b-20c4-4368-82b6-3aaf9480b30d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改参数',3,2,'module_system:param:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改参数','null',0,18,82,'3452b8ba-5668-4671-8828-25267fbb48ea','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除参数',3,3,'module_system:param:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除参数','null',0,18,83,'1742b81a-48ce-4d1a-a4c0-dc856addecba','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导出参数',3,4,'module_system:param:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出参数','null',0,18,84,'8b73d127-006a-4ac5-9ab4-fb4eb2d3a00c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('参数上传',3,5,'module_system:param:upload',NULL,NULL,NULL,NULL,NULL,0,1,0,'参数上传','null',0,18,85,'ea4d447b-cf61-45ef-8f73-d8824a4fcfe5','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('参数详情',3,6,'module_system:param:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'参数详情','null',0,18,86,'0978cb2f-576d-4f2b-a84b-0d0082fec7f2','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询参数',3,7,'module_system:param:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询参数','null',0,18,87,'9aced99d-5c04-4d8b-ac22-a1b91c99196d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建字典类型',3,1,'module_system:dict_type:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建字典类型','null',0,19,88,'ca5f8365-351c-40cc-9e1a-3ee4e49cf57c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改字典类型',3,2,'module_system:dict_type:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改字典类型','null',0,19,89,'15d2adc4-8be8-4c0c-a591-0f70116f7845','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除字典类型',3,3,'module_system:dict_type:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除字典类型','null',0,19,90,'79dbfced-a8e3-4d73-9b5c-4d97ab49c722','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导出字典类型',3,4,'module_system:dict_type:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出字典类型','null',0,19,91,'3cdbc2ac-883b-4fa1-8b7e-a1c14e5c7db3','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改字典状态',3,5,'module_system:dict_type:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出字典类型','null',0,19,92,'a6f2a050-ab95-4617-b1d1-ec78f4029a18','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('字典数据查询',3,6,'module_system:dict_data:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'字典数据查询','null',0,19,93,'629304b2-6e14-4a16-a7cb-036ba0567cea','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建字典数据',3,7,'module_system:dict_data:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建字典数据','null',0,19,94,'bc0af15d-4c38-4f46-87f4-513c0c9a4996','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改字典数据',3,8,'module_system:dict_data:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改字典数据','null',0,19,95,'41450a47-cd33-4b9c-a937-7dfeca1d0b4f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除字典数据',3,9,'module_system:dict_data:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除字典数据','null',0,19,96,'46c63e82-5622-4090-8f25-e33622b2f57c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导出字典数据',3,10,'module_system:dict_data:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出字典数据','null',0,19,97,'60b62647-9a54-44ab-91d2-8661c43d61fb','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改字典数据状态',3,11,'module_system:dict_data:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改字典数据状态','null',0,19,98,'942d8086-40cb-4878-af9a-b50a8c07d05c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情字典类型',3,12,'module_system:dict_type:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情字典类型','null',0,19,99,'9457ba83-ba30-4edf-9af3-087aa08c2967','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询字典类型',3,13,'module_system:dict_type:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询字典类型','null',0,19,100,'75b9eb1c-83a7-4118-b2d1-ef277964ce3c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情字典数据',3,14,'module_system:dict_data:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情字典数据','null',0,19,101,'f1f37520-09f6-4d27-a07c-7d226161bd5e','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('在线用户强制下线',3,1,'module_monitor:online:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'在线用户强制下线','null',0,20,102,'ef5a15e2-63d8-4e86-a2e3-ee73cd69f3d2','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('清除缓存',3,1,'module_monitor:cache:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'清除缓存','null',0,22,103,'2c355f54-61fd-4874-8aac-57416e23ad00','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件上传',3,1,'module_monitor:resource:upload',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件上传','null',0,23,104,'17b64d94-59f3-4acc-aeb8-6858dca61773','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件下载',3,2,'module_monitor:resource:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件下载','null',0,23,105,'39cc4139-de69-4454-8bfa-d9b0bbc7739b','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件删除',3,3,'module_monitor:resource:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件删除','null',0,23,106,'b74f9b64-32b9-436a-bf7d-25c166940370','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件移动',3,4,'module_monitor:resource:move',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件移动','null',0,23,107,'bc9a2026-73f7-4e31-8a53-73b02ab5e332','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件复制',3,5,'module_monitor:resource:copy',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件复制','null',0,23,108,'24e93360-8dc6-457b-b23f-48cbf5438f4b','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('文件重命名',3,6,'module_monitor:resource:rename',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件重命名','null',0,23,109,'36a5c146-bba1-4727-a631-1a971ac78474','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建目录',3,7,'module_monitor:resource:create_dir',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建目录','null',0,23,110,'5885fb6d-f7f2-4d71-8d40-59f4f8810fc6','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导出文件列表',3,9,'module_monitor:resource:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出文件列表','null',0,23,111,'f568a5d7-7c40-4968-b616-316e9fe94e19','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询代码生成业务表列表',3,1,'module_generator:gencode:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询代码生成业务表列表','null',0,27,112,'105b03a6-22ab-48b1-a427-884ac5d11858','0','查询代码生成业务表列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建表结构',3,2,'module_generator:gencode:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建表结构','null',0,27,113,'dd9eddc9-75e2-4dfd-a02d-f20d8376da56','0','创建表结构','2026-03-17 10:31:18','2026-03-17 10:31:18'),('编辑业务表信息',3,3,'module_generator:gencode:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑业务表信息','null',0,27,114,'db428ff8-7255-4e62-bebd-59b25190f397','0','编辑业务表信息','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除业务表信息',3,4,'module_generator:gencode:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除业务表信息','null',0,27,115,'feec3339-4672-4cfd-8254-fe6a372440d9','0','删除业务表信息','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导入表结构',3,5,'module_generator:gencode:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入表结构','null',0,27,116,'e76df24e-1475-4f9a-8137-72b383c6bcbf','0','导入表结构','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量生成代码',3,6,'module_generator:gencode:operate',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量生成代码','null',0,27,117,'a01d83b4-0c1d-4c7c-9284-890e07e4d5e5','0','批量生成代码','2026-03-17 10:31:18','2026-03-17 10:31:18'),('生成代码到指定路径',3,7,'module_generator:gencode:code',NULL,NULL,NULL,NULL,NULL,0,1,0,'生成代码到指定路径','null',0,27,118,'6aa8e89f-3c29-4d68-bca4-d7fde4a48b4d','0','生成代码到指定路径','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询数据库表列表',3,8,'module_generator:dblist:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询数据库表列表','null',0,27,119,'4ded7c79-9037-43df-af3c-96c79c1b2889','0','查询数据库表列表','2026-03-17 10:31:18','2026-03-17 10:31:18'),('同步数据库',3,9,'module_generator:db:sync',NULL,NULL,NULL,NULL,NULL,0,1,0,'同步数据库','null',0,27,120,'82289370-6bf5-479a-b9a5-4b88cc01cae5','0','同步数据库','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建应用',3,1,'module_application:myapp:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建应用','null',0,28,121,'dae76d9f-6690-4501-880b-51183e6deb4f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改应用',3,2,'module_application:myapp:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改应用','null',0,28,122,'aeabf794-cd5c-4139-90ee-6cd895a52a75','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除应用',3,3,'module_application:myapp:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除应用','null',0,28,123,'2089773f-4f2b-4b3f-b3a8-e40306e272bf','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改应用状态',3,4,'module_application:myapp:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改应用状态','null',0,28,124,'e71a69cf-adb5-4c9c-a1d2-8c65d65e6e54','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情应用',3,5,'module_application:myapp:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情应用','null',0,28,125,'7a31175e-96d2-43a4-994f-d7003a990ad1','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询应用',3,6,'module_application:myapp:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询应用','null',0,28,126,'c3a4cc7e-9bb9-4df4-90c9-457c13ff09a5','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('AI对话',3,1,'module_ai:chat:ws',NULL,NULL,NULL,NULL,NULL,0,1,0,'AI对话','null',0,29,127,'ce7d3cc2-fff1-4852-8e67-85ddba64722b','0','AI对话','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询会话',3,2,'module_ai:chat:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询会话','null',0,29,128,'e5e0faff-600e-43f6-8259-0724a57c9d24','0','查询会话','2026-03-17 10:31:18','2026-03-17 10:31:18'),('会话详情',3,3,'module_ai:chat:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'会话详情','null',0,29,129,'3c6701c0-78d2-4bf3-b0ae-4bbc5adb3254','0','会话详情','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建会话',3,4,'module_ai:chat:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建会话','null',0,29,130,'ac08ea18-d88a-458a-bd92-c015e1ed5e08','0','创建会话','2026-03-17 10:31:18','2026-03-17 10:31:18'),('更新会话',3,5,'module_ai:chat:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'更新会话','null',0,29,131,'5b1d8406-5eab-4a9f-a892-d1a06397a94a','0','更新会话','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除会话',3,6,'module_ai:chat:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除会话','null',0,29,132,'b00bbeec-3e36-4a1a-95bc-17de5632d81b','0','删除会话','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询会话记忆',3,1,'module_ai:chat:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询会话记忆','null',0,30,133,'552df985-0387-41ab-a726-1ed4da3cb965','0','查询会话记忆','2026-03-17 10:31:18','2026-03-17 10:31:18'),('会话记忆详情',3,2,'module_ai:chat:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'会话记忆详情','null',0,30,134,'a11943cd-c04e-4701-a4a8-b2d4b54fe9d1','0','会话记忆详情','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除会话记忆',3,3,'module_ai:chat:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除会话记忆','null',0,30,135,'0513f034-c722-48d6-86cc-eba2dbe606e7','0','删除会话记忆','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询调度器',3,1,'module_task:job:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询调度器','null',0,31,136,'543ce9ac-d72c-476e-81ea-061b14ceacc4','0','查询调度器','2026-03-17 10:31:18','2026-03-17 10:31:18'),('控制调度器',3,2,'module_task:job:scheduler',NULL,NULL,NULL,NULL,NULL,0,1,0,'控制调度器','null',0,31,137,'87b41770-7307-4639-9547-5e3926e57d82','0','控制调度器','2026-03-17 10:31:18','2026-03-17 10:31:18'),('操作任务',3,3,'module_task:job:task',NULL,NULL,NULL,NULL,NULL,0,1,0,'操作任务','null',0,31,138,'70e815cc-07bd-45af-95c2-11378374ec75','0','操作任务','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除执行日志',3,4,'module_task:job:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除执行日志','null',0,31,139,'038ef36d-4773-419f-a919-17abbec69dcc','0','删除执行日志','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情执行日志',3,5,'module_task:job:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情执行日志','null',0,31,140,'cc43c396-ed2f-4339-b40b-789ca2aefc72','0','详情执行日志','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建节点',3,1,'module_task:node:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建节点','null',0,32,141,'e3f50bff-d2f4-4a2e-b548-50c3e3c00be4','0','创建节点','2026-03-17 10:31:18','2026-03-17 10:31:18'),('调试节点',3,2,'module_task:node:execute',NULL,NULL,NULL,NULL,NULL,0,1,0,'调试节点','null',0,32,142,'770c38c0-74e1-465c-95a6-2877cb6f7c31','0','调试节点','2026-03-17 10:31:18','2026-03-17 10:31:18'),('修改节点',3,3,'module_task:node:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改节点','null',0,32,143,'f98b38b9-33c5-4764-8308-24c411b5878b','0','修改节点','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除节点',3,4,'module_task:node:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除节点','null',0,32,144,'ba7f1f27-5f07-4a48-a91b-e453f922acf8','0','删除节点','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情节点',3,5,'module_task:node:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情节点','null',0,32,145,'feb37eaf-036d-4847-ae6e-b96c241262d8','0','详情节点','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询节点',3,6,'module_task:node:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询节点','null',0,32,146,'b332d5d8-e3f4-412a-b9c2-6413734332c2','0','查询节点','2026-03-17 10:31:18','2026-03-17 10:31:18'),('创建示例',3,1,'module_example:demo:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建示例','null',0,33,147,'f55b6e8d-29f0-4e84-b3c9-327479a6d8de','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('更新示例',3,2,'module_example:demo:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'更新示例','null',0,33,148,'24d79c90-585a-4625-bf29-1539f9398b0e','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('删除示例',3,3,'module_example:demo:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除示例','null',0,33,149,'ba156447-29b9-4fbc-badb-a8e2f6bf7a5b','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('批量修改示例状态',3,4,'module_example:demo:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改示例状态','null',0,33,150,'2a40e645-db07-4335-a06c-835a2c6b4a2f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导出示例',3,5,'module_example:demo:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出示例','null',0,33,151,'703e377e-c7b0-44ca-9a88-89c8777afea8','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('导入示例',3,6,'module_example:demo:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入示例','null',0,33,152,'42eb9882-ea99-4904-bfb3-9c82179ce303','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('下载导入示例模版',3,7,'module_example:demo:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载导入示例模版','null',0,33,153,'e667943b-1832-45aa-8844-7de1e3403c2c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('详情示例',3,8,'module_example:demo:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情示例','null',0,33,154,'1bfc3053-87d3-4f47-998f-4442441b9bc4','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('查询示例',3,9,'module_example:demo:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询示例','null',0,33,155,'cf8a5d2b-cc31-490e-89bf-6bb4b091fd6d','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_title` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告标题',
  `notice_type` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告类型(1通知 2公告)',
  `notice_content` text COLLATE utf8mb4_unicode_ci COMMENT '公告内容',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_notice_uuid` (`uuid`),
  KEY `ix_sys_notice_updated_time` (`updated_time`),
  KEY `ix_sys_notice_id` (`id`),
  KEY `ix_sys_notice_created_id` (`created_id`),
  KEY `ix_sys_notice_status` (`status`),
  KEY `ix_sys_notice_created_time` (`created_time`),
  KEY `ix_sys_notice_updated_id` (`updated_id`),
  CONSTRAINT `sys_notice_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_notice_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

LOCK TABLES `sys_notice` WRITE;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_param`
--

DROP TABLE IF EXISTS `sys_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_param` (
  `config_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数名称',
  `config_key` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数键名',
  `config_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '参数键值',
  `config_type` tinyint(1) DEFAULT NULL COMMENT '系统内置(True:是 False:否)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_param_uuid` (`uuid`),
  KEY `ix_sys_param_status` (`status`),
  KEY `ix_sys_param_updated_time` (`updated_time`),
  KEY `ix_sys_param_id` (`id`),
  KEY `ix_sys_param_created_time` (`created_time`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统参数表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_param`
--

LOCK TABLES `sys_param` WRITE;
/*!40000 ALTER TABLE `sys_param` DISABLE KEYS */;
INSERT INTO `sys_param` VALUES ('网站名称','sys_web_title','FastApiAdmin',1,1,'29345dea-177e-4634-a90a-72cb33ed6891','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('网站描述','sys_web_description','FastApiAdmin 是完全开源的权限管理系统',1,2,'2fd29e09-2258-482c-ad23-bda3120360cf','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('网页图标','sys_web_favicon','https://service.fastapiadmin.com/api/v1/static/image/favicon.png',1,3,'36851a0d-b7eb-4216-93df-a5761ad89af0','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('网站Logo','sys_web_logo','https://service.fastapiadmin.com/api/v1/static/image/logo.png',1,4,'9561c755-a429-4764-b9ef-12fb90a65b24','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('登录背景','sys_login_background','https://service.fastapiadmin.com/api/v1/static/image/background.svg',1,5,'75c16099-dd8c-4315-8dde-4c2ffcdc6e6f','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('版权信息','sys_web_copyright','Copyright © 2025-2026 service.fastapiadmin.com 版权所有',1,6,'6b27853f-2047-44eb-be28-6239151e0907','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('备案信息','sys_keep_record','陕ICP备2025069493号-1',1,7,'6ae4da80-956f-4fd9-9706-df0adf817ee0','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('帮助文档','sys_help_doc','https://service.fastapiadmin.com',1,8,'92ca7eda-0b4b-4c65-b58d-9ded079e1996','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('隐私政策','sys_web_privacy','https://github.com/fastapiadmin/FastapiAdmin/blob/master/LICENSE',1,9,'f877e73e-ae79-4661-a425-54172c5d539a','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('用户协议','sys_web_clause','https://github.com/fastapiadmin/FastapiAdmin/blob/master/LICENSE',1,10,'25575848-d4a2-47ef-9598-cc19798b91d3','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('源码代码','sys_git_code','https://github.com/fastapiadmin/FastapiAdmin.git',1,11,'7a5abf3e-ba34-4886-b7ce-173f884393f8','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('项目版本','sys_web_version','2.0.0',1,12,'fa02f093-a6cc-4c61-b374-a6638b50bacd','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('演示模式启用','demo_enable','false',1,13,'8716c756-fd1d-46a7-9dcf-54ba4c062efd','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('演示访问IP白名单','ip_white_list','[\"127.0.0.1\"]',1,14,'1f0c9531-52ba-4d5a-8806-b13c64404c6c','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('接口白名单','white_api_list_path','[\"/api/v1/system/auth/login\", \"/api/v1/system/auth/token/refresh\", \"/api/v1/system/auth/captcha/get\", \"/api/v1/system/auth/logout\", \"/api/v1/system/config/info\", \"/api/v1/system/user/current/info\", \"/api/v1/system/notice/available\", \"/api/v1/system/auth/auto-login/users\", \"/api/v1/system/auth/auto-login/token\", \"/api/v1/system/auth/auto-login\"]',1,15,'dcfc1f97-2626-4ed7-a470-3640594a18da','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18'),('访问IP黑名单','ip_black_list','[]',1,16,'a52b02b6-b15e-4af7-a623-99fa33ca6a6a','0','初始化数据','2026-03-17 10:31:18','2026-03-17 10:31:18');
/*!40000 ALTER TABLE `sys_param` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_position`
--

DROP TABLE IF EXISTS `sys_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_position` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位名称',
  `order` int NOT NULL COMMENT '显示排序',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_position_uuid` (`uuid`),
  KEY `ix_sys_position_id` (`id`),
  KEY `ix_sys_position_status` (`status`),
  KEY `ix_sys_position_updated_id` (`updated_id`),
  KEY `ix_sys_position_created_id` (`created_id`),
  KEY `ix_sys_position_created_time` (`created_time`),
  KEY `ix_sys_position_updated_time` (`updated_time`),
  CONSTRAINT `sys_position_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_position_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='岗位表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_position`
--

LOCK TABLES `sys_position` WRITE;
/*!40000 ALTER TABLE `sys_position` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_position` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `code` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '角色编码',
  `order` int NOT NULL COMMENT '显示排序',
  `data_scope` int NOT NULL COMMENT '数据权限范围(1:仅本人 2:本部门 3:本部门及以下 4:全部 5:自定义)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_role_uuid` (`uuid`),
  KEY `ix_sys_role_updated_time` (`updated_time`),
  KEY `ix_sys_role_status` (`status`),
  KEY `ix_sys_role_code` (`code`),
  KEY `ix_sys_role_id` (`id`),
  KEY `ix_sys_role_created_time` (`created_time`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES ('管理员角色','ADMIN',1,4,1,'f306770d-009b-4d80-af6b-a678259e9c81','0','初始化角色','2026-03-17 10:31:18','2026-03-17 10:31:18');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_depts`
--

DROP TABLE IF EXISTS `sys_role_depts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_depts` (
  `role_id` int NOT NULL COMMENT '角色ID',
  `dept_id` int NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`),
  KEY `dept_id` (`dept_id`),
  CONSTRAINT `sys_role_depts_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_role_depts_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_depts`
--

LOCK TABLES `sys_role_depts` WRITE;
/*!40000 ALTER TABLE `sys_role_depts` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_depts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menus`
--

DROP TABLE IF EXISTS `sys_role_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menus` (
  `role_id` int NOT NULL COMMENT '角色ID',
  `menu_id` int NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `sys_role_menus_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_role_menus_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `sys_menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menus`
--

LOCK TABLES `sys_role_menus` WRITE;
/*!40000 ALTER TABLE `sys_role_menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名/登录账号',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '昵称',
  `mobile` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `email` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `gender` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '性别(0:男 1:女 2:未知)',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL地址',
  `is_superuser` tinyint(1) NOT NULL COMMENT '是否超管',
  `last_login` datetime DEFAULT NULL COMMENT '最后登录时间',
  `gitee_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Gitee登录',
  `github_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Github登录',
  `wx_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信登录',
  `qq_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'QQ登录',
  `dept_id` int DEFAULT NULL COMMENT '部门ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `ix_sys_user_uuid` (`uuid`),
  UNIQUE KEY `mobile` (`mobile`),
  UNIQUE KEY `email` (`email`),
  KEY `ix_sys_user_updated_time` (`updated_time`),
  KEY `ix_sys_user_updated_id` (`updated_id`),
  KEY `ix_sys_user_id` (`id`),
  KEY `ix_sys_user_created_time` (`created_time`),
  KEY `ix_sys_user_status` (`status`),
  KEY `ix_sys_user_dept_id` (`dept_id`),
  KEY `ix_sys_user_created_id` (`created_id`),
  CONSTRAINT `sys_user_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES ('admin','$2b$12$e2IJgS/cvHgJ0H3G7Xa08OXoXnk6N/NX3IZRtubBDElA0VLZhkNOa','超级管理员',NULL,NULL,'0','https://service.fastapiadmin.com/api/v1/static/image/avatar.png',1,'2026-03-17 14:04:54',NULL,NULL,NULL,NULL,1,1,'24f4d172-587a-47f5-9ae3-916dfd8235c6','0','超级管理员','2026-03-17 10:31:19','2026-03-17 14:04:54',NULL,NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_positions`
--

DROP TABLE IF EXISTS `sys_user_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_positions` (
  `user_id` int NOT NULL COMMENT '用户ID',
  `position_id` int NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`position_id`),
  KEY `position_id` (`position_id`),
  CONSTRAINT `sys_user_positions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_user_positions_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `sys_position` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户岗位关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_positions`
--

LOCK TABLES `sys_user_positions` WRITE;
/*!40000 ALTER TABLE `sys_user_positions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_user_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_roles`
--

DROP TABLE IF EXISTS `sys_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_roles` (
  `user_id` int NOT NULL COMMENT '用户ID',
  `role_id` int NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `sys_user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_roles`
--

LOCK TABLES `sys_user_roles` WRITE;
/*!40000 ALTER TABLE `sys_user_roles` DISABLE KEYS */;
INSERT INTO `sys_user_roles` VALUES (1,1);
/*!40000 ALTER TABLE `sys_user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_job`
--

DROP TABLE IF EXISTS `task_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_job` (
  `job_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务ID',
  `job_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '任务名称',
  `trigger_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '触发方式: cron/interval/date/manual',
  `status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行状态',
  `next_run_time` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下次执行时间',
  `job_state` text COLLATE utf8mb4_unicode_ci COMMENT '任务状态信息',
  `result` text COLLATE utf8mb4_unicode_ci COMMENT '执行结果',
  `error` text COLLATE utf8mb4_unicode_ci COMMENT '错误信息',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_job_uuid` (`uuid`),
  KEY `ix_task_job_updated_time` (`updated_time`),
  KEY `ix_task_job_id` (`id`),
  KEY `ix_task_job_created_time` (`created_time`),
  KEY `ix_task_job_job_id` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务执行日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_job`
--

LOCK TABLES `task_job` WRITE;
/*!40000 ALTER TABLE `task_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_node`
--

DROP TABLE IF EXISTS `task_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_node` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点名称',
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点编码',
  `jobstore` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '存储器',
  `executor` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '执行器',
  `trigger` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '触发器',
  `trigger_args` text COLLATE utf8mb4_unicode_ci COMMENT '触发器参数',
  `func` text COLLATE utf8mb4_unicode_ci COMMENT '代码块',
  `args` text COLLATE utf8mb4_unicode_ci COMMENT '位置参数',
  `kwargs` text COLLATE utf8mb4_unicode_ci COMMENT '关键字参数',
  `coalesce` tinyint(1) DEFAULT NULL COMMENT '是否合并运行',
  `max_instances` int DEFAULT NULL COMMENT '最大实例数',
  `start_date` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开始时间',
  `end_date` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结束时间',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_task_node_uuid` (`uuid`),
  KEY `ix_task_node_updated_time` (`updated_time`),
  KEY `ix_task_node_id` (`id`),
  KEY `ix_task_node_created_id` (`created_id`),
  KEY `ix_task_node_status` (`status`),
  KEY `ix_task_node_updated_id` (`updated_id`),
  KEY `ix_task_node_created_time` (`created_time`),
  CONSTRAINT `task_node_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_node_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='节点类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_node`
--

LOCK TABLES `task_node` WRITE;
/*!40000 ALTER TABLE `task_node` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_node` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-17 14:34:31
