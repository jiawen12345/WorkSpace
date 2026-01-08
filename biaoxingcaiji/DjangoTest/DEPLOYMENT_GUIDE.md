# 部署指南 - 新环境安装

本文档详细说明如何在新电脑上从零开始部署表型采集系统（使用 uv 管理虚拟环境）。

## 📋 系统要求

### 必需软件
- **Python**: 3.8 或更高版本
- **MySQL**: 5.7+ 或 MariaDB 10.2+
- **Git**: 用于克隆代码（可选）
- **uv**: Python 包管理器

### 操作系统
- Linux (Ubuntu/Debian/CentOS)
- macOS
- Windows 10/11

---

## 🚀 完整部署步骤

### 步骤 1: 安装系统依赖

#### Ubuntu/Debian
```bash
# 更新包列表
sudo apt update

# 安装 Python 和必要的开发工具
sudo apt install -y python3 python3-pip python3-dev

# 安装 MySQL 客户端开发库（mysqlclient 需要）
sudo apt install -y default-libmysqlclient-dev build-essential pkg-config

# 安装 MySQL 服务器（如果本机需要）
sudo apt install -y mysql-server
```

#### CentOS/RHEL
```bash
# 安装 Python 和开发工具
sudo yum install -y python3 python3-devel gcc

# 安装 MySQL 开发库
sudo yum install -y mysql-devel

# 安装 MySQL 服务器（如果本机需要）
sudo yum install -y mysql-server
```

#### macOS
```bash
# 使用 Homebrew 安装
brew install python3 mysql pkg-config
```

#### Windows
1. 下载并安装 [Python](https://www.python.org/downloads/)
2. 下载并安装 [MySQL](https://dev.mysql.com/downloads/installer/)
3. 安装 [Microsoft C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)

---

### 步骤 2: 安装 uv 包管理器

#### Linux/macOS
```bash
# 方法 1: 使用官方安装脚本（推荐）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 方法 2: 使用 pip 安装
pip install uv

# 验证安装
uv --version
```

#### Windows
```powershell
# 使用 PowerShell
irm https://astral.sh/uv/install.ps1 | iex

# 或使用 pip
pip install uv

# 验证安装
uv --version
```

---

### 步骤 3: 获取项目代码

#### 方法 1: 使用 Git（推荐）
```bash
# 克隆项目
git clone <your-repository-url>
cd django_to_pengjiawen
```

#### 方法 2: 手动复制
将整个项目文件夹复制到新电脑，确保包含以下文件：
```
django_to_pengjiawen/
├── manage.py
├── pyproject.toml          # ⭐ 重要：包含项目依赖定义
├── phenotype/
├── phenotype_project/
└── 所有其他文件
```

---

### 步骤 4: 创建虚拟环境

```bash
# 进入项目目录
cd django_to_pengjiawen

# 使用 uv 创建虚拟环境
python3 -m uv venv

# 验证虚拟环境已创建
ls -la .venv/
```

---

### 步骤 5: 安装项目依赖

#### 方法 1: 使用 pyproject.toml（推荐）⭐

本项目使用 `pyproject.toml` 管理依赖，这是使用 uv 的标准方式：

```bash
# 查看 pyproject.toml 中定义的依赖
cat pyproject.toml
```

**pyproject.toml 内容**:
```toml
[project]
name = "phenotype-system"
version = "0.1.0"
description = "表型采集系统 - Django REST Framework 项目"
requires-python = ">=3.8"
dependencies = [
    "django>=4.2,<5.0",
    "pillow>=10.0.0",
    "mysqlclient>=2.2.0",
    "djangorestframework>=3.14.0",
    "django-filter>=23.0",
]
```

**安装所有依赖**:
```bash
# 使用 uv 根据 pyproject.toml 安装依赖
python3 -m uv pip install --python .venv/bin/python -e .
```

#### 方法 2: 手动安装各个包

如果方法 1 不工作，可以手动安装：

```bash
python3 -m uv pip install --python .venv/bin/python \
    django \
    pillow \
    mysqlclient \
    djangorestframework \
    django-filter
```

#### 验证安装

```bash
# 查看已安装的包
python3 -m uv pip list --python .venv/bin/python
```

**预期输出**:
```
Package              Version
-------------------- -------
asgiref              3.11.0
django               5.2.9
django-filter        25.2
djangorestframework  3.16.1
mysqlclient          2.2.7
pillow               12.0.0
sqlparse             0.5.4
typing-extensions    4.15.0
```

---

### 步骤 6: 配置 MySQL 数据库

#### 6.1 启动 MySQL 服务

```bash
# Linux
sudo systemctl start mysql
sudo systemctl enable mysql  # 开机自启

# macOS
brew services start mysql

# Windows
# 在服务管理器中启动 MySQL 服务
```

#### 6.2 创建数据库

```bash
# 登录 MySQL
mysql -u root -p

# 在 MySQL 命令行中执行
CREATE DATABASE test1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 创建专用数据库用户（推荐）
CREATE USER 'phenotype_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON test1.* TO 'phenotype_user'@'localhost';
FLUSH PRIVILEGES;

# 退出
EXIT;
```

#### 6.3 配置数据库连接

编辑 `phenotype_project/settings.py`，修改数据库配置：

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'test1',
        'USER': 'root',  # 或 'phenotype_user'
        'PASSWORD': 'your_password',  # 修改为实际密码
        'HOST': '127.0.0.1',
        'PORT': 3306,
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        },
    }
}
```

---

### 步骤 7: 激活虚拟环境并初始化数据库

#### Linux/macOS
```bash
# 激活虚拟环境
source .venv/bin/activate

