# 创新学分管理系统 - 接口层文档

## 1. 接口清单

### 1.1 认证模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/auth/login | POST | 用户登录 |
| http://localhost:8080/api/auth/logout | POST | 用户登出 |
| http://localhost:8080/api/auth/refresh | POST | 刷新 token |

#### 1.1.1 用户登录
- **请求地址**：http://localhost:8080/api/auth/login
- **请求方法**：POST
- **请求参数**：
  | 字段名 | 类型 | 是否必填 | 示例值 | 业务说明 |
  |-------|------|---------|--------|----------|
  | username | String | 是 | student1 | 用户名 |
  | password | String | 是 | 123456 | 密码 |
  | role | Integer | 是 | 1 | 角色类型（1=学生，2=辅导员，3=管理员） |

- **响应格式**：
  - 成功：
  ```json
  {
    "code": 200,
    "msg": "登录成功",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expire": 86400,
      "userInfo": {
        "userId": "1001",
        "username": "student1",
        "name": "张三",
        "role": 1,
        "college": "计算机学院"
      }
    }
  }
  ```
  - 失败：
  ```json
  {
    "code": 401,
    "msg": "用户名或密码错误",
    "data": null
  }
  ```

### 1.2 学生模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/student/info | GET | 获取学生信息 |
| http://localhost:8080/api/student/credit/list | GET | 获取学分列表 |
| http://localhost:8080/api/student/credit/apply | POST | 学分申请 |
| http://localhost:8080/api/student/credit/apply/list | GET | 获取申请记录列表 |
| http://localhost:8080/api/student/credit/apply/detail | GET | 获取申请详情 |

#### 1.2.1 获取学生信息
- **请求地址**：http://localhost:8080/api/student/info
- **请求方法**：GET
- **请求参数**：无
- **响应格式**：
  - 成功：
  ```json
  {
    "code": 200,
    "msg": "获取成功",
    "data": {
      "studentId": "1001",
      "name": "张三",
      "college": "计算机学院",
      "creditTotal": 120.5
    }
  }
  ```

#### 1.2.2 学分申请
- **请求地址**：http://localhost:8080/api/student/credit/apply
- **请求方法**：POST
- **请求参数**：
  | 字段名 | 类型 | 是否必填 | 示例值 | 业务说明 |
  |-------|------|---------|--------|----------|
  | activityName | String | 是 | "科技创新大赛" | 活动名称 |
  | creditValue | Double | 是 | 2.5 | 申请学分 |
  | activityType | Integer | 是 | 1 | 活动类型（1=科技竞赛，2=学术论文，3=实践活动） |
  | description | String | 否 | "参加省级科技创新大赛获得二等奖" | 活动描述 |
  | attachment | MultipartFile | 否 | 文件 | 附件（如证书扫描件） |

- **响应格式**：
  - 成功：
  ```json
  {
    "code": 200,
    "msg": "申请成功",
    "data": {
      "applyId": "A20240101001",
      "auditStatus": 1
    }
  }
  ```

### 1.3 辅导员模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/counselor/apply/list | GET | 获取待审核列表 |
| http://localhost:8080/api/counselor/apply/audit | POST | 审核学分申请 |
| http://localhost:8080/api/counselor/student/list | GET | 获取学生列表 |

#### 1.3.1 获取待审核列表
- **请求地址**：http://localhost:8080/api/counselor/apply/list
- **请求方法**：GET
- **请求参数**：
  | 字段名 | 类型 | 是否必填 | 示例值 | 业务说明 |
  |-------|------|---------|--------|----------|
  | page | Integer | 是 | 1 | 页码 |
  | size | Integer | 是 | 10 | 页大小 |
  | status | Integer | 否 | 1 | 审核状态（1=待审核） |

- **响应格式**：
  - 成功：
  ```json
  {
    "code": 200,
    "msg": "获取成功",
    "data": {
      "total": 20,
      "list": [
        {
          "applyId": "A20240101001",
          "studentId": "1001",
          "studentName": "张三",
          "activityName": "科技创新大赛",
          "creditValue": 2.5,
          "auditStatus": 1,
          "applyTime": "2024-01-01 10:00:00"
        }
      ]
    }
  }
  ```

#### 1.3.2 审核学分申请
- **请求地址**：http://localhost:8080/api/counselor/apply/audit
- **请求方法**：POST
- **请求参数**：
  | 字段名 | 类型 | 是否必填 | 示例值 | 业务说明 |
  |-------|------|---------|--------|----------|
  | applyId | String | 是 | "A20240101001" | 申请ID |
  | status | Integer | 是 | 2 | 审核状态（2=通过，3=驳回） |
  | comment | String | 否 | "同意申请" | 审核意见 |

- **响应格式**：
  - 成功：
  ```json
  {
    "code": 200,
    "msg": "审核成功",
    "data": null
  }
  ```

### 1.4 管理员模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/admin/user/list | GET | 获取用户列表 |
| http://localhost:8080/api/admin/user/add | POST | 添加用户 |
| http://localhost:8080/api/admin/user/update | PUT | 更新用户 |
| http://localhost:8080/api/admin/user/delete | DELETE | 删除用户 |
| http://localhost:8080/api/admin/credit/statistics | GET | 学分统计 |

## 2. 业务状态码

| 状态码 | 说明 |
|-------|------|
| 200 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录 |
| 403 | 无权限 |
| 500 | 服务端错误 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求过于频繁 |

## 3. 接口调用规则

### 3.1 接口基地址
- 开发环境：http://localhost:8080/api
- 测试环境：http://test.example.com/api

### 3.2 认证规则
- Token 传递方式：请求头 Authorization: Bearer {token}
- Token 有效期：24小时（86400秒）
- 免登录接口列表：
  - /api/auth/login
  - /api/auth/refresh

### 3.3 特殊接口

#### 3.3.1 文件上传
- 参数名：attachment
- 格式限制：jpg, jpeg, png, pdf, doc, docx
- 大小限制：最大10MB
- 返回值：文件存储路径

#### 3.3.2 分页接口
- 页码参数：page（从1开始）
- 页大小参数：size
- 返回结构：
  ```json
  {
    "total": 总记录数,
    "list": [数据列表]
  }
  ```