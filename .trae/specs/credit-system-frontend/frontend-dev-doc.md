# 创新学分管理系统 - 前端开发技术文档

## 1. 接口层

### 1.1 接口清单

#### 1.1.1 认证模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/auth/login | POST | 用户登录 |
| http://localhost:8080/api/auth/logout | POST | 用户登出 |
| http://localhost:8080/api/auth/refresh | POST | 刷新 token |

##### 1.1.1.1 用户登录
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

#### 1.1.2 学生模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/student/info | GET | 获取学生信息 |
| http://localhost:8080/api/student/credit/list | GET | 获取学分列表 |
| http://localhost:8080/api/student/credit/apply | POST | 学分申请 |
| http://localhost:8080/api/student/credit/apply/list | GET | 获取申请记录列表 |
| http://localhost:8080/api/student/credit/apply/detail | GET | 获取申请详情 |

##### 1.1.2.1 获取学生信息
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

##### 1.1.2.2 学分申请
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

#### 1.1.3 辅导员模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/counselor/apply/list | GET | 获取待审核列表 |
| http://localhost:8080/api/counselor/apply/audit | POST | 审核学分申请 |
| http://localhost:8080/api/counselor/student/list | GET | 获取学生列表 |

##### 1.1.3.1 获取待审核列表
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

##### 1.1.3.2 审核学分申请
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

#### 1.1.4 管理员模块

| 接口地址 | 请求方法 | 功能描述 |
|---------|---------|----------|
| http://localhost:8080/api/admin/user/list | GET | 获取用户列表 |
| http://localhost:8080/api/admin/user/add | POST | 添加用户 |
| http://localhost:8080/api/admin/user/update | PUT | 更新用户 |
| http://localhost:8080/api/admin/user/delete | DELETE | 删除用户 |
| http://localhost:8080/api/admin/credit/statistics | GET | 学分统计 |

### 1.2 业务状态码

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

### 1.3 接口调用规则

#### 1.3.1 接口基地址
- 开发环境：http://localhost:8080/api
- 测试环境：http://test.example.com/api

#### 1.3.2 认证规则
- Token 传递方式：请求头 Authorization: Bearer {token}
- Token 有效期：24小时（86400秒）
- 免登录接口列表：
  - /api/auth/login
  - /api/auth/refresh

#### 1.3.3 特殊接口

##### 1.3.3.1 文件上传
- 参数名：attachment
- 格式限制：jpg, jpeg, png, pdf, doc, docx
- 大小限制：最大10MB
- 返回值：文件存储路径

##### 1.3.3.2 分页接口
- 页码参数：page（从1开始）
- 页大小参数：size
- 返回结构：
  ```json
  {
    "total": 总记录数,
    "list": [数据列表]
  }
  ```

## 2. 数据层

### 2.1 核心实体类字段

#### 2.1.1 Student（学生）
| 字段名 | 类型 | 说明 | 示例值 |
|-------|------|------|--------|
| studentId | String | 学号 | "1001" |
| name | String | 姓名 | "张三" |
| college | String | 学院 | "计算机学院" |
| creditTotal | Double | 总学分 | 120.5 |
| username | String | 用户名 | "student1" |
| password | String | 密码（加密存储） | "$2a$10$..." |
| role | Integer | 角色类型 | 1 |
| createTime | String | 创建时间 | "2024-01-01 00:00:00" |
| updateTime | String | 更新时间 | "2024-01-01 00:00:00" |

#### 2.1.2 ApplyRecord（申请记录）
| 字段名 | 类型 | 说明 | 示例值 |
|-------|------|------|--------|
| applyId | String | 申请ID | "A20240101001" |
| studentId | String | 学生学号 | "1001" |
| activityName | String | 活动名称 | "科技创新大赛" |
| activityType | Integer | 活动类型 | 1 |
| creditValue | Double | 申请学分 | 2.5 |
| description | String | 活动描述 | "参加省级科技创新大赛获得二等奖" |
| attachmentPath | String | 附件路径 | "/uploads/2024/01/01/certificate.pdf" |
| auditStatus | Integer | 审核状态 | 1 |
| auditComment | String | 审核意见 | "同意申请" |
| counselorId | String | 辅导员ID | "2001" |
| applyTime | String | 申请时间 | "2024-01-01 10:00:00" |
| auditTime | String | 审核时间 | "2024-01-02 14:00:00" |

### 2.2 枚举值说明

#### 2.2.1 审核状态（auditStatus）
| 枚举值 | 说明 |
|-------|------|
| 1 | 待审核 |
| 2 | 通过 |
| 3 | 驳回 |

#### 2.2.2 活动类型（activityType）
| 枚举值 | 说明 |
|-------|------|
| 1 | 科技竞赛 |
| 2 | 学术论文 |
| 3 | 实践活动 |
| 4 | 志愿服务 |
| 5 | 其他 |

#### 2.2.3 角色类型（role）
| 枚举值 | 说明 |
|-------|------|
| 1 | 学生 |
| 2 | 辅导员 |
| 3 | 学校管理员 |

