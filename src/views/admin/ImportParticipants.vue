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
          <el-table :data="activities" style="width: 100%" @row-click="handleActivityClick">
            <el-table-column prop="name" label="活动名称" width="300"></el-table-column>
            <el-table-column prop="credit" label="学分" width="100"></el-table-column>
            <el-table-column prop="level" label="级别" width="100"></el-table-column>
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
          <el-table :data="participants" style="width: 100%">
            <el-table-column prop="studentId" label="学号" width="150"></el-table-column>
            <el-table-column prop="name" label="姓名" width="120"></el-table-column>
            <el-table-column prop="className" label="班级" width="150"></el-table-column>
            <el-table-column label="操作" width="120" fixed="right">
              <template #default="scope">
                <el-button type="danger" size="small" @click="handleDelete(scope.row.studentId)">
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
import { activityAPI, excelAPI } from '../../api'

// 活动相关数据
const activities = ref([])
const selectedActivity = ref(null)
const participants = ref([])

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

// 加载活动列表
const loadActivities = async () => {
  try {
    const response = await activityAPI.getAllActivities()
    activities.value = response.data || []
    if (activities.value.length > 0) {
      selectedActivity.value = activities.value[0]
      loadParticipants(selectedActivity.value.id)
    }
  } catch (error) {
    console.error('加载活动列表失败:', error)
    ElMessage.error('加载活动列表失败')
  }
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
onMounted(() => {
  loadActivities()
})
</script>

<style scoped>
.import-participants {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.content-wrapper {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.activity-section {
  flex: 1;
  min-width: 400px;
  margin-bottom: 20px;
}

.participants-section {
  flex: 1;
  min-width: 400px;
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 15px;
  color: #303133;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.file-info {
  margin-bottom: 15px;
  padding: 10px;
  background-color: #f0f9ff;
  border: 1px solid #b3d8ff;
  border-radius: 4px;
  color: #409eff;
}

.empty-state {
  margin-top: 30px;
  text-align: center;
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