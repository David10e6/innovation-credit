# 管理员端学分审核终审功能 - 实现计划

## [x] Task 1: 添加管理员端终审页面路由
- **Priority**: P0
- **Depends On**: None
- **Description**: 在路由配置文件中添加管理员端终审页面路由，设置正确的权限控制
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: 路由配置正确，包含 `/admin/credit/final-audit` 路径
  - `programmatic` TR-1.2: 路由元信息设置 `requiresAuth: true, role: 3`
- **Notes**: 参考现有管理员路由的配置方式

## [x] Task 2: 在Layout组件中添加终审菜单项
- **Priority**: P0
- **Depends On**: Task 1
- **Description**: 在Layout.vue的管理员菜单配置中添加学分终审菜单项
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `human-judgment` TR-2.1: 管理员菜单中显示"学分终审"菜单项
  - `programmatic` TR-2.2: 菜单项链接到正确的路由路径
- **Notes**: 参考现有菜单项的配置格式

## [x] Task 3: 创建管理员端终审页面组件
- **Priority**: P0
- **Depends On**: Task 1, Task 2
- **Description**: 创建 `CreditFinalAudit.vue` 页面组件，实现待终审列表展示功能
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `human-judgment` TR-3.1: 页面布局符合管理员端风格
  - `programmatic` TR-3.2: 成功调用 `auditAPI.getSchoolPending()` 获取待终审列表
  - `human-judgment` TR-3.3: 列表正确显示申请数据，包括学生信息、申请内容等
- **Notes**: 参考 `ApplyAudit.vue` 的实现方式

## [x] Task 4: 实现审核通过功能
- **Priority**: P0
- **Depends On**: Task 3
- **Description**: 在终审页面中实现审核通过按钮和相关逻辑
- **Acceptance Criteria Addressed**: AC-3, AC-5
- **Test Requirements**:
  - `programmatic` TR-4.1: 点击"通过"按钮后调用 `auditAPI.schoolAudit()` 接口
  - `programmatic` TR-4.2: 接口调用成功后列表自动刷新
  - `human-judgment` TR-4.3: 操作后显示成功提示信息
- **Notes**: 确保传递正确的参数给后端接口

## [x] Task 5: 实现审核驳回功能和弹窗
- **Priority**: P0
- **Depends On**: Task 3
- **Description**: 实现审核驳回按钮、驳回原因输入弹窗和相关逻辑
- **Acceptance Criteria Addressed**: AC-4, AC-5
- **Test Requirements**:
  - `human-judgment` TR-5.1: 点击"驳回"按钮后弹出输入驳回原因的弹窗
  - `programmatic` TR-5.2: 弹窗中输入的原因通过验证
  - `programmatic` TR-5.3: 点击"确认"后调用 `auditAPI.schoolAudit()` 接口
  - `programmatic` TR-5.4: 接口调用成功后列表自动刷新
- **Notes**: 使用Element Plus的Dialog组件实现弹窗

## [x] Task 6: 测试学生端状态同步
- **Priority**: P1
- **Depends On**: Task 4, Task 5
- **Description**: 测试学生端是否能正确显示终审结果和驳回原因
- **Acceptance Criteria Addressed**: AC-6
- **Test Requirements**:
  - `human-judgment` TR-6.1: 学生端正确显示终审通过状态
  - `human-judgment` TR-6.2: 学生端正确显示驳回状态和驳回原因
- **Notes**: 需要模拟不同的审核结果进行测试

## [x] Task 7: 测试重新提交功能
- **Priority**: P1
- **Depends On**: Task 6
- **Description**: 测试学生端重新提交被驳回申请的功能
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `programmatic` TR-7.1: 学生点击"重新提交"按钮后申请状态重置
  - `programmatic` TR-7.2: 重新提交的申请进入新的审核流程
- **Notes**: 验证重新提交后是否能在终审列表中再次出现

## [x] Task 8: 优化用户体验和响应式设计
- **Priority**: P2
- **Depends On**: Task 4, Task 5
- **Description**: 优化页面响应速度、操作反馈和响应式布局
- **Acceptance Criteria Addressed**: NFR-1, NFR-2, NFR-3, NFR-4
- **Test Requirements**:
  - `human-judgment` TR-8.1: 页面加载时间不超过2秒
  - `human-judgment` TR-8.2: 操作反馈及时，提示信息清晰
  - `human-judgment` TR-8.3: 页面在不同屏幕尺寸下显示正常
- **Notes**: 可以添加加载状态、错误处理等增强用户体验的功能