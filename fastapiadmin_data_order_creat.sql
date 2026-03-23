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
  KEY `ix_data_project_status` (`status`),
  KEY `ix_data_project_created_time` (`created_time`),
  KEY `ix_data_project_updated_time` (`updated_time`),
  KEY `ix_data_project_created_id` (`created_id`),
  KEY `ix_data_project_updated_id` (`updated_id`),
  CONSTRAINT `fk_data_project_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_data_project_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目信息表';


CREATE TABLE `data_bom` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_code` varchar(64) NOT NULL COMMENT '父代号',
  `code` varchar(64) DEFAULT NULL COMMENT '代号',
  `spec` varchar(255) NOT NULL COMMENT '名称',
  `count` int NOT NULL COMMENT '数量',
  `material` varchar(255) DEFAULT NULL COMMENT '材质',
  `unit_mass` float DEFAULT NULL COMMENT '单重',
  `total_mass` float DEFAULT NULL COMMENT '总重',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  
  `uuid` varchar(64) NOT NULL DEFAULT (UUID()) COMMENT 'UUID',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text NULL COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int NULL COMMENT '创建人ID',
  `updated_id` int NULL COMMENT '更新人ID',

  PRIMARY KEY (`id`),
  -- 优化：索引名匹配完整表名 data_bom
  KEY `ix_data_bom_parent_code` (`parent_code`),  
  -- 修正：外键别名+关联表名，匹配 data_bom + data_project
  CONSTRAINT `data_bom_ibfk_1` 
  FOREIGN KEY (`parent_code`) REFERENCES `data_project` (`code`)
  ON DELETE NO ACTION  -- 删除data_project时，data_bom记录不变
  ON UPDATE CASCADE    -- 更新data_project.code时，data_bom.parent_code同步更新
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='BOM清单';


