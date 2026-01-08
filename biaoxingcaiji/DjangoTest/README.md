# 表型采集系统 (Phenotype Collection System)

基于 Django REST Framework 的表型数据采集管理系统，支持植物和动物实验数据的采集、管理和分析。

## 🚀 快速部署（新环境）

### 自动部署（推荐）

#### Linux/macOS
```bash
# 克隆或复制项目到新电脑
cd django_to_pengjiawen

# 运行自动部署脚本
./deploy.sh
```

#### Windows
```cmd
# 进入项目目录
cd django_to_pengjiawen

# 运行自动部署脚本
deploy.bat
```

### 手动部署

详细步骤请查看 **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**

---

## 📋 系统要求

- **Python**: 3.8+
- **MySQL**: 5.7+ 或 MariaDB 10.2+
- **uv**: Python 包管理器

---

## 🎯 快速开始（已部署环境）

### 1. 激活虚拟环境

```bash
source .venv/bin/activate  # Linux/macOS
# 或
.venv\Scripts\activate     # Windows
```

### 2. 启动服务器

```bash
python manage.py runserver
```

### 3. 访问系统

- **首页**: http://127.0.0.1:8000/
- **管理后台**: http://127.0.0.1:8000/admin/
- **REST API**: http://127.0.0.1:8000/api/

---

## 📦 功能特性

### 核心功能
- ✅ **实验管理**: 创建和管理植物/动物实验项目
- ✅ **小区管理**: 管理实验小区和种质信息
- ✅ **动物管理**: 记录动物个体信息（耳号、血统等）
- ✅ **性状定义**: 灵活定义各类性状指标
- ✅ **数据采集**: 记录观测数据和测量值
- ✅ **多媒体支持**: 上传照片和视频记录

### REST API 功能
- ✅ **完整的 CRUD 操作**: 所有模型支持增删改查
- ✅ **高级过滤**: 支持多字段过滤和搜索
- ✅ **分页**: 自动分页，默认每页 20 条
- ✅ **排序**: 支持多字段排序
- ✅ **认证**: Session 和 Basic 认证
- ✅ **可浏览 API**: 浏览器友好的 API 界面
- ✅ **关联数据**: 自动包含关联对象信息

---

## 🗄️ 数据模型

| 模型 | 说明 | 数据表 |
|------|------|--------|
| Mutant | 种质/突变体 | `ccge_mutants` |
| Experiment | 实验项目 | `pt_experiments` |
| Field | 小区（植物实验） | `pt_fields` |
| Animal | 动物个体（动物实验） | `pt_animals` |
| TraitDefinition | 性状定义 | `pt_trait_definitions` |
| Observation | 观测数据 | `pt_observations` |
| MediaFile | 多媒体文件 | `pt_media_files` |

---

## 📡 REST API 端点

| 端点 | 说明 | URL |
|------|------|-----|
| 种质列表 | GET/POST | `/api/mutants/` |
| 实验列表 | GET/POST | `/api/experiments/` |
| 小区列表 | GET/POST | `/api/fields/` |
| 动物列表 | GET/POST | `/api/animals/` |
| 性状定义 | GET/POST | `/api/traits/` |
| 观测数据 | GET/POST | `/api/observations/` |
| 多媒体文件 | GET/POST | `/api/media/` |

详细 API 文档请查看 **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)**

---

## 💡 使用示例

### Python 脚本调用 API

```python
import requests

# 创建 session
session = requests.Session()
session.auth = ('username', 'password')

# 获取实验列表
response = session.get('http://127.0.0.1:8000/api/experiments/')
experiments = response.json()

# 创建新实验
new_experiment = {
    'name': '2025年春季实验',
    'year': 2025,
    'experiment_type': 'plant',
    'start_date': '2025-03-01',
    'status': 'ongoing'
}
response = session.post('http://127.0.0.1:8000/api/experiments/', json=new_experiment)
```