### 2.3 数据格式约定

#### 2.3.1 字段命名规则
- 后端：采用驼峰命名法（camelCase）
- 前端：与后端保持一致，使用驼峰命名法

#### 2.3.2 日期格式
- 统一使用：yyyy-MM-dd HH:mm:ss
- 示例："2024-01-01 10:00:00"

#### 2.3.3 空值处理
- 字符串类型：空值使用空字符串（""）
- 数字类型：空值使用 0 或 null
- 日期类型：空值使用 null
- 布尔类型：空值使用 false

## 3. 开发调试层

### 3.1 后端环境配置

#### 3.1.1 核心依赖
- Spring Boot 3.2.5
- Java 17
- Spring Security
- Spring Data JPA
- MySQL
- Redis
- Maven

#### 3.1.2 数据库连接配置
- **配置文件**：`application.yml`
- **配置示例**：
  ```yaml
  spring:
    datasource:
      url: jdbc:mysql://localhost:3306/credit_system?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
      username: root
      password: 123456
      driver-class-name: com.mysql.cj.jdbc.Driver
    jpa:
      hibernate:
        ddl-auto: update
      show-sql: true
  ```

### 3.2 跨域配置
- **前端地址**：http://localhost:8081
- **后端跨域配置**：已配置允许前端地址访问
- **前端请求头**：
  ```javascript
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };
  ```

### 3.3 测试资源

#### 3.3.1 多角色测试账号

| 角色 | 用户名 | 密码 | 学院 |
|------|--------|------|------|
| 学生 | student1 | 123456 | 计算机学院 |
| 学生 | student2 | 123456 | 电子信息学院 |
| 辅导员 | counselor1 | 123456 | 计算机学院 |
| 辅导员 | counselor2 | 123456 | 电子信息学院 |
| 管理员 | admin1 | 123456 | 学校管理 |

## 4. 业务逻辑层

### 4.1 核心业务流程

#### 4.1.1 学生学分申请流程
1. 选择活动类型
2. 填写申请信息
3. 上传附件（可选）
4. 提交申请
5. 查询申请进度

#### 4.1.2 辅导员审核流程
1. 查看待审核列表
2. 审核申请
3. 填写审核意见

### 4.2 权限边界

#### 4.2.1 学生权限
- **可访问接口**：
  - /api/auth/login
  - /api/auth/logout
  - /api/auth/refresh
  - /api/student/info
  - /api/student/credit/list
  - /api/student/credit/apply
  - /api/student/credit/apply/list
  - /api/student/credit/apply/detail

#### 4.2.2 辅导员权限
- **可访问接口**：
  - /api/auth/login
  - /api/auth/logout
  - /api/auth/refresh
  - /api/counselor/apply/list
  - /api/counselor/apply/audit
  - /api/counselor/student/list

#### 4.2.3 管理员权限
- **可访问接口**：
  - /api/auth/login
  - /api/auth/logout
  - /api/auth/refresh
  - /api/admin/user/list
  - /api/admin/user/add
  - /api/admin/user/update
  - /api/admin/user/delete
  - /api/admin/credit/statistics

### 4.3 业务限制
- **单次申请最大值**：5.0 学分
- **年度申请最大值**：15.0 学分
- **附件格式限制**：jpg、jpeg、png、pdf、doc、docx
- **附件大小限制**：最大 10MB

## 5. 前端开发建议

### 5.1 技术选型
- **框架**：推荐使用 Vue 3 + Vite 或 React + Vite
- **状态管理**：Pinia 或 Redux
- **HTTP 客户端**：Axios
- **UI 组件库**：Element Plus 或 Ant Design

### 5.2 项目结构
```
src/
├── api/           # API 调用封装
├── components/    # 公共组件
├── views/         # 页面组件
│   ├── auth/      # 认证相关页面
│   ├── student/   # 学生相关页面
│   ├── counselor/ # 辅导员相关页面
│   └── admin/     # 管理员相关页面
├── store/         # 状态管理
├── utils/         # 工具函数
└── router/        # 路由配置
```

### 5.3 关键实现
- **认证拦截**：使用 Axios 拦截器处理 token 过期
- **权限控制**：基于角色的路由守卫
- **文件上传**：使用 FormData 处理文件上传
- **错误处理**：统一的错误处理机制

### 5.4 开发注意事项
- 严格按照接口文档的请求参数和响应格式开发
- 注意处理跨域问题，确保前端请求头配置正确
- 使用测试账号进行充分测试
- 遵循后端的数据格式约定，特别是日期格式和空值处理

## 6. 附件

### 6.1 接口测试工具配置
- **Postman 环境变量**：
  - `BASE_URL`：http://localhost:8080/api
  - `TOKEN`：登录后获取的 token

### 6.2 常见问题及解决方案
- **跨域问题**：检查后端跨域配置是否正确
- **Token 过期**：实现 token 自动刷新机制
- **文件上传失败**：检查文件大小和格式是否符合要求
- **权限错误**：确保用户角色与访问接口匹配