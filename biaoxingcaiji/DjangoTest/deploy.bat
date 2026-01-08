@echo off
REM 表型采集系统 - 自动部署脚本 (Windows)
setlocal enabledelayedexpansion

echo ==================================
echo 表型采集系统 - 自动部署
echo ==================================
echo.

REM 检查 Python
echo [1/9] 检查 Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo √ 找到 !PYTHON_VERSION!
echo.

REM 检查 MySQL
echo [2/9] 检查 MySQL...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo 警告: 未找到 MySQL 客户端
    echo 请确保 MySQL 服务器已安装并运行
) else (
    echo √ MySQL 客户端已安装
)
echo.

REM 安装 uv
echo [3/9] 检查/安装 uv...
python -m uv --version >nul 2>&1
if errorlevel 1 (
    echo 正在安装 uv...
    pip install uv
    echo √ uv 安装完成
) else (
    echo √ uv 已安装
)
echo.

REM 创建虚拟环境
echo [4/9] 创建虚拟环境...
if exist ".venv" (
    echo 虚拟环境已存在，跳过创建
) else (
    python -m uv venv
    echo √ 虚拟环境创建完成
)
echo.

REM 安装依赖
echo [5/9] 安装项目依赖...
python -m uv pip install --python .venv\Scripts\python.exe django pillow mysqlclient djangorestframework django-filter
echo √ 依赖安装完成
echo.

REM 配置数据库
echo [6/9] 配置数据库...
echo 请输入 MySQL 配置信息：
set /p DB_NAME="数据库名称 [test1]: "
if "!DB_NAME!"=="" set DB_NAME=test1

set /p DB_USER="MySQL 用户名 [root]: "
if "!DB_USER!"=="" set DB_USER=root

set /p DB_PASSWORD="MySQL 密码: "

set /p DB_HOST="MySQL 主机 [127.0.0.1]: "
if "!DB_HOST!"=="" set DB_HOST=127.0.0.1

set /p DB_PORT="MySQL 端口 [3306]: "
if "!DB_PORT!"=="" set DB_PORT=3306

echo.
echo 数据库配置：
echo   数据库名: !DB_NAME!
echo   用户名: !DB_USER!
echo   主机: !DB_HOST!
echo   端口: !DB_PORT!
echo.

REM 更新配置提示
echo [7/9] 数据库配置...
echo 请手动更新 phenotype_project\settings.py 中的数据库配置：
echo   NAME: !DB_NAME!
echo   USER: !DB_USER!
echo   PASSWORD: ****
echo   HOST: !DB_HOST!
echo   PORT: !DB_PORT!
echo.
pause

REM 数据库迁移
echo [8/9] 执行数据库迁移...
call .venv\Scripts\activate.bat
python manage.py makemigrations
python manage.py migrate
echo √ 数据库迁移完成
echo.

REM 创建超级用户
echo [9/9] 创建超级用户...
echo 请按提示创建管理员账户：
python manage.py createsuperuser
echo.

REM 完成
echo ==================================
echo √ 部署完成！
echo ==================================
echo.
echo 启动开发服务器：
echo   .venv\Scripts\activate
echo   python manage.py runserver
echo.
echo 访问地址：
echo   首页: http://127.0.0.1:8000/
echo   管理后台: http://127.0.0.1:8000/admin/
echo   REST API: http://127.0.0.1:8000/api/
echo.
echo 详细文档请查看：
echo   - DEPLOYMENT_GUIDE.md (完整部署指南)
echo   - README.md (项目说明)
echo   - API_DOCUMENTATION.md (API 文档)
echo.
pause