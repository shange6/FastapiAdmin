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

INSERT INTO data_project (code, name, no) 
VALUES ('WGRO32JD', '2026年Q3光伏支架项目', 'WT26-01');


CREATE TABLE `data_bom` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_code` varchar(64) NOT NULL COMMENT '父代号（关联data_project.code）',
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