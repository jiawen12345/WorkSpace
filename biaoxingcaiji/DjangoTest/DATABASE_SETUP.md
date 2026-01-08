# 数据库配置说明

## 📊 MySQL 数据库配置

本项目使用 MySQL 作为数据库后端。

## 🔧 当前配置

**数据库信息** (在 `phenotype_project/settings.py` 中配置):

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'test1',          # 数据库名称
        'USER': 'root',           # MySQL用户名
        'PASSWORD': 'root',       # MySQL密码
        'HOST': '127.0.0.1',      # 数据库主机
        'PORT': 3306,             # 数据库端口
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        },
    }
}
```

## 📝 数据库创建步骤

### 方法1: 使用 MySQL 命令行

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE test1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 查看数据库
SHOW DATABASES;

# 退出
EXIT;
```

### 方法2: 使用一行命令

```bash
mysql -u root -p -e "CREATE DATABASE test1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

## 🗃️ 数据库表结构

执行 Django 迁移后，将创建以下表：

### 核心业务表

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `ccge_mutants` | 种质/突变体 | mutant_code, name, description |
| `pt_experiments` | 实验项目 | name, year, experiment_type, location, status |
| `pt_fields` | 小区信息 | field_code, experiment_id, mutant_id, status |
| `pt_animals` | 动物个体 | ear_tag, sex, birth_date, experiment_id |
| `pt_trait_definitions` | 性状定义 | code, name, unit, data_type |
| `pt_observations` | 观测数据 | field_link_id, animal_link_id, trait_id, value |
| `pt_media_files` | 多媒体文件 | file_path, media_type, capture_time |

### Django 系统表

- `auth_*` - 认证和授权相关表
- `django_*` - Django 框架系统表
- `sessions` - 会话表

## 🔐 修改数据库密码

如果您的 MySQL 密码不是 `root`，请修改 `phenotype_project/settings.py`:

```python
DATABASES = {
    'default': {
        'PASSWORD': '你的实际密码',  # 修改这里
    }
}
```

## 🌐 远程数据库配置

如果使用远程 MySQL 服务器：

```python
DATABASES = {
    'default': {
        'HOST': '远程服务器IP',      # 例如: '192.168.1.100'
        'PORT': 3306,
        'USER': '数据库用户名',
        'PASSWORD': '数据库密码',
    }
}
```

## ⚙️ 数据库优化建议

### 1. 连接池配置

安装 django-mysql:

```bash
python3 -m uv pip install --python .venv/bin/python django-mysql
```

在 settings.py 中添加：

```python
DATABASES = {
    'default': {
        # ... 其他配置
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
            'connect_timeout': 10,
        },
        'CONN_MAX_AGE': 600,  # 连接池
    }
}
```

### 2. 索引优化

模型中已添加必要的索引：

- `pt_experiments`: year, location, status
- `pt_fields`: experiment, field_code
- `pt_animals`: ear_tag, experiment, pen
- `pt_observations`: field_link, animal_link, trait, measure_date
- `pt_media_files`: field_link, animal_link, capture_time

### 3. 查询优化

使用 `select_related()` 和 `prefetch_related()` 减少数据库查询次数。

## 🔍 数据库管理工具

推荐使用以下工具管理 MySQL：

- **命令行**: `mysql` 客户端
- **GUI工具**: 
  - MySQL Workbench
  - phpMyAdmin
  - DBeaver
  - Navicat

## 📊 查看数据库状态

```bash
# 进入 Django dbshell
python manage.py dbshell

# 查看所有表
SHOW TABLES;

# 查看表结构
DESCRIBE pt_experiments;

# 查看表数据量
SELECT COUNT(*) FROM pt_experiments;
```

## 🔄 数据库备份与恢复

### 备份

```bash
mysqldump -u root -p test1 > backup_$(date +%Y%m%d).sql
```

### 恢复

```bash
mysql -u root -p test1 < backup_20251215.sql
```

## ⚠️ 注意事项

1. **字符集**: 使用 utf8mb4 支持完整的 Unicode 字符（包括 emoji）
2. **时区**: Django 设置为 `Asia/Shanghai`，MySQL 也应配置相应时区
3. **权限**: 确保数据库用户有足够的权限（CREATE, ALTER, DROP, SELECT, INSERT, UPDATE, DELETE）
4. **备份**: 定期备份生产数据库
5. **安全**: 生产环境不要使用 root 用户，创建专用数据库用户

## 🚀 生产环境建议

```python
# 使用环境变量管理敏感信息
import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', 'test1'),
        'USER': os.environ.get('DB_USER', 'root'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST', '127.0.0.1'),
        'PORT': int(os.environ.get('DB_PORT', 3306)),
    }
}
```

---

**数据库配置完成后，即可开始使用系统！** 🎉