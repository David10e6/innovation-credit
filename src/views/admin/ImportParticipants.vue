<template>
  <div class="import-participants">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>导入活动参与者</span>
        </div>
      </template>
      
      <div class="content-wrapper">
        <!-- 活动选择区 -->
        <div class="activity-section">
          <h3 class="section-title">活动选择</h3>
          
          <!-- 搜索区域 -->
          <div class="search-form">
            <el-form :inline="true" :model="searchForm">
              <el-form-item label="活动名称">
                <el-input v-model="searchForm.name" placeholder="请输入活动名称" clearable @input="handleSearchActivities"></el-input>
              </el-form-item>
              <el-form-item label="活动等级">
                <el-select v-model="searchForm.level" placeholder="请选择活动等级" clearable @change="handleSearchActivities">
                  <el-option label="院级" value="院级"></el-option>
                  <el-option label="校级" value="校级"></el-option>
                </el-select>
              </el-form-item>
              <el-form-item label="主办学院">
                <el-select v-model="searchForm.collegeId" placeholder="请选择主办学院" clearable @change="handleSearchActivities">
                  <el-option 
                    v-for="college in colleges" 
                    :key="college.id" 
                    :label="college.name" 
                    :value="college.id"
                  ></el-option>
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="handleResetSearch">重置</el-button>
              </el-form-item>
            </el-form>
          </div>
          
          <el-table 
            :data="filteredActivities" 
            style="width: 100%" 
            @row-click="handleActivityClick"
            :highlight-current-row="true"
            :row-class-name="tableRowClassName"
          >
            <el-table-column prop="name" label="活动名称" min-width="200"></el-table-column>
            <el-table-column prop="credit" label="学分" width="100" align="center">
              <template #default="scope">
                <span class="credit-tag">{{ scope.row.credit }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="level" label="级别" width="100" align="center">
              <template #default="scope">
                <el-tag :type="scope.row.level === '校级' ? 'danger' : 'primary'" size="small">
                  {{ scope.row.level }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="主办学院" min-width="150">
              <template #default="scope">
                <span class="organizer-text">
                  {{ scope.row.organizer || scope.row.collegeName || '未设置' }}
                </span>
              </template>
            </el-table-column>
          </el-table>
        </div>
        
        <!-- 参与者管理区 -->
        <div class="participants-section">
          <div class="section-header">
            <h3 class="section-title">参与者管理</h3>
            <div class="action-buttons">
              <el-upload
                class="upload-demo"
                action=""
                :auto-upload="false"
                :on-change="handleFileChange"
                accept=".xlsx"
                :show-file-list="false"
              >
                <el-button type="success">Excel批量导入</el-button>
              </el-upload>
              <el-button type="primary" @click="showStudentDialog = true">添加参与者</el-button>
            </div>
          </div>
          <div v-if="selectedFile" class="file-info">
            已选择文件: {{ selectedFile.name }}
          </div>
          <el-table 
            :data="participants" 
            style="width: 100%"
            :stripe="true"
          >
            <el-table-column prop="studentId" label="学号" min-width="140"></el-table-column>
            <el-table-column label="姓名" min-width="100">
              <template #default="scope">
                <span class="participant-name">
                  {{ scope.row.studentName || scope.row.name || scope.row['姓名'] || '-' }}
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="className" label="班级" min-width="140"></el-table-column>
            <el-table-column label="操作" width="100" fixed="right" align="center">
              <template #default="scope">
                <el-button 
                  type="danger" 
                  size="small" 
                  @click="handleDelete(scope.row.studentId)"
                >
                  <template #icon>
                    <Delete />
                  </template>
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <div v-if="participants.length === 0" class="empty-state">
            <el-empty description="暂无参与者"></el-empty>
          </div>
        </div>
      </div>
    </el-card>
    
    <!-- 学生选择弹窗 -->
    <el-dialog
      v-model="showStudentDialog"
      title="选择学生"
      width="80%"
      height="80%"
    >
      <div class="dialog-header">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索学生"
          prefix-icon="el-icon-search"
          @input="handleSearch"
        ></el-input>
      </div>
      <div class="student-list">
        <!-- 将所有学生显示在一个表格中，按班级分组 -->
        <el-table 
          ref="studentTable" 
          :data="allStudents" 
          style="width: 100%" 
          @selection-change="handleSelectionChange"
          row-key="studentId"
          :default-sort="{prop: 'className', order: 'asc'}"
        >
          <el-table-column type="selection" width="55"></el-table-column>
          <el-table-column prop="className" label="班级" width="150"></el-table-column>
          <el-table-column prop="studentId" label="学号" width="150"></el-table-column>
          <el-table-column prop="name" label="姓名" width="120"></el-table-column>
        </el-table>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showStudentDialog = false">取消</el-button>
          <el-button type="primary" @click="handleConfirm">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, watchEffect, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Delete } from '@element-plus/icons-vue'
import { activityAPI, excelAPI, adminAPI } from '../../api'

// 活动相关数据
const activities = ref([])
const colleges = ref([])
const selectedActivity = ref(null)
const participants = ref([])

// 搜索表单
const searchForm = ref({
  name: '',
  level: '',
  collegeId: ''
})

// 过滤后的活动
const filteredActivities = computed(() => {
  let result = activities.value
  
  if (searchForm.value.name) {
    result = result.filter(item => 
      item.name && item.name.includes(searchForm.value.name)
    )
  }
  
  if (searchForm.value.level) {
    result = result.filter(item => 
      item.level === searchForm.value.level
    )
  }
  
  if (searchForm.value.collegeId) {
    result = result.filter(item => 
      String(item.collegeId) === String(searchForm.value.collegeId)
    )
  }
  
  return result
})

// 学生选择弹窗相关数据
const showStudentDialog = ref(false)
const studentGroups = ref({})
const activeClasses = ref([])
const searchKeyword = ref('')
const studentTable = ref(null) // 单个表格的ref
const selectedStudents = ref([])

// Excel导入相关
const selectedFile = ref(null)

// 计算属性：将所有学生合并成一个数组
const allStudents = computed(() => {
  const students = []
  for (const className in studentGroups.value) {
    if (studentGroups.value.hasOwnProperty(className)) {
      const classStudents = studentGroups.value[className]
      classStudents.forEach(student => {
        // 确保每个学生都有className属性
        students.push({ ...student, className })
      })
    }
  }
  return students
})

// 加载学院列表
const loadColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    colleges.value = response.data || []
    console.log('学院列表加载完成:', colleges.value)
  } catch (error) {
    console.error('加载学院列表失败:', error)
  }
}

