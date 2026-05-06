<template>
  <div class="activity-management">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">活动管理</span>
          <el-button type="primary" @click="openAddDialog">新增活动</el-button>
        </div>
      </template>
      
      <!-- 搜索和筛选 -->
      <div class="search-section">
        <el-form :inline="true" :model="searchForm" class="mb-4">
          <el-form-item label="活动名称">
            <el-input v-model="searchForm.name" placeholder="请输入活动名称" style="width: 300px;"></el-input>
          </el-form-item>
          <el-form-item label="活动类型">
            <el-select v-model="searchForm.type" placeholder="请选择活动类型" style="width: 200px;" clearable>
                <el-option 
                    v-for="type in activityTypes" 
                    :key="getTypeKey(type)" 
                    :label="getTypeName(type)" 
                    :value="getTypeValue(type)" 
                />
            </el-select>
        </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>
      
      <!-- 活动列表 -->
      <el-table :data="activities" style="width: 100%" border v-loading="loading">
        <el-table-column prop="id" label="活动ID" width="100" />
        <el-table-column prop="name" label="活动名称" />
        <el-table-column prop="type" label="活动类型" />
            <el-table-column prop="level" label="级别" width="100" />
            <el-table-column prop="organizer" label="组织者" />
        <el-table-column prop="startTime" label="开始时间" width="180" />
        <el-table-column prop="endTime" label="结束时间" width="180" />
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="openEditDialog(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteActivity(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination" style="margin-top: 20px;">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
    
    <!-- 活动表单对话框 -->
    <el-dialog
      v-model="activityDialogVisible"
      :title="isEdit ? '编辑活动' : '新增活动'"
      width="800px"
    >
      <el-form :model="currentActivity" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="活动名称" prop="name">
          <el-input v-model="currentActivity.name" placeholder="请输入活动名称" />
        </el-form-item>
        
        <el-form-item label="活动类型" prop="type">
        <el-select v-model="currentActivity.type" placeholder="请选择活动类型">
          <el-option 
            v-for="type in activityTypes" 
            :key="getTypeKey(type)" 
            :label="getTypeName(type)" 
            :value="getTypeValue(type)" 
          />
        </el-select>
      </el-form-item>
      
      <el-form-item label="活动级别" prop="level">
        <el-select v-model="currentActivity.level" placeholder="请选择活动级别">
          <el-option label="院级" value="院级" />
          <el-option label="校级" value="校级" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="主办方" prop="collegeId">
        <el-select v-model="currentActivity.collegeId" placeholder="请选择主办方">
          <el-option 
            v-for="college in colleges" 
            :key="getCollegeKey(college)" 
            :label="getCollegeName(college)" 
            :value="getCollegeId(college)" 
          />
        </el-select>
      </el-form-item>
        
        <el-form-item label="活动详情" prop="details">
          <el-input v-model="currentActivity.details" type="textarea" placeholder="请输入活动详情" />
        </el-form-item>
        
        <el-form-item label="参与方式" prop="applicationMethod">
          <el-input v-model="currentActivity.applicationMethod" placeholder="请输入参与方式" />
        </el-form-item>
        
        <el-form-item label="参与要求" prop="participationRequirements">
          <el-input v-model="currentActivity.participationRequirements" placeholder="请输入参与要求" />
        </el-form-item>
        
        <el-form-item label="报名截止时间" prop="applicationDeadline">
          <el-date-picker
            v-model="currentActivity.applicationDeadline"
            type="datetime"
            placeholder="选择报名截止时间"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            v-model="currentActivity.startTime"
            type="datetime"
            placeholder="选择开始时间"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker
            v-model="currentActivity.endTime"
            type="datetime"
            placeholder="选择结束时间"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="activityDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveActivity" :loading="submitLoading">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { activityAPI, adminAPI, creditRuleAPI } from '../../api'

const activityDialogVisible = ref(false)
const activities = ref([])
const colleges = ref([])
const activityTypes = ref([])
const isEdit = ref(false)
const loading = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)

// 搜索表单
const searchForm = reactive({
  name: '',
  type: ''
})

// 分页数据
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 当前活动数据
const currentActivity = ref({
  id: '',
  name: '',
  type: '',
  level: '',
  details: '',
  applicationMethod: '',
  participationRequirements: '',
  applicationDeadline: '',
  startTime: '',
  endTime: '',
  organizer: '',
  collegeId: ''
})

