# 创新学分管理系统 - 前端API地址修复规格文档

## Overview
- **Summary**: 修复前端API请求地址错误的问题，确保前端请求正确发送到后端8080端口，而不是前端开发服务器的端口
- **Purpose**: 解决CORS跨域错误和请求404错误，确保前端能正常与后端通信
- **Target Users**: 前端开发人员

## Goals
- 确保前端API请求正确发送到后端8080端口
- 修复CORS跨域错误
- 验证登录功能能正常工作

## Non-Goals (Out of Scope)
- 不修改后端代码
- 不添加新的业务功能
- 不优化前端UI/UX设计

## Background & Context
- 前端开发服务器运行在 http://localhost:5174
- 后端服务运行在 http://localhost:8080
- 前端API请求被错误地发送到前端开发服务器的端口，导致404错误

## Functional Requirements
- **FR-1**: 修复前端API基地址配置，确保请求发送到后端8080端口
- **FR-2**: 确保Vite代理配置正确生效
- **FR-3**: 验证登录功能能正常工作

## Non-Functional Requirements
- **NFR-1**: 前端API请求响应时间不超过10秒
- **NFR-2**: 跨域配置正确，支持开发环境访问

## Constraints
- **Technical**: 前端使用Vue 3 + Vite，后端使用Java Spring Boot
- **Dependencies**: 依赖axios进行HTTP请求

## Assumptions
- 后端服务已正常运行在 http://localhost:8080
- 前端项目已搭建完成，具备基本的页面结构

## Acceptance Criteria

### AC-1: API配置修复
- **Given**: 前端API配置文件已修改
- **When**: 发送登录请求
- **Then**: 请求正确发送到 http://localhost:8080/api/auth/login
- **Verification**: `programmatic`

### AC-2: 跨域错误修复
- **Given**: 前端API配置已修复
- **When**: 发送登录请求
- **Then**: 不再出现CORS跨域错误
- **Verification**: `programmatic`

### AC-3: 登录功能正常
- **Given**: API配置已修复
- **When**: 输入正确的用户名和密码
- **Then**: 登录成功，跳转到对应首页
- **Verification**: `programmatic`

## Open Questions
- [ ] 前端开发服务器的实际端口是多少
- [ ] 后端服务是否已正常启动