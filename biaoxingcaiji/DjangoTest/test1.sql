/*
 Navicat Premium Dump SQL

 Source Server         : local111
 Source Server Type    : MySQL
 Source Server Version : 80031 (8.0.31)
 Source Host           : localhost:3306
 Source Schema         : test1

 Target Server Type    : MySQL
 Target Server Version : 80031 (8.0.31)
 File Encoding         : 65001

 Date: 17/12/2025 09:19:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for auth_group
-- ----------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group
-- ----------------------------

-- ----------------------------
-- Table structure for auth_group_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_group_permissions_group_id_permission_id_0cd325b0_uniq`(`group_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for auth_permission
-- ----------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_permission_content_type_id_codename_01ab375a_uniq`(`content_type_id` ASC, `codename` ASC) USING BTREE,
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_permission
-- ----------------------------
INSERT INTO `auth_permission` VALUES (1, 'Can add log entry', 1, 'add_logentry');
INSERT INTO `auth_permission` VALUES (2, 'Can change log entry', 1, 'change_logentry');
INSERT INTO `auth_permission` VALUES (3, 'Can delete log entry', 1, 'delete_logentry');
INSERT INTO `auth_permission` VALUES (4, 'Can view log entry', 1, 'view_logentry');
INSERT INTO `auth_permission` VALUES (5, 'Can add permission', 2, 'add_permission');
INSERT INTO `auth_permission` VALUES (6, 'Can change permission', 2, 'change_permission');
INSERT INTO `auth_permission` VALUES (7, 'Can delete permission', 2, 'delete_permission');
INSERT INTO `auth_permission` VALUES (8, 'Can view permission', 2, 'view_permission');
INSERT INTO `auth_permission` VALUES (9, 'Can add group', 3, 'add_group');
INSERT INTO `auth_permission` VALUES (10, 'Can change group', 3, 'change_group');
INSERT INTO `auth_permission` VALUES (11, 'Can delete group', 3, 'delete_group');
INSERT INTO `auth_permission` VALUES (12, 'Can view group', 3, 'view_group');
INSERT INTO `auth_permission` VALUES (13, 'Can add user', 4, 'add_user');
INSERT INTO `auth_permission` VALUES (14, 'Can change user', 4, 'change_user');
INSERT INTO `auth_permission` VALUES (15, 'Can delete user', 4, 'delete_user');
INSERT INTO `auth_permission` VALUES (16, 'Can view user', 4, 'view_user');
INSERT INTO `auth_permission` VALUES (17, 'Can add content type', 5, 'add_contenttype');
INSERT INTO `auth_permission` VALUES (18, 'Can change content type', 5, 'change_contenttype');
INSERT INTO `auth_permission` VALUES (19, 'Can delete content type', 5, 'delete_contenttype');
INSERT INTO `auth_permission` VALUES (20, 'Can view content type', 5, 'view_contenttype');
INSERT INTO `auth_permission` VALUES (21, 'Can add session', 6, 'add_session');
INSERT INTO `auth_permission` VALUES (22, 'Can change session', 6, 'change_session');
INSERT INTO `auth_permission` VALUES (23, 'Can delete session', 6, 'delete_session');
INSERT INTO `auth_permission` VALUES (24, 'Can view session', 6, 'view_session');
INSERT INTO `auth_permission` VALUES (25, 'Can add 种质/突变体', 7, 'add_mutant');
INSERT INTO `auth_permission` VALUES (26, 'Can change 种质/突变体', 7, 'change_mutant');
INSERT INTO `auth_permission` VALUES (27, 'Can delete 种质/突变体', 7, 'delete_mutant');
INSERT INTO `auth_permission` VALUES (28, 'Can view 种质/突变体', 7, 'view_mutant');
INSERT INTO `auth_permission` VALUES (29, 'Can add 实验', 8, 'add_experiment');
INSERT INTO `auth_permission` VALUES (30, 'Can change 实验', 8, 'change_experiment');
INSERT INTO `auth_permission` VALUES (31, 'Can delete 实验', 8, 'delete_experiment');
INSERT INTO `auth_permission` VALUES (32, 'Can view 实验', 8, 'view_experiment');
INSERT INTO `auth_permission` VALUES (33, 'Can add 小区', 9, 'add_field');
INSERT INTO `auth_permission` VALUES (34, 'Can change 小区', 9, 'change_field');
INSERT INTO `auth_permission` VALUES (35, 'Can delete 小区', 9, 'delete_field');
INSERT INTO `auth_permission` VALUES (36, 'Can view 小区', 9, 'view_field');
INSERT INTO `auth_permission` VALUES (37, 'Can add 动物个体', 10, 'add_animal');
INSERT INTO `auth_permission` VALUES (38, 'Can change 动物个体', 10, 'change_animal');
INSERT INTO `auth_permission` VALUES (39, 'Can delete 动物个体', 10, 'delete_animal');
INSERT INTO `auth_permission` VALUES (40, 'Can view 动物个体', 10, 'view_animal');
INSERT INTO `auth_permission` VALUES (41, 'Can add 性状定义', 11, 'add_traitdefinition');
INSERT INTO `auth_permission` VALUES (42, 'Can change 性状定义', 11, 'change_traitdefinition');
INSERT INTO `auth_permission` VALUES (43, 'Can delete 性状定义', 11, 'delete_traitdefinition');
INSERT INTO `auth_permission` VALUES (44, 'Can view 性状定义', 11, 'view_traitdefinition');
INSERT INTO `auth_permission` VALUES (45, 'Can add 观测数据', 12, 'add_observation');
INSERT INTO `auth_permission` VALUES (46, 'Can change 观测数据', 12, 'change_observation');
INSERT INTO `auth_permission` VALUES (47, 'Can delete 观测数据', 12, 'delete_observation');
INSERT INTO `auth_permission` VALUES (48, 'Can view 观测数据', 12, 'view_observation');
INSERT INTO `auth_permission` VALUES (49, 'Can add 多媒体文件', 13, 'add_mediafile');
INSERT INTO `auth_permission` VALUES (50, 'Can change 多媒体文件', 13, 'change_mediafile');
INSERT INTO `auth_permission` VALUES (51, 'Can delete 多媒体文件', 13, 'delete_mediafile');
INSERT INTO `auth_permission` VALUES (52, 'Can view 多媒体文件', 13, 'view_mediafile');

-- ----------------------------
-- Table structure for auth_user
-- ----------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `last_login` datetime(6) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `first_name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `last_name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `email` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user
-- ----------------------------
INSERT INTO `auth_user` VALUES (1, 'pbkdf2_sha256$1000000$rIq8VK4iCYyAFYlBVmCIp3$AanorAjDhHNB16nHWGRwdB+EpYRe2EDOz10KqjWp3Mk=', '2025-12-15 13:57:26.823359', 1, 'wangjun', '', '', '2321043623@qq.com', 1, 1, '2025-12-15 13:56:57.246025');

-- ----------------------------
-- Table structure for auth_user_groups
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_groups`;
CREATE TABLE `auth_user_groups`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_user_groups_user_id_group_id_94350c0c_uniq`(`user_id` ASC, `group_id` ASC) USING BTREE,
  INDEX `auth_user_groups_group_id_97559544_fk_auth_group_id`(`group_id` ASC) USING BTREE,
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user_groups
-- ----------------------------

-- ----------------------------
-- Table structure for auth_user_user_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_user_permissions`;
CREATE TABLE `auth_user_user_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq`(`user_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user_user_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for ccge_mutants
-- ----------------------------
DROP TABLE IF EXISTS `ccge_mutants`;
CREATE TABLE `ccge_mutants`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mutant_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `mutant_code`(`mutant_code` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ccge_mutants
-- ----------------------------

-- ----------------------------
-- Table structure for django_admin_log
-- ----------------------------
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `object_repr` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `content_type_id` int NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `django_admin_log_content_type_id_c4bce8eb_fk_django_co`(`content_type_id` ASC) USING BTREE,
  INDEX `django_admin_log_user_id_c564eba6_fk_auth_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_chk_1` CHECK (`action_flag` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_admin_log
-- ----------------------------

-- ----------------------------
-- Table structure for django_content_type
-- ----------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_content_type_app_label_model_76bd3d3b_uniq`(`app_label` ASC, `model` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_content_type
-- ----------------------------
INSERT INTO `django_content_type` VALUES (1, 'admin', 'logentry');
INSERT INTO `django_content_type` VALUES (3, 'auth', 'group');
INSERT INTO `django_content_type` VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` VALUES (4, 'auth', 'user');
INSERT INTO `django_content_type` VALUES (5, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` VALUES (10, 'phenotype', 'animal');
INSERT INTO `django_content_type` VALUES (8, 'phenotype', 'experiment');
INSERT INTO `django_content_type` VALUES (9, 'phenotype', 'field');
INSERT INTO `django_content_type` VALUES (13, 'phenotype', 'mediafile');
INSERT INTO `django_content_type` VALUES (7, 'phenotype', 'mutant');
INSERT INTO `django_content_type` VALUES (12, 'phenotype', 'observation');
INSERT INTO `django_content_type` VALUES (11, 'phenotype', 'traitdefinition');
INSERT INTO `django_content_type` VALUES (6, 'sessions', 'session');

-- ----------------------------
-- Table structure for django_migrations
-- ----------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_migrations
-- ----------------------------
INSERT INTO `django_migrations` VALUES (1, 'contenttypes', '0001_initial', '2025-12-15 13:55:05.229591');
INSERT INTO `django_migrations` VALUES (2, 'auth', '0001_initial', '2025-12-15 13:55:42.878643');
INSERT INTO `django_migrations` VALUES (3, 'admin', '0001_initial', '2025-12-15 13:55:50.631450');
INSERT INTO `django_migrations` VALUES (4, 'admin', '0002_logentry_remove_auto_add', '2025-12-15 13:55:50.872850');
INSERT INTO `django_migrations` VALUES (5, 'admin', '0003_logentry_add_action_flag_choices', '2025-12-15 13:55:51.031079');
INSERT INTO `django_migrations` VALUES (6, 'contenttypes', '0002_remove_content_type_name', '2025-12-15 13:55:53.865811');
INSERT INTO `django_migrations` VALUES (7, 'auth', '0002_alter_permission_name_max_length', '2025-12-15 13:55:56.478647');
INSERT INTO `django_migrations` VALUES (8, 'auth', '0003_alter_user_email_max_length', '2025-12-15 13:56:00.245893');
INSERT INTO `django_migrations` VALUES (9, 'auth', '0004_alter_user_username_opts', '2025-12-15 13:56:00.392180');
INSERT INTO `django_migrations` VALUES (10, 'auth', '0005_alter_user_last_login_null', '2025-12-15 13:56:03.347997');
INSERT INTO `django_migrations` VALUES (11, 'auth', '0006_require_contenttypes_0002', '2025-12-15 13:56:03.590893');
INSERT INTO `django_migrations` VALUES (12, 'auth', '0007_alter_validators_add_error_messages', '2025-12-15 13:56:03.878005');
INSERT INTO `django_migrations` VALUES (13, 'auth', '0008_alter_user_username_max_length', '2025-12-15 13:56:07.445796');
INSERT INTO `django_migrations` VALUES (14, 'auth', '0009_alter_user_last_name_max_length', '2025-12-15 13:56:10.675455');
INSERT INTO `django_migrations` VALUES (15, 'auth', '0010_alter_group_name_max_length', '2025-12-15 13:56:13.865626');
INSERT INTO `django_migrations` VALUES (16, 'auth', '0011_update_proxy_permissions', '2025-12-15 13:56:14.117846');
INSERT INTO `django_migrations` VALUES (17, 'auth', '0012_alter_user_first_name_max_length', '2025-12-15 13:56:17.147854');
INSERT INTO `django_migrations` VALUES (18, 'sessions', '0001_initial', '2025-12-15 13:56:19.283212');
INSERT INTO `django_migrations` VALUES (19, 'phenotype', '0001_initial', '2025-12-16 12:50:57.413465');

-- ----------------------------
-- Table structure for django_session
-- ----------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session`  (
  `session_key` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `session_data` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`) USING BTREE,
  INDEX `django_session_expire_date_a5c62663`(`expire_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_session
-- ----------------------------

-- ----------------------------
-- Table structure for pt_animals
-- ----------------------------
DROP TABLE IF EXISTS `pt_animals`;
CREATE TABLE `pt_animals`  (
  `id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `ear_tag` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `building` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `pen` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `sex` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `birth_date` date NULL DEFAULT NULL,
  `birth_weight` double NULL DEFAULT NULL,
  `sire_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `dam_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `is_invisible` tinyint(1) NOT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `comment` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `experiment_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ear_tag`(`ear_tag` ASC) USING BTREE,
  INDEX `pt_animals_ear_tag_738d56_idx`(`ear_tag` ASC) USING BTREE,
  INDEX `pt_animals_experim_abda22_idx`(`experiment_id` ASC, `pen` ASC) USING BTREE,
  CONSTRAINT `pt_animals_experiment_id_607a5c44_fk_pt_experiments_id` FOREIGN KEY (`experiment_id`) REFERENCES `pt_experiments` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pt_animals
-- ----------------------------

-- ----------------------------
-- Table structure for pt_experiments
-- ----------------------------
DROP TABLE IF EXISTS `pt_experiments`;
CREATE TABLE `pt_experiments`  (
  `id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `year` int NOT NULL,
  `experiment_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `location` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NULL DEFAULT NULL,
  `created_name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `is_invisible` tinyint(1) NOT NULL,
  `comment` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `pt_experime_year_e0e2ef_idx`(`year` ASC, `location` ASC) USING BTREE,
  INDEX `pt_experime_status_f7e570_idx`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pt_experiments
-- ----------------------------
INSERT INTO `pt_experiments` VALUES ('3d841a258c634e4bac75f92f23b8da0a', '2025突变体库T1', 2025, 'plant', '南京土桥', '', 'ongoing', '2025-01-01', '2025-12-31', 'wj', 0, '', '2025-12-16 13:21:23.089045', '2025-12-16 13:21:23.089103');
INSERT INTO `pt_experiments` VALUES ('66d69ea97fae4d3681d82ad0ac37323b', '2025突变体库T0', 2025, 'plant', '南京土桥', '', 'ongoing', '2025-01-01', '2025-12-31', 'wj', 0, '', '2025-12-16 13:21:52.781292', '2025-12-16 13:21:52.781306');
INSERT INTO `pt_experiments` VALUES ('d37de615d0bf4c22b78513ffb3ca8be4', '2025突变体库T2', 2025, 'plant', '南京土桥', '', 'ongoing', '2025-01-01', '2025-12-31', 'wj', 0, '', '2025-12-16 13:21:46.622553', '2025-12-16 13:21:46.622570');

-- ----------------------------
-- Table structure for pt_fields
-- ----------------------------
DROP TABLE IF EXISTS `pt_fields`;
CREATE TABLE `pt_fields`  (
  `id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `field_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `mutant_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `last_collected` datetime(6) NULL DEFAULT NULL,
  `is_invisible` tinyint(1) NOT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `comment` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `experiment_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `mutant_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `pt_fields_experiment_id_field_code_29c17539_uniq`(`experiment_id` ASC, `field_code` ASC) USING BTREE,
  INDEX `pt_fields_experim_b20d77_idx`(`experiment_id` ASC, `field_code` ASC) USING BTREE,
  INDEX `pt_fields_mutant_id_a91858d1_fk_ccge_mutants_id`(`mutant_id` ASC) USING BTREE,
  CONSTRAINT `pt_fields_experiment_id_dced44e0_fk_pt_experiments_id` FOREIGN KEY (`experiment_id`) REFERENCES `pt_experiments` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pt_fields_mutant_id_a91858d1_fk_ccge_mutants_id` FOREIGN KEY (`mutant_id`) REFERENCES `ccge_mutants` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pt_fields
-- ----------------------------
INSERT INTO `pt_fields` VALUES ('0d289a94ac574b1fb65d1782d05de6af', '25KY00009', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:36.488020', '2025-12-16 13:27:36.488036', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('17c5a3472cad4ae7add9e656b2bb1c65', '25KY00004', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:16.919469', '2025-12-16 13:27:16.919485', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('29567462741e484cbe986a874562594b', '25KY00001', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:02.296969', '2025-12-16 13:27:02.296990', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('39f7e2523795430f9a1f477ccc976898', '25KY00010', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:42.265918', '2025-12-16 13:27:42.265934', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('6867037058464c4fa9bf39d29579a541', '25KY00007', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:27.175758', '2025-12-16 13:27:27.175775', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('903c93da2226454db412f71be96660e3', '25KY00002', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:09.472677', '2025-12-16 13:27:09.472695', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('c4234733de9649a8a458da4659bb5579', '25KY00005', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:20.410656', '2025-12-16 13:27:20.410671', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('c67eeaf326f64fab96a464c807d17476', '25KY00006', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:23.879261', '2025-12-16 13:27:23.879290', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('d19c5c5c35334633938257e95a412271', '25KY00008', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:31.646603', '2025-12-16 13:27:31.646619', '66d69ea97fae4d3681d82ad0ac37323b', NULL);
INSERT INTO `pt_fields` VALUES ('e48ae0607fc348c9a22d7bf7e91cb55c', '25KY00003', NULL, 'not_collected', NULL, 0, '', '', '2025-12-16 13:27:13.648271', '2025-12-16 13:27:13.648287', '66d69ea97fae4d3681d82ad0ac37323b', NULL);

-- ----------------------------
-- Table structure for pt_media_files
-- ----------------------------
DROP TABLE IF EXISTS `pt_media_files`;
CREATE TABLE `pt_media_files`  (
  `id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `file_path` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `media_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `capture_time` datetime(6) NOT NULL,
  `captured_by` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `is_invisible` tinyint(1) NOT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `comment` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `animal_link_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `field_link_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `pt_media_fi_field_l_b58ace_idx`(`field_link_id` ASC) USING BTREE,
  INDEX `pt_media_fi_animal__76a1e9_idx`(`animal_link_id` ASC) USING BTREE,
  INDEX `pt_media_fi_capture_7b9acb_idx`(`capture_time` ASC) USING BTREE,
  CONSTRAINT `pt_media_files_animal_link_id_aceae98b_fk_pt_animals_id` FOREIGN KEY (`animal_link_id`) REFERENCES `pt_animals` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pt_media_files_field_link_id_05e79517_fk_pt_fields_id` FOREIGN KEY (`field_link_id`) REFERENCES `pt_fields` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pt_media_files
-- ----------------------------

-- ----------------------------
-- Table structure for pt_observations
-- ----------------------------
DROP TABLE IF EXISTS `pt_observations`;
CREATE TABLE `pt_observations`  (
  `id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `value` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `observer` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `measure_date` datetime(6) NOT NULL,
  `is_invisible` tinyint(1) NOT NULL,
  `comment` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `animal_link_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `field_link_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `trait_id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `pt_observat_field_l_a7f234_idx`(`field_link_id` ASC, `trait_id` ASC) USING BTREE,
  INDEX `pt_observat_animal__469325_idx`(`animal_link_id` ASC, `trait_id` ASC) USING BTREE,
  INDEX `pt_observat_measure_cf74ca_idx`(`measure_date` ASC) USING BTREE,
  INDEX `pt_observations_trait_id_b0261d3a_fk_pt_trait_definitions_id`(`trait_id` ASC) USING BTREE,
  CONSTRAINT `pt_observations_animal_link_id_55eb0b90_fk_pt_animals_id` FOREIGN KEY (`animal_link_id`) REFERENCES `pt_animals` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pt_observations_field_link_id_c38a6297_fk_pt_fields_id` FOREIGN KEY (`field_link_id`) REFERENCES `pt_fields` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pt_observations_trait_id_b0261d3a_fk_pt_trait_definitions_id` FOREIGN KEY (`trait_id`) REFERENCES `pt_trait_definitions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pt_observations
-- ----------------------------

-- ----------------------------
-- Table structure for pt_trait_definitions
-- ----------------------------
DROP TABLE IF EXISTS `pt_trait_definitions`;
CREATE TABLE `pt_trait_definitions`  (
  `id` char(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `unit` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `data_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `is_invisible` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE,
  INDEX `pt_trait_de_code_dd4360_idx`(`code` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pt_trait_definitions
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
