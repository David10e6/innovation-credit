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
      <ActivityForm
        v-model="currentActivity"
        @open-participant-select="openParticipantDialog"
      />
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="activityDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveActivity">保存</el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 参与者选择对话框 -->
    <ParticipantSelectDialog
      v-model:visible="participantSelectVisible"
      :existing-participants="currentActivity.participants"
      @confirm="handleParticipantConfirm"
    />
    

    

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { activityAPI } from '../../api'
import useUserStore from '../../store/user'
import ActivityForm from '../../components/ActivityForm.vue'
import ParticipantSelectDialog from '../../components/ParticipantSelectDialog.vue'

const participantDialogVisible = ref(false)
const activityDialogVisible = ref(false)
const participantSelectVisible = ref(false)
const activities = ref([])
const userStore = useUserStore()
const isEdit = ref(false)
const loading = ref(false)

// 当前活动数据
const currentActivity = ref({
  id: '',
  name: '',
  type: '',
  credit: 0,
  organizer: '',
  startTime: '',
  endTime: '',
  location: '',
  status: '未开始',
  participants: []
})

// 文件变量
const singleParticipantFile = ref(null)
const currentActivityId = ref(null)



const getActivities = async () => {
  loading.value = true
  try {
    const response = await activityAPI.getCounselorCollegeActivities()
    activities.value = response.data || []
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
    credit: 0,
    organizer: '',
    startTime: '',
    endTime: '',
    location: '',
    status: '未开始',
    participants: []
  }
  isEdit.value = false
  activityDialogVisible.value = true
}

const openEditDialog = async (activity) => {
  loading.value = true
  try {
    // 获取活动详情，包括参与者信息
    const detailResponse = await activityAPI.getActivityDetail(activity.id)
    const participantsResponse = await activityAPI.getActivityParticipants(activity.id)
    
    currentActivity.value = {
      ...detailResponse.data,
      participants: participantsResponse.data || []
    }
    isEdit.value = true
    activityDialogVisible.value = true
  } catch (error) {
    console.error('获取活动详情失败:', error)
    ElMessage.error('获取活动详情失败')
  } finally {
    loading.value = false
  }
}

const saveActivity = async () => {
  loading.value = true
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

const openParticipantDialog = () => {
  participantSelectVisible.value = true
}

const handleParticipantConfirm = (participants) => {
  currentActivity.value.participants = participants
  ElMessage.success(`已选择 ${participants.length} 名参与者`)
}

const handleSingleParticipantFileChange = (file) => {
  singleParticipantFile.value = file.raw
}

const importParticipants = (activityId) => {
  currentActivityId.value = activityId
  singleParticipantFile.value = null
  participantDialogVisible.value = true
}

const handleImportParticipants = async () => {
  try {
    if (!singleParticipantFile.value) {
      ElMessage.warning('请选择参与者Excel文件')
      return
    }
    
    await activityAPI.importParticipants(currentActivityId.value, singleParticipantFile.value)
    ElMessage.success('参与者导入成功')
    participantDialogVisible.value = false
    getActivities()
  } catch (error) {
    ElMessage.error('导入失败: ' + (error.message || '网络错误'))
  }
}

onMounted(() => {
  getActivities()
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