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
      <div class="activity-list">
        <el-table
          v-loading="loading"
          :data="activities"
          style="width: 100%"
          border
          stripe
        >
          <el-table-column prop="id" label="活动ID" width="100" />
          <el-table-column prop="name" label="活动名称" />
          <el-table-column prop="type" label="活动类型" />
          <el-table-column prop="level" label="级别" width="100" />
          <el-table-column prop="organizer" label="组织者" />
          <el-table-column prop="startTime" label="开始时间" width="180" />
          <el-table-column prop="endTime" label="结束时间" width="180" />
          <el-table-column label="操作" width="150">
            <template #default="scope">
              <el-button size="small" type="primary" @click="openEditDialog(scope.row)">编辑</el-button>
              <el-button size="small" type="danger" @click="deleteActivity(scope.row.id)" style="margin-left: 10px">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 空状态 -->
        <div v-if="!loading && activities.length === 0" class="empty-state">
          <el-empty description="暂无活动数据" />
        </div>
        
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
      </div>
    </el-card>
    
    <!-- 活动表单对话框 -->
    <el-dialog
      v-model="activityDialogVisible"
      :title="isEdit ? '编辑活动' : '新增活动'"
      width="800px"
    >
      <ActivityForm
        v-model="currentActivity"
        :showParticipants="false"
      />
      
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
import useUserStore from '../../store/user'
import ActivityForm from '../../components/ActivityForm.vue'

const activityDialogVisible = ref(false)
const activities = ref([])
const userStore = useUserStore()
const isEdit = ref(false)
const loading = ref(false)
const submitLoading = ref(false)
const activityTypes = ref([])

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
  collegeId: '',
  organizer: '',
  startTime: '',
  endTime: '',
  location: '',
  status: '未开始'
})

const getActivities = async () => {
  loading.value = true
  try {
    const response = await activityAPI.getCounselorCollegeActivities()
    let data = response.data || []
    activities.value = data
    total.value = data.length
  } catch (error) {
    console.error('获取活动列表失败:', error)
    ElMessage.error('获取活动列表失败')
    activities.value = []
  } finally {
    loading.value = false
  }
}

// 获取状态标签类型
const getStatusType = (status) => {
  switch (status) {
    case '未开始':
      return 'info'
    case '进行中':
      return 'warning'
    case '已结束':
      return 'success'
    default:
      return 'default'
  }
}

const openAddDialog = () => {
  // 重置表单
  currentActivity.value = {
    id: '',
    name: '',
    type: '',
    level: '',
    collegeId: userStore.user?.collegeId,
    organizer: userStore.user?.collegeName,
    startTime: '',
    endTime: '',
    location: '',
    status: '未开始'
  }
  isEdit.value = false
  activityDialogVisible.value = true
}

// 获取学院列表
const getColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    console.log('getColleges响应:', response)
  } catch (error) {
    console.error('获取学院列表失败:', error)
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

const openEditDialog = async (activity) => {
  try {
    // 直接使用列表中的活动数据，不额外请求详情
    currentActivity.value = {
      ...activity
    }
    
    isEdit.value = true
    activityDialogVisible.value = true
  } catch (error) {
    console.error('打开编辑对话框失败:', error)
    ElMessage.error('打开编辑对话框失败')
  }
}

const saveActivity = async () => {
  submitLoading.value = true
  try {
    if (isEdit.value) {
      // 编辑活动
      await activityAPI.updateActivity(currentActivity.value)
      ElMessage.success('活动编辑成功')
    } else {
      // 新增活动
      await activityAPI.createActivity(currentActivity.value)
      ElMessage.success('活动新增成功')
    }
    
    activityDialogVisible.value = false
    // 重新获取活动列表
    await getActivities()
  } catch (error) {
    ElMessage.error('保存失败: ' + (error.message || '网络错误'))
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
    loading.value = true
    try {
      await activityAPI.deleteActivity(activityId)
      ElMessage.success('活动删除成功')
      // 重新获取活动列表
      await getActivities()
    } catch (error) {
      ElMessage.error('删除失败: ' + (error.message || '网络错误'))
    } finally {
      loading.value = false
    }
  }).catch(() => {
    // 取消删除
  })
}

// 搜索
const handleSearch = async () => {
  loading.value = true
  try {
    const response = await activityAPI.getCounselorCollegeActivities()
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

.activity-list {
  margin-top: 20px;
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

.file-info {
  margin-top: 10px;
  color: #606266;
}

.mt-4 {
  margin-top: 20px;
}
</style>
