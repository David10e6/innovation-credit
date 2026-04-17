# 创新学分管理系统 - 前后端对齐规格文档

## Overview
- **Summary**: 根据后端基准，对前端项目进行全面对齐，确保接口调用、数据格式、认证权限等方面与后端完全一致
- **Purpose**: 解决前后端对接中的接口不匹配、数据解析错误、权限控制问题，确保系统正常运行
- **Target Users**: 前端开发人员、测试人员

## Goals
- 统一接口地址和调用规范，避免404错误
- 对齐数据格式和字段命名，避免数据解析错误
- 实现统一的认证和权限控制
- 确保路由配置正确，避免页面刷新404问题
- 验证完整的业务流程联调

## Non-Goals (Out of Scope)
- 不修改后端代码
- 不添加新的业务功能
- 不优化前端UI/UX设计

## Background & Context
- 后端服务运行在 http://localhost:8080/api
- 前端项目基于Vue 3 + Vite
- 指导书提供了详细的接口文档和配置示例

## Functional Requirements
- **FR-1**: 统一API配置，使用正确的baseURL和请求拦截器
- **FR-2**: 实现hash模式路由，避免静态资源404问题
- **FR-3**: 对齐所有核心接口的调用方式和参数格式
- **FR-4**: 实现统一的认证和权限控制
- **FR-5**: 确保数据格式和字段命名与后端一致

## Non-Functional Requirements
- **NFR-1**: 前端API调用响应时间不超过10秒
- **NFR-2**: 跨域配置正确，支持开发环境访问
- **NFR-3**: 错误处理机制完善，能正确处理后端返回的错误状态

## Constraints
- **Technical**: 前端使用Vue 3 + Vite，后端使用Java Spring Boot
- **Dependencies**: 依赖axios进行HTTP请求

## Assumptions
- 后端服务已正常运行在 http://localhost:8080/api
- 前端项目已搭建完成，具备基本的页面结构

## Acceptance Criteria

### AC-1: API配置对齐
- **Given**: 前端项目已配置
- **When**: 检查axios配置
- **Then**: baseURL设置为 http://localhost:8080/api，请求拦截器正确添加token
- **Verification**: `programmatic`

### AC-2: 路由配置对齐
- **Given**: 前端路由配置
- **When**: 检查路由模式
- **Then**: 使用hash模式，避免页面刷新404
- **Verification**: `programmatic`

### AC-3: 核心接口调用对齐
- **Given**: 前端API调用
- **When**: 调用所有核心接口
- **Then**: 接口路径、参数格式、请求方法与后端一致
- **Verification**: `programmatic`

### AC-4: 认证和权限控制
- **Given**: 前端认证流程
- **When**: 登录和访问权限页面
- **Then**: token正确存储和传递，权限控制生效
- **Verification**: `programmatic`

### AC-5: 数据格式对齐
- **Given**: 前端数据处理
- **When**: 接收和发送数据
- **Then**: 字段命名、日期格式与后端一致
- **Verification**: `programmatic`

## Open Questions
- [ ] 后端是否已配置跨域支持
- [ ] 前端是否需要配置环境变量区分开发/生产环境