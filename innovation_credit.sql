/*
 Navicat Premium Dump SQL

 Source Server         : MySQL80
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : innovation_credit

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 13/03/2026 22:01:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for activity
-- ----------------------------
DROP TABLE IF EXISTS `activity`;
CREATE TABLE `activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动名称',
  `type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动类型',
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动级别',
  `organizer` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主办方',
  `start_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '拟认定学分',
  `college_id` bigint NULL DEFAULT NULL COMMENT '主办学院ID（校级活动为空）',
  `publish_status` tinyint NULL DEFAULT 0 COMMENT '发布状态：0-草稿，1-已发布',
  `entry_status` tinyint NULL DEFAULT 0 COMMENT '报名状态：0-未开始，1-进行中，2-已结束',
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `application_method` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `participation_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `application_deadline` datetime NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_activity_college_id`(`college_id` ASC) USING BTREE,
  CONSTRAINT `activity_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '创新活动表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity
-- ----------------------------
INSERT INTO `activity` VALUES (1, 'Python编程竞赛', '学科竞赛', '院级', '计算机科学与技术学院', '2026-04-01 09:00:00', '2026-04-30 18:00:00', 0.5, 1, 1, 1, '面向全院学生的编程竞赛', '线上报名', '计科院在读学生', '2026-04-20 23:59:59', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity` VALUES (2, '电子设计竞赛', '学科竞赛', '校级', '电子信息工程学院', '2026-05-01 09:00:00', '2026-05-30 18:00:00', 1.0, 2, 1, 1, '校级电子设计竞赛', '线下报名', '全校理工科学生', '2026-04-25 23:59:59', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity` VALUES (3, '创业大赛', '创新创业', '院级', '工商管理学院', '2026-06-01 09:00:00', '2026-06-30 18:00:00', 1.5, 3, 1, 0, '院级创业大赛', '线上+线下', '工商院学生', '2026-05-20 23:59:59', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity` VALUES (4, '经典诵读比赛', '文化活动', '院级', '文学院', '2026-04-10 09:00:00', '2026-04-20 18:00:00', 0.3, 4, 1, 2, '经典诵读比赛', '线下报名', '文学院学生', '2026-04-05 23:59:59', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity` VALUES (5, '外语演讲比赛', '学科竞赛', '省级', '外国语学院', '2026-05-10 09:00:00', '2026-05-20 18:00:00', 1.0, 5, 1, 1, '省级外语演讲比赛', '线上报名', '外院学生', '2026-04-30 23:59:59', '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for activity_participant
-- ----------------------------
DROP TABLE IF EXISTS `activity_participant`;
CREATE TABLE `activity_participant`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NOT NULL,
  `activity_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动名称（冗余自activity表）',
  `activity_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动类型（冗余自activity表）',
  `activity_level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动级别（冗余自activity表）',
  `activity_credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '拟认定学分（冗余自activity表）',
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `class_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `college_id` bigint NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `college_id`(`college_id` ASC) USING BTREE,
  INDEX `idx_activity_participant_activity_id`(`activity_id` ASC) USING BTREE,
  INDEX `idx_activity_participant_student_id`(`student_id` ASC) USING BTREE,
  CONSTRAINT `activity_participant_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `activity_participant_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `activity_participant_ibfk_3` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '活动参与人员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity_participant
-- ----------------------------
INSERT INTO `activity_participant` VALUES (1, 1, 'Python编程竞赛', '学科竞赛', '院级', 0.5, '202201001', '张三', '计科2201', 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (2, 1, 'Python编程竞赛', '学科竞赛', '院级', 0.5, '202501003', '郑十一', '智能2501', 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (3, 2, '电子设计竞赛', '学科竞赛', '校级', 1.0, '202302001', '王五', '电信2301', 2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (4, 2, '电子设计竞赛', '学科竞赛', '校级', 1.0, '202602004', '蒋十七', '物联2601', 2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (5, 3, '创业大赛', '创新创业', '院级', 1.5, '202403001', '钱七', '营销2401', 3, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (6, 3, '创业大赛', '创新创业', '院级', 1.5, '202503003', '冯十三', '人力2501', 3, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (7, 4, '经典诵读比赛', '文化活动', '院级', 0.3, '202204002', '韩十九', '新闻2201', 4, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (8, 4, '经典诵读比赛', '文化活动', '院级', 0.3, '202404001', '周九', '文编2401', 4, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (9, 5, '外语演讲比赛', '学科竞赛', '省级', 1.0, '202305003', '杨二十', '法语2301', 5, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `activity_participant` VALUES (10, 5, '外语演讲比赛', '学科竞赛', '省级', 1.0, '202505002', '褚十五', '日语2501', 5, '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for audit_record
-- ----------------------------
DROP TABLE IF EXISTS `audit_record`;
CREATE TABLE `audit_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `application_id` bigint NOT NULL,
  `auditor_id` bigint NOT NULL,
  `auditor_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `audit_level` int NOT NULL,
  `audit_result` int NOT NULL,
  `audit_opinion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `audit_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_audit_record_application_id`(`application_id` ASC) USING BTREE,
  INDEX `idx_audit_record_auditor_id`(`auditor_id` ASC) USING BTREE,
  CONSTRAINT `audit_record_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `credit_application` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `audit_record_ibfk_2` FOREIGN KEY (`auditor_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `chk_audit_role` CHECK (`role` in (_utf8mb4'student',_utf8mb4'college',_utf8mb4'school'))
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of audit_record
-- ----------------------------

-- ----------------------------
-- Table structure for college
-- ----------------------------
DROP TABLE IF EXISTS `college`;
CREATE TABLE `college`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学院名称',
  `principal` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '负责人姓名',
  `contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学院信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of college
-- ----------------------------
INSERT INTO `college` VALUES (1, '计算机科学与技术学院', NULL, NULL, 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college` VALUES (2, '电子信息工程学院', NULL, NULL, 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college` VALUES (3, '工商管理学院', NULL, NULL, 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college` VALUES (4, '文学院', NULL, NULL, 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college` VALUES (5, '外国语学院', NULL, NULL, 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for college_notice
-- ----------------------------
DROP TABLE IF EXISTS `college_notice`;
CREATE TABLE `college_notice`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `credit` double NULL DEFAULT NULL,
  `college_id` bigint NOT NULL,
  `publish_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `expire_time` datetime NULL DEFAULT NULL,
  `publisher` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `publisher_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'published',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_college_notice_college_id`(`college_id` ASC) USING BTREE,
  INDEX `idx_college_notice_publish_time`(`publish_time` ASC) USING BTREE,
  INDEX `idx_college_notice_title`(`title` ASC) USING BTREE,
  CONSTRAINT `college_notice_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of college_notice
-- ----------------------------
INSERT INTO `college_notice` VALUES (1, '计科院2026年春季学科竞赛通知', '学院将组织Python编程竞赛，参与可获0.5学分', 0.5, 1, '2026-03-13 21:59:26', '2026-04-30 23:59:59', '01001', '张老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (2, '计科院创新项目申报通知', '2026年学院创新项目申报开始，立项可获1学分', 1, 1, '2026-03-13 21:59:26', '2026-05-20 23:59:59', '01001', '张老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (3, '计科院学术讲座通知（人工智能）', '邀请校外专家开展AI讲座，参与可获0.2学分', 0.2, 1, '2026-03-13 21:59:26', '2026-04-15 23:59:59', '01001', '张老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (4, '计科院毕业设计创新加分通知', '优秀毕业设计可额外获0.3创新学分', 0.3, 1, '2026-03-13 21:59:26', '2026-06-20 23:59:59', '01001', '张老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (5, '电信院电子设计竞赛通知', '学院电子设计竞赛报名开始，参与可获0.8学分', 0.8, 2, '2026-03-13 21:59:26', '2026-05-10 23:59:59', '02001', '李老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (6, '电信院实验室开放通知', '暑期实验室开放，参与实践可获0.4学分', 0.4, 2, '2026-03-13 21:59:26', '2026-08-20 23:59:59', '02001', '李老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (7, '电信院校企合作项目通知', '与华为合作项目招募，参与可获1.2学分', 1.2, 2, '2026-03-13 21:59:26', '2026-04-25 23:59:59', '02001', '李老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (8, '电信院专利申报指导通知', '开展专利申报培训，申报成功可获2学分', 2, 2, '2026-03-13 21:59:26', '2026-07-10 23:59:59', '02001', '李老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (9, '工商院创业大赛通知', '学院创业大赛报名，获奖可获1.5学分', 1.5, 3, '2026-03-13 21:59:26', '2026-05-30 23:59:59', '03001', '王老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (10, '工商院企业实习通知', '暑期企业实习报名，实习合格可获1学分', 1, 3, '2026-03-13 21:59:26', '2026-08-15 23:59:59', '03001', '王老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (11, '工商院商务谈判大赛通知', '商务谈判大赛，参与可获0.6学分', 0.6, 3, '2026-03-13 21:59:26', '2026-04-20 23:59:59', '03001', '王老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (12, '工商院案例分析大赛通知', '案例分析大赛报名，获奖可获0.9学分', 0.9, 3, '2026-03-13 21:59:26', '2026-06-15 23:59:59', '03001', '王老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (13, '文学院征文比赛通知', '校级征文比赛报名，获奖可获0.7学分', 0.7, 4, '2026-03-13 21:59:26', '2026-05-05 23:59:59', '04001', '赵老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (14, '文学院经典诵读比赛通知', '经典诵读比赛，参与可获0.3学分', 0.3, 4, '2026-03-13 21:59:26', '2026-04-10 23:59:59', '04001', '赵老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (15, '文学院学术论文征集通知', '学术论文征集，发表可获1.8学分', 1.8, 4, '2026-03-13 21:59:26', '2026-07-20 23:59:59', '04001', '赵老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (16, '文学院非遗调研通知', '非遗调研项目招募，参与可获1.1学分', 1.1, 4, '2026-03-13 21:59:26', '2026-06-05 23:59:59', '04001', '赵老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (17, '外院外语演讲比赛通知', '省级外语演讲比赛报名，获奖可获1.0学分', 1, 5, '2026-03-13 21:59:26', '2026-05-15 23:59:59', '05001', '钱老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (18, '外院翻译大赛通知', '全国翻译大赛报名，参与可获0.8学分', 0.8, 5, '2026-03-13 21:59:26', '2026-04-05 23:59:59', '05001', '钱老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (19, '外院海外交流项目通知', '暑期海外交流项目，参与可获2.0学分', 2, 5, '2026-03-13 21:59:26', '2026-07-05 23:59:59', '05001', '钱老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `college_notice` VALUES (20, '外院双语主持大赛通知', '双语主持大赛，获奖可获0.7学分', 0.7, 5, '2026-03-13 21:59:26', '2026-06-30 23:59:59', '05001', '钱老师', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for credit_application
-- ----------------------------
DROP TABLE IF EXISTS `credit_application`;
CREATE TABLE `credit_application`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学号',
  `activity_id` bigint NULL DEFAULT NULL,
  `activity_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `activity_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `organizer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `participation_time` datetime NULL DEFAULT NULL,
  `apply_credit` double NOT NULL COMMENT '申请学分',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `proof_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `audit_status` int NULL DEFAULT 0 COMMENT '审核状态：0-待审核，1-审核中，2-通过，3-驳回',
  `audit_level` int NULL DEFAULT NULL COMMENT '当前审核级别：1-学院，2-学校',
  `college_id` bigint NULL DEFAULT NULL,
  `college_auditor_username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学院审批人账号（关联user表username）',
  `school_auditor_username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学校审批人账号（关联user表username）',
  `college_audit_time` datetime NULL DEFAULT NULL COMMENT '学院审批时间',
  `college_audit_opinion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '学院审批意见',
  `school_audit_time` datetime NULL DEFAULT NULL COMMENT '学校审批时间',
  `school_audit_opinion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '学校审批意见',
  `audit_time` datetime NULL DEFAULT NULL,
  `audit_opinion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `apply_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `status` int NULL DEFAULT 0 COMMENT '最终状态：0-进行中，1-完成，2-终止',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_credit_application_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_credit_application_activity_id`(`activity_id` ASC) USING BTREE,
  INDEX `idx_credit_application_college_id`(`college_id` ASC) USING BTREE,
  INDEX `idx_college_auditor_username`(`college_auditor_username` ASC) USING BTREE,
  INDEX `idx_school_auditor_username`(`school_auditor_username` ASC) USING BTREE,
  CONSTRAINT `credit_application_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `credit_application_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `credit_application_ibfk_3` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学分申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of credit_application
-- ----------------------------
INSERT INTO `credit_application` VALUES (1, '202201001', NULL, '全国大学生数学建模竞赛（校外）', '学科竞赛', '国家级', '中国工业与应用数学学会', '2026-02-15 10:00:00', 3, '参赛选手', '/uploads/proof/202201001_ext.pdf', 0, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 18:00:00', 0, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (2, '202302001', NULL, '全国大学生电子设计竞赛（校外）', '学科竞赛', '国家级', '教育部高等学校电子信息类专业教学指导委员会', '2026-01-10 10:00:00', 4, '团队队长', '/uploads/proof/202302001_ext.pdf', 2, 2, 2, '02001', 'admin', '2026-02-11 10:00:00', '学院审核通过，推荐至学校', '2026-02-12 14:00:00', '学校审核通过，认定4学分', NULL, NULL, '2026-02-10 18:00:00', 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (3, '202403001', NULL, '全国大学生创新创业训练计划（校外）', '科研创新', '国家级', '教育部高等教育司', '2026-01-15 10:00:00', 2, '项目成员', '/uploads/proof/202403001_ext.pdf', 3, 1, 3, '03001', NULL, '2026-02-16 11:00:00', '项目证明材料不全，驳回重新提交', NULL, NULL, NULL, NULL, '2026-02-15 19:00:00', 2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (4, '202204002', NULL, '全国大学生文学作品大赛（校外）', '文化活动', '国家级', '中国作家协会', '2026-01-20 10:00:00', 1.5, '参赛选手', '/uploads/proof/202204002_ext.pdf', 3, 2, 4, '04001', 'admin', '2026-02-21 14:00:00', '学院审核通过，推荐至学校', '2026-02-22 09:00:00', '获奖等级不符合学分认定标准，驳回', NULL, NULL, '2026-02-20 20:00:00', 2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (5, '202305003', NULL, '全国大学生英语竞赛（校外）', '学科竞赛', '国家级', '高等学校大学外语教学指导委员会', '2026-03-05 10:00:00', 2, '参赛选手', '/uploads/proof/202305003_ext.pdf', 1, 1, 5, '05001', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-15 17:00:00', 0, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (6, '202405001', NULL, '全国大学生翻译大赛（校外）', '学科竞赛', '国家级', '中国翻译协会', '2026-01-25 10:00:00', 3, '一等奖', '/uploads/proof/202405001_ext.pdf', 2, 2, 5, '05001', 'admin', '2026-02-26 10:00:00', '学院审核通过，一等奖符合3学分标准', '2026-02-27 15:00:00', '学校复核通过，认定3学分', NULL, NULL, '2026-02-25 18:00:00', 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (7, '202501003', NULL, '全国大学生人工智能创新大赛（校外）', '学科竞赛', '国家级', '中国人工智能学会', '2026-03-10 10:00:00', 2.5, '参赛选手', '/uploads/proof/202501003_ext.pdf', 1, 2, 1, '01001', NULL, '2026-03-11 09:30:00', '学院审核通过，同意申报', NULL, NULL, NULL, NULL, '2026-03-10 18:30:00', 0, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (8, '202502003', NULL, '全国大学生自动化设计大赛（校外）', '学科竞赛', '国家级', '中国自动化学会', '2026-02-05 10:00:00', 2, '参赛选手', '/uploads/proof/202502003_ext.pdf', 3, 1, 2, '02001', NULL, '2026-02-06 11:00:00', '参赛证明为伪造，驳回申请', NULL, NULL, NULL, NULL, '2026-02-05 19:00:00', 2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (9, '202503003', NULL, '全国大学生人力资源管理案例大赛（校外）', '学科竞赛', '国家级', '中国人力资源开发研究会', '2026-01-30 10:00:00', 2, '团队成员', '/uploads/proof/202503003_ext.pdf', 2, 2, 3, '03001', 'admin', '2026-02-01 15:00:00', '跨专业参赛，学院同意申报', '2026-02-02 10:00:00', '学校审核通过，认定2学分', NULL, NULL, '2026-01-30 20:00:00', 1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `credit_application` VALUES (10, '202603004', NULL, '全国大学生财务管理创新大赛（校外）', '学科竞赛', '国家级', '中国会计学会', '2026-03-20 10:00:00', 1.5, '项目负责人', '/uploads/proof/202603004_ext.pdf', 0, 1, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-20 18:00:00', 0, '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for credit_rule
-- ----------------------------
DROP TABLE IF EXISTS `credit_rule`;
CREATE TABLE `credit_rule`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动类型（如学科竞赛、科研创新）',
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '级别（如国家级、省级、校级）',
  `rank_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '获奖名次（一等奖/二等奖/三等奖/优秀奖/参与奖）',
  `credit` decimal(3, 1) NOT NULL COMMENT '对应学分',
  `credit_upper` decimal(3, 1) NULL DEFAULT 0.0 COMMENT '该类型活动年度学分上限',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '规则说明',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-生效，0-失效',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 151 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学分认定规则表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of credit_rule
-- ----------------------------
INSERT INTO `credit_rule` VALUES (1, '学科竞赛', '院级', '参与奖', 0.2, 0.0, '院级学科竞赛参与即可获得，不设获奖要求', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (2, '学科竞赛', '院级', '优秀奖', 0.4, 0.0, '院级学科竞赛优秀奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (3, '学科竞赛', '院级', '三等奖', 0.6, 0.0, '院级学科竞赛三等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (4, '学科竞赛', '院级', '二等奖', 0.8, 0.0, '院级学科竞赛二等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (5, '学科竞赛', '院级', '一等奖', 1.0, 0.0, '院级学科竞赛一等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (6, '学科竞赛', '校级', '参与奖', 0.8, 0.0, '校级学科竞赛参与即可获得，不设获奖要求', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (7, '学科竞赛', '校级', '优秀奖', 1.5, 0.0, '校级学科竞赛优秀奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (8, '学科竞赛', '校级', '三等奖', 2.5, 0.0, '校级学科竞赛三等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (9, '学科竞赛', '校级', '二等奖', 3.0, 0.0, '校级学科竞赛二等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (10, '学科竞赛', '校级', '一等奖', 4.0, 0.0, '校级学科竞赛一等奖，达到创新学分合格线（4.0分）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (11, '学科竞赛', '市级', '参与奖', 1.5, 0.0, '市级学科竞赛参与即可获得，不设获奖要求', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (12, '学科竞赛', '市级', '优秀奖', 2.0, 0.0, '市级学科竞赛优秀奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (13, '学科竞赛', '市级', '三等奖', 3.0, 0.0, '市级学科竞赛三等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (14, '学科竞赛', '市级', '二等奖', 3.5, 0.0, '市级学科竞赛二等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (15, '学科竞赛', '市级', '一等奖', 4.5, 0.0, '市级学科竞赛一等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (16, '学科竞赛', '省级', '参与奖', 2.0, 0.0, '省级学科竞赛参与即可获得，不设获奖要求', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (17, '学科竞赛', '省级', '优秀奖', 2.5, 0.0, '省级学科竞赛优秀奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (18, '学科竞赛', '省级', '三等奖', 3.5, 0.0, '省级学科竞赛三等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (19, '学科竞赛', '省级', '二等奖', 4.0, 0.0, '省级学科竞赛二等奖，达到创新学分合格线（4.0分）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (20, '学科竞赛', '省级', '一等奖', 5.0, 0.0, '省级学科竞赛一等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (21, '学科竞赛', '国家级', '参与奖', 2.5, 0.0, '国家级学科竞赛参与即可获得，不设获奖要求', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (22, '学科竞赛', '国家级', '优秀奖', 3.0, 0.0, '国家级学科竞赛优秀奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (23, '学科竞赛', '国家级', '三等奖', 4.0, 0.0, '国家级学科竞赛三等奖，达到创新学分合格线（4.0分）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (24, '学科竞赛', '国家级', '二等奖', 4.5, 0.0, '国家级学科竞赛二等奖', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (25, '学科竞赛', '国家级', '一等奖', 5.5, 0.0, '国家级学科竞赛一等奖，年度最高可认定6.0分', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (26, '科研创新', '院级', '参与奖', 0.2, 0.0, '院级科研立项/专利申报参与奖（固定0.2分），分值=学科竞赛×1.5', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (27, '科研创新', '院级', '优秀奖', 0.6, 0.0, '院级科研立项/专利申报优秀奖（0.4×1.5=0.6）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (28, '科研创新', '院级', '三等奖', 0.9, 0.0, '院级科研立项/专利申报三等奖（0.6×1.5=0.9）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (29, '科研创新', '院级', '二等奖', 1.2, 0.0, '院级科研立项/专利申报二等奖（0.8×1.5=1.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (30, '科研创新', '院级', '一等奖', 1.5, 0.0, '院级科研立项/专利申报一等奖（1.0×1.5=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (31, '科研创新', '校级', '参与奖', 1.2, 0.0, '校级科研立项/专利申报参与奖（0.8×1.5=1.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (32, '科研创新', '校级', '优秀奖', 2.3, 0.0, '校级科研立项/专利申报优秀奖（1.5×1.5=2.25→2.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (33, '科研创新', '校级', '三等奖', 3.8, 0.0, '校级科研立项/专利申报三等奖（2.5×1.5=3.75→3.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (34, '科研创新', '校级', '二等奖', 4.5, 0.0, '校级科研立项/专利申报二等奖（3.0×1.5=4.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (35, '科研创新', '校级', '一等奖', 6.0, 0.0, '校级科研创新一等奖（4.0×1.5=6.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (36, '科研创新', '市级', '参与奖', 2.3, 0.0, '市级科研立项/专利申报参与奖（1.5×1.5=2.25→2.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (37, '科研创新', '市级', '优秀奖', 3.0, 0.0, '市级科研立项/专利申报优秀奖（2.0×1.5=3.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (38, '科研创新', '市级', '三等奖', 4.5, 0.0, '市级科研立项/专利申报三等奖（3.0×1.5=4.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (39, '科研创新', '市级', '二等奖', 5.3, 0.0, '市级科研立项/专利申报二等奖（3.5×1.5=5.25→5.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (40, '科研创新', '市级', '一等奖', 6.8, 0.0, '市级科研创新一等奖（4.5×1.5=6.75→6.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (41, '科研创新', '省级', '参与奖', 3.0, 0.0, '省级科研立项/专利申报参与奖（2.0×1.5=3.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (42, '科研创新', '省级', '优秀奖', 3.8, 0.0, '省级科研立项/专利申报优秀奖（2.5×1.5=3.75→3.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (43, '科研创新', '省级', '三等奖', 5.3, 0.0, '省级科研立项/专利申报三等奖（3.5×1.5=5.25→5.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (44, '科研创新', '省级', '二等奖', 6.0, 0.0, '省级科研立项/专利申报二等奖（4.0×1.5=6.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (45, '科研创新', '省级', '一等奖', 7.5, 0.0, '省级科研创新一等奖（5.0×1.5=7.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (46, '科研创新', '国家级', '参与奖', 3.8, 0.0, '国家级科研立项/专利申报参与奖（2.5×1.5=3.75→3.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (47, '科研创新', '国家级', '优秀奖', 4.5, 0.0, '国家级科研立项/专利申报优秀奖（3.0×1.5=4.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (48, '科研创新', '国家级', '三等奖', 6.0, 0.0, '国家级科研立项/专利申报三等奖（4.0×1.5=6.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (49, '科研创新', '国家级', '二等奖', 6.8, 0.0, '国家级科研立项/专利申报二等奖（4.5×1.5=6.75→6.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (50, '科研创新', '国家级', '一等奖', 8.3, 0.0, '国家级科研创新一等奖（5.5×1.5=8.25→8.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (51, '学术论文', '院级', '参与奖', 0.2, 0.0, '院级论文征集参与奖（固定0.2分），分值=学科竞赛×1.5', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (52, '学术论文', '院级', '优秀奖', 0.6, 0.0, '院级论文征集优秀奖（0.4×1.5=0.6）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (53, '学术论文', '院级', '三等奖', 0.9, 0.0, '院级论文征集三等奖（0.6×1.5=0.9）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (54, '学术论文', '院级', '二等奖', 1.2, 0.0, '院级论文征集二等奖（0.8×1.5=1.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (55, '学术论文', '院级', '一等奖', 1.5, 0.0, '院级论文征集一等奖（1.0×1.5=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (56, '学术论文', '校级', '参与奖', 1.2, 0.0, '校级论文征集参与奖（0.8×1.5=1.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (57, '学术论文', '校级', '优秀奖', 2.3, 0.0, '校级论文征集优秀奖（1.5×1.5=2.25→2.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (58, '学术论文', '校级', '三等奖', 3.8, 0.0, '校级论文征集三等奖（2.5×1.5=3.75→3.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (59, '学术论文', '校级', '二等奖', 4.5, 0.0, '校级论文征集二等奖（3.0×1.5=4.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (60, '学术论文', '校级', '一等奖', 6.0, 0.0, '校级论文征集一等奖（4.0×1.5=6.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (61, '学术论文', '市级', '参与奖', 2.3, 0.0, '市级期刊论文投稿参与奖（1.5×1.5=2.25→2.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (62, '学术论文', '市级', '优秀奖', 3.0, 0.0, '市级期刊论文投稿优秀奖（2.0×1.5=3.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (63, '学术论文', '市级', '三等奖', 4.5, 0.0, '市级期刊论文投稿三等奖（3.0×1.5=4.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (64, '学术论文', '市级', '二等奖', 5.3, 0.0, '市级期刊论文投稿二等奖（3.5×1.5=5.25→5.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (65, '学术论文', '市级', '一等奖', 6.8, 0.0, '市级期刊论文投稿一等奖（4.5×1.5=6.75→6.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (66, '学术论文', '省级', '参与奖', 3.0, 0.0, '省级期刊论文投稿参与奖（2.0×1.5=3.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (67, '学术论文', '省级', '优秀奖', 3.8, 0.0, '省级期刊论文投稿优秀奖（2.5×1.5=3.75→3.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (68, '学术论文', '省级', '三等奖', 5.3, 0.0, '省级期刊论文投稿三等奖（3.5×1.5=5.25→5.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (69, '学术论文', '省级', '二等奖', 6.0, 0.0, '省级期刊论文投稿二等奖（4.0×1.5=6.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (70, '学术论文', '省级', '一等奖', 7.5, 0.0, '省级期刊论文投稿一等奖（5.0×1.5=7.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (71, '学术论文', '国家级', '参与奖', 3.8, 0.0, '核心期刊论文投稿参与奖（2.5×1.5=3.75→3.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (72, '学术论文', '国家级', '优秀奖', 4.5, 0.0, '核心期刊论文投稿优秀奖（3.0×1.5=4.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (73, '学术论文', '国家级', '三等奖', 6.0, 0.0, '核心期刊论文投稿三等奖（4.0×1.5=6.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (74, '学术论文', '国家级', '二等奖', 6.8, 0.0, '核心期刊论文投稿二等奖（4.5×1.5=6.75→6.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (75, '学术论文', '国家级', '一等奖', 8.3, 0.0, '核心期刊论文投稿一等奖（5.5×1.5=8.25→8.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (76, '社会实践', '院级', '参与奖', 0.1, 0.0, '院级社会实践参与奖，系数0.7（0.2×0.7≈0.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (77, '社会实践', '院级', '优秀奖', 0.3, 0.0, '院级社会实践优秀奖，系数0.7（0.4×0.7≈0.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (78, '社会实践', '院级', '三等奖', 0.4, 0.0, '院级社会实践三等奖，系数0.7（0.6×0.7≈0.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (79, '社会实践', '院级', '二等奖', 0.6, 0.0, '院级社会实践二等奖，系数0.7（0.8×0.7≈0.6）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (80, '社会实践', '院级', '一等奖', 0.7, 0.0, '院级社会实践一等奖，系数0.7（1.0×0.7=0.7）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (81, '社会实践', '校级', '参与奖', 0.6, 0.0, '校级社会实践参与奖，系数0.7（0.8×0.7≈0.6）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (82, '社会实践', '校级', '优秀奖', 1.1, 0.0, '校级社会实践优秀奖，系数0.7（1.5×0.7≈1.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (83, '社会实践', '校级', '三等奖', 1.8, 0.0, '校级社会实践三等奖，系数0.7（2.5×0.7≈1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (84, '社会实践', '校级', '二等奖', 2.1, 0.0, '校级社会实践二等奖，系数0.7（3.0×0.7=2.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (85, '社会实践', '校级', '一等奖', 2.8, 0.0, '校级社会实践一等奖，系数0.7（4.0×0.7=2.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (86, '社会实践', '市级', '参与奖', 1.1, 0.0, '市级社会实践参与奖，系数0.7（1.5×0.7≈1.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (87, '社会实践', '市级', '优秀奖', 1.4, 0.0, '市级社会实践优秀奖，系数0.7（2.0×0.7=1.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (88, '社会实践', '市级', '三等奖', 2.1, 0.0, '市级社会实践三等奖，系数0.7（3.0×0.7=2.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (89, '社会实践', '市级', '二等奖', 2.5, 0.0, '市级社会实践二等奖，系数0.7（3.5×0.7≈2.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (90, '社会实践', '市级', '一等奖', 3.2, 0.0, '市级社会实践一等奖，系数0.7（4.5×0.7≈3.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (91, '社会实践', '省级', '参与奖', 1.4, 0.0, '省级社会实践参与奖，系数0.7（2.0×0.7=1.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (92, '社会实践', '省级', '优秀奖', 1.8, 0.0, '省级社会实践优秀奖，系数0.7（2.5×0.7≈1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (93, '社会实践', '省级', '三等奖', 2.5, 0.0, '省级社会实践三等奖，系数0.7（3.5×0.7≈2.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (94, '社会实践', '省级', '二等奖', 2.8, 0.0, '省级社会实践二等奖，系数0.7（4.0×0.7=2.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (95, '社会实践', '省级', '一等奖', 3.5, 0.0, '省级社会实践一等奖，系数0.7（5.0×0.7=3.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (96, '社会实践', '国家级', '参与奖', 1.8, 0.0, '国家级社会实践参与奖，系数0.7（2.5×0.7≈1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (97, '社会实践', '国家级', '优秀奖', 2.1, 0.0, '国家级社会实践优秀奖，系数0.7（3.0×0.7=2.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (98, '社会实践', '国家级', '三等奖', 2.8, 0.0, '国家级社会实践三等奖，系数0.7（4.0×0.7=2.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (99, '社会实践', '国家级', '二等奖', 3.2, 0.0, '国家级社会实践二等奖，系数0.7（4.5×0.7≈3.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (100, '社会实践', '国家级', '一等奖', 3.9, 0.0, '国家级社会实践一等奖，系数0.7（5.5×0.7≈3.9）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (101, '技能证书', '院级', '参与奖', 0.1, 0.0, '院级技能认证参与奖，系数0.6（0.2×0.6=0.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:36:46');
INSERT INTO `credit_rule` VALUES (102, '技能证书', '院级', '优秀奖', 0.2, 0.0, '院级技能认证优秀奖，系数0.6（0.4×0.6=0.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:03');
INSERT INTO `credit_rule` VALUES (103, '技能证书', '院级', '三等奖', 0.4, 0.0, '院级技能认证三等奖，系数0.6（0.6×0.6=0.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:07');
INSERT INTO `credit_rule` VALUES (104, '技能证书', '院级', '二等奖', 0.5, 0.0, '院级技能认证二等奖，系数0.6（0.8×0.6≈0.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:14');
INSERT INTO `credit_rule` VALUES (105, '技能证书', '院级', '一等奖', 0.6, 0.0, '院级技能认证一等奖，系数0.6（1.0×0.6=0.6）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:16');
INSERT INTO `credit_rule` VALUES (106, '技能证书', '校级', '参与奖', 0.5, 0.0, '校级技能证书参与奖，系数0.6（0.8×0.6≈0.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:18');
INSERT INTO `credit_rule` VALUES (107, '技能证书', '校级', '优秀奖', 0.9, 0.0, '校级技能证书优秀奖，系数0.6（1.5×0.6=0.9）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:20');
INSERT INTO `credit_rule` VALUES (108, '技能证书', '校级', '三等奖', 1.5, 0.0, '校级技能证书三等奖，系数0.6（2.5×0.6=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:23');
INSERT INTO `credit_rule` VALUES (109, '技能证书', '校级', '二等奖', 1.8, 0.0, '校级技能证书二等奖，系数0.6（3.0×0.6=1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:25');
INSERT INTO `credit_rule` VALUES (110, '技能证书', '校级', '一等奖', 2.4, 0.0, '校级技能证书一等奖，系数0.6（4.0×0.6=2.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:27');
INSERT INTO `credit_rule` VALUES (111, '技能证书', '市级', '参与奖', 0.9, 0.0, '市级技能证书参与奖，系数0.6（1.5×0.6=0.9）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (112, '技能证书', '市级', '优秀奖', 1.2, 0.0, '市级技能证书优秀奖，系数0.6（2.0×0.6=1.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (113, '技能证书', '市级', '三等奖', 1.8, 0.0, '市级技能证书三等奖，系数0.6（3.0×0.6=1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (114, '技能证书', '市级', '二等奖', 2.1, 0.0, '市级技能证书二等奖，系数0.6（3.5×0.6≈2.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (115, '技能证书', '市级', '一等奖', 2.7, 0.0, '市级技能证书一等奖，系数0.6（4.5×0.6=2.7）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (116, '技能证书', '省级', '参与奖', 1.2, 0.0, '省级技能证书参与奖，系数0.6（2.0×0.6=1.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (117, '技能证书', '省级', '优秀奖', 1.5, 0.0, '省级技能证书优秀奖，系数0.6（2.5×0.6=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (118, '技能证书', '省级', '三等奖', 2.1, 0.0, '省级技能证书三等奖，系数0.6（3.5×0.6=2.1）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (119, '技能证书', '省级', '二等奖', 2.4, 0.0, '省级技能证书二等奖，系数0.6（4.0×0.6=2.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (120, '技能证书', '省级', '一等奖', 2.0, 0.0, '省级技能证书一等奖，系数0.6（5.0×0.6=3.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:36:32');
INSERT INTO `credit_rule` VALUES (121, '技能证书', '国家级', '参与奖', 1.5, 0.0, '国家级技能证书参与奖，系数0.6（2.5×0.6=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (122, '技能证书', '国家级', '优秀奖', 1.8, 0.0, '国家级技能证书优秀奖，系数0.6（3.0×0.6=1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (123, '技能证书', '国家级', '三等奖', 2.4, 0.0, '国家级技能证书三等奖，系数0.6（4.0×0.6=2.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (124, '技能证书', '国家级', '二等奖', 2.7, 0.0, '国家级技能证书二等奖，系数0.6（4.5×0.6=2.7）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (125, '技能证书', '国家级', '一等奖', 3.0, 0.0, '国家级技能证书一等奖，系数0.6（5.5×0.6=3.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:36:19');
INSERT INTO `credit_rule` VALUES (126, '其他', '院级', '参与奖', 0.2, 0.0, '未明确归类的其他活动参与奖（固定0.2分），系数0.5', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (127, '其他', '院级', '优秀奖', 0.2, 0.0, '未明确归类的其他活动优秀奖（0.4×0.5=0.2）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (128, '其他', '院级', '三等奖', 0.3, 0.0, '未明确归类的其他活动三等奖（0.6×0.5=0.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (129, '其他', '院级', '二等奖', 0.4, 0.0, '未明确归类的其他活动二等奖（0.8×0.5=0.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:35:21');
INSERT INTO `credit_rule` VALUES (130, '其他', '院级', '一等奖', 0.5, 0.0, '未明确归类的其他活动一等奖（1.0×0.5=0.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:13');
INSERT INTO `credit_rule` VALUES (131, '其他', '校级', '参与奖', 0.4, 0.0, '未明确归类的其他活动参与奖（0.8×0.5=0.4）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:10');
INSERT INTO `credit_rule` VALUES (132, '其他', '校级', '优秀奖', 0.8, 0.0, '未明确归类的其他活动优秀奖（1.5×0.5=0.75→0.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:09');
INSERT INTO `credit_rule` VALUES (133, '其他', '校级', '三等奖', 1.3, 0.0, '未明确归类的其他活动三等奖（2.5×0.5=1.25→1.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:07');
INSERT INTO `credit_rule` VALUES (134, '其他', '校级', '二等奖', 1.5, 0.0, '未明确归类的其他活动二等奖（3.0×0.5=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:04');
INSERT INTO `credit_rule` VALUES (135, '其他', '校级', '一等奖', 2.0, 0.0, '未明确归类的其他活动一等奖（4.0×0.5=2.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:03');
INSERT INTO `credit_rule` VALUES (136, '其他', '市级', '参与奖', 0.8, 0.0, '未明确归类的其他活动参与奖（1.5×0.5=0.75→0.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:02');
INSERT INTO `credit_rule` VALUES (137, '其他', '市级', '优秀奖', 1.0, 0.0, '未明确归类的其他活动优秀奖（2.0×0.5=1.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:38:00');
INSERT INTO `credit_rule` VALUES (138, '其他', '市级', '三等奖', 1.5, 0.0, '未明确归类的其他活动三等奖（3.0×0.5=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:58');
INSERT INTO `credit_rule` VALUES (139, '其他', '市级', '二等奖', 1.8, 0.0, '未明确归类的其他活动二等奖（3.5×0.5=1.75→1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:56');
INSERT INTO `credit_rule` VALUES (140, '其他', '市级', '一等奖', 2.3, 0.0, '未明确归类的其他活动一等奖（4.5×0.5=2.25→2.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:55');
INSERT INTO `credit_rule` VALUES (141, '其他', '省级', '参与奖', 1.0, 0.0, '未明确归类的其他活动参与奖（2.0×0.5=1.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:52');
INSERT INTO `credit_rule` VALUES (142, '其他', '省级', '优秀奖', 1.3, 0.0, '未明确归类的其他活动优秀奖（2.5×0.5=1.25→1.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:51');
INSERT INTO `credit_rule` VALUES (143, '其他', '省级', '三等奖', 1.8, 0.0, '未明确归类的其他活动三等奖（3.5×0.5=1.75→1.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:50');
INSERT INTO `credit_rule` VALUES (144, '其他', '省级', '二等奖', 2.0, 0.0, '未明确归类的其他活动二等奖（4.0×0.5=2.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:48');
INSERT INTO `credit_rule` VALUES (145, '其他', '省级', '一等奖', 2.5, 0.0, '未明确归类的其他活动一等奖（5.0×0.5=2.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:44');
INSERT INTO `credit_rule` VALUES (146, '其他', '国家级', '参与奖', 1.3, 0.0, '未明确归类的其他活动参与奖（2.5×0.5=1.25→1.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:46');
INSERT INTO `credit_rule` VALUES (147, '其他', '国家级', '优秀奖', 1.5, 0.0, '未明确归类的其他活动优秀奖（3.0×0.5=1.5）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:42');
INSERT INTO `credit_rule` VALUES (148, '其他', '国家级', '三等奖', 2.0, 0.0, '未明确归类的其他活动三等奖（4.0×0.5=2.0）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:40');
INSERT INTO `credit_rule` VALUES (149, '其他', '国家级', '二等奖', 2.3, 0.0, '未明确归类的其他活动二等奖（4.5×0.5=2.25→2.3）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:38');
INSERT INTO `credit_rule` VALUES (150, '其他', '国家级', '一等奖', 2.8, 0.0, '未明确归类的其他活动一等奖（5.5×0.5=2.75→2.8）', 1, '2026-03-13 15:35:21', '2026-03-13 15:37:37');

-- ----------------------------
-- Table structure for notice_read
-- ----------------------------
DROP TABLE IF EXISTS `notice_read`;
CREATE TABLE `notice_read`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notice_id` bigint NOT NULL,
  `notice_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `read_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_notice`(`student_id` ASC, `notice_id` ASC, `notice_type` ASC) USING BTREE,
  INDEX `idx_notice_read_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_notice_read_notice_id`(`notice_id` ASC) USING BTREE,
  INDEX `idx_notice_read_notice_type`(`notice_type` ASC) USING BTREE,
  CONSTRAINT `notice_read_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice_read
-- ----------------------------
INSERT INTO `notice_read` VALUES (1, '202201001', 1, 'school_notice', '2026-03-13 16:05:36', '2026-03-13 16:05:36', '2026-03-13 16:05:36');
INSERT INTO `notice_read` VALUES (2, '202302001', 2, 'school_notice', '2026-03-13 16:05:36', '2026-03-13 16:05:36', '2026-03-13 16:05:36');
INSERT INTO `notice_read` VALUES (3, '202403001', 1, 'college_notice', '2026-03-13 16:05:36', '2026-03-13 16:05:36', '2026-03-13 16:05:36');
INSERT INTO `notice_read` VALUES (4, '202504002', 4, 'college_notice', '2026-03-13 16:05:36', '2026-03-13 16:05:36', '2026-03-13 16:05:36');
INSERT INTO `notice_read` VALUES (5, '202602004', 5, 'college_notice', '2026-03-13 16:05:36', '2026-03-13 16:05:36', '2026-03-13 16:05:36');

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operator_id` bigint NULL DEFAULT NULL,
  `operator_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `operation_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_operation_log_operator_id`(`operator_id` ASC) USING BTREE,
  CONSTRAINT `operation_log_ibfk_1` FOREIGN KEY (`operator_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `chk_log_role` CHECK (`role` in (_utf8mb4'student',_utf8mb4'college',_utf8mb4'school'))
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, 1, '张老师', 'college', '2026-03-13 21:59:26', '发布通知', '发布计科院2026年春季学科竞赛通知', '192.168.1.101', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `operation_log` VALUES (2, 2, '李老师', 'college', '2026-03-13 21:59:26', '审核学分', '审核王五的校外电子设计竞赛学分申请', '192.168.1.102', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `operation_log` VALUES (3, 9, '系统管理员', 'school', '2026-03-13 21:59:26', '发布通知', '发布2026年创新学分认定工作通知', '192.168.1.100', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `operation_log` VALUES (4, 4, '赵老师', 'college', '2026-03-13 21:59:26', '审核学分', '审核韩十九的校外文学作品大赛学分申请', '192.168.1.104', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `operation_log` VALUES (5, 5, '钱老师', 'college', '2026-03-13 21:59:26', '发布通知', '发布外院外语演讲比赛通知', '192.168.1.105', '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for school_notice
-- ----------------------------
DROP TABLE IF EXISTS `school_notice`;
CREATE TABLE `school_notice`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `credit` double NULL DEFAULT NULL,
  `publish_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `expire_time` datetime NULL DEFAULT NULL,
  `publisher` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `publisher_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'published',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_school_notice_publish_time`(`publish_time` ASC) USING BTREE,
  INDEX `idx_school_notice_title`(`title` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of school_notice
-- ----------------------------
INSERT INTO `school_notice` VALUES (1, '2026年创新学分认定工作通知', '请各学院组织学生完成2026年度创新学分申报工作，申报截止日期为2026年6月30日。', 2, '2026-03-13 21:59:26', '2026-06-30 23:59:59', 'admin', '系统管理员', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `school_notice` VALUES (2, '关于开展2026年学科竞赛申报的通知', '本年度校级学科竞赛申报通道已开启，各学院需于5月15日前提交竞赛方案。', 3, '2026-03-13 21:59:26', '2026-05-15 23:59:59', 'admin', '系统管理员', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `school_notice` VALUES (3, '创新学分管理办法修订通知', '修订后的创新学分管理办法将于2026年9月1日正式实施，请各学院遵照执行。', 0, '2026-03-13 21:59:26', '2026-09-01 23:59:59', 'admin', '系统管理员', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `school_notice` VALUES (4, '2026年暑期创新实践活动通知', '暑期创新实践活动报名开始，参与学生可获得1-2分创新学分。', 1.5, '2026-03-13 21:59:26', '2026-08-31 23:59:59', 'admin', '系统管理员', 'published', '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学生姓名',
  `college_id` bigint NULL DEFAULT NULL COMMENT '所属学院ID',
  `major` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '专业',
  `class_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班级',
  `grade` int NULL DEFAULT NULL COMMENT '年级（如2024级）',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态：1-在读，0-休学/毕业',
  `total_credit` decimal(3, 1) NULL DEFAULT 0.0 COMMENT '已获得总创新学分',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `student_id`(`student_id` ASC) USING BTREE,
  UNIQUE INDEX `student_id_2`(`student_id` ASC) USING BTREE,
  INDEX `idx_student_college_id`(`college_id` ASC) USING BTREE,
  CONSTRAINT `student_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学生信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO `student` VALUES (1, '202201001', '张三', 1, '计算机科学与技术', '计科2201', 2022, '1', 8.5, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (2, '202201002', '李四', 1, '软件工程', '软工2202', 2022, '1', 7.2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (3, '202302001', '王五', 2, '电子信息工程', '电信2301', 2023, '1', 5.8, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (4, '202302002', '赵六', 2, '通信工程', '通信2302', 2023, '1', 9.1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (5, '202403001', '钱七', 3, '市场营销', '营销2401', 2024, '1', 4.3, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (6, '202403002', '孙八', 3, '会计学', '会计2402', 2024, '1', 6.7, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (7, '202404001', '周九', 4, '汉语言文学', '文编2401', 2024, '1', 3.9, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (8, '202405001', '吴十', 5, '英语', '英语2401', 2024, '1', 7.8, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (9, '202501003', '郑十一', 1, '人工智能', '智能2501', 2025, '1', 2.5, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (10, '202502003', '王十二', 2, '自动化', '自动化2501', 2025, '1', 8.9, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (11, '202503003', '冯十三', 3, '人力资源管理', '人力2501', 2025, '1', 5.2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (12, '202504002', '陈十四', 4, '历史学', '历史2501', 2025, '1', 4.7, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (13, '202505002', '褚十五', 5, '日语', '日语2501', 2025, '1', 6.1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (14, '202601004', '卫十六', 1, '数据科学与大数据技术', '数科2601', 2026, '1', 1.8, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (15, '202602004', '蒋十七', 2, '物联网工程', '物联2601', 2026, '1', 3.2, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (16, '202603004', '沈十八', 3, '财务管理', '财管2601', 2026, '1', 4.8, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (17, '202204002', '韩十九', 4, '新闻学', '新闻2201', 2022, '1', 9.5, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (18, '202305003', '杨二十', 5, '法语', '法语2301', 2023, '1', 8.1, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (19, '202401005', '朱二一', 1, '网络工程', '网工2401', 2024, '1', 5.5, '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `student` VALUES (20, '202502005', '秦二二', 2, '测控技术与仪器', '测控2501', 2025, '1', 7.4, '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键',
  `config_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配置说明',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'credit_max_year', '10.0', '年度创新学分上限', '2026-03-13 21:59:26', '2026-03-13 21:59:26');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '加密密码',
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色：student-学生，college-学院，school-学校',
  `college_id` bigint NULL DEFAULT NULL COMMENT '所属学院ID（教师/管理员）',
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联学号（仅学生角色）',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态：1-启用，0-禁用',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `username_2`(`username` ASC) USING BTREE,
  INDEX `idx_user_college_id`(`college_id` ASC) USING BTREE,
  INDEX `idx_user_student_id`(`student_id` ASC) USING BTREE,
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `user_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `chk_user_role` CHECK (`role` in (_utf8mb4'student',_utf8mb4'college',_utf8mb4'school'))
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'school', NULL, NULL, '系统管理员', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (2, '01001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'college', 1, NULL, '张老师', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (3, '02001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'college', 2, NULL, '李老师', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (4, '03001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'college', 3, NULL, '王老师', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (5, '04001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'college', 4, NULL, '赵老师', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (6, '05001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'college', 5, NULL, '钱老师', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (7, '202201001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 1, '202201001', '张三', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (8, '202201002', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 1, '202201002', '李四', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (9, '202302001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 2, '202302001', '王五', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (10, '202302002', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 2, '202302002', '赵六', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (11, '202403001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 3, '202403001', '钱七', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (12, '202403002', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 3, '202403002', '孙八', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (13, '202404001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 4, '202404001', '周九', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (14, '202405001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 5, '202405001', '吴十', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (15, '202501003', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 1, '202501003', '郑十一', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (16, '202502003', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 2, '202502003', '王十二', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (17, '202503003', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 3, '202503003', '冯十三', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (18, '202504002', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 4, '202504002', '陈十四', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (19, '202505002', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 5, '202505002', '褚十五', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (20, '202601004', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 1, '202601004', '卫十六', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (21, '202602004', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 2, '202602004', '蒋十七', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (22, '202603004', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 3, '202603004', '沈十八', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (23, '202204002', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 4, '202204002', '韩十九', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (24, '202305003', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 5, '202305003', '杨二十', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (25, '202401005', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 1, '202401005', '朱二一', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');
INSERT INTO `user` VALUES (26, '202502005', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhW', 'student', 2, '202502005', '秦二二', '1', '2026-03-13 21:59:26', '2026-03-13 21:59:26');

SET FOREIGN_KEY_CHECKS = 1;
