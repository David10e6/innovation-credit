# 创新学分管理系统 - 前后端对齐实现计划

## [x] Task 1: 统一API配置
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 更新axios配置，设置正确的baseURL为 http://localhost:8080/api
  - 实现请求拦截器，从localStorage获取token并添加到请求头
  - 实现响应拦截器，统一处理后端返回的错误状态
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: axios配置文件中的baseURL正确设置
  - `programmatic` TR-1.2: 请求拦截器正确添加Authorization头
  - `programmatic` TR-1.3: 响应拦截器正确处理错误状态
- **Notes**: 参考指导书中的Axios配置示例

## [x] Task 2: 实现hash模式路由
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 修改路由配置，使用createWebHashHistory替代createWebHistory
  - 确保路由守卫正确处理登录状态
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-2.1: 路由配置使用hash模式
  - `programmatic` TR-2.2: 页面刷新不会出现404错误
- **Notes**: 参考指导书中的路由配置示例

## [x] Task 3: 对齐核心接口调用
- **Priority**: P0
- **Depends On**: Task 1
- **Description**:
  - 更新API模块，按照指导书中的接口清单实现所有核心接口
  - 确保接口路径、请求方法、参数格式与后端一致
  - 特别注意学分申请和审核相关接口
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-3.1: 所有核心接口路径与后端一致
  - `programmatic` TR-3.2: 请求参数格式与后端接口文档一致
  - `programmatic` TR-3.3: 请求方法正确使用
- **Notes**: 严格按照指导书中的接口详细说明实现

## [x] Task 4: 实现认证和权限控制
- **Priority**: P0
- **Depends On**: Task 1, Task 2
- **Description**:
  - 实现登录功能，正确存储token和用户信息到localStorage
  - 完善路由守卫，根据token和用户角色控制访问权限
  - 确保不同角色只能访问对应权限的页面
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-4.1: 登录成功后token正确存储
  - `programmatic` TR-4.2: 未登录状态下访问权限页面会重定向到登录页
  - `programmatic` TR-4.3: 不同角色只能访问对应权限的页面
- **Notes**: 参考指导书中的登录组件示例

## [x] Task 5: 对齐数据格式
- **Priority**: P1
- **Depends On**: Task 3
- **Description**:
  - 确保前端数据字段命名与后端一致（驼峰命名）
  - 统一日期格式为 yyyy-MM-dd HH:mm:ss
  - 处理空值，避免展示"null"字符串
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `programmatic` TR-5.1: 前端使用的字段名与后端一致
  - `programmatic` TR-5.2: 日期格式正确处理
  - `programmatic` TR-5.3: 空值正确处理为"-"或空
- **Notes**: 参考指导书中的核心实体字段清单

## [x] Task 6: 测试完整业务流程
- **Priority**: P1
- **Depends On**: Task 1, Task 2, Task 3, Task 4, Task 5
- **Description**:
  - 测试登录功能
  - 测试学分申请流程
  - 测试审核流程
  - 测试权限控制
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3, AC-4, AC-5
- **Test Requirements**:
  - `programmatic` TR-6.1: 登录功能正常
  - `programmatic` TR-6.2: 学分申请流程完整
  - `programmatic` TR-6.3: 审核流程完整
  - `programmatic` TR-6.4: 权限控制生效
- **Notes**: 按照指导书中的联调注意事项进行测试