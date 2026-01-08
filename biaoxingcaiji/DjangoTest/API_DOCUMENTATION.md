# REST API 文档

## 📡 API 概览

表型采集系统提供完整的 RESTful API，支持所有数据模型的 CRUD 操作。

## 🔗 基础信息

- **Base URL**: `http://127.0.0.1:8000/api/`
- **认证方式**: Session Authentication / Basic Authentication
- **数据格式**: JSON
- **分页**: 默认每页 20 条记录

## 📚 API 端点

### 1. 种质/突变体 (Mutants)

**列表**: `GET /api/mutants/`
```json
{
    "count": 100,
    "next": "http://127.0.0.1:8000/api/mutants/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "mutant_code": "M0001",
            "name": "突变体1号",
            "description": "描述信息",
            "created_at": "2025-01-01T00:00:00Z",
            "updated_at": "2025-01-01T00:00:00Z"
        }
    ]
}
```

**详情**: `GET /api/mutants/{id}/`

**创建**: `POST /api/mutants/`
```json
{
    "mutant_code": "M0001",
    "name": "突变体1号",
    "description": "描述信息"
}
```

**更新**: `PUT /api/mutants/{id}/` 或 `PATCH /api/mutants/{id}/`

**删除**: `DELETE /api/mutants/{id}/`

**搜索**: `GET /api/mutants/?search=M0001`

---

### 2. 实验 (Experiments)

**列表**: `GET /api/experiments/`

**详情**: `GET /api/experiments/{id}/`
- 包含关联的小区和动物数据

**创建**: `POST /api/experiments/`
```json
{
    "name": "2025年春季水稻实验",
    "year": 2025,
    "experiment_type": "plant",
    "location": "海南三亚",
    "description": "水稻表型鉴定",
    "status": "ongoing",
    "start_date": "2025-03-01",
    "created_name": "张三"
}
```

**过滤**:
- `GET /api/experiments/?year=2025`
- `GET /api/experiments/?experiment_type=plant`
- `GET /api/experiments/?status=ongoing`
- `GET /api/experiments/?location=海南`

**自定义动作**:
- `GET /api/experiments/{id}/fields/` - 获取实验的所有小区
- `GET /api/experiments/{id}/animals/` - 获取实验的所有动物
- `GET /api/experiments/{id}/statistics/` - 获取实验统计信息

---

### 3. 小区 (Fields)

**列表**: `GET /api/fields/`

**详情**: `GET /api/fields/{id}/`
- 包含关联的观测数据和媒体文件

**创建**: `POST /api/fields/`
```json
{
    "field_code": "A001",
    "experiment": "uuid-of-experiment",
    "mutant": 1,
    "status": "not_collected",
    "description": "第1号小区"
}
```

**过滤**:
- `GET /api/fields/?experiment={uuid}`
- `GET /api/fields/?mutant={id}`
- `GET /api/fields/?status=not_collected`

**自定义动作**:
- `GET /api/fields/{id}/observations/` - 获取小区的所有观测数据

---

### 4. 动物个体 (Animals)

**列表**: `GET /api/animals/`

**详情**: `GET /api/animals/{id}/`
- 包含关联的观测数据和媒体文件

**创建**: `POST /api/animals/`
```json
{
    "experiment": "uuid-of-experiment",
    "ear_tag": "PIG0001",
    "building": "1号舍",
    "pen": "1号栏",
    "sex": "M",
    "birth_date": "2024-12-01",
    "birth_weight": 1.5,
    "status": "active"
}
```

**过滤**:
- `GET /api/animals/?experiment={uuid}`
- `GET /api/animals/?sex=M`
- `GET /api/animals/?status=active`
- `GET /api/animals/?building=1号舍`

**自定义动作**:
- `GET /api/animals/{id}/observations/` - 获取动物的所有观测数据

---

### 5. 性状定义 (Traits)

**列表**: `GET /api/traits/`

**创建**: `POST /api/traits/`
```json
{
    "code": "PH",
    "name": "株高",
    "unit": "cm",
    "data_type": "number",
    "description": "植株高度"
}
```

**过滤**:
- `GET /api/traits/?data_type=number`
- `GET /api/traits/?code=PH`

---

### 6. 观测数据 (Observations)

**列表**: `GET /api/observations/`

**创建**: `POST /api/observations/`
```json
{
    "field_link": "uuid-of-field",
    "trait": "uuid-of-trait",
    "value": "120.5",
    "observer": "张三"
}
```

