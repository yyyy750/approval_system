-- ============================================================
-- 审批系统数据库初始化脚本 (RBAC版本)
-- 对应文档: doc/06_数据库设计文档.md
-- 版本: 2.0.0
-- 生成时间: 2026-01-14
-- 更新内容: 引入RBAC机制，职位与权限分离
-- ============================================================

-- SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 第一部分: 表结构创建 (按依赖顺序)
-- ============================================================

-- ----------------------------
-- 1. 部门表 (sys_department)
-- 必须先创建，因为 sys_user 依赖它
-- ----------------------------
DROP TABLE IF EXISTS `sys_department`;
CREATE TABLE `sys_department` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `name` VARCHAR(100) NOT NULL COMMENT '部门名称',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父部门ID（0表示顶级部门）',
  `leader_id` BIGINT DEFAULT NULL COMMENT '部门负责人ID',
  `sort_order` INT DEFAULT 0 COMMENT '排序序号',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='部门表';

-- ----------------------------
-- 2. 用户表 (sys_user) - RBAC版本：移除role字段
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名（登录账号）',
  `password` VARCHAR(100) NOT NULL COMMENT '密码（BCrypt加密）',
  `nickname` VARCHAR(50) NOT NULL COMMENT '昵称（显示名称）',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱地址',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像文件路径',
  `department_id` BIGINT DEFAULT NULL COMMENT '所属部门ID',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `last_login_at` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_department` (`department_id`),
  CONSTRAINT `fk_user_dept` FOREIGN KEY (`department_id`) REFERENCES `sys_department` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户表';

-- ----------------------------
-- 3. 角色表 (sys_role) - RBAC核心表
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `code` VARCHAR(50) NOT NULL COMMENT '角色编码（如SUPER_ADMIN）',
  `name` VARCHAR(100) NOT NULL COMMENT '角色名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '角色描述',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `sort_order` INT DEFAULT 0 COMMENT '排序序号',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色表';

-- ----------------------------
-- 4. 权限表 (sys_permission) - RBAC核心表
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `code` VARCHAR(100) NOT NULL COMMENT '权限编码（如user:view）',
  `name` VARCHAR(100) NOT NULL COMMENT '权限名称',
  `type` VARCHAR(20) NOT NULL COMMENT '权限类型: MENU/BUTTON/API',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父权限ID（树形结构）',
  `path` VARCHAR(255) DEFAULT NULL COMMENT '路由路径/API路径',
  `icon` VARCHAR(50) DEFAULT NULL COMMENT '图标（菜单用）',
  `sort_order` INT DEFAULT 0 COMMENT '排序序号',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='权限表';

-- ----------------------------
-- 5. 用户角色关联表 (sys_user_role)
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户角色关联表';

-- ----------------------------
-- 6. 角色权限关联表 (sys_role_permission)
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `permission_id` BIGINT NOT NULL COMMENT '权限ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_perm` (`role_id`, `permission_id`),
  KEY `idx_permission_id` (`permission_id`),
  CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_perm` FOREIGN KEY (`permission_id`) REFERENCES `sys_permission` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色权限关联表';

-- ----------------------------
-- 7. 职位表 (sys_position) - 业务岗位，与系统权限分离
-- ----------------------------
DROP TABLE IF EXISTS `sys_position`;
CREATE TABLE `sys_position` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '职位ID',
  `code` VARCHAR(50) NOT NULL COMMENT '职位编码（如DEPT_MANAGER）',
  `name` VARCHAR(100) NOT NULL COMMENT '职位名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '职位描述',
  `level` INT DEFAULT 0 COMMENT '职级（用于审批层级）',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `sort_order` INT DEFAULT 0 COMMENT '排序序号',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='职位表';

-- ----------------------------
-- 8. 用户职位关联表 (sys_user_position)
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_position`;
CREATE TABLE `sys_user_position` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `position_id` BIGINT NOT NULL COMMENT '职位ID',
  `is_primary` TINYINT DEFAULT 0 COMMENT '是否主职位: 0-否 1-是',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_position` (`user_id`, `position_id`),
  KEY `idx_position_id` (`position_id`),
  CONSTRAINT `fk_up_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_up_position` FOREIGN KEY (`position_id`) REFERENCES `sys_position` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户职位关联表';

-- ----------------------------
-- 9. 审批类型表 (approval_type)
-- ----------------------------
DROP TABLE IF EXISTS `approval_type`;
CREATE TABLE `approval_type` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '类型ID',
  `code` VARCHAR(50) NOT NULL COMMENT '类型编码（如LEAVE/EXPENSE）',
  `name` VARCHAR(100) NOT NULL COMMENT '类型名称',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '类型描述',
  `icon` VARCHAR(50) DEFAULT NULL COMMENT '图标名称',
  `color` VARCHAR(20) DEFAULT NULL COMMENT '主题颜色',
  `sort_order` INT DEFAULT 0 COMMENT '排序序号',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='审批类型表';

-- ----------------------------
-- 10. 工作流模板表 (workflow_template)
-- ----------------------------
DROP TABLE IF EXISTS `workflow_template`;
CREATE TABLE `workflow_template` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` VARCHAR(100) NOT NULL COMMENT '模板名称',
  `type_code` VARCHAR(50) NOT NULL COMMENT '关联审批类型编码',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '模板描述',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `created_by` BIGINT NOT NULL COMMENT '创建人ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_type_code` (`type_code`),
  KEY `idx_status` (`status`),
  KEY `fk_workflow_creator` (`created_by`),
  CONSTRAINT `fk_tpl_creator` FOREIGN KEY (`created_by`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_tpl_type` FOREIGN KEY (`type_code`) REFERENCES `approval_type` (`code`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='工作流模板表';

-- ----------------------------
-- 11. 工作流节点模板表 (workflow_node_template)
-- approver_type 支持: USER/POSITION/DEPARTMENT_HEAD
-- ----------------------------
DROP TABLE IF EXISTS `workflow_node_template`;
CREATE TABLE `workflow_node_template` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '节点模板ID',
  `workflow_id` BIGINT NOT NULL COMMENT '工作流模板ID',
  `node_name` VARCHAR(100) NOT NULL COMMENT '节点名称',
  `node_order` INT NOT NULL COMMENT '节点顺序',
  `approver_type` VARCHAR(20) NOT NULL COMMENT '审批人类型: USER/POSITION/DEPARTMENT_HEAD',
  `approver_id` BIGINT DEFAULT NULL COMMENT '指定审批人ID（USER类型）或职位ID（POSITION类型）',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_workflow_order` (`workflow_id`,`node_order`),
  KEY `idx_workflow` (`workflow_id`),
  CONSTRAINT `fk_node_tpl_workflow` FOREIGN KEY (`workflow_id`) REFERENCES `workflow_template` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='工作流节点模板表';

-- ----------------------------
-- 12. 审批记录表 (approval_record)
-- ----------------------------
DROP TABLE IF EXISTS `approval_record`;
CREATE TABLE `approval_record` (
  `id` VARCHAR(36) NOT NULL COMMENT '审批ID (UUID)',
  `title` VARCHAR(200) NOT NULL COMMENT '审批标题',
  `type_code` VARCHAR(50) NOT NULL COMMENT '审批类型编码',
  `content` TEXT COMMENT '审批内容（支持JSON）',
  `initiator_id` BIGINT NOT NULL COMMENT '发起人ID',
  `priority` TINYINT DEFAULT 0 COMMENT '紧急程度: 0-普通 1-紧急 2-非常紧急',
  `deadline` DATETIME DEFAULT NULL COMMENT '截止日期',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态码',
  `current_node_order` INT DEFAULT 1 COMMENT '当前审批节点序号',
  `workflow_id` BIGINT DEFAULT NULL COMMENT '使用的工作流模板ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` DATETIME DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`id`),
  KEY `idx_initiator` (`initiator_id`),
  KEY `idx_type` (`type_code`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_approval_workflow` (`workflow_id`),
  CONSTRAINT `fk_record_initiator` FOREIGN KEY (`initiator_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_record_type` FOREIGN KEY (`type_code`) REFERENCES `approval_type` (`code`) ON DELETE RESTRICT,
  CONSTRAINT `fk_record_workflow` FOREIGN KEY (`workflow_id`) REFERENCES `workflow_template` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='审批记录表';

-- ----------------------------
-- 13. 审批节点表 (approval_node)
-- ----------------------------
DROP TABLE IF EXISTS `approval_node`;
CREATE TABLE `approval_node` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '节点ID',
  `approval_id` VARCHAR(36) NOT NULL COMMENT '审批记录ID',
  `node_name` VARCHAR(100) NOT NULL COMMENT '节点名称',
  `approver_id` BIGINT NOT NULL COMMENT '审批人ID',
  `node_order` INT NOT NULL COMMENT '节点顺序',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0-待审批 1-已通过 2-已拒绝',
  `comment` VARCHAR(500) DEFAULT NULL COMMENT '审批意见',
  `approved_at` DATETIME DEFAULT NULL COMMENT '审批时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_approval_order` (`approval_id`,`node_order`),
  KEY `idx_approval_id` (`approval_id`),
  KEY `idx_approver` (`approver_id`),
  CONSTRAINT `fk_node_record` FOREIGN KEY (`approval_id`) REFERENCES `approval_record` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_node_approver` FOREIGN KEY (`approver_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='审批节点表';

-- ----------------------------
-- 14. 附件表 (attachment)
-- ----------------------------
DROP TABLE IF EXISTS `attachment`;
CREATE TABLE `attachment` (
  `id` VARCHAR(36) NOT NULL COMMENT '附件ID (UUID)',
  `approval_id` VARCHAR(36) DEFAULT NULL COMMENT '关联审批ID',
  `original_name` VARCHAR(255) NOT NULL COMMENT '原始文件名',
  `stored_name` VARCHAR(255) NOT NULL COMMENT '存储文件名',
  `file_path` VARCHAR(500) NOT NULL COMMENT '文件存储路径',
  `file_size` BIGINT NOT NULL COMMENT '文件大小（字节）',
  `file_type` VARCHAR(50) DEFAULT NULL COMMENT '文件类型',
  `mime_type` VARCHAR(100) DEFAULT NULL COMMENT 'MIME 类型',
  `preview_support` TINYINT DEFAULT 0 COMMENT '是否支持在线预览',
  `uploader_id` BIGINT NOT NULL COMMENT '上传者ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_approval_id` (`approval_id`),
  KEY `idx_uploader` (`uploader_id`),
  CONSTRAINT `fk_attach_record` FOREIGN KEY (`approval_id`) REFERENCES `approval_record` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_attach_uploader` FOREIGN KEY (`uploader_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='附件表';

-- ----------------------------
-- 15. 通知表 (notification)
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification` (
  `id` VARCHAR(36) NOT NULL COMMENT '通知ID (UUID)',
  `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
  `title` VARCHAR(200) NOT NULL COMMENT '通知标题',
  `content` VARCHAR(500) DEFAULT NULL COMMENT '通知内容',
  `type` VARCHAR(20) NOT NULL COMMENT '通知类型: APPROVAL/SYSTEM/REMINDER',
  `related_id` VARCHAR(36) DEFAULT NULL COMMENT '关联业务ID',
  `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读 1-已读',
  `read_at` DATETIME DEFAULT NULL COMMENT '阅读时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_read` (`user_id`,`is_read`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_notify_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='通知表';

-- ----------------------------
-- 16. 操作日志表 (operation_log)
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` BIGINT NOT NULL COMMENT '操作用户ID',
  `module` VARCHAR(50) NOT NULL COMMENT '模块名称',
  `operation` VARCHAR(50) NOT NULL COMMENT '操作类型',
  `target_id` VARCHAR(36) DEFAULT NULL COMMENT '目标业务ID',
  `detail` TEXT COMMENT '操作详情',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT '客户端IP地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '用户代理信息',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_module` (`module`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作日志表';

-- 补上循环依赖的外键
ALTER TABLE `sys_department` ADD CONSTRAINT `fk_dept_leader` FOREIGN KEY (`leader_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL;


-- ============================================================
-- 第二部分: 初始化数据
-- ============================================================

-- ----------------------------
-- 1. 部门数据
-- ----------------------------
INSERT INTO `sys_department` (`id`, `name`, `parent_id`, `leader_id`, `sort_order`, `status`) VALUES
-- 一级部门
(1, '总经办', 0, NULL, 1, 1),
(2, '人事行政部', 1, NULL, 2, 1),
(3, '技术部', 1, NULL, 3, 1),
(4, '财务部', 1, NULL, 4, 1),
(5, '市场部', 1, NULL, 5, 1),
-- 技术部下设子部门
(6, '前端开发组', 3, NULL, 1, 1),
(7, '后端开发组', 3, NULL, 2, 1),
(8, '测试组', 3, NULL, 3, 1),
-- 市场部下设子部门
(9, '品牌推广组', 5, NULL, 1, 1),
(10, '销售组', 5, NULL, 2, 1);

-- ----------------------------
-- 2. 用户数据 (密码均为: admin123 -> BCrypt加密)
-- 注意: 用户的角色和职位通过关联表设置
-- ----------------------------
INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `email`, `phone`, `department_id`, `status`) VALUES
-- 管理层
(1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 'admin@company.com', '13800000001', 1, 1),
(2, 'hr_admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '人事经理', 'hr@company.com', '13800000002', 2, 1),
(3, 'tech_lead', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '技术总监', 'tech@company.com', '13800000003', 3, 1),
(4, 'finance_mgr', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '财务经理', 'finance@company.com', '13800000004', 4, 1),
(5, 'market_mgr', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '市场总监', 'market@company.com', '13800000005', 5, 1),
-- 前端开发组
(6, 'wang_fe', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '王前端', 'wang.fe@company.com', '13800000006', 6, 1),
(7, 'zhao_fe', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '赵前端', 'zhao.fe@company.com', '13800000007', 6, 1),
(8, 'liu_fe', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '刘前端', 'liu.fe@company.com', '13800000008', 6, 1),
-- 后端开发组
(9, 'chen_be', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '陈后端', 'chen.be@company.com', '13800000009', 7, 1),
(10, 'yang_be', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '杨后端', 'yang.be@company.com', '13800000010', 7, 1),
(11, 'zhou_be', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '周后端', 'zhou.be@company.com', '13800000011', 7, 1),
-- 测试组
(12, 'wu_test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '吴测试', 'wu.test@company.com', '13800000012', 8, 1),
(13, 'sun_test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '孙测试', 'sun.test@company.com', '13800000013', 8, 1),
-- 人事行政部
(14, 'zheng_hr', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '郑人事', 'zheng.hr@company.com', '13800000014', 2, 1),
-- 财务部
(15, 'qian_fin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '钱财务', 'qian.fin@company.com', '13800000015', 4, 1),
(16, 'ma_fin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '马财务', 'ma.fin@company.com', '13800000016', 4, 1),
-- 品牌推广组
(17, 'he_brand', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '何品牌', 'he.brand@company.com', '13800000017', 9, 1),
-- 销售组
(18, 'lin_sales', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '林销售', 'lin.sales@company.com', '13800000018', 10, 1),
(19, 'xu_sales', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '徐销售', 'xu.sales@company.com', '13800000019', 10, 1);

-- 更新部门负责人
UPDATE `sys_department` SET `leader_id` = 1 WHERE `id` = 1;  -- 总经办 -> admin
UPDATE `sys_department` SET `leader_id` = 2 WHERE `id` = 2;  -- 人事行政部 -> hr_admin
UPDATE `sys_department` SET `leader_id` = 3 WHERE `id` = 3;  -- 技术部 -> tech_lead
UPDATE `sys_department` SET `leader_id` = 4 WHERE `id` = 4;  -- 财务部 -> finance_mgr
UPDATE `sys_department` SET `leader_id` = 5 WHERE `id` = 5;  -- 市场部 -> market_mgr
UPDATE `sys_department` SET `leader_id` = 6 WHERE `id` = 6;  -- 前端开发组 -> wang_fe (组长)
UPDATE `sys_department` SET `leader_id` = 9 WHERE `id` = 7;  -- 后端开发组 -> chen_be (组长)
UPDATE `sys_department` SET `leader_id` = 12 WHERE `id` = 8; -- 测试组 -> wu_test (组长)
UPDATE `sys_department` SET `leader_id` = 17 WHERE `id` = 9; -- 品牌推广组 -> he_brand (组长)
UPDATE `sys_department` SET `leader_id` = 18 WHERE `id` = 10; -- 销售组 -> lin_sales (组长)

-- ----------------------------
-- 3. 系统角色数据 (RBAC核心)
-- ----------------------------
INSERT INTO `sys_role` (`id`, `code`, `name`, `description`, `sort_order`, `status`) VALUES
(1, 'SUPER_ADMIN', '超级管理员', '系统最高权限，可管理所有功能', 1, 1),
(2, 'ADMIN', '管理员', '系统管理功能权限', 2, 1),
(3, 'USER', '普通用户', '基础功能权限', 3, 1);

-- ----------------------------
-- 4. 系统权限数据 (RBAC核心)
-- ----------------------------
INSERT INTO `sys_permission` (`id`, `code`, `name`, `type`, `parent_id`, `path`, `icon`, `sort_order`, `status`) VALUES
-- 一级菜单
(1, 'dashboard:view', '仪表盘', 'MENU', 0, '/dashboard', 'home', 1, 1),
(2, 'approval:view', '审批列表', 'MENU', 0, '/approval', 'file-check', 2, 1),
(3, 'user:view', '用户管理', 'MENU', 0, '/admin/users', 'users', 10, 1),
(4, 'role:view', '角色管理', 'MENU', 0, '/admin/roles', 'shield', 11, 1),
(5, 'system:config', '系统配置', 'MENU', 0, '/admin/settings', 'settings', 12, 1),
-- 审批相关按钮权限
(10, 'approval:create', '发起审批', 'BUTTON', 2, NULL, NULL, 1, 1),
(11, 'approval:approve', '审批操作', 'BUTTON', 2, NULL, NULL, 2, 1),
(12, 'approval:withdraw', '撤回审批', 'BUTTON', 2, NULL, NULL, 3, 1),
-- 用户管理按钮权限
(20, 'user:create', '新增用户', 'BUTTON', 3, NULL, NULL, 1, 1),
(21, 'user:edit', '编辑用户', 'BUTTON', 3, NULL, NULL, 2, 1),
(22, 'user:delete', '删除用户', 'BUTTON', 3, NULL, NULL, 3, 1),
-- 角色管理按钮权限
(30, 'role:manage', '角色配置', 'BUTTON', 4, NULL, NULL, 1, 1);

-- ----------------------------
-- 5. 用户角色关联数据
-- admin: 超级管理员
-- hr_admin, tech_lead, finance_mgr, market_mgr: 管理员
-- 其他员工: 普通用户
-- ----------------------------
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES
(1, 1),   -- admin -> 超级管理员
(2, 2),   -- hr_admin -> 管理员
(3, 2),   -- tech_lead -> 管理员
(4, 2),   -- finance_mgr -> 管理员
(5, 2),   -- market_mgr -> 管理员
(6, 3),   -- wang_fe -> 普通用户
(7, 3),   -- zhao_fe -> 普通用户
(8, 3),   -- liu_fe -> 普通用户
(9, 3),   -- chen_be -> 普通用户
(10, 3),  -- yang_be -> 普通用户
(11, 3),  -- zhou_be -> 普通用户
(12, 3),  -- wu_test -> 普通用户
(13, 3),  -- sun_test -> 普通用户
(14, 3),  -- zheng_hr -> 普通用户
(15, 3),  -- qian_fin -> 普通用户
(16, 3),  -- ma_fin -> 普通用户
(17, 3),  -- he_brand -> 普通用户
(18, 3),  -- lin_sales -> 普通用户
(19, 3);  -- xu_sales -> 普通用户

-- ----------------------------
-- 6. 角色权限关联数据
-- 超级管理员: 所有权限
-- 管理员: 除系统配置外的管理权限
-- 普通用户: 基础功能
-- ----------------------------
-- 超级管理员 - 拥有所有权限
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(1, 10), (1, 11), (1, 12),
(1, 20), (1, 21), (1, 22),
(1, 30);

-- 管理员 - 用户管理、审批管理，无系统配置
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`) VALUES
(2, 1), (2, 2), (2, 3),
(2, 10), (2, 11), (2, 12),
(2, 20), (2, 21);

-- 普通用户 - 仪表盘、审批列表、发起审批
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`) VALUES
(3, 1), (3, 2),
(3, 10), (3, 12);

-- ----------------------------
-- 7. 业务职位数据 (与系统权限分离)
-- ----------------------------
INSERT INTO `sys_position` (`id`, `code`, `name`, `description`, `level`, `sort_order`, `status`) VALUES
(1, 'CEO', '总经理', '公司最高决策者', 100, 1, 1),
(2, 'DEPT_MANAGER', '部门经理', '部门负责人', 50, 2, 1),
(3, 'TEAM_LEADER', '组长', '团队负责人', 30, 3, 1),
(4, 'STAFF', '员工', '普通员工', 10, 4, 1),
(5, 'FINANCE', '财务', '财务审核职责', 40, 5, 1),
(6, 'HR', '人事', '人事管理职责', 40, 6, 1);

-- ----------------------------
-- 8. 用户职位关联数据
-- ----------------------------
INSERT INTO `sys_user_position` (`user_id`, `position_id`, `is_primary`) VALUES
-- 管理层
(1, 1, 1),   -- admin -> 总经理(主)
(2, 2, 1),   -- hr_admin -> 部门经理(主)
(2, 6, 0),   -- hr_admin -> 人事(兼)
(3, 2, 1),   -- tech_lead -> 部门经理(主)
(4, 2, 1),   -- finance_mgr -> 部门经理(主)
(4, 5, 0),   -- finance_mgr -> 财务(兼)
(5, 2, 1),   -- market_mgr -> 部门经理(主)
-- 子部门组长
(6, 3, 1),   -- wang_fe -> 组长(主) - 前端组长
(9, 3, 1),   -- chen_be -> 组长(主) - 后端组长
(12, 3, 1),  -- wu_test -> 组长(主) - 测试组长
(17, 3, 1),  -- he_brand -> 组长(主) - 品牌组长
(18, 3, 1),  -- lin_sales -> 组长(主) - 销售组长
-- 普通员工
(7, 4, 1),   -- zhao_fe -> 员工(主)
(8, 4, 1),   -- liu_fe -> 员工(主)
(10, 4, 1),  -- yang_be -> 员工(主)
(11, 4, 1),  -- zhou_be -> 员工(主)
(13, 4, 1),  -- sun_test -> 员工(主)
(14, 4, 1),  -- zheng_hr -> 员工(主)
(14, 6, 0),  -- zheng_hr -> 人事(兼)
(15, 4, 1),  -- qian_fin -> 员工(主)
(15, 5, 0),  -- qian_fin -> 财务(兼)
(16, 4, 1),  -- ma_fin -> 员工(主)
(16, 5, 0),  -- ma_fin -> 财务(兼)
(19, 4, 1);  -- xu_sales -> 员工(主)

-- ----------------------------
-- 9. 审批类型数据
-- ----------------------------
INSERT INTO `approval_type` (`code`, `name`, `description`, `icon`, `color`, `sort_order`) VALUES
('LEAVE', '请假申请', '员工请假、调休审批', 'calendar', '#3B82F6', 1),
('EXPENSE', '报销申请', '差旅费、业务费报销', 'dollar-sign', '#10B981', 2),
('PURCHASE', '采购申请', '办公用品、设备采购', 'shopping-cart', '#8B5CF6', 3),
('BUSINESS_TRIP', '出差申请', '外出公干、出差备案', 'plane', '#F59E0B', 4),
('OVERTIME', '加班申请', '工作日及节假日加班', 'clock', '#EF4444', 5),
('CONTRACT', '合同审批', '业务合同审核', 'file-text', '#6366F1', 6);

-- ----------------------------
-- 10. 工作流模板数据
-- ----------------------------
INSERT INTO `workflow_template` (`id`, `name`, `type_code`, `description`, `created_by`, `status`) VALUES
(1, '普通请假流程', 'LEAVE', '适用于3天以内的普通请假，需经部门负责人和人事审批', 2, 1),
(2, '费用报销流程', 'EXPENSE', '标准报销审批流，需经部门负责人、财务和总经理审批', 4, 1),
(3, '采购申请流程', 'PURCHASE', '办公用品及设备采购审批，需经部门负责人和财务审批', 4, 1),
(4, '出差申请流程', 'BUSINESS_TRIP', '出差备案审批，需经部门负责人和人事审批', 2, 1),
(5, '加班申请流程', 'OVERTIME', '加班审批流程，仅需部门负责人审批', 3, 1),
(6, '合同审批流程', 'CONTRACT', '业务合同审核，需经部门负责人、财务和总经理审批', 1, 1);

-- ----------------------------
-- 11. 工作流节点数据 (使用POSITION类型)
-- ----------------------------
INSERT INTO `workflow_node_template` (`workflow_id`, `node_name`, `node_order`, `approver_type`, `approver_id`) VALUES
-- 请假流程: 部门负责人 -> 人事
(1, '部门负责人审批', 1, 'DEPARTMENT_HEAD', NULL),
(1, '人事审批', 2, 'POSITION', 6),
-- 报销流程: 部门负责人 -> 财务 -> 总经理
(2, '部门负责人审批', 1, 'DEPARTMENT_HEAD', NULL),
(2, '财务初审', 2, 'POSITION', 5),
(2, '总经理审批', 3, 'POSITION', 1),
-- 采购流程: 部门负责人 -> 财务
(3, '部门负责人审批', 1, 'DEPARTMENT_HEAD', NULL),
(3, '财务审批', 2, 'POSITION', 5),
-- 出差流程: 部门负责人 -> 人事
(4, '部门负责人审批', 1, 'DEPARTMENT_HEAD', NULL),
(4, '人事备案', 2, 'POSITION', 6),
-- 加班流程: 部门负责人
(5, '部门负责人审批', 1, 'DEPARTMENT_HEAD', NULL),
-- 合同流程: 部门负责人 -> 财务 -> 总经理
(6, '部门负责人审批', 1, 'DEPARTMENT_HEAD', NULL),
(6, '财务审核', 2, 'POSITION', 5),
(6, '总经理审批', 3, 'POSITION', 1);

-- ----------------------------
-- 12. 审批记录示例数据 (各种状态)
-- 状态: 0-草稿 1-待审批 2-审批中 3-已通过 4-已拒绝 5-已撤回
-- ----------------------------
INSERT INTO `approval_record` (`id`, `title`, `type_code`, `content`, `initiator_id`, `priority`, `deadline`, `status`, `current_node_order`, `workflow_id`, `created_at`, `completed_at`) VALUES
-- 草稿状态
('apr-draft-001', '年假申请 - 张前端', 'LEAVE', '{"leaveType":"年假","startDate":"2026-01-20","endDate":"2026-01-22","days":3,"reason":"春节回家探亲"}', 7, 0, '2026-01-19 00:00:00', 0, 1, 1, '2026-01-10 09:30:00', NULL),
('apr-draft-002', '办公椅采购申请', 'PURCHASE', '{"itemName":"人体工学办公椅","quantity":5,"unitPrice":1500,"totalAmount":7500,"reason":"部门新增员工，需采购办公椅"}', 9, 0, NULL, 0, 1, 3, '2026-01-11 14:00:00', NULL),
-- 待审批状态 (已提交，等待第一个节点审批)
('apr-pending-001', '病假申请 - 刘前端', 'LEAVE', '{"leaveType":"病假","startDate":"2026-01-15","endDate":"2026-01-16","days":2,"reason":"感冒发烧，需在家休息"}', 8, 1, '2026-01-14 18:00:00', 1, 1, 1, '2026-01-14 08:30:00', NULL),
('apr-pending-002', '出差申请 - 陈后端', 'BUSINESS_TRIP', '{"destination":"上海","startDate":"2026-01-18","endDate":"2026-01-20","days":3,"purpose":"参加技术大会","estimatedCost":5000}', 9, 0, '2026-01-17 00:00:00', 1, 1, 4, '2026-01-12 10:00:00', NULL),
('apr-pending-003', '加班申请 - 周后端', 'OVERTIME', '{"date":"2026-01-15","startTime":"19:00","endTime":"22:00","hours":3,"reason":"紧急修复线上bug"}', 11, 2, NULL, 1, 1, 5, '2026-01-15 17:30:00', NULL),
-- 审批中状态 (已通过第一个节点，等待后续节点)
('apr-progress-001', '报销申请 - 何品牌', 'EXPENSE', '{"expenseType":"差旅费","amount":3500,"items":[{"name":"机票","amount":2000},{"name":"住宿","amount":1500}],"tripDate":"2026-01-05"}', 17, 0, NULL, 2, 2, 2, '2026-01-06 09:00:00', NULL),
('apr-progress-002', '合同审批 - 林销售', 'CONTRACT', '{"contractName":"客户A年度服务合同","partyB":"北京某科技公司","amount":500000,"period":"2026-01-01至2026-12-31"}', 18, 1, '2026-01-20 00:00:00', 2, 2, 6, '2026-01-08 11:00:00', NULL),
-- 已通过状态
('apr-approved-001', '年假申请 - 王前端', 'LEAVE', '{"leaveType":"年假","startDate":"2026-01-02","endDate":"2026-01-03","days":2,"reason":"个人事务"}', 6, 0, NULL, 3, 2, 1, '2025-12-28 16:00:00', '2025-12-30 10:30:00'),
('apr-approved-002', '报销申请 - 杨后端', 'EXPENSE', '{"expenseType":"业务招待费","amount":800,"items":[{"name":"商务晚餐","amount":800}],"businessDate":"2025-12-20"}', 10, 0, NULL, 3, 3, 2, '2025-12-22 14:00:00', '2025-12-25 16:00:00'),
('apr-approved-003', '加班申请 - 吴测试', 'OVERTIME', '{"date":"2025-12-31","startTime":"20:00","endTime":"23:00","hours":3,"reason":"年终版本测试"}', 12, 0, NULL, 3, 1, 5, '2025-12-30 18:00:00', '2025-12-31 09:00:00'),
-- 已拒绝状态
('apr-rejected-001', '采购申请 - 孙测试', 'PURCHASE', '{"itemName":"高端游戏显示器","quantity":2,"unitPrice":5000,"totalAmount":10000,"reason":"测试需要更好的显示效果"}', 13, 0, NULL, 4, 1, 3, '2026-01-05 10:00:00', '2026-01-06 11:00:00'),
('apr-rejected-002', '出差申请 - 徐销售', 'BUSINESS_TRIP', '{"destination":"三亚","startDate":"2026-02-01","endDate":"2026-02-05","days":5,"purpose":"客户拜访","estimatedCost":15000}', 19, 0, NULL, 4, 1, 4, '2026-01-10 09:00:00', '2026-01-10 14:00:00'),
-- 已撤回状态
('apr-withdrawn-001', '请假申请 - 郑人事', 'LEAVE', '{"leaveType":"事假","startDate":"2026-01-12","endDate":"2026-01-12","days":1,"reason":"处理个人事务"}', 14, 0, NULL, 5, 1, 1, '2026-01-11 08:00:00', '2026-01-11 09:00:00');

-- ----------------------------
-- 13. 审批节点示例数据
-- 状态: 0-待审批 1-已通过 2-已拒绝
-- ----------------------------
INSERT INTO `approval_node` (`approval_id`, `node_name`, `approver_id`, `node_order`, `status`, `comment`, `approved_at`) VALUES
-- apr-pending-001 的节点 (待审批)
('apr-pending-001', '部门负责人审批', 6, 1, 0, NULL, NULL),
('apr-pending-001', '人事审批', 2, 2, 0, NULL, NULL),
-- apr-pending-002 的节点 (待审批)
('apr-pending-002', '部门负责人审批', 9, 1, 0, NULL, NULL),
('apr-pending-002', '人事备案', 2, 2, 0, NULL, NULL),
-- apr-pending-003 的节点 (待审批 - 加班只需一级审批)
('apr-pending-003', '部门负责人审批', 9, 1, 0, NULL, NULL),
-- apr-progress-001 的节点 (审批中，第一节点已通过)
('apr-progress-001', '部门负责人审批', 5, 1, 1, '同意报销', '2026-01-06 15:00:00'),
('apr-progress-001', '财务初审', 4, 2, 0, NULL, NULL),
('apr-progress-001', '总经理审批', 1, 3, 0, NULL, NULL),
-- apr-progress-002 的节点 (审批中，第一节点已通过)
('apr-progress-002', '部门负责人审批', 5, 1, 1, '合同条款已审核，同意', '2026-01-09 10:00:00'),
('apr-progress-002', '财务审核', 4, 2, 0, NULL, NULL),
('apr-progress-002', '总经理审批', 1, 3, 0, NULL, NULL),
-- apr-approved-001 的节点 (已通过)
('apr-approved-001', '部门负责人审批', 3, 1, 1, '同意休假', '2025-12-29 09:00:00'),
('apr-approved-001', '人事审批', 2, 2, 1, '已备案', '2025-12-30 10:30:00'),
-- apr-approved-002 的节点 (已通过)
('apr-approved-002', '部门负责人审批', 3, 1, 1, '同意报销', '2025-12-23 10:00:00'),
('apr-approved-002', '财务初审', 4, 2, 1, '票据齐全，同意', '2025-12-24 14:00:00'),
('apr-approved-002', '总经理审批', 1, 3, 1, '同意', '2025-12-25 16:00:00'),
-- apr-approved-003 的节点 (已通过 - 加班只需一级审批)
('apr-approved-003', '部门负责人审批', 3, 1, 1, '辛苦了，同意加班', '2025-12-31 09:00:00'),
-- apr-rejected-001 的节点 (已拒绝)
('apr-rejected-001', '部门负责人审批', 12, 1, 2, '游戏显示器非工作必需，采购申请不予批准', '2026-01-06 11:00:00'),
('apr-rejected-001', '财务审批', 4, 2, 0, NULL, NULL),
-- apr-rejected-002 的节点 (已拒绝)
('apr-rejected-002', '部门负责人审批', 5, 1, 2, '三亚非主要客户区域，出差理由不充分', '2026-01-10 14:00:00'),
('apr-rejected-002', '人事备案', 2, 2, 0, NULL, NULL),
-- apr-withdrawn-001 的节点 (已撤回)
('apr-withdrawn-001', '部门负责人审批', 2, 1, 0, NULL, NULL),
('apr-withdrawn-001', '人事审批', 2, 2, 0, NULL, NULL);

-- ----------------------------
-- 14. 通知消息示例数据
-- ----------------------------
INSERT INTO `notification` (`id`, `user_id`, `title`, `content`, `type`, `related_id`, `is_read`, `read_at`, `created_at`) VALUES
-- 系统通知
('uuid-notify-sys-001', 6, '欢迎使用审批系统', '您好，王前端！您的账号已创建成功，请尽快完善个人信息。', 'SYSTEM', NULL, 1, '2026-01-02 09:00:00', '2026-01-01 08:00:00'),
('uuid-notify-sys-002', 7, '欢迎使用审批系统', '您好，赵前端！您的账号已创建成功，请尽快完善个人信息。', 'SYSTEM', NULL, 1, '2026-01-02 10:30:00', '2026-01-01 08:00:00'),
('uuid-notify-sys-003', 8, '欢迎使用审批系统', '您好，刘前端！您的账号已创建成功，请尽快完善个人信息。', 'SYSTEM', NULL, 0, NULL, '2026-01-01 08:00:00'),
('uuid-notify-sys-004', 9, '欢迎使用审批系统', '您好，陈后端！您的账号已创建成功，请尽快完善个人信息。', 'SYSTEM', NULL, 1, '2026-01-01 09:00:00', '2026-01-01 08:00:00'),
-- 审批待办通知
('uuid-notify-apr-001', 6, '您有新的审批待办', '刘前端提交了一份病假申请，请尽快审批。', 'APPROVAL', 'apr-pending-001', 0, NULL, '2026-01-14 08:30:00'),
('uuid-notify-apr-002', 9, '您有新的审批待办', '周后端提交了一份加班申请，请尽快审批。', 'APPROVAL', 'apr-pending-003', 0, NULL, '2026-01-15 17:30:00'),
('uuid-notify-apr-003', 4, '您有新的审批待办', '何品牌的报销申请已通过部门审批，请进行财务初审。', 'APPROVAL', 'apr-progress-001', 0, NULL, '2026-01-06 15:00:00'),
('uuid-notify-apr-004', 4, '您有新的审批待办', '林销售的合同审批已通过部门审批，请进行财务审核。', 'APPROVAL', 'apr-progress-002', 1, '2026-01-09 11:00:00', '2026-01-09 10:00:00'),
-- 审批结果通知
('uuid-notify-res-001', 6, '您的请假申请已通过', '您的年假申请(2026-01-02至2026-01-03)已审批通过，祝您假期愉快！', 'APPROVAL', 'apr-approved-001', 1, '2025-12-30 11:00:00', '2025-12-30 10:30:00'),
('uuid-notify-res-002', 10, '您的报销申请已通过', '您的业务招待费报销申请(金额:¥800)已审批通过，财务将尽快处理。', 'APPROVAL', 'apr-approved-002', 1, '2025-12-26 09:00:00', '2025-12-25 16:00:00'),
('uuid-notify-res-003', 13, '您的采购申请被驳回', '您的采购申请"高端游戏显示器"被驳回，原因：游戏显示器非工作必需，采购申请不予批准。', 'APPROVAL', 'apr-rejected-001', 1, '2026-01-06 12:00:00', '2026-01-06 11:00:00'),
('uuid-notify-res-004', 19, '您的出差申请被驳回', '您的出差申请被驳回，原因：三亚非主要客户区域，出差理由不充分。', 'APPROVAL', 'apr-rejected-002', 0, NULL, '2026-01-10 14:00:00'),
-- 提醒通知
('uuid-notify-rem-001', 3, '待办事项提醒', '您有2条审批待处理，请及时审批。', 'REMINDER', NULL, 0, NULL, '2026-01-15 09:00:00'),
('uuid-notify-rem-002', 4, '待办事项提醒', '您有2条财务审批待处理，请及时审批。', 'REMINDER', NULL, 0, NULL, '2026-01-15 09:00:00');

-- ----------------------------
-- 15. 操作日志示例数据
-- ----------------------------
INSERT INTO `operation_log` (`user_id`, `module`, `operation`, `target_id`, `detail`, `ip_address`, `user_agent`, `created_at`) VALUES
-- 登录日志
(1, 'AUTH', 'LOGIN', NULL, '用户登录成功', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-15 08:00:00'),
(2, 'AUTH', 'LOGIN', NULL, '用户登录成功', '192.168.1.101', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-15 08:30:00'),
(3, 'AUTH', 'LOGIN', NULL, '用户登录成功', '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15', '2026-01-15 09:00:00'),
(4, 'AUTH', 'LOGIN', NULL, '用户登录成功', '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120.0.0.0', '2026-01-15 09:15:00'),
(6, 'AUTH', 'LOGIN', NULL, '用户登录成功', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-15 09:30:00'),
-- 用户管理日志
(1, 'USER', 'CREATE', '19', '创建用户: xu_sales(徐销售)', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-10 10:00:00'),
(1, 'USER', 'UPDATE', '14', '更新用户信息: zheng_hr', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-11 14:30:00'),
(2, 'USER', 'ASSIGN_ROLE', '7', '为用户 zhao_fe 分配角色: 普通用户', '192.168.1.101', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-05 11:00:00'),
-- 审批操作日志
(8, 'APPROVAL', 'SUBMIT', 'apr-pending-001', '提交病假申请', '192.168.1.112', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-14 08:30:00'),
(11, 'APPROVAL', 'SUBMIT', 'apr-pending-003', '提交加班申请', '192.168.1.115', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-15 17:30:00'),
(5, 'APPROVAL', 'APPROVE', 'apr-progress-001', '审批通过: 同意报销', '192.168.1.109', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-06 15:00:00'),
(3, 'APPROVAL', 'APPROVE', 'apr-approved-001', '审批通过: 同意休假', '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15', '2025-12-29 09:00:00'),
(12, 'APPROVAL', 'REJECT', 'apr-rejected-001', '审批拒绝: 游戏显示器非工作必需', '192.168.1.116', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-06 11:00:00'),
(14, 'APPROVAL', 'WITHDRAW', 'apr-withdrawn-001', '撤回请假申请', '192.168.1.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-11 09:00:00'),
-- 工作流管理日志
(1, 'WORKFLOW', 'CREATE', '6', '创建工作流模板: 合同审批流程', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-08 16:00:00'),
(2, 'WORKFLOW', 'UPDATE', '1', '更新工作流模板: 普通请假流程', '192.168.1.101', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-03 10:00:00'),
-- 部门管理日志
(1, 'DEPARTMENT', 'CREATE', '10', '创建部门: 销售组', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-02 14:00:00'),
(1, 'DEPARTMENT', 'UPDATE', '6', '更新部门信息: 前端开发组, 设置负责人: 王前端', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0', '2026-01-02 14:30:00');

-- SET FOREIGN_KEY_CHECKS = 1;
