# 创新学分管理系统 - 数据层文档

## 1. 核心实体类字段

### 1.1 Student（学生）
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

### 1.2 ApplyRecord（申请记录）
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

### 1.3 Counselor（辅导员）
| 字段名 | 类型 | 说明 | 示例值 |
|-------|------|------|--------|
| counselorId | String | 辅导员ID | "2001" |
| name | String | 姓名 | "李老师" |
| college | String | 所属学院 | "计算机学院" |
| username | String | 用户名 | "counselor1" |
| password | String | 密码（加密存储） | "$2a$10$..." |
| role | Integer | 角色类型 | 2 |
| createTime | String | 创建时间 | "2024-01-01 00:00:00" |
| updateTime | String | 更新时间 | "2024-01-01 00:00:00" |

### 1.4 Admin（管理员）
| 字段名 | 类型 | 说明 | 示例值 |
|-------|------|------|--------|
| adminId | String | 管理员ID | "3001" |
| name | String | 姓名 | "王管理员" |
| username | String | 用户名 | "admin1" |
| password | String | 密码（加密存储） | "$2a$10$..." |
| role | Integer | 角色类型 | 3 |
| createTime | String | 创建时间 | "2024-01-01 00:00:00" |
| updateTime | String | 更新时间 | "2024-01-01 00:00:00" |

## 2. 枚举值说明

### 2.1 审核状态（auditStatus）
| 枚举值 | 说明 |
|-------|------|
| 1 | 待审核 |
| 2 | 通过 |
| 3 | 驳回 |

### 2.2 活动类型（activityType）
| 枚举值 | 说明 |
|-------|------|
| 1 | 科技竞赛 |
| 2 | 学术论文 |
| 3 | 实践活动 |
| 4 | 志愿服务 |
| 5 | 其他 |

### 2.3 角色类型（role）
| 枚举值 | 说明 |
|-------|------|
| 1 | 学生 |
| 2 | 辅导员 |
| 3 | 学校管理员 |

## 3. 数据格式约定

### 3.1 字段命名规则
- 后端：采用驼峰命名法（camelCase）
- 前端：与后端保持一致，使用驼峰命名法

### 3.2 日期格式
- 统一使用：yyyy-MM-dd HH:mm:ss
- 示例："2024-01-01 10:00:00"

### 3.3 空值处理
- 字符串类型：空值使用空字符串（""）
- 数字类型：空值使用 0 或 null
- 日期类型：空值使用 null
- 布尔类型：空值使用 false

### 3.4 数据类型映射
| 后端类型 | 前端类型 | 说明 |
|---------|---------|------|
| String | String | 字符串 |
| Integer | Number | 整数 |
| Double | Number | 浮点数 |
| Boolean | Boolean | 布尔值 |
| LocalDateTime | String | 日期时间，格式为 yyyy-MM-dd HH:mm:ss |
| MultipartFile | File | 文件上传 |

### 3.5 响应数据结构
- 统一响应格式：
  ```json
  {
    "code": 状态码,
    "msg": "消息",
    "data": 数据
  }
  ```
- 分页响应格式：
  ```json
  {
    "code": 200,
    "msg": "获取成功",
    "data": {
      "total": 总记录数,
      "list": [数据列表]
    }
  }
  ```