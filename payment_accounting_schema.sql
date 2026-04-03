-- ============================================================================
-- 电商支付账务清结算系统数据库表设计
-- 基于人人都是产品经理《中文互联网最好的图解支付系统设计精华》文章内容设计
-- ============================================================================

-- ============================================================================
-- 1. 基础信息表
-- ============================================================================

-- 1.1 商户信息表
CREATE TABLE `merchant` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `merchant_name` VARCHAR(128) NOT NULL COMMENT '商户名称',
    `merchant_type` TINYINT NOT NULL DEFAULT 1 COMMENT '商户类型：1-普通商户，2-大商户，3-平台商户',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-冻结，3-注销',
    `settle_cycle` TINYINT NOT NULL DEFAULT 1 COMMENT '结算周期：1-T+0，2-T+1，3-T+7',
    `settle_account_type` TINYINT NOT NULL DEFAULT 1 COMMENT '结算账户类型：1-余额，2-银行卡',
    `bank_card_no` VARCHAR(32) DEFAULT NULL COMMENT '结算银行卡号',
    `bank_name` VARCHAR(64) DEFAULT NULL COMMENT '开户行名称',
    `bank_account_name` VARCHAR(128) DEFAULT NULL COMMENT '银行账户名',
    `fee_rate` DECIMAL(10,6) NOT NULL DEFAULT 0.006000 COMMENT '手续费率',
    `min_refund_amount` DECIMAL(15,2) DEFAULT NULL COMMENT '最小退款金额',
    `refund_expire_days` INT DEFAULT NULL COMMENT '退款有效期天数',
    `allow_overdraft` TINYINT NOT NULL DEFAULT 0 COMMENT '是否允许透支：0-否，1-是',
    `buffer_accounting` TINYINT NOT NULL DEFAULT 0 COMMENT '是否缓冲记账：0-否，1-是',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_merchant_no` (`merchant_no`),
    KEY `idx_status` (`status`),
    KEY `idx_settle_cycle` (`settle_cycle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户信息表';

