# 学习管理员端校级通知管理功能 - 实现计划

## [/] 任务 1: 分析现有管理员端通知管理模块代码
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 分析当前管理员端通知管理模块的代码结构和功能
  - 识别需要修改的部分，特别是与school_notice表相关的API调用
  - 参考辅导员端院级通知管理模块的实现
- **Acceptance Criteria Addressed**: AC-1, AC-2
- **Test Requirements**:
  - `human-judgement` TR-1.1: 确认现有代码结构和功能
  - `human-judgement` TR-1.2: 识别需要修改的API调用和界面元素
- **Notes**: 重点关注API调用部分，确保与school_notice表对应

## [ ] 任务 2: 更新通知列表展示功能
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**:
  - 修改通知列表展示逻辑，从school_notice表获取数据
  - 调整表格列，确保显示正确的字段（title, content, publishTime, expireTime, publisherName）
  - 实现分页功能
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-2.1: 通知列表能正确从school_notice表获取数据
  - `human-judgement` TR-2.2: 表格显示正确的字段和数据
  - `programmatic` TR-2.3: 分页功能正常工作
- **Notes**: 参考辅导员端的表格结构和分页实现

## [ ] 任务 3: 实现通知新增功能
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**:
  - 修改新增通知弹窗，移除不需要的字段（credit, scope, 附件等）
  - 实现从当前登录用户获取publisher和publisher_name的逻辑
  - 调整表单验证规则，确保title、content、expireTime为必填项
  - 实现发布时间的自动设置和手动修改功能
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-3.1: 新增通知时能自动填充publisher和publisher_name
  - `programmatic` TR-3.2: 表单验证规则正确执行
  - `programmatic` TR-3.3: 通知数据能正确保存到school_notice表
- **Notes**: 确保发布时间默认为当前时间，但允许管理员修改

## [ ] 任务 4: 实现通知编辑功能
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**:
  - 修改编辑通知弹窗，确保只显示需要的字段
  - 实现编辑功能的API调用
  - 确保编辑时保持原有数据的完整性
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-4.1: 编辑弹窗能正确显示原有通知数据
  - `programmatic` TR-4.2: 编辑后的数据能正确更新到school_notice表
- **Notes**: 参考辅导员端的编辑功能实现

## [ ] 任务 5: 实现通知删除功能
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**:
  - 实现通知删除的API调用
  - 添加删除确认对话框
  - 确保删除后列表能及时更新
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `programmatic` TR-5.1: 删除操作能正确调用API
  - `human-judgement` TR-5.2: 删除确认对话框正常显示
  - `programmatic` TR-5.3: 删除后列表能及时更新
- **Notes**: 参考辅导员端的删除功能实现

## [ ] 任务 6: 实现通知详情查看功能
- **Priority**: P1
- **Depends On**: 任务 1
- **Description**:
  - 实现通知详情弹窗
  - 确保显示所有通知字段，包括publisher和publisher_name
- **Acceptance Criteria Addressed**: AC-6
- **Test Requirements**:
  - `human-judgement` TR-6.1: 详情弹窗能正确显示通知的所有信息
  - `programmatic` TR-6.2: 详情弹窗能正确打开和关闭
- **Notes**: 参考辅导员端的详情查看功能实现

## [ ] 任务 7: 实现标题关键字搜索功能
- **Priority**: P1
- **Depends On**: 任务 1
- **Description**:
  - 修改搜索表单，添加标题关键字搜索字段
  - 实现搜索功能的API调用
  - 确保搜索结果能正确展示
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `programmatic` TR-7.1: 输入关键字后能正确调用搜索API
  - `programmatic` TR-7.2: 搜索结果能正确显示
- **Notes**: 参考辅导员端的搜索功能实现

## [ ] 任务 8: 实现时间段搜索功能
- **Priority**: P1
- **Depends On**: 任务 1
- **Description**:
  - 修改搜索表单，添加开始时间和结束时间选择器
  - 实现时间段搜索的API调用
  - 确保搜索结果能正确展示
- **Acceptance Criteria Addressed**: AC-8
- **Test Requirements**:
  - `programmatic` TR-8.1: 选择时间范围后能正确调用搜索API
  - `programmatic` TR-8.2: 搜索结果能正确显示
- **Notes**: 参考辅导员端的时间段搜索实现

## [ ] 任务 9: 测试和验证
- **Priority**: P0
- **Depends On**: 任务 2, 3, 4, 5, 6, 7, 8
- **Description**:
  - 测试所有功能是否正常工作
  - 验证只有管理员身份可以访问该功能
  - 确保所有API调用正确
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8
- **Test Requirements**:
  - `programmatic` TR-9.1: 所有功能测试通过
  - `programmatic` TR-9.2: 权限控制正常工作
  - `human-judgement` TR-9.3: 界面美观，操作流畅
- **Notes**: 确保所有功能都能正常工作，特别是权限控制部分