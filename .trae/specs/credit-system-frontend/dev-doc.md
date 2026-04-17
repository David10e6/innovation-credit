# 创新学分管理系统 - 开发调试层文档

## 1. 后端环境配置

### 1.1 核心依赖
- Spring Boot 3.2.5
- Java 17
- Spring Security
- Spring Data JPA
- MySQL
- Redis
- Maven

### 1.2 数据库连接配置
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

### 1.3 Redis 连接配置
- **配置文件**：`application.yml`
- **配置示例**：
  ```yaml
  spring:
    redis:
      host: localhost
      port: 6379
      password: 
      database: 0
  ```

### 1.4 服务器配置
- **端口**：8080
- **上下文路径**：/api
- **配置示例**：
  ```yaml
  server:
    port: 8080
    servlet:
      context-path: /api
  ```

## 2. 跨域配置

### 2.1 前端环境
- **前端地址**：http://localhost:8081
- **需要特殊配置**：是

### 2.2 后端跨域配置
- **配置类**：`CorsConfig.java`
- **配置示例**：
  ```java
  @Configuration
  public class CorsConfig implements WebMvcConfigurer {
      @Override
      public void addCorsMappings(CorsRegistry registry) {
          registry.addMapping("/**")
                  .allowedOrigins("http://localhost:8081")
                  .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                  .allowedHeaders("*)")
                  .allowCredentials(true)
                  .maxAge(3600);
      }
  }
  ```

### 2.3 前端请求头配置
- **Content-Type**：application/json
- **Authorization**：Bearer {token}（登录后）
- **示例**：
  ```javascript
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };
  ```

## 3. 测试资源

### 3.1 多角色测试账号

| 角色 | 用户名 | 密码 | 学院 |
|------|--------|------|------|
| 学生 | student1 | 123456 | 计算机学院 |
| 学生 | student2 | 123456 | 电子信息学院 |
| 辅导员 | counselor1 | 123456 | 计算机学院 |
| 辅导员 | counselor2 | 123456 | 电子信息学院 |
| 管理员 | admin1 | 123456 | 学校管理 |

### 3.2 接口测试工具配置

#### 3.2.1 Postman 配置
- **环境变量**：
  - `BASE_URL`：http://localhost:8080/api
  - `TOKEN`：登录后获取的 token

- **请求示例**：
  - 登录：
    - URL：{{BASE_URL}}/auth/login
    - Method：POST
    - Body：
      ```json
      {
        "username": "student1",
        "password": "123456",
        "role": 1
      }
      ```
  - 获取学生信息：
    - URL：{{BASE_URL}}/student/info
    - Method：GET
    - Headers：
      ```
      Authorization: Bearer {{TOKEN}}
      ```

#### 3.2.2 Apifox 导入
- **导入文件**：`credit-system-api.json`
- **包含接口**：所有模块接口
- **测试用例**：包含登录、学分申请、审核等核心流程

## 4. 后端启动步骤

1. **启动数据库**：确保 MySQL 和 Redis 服务运行
2. **修改配置**：更新 `application.yml` 中的数据库和 Redis 连接信息
3. **编译项目**：执行 `mvn clean package`
4. **启动应用**：执行 `java -jar target/credit-system-1.0.0.jar`
5. **验证启动**：访问 http://localhost:8080/api/auth/login 测试接口

## 5. 常见问题及解决方案

### 5.1 跨域问题
- **症状**：前端请求报错 "CORS policy"
- **解决方案**：检查后端跨域配置是否正确，确保前端地址在允许列表中

### 5.2 数据库连接问题
- **症状**：启动失败，提示数据库连接错误
- **解决方案**：检查数据库服务是否运行，配置文件中的连接信息是否正确

### 5.3 Token 过期问题
- **症状**：请求返回 401 错误
- **解决方案**：重新登录获取新的 token，或实现 token 自动刷新机制

### 5.4 文件上传问题
- **症状**：文件上传失败
- **解决方案**：检查文件大小是否超过限制，文件格式是否符合要求