# 创建数据库迁移
python manage.py makemigrations

# 执行迁移
python manage.py migrate

# 创建超级用户
python manage.py createsuperuser
```

#### Windows
```powershell
# 激活虚拟环境
.venv\Scripts\activate

# 创建数据库迁移
python manage.py makemigrations

# 执行迁移
python manage.py migrate

# 创建超级用户
python manage.py createsuperuser
```

**创建超级用户时的提示**:
```
Username: admin
Email address: admin@example.com
Password: ********
Password (again): ********
Superuser created successfully.
```

---

### 步骤 8: 启动开发服务器

```bash
# 确保虚拟环境已激活
python manage.py runserver

# 或指定端口
python manage.py runserver 0.0.0.0:8000
```

**预期输出**:
```
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
December 17, 2025 - 09:00:00
Django version 5.2.9, using settings 'phenotype_project.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

---

### 步骤 9: 验证部署

#### 9.1 访问系统

在浏览器中访问以下地址：

- **首页**: http://127.0.0.1:8000/
- **管理后台**: http://127.0.0.1:8000/admin/
- **REST API**: http://127.0.0.1:8000/api/

#### 9.2 测试 API

```bash
# 测试 API 端点（需要先登录）
curl http://127.0.0.1:8000/api/

# 使用认证
curl -u admin:password http://127.0.0.1:8000/api/experiments/
```

#### 9.3 检查数据库表

```bash
# 进入 Django shell
python manage.py dbshell

# 在 MySQL 中执行
SHOW TABLES;
```

**预期输出**:
```
+----------------------------+
| Tables_in_test1            |
+----------------------------+
| auth_group                 |
| auth_user                  |
| ccge_mutants               |
| pt_animals                 |
| pt_experiments             |
| pt_fields                  |
| pt_media_files             |
| pt_observations            |
| pt_trait_definitions       |
| ...                        |
+----------------------------+
```

---

## 🔧 常见问题排查

### 问题 1: uv 命令未找到

**错误**: `bash: uv: command not found`

**解决方案**:
```bash
# 重新加载 shell 配置
source ~/.bashrc  # 或 ~/.zshrc

# 或使用完整路径
~/.cargo/bin/uv --version

# 或使用 Python 模块方式
python3 -m uv --version
```

### 问题 2: mysqlclient 安装失败

**错误**: `error: command 'gcc' failed`

**解决方案**:
```bash
# Ubuntu/Debian
sudo apt install -y python3-dev default-libmysqlclient-dev build-essential

# CentOS/RHEL
sudo yum install -y python3-devel mysql-devel gcc

# macOS
brew install mysql pkg-config
export PKG_CONFIG_PATH="/usr/local/opt/mysql/lib/pkgconfig"
```

### 问题 3: 无法从 pyproject.toml 安装

**错误**: `error: failed to build package`

**解决方案**:
```bash
# 方法 1: 安装 hatchling（构建后端）
python3 -m uv pip install --python .venv/bin/python hatchling

# 然后重新安装项目
python3 -m uv pip install --python .venv/bin/python -e .

# 方法 2: 手动安装各个包
python3 -m uv pip install --python .venv/bin/python \
    django pillow mysqlclient djangorestframework django-filter
```

### 问题 4: 无法连接 MySQL

**错误**: `Can't connect to MySQL server`

**解决方案**:
```bash
# 检查 MySQL 服务状态
sudo systemctl status mysql

# 启动 MySQL
sudo systemctl start mysql

# 检查端口
netstat -tlnp | grep 3306

# 测试连接
mysql -u root -p -h 127.0.0.1
```

### 问题 5: 数据库权限错误

**错误**: `Access denied for user`

**解决方案**:
```sql
-- 登录 MySQL
mysql -u root -p

-- 授予权限
GRANT ALL PRIVILEGES ON test1.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### 问题 6: 端口被占用

**错误**: `Error: That port is already in use`

**解决方案**:
```bash
# 查找占用端口的进程
lsof -i :8000  # Linux/macOS
netstat -ano | findstr :8000  # Windows

