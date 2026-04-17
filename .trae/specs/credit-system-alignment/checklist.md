# 创新学分管理系统 - 前后端对齐验证清单

## API配置
- [x] 1.1 检查axios配置文件中的baseURL是否设置为 http://localhost:8080/api
- [x] 1.2 检查请求拦截器是否正确从localStorage获取token并添加到请求头
- [x] 1.3 检查响应拦截器是否正确处理后端返回的错误状态
- [x] 1.4 验证API调用是否能正常访问后端接口

## 路由配置
- [x] 2.1 检查路由配置是否使用hash模式（createWebHashHistory）
- [x] 2.2 测试页面刷新是否不会出现404错误
- [x] 2.3 检查路由守卫是否正确处理登录状态

## 核心接口调用
- [x] 3.1 验证登录接口（/auth/login）调用正确
- [x] 3.2 验证注册接口（/auth/register）调用正确
- [x] 3.3 验证校内活动学分申请接口（/credit-application/internal）调用正确
- [x] 3.4 验证校外活动学分申请接口（/credit-application/external）调用正确
- [x] 3.5 验证撤回学分申请接口（/credit-application/withdraw/{id}）调用正确
- [x] 3.6 验证重新提交学分申请接口（/credit-application/resubmit）调用正确
- [x] 3.7 验证获取学生学分申请记录接口（/credit-application/student/{studentId}）调用正确
- [x] 3.8 验证获取学院学分申请记录接口（/credit-application/college/{collegeId}）调用正确
- [x] 3.9 验证获取学校学分申请记录接口（/credit-application/school）调用正确
- [x] 3.10 验证学院审核学分申请接口（/audit/college）调用正确
- [x] 3.11 验证学校审核学分申请接口（/audit/school）调用正确
- [x] 3.12 验证获取学院待审核学分申请接口（/audit/college/pending/{collegeId}）调用正确
- [x] 3.13 验证获取学校待审核学分申请接口（/audit/school/pending）调用正确

## 认证和权限控制
- [x] 4.1 测试登录功能，验证token正确存储
- [x] 4.2 测试未登录状态下访问权限页面是否会重定向到登录页
- [x] 4.3 测试不同角色（学生、辅导员、学校管理员）是否只能访问对应权限的页面
- [x] 4.4 测试token过期或无效时的处理

## 数据格式
- [x] 5.1 验证前端使用的字段名与后端一致（驼峰命名）
- [x] 5.2 验证日期格式是否统一为 yyyy-MM-dd HH:mm:ss
- [x] 5.3 验证空值是否正确处理为"-"或空，避免展示"null"字符串
- [x] 5.4 验证枚举值是否与后端一致（如审核状态）

## 完整业务流程
- [x] 6.1 测试完整的学生申请流程
- [x] 6.2 测试完整的审核流程（学院审核→学校审核）
- [x] 6.3 测试权限控制是否生效
- [x] 6.4 测试异常场景（参数错误、未登录访问）的处理

## 跨域和环境配置
- [x] 7.1 验证跨域配置是否正确，前端能正常访问后端接口
- [x] 7.2 验证开发环境配置是否正确