// 表单验证规则
const rules = {
  name: [{ required: true, message: '请输入活动名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择活动类型', trigger: 'change' }],
  level: [{ required: true, message: '请选择活动级别', trigger: 'change' }],
  details: [{ required: true, message: '请输入活动详情', trigger: 'blur' }],
  applicationMethod: [{ required: true, message: '请输入参与方式', trigger: 'blur' }],
  participationRequirements: [{ required: true, message: '请输入参与要求', trigger: 'blur' }],
  applicationDeadline: [{ required: true, message: '请选择报名截止时间', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  collegeId: [{ required: true, message: '请选择主办方', trigger: 'change' }]
}

const getActivities = async () => {
  loading.value = true
  try {
    const response = await activityAPI.getAdminActivities()
    console.log('getActivities响应:', response)
    activities.value = response.data || []
    total.value = activities.value.length
  } catch (error) {
    console.error('获取活动列表失败:', error)
    ElMessage.error('获取活动列表失败')
    activities.value = []
  } finally {
    loading.value = false
  }
}

// 辅助函数：获取学院的key
const getCollegeKey = (college) => {
  return college.id || college.collegeId || JSON.stringify(college)
}

// 辅助函数：获取学院名称
const getCollegeName = (college) => {
  return college.name || college.collegeName || String(college)
}

// 辅助函数：获取学院ID
const getCollegeId = (college) => {
  return college.id || college.collegeId || String(college)
}

const getColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    console.log('getColleges响应:', response)
    // 适配不同的数据格式
    if (response.data) {
      if (Array.isArray(response.data)) {
        colleges.value = response.data
      } else if (response.data.rows) {
        colleges.value = response.data.rows
      } else if (Array.isArray(response)) {
        colleges.value = response
      }
    } else {
      colleges.value = response || []
    }
    console.log('学院数据:', colleges.value)
  } catch (error) {
    console.error('获取学院列表失败:', error)
    ElMessage.error('获取学院列表失败')
    colleges.value = []
  }
}

// 辅助函数：获取活动类型的key
const getTypeKey = (type) => {
  return type.id || JSON.stringify(type)
}

// 辅助函数：获取活动类型名称
const getTypeName = (type) => {
  return type.name || String(type)
}

// 辅助函数：获取活动类型值
const getTypeValue = (type) => {
  return type.id || type.name || String(type)
}

// 获取活动类型
const getActivityTypes = async () => {
  try {
    const response = await creditRuleAPI.getActivityTypes()
    console.log('getActivityTypes响应:', response)
    activityTypes.value = response.data?.activityTypes || []
    console.log('活动类型数据:', activityTypes.value)
  } catch (error) {
    console.error('获取活动类型失败:', error)
    // 如果获取失败，使用默认值
    activityTypes.value = ['科技创新', '社会实践', '学术竞赛', '文化活动', '其他']
  }
}

const openAddDialog = () => {
  currentActivity.value = {
    id: '',
    name: '',
    type: '',
    level: '',
    details: '',
    applicationMethod: '',
    participationRequirements: '',
    applicationDeadline: '',
    startTime: '',
    endTime: '',
    organizer: '',
    collegeId: ''
  }
  isEdit.value = false
  activityDialogVisible.value = true
}

const openEditDialog = (activity) => {
  currentActivity.value = {
    ...activity
  }
  isEdit.value = true
  activityDialogVisible.value = true
}

const saveActivity = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
    submitLoading.value = true
    
    if (isEdit.value) {
      await activityAPI.updateAdminActivity(currentActivity.value)
      ElMessage.success('活动编辑成功')
    } else {
      await activityAPI.createAdminActivity(currentActivity.value)
      ElMessage.success('活动新增成功')
    }
    activityDialogVisible.value = false
    await getActivities()
  } catch (error) {
    if (error !== false) {
      ElMessage.error('保存失败: ' + (error.message || '网络错误'))
    }
  } finally {
    submitLoading.value = false
  }
}

const deleteActivity = (activityId) => {
  ElMessageBox.confirm('确定要删除这个活动吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await activityAPI.deleteAdminActivity(activityId)
      ElMessage.success('活动删除成功')
      await getActivities()
    } catch (error) {
      ElMessage.error('删除失败: ' + (error.message || '网络错误'))
    }
  }).catch(() => {})
}

// 搜索
const handleSearch = async () => {
  loading.value = true
  try {
    const response = await activityAPI.getAdminActivities()
    let filtered = response.data || []
    
    // 前端模糊搜索
    if (searchForm.name) {
      filtered = filtered.filter(item => 
        item.name && item.name.toLowerCase().includes(searchForm.name.toLowerCase())
      )
    }
    if (searchForm.type) {
      filtered = filtered.filter(item => item.type === searchForm.type)
    }
    
    activities.value = filtered
    total.value = filtered.length
  } catch (error) {
    console.error('搜索活动失败:', error)
    ElMessage.error('搜索失败，请重试')
  } finally {
    loading.value = false
  }
}

// 重置搜索
const resetSearch = () => {
  Object.assign(searchForm, {
    name: '',
    type: ''
  })
  getActivities()
}

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size
}

const handleCurrentChange = (current) => {
  currentPage.value = current
}

onMounted(() => {
  getActivities()
  getColleges()
  getActivityTypes()
})
</script>

<style scoped>
.activity-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-section {
  margin-bottom: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
