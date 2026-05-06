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

-- =============================================
-- 十、BOM工时计算表
-- =============================================
CREATE TABLE BOM_hours (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',

    -- 零件基础信息
    `name` VARCHAR(128) NOT NULL COMMENT '零件名称',
    `model` VARCHAR(64) COMMENT '零件型号',
    `material` VARCHAR(64) COMMENT '材质',
    `unit` ENUM('g','mm', 'p') NOT NULL COMMENT '计算单位：g=克 mm=毫米 p=件',
    `unit_hour` BIGINT NOT NULL DEFAULT 0 COMMENT '单位工时ms',

    `blanking_ratio` INT DEFAULT 0 COMMENT '下料工时比率',
    `welding_ratio` INT DEFAULT 0 COMMENT '铆焊工时比率',
    `fitting_ratio` INT DEFAULT 0 COMMENT '装配工时比率',

    `description` TEXT NULL COMMENT '备注/描述',
    `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `created_id` INT NULL COMMENT '创建人ID',
    `updated_id` INT NULL COMMENT '更新人ID',

    UNIQUE KEY `uk_bom_hours_name_model_material` (`name`,`model`,`material`),
    CONSTRAINT `fk_bom_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_bom_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT = 'BOM零件工时计算表' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = 'BOM零件工时计算表';


-- ===================== 提升机标准件工时（秒单位 · 系数×1000）=====================
INSERT INTO BOM_hours 
(`name`, `model`, `material`, `unit`, `unit_hour`, `blanking_ratio`, `welding_ratio`, `fitting_ratio`, `description`, `created_id`, `updated_id`) VALUES
-- DT14 1-9中罩										
('提升机'	 'DT14'	 ''	 'p'	189540000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189565920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189591840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189617760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189643680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189669600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189695520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189721440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT14'	 ''	 'p'	189747360	185	450	365	 '9中罩'	1	 1),
-- DT16 1-9中罩
('提升机'	 'DT16'	 ''	 'p'	210924000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	210949920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	210975840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	211001760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	211027680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	211053600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	211079520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	211105440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT16'	 ''	 'p'	211131360	185	450	365	 '9中罩'	1	 1),
-- DT20 1-9中罩
('提升机'	 'DT20'	 ''	 'p'	282204000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282229920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282255840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282281760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282307680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282333600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282359520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282385440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT20'	 ''	 'p'	282411360	185	450	365	 '9中罩'	1	 1),
-- DT25 1-9中罩
('提升机'	 'DT25'	 ''	 'p'	321408000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321433920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321459840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321485760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321511680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321537600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321563520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321589440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT25'	 ''	 'p'	321615360	185	450	365	 '9中罩'	1	 1),
-- DT30 1-9中罩
('提升机'	 'DT30'	 ''	 'p'	346356000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346381920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346407840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346433760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346459680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346485600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346511520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346537440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT30'	 ''	 'p'	346563360	185	450	365	 '9中罩'	1	 1),
-- DT32 1-9中罩
('提升机'	 'DT32'	 ''	 'p'	367740000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367765920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367791840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367817760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367843680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367869600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367895520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367921440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT32'	 ''	 'p'	367947360	185	450	365	 '9中罩'	1	 1),
-- DT35 1-9中罩
('提升机'	 'DT35'	 ''	 'p'	403380000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403405920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403431840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403457760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403483680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403509600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403535520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403561440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT35'	 ''	 'p'	403587360	185	450	365	 '9中罩'	1	 1),
-- DT45 1-9中罩
('提升机'	 'DT45'	 ''	 'p'	428328000	185	450	365	 '1中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428353920	185	450	365	 '2中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428379840	185	450	365	 '3中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428405760	185	450	365	 '4中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428431680	185	450	365	 '5中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428457600	185	450	365	 '6中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428483520	185	450	365	 '7中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428509440	185	450	365	 '8中罩'	1	 1),
('提升机'	 'DT45'	 ''	 'p'	428535360	185	450	365	 '9中罩'	1	 1),
-- DT14 自张紧 1-9中罩
('自张紧提升机'	 'DT14'	 ''	 'p'	208494000	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208519920	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208545840	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208571760	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208597680	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208623600	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208649520	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208675440	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT14'	 ''	 'p'	208701360	185	450	365	 '9中罩'	1	 1),
-- DT16 自张紧 1-9中罩
('自张紧提升机'	 'DT16'	 ''	 'p'	232016400	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232042320	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232068240	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232094160	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232120080	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232146000	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232171920	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232197840	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT16'	 ''	 'p'	232223760	185	450	365	 '9中罩'	1	 1),
-- DT20 自张紧 1-9中罩
('自张紧提升机'	 'DT20'	 ''	 'p'	310424400	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310450320	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310476240	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310502160	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310528080	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310554000	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310579920	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310605840	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT20'	 ''	 'p'	310631760	185	450	365	 '9中罩'	1	 1),
-- DT25 自张紧 1-9中罩
('自张紧提升机'	 'DT25'	 ''	 'p'	353548800	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353574720	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353600640	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353626560	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353652480	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353678400	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353704320	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353730240	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT25'	 ''	 'p'	353756160	185	450	365	 '9中罩'	1	 1),
-- DT30 自张紧 1-9中罩
('自张紧提升机'	 'DT30'	 ''	 'p'	380991600	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381017520	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381043440	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381069360	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381095280	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381121200	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381147120	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381173040	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT30'	 ''	 'p'	381198960	185	450	365	 '9中罩'	1	 1),
-- DT32 自张紧 1-9中罩
('自张紧提升机'	 'DT32'	 ''	 'p'	404514000	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404539920	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404565840	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404591760	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404617680	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404643600	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404669520	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404695440	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT32'	 ''	 'p'	404721360	185	450	365	 '9中罩'	1	 1),
-- DT35 自张紧 1-9中罩
('自张紧提升机'	 'DT35'	 ''	 'p'	443718000	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443743920	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443769840	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443795760	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443821680	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443847600	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443873520	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443899440	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT35'	 ''	 'p'	443925360	185	450	365	 '9中罩'	1	 1),
-- DT45 自张紧 1-9中罩
('自张紧提升机'	 'DT45'	 ''	 'p'	471160800	185	450	365	 '1中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471186720	185	450	365	 '2中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471212640	185	450	365	 '3中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471238560	185	450	365	 '4中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471264480	185	450	365	 '5中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471290400	185	450	365	 '6中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471316320	185	450	365	 '7中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471342240	185	450	365	 '8中罩'	1	 1),
('自张紧提升机'	 'DT45'	 ''	 'p'	471368160	185	450	365	 '9中罩'	1	 1),

('分离器', 'Q376重力', '', 'p', 99792000, 185, 600, 215, '', 1, 1),
('分离器', 'H型钢重力', '', 'p', 138996000, 185, 600, 215, '', 1, 1),
('分离器', 'L1000', '', 'p', 274428000, 185, 600, 215, '', 1, 1),
('分离器', 'L1200', '', 'p', 299376000, 185, 600, 215, '', 1, 1),
('分离器', 'L1400', '', 'p', 324324000, 185, 600, 215, '', 1, 1),
('分离器', 'L1600', '', 'p', 349272000, 185, 600, 215, '', 1, 1),
('分离器', 'L1800', '', 'p', 359964000, 185, 600, 215, '', 1, 1),
('分离器', 'L2000', '', 'p', 374220000, 185, 600, 215, '', 1, 1),

('螺旋输送器', 'ф15', '', 'mm', 10692, 165, 500, 335, '轴壳各半', 1, 1),
('螺旋输送器', 'ф20', '', 'mm', 17820, 165, 500, 335, '轴壳各半', 1, 1),
('螺旋输送器', 'ф25', '', 'mm', 20671, 165, 500, 335, '轴壳各半', 1, 1),
('螺旋输送器', 'ф30', '', 'mm', 25661, 165, 500, 335, '轴壳各半', 1, 1),
('螺旋输送器', 'ф35', '', 'mm', 27800, 165, 500, 335, '轴壳各半', 1, 1),
('螺旋输送器', 'ф40', '', 'mm', 29225, 165, 500, 335, '轴壳各半', 1, 1),
('螺旋输送器', 'ф52', '', 'mm', 34214, 165, 500, 335, '轴壳各半', 1, 1),

('螺旋输送器', 'ф15', '', 'mm', 13365, 132, 600, 268, '螺旋轴壳各半', 1, 1),
('螺旋输送器', 'ф20', '', 'mm', 22275, 132, 600, 268, '螺旋轴壳各半', 1, 1),
('螺旋输送器', 'ф25', '', 'mm', 25839, 132, 600, 268, '螺旋轴壳各半', 1, 1),
('螺旋输送器', 'ф30', '', 'mm', 32076, 132, 600, 268, '螺旋轴壳各半', 1, 1),
('螺旋输送器', 'ф35', '', 'mm', 34750, 132, 600, 268, '螺旋轴壳各半', 1, 1),
('螺旋输送器', 'ф40', '', 'mm', 36531, 132, 600, 268, '螺旋轴壳各半', 1, 1),
('螺旋输送器', 'ф52', '', 'mm', 42768, 132, 600, 268, '螺旋轴壳各半', 1, 1),

('抛丸器', 'Q034Z8', '', 'p', 57600000, 100, 400, 500, '', 1, 1),
('抛丸器', 'Q035Z10', '', 'p', 57600000, 100, 400, 500, '', 1, 1),
('抛丸器', 'Q035P10', '', 'p', 68400000, 100, 400, 500, '', 1, 1),
('抛丸器', '180-4RK', '', 'p', 68400000, 100, 400, 500, '', 1, 1),
('抛丸器', '75kw', '', 'p', 75600000, 100, 400, 500, '', 1, 1),

('弹丸控制器', 'DK28', '', 'p', 21600000, 200, 300, 500, '', 1, 1),
('弹丸控制器', 'DK50', '', 'p', 25200000, 200, 300, 500, '', 1, 1),
('弹丸控制器', 'DK70', '', 'p', 18000000, 100, 300, 600, '', 1, 1),
('弹丸控制器', 'DK80', '', 'p', 28800000, 200, 300, 500, '', 1, 1),
('弹丸控制器', 'DK100', '', 'p', 28800000, 200, 300, 500, '', 1, 1),
('弹丸控制器', 'DK120', '', 'p', 32400000, 200, 300, 500, '', 1, 1),

('积放悬链', '悬链直轨', '', 'p', 3564000, 400, 600, 0, '', 1, 1),
('积放悬链', '悬链弯轨', '', 'p', 81972000, 150, 650, 200, '', 1, 1),
('积放悬链', '驱动装置', '', 'p', 99792000, 150, 500, 350, '', 1, 1),
('积放悬链', '涨紧装置', '', 'p', 85536000, 150, 500, 350, '', 1, 1),
('积放悬链', '光轮回转', '', 'p', 32076000, 150, 600, 250, '', 1, 1),
('积放悬链', '自转装置', '', 'p', 64152000, 200, 200, 600, '', 1, 1),
('积放悬链', '悬链道岔', '', 'p', 46332000, 150, 700, 150, '', 1, 1),
('积放悬链', '止推器', '', 'p', 3564000, 150, 700, 150, '', 1, 1),
('积放悬链', '停止器', '', 'p', 7128000, 200, 400, 400, '', 1, 1),

('滤筒除尘器', '2个', '', 'p', 81972000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '4个', '', 'p', 103356000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '6个', '', 'p', 142560000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '6个', '', 'p', 228960000, 143, 591, 266, '带罩', 1, 1),
('滤筒除尘器', '9个', '', 'p', 203148000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '12个', '', 'p', 256608000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '18个', '', 'p', 256608000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '24个', '', 'p', 295812000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '30个', '', 'p', 331452000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '32个', '', 'p', 385020000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '36个', '', 'p', 409860000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '42个', '', 'p', 384912000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '48个', '', 'p', 409860000, 180, 520, 300, '', 1, 1),
('滤筒除尘器', '54个', '', 'p', 459756000, 180, 520, 300, '', 1, 1),

('脉冲滤袋', '50', '', 'p', 327888000, 181, 533, 286, '', 1, 1),
('脉冲滤袋', '60', '', 'p', 370656000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '75', '', 'p', 416988000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '80', '', 'p', 445500000, 176, 533, 291, '', 1, 1),
('脉冲滤袋', '100', '', 'p', 477576000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '120', '', 'p', 538164000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '150', '', 'p', 669912000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '180', '', 'p', 819720000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '200', '', 'p', 866052000, 176, 533, 291, '', 1, 1),
('脉冲滤袋', '220', '', 'p', 894564000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '250', '', 'p', 923076000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '280', '', 'p', 969408000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '300', '', 'p', 1012176000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '420', '', 'p', 1133352000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '450', '', 'p', 1161864000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '480', '', 'p', 1222452000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '600', '', 'p', 1667952000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '660', '', 'p', 1667952000, 195, 533, 272, '', 1, 1),
('脉冲滤袋', '1060', '', 'p', 2207952000, 195, 533, 272, '', 1, 1),

('脉冲滤袋配件', '50', '', 'p', 347921957, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '60', '', 'p', 391227408, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '75', '', 'p', 440130834, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '80', '', 'p', 473611050, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '100', '', 'p', 504081468, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '120', '', 'p', 568032102, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '150', '', 'p', 707092116, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '180', '', 'p', 865214460, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '200', '', 'p', 920699881, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '220', '', 'p', 944212302, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '250', '', 'p', 974306718, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '280', '', 'p', 1023210144, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '300', '', 'p', 1068351768, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '420', '', 'p', 1196253036, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '450', '', 'p', 1226347452, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '480', '', 'p', 1290298086, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '600', '', 'p', 1760523336, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '660', '', 'p', 1760523336, 185, 454, 361, '', 1, 1),
('脉冲滤袋配件', '1060', '', 'p', 2330493336, 185, 454, 361, '', 1, 1),

('机械振摆除尘', '75', '', 'p', 192456000, 200, 450, 350, '', 1, 1),
('机械振摆除尘', '100', '', 'p', 217404000, 200, 450, 350, '', 1, 1),
('机械振摆除尘', '150', '', 'p', 384912000, 200, 450, 350, '', 1, 1),
('机械振摆除尘', '200', '', 'p', 488268000, 200, 450, 350, '', 1, 1),

('机动扇形门', '', '', 'p', 117612000, 150, 400, 450, '', 1, 1),
('吊钩', '', '', 'p', 14256000, 50, 0, 950, '', 1, 1),
('横撑吊钩', '', '', 'p', 21384000, 150, 350, 500, '', 1, 1),
('顶部密封', '', '', 'p', 7128000, 100, 200, 700, '', 1, 1),
('顶防护门', '', '', 'p', 24948000, 200, 500, 300, '', 1, 1),
('吊钩扇形门', '', '', 'p', 103356000, 150, 500, 350, '', 1, 1),
('换轨装置', '', '', 'p', 39204000, 150, 450, 400, '', 1, 1),
('磁选分离器', '', '', 'p', 92664000, 150, 350, 500, '', 1, 1),
('永磁滚筒总成', '', '', 'p', 92664000, 150, 350, 500, '', 1, 1),

('除尘直管道', 'ф150', '', 'p', 6768000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф200', '', 'p', 6768000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф250', '', 'p', 6768000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф300', '', 'p', 6408000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф400', '', 'p', 7488000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф500', '', 'p', 7488000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф600', '', 'p', 7848000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф700', '', 'p', 7848000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф800', '', 'p', 8208000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф1100', '', 'p', 9612000, 250, 650, 100, '', 1, 1),
('除尘直管道', 'ф1300', '', 'p', 11052000, 250, 650, 100, '', 1, 1),

('除尘弯管道', 'ф200', '', 'p', 11052000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф250', '', 'p', 11052000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф300', '', 'p', 11412000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф400', '', 'p', 14256000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф500', '', 'p', 27072000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф600', '', 'p', 29592000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф700', '', 'p', 32076000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф750', '', 'p', 34560000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф800', '', 'p', 37080000, 150, 750, 100, '', 1, 1),
('除尘弯管道', 'ф1100', '', 'p', 45252000, 250, 650, 100, '', 1, 1),
('除尘弯管道', 'ф1300', '', 'p', 51696000, 250, 650, 100, '', 1, 1),

('管道蝶阀', 'ф150', '', 'p', 8928000, 200, 600, 200, '', 1, 1),
('管道蝶阀', 'ф200', '', 'p', 9252000, 250, 650, 100, '', 1, 1),
('管道蝶阀', 'ф250', '', 'p', 9612000, 250, 650, 100, '', 1, 1),
('管道蝶阀', 'ф300', '', 'p', 9612000, 200, 600, 200, '', 1, 1),
('管道蝶阀', 'ф400', '', 'p', 10332000, 250, 650, 100, '', 1, 1),
('管道蝶阀', 'ф500', '', 'p', 11052000, 250, 650, 100, '', 1, 1),
('管道蝶阀', 'ф600', '', 'p', 12132000, 250, 650, 100, '', 1, 1),
('管道蝶阀', 'ф700', '', 'p', 13536000, 200, 600, 200, '', 1, 1),
('管道蝶阀', 'ф800', '', 'p', 14256000, 250, 650, 100, '', 1, 1),

('除尘构件', '旋风除尘', '', 'p', 108720000, 250, 600, 150, '', 1, 1),
('除尘构件', '板式除尘', '', 'p', 102600000, 250, 500, 250, '', 1, 1),
('除尘构件', '分室反吹', '', 'p', 128304000, 150, 500, 350, '', 1, 1),
('法兰', 'φ500-600', '', 'p', 3924000, 100, 700, 200, '', 1, 1),
('法兰', 'φ700-800', '', 'p', 5364000, 100, 700, 200, '', 1, 1),
('法兰', 'φ900-1000', '', 'p', 6408000, 100, 700, 200, '', 1, 1),
('法兰', 'φ1000以上', '', 'p', 7848000, 100, 700, 200, '', 1, 1),

('将军帽', 'φ500', '', 'p', 5364000, 150, 850, 0, '', 1, 1),
('将军帽', 'φ600', '', 'p', 5364000, 250, 750, 0, '', 1, 1),
('将军帽', 'φ800', '', 'p', 7488000, 250, 750, 0, '', 1, 1),
('将军帽', 'φ1000', '', 'p', 10332000, 150, 850, 0, '', 1, 1),
('将军帽', 'φ1200', '', 'p', 12816000, 250, 750, 0, '', 1, 1),
('三通', '', '', 'p', 8568000, 250, 750, 0, '', 1, 1),
('变径三通', '', '', 'p', 18180000, 250, 750, 0, '', 1, 1),
('锥形管', '', '', 'p', 8568000, 250, 750, 0, '', 1, 1),

('除尘器进出风管', '80-100', '', 'p', 106920000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '120-150', '', 'p', 142560000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '180-200', '', 'p', 171072000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '220-250', '', 'p', 206712000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '280-300', '', 'p', 238788000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '350-400', '', 'p', 263736000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '450-500', '', 'p', 359964000, 150, 750, 100, '', 1, 1),
('除尘器进出风管', '550-600', '', 'p', 392040000, 150, 750, 100, '', 1, 1),

('风机总成', 'NO.6C', '', 'p', 39204000, 150, 400, 450, '', 1, 1),
('风机总成', 'NO.8C', '', 'p', 39916800, 150, 400, 450, '', 1, 1),
('风机总成', 'NO.10C', '', 'p', 49896000, 150, 400, 450, '', 1, 1),
('风机总成', 'NO.12C', '', 'p', 59868000, 150, 400, 450, '', 1, 1),

('机动辊道', '', '', 'p', 91944000, 300, 500, 200, '', 1, 1),
('从动辊道', '', '', 'p', 82332000, 300, 500, 200, '', 1, 1),
('天圆地方1', '', '', 'p', 10332000, 150, 650, 150, '', 1, 1),
('天圆地方2', '', '', 'p', 12816000, 200, 650, 150, '', 1, 1),
('溜丸管', '', '', 'p', 3924000, 200, 700, 100, '', 1, 1),
('下部集料箱', '', '', 'p', 30828600, 200, 700, 100, '', 1, 1),

('平台', '', '', 'g', 72000, 175, 650, 175, '', 1, 1),
('立柱及支架', '', '', 'g', 46800, 190, 400, 410, '', 1, 1),
('辊道架', '', '', 'g', 57600, 175, 500, 325, '', 1, 1),
('溜丸斗吸风罩', '', '', 'g', 64800, 175, 650, 325, '', 1, 1),
('副室体', '', '', 'g', 75600, 175, 400, 425, '', 1, 1),
('机动对开门', '', '', 'g', 129600, 175, 415, 410, '', 1, 1),
('主抛室吊钩', '', '', 'g', 122400, 240, 600, 160, '', 1, 1),
('主抛室悬链', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('主抛室钢管', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('主抛室方坯', '', '', 'g', 154800, 240, 600, 160, '', 1, 1),
('主抛室圆钢', '', '', 'g', 154800, 250, 600, 150, '', 1, 1),
('惯性除尘器', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('格删', '', '', 'g', 154800, 260, 740, 0, '', 1, 1),
('梯子', '', '', 'g', 194400, 250, 650, 100, '', 1, 1),
('栏杆', '', '', 'g', 259200, 250, 600, 150, '', 1, 1),
('室体护板', '', '', 'g', 190800, 200, 0, 800, '', 1, 1),
('移动小车', '', '', 'g', 100800, 175, 400, 425, '', 1, 1),
('翻管移动车', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('台车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('沉降风口', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('钢管传送线', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('圆方钢上下料台架', '', '', 'g', 115200, 250, 450, 300, '', 1, 1),
('喷丸系统', '', '', 'g', 169200, 200, 400, 400, '', 1, 1),
('水冷房', '', '', 'g', 154800, 200, 600, 200, '', 1, 1),
('自动敷线装置', '', '', 'g', 133200, 200, 500, 300, '翻', 1, 1),
('旋转支撑支架', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('液压摇臂左右挡管器', '', '', 'g', 115200, 250, 370, 380, '', 1, 1),
('自转台车', '', '', 'g', 234000, 200, 400, 400, '', 1, 1),
('溜丸斗', '', '', 'g', 126000, 240, 600, 160, '', 1, 1),
('储丸斗', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('涂覆传输线', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('破碎机', '', '', 'g', 126000, 150, 450, 400, '', 1, 1),
('水管路', '', '', 'g', 259200, 200, 600, 200, '', 1, 1),
('隔音房', '', '', 'g', 154800, 200, 400, 400, '', 1, 1),
('振动输送机', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('顶部密封', '', '', 'g', 154800, 240, 600, 160, '', 1, 1),
('喷涂系统', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('喷涂房', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('密封装置', '', '', 'g', 75600, 175, 650, 325, '', 1, 1),
('检测支架', '', '', 'g', 1800000, 200, 700, 100, '', 1, 1),
('管端切割机', '', '', 'g', 144000, 200, 650, 650, '', 1, 1),
('加料机', '', '', 'g', 126000, 190, 400, 410, '', 1, 1),
('水冷房', '', '', 'g', 154800, 200, 600, 200, '', 1, 1),
('水管路', '', '', 'g', 259200, 250, 600, 150, '', 1, 1),
('板链输送', '', '', 'g', 129600, 200, 250, 550, '', 1, 1),
('履带驱动系统', '', '', 'g', 154800, 150, 150, 700, '', 1, 1),
('喷丸改动车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('喷丸机内壁喷杆', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('弹丸自动补充装置', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('除锈传送线', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('下部集料箱', '', '', 'g', 205200, 250, 550, 200, '', 1, 1),
('缠绕机', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('V形辊道', '', '', 'g', 129600, 185, 400, 425, '', 1, 1),
('抛丸器总成', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('皮带输送机', '', '', 'g', 129600, 200, 600, 400, '', 1, 1),
('滚筒筛', '', '', 'g', 144000, 250, 800, 0, '', 1, 1),
('磨削机磨头', '', '', 'g', 129600, 185, 215, 600, '', 1, 1),
('输入辊道', '', '', 'g', 115200, 175, 400, 425, '', 1, 1),
('移动辊道', '', '', 'g', 115200, 175, 400, 425, '', 1, 1),
('固定支撑（内吹）', '', '', 'g', 115200, 175, 400, 425, '', 1, 1),
('随动小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('吹尘小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('集灰小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('弹丸收集斗', '', '', 'g', 169200, 270, 600, 130, '', 1, 1),
('喷丸移动车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('电动回平车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('从动支撑车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('升降旋转辊', '', '', 'g', 1980000, 250, 500, 250, '', 1, 1),
('固定旋转辊', '', '', 'g', 1980000, 250, 500, 250, '', 1, 1),
('喷粉房', '', '', 'g', 1980000, 250, 500, 250, '不锈钢', 1, 1),
('钢管内壁惯性除尘器', '', '', 'g', 104400, 200, 600, 200, '', 1, 1),
('旋转喷涂车', '', '', 'g', 144000, 250, 400, 350, '', 1, 1),
('液压移动车', '', '', 'g', 133200, 175, 520, 425, '', 1, 1),
('运管小车', '', '', 'g', 133200, 175, 400, 425, '', 1, 1),
('在线切割机', '', '', 'g', 154800, 200, 800, 668, '', 1, 1),
('安全挡板', '', '', 'g', 129600, 200, 800, 400, '', 1, 1),
('防撞块', '', '', 'g', 129600, 200, 800, 400, '', 1, 1),
('室体辊道', '', '', 'g', 154800, 260, 600, 140, '', 1, 1),
('底座', '', '', 'g', 72000, 175, 650, 175, '', 1, 1),
('定位机构', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('磨头机构', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('管端打磨机', '', '', 'g', 133200, 200, 400, 400, '', 1, 1),
('振动输送机', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('拨轮装置', '', '', 'g', 154800, 200, 200, 600, '', 1, 1),
('电机支架', '', '', 'g', 115200, 250, 370, 380, '', 1, 1),
('集尘小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('旋转喷涂车基础架体', '', '', 'g', 86400, 220, 590, 190, '', 1, 1),
('喷枪系统', '', '', 'g', 144000, 200, 400, 400, '', 1, 1),
('摆床', '', '', 'g', 154800, 250, 600, 150, '', 1, 1),
('加卸料机构1', '', '', 'g', 154800, 200, 300, 500, '', 1, 1),
('加卸料装置', '', '', 'g', 46800, 190, 400, 410, '', 1, 1),
('表面修磨机', '', '', 'g', 144000, 200, 650, 650, '', 1, 1),
('侧挡管器', '', '', 'g', 129600, 200, 400, 400, '', 1, 1),
('辊道输送线', '', '', 'g', 129600, 185, 400, 415, '', 1, 1),
('翻转机', '', '', 'g', 129600, 185, 400, 415, '', 1, 1),
('翻转倒丸机构', '', '', 'g', 194400, 185, 400, 415, '', 1, 1),
('管端旋转辊', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('机架', '', '', 'g', 57600, 200, 400, 400, '', 1, 1),
('上下钳口总成', '', '', 'g', 190800, 400, 600, 0, '', 1, 1),
('喷涂传送线', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('气动摇臂', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('气动挡管器', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('气动推管器', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('机动辊道', '', '', 'g', 129600, 185, 400, 415, '', 1, 1),
('压辊装置', '', '', 'g', 115200, 190, 400, 820, '', 1, 1),
('液压运管车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('机器人底座', '', '', 'g', 72000, 175, 650, 175, '', 1, 1),
('废料斗', '', '', 'g', 169200, 240, 600, 160, '', 1, 1);

('V型辊道', '', '', 'g', 129600, 185, 400, 425, '', 1, 1),
('八工位步进梁', '', '', 'g', 180000, 200, 300, 500, '', 1, 1),
('板料输送', '', '', 'g', 129600, 200, 250, 550, '', 1, 1),
('表面修磨机', '', '', 'g', 144000, 200, 650, 650, '', 1, 1),
('拨轮装置', '', '', 'g', 154800, 200, 200, 600, '', 1, 1),
('沉降风口', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('承载支架', '', '', 'g', 46800, 190, 400, 410, '', 1, 1),
('弹丸收集斗', '', '', 'g', 169200, 270, 600, 130, '', 1, 1),
('弹丸自动补充装置', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('底座', '', '', 'g', 72000, 175, 650, 175, '', 1, 1),
('定位机构 磨头机构', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('翻板装置', '', '', 'g', 162000, 200, 400, 400, '', 1, 1),
('翻管移动车', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('防撞块', '', '', 'g', 129600, 200, 400, 400, '', 1, 1),
('废料斗', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('副室门', '', '', 'g', 75600, 175, 400, 425, '', 1, 1),
('钢管传送线', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('钢管内壁惯性除尘器', '', '', 'g', 104400, 20, 60, 20, '', 1, 1),
('钢管移动车', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('格栅', '', '', 'g', 154800, 260, 740, 0, '', 1, 1),
('隔音房', '', '', 'g', 154800, 200, 400, 400, '', 1, 1),
('工位布管机', '', '', 'g', 180000, 200, 300, 500, '', 1, 1),
('工位布料机', '', '', 'g', 180000, 200, 300, 500, '', 1, 1),
('固定支撑（内吹）', '', '', 'g', 115200, 175, 400, 425, '', 1, 1),
('惯性除尘器', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('辊道架', '', '', 'g', 57600, 175, 500, 325, '', 1, 1),
('辊道输送线', '', '', 'g', 129600, 185, 400, 415, '', 1, 1),
('机动对开门', '', '', 'g', 129600, 175, 415, 410, '', 1, 1),
('机动辊道', '', '', 'g', 169200, 185, 420, 400, '', 1, 1),
('机动门.密封门', '', '', 'g', 129600, 175, 415, 410, '', 1, 1),
('机架', '', '', 'g', 57600, 200, 400, 400, '', 1, 1),
('机器人底座', '', '', 'g', 72000, 175, 650, 175, '', 1, 1),
('机械手上下钳口总成', '', '', 'g', 190800, 400, 600, 0, '', 1, 1),
('机械手总成', '', '', 'g', 255600, 150, 250, 600, '', 1, 1),
('基础架体', '', '', 'g', 108000, 220, 590, 190, '', 1, 1),
('集尘小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('加料机', '', '', 'g', 126000, 190, 400, 410, '', 1, 1),
('加卸料装置', '', '', 'g', 46800, 190, 400, 410, '', 1, 1),
('检测支架', '', '', 'g', 180000, 200, 700, 100, '', 1, 1),
('栏杆', '', '', 'g', 259200, 250, 600, 150, '', 1, 1),
('立柱支架支撑', '', '', 'g', 72000, 190, 400, 410, '', 1, 1),
('溜丸斗', '', '', 'g', 126000, 240, 600, 160, '', 1, 1),
('溜丸斗吸风罩', '', '', 'g', 64800, 185, 650, 325, '', 1, 1),
('履带驱动系统', '', '', 'g', 154800, 150, 150, 700, '', 1, 1),
('密封装置', '', '', 'g', 75600, 175, 650, 325, '', 1, 1),
('磨削机', '', '', 'g', 129600, 185, 215, 600, '', 1, 1),
('磨头', '', '', 'g', 129600, 185, 215, 600, '', 1, 1),
('末端挡料', '', '', 'g', 72000, 175, 550, 325, '', 1, 1),
('内壁抛丸机', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('储料斗', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('储丸斗', '', '', 'g', 169200, 240, 600, 160, '', 1, 1),
('碾环抛丸机导向装置', '', '', 'g', 115200, 250, 370, 380, '', 1, 1),
('抛丸器总成', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('抛丸室中间密封层', '', '', 'g', 154800, 240, 600, 160, '', 1, 1),
('抛丸室顶部密封', '', '', 'g', 154800, 240, 600, 160, '', 1, 1),
('喷粉房（不锈钢）', '', '', 'g', 198000, 250, 500, 250, '', 1, 1),
('喷杆系统', '', '', 'g', 100800, 200, 400, 400, '', 1, 1),
('喷枪系统', '', '', 'g', 144000, 200, 400, 400, '', 1, 1),
('喷涂系统', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('间歇式喷涂房', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('连续喷涂房', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('喷丸改动车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('喷丸机内壁喷杆', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('喷丸移动车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('电动回平车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('从动支撑车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('移动小车', '', '', 'g', 100800, 185, 400, 415, '', 1, 1),
('皮带输送机', '', '', 'g', 129600, 200, 600, 400, '', 1, 1),
('平板输送车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('平台', '', '', 'g', 108000, 175, 650, 175, '', 1, 1),
('破碎机', '', '', 'g', 126000, 150, 450, 400, '', 1, 1),
('气动挡料装置', '', '', 'g', 190800, 200, 500, 800, '', 1, 1),
('清扫室总成', '', '', 'g', 189000, 170, 370, 460, '', 1, 1),
('上.下料辊道', '', '', 'g', 115200, 250, 370, 380, '', 1, 1),
('升降旋转辊', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('固定旋转辊', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('升降移动传送线', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('室体', '', '', 'g', 154800, 250, 600, 1150, '', 1, 1),
('室体护板', '', '', 'g', 190800, 200, 600, 800, '', 1, 1),
('水管路', '', '', 'g', 259200, 250, 600, 150, '', 1, 1),
('随动支撑小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('吹尘小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('集灰小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('行走小车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('台车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('随动支撑小车轮', 'δ<120mm', '', 'p', 1800000, 1000, 0, 0, '', 1, 1),
('吹尘小车轮', '', 'δ<120mm', 'p', 1800000, 175, 0, 0, '', 1, 1),
('集灰小车轮', '', 'δ<120mm', 'p', 1800000, 175, 0, 0, '', 1, 1),
('行走小车轮', '', 'δ<120mm', 'p', 1800000, 175, 0, 0, '', 1, 1),
('台车轮', '', 'δ<120mm', 'p', 1800000, 175, 0, 0, '', 1, 1),
('台架系统', '', '', 'g', 115200, 250, 450, 300, '', 1, 1),
('梯子', '', '', 'g', 194400, 250, 650, 100, '', 1, 1),
('五工位布料机', '', '', 'g', 180000, 200, 300, 500, '', 1, 1),
('下部集料箱', '', '', 'g', 205200, 250, 550, 200, '', 1, 1),
('旋转门', '', '', 'g', 288000, 200, 400, 400, '', 1, 1),
('旋转喷涂车基础架体', '', '', 'g', 86400, 300, 590, 190, '', 1, 1),
('旋转支撑', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('液压摇臂', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('液压摇臂左右挡管器', '', '', 'g', 115200, 250, 370, 380, '', 1, 1),
('液压运管车', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('移动小车', '', '', 'g', 100800, 175, 400, 425, '', 1, 1),
('圆方钢上下料台架', '', '', 'g', 115200, 250, 370, 380, '', 1, 1),
('振动输送机', '', '', 'g', 144000, 200, 600, 200, '', 1, 1),
('整体运管车', '', '', 'g', 133200, 175, 400, 425, '', 1, 1),
('主抛室吊钩', '', '', 'g', 122400, 240, 600, 160, '', 1, 1),
('主抛室方坯', '', '', 'g', 154800, 240, 600, 160, '', 1, 1),
('主抛室悬链', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('主抛室钢管', '', '', 'g', 129600, 240, 600, 160, '', 1, 1),
('主抛室圆钢', '', '', 'g', 154800, 250, 600, 150, '', 1, 1),
('自动敷线装置', '', '', 'g', 133200, 200, 500, 300, '', 1, 1),


('水冷房', '', '', 'g', 154800, 200, 600, 200, '', 1, 1),
('水冷房吹风装置', '', '', 'g', 57600000, 250, 750, 0, '', 1, 1),

('除锈传送线', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('除锈传送线定位销', '', '', 'p', 2592000, 0, 0, 1000, '', 1, 1),
('涂覆传送线', '', '', 'g', 126000, 175, 400, 425, '', 1, 1),
('涂覆传送线定位销', '', '', 'p', 2592000, 0, 0, 1000, '', 1, 1),

('滚筒筛', '2000mm以下', '', 'g', 144000, 200, 800, 0, '', 1, 1),
('滚筒筛', '2000mm以上', '', 'g', 288000, 200, 800, 0, '', 1, 1),

('吊钩抛丸机', '', '', 'g', 122400, 240, 600, 160, '', 1, 1),
('吊钩抛丸室底座', '', '', 'g', 122400, 240, 600, 160, '', 1, 1),

('防撞块有橡胶板', '', '', 'g', 129600, 200, 400, 400, '', 1, 1),
('防撞块无橡胶板', '', '', 'g', 77760, 333, 667, 0, '', 1, 1),
('安全挡板有橡胶板', '', '', 'g', 129600, 200, 400, 400, '', 1, 1),
('安全挡板无橡胶板', '', '', 'g', 77760, 333, 667, 0, '', 1, 1),
('侧挡管器有橡胶板', '', '', 'g', 129600, 200, 400, 400, '', 1, 1),
('侧挡管器无橡胶板', '', '', 'g', 77760, 333, 667, 0, '', 1, 1),

('加卸料机构', '', '', 'g', 210600, 147, 221, 632, '', 1, 1),
('翻转机', '', '', 'g', 140616, 170, 369, 461, '', 1, 1),
('翻转倒丸机构', '', '', 'g', 173016, 138, 300, 562, '', 1, 1),
('工件自转装置', '', '', 'g', 228960, 166, 417, 417, '', 1, 1),
('电动平车', '', '', 'g', 155520, 167, 583, 250, '', 1, 1),
('在线切割机', 'G<2000kg', '', 'g', 258206, 120, 480, 400, '', 1, 1),
('在线切割机', 'G>2000kg', '', 'g', 297216, 104, 417, 479, '', 1, 1),
('管端打磨机', '', '', 'g', 194400, 134, 433, 433, '', 1, 1),
('自转台车', '', '', 'g', 234000, 200, 400, 400, '', 1, 1),
('自转台车耐磨板', '', '', 'g', 305280, 125, 375, 500, '', 1, 1),
('管端打磨机', '', '', 'g', 305280, 125, 375, 500, '', 1, 1),
('盘圆旋转门', '', '', 'g', 198000, 250, 600, 150, '', 1, 1),
('盘圆旋转门聚氨酯密封条', '', '', 'p', 57600000, 0, 0, 1000, '', 1, 1),

('重锤卸灰阀', '', '', 'p', 14400000, 250, 500, 250, '', 1, 1),
('皮带机总成', '', '', 'p', 2232000, 161, 436, 403, '', 1, 1),
('气控系统', '', '', 'p', 15660000, 83, 83, 834, '', 1, 1),
('抛丸器罩壳', '', '', 'p', 43920000, 131, 0, 869, '', 1, 1),
('矫直机', '', '', 'p', 36000000, 200, 300, 500, '', 1, 1),
('精过滤器', '', '', 'p', 178920000, 163, 565, 272, '', 1, 1),
('液压泵站', '', '', 'p', 207000000, 122, 313, 565, '', 1, 1),
('除尘器消防装置', '', '', 'p', 45000000, 120, 80, 800, '', 1, 1),
('车轮吹扫装置', '', '', 'p', 15660000, 83, 83, 834, '', 1, 1),
('吊钩机构横撑', '', '', 'p', 21384000, 150, 350, 500, '', 1, 1),
('皮带轮', '', '', 'p', 11880000, 333, 546, 121, '', 1, 1),
('悬链弯轨', '', '', 'p', 81972000, 150, 650, 200, '', 1, 1),
('驱动装置', '', '', 'p', 99792000, 150, 500, 350, '', 1, 1),
('涨紧装置', '', '', 'p', 85536000, 150, 500, 350, '', 1, 1),
('光轮回转', '', '', 'p', 32076000, 150, 600, 250, '', 1, 1),
('自转装置', '', '', 'p', 64152000, 200, 200, 600, '', 1, 1),
('悬链道岔', '', '', 'p', 46332000, 150, 700, 150, '', 1, 1),
('止推器', '', '', 'p', 3564000, 150, 700, 150, '', 1, 1),
('停止器', '', '', 'p', 7128000, 200, 400, 400, '', 1, 1),
('机动开门', '', '', 'p', 117612000, 150, 400, 450, '', 1, 1),
('吊钩', '', '', 'p', 14256000, 50, 0, 950, '', 1, 1),
('横撑吊钩', '', '', 'p', 21384000, 150, 350, 500, '', 1, 1),
('顶部密封1', '', '', 'p', 7128000, 100, 200, 700, '', 1, 1),
('顶防护门', '', '', 'p', 24948000, 200, 500, 300, '', 1, 1),
('吊钩扇形门', '', '', 'p', 103356000, 150, 500, 350, '', 1, 1),
('换轨装置', '', '', 'p', 39204000, 150, 450, 400, '', 1, 1),
('小磁选分离器', '', '', 'p', 92664000, 150, 350, 500, '', 1, 1),
('三通', '', '', 'p', 8568000, 250, 750, 0, '', 1, 1),
('变径三通', '', '', 'p', 18180000, 250, 750, 0, '', 1, 1),
('锥形管', '', '', 'p', 8568000, 250, 750, 0, '', 1, 1),
('机动辊道', '', '', 'p', 91944000, 300, 500, 200, '', 1, 1),
('从动辊道', '', '', 'p', 82332000, 300, 500, 200, '', 1, 1),
('溜丸管', '', '', 'p', 3924000, 200, 700, 100, '', 1, 1),
('卸灰阀', '', '', 'p', 14400000, 250, 500, 250, '', 1, 1),
('扁布袋除尘器', '', '', 'p', 3096360000, 140, 606, 254, '', 1, 1),
('横撑吊钩机构', '', '', 'p', 21384000, 150, 350, 500, '', 1, 1),
('提升机皮带轮', '', '', 'p', 11880000, 333, 546, 121, '', 1, 1),
('加卸料机构', '', '', 'p', 27000000, 200, 267, 533, '', 1, 1),

('单旋风除尘器', 'Φ1000', '', 'p', 129888000, 209, 665, 126, '含支架', 1, 1),
('双旋风除尘器', 'Φ1000', '', 'p', 259776000, 209, 665, 126, '含支架', 1, 1),
('单旋风除尘器', 'Φ1200', '', 'p', 151488000, 179, 713, 108, '含支架', 1, 1),
('双旋风除尘器', 'Φ1200', '', 'p', 302976000, 179, 713, 108, '含支架', 1, 1),
('单旋风除尘器', 'Φ1600', '', 'p', 194688000, 140, 777, 83, '含支架', 1, 1),
('双旋风除尘器', 'Φ1600', '', 'p', 389376000, 140, 777, 83, '含支架', 1, 1),

('皮带总成', '', '', 'p', 2340000, 200, 415, 385, '', 1, 1),
('悬链直轨', '', '', 'mm', 3564, 404, 606, 0, '', 1, 1),
('内抛回沙皮带机', '', '', 'p', 56880000, 146, 436, 418, '1节', 1, 1),
('提升机皮带总成', '', '', 'p', 2340000, 200, 415, 385, '1件', 1, 1),
('提升机料斗', '', '', 'p', 2340000, 200, 415, 385, '1件', 1, 1),
('气动锤头', '', '', 'p', 30600000, 59, 0, 941, '', 1, 1),
('袋式除尘器', '240', '', 'p', 1441404000, 140, 608, 252, '', 1, 1),
('扁布袋', '334', '', 'p', 1814760000, 138, 622, 240, '', 1, 1),
('滤筒吊杆', '', '', 'p', 2592000, 250, 750, 0, '', 1, 1),
('加卸料机构', '', '', 'p', 27000000, 200, 267, 533, '', 1, 1),

('除锈线不锈钢防水罩', '', '', 'p', 2520000, 0, 1000, 0, '', 1, 1),
('圆方钢室体辊道', '', '', 'p', 28800000, 0, 0, 1000, '', 1, 1),
('弹丸控制系统', '', '', 'p', 3960000, 200, 700, 100, '1件溜丸管含支架', 1, 1),
('滤筒支架', '', '', 'p', 2592000, 250, 750, 0, '', 1, 1),
('滤筒吊杆', '', '', 'p', 2592000, 250, 750, 0, '', 1, 1),
('橡胶帘', '', '', 'p', 3240000, 0, 0, 1000, '1套', 1, 1),
('缠绕机', '', '', 'g', 129600, 175, 400, 425, '', 1, 1),
('小抛头', '', '', 'p', 177840000, 61, 0, 939, '', 1, 1),
('大抛头', '', '', 'p', 200880000, 104, 0, 896, '', 1, 1),
('抛丸清理机输入辊道', '', '', 'g', 115200, 250, 370, 380, '按台架计算', 1, 1),
('抛丸清理机移动辊道', '', '', 'g', 115200, 250, 370, 380, '按台架计算', 1, 1),
('旋转喷涂车', '', '', 'g', 144000, 250, 400, 350, '装配加外购重量', 1, 1),
('液压移动车', '', '', 'g', 149184, 156, 464, 380, '装配加外购重量', 1, 1),
('运管小车', '', '', 'g', 133200, 175, 400, 425, '装配加外购重量', 1, 1),
('喷丸小车', '', '', 'g', 133200, 175, 400, 425, '装配加外购重量', 1, 1),
('旋转体总成', '无护板', '', 'g', 154800, 200, 400, 400, '按室体计算', 1, 1),
('旋转体总成', '有护板', '', 'g', 154800, 250, 600, 150, '按室体计算', 1, 1),
('旋转体总成护板', '', '', 'g', 305280, 125, 375, 500, '', 1, 1),
('液压系统', '', '', 'g', 599998, 1000, 0, 0, '下料切1口', 1, 1),
('液压系统', '', '', 'g', 900000, 0, 1000, 0, '焊接弯1弯', 1, 1),
('液压系统', '', '', 'g', 1200000, 0, 1000, 0, '焊接焊1口', 1, 1),
('液压系统', '', '', 'g', 120000, 0, 0, 1000, '装配接1口', 1, 1),
('光杆吊钩', '', '', 'p', 5400000, 333, 667, 0, '装配接1口', 1, 1),
('中频升降架', '', '', 'p', 194400, 250, 650, 100, '除梯子平台栏杆立柱及支撑', 1, 1),
('缠绕传送线', '', '', 'p', 126000, 175, 400, 425, '', 1, 1),
('缠绕传送线销轴', '', '', 'p', 2592000, 0, 0, 1000, '1件', 1, 1),
('旋转支撑装置', '小', '', 'p', 54000000, 133, 200, 667, '', 1, 1),
('旋转支撑装置', '大', '', 'p', 64800000, 111, 222, 667, '', 1, 1),
('天圆地方', 'L>1100mm', '', 'p', 25200000, 143, 786, 71, '', 1, 1),
('天圆地方', 'L<1100mm', '', 'p', 19800000, 182, 727, 91, '', 1, 1),
('永磁滚筒总成', 'L<1100mm', '', 'p', 78264000, 178, 230, 592, '', 1, 1),


SET FOREIGN_KEY_CHECKS = 1;   -- 重新开启外键约束检查