CREATE TABLE `produce_order` (
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
  KEY `ix_data_project_status` (`status`),
  KEY `ix_data_project_created_time` (`created_time`),
  KEY `ix_data_project_updated_time` (`updated_time`),
  KEY `ix_data_project_created_id` (`created_id`),
  KEY `ix_data_project_updated_id` (`updated_id`),
  CONSTRAINT `fk_data_project_created_id` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_data_project_updated_id` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目信息表';


CREATE TABLE `produce_craft` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '工艺ID',
  `name` varchar(30) NOT NULL COMMENT '工艺名称',
  `uuid` varchar(64) NOT NULL DEFAULT (uuid()) COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`),
  UNIQUE KEY `uk_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工艺字典表';


CREATE TABLE `produce_craft_route` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '工艺路线ID',
  `route` int NOT NULL COMMENT '工艺路线',
  `sort` int NOT NULL COMMENT '排序',
  `craft_id` int NOT NULL COMMENT '工艺ID',
  `uuid` varchar(64) NOT NULL DEFAULT (uuid()) COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL DEFAULT '0' COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工艺路线表';


-- 1: 下料
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (1,1,1);

-- 2: 下料 → 机加
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (2,1,1),(2,2,2);

-- 3: 下料 → 机加 → 铆焊
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (3,1,1),(3,2,2),(3,3,3);

-- 4: 下料 → 机加 → 铆焊 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (4,1,1),(4,2,2),(4,3,3),(4,4,4);

-- 5: 下料 → 机加 → 铆焊 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (5,1,1),(5,2,2),(5,3,3),(5,4,4),(5,5,5);

-- 6: 下料 → 机加 → 铆焊 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (6,1,1),(6,2,2),(6,3,3),(6,4,5);

-- 7: 下料 → 机加 → 铆焊 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (7,1,1),(7,2,2),(7,3,3),(7,4,5),(7,5,4);

-- 8: 下料 → 机加 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (8,1,1),(8,2,2),(8,3,4);

-- 9: 下料 → 机加 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (9,1,1),(9,2,2),(9,3,4),(9,4,5);

-- 10: 下料 → 机加 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (10,1,1),(10,2,2),(10,3,5);

-- 11: 下料 → 机加 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (11,1,1),(11,2,2),(11,3,5),(11,4,4);

-- 12: 下料 → 铆焊
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (12,1,1),(12,2,3);

-- 13: 下料 → 铆焊 → 机加
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (13,1,1),(13,2,3),(13,3,2);

-- 14: 下料 → 铆焊 → 机加 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (14,1,1),(14,2,3),(14,3,2),(14,4,4);

-- 15: 下料 → 铆焊 → 机加 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (15,1,1),(15,2,3),(15,3,2),(15,4,4),(15,5,5);

-- 16: 下料 → 铆焊 → 机加 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (16,1,1),(16,2,3),(16,3,2),(16,4,5);

-- 17: 下料 → 铆焊 → 机加 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (17,1,1),(17,2,3),(17,3,2),(17,4,5),(17,5,4);

-- 18: 下料 → 铆焊 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (18,1,1),(18,2,3),(18,3,4);

-- 19: 下料 → 铆焊 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (19,1,1),(19,2,3),(19,3,4),(19,4,5);

-- 20: 下料 → 铆焊 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (20,1,1),(20,2,3),(20,3,5);

-- 21: 下料 → 铆焊 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (21,1,1),(21,2,3),(21,3,5),(21,4,4);

-- 22: 下料 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (22,1,1),(22,2,4);

-- 23: 下料 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (23,1,1),(23,2,4),(23,3,5);

-- 24: 下料 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (24,1,1),(24,2,5);

-- 25: 下料 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (25,1,1),(25,2,5),(25,3,4);

-- 26: 机加
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (26,1,2);

-- 27: 机加 → 铆焊
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (27,1,2),(27,2,3);

-- 28: 机加 → 铆焊 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (28,1,2),(28,2,3),(28,3,4);

-- 29: 机加 → 铆焊 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (29,1,2),(29,2,3),(29,3,4),(29,4,5);

-- 30: 机加 → 铆焊 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (30,1,2),(30,2,3),(30,3,5);

-- 31: 机加 → 铆焊 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (31,1,2),(31,2,3),(31,3,5),(31,4,4);

-- 32: 机加 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (32,1,2),(32,2,4);

-- 33: 机加 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (33,1,2),(33,2,4),(33,3,5);

-- 34: 机加 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (34,1,2),(34,2,5);

-- 35: 机加 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (35,1,2),(35,2,5),(35,3,4);

-- 36: 铆焊
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (36,1,3);

-- 37: 铆焊 → 机加
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (37,1,3),(37,2,2);

-- 38: 铆焊 → 机加 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (38,1,3),(38,2,2),(38,3,4);

-- 39: 铆焊 → 机加 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (39,1,3),(39,2,2),(39,3,4),(39,4,5);

-- 40: 铆焊 → 机加 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (40,1,3),(40,2,2),(40,3,5);

-- 41: 铆焊 → 机加 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (41,1,3),(41,2,2),(41,3,5),(41,4,4);

-- 42: 铆焊 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (42,1,3),(42,2,4);

-- 43: 铆焊 → 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (43,1,3),(43,2,4),(43,3,5);

-- 44: 铆焊 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (44,1,3),(44,2,5);

-- 45: 铆焊 → 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (45,1,3),(45,2,5),(45,3,4);

-- 46: 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (46,1,4);

-- 47: 喷漆 → 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (47,1,4),(47,2,5);

-- 48: 装配
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (48,1,5);

-- 49: 装配 → 喷漆
INSERT INTO produce_craft_route (route, sort, craft_id) VALUES (49,1,5),(49,2,4);


-- 工艺路线图的视图创建代码
CREATE VIEW v_produce_craft_route AS
SELECT 
    pcr.route AS route_code,
    GROUP_CONCAT(pc.name ORDER BY pcr.sort SEPARATOR ' → ') AS route_name
FROM produce_craft_route pcr
LEFT JOIN produce_craft pc ON pcr.craft_id = pc.id
GROUP BY pcr.route
ORDER BY pcr.route;