// 加载活动列表
const loadActivities = async () => {
  try {
    const response = await activityAPI.getAllActivities()
    let activityList = response.data || []
    
    // 使用学院数据补充主办学院信息
    if (colleges.value.length > 0) {
      activityList = activityList.map(activity => {
        // 查找对应的学院
        const college = colleges.value.find(c => 
          String(c.id) === String(activity.collegeId)
        )
        return {
          ...activity,
          organizer: college ? college.name : (activity.organizer || '未设置')
        }
      })
    }
    
    activities.value = activityList
    if (activities.value.length > 0) {
      selectedActivity.value = activities.value[0]
      loadParticipants(selectedActivity.value.id)
    }
  } catch (error) {
    console.error('加载活动列表失败:', error)
    ElMessage.error('加载活动列表失败')
  }
}

// 处理活动搜索
const handleSearchActivities = () => {
  // 计算属性会自动处理
}

// 重置搜索
const handleResetSearch = () => {
  searchForm.value = {
    name: '',
    level: '',
    collegeId: ''
  }
}

// 表格行样式
const tableRowClassName = ({ row, rowIndex }) => {
  if (selectedActivity.value && selectedActivity.value.id === row.id) {
    return 'selected-row'
  }
  return ''
}

// 加载参与者列表
const loadParticipants = async (activityId) => {
  try {
    const response = await activityAPI.getActivityParticipants(activityId)
    participants.value = response.data || []
  } catch (error) {
    console.error('加载参与者列表失败:', error)
    ElMessage.error('加载参与者列表失败')
  }
}

// 处理活动点击
const handleActivityClick = (row) => {
  selectedActivity.value = row
  loadParticipants(row.id)
}

// 处理删除参与者
const handleDelete = (studentId) => {
  ElMessageBox.confirm('确定要删除该参与者吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await activityAPI.removeParticipant(selectedActivity.value.id, studentId)
      ElMessage.success('删除成功')
      loadParticipants(selectedActivity.value.id)
    } catch (error) {
      console.error('删除参与者失败:', error)
      ElMessage.error('删除参与者失败')
    }
  }).catch(() => {
    // 取消删除
  })
}

// 加载学生列表
const loadStudents = async () => {
  try {
    const response = await activityAPI.getStudentsByClass()
    studentGroups.value = response.data || {}
    // 默认展开所有班级
    activeClasses.value = Object.keys(studentGroups.value)
    
    // 设置默认选中状态
    setTimeout(() => {
      setDefaultSelection()
    }, 100)
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  }
}

// 设置默认选中状态
const setDefaultSelection = () => {
  if (!studentTable.value || !participants.value || participants.value.length === 0) {
    return
  }
  
  // 获取所有学生
  const allStudentsList = allStudents.value
  
  // 遍历参与者列表，设置默认选中
  participants.value.forEach(participant => {
    const student = allStudentsList.find(s => s.studentId === participant.studentId)
    if (student) {
      studentTable.value.toggleRowSelection(student, true)
    }
  })
}