# 使用其他端口
python manage.py runserver 8080
```

---

## 📦 关于 pyproject.toml

### 什么是 pyproject.toml？

`pyproject.toml` 是 Python 项目的标准配置文件（PEP 518），用于：
- 定义项目元数据
- 声明项目依赖
- 配置构建系统
- 配置开发工具

### 为什么使用 pyproject.toml？

1. **标准化**: Python 社区的标准配置格式
2. **简洁**: 一个文件管理所有配置
3. **兼容性**: 与 uv、pip、poetry 等工具兼容
4. **可维护**: 依赖版本集中管理

### 如何更新依赖？

```bash
# 1. 编辑 pyproject.toml，添加新依赖
# 例如添加: "requests>=2.31.0"

# 2. 重新安装
python3 -m uv pip install --python .venv/bin/python -e .

# 3. 验证
python3 -m uv pip list --python .venv/bin/python
```

### pyproject.toml vs requirements.txt

| 特性 | pyproject.toml | requirements.txt |
|------|----------------|------------------|
| 标准化 | ✅ Python 标准 | ❌ 非标准 |
| 元数据 | ✅ 包含项目信息 | ❌ 仅依赖列表 |
| 版本范围 | ✅ 灵活的版本约束 | ⚠️ 通常固定版本 |
| 工具支持 | ✅ uv, pip, poetry | ✅ pip |
| 推荐使用 | ✅ 现代项目 | ⚠️ 传统项目 |

---

## 📦 生产环境部署建议

### 1. 使用环境变量管理敏感信息

创建 `.env` 文件：
```bash
DB_NAME=test1
DB_USER=phenotype_user
DB_PASSWORD=secure_password
DB_HOST=127.0.0.1
DB_PORT=3306
SECRET_KEY=your-secret-key-here
DEBUG=False
```

安装 python-decouple：
```bash
python3 -m uv pip install --python .venv/bin/python python-decouple
```

修改 `settings.py`：
```python
from decouple import config

SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST'),
        'PORT': config('DB_PORT', cast=int),
    }
}
```

### 2. 使用 Gunicorn 作为 WSGI 服务器

```bash
# 安装 Gunicorn
python3 -m uv pip install --python .venv/bin/python gunicorn

# 启动服务
gunicorn phenotype_project.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

### 3. 使用 Nginx 作为反向代理

Nginx 配置示例：
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /static/ {
        alias /path/to/project/staticfiles/;
    }

    location /media/ {
        alias /path/to/project/media/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 4. 收集静态文件

```bash
# 在 settings.py 中设置
STATIC_ROOT = BASE_DIR / 'staticfiles'

# 收集静态文件
python manage.py collectstatic
```

### 5. 设置系统服务（Systemd）

创建 `/etc/systemd/system/phenotype.service`：
```ini
[Unit]
Description=Phenotype Collection System
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/django_to_pengjiawen
Environment="PATH=/path/to/django_to_pengjiawen/.venv/bin"
ExecStart=/path/to/django_to_pengjiawen/.venv/bin/gunicorn \
          --workers 4 \
          --bind 127.0.0.1:8000 \
          phenotype_project.wsgi:application

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl start phenotype
sudo systemctl enable phenotype
```

---

## ✅ 部署检查清单

部署完成后，请检查以下项目：

- [ ] Python 3.8+ 已安装
- [ ] uv 包管理器已安装
- [ ] MySQL 服务正常运行
- [ ] 数据库 `test1` 已创建
- [ ] 虚拟环境已创建（`.venv/`）
- [ ] pyproject.toml 文件存在
- [ ] 所有依赖包已安装（通过 pyproject.toml）
- [ ] 数据库配置正确
- [ ] 数据库迁移已执行
- [ ] 超级用户已创建
- [ ] 开发服务器可以启动
- [ ] 可以访问管理后台
- [ ] REST API 正常工作
- [ ] 静态文件配置正确（生产环境）
- [ ] 媒体文件目录已创建

---

## 📞 获取帮助

如果遇到问题：

1. 查看项目文档：
   - `README.md` - 项目概述
   - `QUICKSTART.md` - 快速启动
   - `DATABASE_SETUP.md` - 数据库配置
   - `API_DOCUMENTATION.md` - API 文档

2. 检查日志：
   ```bash
   # Django 日志
   python manage.py runserver --verbosity 3
   
   # MySQL 日志
   sudo tail -f /var/log/mysql/error.log
   ```

3. 验证配置：
   ```bash
   # 检查 Django 配置
   python manage.py check
   
   # 测试数据库连接
   python manage.py dbshell
   
   # 查看已安装的包
   python3 -m uv pip list --python .venv/bin/python
   ```

---

**部署完成！祝您使用愉快！** 🎉