### cURL 调用 API

```bash
# 获取实验列表
curl -u username:password http://127.0.0.1:8000/api/experiments/

# 创建新实验
curl -u username:password \
  -H "Content-Type: application/json" \
  -d '{"name":"2025年实验","year":2025,"experiment_type":"plant","start_date":"2025-03-01"}' \
  http://127.0.0.1:8000/api/experiments/
```

---

## 🔧 使用 uv 管理包

### 重要说明

本项目使用 **uv** 管理虚拟环境。uv 创建的虚拟环境不包含 pip，需要使用系统的 uv 来安装包。

### 安装新包

```bash
# 正确方式
python3 -m uv pip install --python .venv/bin/python package-name

# 查看已安装的包
python3 -m uv pip list --python .venv/bin/python
```

---

## 🛠️ 技术栈

| 组件 | 版本 | 说明 |
|------|------|------|
| Python | 3.10+ | 编程语言 |
| Django | 5.2.9 | Web 框架 |
| Django REST Framework | 3.16.1 | REST API 框架 |
| MySQL | 5.7+ | 数据库 |
| mysqlclient | 2.2.7 | MySQL 客户端 |
| Pillow | 12.0.0 | 图像处理 |
| django-filter | 25.2 | 过滤器 |
| uv | latest | 包管理器 |

---

## 📚 完整文档

| 文档 | 说明 |
|------|------|
| **[README.md](README.md)** | 项目概述（本文件） |
| **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** | 完整部署指南 ⭐ |
| **[QUICKSTART.md](QUICKSTART.md)** | 快速启动指南 |
| **[DATABASE_SETUP.md](DATABASE_SETUP.md)** | 数据库配置说明 |
| **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** | REST API 完整文档 |

---

## 📂 项目结构

```
django_to_pengjiawen/
├── deploy.sh              # Linux/macOS 自动部署脚本
├── deploy.bat             # Windows 自动部署脚本
├── manage.py              # Django 管理脚本
├── pyproject.toml         # 项目配置
├── 文档/
│   ├── README.md          # 项目说明
│   ├── DEPLOYMENT_GUIDE.md    # 部署指南
│   ├── QUICKSTART.md      # 快速启动
│   ├── DATABASE_SETUP.md  # 数据库配置
│   └── API_DOCUMENTATION.md   # API 文档
├── phenotype_project/     # Django 项目配置
│   ├── settings.py        # 项目设置
│   ├── urls.py            # URL 路由
│   └── wsgi.py            # WSGI 配置
└── phenotype/             # 表型采集应用
    ├── models.py          # 数据模型
    ├── serializers.py     # DRF 序列化器
    ├── views.py           # API ViewSets
    ├── urls.py            # 应用 URL
    └── admin.py           # 管理后台
```

---

## ⚠️ 注意事项

1. **使用 uv 安装包**: 不要使用 `pip install`，使用 `python3 -m uv pip install --python .venv/bin/python`
2. **数据库配置**: 确保MySQL服务已启动，数据库 `test1` 已创建
3. **密码配置**: 根据实际情况修改 `phenotype_project/settings.py` 中的数据库密码
4. **API 认证**: 需要登录后才能进行写操作（POST/PUT/DELETE）
5. **生产环境**: 修改 SECRET_KEY 和 DEBUG 设置

---

## 🎯 为什么使用 uv？

- ⚡ **更快**: 比 pip 快 10-100 倍
- 🔒 **可靠**: 更好的依赖解析
- 📦 **简洁**: 统一的包管理体验
- 🚀 **现代**: Python 包管理的未来

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

请根据实际情况添加许可证信息。

---

## 📞 获取帮助

如果遇到问题：

1. 查看 **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** 中的常见问题排查
2. 检查项目文档
3. 运行 `python manage.py check` 检查配置
4. 查看日志文件

---

**祝您使用愉快！** 🎉