或者（动物观测）:
```json
{
    "animal_link": "uuid-of-animal",
    "trait": "uuid-of-trait",
    "value": "85.2",
    "observer": "李四"
}
```

**过滤**:
- `GET /api/observations/?trait={uuid}`
- `GET /api/observations/?field_link={uuid}`
- `GET /api/observations/?animal_link={uuid}`
- `GET /api/observations/?observer=张三`

**自定义动作**:
- `GET /api/observations/by_field/?field_id={uuid}` - 按小区查询
- `GET /api/observations/by_animal/?animal_id={uuid}` - 按动物查询

---

### 7. 多媒体文件 (Media)

**列表**: `GET /api/media/`

**创建**: `POST /api/media/`
```json
{
    "field_link": "uuid-of-field",
    "file_path": "file-upload",
    "media_type": "image",
    "capture_time": "2025-01-01T12:00:00Z",
    "captured_by": "张三",
    "description": "照片描述"
}
```

**过滤**:
- `GET /api/media/?media_type=image`
- `GET /api/media/?field_link={uuid}`
- `GET /api/media/?animal_link={uuid}`

---

## 🔍 通用查询参数

### 分页
- `?page=2` - 第2页
- `?page_size=50` - 每页50条（覆盖默认的20条）

### 搜索
- `?search=关键词` - 全文搜索

### 排序
- `?ordering=field_name` - 升序
- `?ordering=-field_name` - 降序
- `?ordering=field1,-field2` - 多字段排序

### 过滤
- `?field_name=value` - 精确匹配
- `?field_name__contains=value` - 包含
- `?field_name__gte=value` - 大于等于
- `?field_name__lte=value` - 小于等于

## 🔐 认证

### Session 认证（推荐用于浏览器）
1. 访问 `/api-auth/login/` 登录
2. 之后的请求会自动携带 session cookie

### Basic 认证（推荐用于脚本）
```bash
curl -u username:password http://127.0.0.1:8000/api/mutants/
```

### Python 示例
```python
import requests

# 登录
session = requests.Session()
session.auth = ('username', 'password')

# 获取数据
response = session.get('http://127.0.0.1:8000/api/mutants/')
data = response.json()

# 创建数据
new_mutant = {
    'mutant_code': 'M0001',
    'name': '测试突变体'
}
response = session.post('http://127.0.0.1:8000/api/mutants/', json=new_mutant)
```

## 📊 响应格式

### 成功响应
```json
{
    "id": 1,
    "field": "value",
    ...
}
```

### 列表响应（分页）
```json
{
    "count": 100,
    "next": "http://127.0.0.1:8000/api/endpoint/?page=2",
    "previous": null,
    "results": [...]
}
```

### 错误响应
```json
{
    "detail": "错误信息"
}
```

或

```json
{
    "field_name": ["错误信息"]
}
```

## 🌐 浏览器访问

访问 `http://127.0.0.1:8000/api/` 可以在浏览器中查看和测试所有 API 端点。

Django REST Framework 提供了友好的可浏览 API 界面，支持：
- 查看 API 文档
- 测试 API 请求
- 查看响应数据
- 表单提交数据

## 📝 使用示例

### 创建完整的实验流程

```python
import requests

session = requests.Session()
session.auth = ('admin', 'password')
base_url = 'http://127.0.0.1:8000/api'

# 1. 创建实验
experiment = session.post(f'{base_url}/experiments/', json={
    'name': '2025年水稻实验',
    'year': 2025,
    'experiment_type': 'plant',
    'start_date': '2025-03-01',
    'status': 'ongoing'
}).json()

# 2. 创建小区
field = session.post(f'{base_url}/fields/', json={
    'field_code': 'A001',
    'experiment': experiment['id'],
    'status': 'not_collected'
}).json()

# 3. 创建性状定义
trait = session.post(f'{base_url}/traits/', json={
    'code': 'PH',
    'name': '株高',
    'unit': 'cm',
    'data_type': 'number'
}).json()

# 4. 记录观测数据
observation = session.post(f'{base_url}/observations/', json={
    'field_link': field['id'],
    'trait': trait['id'],
    'value': '120.5',
    'observer': '张三'
}).json()

print('实验创建完成！')
```

---

**更多信息请访问**: http://127.0.0.1:8000/api/