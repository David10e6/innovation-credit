<template>
  <div class="activity-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>活动管理</span>
          <div>
            <el-button type="primary" @click="openAddDialog">新增活动</el-button>
          </div>
        </div>
      </template>
      
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
          <el-table-column prop="credit" label="学分" width="100" />
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
            <el-option label="科技创新" value="科技创新" />
            <el-option label="社会实践" value="社会实践" />
            <el-option label="学术竞赛" value="学术竞赛" />
            <el-option label="文化活动" value="文化活动" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="学分" prop="credit">
          <el-input-number v-model="currentActivity.credit" :min="0" :step="0.5" placeholder="请输入学分" />
        </el-form-item>
        
        <el-form-item label="主办方" prop="collegeId">
          <el-select v-model="currentActivity.collegeId" placeholder="请选择主办方">
            <el-option v-for="college in colleges" :key="college.id" :label="college.name" :value="college.id" />
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
          <el-button type="primary" @click="saveActivity">保存</el-button>
        </span>
      </template>
    </el-dialog>
    

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { activityAPI, adminAPI } from '../../api'

const activityDialogVisible = ref(false)
const activities = ref([])
const colleges = ref([])
const isEdit = ref(false)
const loading = ref(false)
const formRef = ref(null)

// 当前活动数据
const currentActivity = ref({
  id: '',
  name: '',
  type: '',
  credit: 0,
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
  credit: [{ required: true, message: '请输入学分', trigger: 'blur' }],
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
    activities.value = Array.isArray(response.data) ? response.data : []
  } catch (error) {
    console.error('获取活动列表失败:', error)
    ElMessage.error('获取活动列表失败')
    activities.value = []
  } finally {
    loading.value = false
  }
}

const getColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    colleges.value = Array.isArray(response.data) ? response.data : []
  } catch (error) {
    console.error('获取学院列表失败:', error)
    ElMessage.error('获取学院列表失败')
    colleges.value = []
  }
}

const openAddDialog = () => {
  // 重置表单
  currentActivity.value = {
    id: '',
    name: '',
    type: '',
    credit: 0,
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
  // 直接使用传入的活动数据
  currentActivity.value = {
    ...activity
  }
  isEdit.value = true
  activityDialogVisible.value = true
}

const saveActivity = async () => {
  loading.value = true
  try {
    if (isEdit.value) {
      // 编辑活动
      await activityAPI.updateAdminActivity(currentActivity.value)
      ElMessage.success('活动编辑成功')
    } else {
      // 新增活动
      await activityAPI.createAdminActivity(currentActivity.value)
      ElMessage.success('活动新增成功')
    }
    activityDialogVisible.value = false
    // 重新获取活动列表
    await getActivities()
  } catch (error) {
    ElMessage.error('保存失败: ' + (error.message || '网络错误'))
  } finally {
    loading.value = false
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
      await activityAPI.deleteAdminActivity(activityId)
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



onMounted(() => {
  getActivities()
  getColleges()
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

.activity-list {
  margin-top: 20px;
}

.file-info {
  margin-top: 10px;
  color: #606266;
}

.mt-4 {
  margin-top: 20px;
}
</style>