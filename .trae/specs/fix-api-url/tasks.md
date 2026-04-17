# 创新学分管理系统 - 前端API地址修复实现计划

## [x] Task 1: 修复前端API基地址配置
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 修改前端API配置文件，将baseURL设置为正确的后端地址
  - 确保请求能正确发送到后端8080端口
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: API配置文件中的baseURL正确设置为后端地址
  - `programmatic` TR-1.2: 登录请求正确发送到后端8080端口
- **Notes**: 根据错误信息，当前请求被发送到了前端5174端口，需要修复这个问题

## [x] Task 2: 验证Vite代理配置
- **Priority**: P0
- **Depends On**: Task 1
- **Description**:
  - 检查Vite代理配置是否正确
  - 确保代理能正确转发请求到后端8080端口
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-2.1: Vite代理配置正确设置
  - `programmatic` TR-2.2: 代理能正确转发请求到后端
- **Notes**: 检查vite.config.js文件中的proxy配置

## [x] Task 3: 测试登录功能
- **Priority**: P0
- **Depends On**: Task 1, Task 2
- **Description**:
  - 重启前端开发服务器
  - 测试登录功能，验证请求是否正确发送到后端
  - 验证登录成功后是否能跳转到对应首页
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-3.1: 登录请求能正确发送到后端
  - `programmatic` TR-3.2: 登录成功后能跳转到对应首页
- **Notes**: 测试时需要确保后端服务已启动