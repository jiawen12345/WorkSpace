# 快速启动指南

## 📍 当前状态

✅ Django项目已创建完成  
✅ 虚拟环境已创建 (`.venv/`) - 使用 uv 管理  
✅ 基础依赖已安装 (Django 5.2.9, Pillow 12.0.0)  
✅ mysqlclient 已安装 (2.2.7)  
✅ 数据库配置为 MySQL  
✅ 所有模型文件已就绪

**工作目录**: `/home/mingmi/workspace/django_to_pengjiawen`

## 🚀 完整启动步骤

### 步骤 1: 激活虚拟环境

```bash
source .venv/bin/activate
```

### 步骤 2: 创建 MySQL 数据库

登录MySQL并创建数据库：

```sql
CREATE DATABASE test1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

或使用命令行：

```bash
mysql -u root -p -e "CREATE DATABASE test1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 步骤 3: 配置数据库连接

数据库配置已在 `phenotype_project/settings.py` 中设置：

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'test1',          # 数据库名称
        'USER': 'root',           # 用户名
        'PASSWORD': 'root',       # 密码（根据实际情况修改）
        'HOST': '127.0.0.1',      # 主机
        'PORT': 3306,             # 端口
    }
}
```

**如需修改密码**，请编辑 `phenotype_project/settings.py` 文件。

### 步骤 4: 创建数据库迁移文件

```bash
python manage.py makemigrations
```

这将为以下模型创建迁移：
- Mutant (种质/突变体)
- Experiment (实验)
- Field (小区)
- Animal (动物个体)
- TraitDefinition (性状定义)
- Observation (观测数据)
- MediaFile (多媒体文件)

### 步骤 5: 执行数据库迁移

```bash
python manage.py migrate
```

这将在MySQL数据库中创建所有必要的表。

### 步骤 6: 创建管理员账户

```bash
python manage.py createsuperuser
```

按提示输入用户名、邮箱和密码。

### 步骤 7: 启动开发服务器

```bash
python manage.py runserver
```

### 步骤 8: 访问系统

- **首页**: http://127.0.0.1:8000/
- **管理后台**: http://127.0.0.1:8000/admin/

使用步骤6创建的管理员账户登录。

## 📦 已安装的包

```
django==5.2.9
pillow==12.0.0
mysqlclient==2.2.7
asgiref==3.11.0
sqlparse==0.5.4
typing-extensions==4.15.0
```

## 🔧 使用 uv 管理包

### 重要说明

本项目使用 **uv** 管理虚拟环境和依赖。uv 创建的虚拟环境不包含 pip，需要使用系统的 uv 来安装包。

### 安装新包的正确方式

```bash
# ✅ 正确：使用系统的 uv
python3 -m uv pip install --python .venv/bin/python package-name

# ❌ 错误：虚拟环境中没有 pip
pip install package-name  # 这不会工作
```

### 常用命令

```bash
# 查看已安装的包
python3 -m uv pip list --python .venv/bin/python

# 安装新包
python3 -m uv pip install --python .venv/bin/python package-name

# 卸载包
python3 -m uv pip uninstall --python .venv/bin/python package-name

# 升级包
python3 -m uv pip install --python .venv/bin/python --upgrade package-name
```

## 🗂️ 项目结构

```
django_to_pengjiawen/
├── .venv/                    # 虚拟环境 (uv管理)
├── manage.py                 # Django管理脚本
├── pyproject.toml            # 项目配置
├── README.md                 # 项目说明
├── QUICKSTART.md            # 本文件
├── DATABASE_SETUP.md        # 数据库配置说明
├── .gitignore               # Git忽略配置
├── phenotype_project/        # 项目配置
│   ├── __init__.py
│   ├── settings.py           # 设置文件 (含MySQL配置)
│   ├── urls.py               # URL路由
│   └── wsgi.py               # WSGI配置
└── phenotype/                # 表型采集应用
    ├── __init__.py
    ├── apps.py
    ├── models.py             # 数据模型 (基于reference.py)
    ├── admin.py              # 管理后台配置
    ├── views.py
    └── urls.py
```

## 🗄️ 数据库表

执行迁移后，将在MySQL中创建以下表：

- `ccge_mutants` - 种质/突变体表
- `pt_experiments` - 实验表
- `pt_fields` - 小区表
- `pt_animals` - 动物个体表
- `pt_trait_definitions` - 性状定义表
- `pt_observations` - 观测数据表
- `pt_media_files` - 多媒体文件表

## 🎯 Django 管理命令

```bash
# 激活虚拟环境后使用
python manage.py makemigrations    # 创建迁移
python manage.py migrate           # 执行迁移
python manage.py createsuperuser   # 创建管理员
python manage.py runserver         # 启动服务器
python manage.py shell             # Django Shell
python manage.py dbshell           # 数据库 Shell
```

## ⚠️ 常见问题

### 问题1: 为什么不能用 pip？

**答**: uv 创建的虚拟环境是纯净的，不包含 pip。这是 uv 的设计理念，使用 uv 统一管理所有包。

**解决方案**: 使用 `python3 -m uv pip install --python .venv/bin/python package-name`

### 问题2: pyproject.toml 中的包很少？

**答**: pyproject.toml 只列出**直接依赖**，传递依赖（如 asgiref, sqlparse）会自动安装。这是现代 Python 项目的标准做法。

### 问题3: mysqlclient 安装失败

**解决方案**：安装系统依赖

```bash
# Ubuntu/Debian
sudo apt-get install python3-dev default-libmysqlclient-dev build-essential

# CentOS/RHEL
sudo yum install python3-devel mysql-devel

# macOS
brew install mysql
```

### 问题4: 无法连接到MySQL

**检查项**：
1. MySQL服务是否启动：`sudo systemctl status mysql`
2. 数据库是否存在：`mysql -u root -p -e "SHOW DATABASES;"`
3. 用户名和密码是否正确
4. 防火墙设置

## 📚 数据模型说明

所有模型都基于 `reference.py` 创建：

- **Mutant**: 种质/突变体信息
- **Experiment**: 实验项目（支持植物和动物）
- **Field**: 小区信息（用于植物实验）
- **Animal**: 动物个体信息（用于动物实验）
- **TraitDefinition**: 性状定义
- **Observation**: 观测数据记录
- **MediaFile**: 多媒体文件（照片/视频）

## 🎯 为什么使用 uv？

- ⚡ **更快**: 比 pip 快 10-100 倍
- 🔒 **可靠**: 更好的依赖解析
- 📦 **简洁**: 统一的包管理体验
- 🚀 **现代**: Python 包管理的未来

---

**准备就绪！开始使用吧！** 🎉