-- 1.2 用户信息表
CREATE TABLE `user_account` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_no` VARCHAR(32) NOT NULL COMMENT '用户编号',
    `user_name` VARCHAR(64) DEFAULT NULL COMMENT '用户姓名',
    `mobile` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
    `email` VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-冻结，3-注销',
    `allow_overdraft` TINYINT NOT NULL DEFAULT 0 COMMENT '是否允许透支：0-否，1-是',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_no` (`user_no`),
    UNIQUE KEY `uk_mobile` (`mobile`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户账户信息表';

-- 1.3 会计科目表（多级科目）
CREATE TABLE `accounting_subject` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `subject_code` VARCHAR(32) NOT NULL COMMENT '科目代码，如：1001,100201',
    `subject_name` VARCHAR(128) NOT NULL COMMENT '科目名称',
    `parent_code` VARCHAR(32) DEFAULT NULL COMMENT '父级科目代码',
    `level` TINYINT NOT NULL DEFAULT 1 COMMENT '科目级别：1-一级，2-二级，3-三级',
    `subject_type` TINYINT NOT NULL COMMENT '科目类型：1-资产类，2-负债类，3-共同类，4-所有者权益类，5-损益类',
    `balance_direction` TINYINT NOT NULL COMMENT '余额方向：1-借方，2-贷方',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-停用',
    `description` VARCHAR(256) DEFAULT NULL COMMENT '科目说明',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_subject_code` (`subject_code`),
    KEY `idx_parent_code` (`parent_code`),
    KEY `idx_level` (`level`),
    KEY `idx_subject_type` (`subject_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会计科目表';

-- 示例数据：会计科目
-- INSERT INTO `accounting_subject` VALUES
-- (1, '1001', '库存现金', NULL, 1, 1, 1, 1, '资产类科目'),
-- (2, '1002', '银行存款', NULL, 1, 1, 1, 1, '资产类科目'),
-- (3, '100201', '备付金存款', '1002', 2, 1, 1, 1, '在银行的备付金账户'),
-- (4, '100202', '渠道待清算', '1002', 2, 1, 1, 1, '等待与渠道清算的资金'),
-- (5, '100203', '渠道应清算', '1002', 2, 1, 1, 1, '应与渠道清算的资金'),
-- (6, '100204', '银行头寸', '1002', 2, 1, 1, 1, '银行账户实际头寸'),
-- (7, '1122', '应收商户款', NULL, 1, 1, 1, 1, '应收商户的款项'),
-- (8, '2201', '应付商户款', NULL, 1, 2, 2, 1, '应付商户的结算款'),
-- (9, '220101', '商户待结算户', '2201', 2, 2, 2, 1, '等待结算给商户的资金'),
-- (10, '2202', '应付用户款', NULL, 1, 2, 2, 1, '应付用户的款项'),
-- (11, '220201', '用户余额账户', '2202', 2, 2, 2, 1, '用户的余额账户'),
-- (12, '2203', '支付网关过渡户', NULL, 1, 2, 2, 1, '支付网关的过渡账户'),
-- (13, '2204', '提现过渡户', NULL, 1, 2, 2, 1, '提现业务的过渡账户'),
-- (14, '2205', '退款过渡户', NULL, 1, 2, 2, 1, '退款业务的过渡账户'),
-- (15, '6001', '手续费收入', NULL, 1, 5, 2, 1, '手续费收入科目');

-- ============================================================================
-- 2. 账户体系表
-- ============================================================================

-- 2.1 账户信息表（内部账户）
CREATE TABLE `internal_account` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `account_name` VARCHAR(128) NOT NULL COMMENT '账户名称',
    `account_type` TINYINT NOT NULL COMMENT '账户类型：1-资产类，2-负债类，3-共同类',
    `subject_code` VARCHAR(32) NOT NULL COMMENT '关联的会计科目代码',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '当前余额',
    `available_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '可用余额',
    `frozen_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '冻结余额',
    `overdraft_limit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '透支额度',
    `allow_overdraft` TINYINT NOT NULL DEFAULT 0 COMMENT '是否允许透支：0-否，1-是',
    `buffer_accounting` TINYINT NOT NULL DEFAULT 0 COMMENT '是否缓冲记账：0-否，1-是',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-冻结，3-销户',
    `owner_type` TINYINT DEFAULT NULL COMMENT '所有者类型：1-平台，2-商户，3-用户',
    `owner_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '所有者ID（商户ID或用户ID）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_account_no` (`account_no`),
    KEY `idx_subject_code` (`subject_code`),
    KEY `idx_account_type` (`account_type`),
    KEY `idx_owner` (`owner_type`, `owner_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='内部账户信息表';

-- 2.2 用户余额账户表
CREATE TABLE `user_balance_account` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_no` VARCHAR(32) NOT NULL COMMENT '用户编号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '当前余额',
    `available_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '可用余额',
    `frozen_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '冻结余额',
    `total_income` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '累计收入',
    `total_expense` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '累计支出',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-冻结，3-销户',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_no_currency` (`user_no`, `currency`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户余额账户表';

-- 2.3 商户结算账户表
CREATE TABLE `merchant_settle_account` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `settle_type` TINYINT NOT NULL DEFAULT 1 COMMENT '结算类型：1-待结算，2-已结算',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '当前余额',
    `available_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '可用余额',
    `frozen_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '冻结余额',
    `pending_settle_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '待结算金额',
    `total_income` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '累计收入',
    `total_settled` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '累计已结算',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-冻结，3-销户',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_merchant_no_type` (`merchant_no`, `settle_type`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户结算账户表';

-- ============================================================================
-- 3. 交易核心表
-- ============================================================================

-- 3.1 支付订单表
CREATE TABLE `pay_order` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_no` VARCHAR(32) NOT NULL COMMENT '支付订单号',
    `merchant_order_no` VARCHAR(64) DEFAULT NULL COMMENT '商户订单号',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `user_no` VARCHAR(32) DEFAULT NULL COMMENT '用户编号',
    `product_code` VARCHAR(32) DEFAULT NULL COMMENT '产品代码',
    `trade_type` TINYINT NOT NULL COMMENT '交易类型：1-消费，2-预授权，3-分期',
    `pay_channel` VARCHAR(32) NOT NULL COMMENT '支付渠道：ALIPAY,WECHAT,CMB等',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '订单金额',
    `fee_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '手续费',
    `settle_amount` DECIMAL(15,2) NOT NULL COMMENT '结算金额（扣除手续费后）',
    `exchange_rate` DECIMAL(18,6) DEFAULT 1.000000 COMMENT '汇率（跨境场景）',
    `original_currency` CHAR(3) DEFAULT NULL COMMENT '原始币种（跨境场景）',
    `original_amount` DECIMAL(15,2) DEFAULT NULL COMMENT '原始金额（跨境场景）',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待支付，1-支付中，2-支付成功，3-支付失败，4-已关闭，5-已退款',
    `pay_time` DATETIME DEFAULT NULL COMMENT '支付成功时间',
    `settle_date` DATE DEFAULT NULL COMMENT '会计日期（用于日切）',
    `channel_order_no` VARCHAR(64) DEFAULT NULL COMMENT '渠道订单号',
    `channel_status` VARCHAR(32) DEFAULT NULL COMMENT '渠道返回状态',
    `client_ip` VARCHAR(32) DEFAULT NULL COMMENT '客户端IP',
    `device_info` VARCHAR(128) DEFAULT NULL COMMENT '设备信息',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `extend_info` JSON DEFAULT NULL COMMENT '扩展信息',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    UNIQUE KEY `uk_merchant_order_no` (`merchant_no`, `merchant_order_no`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_user_no` (`user_no`),
    KEY `idx_pay_channel` (`pay_channel`),
    KEY `idx_status` (`status`),
    KEY `idx_settle_date` (`settle_date`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付订单表';

-- 3.2 退款订单表
CREATE TABLE `refund_order` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `refund_no` VARCHAR(32) NOT NULL COMMENT '退款订单号',
    `order_no` VARCHAR(32) NOT NULL COMMENT '原支付订单号',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `user_no` VARCHAR(32) DEFAULT NULL COMMENT '用户编号',
    `refund_type` TINYINT NOT NULL DEFAULT 1 COMMENT '退款类型：1-全额退款，2-部分退款',
    `refund_amount` DECIMAL(15,2) NOT NULL COMMENT '退款金额',
    `refund_fee` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '退还手续费',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `refund_reason` VARCHAR(256) DEFAULT NULL COMMENT '退款原因',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待退款，1-退款中，2-退款成功，3-退款失败，4-已关闭',
    `refund_time` DATETIME DEFAULT NULL COMMENT '退款成功时间',
    `settle_date` DATE DEFAULT NULL COMMENT '会计日期',
    `channel_refund_no` VARCHAR(64) DEFAULT NULL COMMENT '渠道退款单号',
    `channel_status` VARCHAR(32) DEFAULT NULL COMMENT '渠道返回状态',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_refund_no` (`refund_no`),
    KEY `idx_order_no` (`order_no`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_status` (`status`),
    KEY `idx_settle_date` (`settle_date`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款订单表';

-- 3.3 充值订单表
CREATE TABLE `recharge_order` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `recharge_no` VARCHAR(32) NOT NULL COMMENT '充值订单号',
    `user_no` VARCHAR(32) NOT NULL COMMENT '用户编号',
    `recharge_channel` VARCHAR(32) NOT NULL COMMENT '充值渠道',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '充值金额',
    `fee_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '手续费',
    `actual_amount` DECIMAL(15,2) NOT NULL COMMENT '实际到账金额',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待充值，1-充值中，2-充值成功，3-充值失败',
    `recharge_time` DATETIME DEFAULT NULL COMMENT '充值成功时间',
    `settle_date` DATE DEFAULT NULL COMMENT '会计日期',
    `channel_order_no` VARCHAR(64) DEFAULT NULL COMMENT '渠道订单号',
    `channel_status` VARCHAR(32) DEFAULT NULL COMMENT '渠道返回状态',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_recharge_no` (`recharge_no`),
    KEY `idx_user_no` (`user_no`),
    KEY `idx_status` (`status`),
    KEY `idx_settle_date` (`settle_date`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值订单表';

-- 3.4 提现订单表
CREATE TABLE `withdraw_order` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `withdraw_no` VARCHAR(32) NOT NULL COMMENT '提现订单号',
    `user_no` VARCHAR(32) NOT NULL COMMENT '用户编号',
    `withdraw_type` TINYINT NOT NULL DEFAULT 1 COMMENT '提现类型：1-提现到银行卡，2-提现到第三方账户',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '提现金额',
    `fee_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '手续费',
    `actual_amount` DECIMAL(15,2) NOT NULL COMMENT '实际到账金额',
    `bank_card_no` VARCHAR(32) DEFAULT NULL COMMENT '银行卡号',
    `bank_name` VARCHAR(64) DEFAULT NULL COMMENT '开户行名称',
    `bank_account_name` VARCHAR(128) DEFAULT NULL COMMENT '银行账户名',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待处理，1-处理中，2-提现成功，3-提现失败，4-已关闭',
    `withdraw_time` DATETIME DEFAULT NULL COMMENT '提现成功时间',
    `settle_date` DATE DEFAULT NULL COMMENT '会计日期',
    `channel_order_no` VARCHAR(64) DEFAULT NULL COMMENT '渠道订单号',
    `channel_status` VARCHAR(32) DEFAULT NULL COMMENT '渠道返回状态',
    `reject_reason` VARCHAR(256) DEFAULT NULL COMMENT '拒绝原因',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_withdraw_no` (`withdraw_no`),
    KEY `idx_user_no` (`user_no`),
    KEY `idx_status` (`status`),
    KEY `idx_settle_date` (`settle_date`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提现订单表';

-- 3.5 转账订单表
CREATE TABLE `transfer_order` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `transfer_no` VARCHAR(32) NOT NULL COMMENT '转账订单号',
    `from_user_no` VARCHAR(32) NOT NULL COMMENT '付款用户编号',
    `to_user_no` VARCHAR(32) NOT NULL COMMENT '收款用户编号',
    `transfer_type` TINYINT NOT NULL DEFAULT 1 COMMENT '转账类型：1-普通转账，2-红包，3-AA收款',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '转账金额',
    `fee_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '手续费',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待处理，1-处理中，2-转账成功，3-转账失败',
    `transfer_time` DATETIME DEFAULT NULL COMMENT '转账成功时间',
    `settle_date` DATE DEFAULT NULL COMMENT '会计日期',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_transfer_no` (`transfer_no`),
    KEY `idx_from_user` (`from_user_no`),
    KEY `idx_to_user` (`to_user_no`),
    KEY `idx_status` (`status`),
    KEY `idx_settle_date` (`settle_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='转账订单表';

-- ============================================================================
-- 4. 记账核心表（复式记账）
-- ============================================================================

-- 4.1 会计分录表（记录每笔交易的借贷分录）
CREATE TABLE `accounting_entry` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `entry_no` VARCHAR(32) NOT NULL COMMENT '分录编号',
    `biz_type` TINYINT NOT NULL COMMENT '业务类型：1-支付，2-退款，3-充值，4-提现，5-转账，6-结算，7-清分，8-手续费',
    `biz_order_no` VARCHAR(32) NOT NULL COMMENT '业务订单号（支付单号/退款单号等）',
    `biz_sub_order_no` VARCHAR(32) DEFAULT NULL COMMENT '业务子订单号（用于一笔业务多次记账）',
    `entry_date` DATE NOT NULL COMMENT '会计日期',
    `entry_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记账时间',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `total_amount` DECIMAL(20,2) NOT NULL COMMENT '分录总金额',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-待记账，2-已记账，3-记账失败，4-已冲正',
    `check_status` TINYINT NOT NULL DEFAULT 0 COMMENT '试算平衡状态：0-未校验，1-平衡，2-不平衡',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '操作人',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `extend_info` JSON DEFAULT NULL COMMENT '扩展信息',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_entry_no` (`entry_no`),
    KEY `idx_biz_order` (`biz_type`, `biz_order_no`),
    KEY `idx_entry_date` (`entry_date`),
    KEY `idx_status` (`status`),
    KEY `idx_check_status` (`check_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会计分录表';

-- 4.2 会计分录明细表（借贷明细）
CREATE TABLE `accounting_entry_detail` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `entry_no` VARCHAR(32) NOT NULL COMMENT '分录编号',
    `detail_seq` INT NOT NULL COMMENT '明细序号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `subject_code` VARCHAR(32) NOT NULL COMMENT '会计科目代码',
    `direction` TINYINT NOT NULL COMMENT '借贷方向：1-借方(DEBIT)，2-贷方(CREDIT)',
    `amount` DECIMAL(20,2) NOT NULL COMMENT '金额',
    `balance_before` DECIMAL(20,2) DEFAULT NULL COMMENT '记账前余额',
    `balance_after` DECIMAL(20,2) DEFAULT NULL COMMENT '记账后余额',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `summary` VARCHAR(256) DEFAULT NULL COMMENT '摘要',
    `counter_account_no` VARCHAR(32) DEFAULT NULL COMMENT '对方账户编号',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_entry_no` (`entry_no`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_subject_code` (`subject_code`),
    KEY `idx_direction` (`direction`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会计分录明细表';

-- 4.3 流水表（记录所有资金变动流水）
CREATE TABLE `account_flow` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `flow_no` VARCHAR(32) NOT NULL COMMENT '流水编号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `biz_type` TINYINT NOT NULL COMMENT '业务类型：1-支付，2-退款，3-充值，4-提现，5-转账，6-结算，7-清分，8-手续费，9-调账',
    `biz_order_no` VARCHAR(32) NOT NULL COMMENT '业务订单号',
    `entry_no` VARCHAR(32) DEFAULT NULL COMMENT '关联的分录编号',
    `direction` TINYINT NOT NULL COMMENT '资金方向：1-收入，2-支出',
    `amount` DECIMAL(20,2) NOT NULL COMMENT '金额',
    `balance_before` DECIMAL(20,2) NOT NULL COMMENT '变动前余额',
    `balance_after` DECIMAL(20,2) NOT NULL COMMENT '变动后余额',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `summary` VARCHAR(256) DEFAULT NULL COMMENT '摘要',
    `counter_account_no` VARCHAR(32) DEFAULT NULL COMMENT '对方账户编号',
    `counter_account_name` VARCHAR(128) DEFAULT NULL COMMENT '对方账户名称',
    `channel` VARCHAR(32) DEFAULT NULL COMMENT '渠道',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '操作人',
    `client_ip` VARCHAR(32) DEFAULT NULL COMMENT '客户端IP',
    `device_info` VARCHAR(128) DEFAULT NULL COMMENT '设备信息',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `extend_info` JSON DEFAULT NULL COMMENT '扩展信息',
    `is_buffered` TINYINT NOT NULL DEFAULT 0 COMMENT '是否缓冲记账：0-否，1-是',
    `buffer_batch_no` VARCHAR(32) DEFAULT NULL COMMENT '缓冲记账批次号',
    `accounting_status` TINYINT NOT NULL DEFAULT 0 COMMENT '记账状态：0-未记账，1-已记账，2-记账失败',
    `accounting_time` DATETIME DEFAULT NULL COMMENT '记账时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_flow_no` (`flow_no`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_biz_order` (`biz_type`, `biz_order_no`),
    KEY `idx_entry_no` (`entry_no`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_accounting_status` (`accounting_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资金流水表';

-- 4.4 缓冲记账批次表
CREATE TABLE `buffer_accounting_batch` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `batch_no` VARCHAR(32) NOT NULL COMMENT '批次编号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `total_amount` DECIMAL(20,2) NOT NULL COMMENT '批次总金额',
    `total_count` INT NOT NULL DEFAULT 0 COMMENT '流水总数',
    `net_amount` DECIMAL(20,2) NOT NULL COMMENT '轧差后净额（正数为收入，负数为支出）',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待处理，1-处理中，2-已完成，3-失败',
    `start_time` DATETIME NOT NULL COMMENT '流水开始时间',
    `end_time` DATETIME NOT NULL COMMENT '流水结束时间',
    `accounting_time` DATETIME DEFAULT NULL COMMENT '记账时间',
    `entry_no` VARCHAR(32) DEFAULT NULL COMMENT '生成的分录编号',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '操作人',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_batch_no` (`batch_no`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='缓冲记账批次表';

-- ============================================================================
-- 5. 清结算表
-- ============================================================================

-- 5.1 清分明细表（对支付订单进行清分）
CREATE TABLE `clearing_detail` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `clearing_no` VARCHAR(32) NOT NULL COMMENT '清分编号',
    `order_no` VARCHAR(32) NOT NULL COMMENT '支付订单号',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `order_amount` DECIMAL(15,2) NOT NULL COMMENT '订单金额',
    `platform_fee` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '平台手续费',
    `channel_fee` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '渠道手续费',
    `merchant_settle_amount` DECIMAL(15,2) NOT NULL COMMENT '商户结算金额',
    `profit_sharing_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '分润金额（大商户场景）',
    `clearing_rule` VARCHAR(256) DEFAULT NULL COMMENT '清分规则',
    `clearing_date` DATE NOT NULL COMMENT '清分日期',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待清分，1-已清分，2-清分失败',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_clearing_no` (`clearing_no`),
    KEY `idx_order_no` (`order_no`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_clearing_date` (`clearing_date`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='清分明细表';

-- 5.2 商户结算单表
CREATE TABLE `merchant_settlement` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `settlement_no` VARCHAR(32) NOT NULL COMMENT '结算单号',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `settlement_cycle` TINYINT NOT NULL COMMENT '结算周期：1-T+0，2-T+1，3-T+7',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `start_date` DATE NOT NULL COMMENT '结算开始日期',
    `end_date` DATE NOT NULL COMMENT '结算结束日期',
    `total_order_count` INT NOT NULL DEFAULT 0 COMMENT '订单总数',
    `total_order_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '订单总金额',
    `total_refund_count` INT NOT NULL DEFAULT 0 COMMENT '退款总数',
    `total_refund_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '退款总金额',
    `total_fee` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '手续费总额',
    `settle_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '应结算金额',
    `actual_settle_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '实际结算金额',
    `adjust_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '调整金额',
    `settle_type` TINYINT NOT NULL DEFAULT 1 COMMENT '结算类型：1-结算到余额，2-结算到卡',
    `bank_card_no` VARCHAR(32) DEFAULT NULL COMMENT '结算银行卡号',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待结算，1-结算中，2-结算成功，3-结算失败，4-已打款',
    `settle_time` DATETIME DEFAULT NULL COMMENT '结算时间',
    `channel_order_no` VARCHAR(64) DEFAULT NULL COMMENT '渠道打款单号',
    `channel_status` VARCHAR(32) DEFAULT NULL COMMENT '渠道返回状态',
    `fail_reason` VARCHAR(256) DEFAULT NULL COMMENT '失败原因',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '操作人',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_settlement_no` (`settlement_no`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_settlement_cycle` (`settlement_cycle`),
    KEY `idx_status` (`status`),
    KEY `idx_end_date` (`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户结算单表';

-- 5.3 结算单明细表
CREATE TABLE `merchant_settlement_detail` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `settlement_no` VARCHAR(32) NOT NULL COMMENT '结算单号',
    `order_no` VARCHAR(32) NOT NULL COMMENT '支付订单号',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `order_amount` DECIMAL(15,2) NOT NULL COMMENT '订单金额',
    `refund_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '退款金额',
    `fee_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '手续费',
    `settle_amount` DECIMAL(15,2) NOT NULL COMMENT '结算金额',
    `trade_date` DATE NOT NULL COMMENT '交易日期',
    `settle_date` DATE NOT NULL COMMENT '结算日期',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_settlement_no` (`settlement_no`),
    KEY `idx_order_no` (`order_no`),
    KEY `idx_merchant_no` (`merchant_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='结算单明细表';

-- ============================================================================
-- 6. 渠道对账表
-- ============================================================================

-- 6.1 渠道清算信息表
CREATE TABLE `channel_clearing_file` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `file_no` VARCHAR(32) NOT NULL COMMENT '文件编号',
    `channel` VARCHAR(32) NOT NULL COMMENT '渠道标识',
    `clearing_date` DATE NOT NULL COMMENT '清算日期',
    `file_type` TINYINT NOT NULL DEFAULT 1 COMMENT '文件类型：1-支付清算，2-退款清算，3-汇总对账单',
    `file_path` VARCHAR(256) NOT NULL COMMENT '文件存储路径',
    `file_status` TINYINT NOT NULL DEFAULT 0 COMMENT '文件状态：0-待下载，1-已下载，2-解析中，3-解析完成，4-解析失败',
    `total_amount` DECIMAL(20,2) DEFAULT NULL COMMENT '文件总金额',
    `total_count` INT DEFAULT NULL COMMENT '文件总笔数',
    `download_time` DATETIME DEFAULT NULL COMMENT '下载时间',
    `parse_time` DATETIME DEFAULT NULL COMMENT '解析完成时间',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_file_no` (`file_no`),
    UNIQUE KEY `uk_channel_date_type` (`channel`, `clearing_date`, `file_type`),
    KEY `idx_file_status` (`file_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道清算文件表';

-- 6.2 渠道清算明细表
CREATE TABLE `channel_clearing_detail` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `file_no` VARCHAR(32) NOT NULL COMMENT '文件编号',
    `channel_order_no` VARCHAR(64) NOT NULL COMMENT '渠道订单号',
    `channel` VARCHAR(32) NOT NULL COMMENT '渠道标识',
    `biz_type` TINYINT NOT NULL COMMENT '业务类型：1-支付，2-退款',
    `our_order_no` VARCHAR(32) DEFAULT NULL COMMENT '我方订单号（匹配后填充）',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '金额',
    `fee_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '渠道手续费',
    `net_amount` DECIMAL(15,2) NOT NULL COMMENT '净额',
    `trade_time` DATETIME DEFAULT NULL COMMENT '交易时间',
    `clearing_date` DATE NOT NULL COMMENT '清算日期',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待对账，1-对账成功，2-长款，3-短款，4-金额不符',
    `diff_amount` DECIMAL(15,2) DEFAULT NULL COMMENT '差异金额',
    `diff_reason` VARCHAR(256) DEFAULT NULL COMMENT '差异原因',
    `handle_status` TINYINT NOT NULL DEFAULT 0 COMMENT '处理状态：0-待处理，1-已处理，2-挂起',
    `handle_result` VARCHAR(256) DEFAULT NULL COMMENT '处理结果',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_file_no` (`file_no`),
    KEY `idx_channel_order` (`channel`, `channel_order_no`),
    KEY `idx_our_order` (`our_order_no`),
    KEY `idx_clearing_date` (`clearing_date`),
    KEY `idx_status` (`status`),
    KEY `idx_handle_status` (`handle_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道清算明细表';

-- 6.3 对账结果表（三方对账结果）
CREATE TABLE `reconciliation_result` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `reconcile_no` VARCHAR(32) NOT NULL COMMENT '对账编号',
    `channel` VARCHAR(32) NOT NULL COMMENT '渠道标识',
    `reconcile_date` DATE NOT NULL COMMENT '对账日期',
    `reconcile_type` TINYINT NOT NULL COMMENT '对账类型：1-明细对账，2-账单对账，3-账实对账',
    `our_total_count` INT NOT NULL DEFAULT 0 COMMENT '我方总笔数',
    `our_total_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '我方总金额',
    `channel_total_count` INT NOT NULL DEFAULT 0 COMMENT '渠道总笔数',
    `channel_total_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '渠道总金额',
    `success_count` INT NOT NULL DEFAULT 0 COMMENT '成功对账笔数',
    `success_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '成功对账金额',
    `long_count` INT NOT NULL DEFAULT 0 COMMENT '长款笔数',
    `long_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '长款金额',
    `short_count` INT NOT NULL DEFAULT 0 COMMENT '短款笔数',
    `short_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '短款金额',
    `diff_count` INT NOT NULL DEFAULT 0 COMMENT '金额不符笔数',
    `diff_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '金额不符差额',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-对账中，1-对账完成，2-有差异，3-对账失败',
    `balance_status` TINYINT NOT NULL DEFAULT 0 COMMENT '平衡状态：0-未校验，1-平衡，2-不平衡',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '操作人',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_reconcile_no` (`reconcile_no`),
    KEY `idx_channel_date` (`channel`, `reconcile_date`),
    KEY `idx_reconcile_type` (`reconcile_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对账结果表';

-- 6.4 差异处理表
CREATE TABLE `reconciliation_diff` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `diff_no` VARCHAR(32) NOT NULL COMMENT '差异编号',
    `reconcile_no` VARCHAR(32) NOT NULL COMMENT '对账编号',
    `channel` VARCHAR(32) NOT NULL COMMENT '渠道标识',
    `diff_type` TINYINT NOT NULL COMMENT '差异类型：1-长款，2-短款，3-金额不符',
    `our_order_no` VARCHAR(32) DEFAULT NULL COMMENT '我方订单号',
    `channel_order_no` VARCHAR(64) NOT NULL COMMENT '渠道订单号',
    `our_amount` DECIMAL(15,2) DEFAULT NULL COMMENT '我方金额',
    `channel_amount` DECIMAL(15,2) NOT NULL COMMENT '渠道金额',
    `diff_amount` DECIMAL(15,2) NOT NULL COMMENT '差异金额',
    `diff_date` DATE NOT NULL COMMENT '差异日期',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待处理，1-处理中，2-已处理，3-已核销，4-已挂账',
    `handle_method` TINYINT DEFAULT NULL COMMENT '处理方式：1-补单，2-调账，3-退款，4-追款，5-核销',
    `handle_result` VARCHAR(512) DEFAULT NULL COMMENT '处理结果',
    `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
    `handler` VARCHAR(32) DEFAULT NULL COMMENT '处理人',
    `remark` VARCHAR(512) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_diff_no` (`diff_no`),
    KEY `idx_reconcile_no` (`reconcile_no`),
    KEY `idx_our_order` (`our_order_no`),
    KEY `idx_channel_order` (`channel`, `channel_order_no`),
    KEY `idx_diff_type` (`diff_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='差异处理表';

-- ============================================================================
-- 7. 日切与试算平衡表
-- ============================================================================

-- 7.1 会计日期表
CREATE TABLE `accounting_date` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `accounting_date` DATE NOT NULL COMMENT '会计日期',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-未日切，1-日切中，2-日切完成，3-日切失败',
    `switch_time` DATETIME DEFAULT NULL COMMENT '日切时间',
    `total_entry_count` INT DEFAULT NULL COMMENT '分录总数',
    `total_amount` DECIMAL(20,2) DEFAULT NULL COMMENT '总金额',
    `debit_total` DECIMAL(20,2) DEFAULT NULL COMMENT '借方总额',
    `credit_total` DECIMAL(20,2) DEFAULT NULL COMMENT '贷方总额',
    `balance_status` TINYINT DEFAULT NULL COMMENT '平衡状态：0-未校验，1-平衡，2-不平衡',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '操作人',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_accounting_date` (`accounting_date`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会计日期表';

-- 7.2 试算平衡表
CREATE TABLE `trial_balance` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `balance_no` VARCHAR(32) NOT NULL COMMENT '试算编号',
    `accounting_date` DATE NOT NULL COMMENT '会计日期',
    `subject_code` VARCHAR(32) NOT NULL COMMENT '科目代码',
    `subject_name` VARCHAR(128) NOT NULL COMMENT '科目名称',
    `opening_debit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '期初借方余额',
    `opening_credit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '期初贷方余额',
    `current_debit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '本期借方发生额',
    `current_credit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '本期贷方发生额',
    `closing_debit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '期末借方余额',
    `closing_credit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '期末贷方余额',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `balance_status` TINYINT NOT NULL DEFAULT 0 COMMENT '平衡状态：0-未校验，1-平衡，2-不平衡',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_balance_no` (`balance_no`),
    KEY `idx_accounting_date` (`accounting_date`),
    KEY `idx_subject_code` (`subject_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='试算平衡表';

-- ============================================================================
-- 8. 调账与冲正表
-- ============================================================================

-- 8.1 调账申请单表
CREATE TABLE `adjustment_apply` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `apply_no` VARCHAR(32) NOT NULL COMMENT '申请编号',
    `apply_type` TINYINT NOT NULL COMMENT '申请类型：1-差错调账，2-手工调账，3-冲正',
    `biz_type` TINYINT DEFAULT NULL COMMENT '关联业务类型',
    `biz_order_no` VARCHAR(32) DEFAULT NULL COMMENT '关联业务订单号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '调账账户编号',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `adjust_amount` DECIMAL(20,2) NOT NULL COMMENT '调账金额',
    `adjust_direction` TINYINT NOT NULL COMMENT '调整方向：1-调增，2-调减',
    `reason_type` TINYINT NOT NULL COMMENT '原因类型：1-系统差错，2-人工差错，3-渠道差错，4-其他',
    `reason_desc` VARCHAR(512) NOT NULL COMMENT '原因描述',
    `evidence` JSON DEFAULT NULL COMMENT '证明材料',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待审批，1-审批中，2-审批通过，3-审批拒绝，4-已调账',
    `approver` VARCHAR(32) DEFAULT NULL COMMENT '审批人',
    `approve_time` DATETIME DEFAULT NULL COMMENT '审批时间',
    `approve_remark` VARCHAR(256) DEFAULT NULL COMMENT '审批意见',
    `operator` VARCHAR(32) DEFAULT NULL COMMENT '申请人',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_apply_no` (`apply_no`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_biz_order` (`biz_type`, `biz_order_no`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调账申请单表';

-- 8.2 调账记录表
CREATE TABLE `adjustment_record` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `adjust_no` VARCHAR(32) NOT NULL COMMENT '调账编号',
    `apply_no` VARCHAR(32) NOT NULL COMMENT '申请编号',
    `account_no` VARCHAR(32) NOT NULL COMMENT '账户编号',
    `subject_code` VARCHAR(32) NOT NULL COMMENT '会计科目代码',
    `direction` TINYINT NOT NULL COMMENT '借贷方向：1-借方，2-贷方',
    `amount` DECIMAL(20,2) NOT NULL COMMENT '金额',
    `balance_before` DECIMAL(20,2) NOT NULL COMMENT '调账前余额',
    `balance_after` DECIMAL(20,2) NOT NULL COMMENT '调账后余额',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `summary` VARCHAR(256) NOT NULL COMMENT '摘要',
    `operator` VARCHAR(32) NOT NULL COMMENT '操作人',
    `entry_no` VARCHAR(32) DEFAULT NULL COMMENT '生成的分录编号',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_adjust_no` (`adjust_no`),
    KEY `idx_apply_no` (`apply_no`),
    KEY `idx_account_no` (`account_no`),
    KEY `idx_entry_no` (`entry_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调账记录表';

-- ============================================================================
-- 9. 辅助表
-- ============================================================================

-- 9.1 交易码配置表（用于驱动自动记账）
CREATE TABLE `trade_code_config` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `trade_code` VARCHAR(32) NOT NULL COMMENT '交易码',
    `trade_name` VARCHAR(128) NOT NULL COMMENT '交易名称',
    `biz_type` TINYINT NOT NULL COMMENT '业务类型',
    `scene_code` VARCHAR(32) NOT NULL COMMENT '场景代码',
    `entry_template` JSON NOT NULL COMMENT '分录模板（定义借贷方向和科目）',
    `allow_buffer` TINYINT NOT NULL DEFAULT 0 COMMENT '是否允许缓冲记账',
    `need_approval` TINYINT NOT NULL DEFAULT 0 COMMENT '是否需要审批',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-停用',
    `description` VARCHAR(256) DEFAULT NULL COMMENT '说明',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_trade_code` (`trade_code`),
    KEY `idx_biz_type` (`biz_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易码配置表';

-- 9.2 系统参数表
CREATE TABLE `system_parameter` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `param_key` VARCHAR(64) NOT NULL COMMENT '参数键',
    `param_value` TEXT NOT NULL COMMENT '参数值',
    `param_type` TINYINT NOT NULL DEFAULT 1 COMMENT '参数类型：1-字符串，2-数字，3-布尔，4-JSON',
    `category` VARCHAR(32) DEFAULT NULL COMMENT '分类',
    `description` VARCHAR(256) DEFAULT NULL COMMENT '说明',
    `is_editable` TINYINT NOT NULL DEFAULT 1 COMMENT '是否可编辑：0-否，1-是',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-停用',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_param_key` (`param_key`),
    KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统参数表';

-- ============================================================================
-- 初始化数据示例
-- ============================================================================

-- 插入示例会计科目
INSERT INTO `accounting_subject` (`subject_code`, `subject_name`, `parent_code`, `level`, `subject_type`, `balance_direction`, `status`, `description`) VALUES
('1001', '库存现金', NULL, 1, 1, 1, 1, '资产类科目'),
('1002', '银行存款', NULL, 1, 1, 1, 1, '资产类科目'),
('100201', '备付金存款', '1002', 2, 1, 1, 1, '在银行的备付金账户'),
('100202', '渠道待清算', '1002', 2, 1, 1, 1, '等待与渠道清算的资金'),
('100203', '渠道应清算', '1002', 2, 1, 1, 1, '应与渠道清算的资金'),
('100204', '银行头寸', '1002', 2, 1, 1, 1, '银行账户实际头寸'),
('2201', '应付商户款', NULL, 1, 2, 2, 1, '应付商户的结算款'),
('220101', '商户待结算户', '2201', 2, 2, 2, 1, '等待结算给商户的资金'),
('2202', '应付用户款', NULL, 1, 2, 2, 1, '应付用户的款项'),
('220201', '用户余额账户', '2202', 2, 2, 2, 1, '用户的余额账户'),
('2203', '支付网关过渡户', NULL, 1, 2, 2, 1, '支付网关的过渡账户'),
('2204', '提现过渡户', NULL, 1, 2, 2, 1, '提现业务的过渡账户'),
('2205', '退款过渡户', NULL, 1, 2, 2, 1, '退款业务的过渡账户'),
('6001', '手续费收入', NULL, 1, 5, 2, 1, '手续费收入科目');

-- 插入示例系统参数
INSERT INTO `system_parameter` (`param_key`, `param_value`, `param_type`, `category`, `description`, `is_editable`) VALUES
('DEFAULT_SETTLE_CYCLE', '1', 2, 'SETTLEMENT', '默认结算周期：1-T+0，2-T+1，3-T+7', 1),
('MIN_REFUND_AMOUNT', '1.00', 2, 'REFUND', '最小退款金额', 1),
('REFUND_EXPIRE_DAYS', '30', 2, 'REFUND', '退款有效期天数', 1),
('ENABLE_BUFFER_ACCOUNTING', 'true', 3, 'ACCOUNTING', '是否启用缓冲记账', 1),
('DAILY_CUTOFF_TIME', '23:59:59', 1, 'ACCOUNTING', '日切时间', 1);

-- ============================================================================
-- 10. 财务报表表（新增）
-- ============================================================================

-- 10.1 税务配置表（支持不同地区、不同业务类型的税率配置）
CREATE TABLE `tax_config` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `tax_code` VARCHAR(32) NOT NULL COMMENT '税码',
    `tax_name` VARCHAR(128) NOT NULL COMMENT '税种名称',
    `region_code` VARCHAR(16) NOT NULL COMMENT '地区代码',
    `business_type` TINYINT NOT NULL COMMENT '业务类型：1-商品销售，2-服务收入，3-手续费收入，4-其他',
    `tax_rate` DECIMAL(10,6) NOT NULL DEFAULT 0.000000 COMMENT '税率',
    `tax_type` TINYINT NOT NULL DEFAULT 1 COMMENT '税类型：1-增值税，2-消费税，3-营业税，4-所得税',
    `is_inclusive` TINYINT NOT NULL DEFAULT 0 COMMENT '是否含税：0-不含税，1-含税',
    `effective_date` DATE NOT NULL COMMENT '生效日期',
    `expiry_date` DATE DEFAULT NULL COMMENT '失效日期',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-停用',
    `description` VARCHAR(256) DEFAULT NULL COMMENT '说明',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tax_code_region` (`tax_code`, `region_code`),
    KEY `idx_business_type` (`business_type`),
    KEY `idx_effective_date` (`effective_date`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='税务配置表';

-- 10.2 税务明细表（记录每笔交易的税务信息）
CREATE TABLE `tax_detail` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `tax_no` VARCHAR(32) NOT NULL COMMENT '税务编号',
    `order_no` VARCHAR(32) NOT NULL COMMENT '关联订单号（支付/退款/充值等）',
    `order_type` TINYINT NOT NULL COMMENT '订单类型：1-支付，2-退款，3-充值，4-提现，5-转账',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `tax_code` VARCHAR(32) NOT NULL COMMENT '税码',
    `region_code` VARCHAR(16) NOT NULL COMMENT '地区代码',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `original_amount` DECIMAL(15,2) NOT NULL COMMENT '原始金额',
    `taxable_amount` DECIMAL(15,2) NOT NULL COMMENT '应税金额',
    `tax_rate` DECIMAL(10,6) NOT NULL DEFAULT 0.000000 COMMENT '税率',
    `tax_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '税额',
    `tax_inclusive_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '含税总额',
    `settle_date` DATE NOT NULL COMMENT '会计日期',
    `invoice_status` TINYINT NOT NULL DEFAULT 0 COMMENT '开票状态：0-未开票，1-已申请，2-已开票，3-已红冲',
    `invoice_no` VARCHAR(64) DEFAULT NULL COMMENT '发票号码',
    `invoice_time` DATETIME DEFAULT NULL COMMENT '开票时间',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tax_no` (`tax_no`),
    KEY `idx_order_no` (`order_no`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_settle_date` (`settle_date`),
    KEY `idx_invoice_status` (`invoice_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='税务明细表';

-- 10.3 税务汇总表（按日/月汇总，用于税率报表）
CREATE TABLE `tax_summary` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `summary_date` DATE NOT NULL COMMENT '汇总日期',
    `summary_period` TINYINT NOT NULL COMMENT '汇总周期：1-日，2-周，3-月，4-季，5-年',
    `region_code` VARCHAR(16) NOT NULL COMMENT '地区代码',
    `business_type` TINYINT NOT NULL COMMENT '业务类型',
    `tax_code` VARCHAR(32) NOT NULL COMMENT '税码',
    `tax_type` TINYINT NOT NULL COMMENT '税类型',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `total_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '交易总笔数',
    `total_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '交易总金额',
    `taxable_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '应税总金额',
    `tax_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '税额总计',
    `tax_inclusive_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '含税总额',
    `invoice_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '已开票金额',
    `uninvoiced_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '未开票金额',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_summary_date_region_tax` (`summary_date`, `summary_period`, `region_code`, `business_type`, `tax_code`),
    KEY `idx_summary_period` (`summary_period`),
    KEY `idx_summary_date` (`summary_date`),
    KEY `idx_business_type` (`business_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='税务汇总表';

-- 10.4 供应商信息表
CREATE TABLE `supplier` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `supplier_no` VARCHAR(32) NOT NULL COMMENT '供应商编号',
    `supplier_name` VARCHAR(128) NOT NULL COMMENT '供应商名称',
    `supplier_type` TINYINT NOT NULL DEFAULT 1 COMMENT '供应商类型：1-渠道商，2-服务商，3-技术提供商，4-其他',
    `contact_person` VARCHAR(64) DEFAULT NULL COMMENT '联系人',
    `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
    `contact_email` VARCHAR(128) DEFAULT NULL COMMENT '联系邮箱',
    `bank_account_name` VARCHAR(128) DEFAULT NULL COMMENT '银行账户名',
    `bank_card_no` VARCHAR(32) DEFAULT NULL COMMENT '银行卡号',
    `bank_name` VARCHAR(64) DEFAULT NULL COMMENT '开户行名称',
    `settle_cycle` TINYINT NOT NULL DEFAULT 1 COMMENT '结算周期：1-日结，2-周结，3-月结',
    `credit_limit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '信用额度',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-冻结，3-注销',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_supplier_no` (`supplier_no`),
    KEY `idx_supplier_type` (`supplier_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商信息表';

-- 10.5 供应商往来明细表（记录与供应商的每笔资金往来）
CREATE TABLE `supplier_transaction` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `transaction_no` VARCHAR(32) NOT NULL COMMENT '往来编号',
    `supplier_no` VARCHAR(32) NOT NULL COMMENT '供应商编号',
    `transaction_type` TINYINT NOT NULL COMMENT '往来类型：1-应付（借方），2-实付（贷方），3-调整',
    `related_order_no` VARCHAR(32) DEFAULT NULL COMMENT '关联订单号（清算单/结算单等）',
    `related_order_type` TINYINT DEFAULT NULL COMMENT '关联订单类型：1-清算单，2-结算单，3-调账单',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `amount` DECIMAL(20,2) NOT NULL COMMENT '金额（正数为应收/应付，负数为实收/实付）',
    `balance_after` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '往来后余额',
    `business_date` DATE NOT NULL COMMENT '业务日期',
    `settle_date` DATE NOT NULL COMMENT '会计日期',
    `due_date` DATE DEFAULT NULL COMMENT '到期日期',
    `payment_status` TINYINT NOT NULL DEFAULT 0 COMMENT '支付状态：0-未支付，1-部分支付，2-已支付，3-已核销',
    `payment_time` DATETIME DEFAULT NULL COMMENT '支付时间',
    `payment_method` TINYINT DEFAULT NULL COMMENT '支付方式：1-银行转账，2-支票，3-承兑汇票，4-其他',
    `remark` VARCHAR(256) DEFAULT NULL COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_transaction_no` (`transaction_no`),
    KEY `idx_supplier_no` (`supplier_no`),
    KEY `idx_transaction_type` (`transaction_type`),
    KEY `idx_business_date` (`business_date`),
    KEY `idx_payment_status` (`payment_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商往来明细表';

-- 10.6 供应商往来汇总表（用于供应商借贷报表）
CREATE TABLE `supplier_summary` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `summary_date` DATE NOT NULL COMMENT '汇总日期',
    `summary_period` TINYINT NOT NULL COMMENT '汇总周期：1-日，2-周，3-月，4-季，5-年',
    `supplier_no` VARCHAR(32) NOT NULL COMMENT '供应商编号',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `beginning_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '期初余额（正为应付，负为应收）',
    `debit_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '借方发生额（新增应付）',
    `credit_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '贷方发生额（实际支付）',
    `adjustment_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '调整金额',
    `ending_balance` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '期末余额',
    `overdue_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '逾期金额',
    `transaction_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '交易笔数',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_summary_date_supplier` (`summary_date`, `summary_period`, `supplier_no`),
    KEY `idx_summary_period` (`summary_period`),
    KEY `idx_summary_date` (`summary_date`),
    KEY `idx_supplier_no` (`supplier_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商往来汇总表';

-- 10.7 支付交易汇总表（用于支付报表）
CREATE TABLE `pay_transaction_summary` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `summary_date` DATE NOT NULL COMMENT '汇总日期',
    `summary_period` TINYINT NOT NULL COMMENT '汇总周期：1-小时，2-日，3-周，4-月，5-季，6-年',
    `merchant_no` VARCHAR(32) DEFAULT NULL COMMENT '商户编号（NULL 表示全平台汇总）',
    `pay_channel` VARCHAR(32) DEFAULT NULL COMMENT '支付渠道（NULL 表示全部渠道）',
    `trade_type` TINYINT DEFAULT NULL COMMENT '交易类型（NULL 表示全部类型）',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `success_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成功交易笔数',
    `failed_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '失败交易笔数',
    `processing_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '处理中交易笔数',
    `success_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '成功交易金额',
    `failed_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '失败交易金额',
    `refund_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '退款笔数',
    `refund_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '退款金额',
    `fee_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '手续费收入',
    `net_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '净结算金额（成功 - 退款 - 手续费）',
    `chargeback_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '拒付/退单笔数',
    `chargeback_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '拒付/退单金额',
    `success_rate` DECIMAL(10,6) NOT NULL DEFAULT 0.000000 COMMENT '成功率',
    `avg_transaction_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '平均交易金额',
    `peak_hour` TINYINT DEFAULT NULL COMMENT '交易高峰时段（0-23）',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_summary_date_channel` (`summary_date`, `summary_period`, `merchant_no`, `pay_channel`, `trade_type`, `currency`),
    KEY `idx_summary_period` (`summary_period`),
    KEY `idx_summary_date` (`summary_date`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_pay_channel` (`pay_channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付交易汇总表';

-- 10.8 渠道统计表（用于支付渠道分析报表）
CREATE TABLE `channel_statistics` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `statistics_date` DATE NOT NULL COMMENT '统计日期',
    `statistics_period` TINYINT NOT NULL COMMENT '统计周期：1-日，2-周，3-月，4-季，5-年',
    `pay_channel` VARCHAR(32) NOT NULL COMMENT '支付渠道',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `total_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '总交易笔数',
    `success_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成功笔数',
    `fail_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '失败笔数',
    `total_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '总金额',
    `success_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '成功金额',
    `channel_fee_rate` DECIMAL(10,6) NOT NULL DEFAULT 0.000000 COMMENT '渠道费率',
    `channel_fee_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '渠道手续费',
    `net_income` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '净收益（我方手续费 - 渠道手续费）',
    `avg_response_time_ms` INT NOT NULL DEFAULT 0 COMMENT '平均响应时间（毫秒）',
    `max_response_time_ms` INT NOT NULL DEFAULT 0 COMMENT '最大响应时间（毫秒）',
    `min_response_time_ms` INT NOT NULL DEFAULT 0 COMMENT '最小响应时间（毫秒）',
    `timeout_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '超时次数',
    `error_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '错误次数',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_statistics_date_channel` (`statistics_date`, `statistics_period`, `pay_channel`, `currency`),
    KEY `idx_statistics_period` (`statistics_period`),
    KEY `idx_statistics_date` (`statistics_date`),
    KEY `idx_pay_channel` (`pay_channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道统计表';

-- 10.9 销售统计表（用于销售报表）
CREATE TABLE `sales_statistics` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `statistics_date` DATE NOT NULL COMMENT '统计日期',
    `statistics_period` TINYINT NOT NULL COMMENT '统计周期：1-小时，2-日，3-周，4-月，5-季，6-年',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `product_category` VARCHAR(64) DEFAULT NULL COMMENT '商品类目（NULL 表示全部）',
    `region_code` VARCHAR(16) DEFAULT NULL COMMENT '地区代码（NULL 表示全部）',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `order_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单总数',
    `paid_order_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已支付订单数',
    `refunded_order_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已退款订单数',
    `gross_sales_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '销售总额（GMV）',
    `net_sales_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '销售净额（扣除退款）',
    `discount_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
    `platform_fee` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '平台服务费',
    `channel_fee` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '渠道手续费',
    `tax_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '税额',
    `settle_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '应结算金额',
    `actual_settle_amount` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '实际结算金额',
    `avg_order_value` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '客单价',
    `buyer_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '购买用户数',
    `new_buyer_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '新用户数',
    `repeat_buyer_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '复购用户数',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_statistics_date_merchant` (`statistics_date`, `statistics_period`, `merchant_no`, `product_category`, `region_code`, `currency`),
    KEY `idx_statistics_period` (`statistics_period`),
    KEY `idx_statistics_date` (`statistics_date`),
    KEY `idx_merchant_no` (`merchant_no`),
    KEY `idx_product_category` (`product_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售统计表';

-- 10.10 商户经营分析表（综合销售、费用、利润分析）
CREATE TABLE `merchant_business_analysis` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `analysis_date` DATE NOT NULL COMMENT '分析日期',
    `analysis_period` TINYINT NOT NULL COMMENT '分析周期：1-日，2-周，3-月，4-季，5-年',
    `merchant_no` VARCHAR(32) NOT NULL COMMENT '商户编号',
    `currency` CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    `gmv` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '商品交易总额',
    `net_revenue` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '净营收',
    `total_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '总成本',
    `channel_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '渠道成本',
    `platform_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '平台成本',
    `tax_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '税费成本',
    `refund_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '退款成本',
    `chargeback_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '拒付成本',
    `operating_cost` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '运营成本',
    `gross_profit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '毛利润',
    `net_profit` DECIMAL(20,2) NOT NULL DEFAULT 0.00 COMMENT '净利润',
    `gross_margin` DECIMAL(10,6) NOT NULL DEFAULT 0.000000 COMMENT '毛利率',
    `net_margin` DECIMAL(10,6) NOT NULL DEFAULT 0.000000 COMMENT '净利率',
    `order_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单数',
    `buyer_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '买家数',
    `avg_order_value` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '客单价',
    `customer_acquisition_cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '获客成本',
    `customer_lifetime_value` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '客户终身价值',
    `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '版本号（乐观锁）',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_analysis_date_merchant` (`analysis_date`, `analysis_period`, `merchant_no`, `currency`),
    KEY `idx_analysis_period` (`analysis_period`),
    KEY `idx_analysis_date` (`analysis_date`),
    KEY `idx_merchant_no` (`merchant_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户经营分析表';

-- 10.11 财务报表配置表（定义报表模板和维度）
CREATE TABLE `report_config` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `report_code` VARCHAR(32) NOT NULL COMMENT '报表编码',
    `report_name` VARCHAR(128) NOT NULL COMMENT '报表名称',
    `report_type` TINYINT NOT NULL COMMENT '报表类型：1-税率报表，2-供应商借贷报表，3-支付报表，4-销售报表，5-综合报表',
    `frequency` TINYINT NOT NULL COMMENT '生成频率：1-实时，2-小时，3-日，4-周，5-月，6-季，7-年',
    `dimensions` JSON DEFAULT NULL COMMENT '统计维度（如：商户、渠道、地区、时间等）',
    `metrics` JSON DEFAULT NULL COMMENT '统计指标（如：金额、笔数、费率等）',
    `filters` JSON DEFAULT NULL COMMENT '过滤条件',
    `output_format` VARCHAR(32) NOT NULL DEFAULT 'EXCEL' COMMENT '输出格式：EXCEL,CSV,PDF,HTML',
    `auto_generate` TINYINT NOT NULL DEFAULT 0 COMMENT '是否自动生成：0-否，1-是',
    `generate_time` TIME DEFAULT NULL COMMENT '定时生成时间',
    `recipients` JSON DEFAULT NULL COMMENT '接收人列表（邮箱/手机号）',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-停用',
    `description` VARCHAR(512) DEFAULT NULL COMMENT '报表说明',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_report_code` (`report_code`),
    KEY `idx_report_type` (`report_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='财务报表配置表';

-- 10.12 报表生成记录表
CREATE TABLE `report_generation_log` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `report_code` VARCHAR(32) NOT NULL COMMENT '报表编码',
    `report_name` VARCHAR(128) NOT NULL COMMENT '报表名称',
    `report_type` TINYINT NOT NULL COMMENT '报表类型',
    `period_start` DATE NOT NULL COMMENT '统计开始日期',
    `period_end` DATE NOT NULL COMMENT '统计结束日期',
    `generate_type` TINYINT NOT NULL COMMENT '生成类型：1-定时生成，2-手动生成',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-生成中，1-成功，2-失败',
    `file_path` VARCHAR(512) DEFAULT NULL COMMENT '文件存储路径',
    `file_size` BIGINT UNSIGNED DEFAULT NULL COMMENT '文件大小（字节）',
    `record_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '数据记录数',
    `error_message` VARCHAR(1024) DEFAULT NULL COMMENT '错误信息',
    `start_time` DATETIME NOT NULL COMMENT '开始生成时间',
    `end_time` DATETIME DEFAULT NULL COMMENT '完成时间',
    `duration_seconds` INT DEFAULT NULL COMMENT '耗时（秒）',
    `operator` VARCHAR(64) DEFAULT NULL COMMENT '操作人',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_report_code` (`report_code`),
    KEY `idx_report_type` (`report_type`),
    KEY `idx_period` (`period_start`, `period_end`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报表生成记录表';

-- 插入示例税务配置
INSERT INTO `tax_config` (`tax_code`, `tax_name`, `region_code`, `business_type`, `tax_rate`, `tax_type`, `is_inclusive`, `effective_date`, `status`, `description`) VALUES
('VAT_13', '增值税 13%', 'CN', 1, 0.130000, 1, 0, '2024-01-01', 1, '商品销售增值税'),
('VAT_6', '增值税 6%', 'CN', 2, 0.060000, 1, 0, '2024-01-01', 1, '服务收入增值税'),
('VAT_0', '零税率', 'CN', 1, 0.000000, 1, 0, '2024-01-01', 1, '出口商品零税率');

-- 插入示例报表配置
INSERT INTO `report_config` (`report_code`, `report_name`, `report_type`, `frequency`, `dimensions`, `metrics`, `output_format`, `auto_generate`, `generate_time`, `status`, `description`) VALUES
('TAX_DAILY', '税率日报表', 1, 3, '["region_code", "business_type", "tax_type"]', '["total_amount", "taxable_amount", "tax_amount", "invoice_amount"]', 'EXCEL', 1, '08:00:00', 1, '每日生成各地区的税务汇总报表'),
('SUPPLIER_LEDGER', '供应商借贷月报表', 2, 5, '["supplier_no", "transaction_type"]', '["beginning_balance", "debit_amount", "credit_amount", "ending_balance", "overdue_amount"]', 'EXCEL', 1, '09:00:00', 1, '每月生成供应商往来借贷明细报表'),
('PAY_CHANNEL_DAILY', '支付渠道日报表', 3, 3, '["pay_channel", "trade_type"]', '["success_count", "success_amount", "fee_amount", "success_rate"]', 'EXCEL', 1, '07:00:00', 1, '每日生成各支付渠道的交易统计报表'),
('SALES_MERCHANT_MONTHLY', '商户销售月报表', 4, 5, '["merchant_no", "product_category"]', '["gmv", "net_sales_amount", "order_count", "buyer_count", "avg_order_value"]', 'EXCEL', 1, '10:00:00', 1, '每月生成商户销售业绩报表');
