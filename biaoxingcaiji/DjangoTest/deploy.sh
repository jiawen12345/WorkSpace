#!/bin/bash
# 表型采集系统 - 自动部署脚本
# 适用于 Linux/macOS
# 使用 uv 和 pyproject.toml 管理依赖

set -e  # 遇到错误立即退出

echo "=================================="
echo "表型采集系统 - 自动部署"
echo "使用 uv + pyproject.toml"
echo "=================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查 Python
echo -e "${YELLOW}[1/9] 检查 Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误: 未找到 Python3，请先安装 Python 3.8+${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✓ 找到 $PYTHON_VERSION${NC}"
echo ""

# 检查 pyproject.toml
echo -e "${YELLOW}[2/9] 检查 pyproject.toml...${NC}"
if [ ! -f "pyproject.toml" ]; then
    echo -e "${RED}错误: 未找到 pyproject.toml 文件${NC}"
    exit 1
fi
echo -e "${GREEN}✓ pyproject.toml 文件存在${NC}"
echo ""

# 检查 MySQL
echo -e "${YELLOW}[3/9] 检查 MySQL...${NC}"
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}警告: 未找到 MySQL 客户端${NC}"
    echo "请确保 MySQL 服务器已安装并运行"
else
    echo -e "${GREEN}✓ MySQL 客户端已安装${NC}"
fi
echo ""

# 安装 uv
echo -e "${YELLOW}[4/9] 检查/安装 uv...${NC}"
if ! command -v uv &> /dev/null && ! python3 -m uv --version &> /dev/null; then
    echo "正在安装 uv..."
    pip install uv
    echo -e "${GREEN}✓ uv 安装完成${NC}"
else
    echo -e "${GREEN}✓ uv 已安装${NC}"
fi
echo ""

# 创建虚拟环境
echo -e "${YELLOW}[5/9] 创建虚拟环境...${NC}"
if [ -d ".venv" ]; then
    echo "虚拟环境已存在，跳过创建"
else
    python3 -m uv venv
    echo -e "${GREEN}✓ 虚拟环境创建完成${NC}"
fi
echo ""

# 安装依赖（使用 pyproject.toml）
echo -e "${YELLOW}[6/9] 从 pyproject.toml 安装依赖...${NC}"
echo "正在安装项目依赖..."
python3 -m uv pip install --python .venv/bin/python -e . || {
    echo -e "${YELLOW}警告: 使用 -e . 安装失败，尝试手动安装依赖...${NC}"
    python3 -m uv pip install --python .venv/bin/python \
        django \
        pillow \
        mysqlclient \
        djangorestframework \
        django-filter
}
echo -e "${GREEN}✓ 依赖安装完成${NC}"
echo ""

# 配置数据库
echo -e "${YELLOW}[7/9] 配置数据库...${NC}"
echo "请输入 MySQL 配置信息："
read -p "数据库名称 [test1]: " DB_NAME
DB_NAME=${DB_NAME:-test1}

read -p "MySQL 用户名 [root]: " DB_USER
DB_USER=${DB_USER:-root}

read -sp "MySQL 密码: " DB_PASSWORD
echo ""

read -p "MySQL 主机 [127.0.0.1]: " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}

read -p "MySQL 端口 [3306]: " DB_PORT
DB_PORT=${DB_PORT:-3306}

# 测试数据库连接
echo "测试数据库连接..."
if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" &> /dev/null; then
    echo -e "${GREEN}✓ 数据库连接成功${NC}"
    
    # 创建数据库（如果不存在）
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e \
        "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
    echo -e "${GREEN}✓ 数据库 $DB_NAME 已准备就绪${NC}"
else
    echo -e "${RED}警告: 无法连接到数据库，请检查配置${NC}"
fi
echo ""

# 更新 settings.py
echo -e "${YELLOW}[8/9] 更新数据库配置...${NC}"
echo "请手动更新 phenotype_project/settings.py 中的数据库配置："
echo "  NAME: $DB_NAME"
echo "  USER: $DB_USER"
echo "  PASSWORD: ****"
echo "  HOST: $DB_HOST"
echo "  PORT: $DB_PORT"
echo ""

# 数据库迁移
echo -e "${YELLOW}[9/10] 执行数据库迁移...${NC}"
source .venv/bin/activate
python manage.py makemigrations
python manage.py migrate
echo -e "${GREEN}✓ 数据库迁移完成${NC}"
echo ""

# 创建超级用户
echo -e "${YELLOW}[10/10] 创建超级用户...${NC}"
echo "请按提示创建管理员账户："
python manage.py createsuperuser
echo ""

# 完成
echo "=================================="
echo -e "${GREEN}✓ 部署完成！${NC}"
echo "=================================="
echo ""
echo "已安装的包："
python3 -m uv pip list --python .venv/bin/python | grep -E "django|pillow|mysql|rest"
echo ""
echo "启动开发服务器："
echo "  source .venv/bin/activate"
echo "  python manage.py runserver"
echo ""
echo "访问地址："
echo "  首页: http://127.0.0.1:8000/"
echo "  管理后台: http://127.0.0.1:8000/admin/"
echo "  REST API: http://127.0.0.1:8000/api/"
echo ""
echo "详细文档请查看："
echo "  - DEPLOYMENT_GUIDE.md (完整部署指南)"
echo "  - README.md (项目说明)"
echo "  - API_DOCUMENTATION.md (API 文档)"
echo ""