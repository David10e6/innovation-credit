# 导入活动参与者功能 - 产品需求文档

## Overview
- **Summary**: 为校级管理员创建一个导入活动参与者的功能，允许管理员为活动添加和删除参与者，自动更新学生的总学分。
- **Purpose**: 解决校级管理员需要手动为活动添加参与者的问题，提高管理效率，确保学分自动更新的准确性。
- **Target Users**: 校级管理员

## Goals
- 实现活动选择功能，展示所有活动列表
- 实现参与者管理功能，展示和删除活动的现有参与者
- 实现学生选择弹窗，支持按班级分组和搜索
- 实现参与者的添加和删除功能
- 确保学分自动更新

## Non-Goals (Out of Scope)
- 批量导入参与者（通过文件上传）
- 参与者信息编辑
- 活动创建和编辑
- 学分规则修改

## Background & Context
- 系统已有完整的活动管理功能
- 系统已有完整的学生管理功能
- 系统已有完整的学分计算功能
- 前端使用Vue 3 + Element Plus
- 后端提供了相关的API接口

## Functional Requirements
- **FR-1**: 活动选择功能
  - 展示所有活动列表
  - 支持活动选择
  - 显示活动基本信息（名称、学分、级别）

- **FR-2**: 参与者管理功能
  - 展示所选活动的现有参与者
  - 支持删除参与者
  - 实时更新参与者列表

- **FR-3**: 学生选择弹窗
  - 按班级分组展示学生
  - 支持学生搜索
  - 支持多选学生
  - 支持确认添加所选学生

- **FR-4**: API集成
  - 调用获取活动列表API
  - 调用获取参与者列表API
  - 调用添加参与者API
  - 调用删除参与者API
  - 调用获取学生列表API
  - 调用按班级获取学生列表API

## Non-Functional Requirements
- **NFR-1**: 性能
  - 页面加载时间不超过2秒
  - API响应时间不超过1秒
  - 操作响应时间不超过0.5秒

- **NFR-2**: 可用性
  - 界面清晰易用
  - 操作流程简单直观
  - 错误提示友好明确

- **NFR-3**: 响应式设计
  - 适配不同屏幕尺寸
  - 在小屏幕设备上正常显示

## Constraints
- **Technical**: Vue 3, Element Plus, Axios
- **Business**: 与现有系统风格保持一致
- **Dependencies**: 后端API接口

## Assumptions
- 后端API接口已实现并可用
- 系统已登录且用户具有管理员权限
- 学生信息已存在于系统中

## Acceptance Criteria

### AC-1: 活动列表展示
- **Given**: 管理员进入导入活动参与者页面
- **When**: 页面加载完成
- **Then**: 显示所有活动列表，包含活动名称、学分、级别
- **Verification**: `human-judgment`

### AC-2: 活动选择功能
- **Given**: 活动列表已显示
- **When**: 点击活动列表中的活动
- **Then**: 活动被选中，显示该活动的参与者列表
- **Verification**: `human-judgment`

### AC-3: 参与者列表展示
- **Given**: 活动已选中
- **When**: 系统获取参与者列表
- **Then**: 显示参与者的学号、姓名、班级信息
- **Verification**: `human-judgment`

### AC-4: 删除参与者功能
- **Given**: 参与者列表已显示
- **When**: 点击删除按钮并确认
- **Then**: 参与者被删除，列表更新
- **Verification**: `human-judgment`

### AC-5: 学生选择弹窗
- **Given**: 点击添加参与者按钮
- **When**: 弹窗打开
- **Then**: 显示按班级分组的学生列表，支持搜索和多选
- **Verification**: `human-judgment`

### AC-6: 添加参与者功能
- **Given**: 学生选择弹窗已打开
- **When**: 选择学生并点击确定
- **Then**: 学生被添加为参与者，列表更新
- **Verification**: `human-judgment`

### AC-7: 错误处理
- **Given**: API调用失败
- **When**: 系统尝试获取数据或执行操作
- **Then**: 显示友好的错误提示
- **Verification**: `human-judgment`

### AC-8: 响应式设计
- **Given**: 在不同屏幕尺寸的设备上
- **When**: 访问导入活动参与者页面
- **Then**: 页面布局自适应，功能正常
- **Verification**: `human-judgment`

## Open Questions
- [ ] 活动列表是否需要分页？
- [ ] 参与者列表是否需要分页？
- [ ] 学生选择弹窗是否需要分页？