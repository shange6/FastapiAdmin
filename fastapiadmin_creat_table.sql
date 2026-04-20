SET FOREIGN_KEY_CHECKS = 0;   -- 临时关闭外键约束检查
-- =============================================
-- 〇、项目表
-- =============================================
DROP TABLE IF EXISTS `data_project`;
CREATE TABLE `data_project` (
  `code` varchar(64) NOT NULL COMMENT '项目编码',
  `name` varchar(255) NOT NULL COMMENT '项目名称',
  `no` varchar(64) NOT NULL COMMENT '项目编号',

  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_data_project_uuid` (`uuid`),
  UNIQUE KEY `uk_data_project_code` (`code`),
  UNIQUE KEY `uk_data_project_no` (`no`),
  -- KEY `ix_data_project_status` (`status`),
  -- KEY `ix_data_project_created_time` (`created_time`),
  -- KEY `ix_data_project_updated_time` (`updated_time`),
  -- KEY `ix_data_project_created_id` (`created_id`),
  -- KEY `ix_data_project_updated_id` (`updated_id`),
  CONSTRAINT `fk_data_project_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_data_project_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目信息表';

-- =============================================
-- 一、BOM清单表
-- =============================================
DROP TABLE IF EXISTS `data_bom`;
CREATE TABLE `data_bom` (
  `project_code` varchar(64) NOT NULL COMMENT '项目编码',
  `parent_code` varchar(64) NOT NULL COMMENT '父代号',
  `first_code` varchar(64) NOT NULL COMMENT '一级代号',
  `code` varchar(64) DEFAULT NULL COMMENT '代号',
  `spec` varchar(255) NOT NULL COMMENT '名称',
  `count` int NOT NULL COMMENT '数量',
  `material` varchar(255) DEFAULT NULL COMMENT '材质',
  `unit_mass` float DEFAULT NULL COMMENT '单重',
  `total_mass` float DEFAULT NULL COMMENT '总重',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `borrow` boolean NOT NULL DEFAULT 0 COMMENT '是否借用',
  `procure` boolean NOT NULL DEFAULT 0 COMMENT '是否采购',
  `noimage` boolean NOT NULL DEFAULT 0 COMMENT '是否无图',
  `figure` varchar(255) DEFAULT NULL COMMENT '是否附图',
  
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_data_bom_uuid` (`uuid`),
  KEY `ix_data_bom_parent_code` (`parent_code`),
  KEY `ix_data_bom_first_code` (`first_code`),
  KEY `ix_data_bom_code` (`code`),
  CONSTRAINT `fk_data_bom_project_code` FOREIGN KEY (`project_code`) REFERENCES `data_project` (`code`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_data_bom_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_data_bom_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='BOM清单';

-- =============================================
-- 二、工艺表：支持 主工艺 + 子工艺 树形结构
-- =============================================
DROP TABLE IF EXISTS `produce_craft`;
CREATE TABLE `produce_craft` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '工艺ID',
  `parent_id` int NOT NULL DEFAULT 0 COMMENT '父工艺ID',
  `has_child` boolean NOT NULL DEFAULT 0 COMMENT '子工艺',
  `name` varchar(64) NOT NULL COMMENT '工艺名称',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工艺表';

-- 插入主工艺
INSERT INTO produce_craft (id, parent_id, has_child, name) VALUES 
(1, 0, 1, '下料'),
(2, 0, 0, '铆焊'),
(3, 0, 1, '机加'),
(4, 0, 1, '喷漆'),
(5, 0, 0, '装配'),
(6, 3, 0, '车削'),
(7, 3, 0, '铣削'),
(8, 3, 0, '钻削'),
(9, 3, 0, '镗削'),
(10, 3, 0, '刨削'),
(11, 1, 0, '板材'),
(12, 1, 0, '型材'),
(13, 4, 0, '打磨'),
(14, 4, 0, '底漆'),
(15, 4, 0, '面漆');

-- =============================================
-- 三、工艺路线明细表（一条路线 = 多个工序）
-- =============================================
DROP TABLE IF EXISTS `produce_craft_route`;
CREATE TABLE `produce_craft_route` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `route` int NOT NULL COMMENT '路线编号',
  `sort` int NOT NULL COMMENT '工序顺序',
  `craft_id` int NOT NULL COMMENT '工艺ID',
  PRIMARY KEY (`id`),
  KEY `idx_route` (`route`),
  KEY `fk_craft` (`craft_id`),
  CONSTRAINT `fk_route_craft` FOREIGN KEY (`craft_id`) REFERENCES `produce_craft` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工艺路线明细';

-- 插入所有工艺路线
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES 
-- 1: 下料
(1,1,1),
-- 2: 下料 → 铆焊
(2,1,1),(2,2,2),
-- 3: 下料 → 铆焊 → 机加
(3,1,1),(3,2,2),(3,3,3),
-- 4: 下料 → 铆焊 → 机加 → 喷漆
(4,1,1),(4,2,2),(4,3,3),(4,4,4),
-- 5: 下料 → 铆焊 → 机加 → 喷漆 → 装配
(5,1,1),(5,2,2),(5,3,3),(5,4,4),(5,5,5),
-- 6: 下料 → 铆焊 → 机加 → 装配
(6,1,1),(6,2,2),(6,3,3),(6,4,5),
-- 7: 下料 → 铆焊 → 机加 → 装配 → 喷漆
(7,1,1),(7,2,2),(7,3,3),(7,4,5),(7,5,4),
-- 8: 下料 → 铆焊 → 喷漆
(8,1,1),(8,2,2),(8,3,4),
-- 9: 下料 → 铆焊 → 喷漆 → 装配
(9,1,1),(9,2,2),(9,3,4),(9,4,5),
-- 10: 下料 → 铆焊 → 装配
(10,1,1),(10,2,2),(10,3,5),
-- 11: 下料 → 铆焊 → 装配 → 喷漆
(11,1,1),(11,2,2),(11,3,5),(11,4,4),
-- 12: 下料 → 机加
(12,1,1),(12,2,3),
-- 13: 下料 → 机加 → 铆焊
(13,1,1),(13,2,3),(13,3,2),
-- 14: 下料 → 机加 → 铆焊 → 喷漆
(14,1,1),(14,2,3),(14,3,2),(14,4,4),
-- 15: 下料 → 机加 → 铆焊 → 喷漆 → 装配
(15,1,1),(15,2,3),(15,3,2),(15,4,4),(15,5,5),
-- 16: 下料 → 机加 → 铆焊 → 装配
(16,1,1),(16,2,3),(16,3,2),(16,4,5),
-- 17: 下料 → 机加 → 铆焊 → 装配 → 喷漆
(17,1,1),(17,2,3),(17,3,2),(17,4,5),(17,5,4),
-- 18: 下料 → 机加 → 铆焊 → 机加
(18,1,1),(18,2,3),(18,3,2),(18,4,3),
-- 19: 下料 → 机加 → 铆焊 → 机加 → 喷漆
(19,1,1),(19,2,3),(19,3,2),(19,4,3),(19,5,4),
-- 20: 下料 → 机加 → 铆焊 → 机加 → 装配
(20,1,1),(20,2,3),(20,3,2),(20,4,3),(20,5,5),
-- 21: 下料 → 机加 → 铆焊 → 机加 → 喷漆 → 装配
(21,1,1),(21,2,3),(21,3,2),(21,4,3),(21,5,4),(21,6,5),
-- 22: 下料 → 机加 → 铆焊 → 机加 → 装配 → 喷漆
(22,1,1),(22,2,3),(22,3,2),(22,4,3),(22,5,5),(22,6,4),
-- 23: 下料 → 机加 → 喷漆
(23,1,1),(23,2,3),(23,3,4),
-- 24: 下料 → 机加 → 喷漆 → 装配
(24,1,1),(24,2,3),(24,3,4),(24,4,5),
-- 25: 下料 → 机加 → 装配
(25,1,1),(25,2,3),(25,3,5),
-- 26: 下料 → 机加 → 装配 → 喷漆
(26,1,1),(26,2,3),(26,3,5),(26,4,4),
-- 27: 下料 → 喷漆
(27,1,1),(27,2,4),
-- 28: 下料 → 喷漆 → 装配
(28,1,1),(28,2,4),(28,3,5),
-- 29: 下料 → 装配
(29,1,1),(29,2,5),
-- 30: 下料 → 装配 → 喷漆
(30,1,1),(30,2,5),(30,3,4),
-- 31: 铆焊
(31,1,2),
-- 32: 铆焊 → 机加
(32,1,2),(32,2,3),
-- 33: 铆焊 → 机加 → 喷漆
(33,1,2),(33,2,3),(33,3,4),
-- 34: 铆焊 → 机加 → 喷漆 → 装配
(34,1,2),(34,2,3),(34,3,4),(34,4,5),
-- 35: 铆焊 → 机加 → 装配
(35,1,2),(35,2,3),(35,3,5),
-- 36: 铆焊 → 机加 → 装配 → 喷漆
(36,1,2),(36,2,3),(36,3,5),(36,4,4),
-- 37: 铆焊 → 喷漆
(37,1,2),(37,2,4),
-- 38: 铆焊 → 喷漆 → 装配
(38,1,2),(38,2,4),(38,3,5),
-- 39: 铆焊 → 装配
(39,1,2),(39,2,5),
-- 40: 铆焊 → 装配 → 喷漆
(40,1,2),(40,2,5),(40,3,4),
-- 41: 机加
(41,1,3),
-- 42: 机加 → 铆焊
(42,1,3),(42,2,2),
-- 43: 机加 → 铆焊 → 机加
(43,1,3),(43,2,2),(43,3,3),
-- 44: 机加 → 铆焊 → 机加 → 喷漆
(44,1,3),(44,2,2),(44,3,3),(44,4,4),
-- 45: 机加 → 铆焊 → 机加 → 装配
(45,1,3),(45,2,2),(45,3,3),(45,4,5),
-- 46: 机加 → 铆焊 → 机加 → 喷漆 → 装配
(46,1,3),(46,2,2),(46,3,3),(46,4,4),(46,5,5),
-- 47: 机加 → 铆焊 → 机加 → 装配 → 喷漆
(47,1,3),(47,2,2),(47,3,3),(47,4,5),(47,5,4),
-- 48: 机加 → 铆焊 → 喷漆
(48,1,3),(48,2,2),(48,3,4),
-- 49: 机加 → 铆焊 → 喷漆 → 装配
(49,1,3),(49,2,2),(49,3,4),(49,4,5),
-- 50: 机加 → 铆焊 → 装配
(50,1,3),(50,2,2),(50,3,5),
-- 51: 机加 → 铆焊 → 装配 → 喷漆
(51,1,3),(51,2,2),(51,3,5),(51,4,4),
-- 52: 机加 → 喷漆
(52,1,3),(52,2,4),
-- 53: 机加 → 喷漆 → 装配
(53,1,3),(52,2,4),(53,3,5),
-- 54: 机加 → 装配
(54,1,3),(54,2,5),
-- 55: 机加 → 装配 → 喷漆
(55,1,3),(54,2,5),(55,3,4),
-- 56: 喷漆
(56,1,4),
-- 57: 喷漆 → 装配
(57,1,4),(57,2,5),
-- 58: 装配
(58,1,5),
-- 59: 装配 → 喷漆
(59,1,5),(59,2,4);

-- =============================================
-- 四、路线名称表（自动拼接路线名称：下料→车削→铣削）
-- =============================================
DROP TABLE IF EXISTS `produce_route_name`;
CREATE TABLE produce_route_name (
    route int NOT NULL PRIMARY KEY COMMENT '工艺路线编号',
    name VARCHAR(512) NOT NULL UNIQUE COMMENT '路线拼接名称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT '工艺路线名称'
AS
SELECT 
    pcr.route AS route,
    GROUP_CONCAT(pc.name ORDER BY pcr.sort SEPARATOR ' → ') AS name
FROM produce_craft_route pcr
LEFT JOIN produce_craft pc ON pcr.craft_id = pc.id
GROUP BY pcr.route
ORDER BY pcr.route;

-- =============================================
-- 五、BOM <-> 路线 关联表
-- =============================================
DROP TABLE IF EXISTS `produce_bom_route`;
CREATE TABLE `produce_bom_route` (
  `project_code` varchar(64) NOT NULL COMMENT '项目编码',
  `first_code` varchar(64) NOT NULL COMMENT '一级代号',
  `bom_id` int NOT NULL COMMENT 'BOMID',
  `route` int NOT NULL COMMENT '路线编号',

  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bom_route` (`bom_id`,`route`),
  KEY `ix_bom_route_project_code` (`project_code`),
  KEY `ix_bom_route_first_code` (`first_code`),
  KEY `ix_bom_route_bom_id` (`bom_id`),
  KEY `ix_bom_route_route` (`route`),
  CONSTRAINT `fk_bom_route_bom` FOREIGN KEY (`bom_id`) REFERENCES `data_bom` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_bom_route_route` FOREIGN KEY (`route`) REFERENCES `produce_route_name` (`route`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_bom_route_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_bom_route_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='BOM路线关联';

-- =============================================
-- 六、BOM工时表（精确到子工艺）
-- =============================================
DROP TABLE IF EXISTS `produce_bom_manhour`;
CREATE TABLE `produce_bom_manhour` (
  `project_code` varchar(64) NOT NULL COMMENT '项目编码',
  `first_code` varchar(64) NOT NULL COMMENT '一级代号',
  `bom_id` int NOT NULL COMMENT 'BOMID',
  `craft_id` int NOT NULL COMMENT '子工艺ID',
  `manhour` int NOT NULL DEFAULT 0 COMMENT '工时',

  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_manhour_bom_craft` (`bom_id`,`craft_id`),
  KEY `ix_manhour_project_code` (`project_code`),
  KEY `ix_manhour_first_code` (`first_code`),
  KEY `ix_manhour_bom_id` (`bom_id`),
  KEY `ix_manhour_craft_id` (`craft_id`),
  CONSTRAINT `fk_manhour_bom` FOREIGN KEY (`bom_id`) REFERENCES `data_bom` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_manhour_craft` FOREIGN KEY (`craft_id`) REFERENCES `produce_craft` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_manhour_bom_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_manhour_bom_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='BOM工时关联';

-- =============================================
-- 七、生产工单表（精确到子工艺）
-- =============================================
DROP TABLE IF EXISTS `produce_order`;
CREATE TABLE `produce_order` (
  `no` varchar(32) NOT NULL COMMENT '单号',
  `project_code` varchar(64) NOT NULL COMMENT '项目编码',
  `first_code` varchar(64) NOT NULL COMMENT '一级代号',
  `bom_id` int NOT NULL COMMENT 'BOMID',
  `craft_id` int NOT NULL COMMENT '子工艺ID',
  `man_hour` int NOT NULL DEFAULT 0 COMMENT '工时',  
  `plan_count` int NOT NULL DEFAULT 1 COMMENT '计划数量',
  `real_count` int DEFAULT 0 COMMENT '实际数量',
  `plan_date` date NOT NULL COMMENT '计划日期',
  `real_date` date DEFAULT NULL COMMENT '实际日期',
  `plan_user` int NOT NULL COMMENT '计划用户',
  `real_user` int NULL COMMENT '实际用户',

  `id` int NOT NULL AUTO_INCREMENT COMMENT '工单ID',  
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_uuid` (`uuid`),
  UNIQUE KEY `uk_order_bom_craft` (`bom_id`,`craft_id`),
  KEY `ix_order_project_code` (`project_code`),
  KEY `ix_order_first_code` (`first_code`),
  KEY `ix_order_bom_id` (`bom_id`),
  KEY `ix_order_no` (`no`),
  KEY `ix_order_craft_id` (`craft_id`),
  CONSTRAINT `fk_order_bom` FOREIGN KEY (`bom_id`) REFERENCES `data_bom` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_craft` FOREIGN KEY (`craft_id`) REFERENCES `produce_craft` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_plan_user` FOREIGN KEY (`plan_user`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_real_user` FOREIGN KEY (`real_user`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='生产工单';


-- =============================================
-- 八、制造过程主表
-- =============================================
DROP TABLE IF EXISTS `produce_make`;
CREATE TABLE `produce_make` (
  `project_code` varchar(64) NOT NULL COMMENT '项目代码',
  `first_code` varchar(64) NOT NULL COMMENT '一级代号',
  `bom_id` int NOT NULL COMMENT 'BOMID',
  `order_no` varchar(32) NOT NULL COMMENT '单号',
  `current_sort` int DEFAULT 1 COMMENT '工艺序号',
  `current_craft_id` int NOT NULL COMMENT '工艺ID',
  
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',  
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_make_bom_id` (`bom_id`),
  KEY `ix_make_first_code` (`first_code`),
  KEY `ix_make_order_no` (`order_no`),
  KEY `ix_make_project_code` (`project_code`),
  KEY `ix_make_current_sort` (`current_sort`),
  KEY `ix_make_current_craft_id` (`current_craft_id`),
  CONSTRAINT `fk_make_bom_id` FOREIGN KEY (`bom_id`) REFERENCES `data_bom` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_make_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_make_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='制造流程主表';


-- =============================================
-- 九、制造流程执行明细
-- =============================================
DROP TABLE IF EXISTS `produce_make_flow`;
CREATE TABLE `produce_make_flow` (
  `project_code` varchar(64) NOT NULL COMMENT '项目代码',
  `first_code` varchar(64) NOT NULL COMMENT '一级代号',
  `bom_id` int NOT NULL COMMENT 'BOMID',
  `make_id` int NOT NULL COMMENT '制造ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `sort` int NOT NULL COMMENT '工艺序号',
  `craft_id` int NOT NULL COMMENT '工艺ID',
  `end_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '完工时间',

  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',  
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_flow_bom_make_sort_craft` (`bom_id`,`make_id`,`sort`,`craft_id`),
  KEY `ix_flow_project_code` (`project_code`),
  KEY `ix_flow_first_code` (`first_code`),
  KEY `ix_flow_bom_id` (`bom_id`),
  KEY `ix_flow_make_id` (`make_id`),
  KEY `ix_flow_user_id` (`user_id`),
  KEY `ix_flow_craft_id` (`craft_id`),
  KEY `ix_flow_end_time` (`end_time`),
  CONSTRAINT `fk_flow_bom_id` FOREIGN KEY (`bom_id`) REFERENCES `data_bom` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_flow_make_id` FOREIGN KEY (`make_id`) REFERENCES `produce_make` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_flow_user_id` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_flow_craft_id` FOREIGN KEY (`craft_id`) REFERENCES `produce_craft` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_flow_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_flow_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='制造流程执行表';









SET FOREIGN_KEY_CHECKS = 1;   -- 重新开启外键约束检查