// 处理搜索
const handleSearch = async () => {
  if (!searchKeyword.value) {
    loadStudents()
    return
  }
  
  try {
    const response = await activityAPI.getStudents(searchKeyword.value)
    // 转换为按班级分组的格式
    const groups = {}
    response.data.forEach(student => {
      const className = student.className || '未分班'
      if (!groups[className]) {
        groups[className] = []
      }
      groups[className].push(student)
    })
    studentGroups.value = groups
    activeClasses.value = Object.keys(groups)
    // 重置选择
    selectedStudents.value = []
    
    // 设置默认选中状态
    setTimeout(() => {
      setDefaultSelection()
    }, 100)
  } catch (error) {
    console.error('搜索学生失败:', error)
    ElMessage.error('搜索学生失败')
  }
}

// 处理学生选择
const handleSelectionChange = (selection) => {
  // 直接使用从事件传递的选中项数组
  selectedStudents.value = selection
  
  console.log('Selected students:', selectedStudents.value)
  console.log('Selected students count:', selectedStudents.value.length)
  
  // 检查第一个学生的结构
  if (selectedStudents.value.length > 0) {
    console.log('First student:', selectedStudents.value[0])
    console.log('First student studentId:', selectedStudents.value[0].studentId)
    console.log('First student studentId type:', typeof selectedStudents.value[0].studentId)
  }
}

// 测试API调用（使用fetch）
const testAPI = async () => {
  try {
    // 使用硬编码的测试数据
    const testStudentIds = ['2023001', '2023002']
    const testActivityId = selectedActivity.value?.id || '1'
    const token = localStorage.getItem('token')
    
    console.log('Testing API with:', testActivityId, testStudentIds)
    
    // 尝试使用fetch API直接调用
    try {
      const response = await fetch(`/api/activity/participants/${testActivityId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(testStudentIds)
      })
      
      const data = await response.json()
      console.log('Fetch response:', data)
      
      if (response.ok) {
        ElMessage.success('测试成功（fetch - 数组格式）')
      } else {
        ElMessage.error(`测试失败（fetch - 数组格式）: ${data.msg}`)
      }
    } catch (error1) {
      console.error('Error with fetch array format:', error1)
      
      // 尝试对象格式
      try {
        const response = await fetch(`/api/activity/participants/${testActivityId}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ studentIds: testStudentIds })
        })
        
        const data = await response.json()
        console.log('Fetch response (object):', data)
        
        if (response.ok) {
          ElMessage.success('测试成功（fetch - 对象格式）')
        } else {
          ElMessage.error(`测试失败（fetch - 对象格式）: ${data.msg}`)
        }
      } catch (error2) {
        console.error('Error with fetch object format:', error2)
        ElMessage.error('测试失败')
      }
    }
  } catch (error) {
    console.error('Test failed:', error)
    ElMessage.error('测试失败')
  }
}

// 处理确认添加
const handleConfirm = async () => {
  if (selectedStudents.value.length === 0) {
    ElMessage.warning('请选择要添加的学生')
    return
  }
  
  try {
    // 提取学生ID列表，确保格式正确
    const studentIds = selectedStudents.value.map(student => {
      // 检查学生对象的结构，确保有正确的ID字段
      console.log('Student object:', student)
      // 尝试不同的ID字段名
      return student.studentId || student.id || student.StudentId
    }).filter(id => id) // 过滤掉空值
    
    console.log('Student IDs to add:', studentIds)
    console.log('Student IDs type:', typeof studentIds)
    console.log('Selected activity ID:', selectedActivity.value.id)
    
    // 确保studentIds是一个有效的数组
    if (!Array.isArray(studentIds)) {
      console.error('studentIds is not an array:', studentIds)
      ElMessage.error('学生ID格式错误')
      return
    }
    
    // 过滤掉已经参与的学生，只添加新的学生
    const existingStudentIds = new Set(participants.value.map(p => p.studentId))
    const newStudentIds = studentIds.filter(id => !existingStudentIds.has(id))
    
    console.log('Existing student IDs:', Array.from(existingStudentIds))
    console.log('New student IDs to add:', newStudentIds)
    
    if (newStudentIds.length === 0) {
      ElMessage.warning('没有新的学生需要添加')
      showStudentDialog.value = false
      return
    }
    
    // 直接传递学生ID数组
    await activityAPI.addParticipants(selectedActivity.value.id, newStudentIds)
    ElMessage.success('添加成功')
    showStudentDialog.value = false
    // 重置选择
    selectedStudents.value = []
    // 重新加载参与者列表
    loadParticipants(selectedActivity.value.id)
  } catch (error) {
    console.error('添加参与者失败:', error)
    ElMessage.error('添加参与者失败')
  }
}

// 监听弹窗显示
watchEffect(() => {
  if (showStudentDialog.value) {
    // 重置选择
    selectedStudents.value = []
    // 加载学生列表
    loadStudents()
    // 加载当前活动的参与者列表，用于设置默认选中状态
    if (selectedActivity.value) {
      loadParticipants(selectedActivity.value.id)
    }
  }
})

// 处理文件选择
const handleFileChange = (file) => {
  selectedFile.value = file.raw
  if (selectedFile.value) {
    handleImport()
  }
}

// 处理Excel导入
const handleImport = async () => {
  if (!selectedFile.value) {
    ElMessage.warning('请选择文件')
    return
  }
  
  if (!selectedActivity.value) {
    ElMessage.warning('请先选择一个活动')
    return
  }
  
  try {
    // 验证文件
    await excelAPI.validateExcel(selectedFile.value)
    
    // 导入文件
    const response = await excelAPI.importExcel(selectedFile.value, 'participant', selectedActivity.value.id)
    
    ElMessage.success('导入成功')
    // 重新加载参与者列表
    loadParticipants(selectedActivity.value.id)
    // 清空选择的文件
    selectedFile.value = null
  } catch (error) {
    console.error('导入失败:', error)
    ElMessage.error('导入失败: ' + (error.message || '网络错误'))
  }
}

// 页面加载时初始化
onMounted(async () => {
  await loadColleges()
  loadActivities()
})
</script>

<style scoped>
.import-participants {
  padding: 20px;
  background: #f0f2f5;
  min-height: 100vh;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.content-wrapper {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.activity-section {
  width: 100%;
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 20px;
  padding-left: 12px;
  border-left: 4px solid #409eff;
}

.search-form {
  margin-bottom: 24px;
  padding: 20px 24px;
  background: linear-gradient(135deg, #f8fafc 0%, #f0f7ff 100%);
  border-radius: 10px;
  border: 1px solid #e0e6ed;
}

.search-form .el-form-item {
  margin-bottom: 12px;
  margin-right: 20px;
}

.search-form .el-input__wrapper,
.search-form .el-select__wrapper {
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
  min-width: 180px;
}

.search-form .el-select {
  min-width: 180px;
}

.search-form .el-input__wrapper:hover,
.search-form .el-select__wrapper:hover {
  box-shadow: 0 2px 6px rgba(64, 158, 255, 0.15);
}

.search-form .el-input__wrapper.is-focus,
.search-form .el-select__wrapper.is-focus {
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.activity-section .el-table {
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.activity-section :deep(.el-table th) {
  background: linear-gradient(180deg, #fafbfc 0%, #f0f2f5 100%);
  color: #475669;
  font-weight: 600;
}

.activity-section :deep(.el-table tr:hover > td) {
  background-color: #f0f7ff !important;
}

.activity-section :deep(.selected-row) {
  background-color: #ecf5ff !important;
}

.credit-tag {
  display: inline-block;
  padding: 4px 12px;
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
  color: white;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
}

.organizer-text {
  color: #606266;
  font-size: 14px;
}

.participants-section {
  width: 100%;
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-header .section-title {
  margin-bottom: 0;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.action-buttons .el-button {
  border-radius: 8px;
  padding: 10px 20px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.action-buttons .el-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.participants-section .el-table {
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.participants-section :deep(.el-table th) {
  background: linear-gradient(180deg, #fafbfc 0%, #f0f2f5 100%);
  color: #475669;
  font-weight: 600;
}

.participants-section :deep(.el-table--striped .el-table__body tr.el-table__row--striped td) {
  background-color: #f8fafc;
}

.participants-section :deep(.el-table tr:hover > td) {
  background-color: #f0f7ff !important;
}

.participant-name {
  color: #303133;
  font-weight: 500;
}

.file-info {
  margin-bottom: 20px;
  padding: 14px 20px;
  background: linear-gradient(135deg, #f0f9ff 0%, #e6f4ff 100%);
  border: 1px solid #b3d8ff;
  border-radius: 10px;
  color: #409eff;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.empty-state {
  margin-top: 40px;
  text-align: center;
  padding: 40px;
}

.dialog-header {
  margin-bottom: 20px;
}

.student-list {
  max-height: 500px;
  overflow-y: auto;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .import-participants {
    padding: 10px;
  }
  
  .content-wrapper {
    flex-direction: column;
  }
  
  .activity-section,
  .participants-section {
    min-width: 100%;
  }
  
  .el-table {
    font-size: 12px;
  }
  
  .el-table th,
  .el-table td {
    padding: 8px;
  }
  
  .el-button {
    font-size: 12px;
    padding: 4px 8px;
  }
}
</style>