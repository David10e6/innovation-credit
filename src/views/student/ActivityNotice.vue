<template>
  <div class="activity-notice">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">创新活动</span>
        </div>
      </template>
      
      <!-- 标签页 -->
      <el-tabs v-model="activeTab">
        <el-tab-pane label="校级活动" name="school">
          <div class="notice-list">
            <el-card
              v-for="activity in schoolActivities"
              :key="activity.id"
              shadow="hover"
              class="notice-card"
              @click="viewActivityDetail(activity)"
            >
              <div class="notice-header">
                <h3 style="margin: 0; display: flex; align-items: center;">
                  {{ activity.name }}
                </h3>
                <span class="notice-time">{{ activity.startTime }}</span>
              </div>
              <div class="notice-content">{{ activity.details }}</div>
              <div class="notice-footer">
                <span class="notice-publisher">发布单位：{{ activity.organizer }}</span>
                <el-tag type="success">学分：{{ activity.credit }} 分</el-tag>
              </div>
            </el-card>
            <el-empty v-if="schoolActivities.length === 0" description="暂无校级活动" />
          </div>
        </el-tab-pane>
        
        <el-tab-pane label="院级活动" name="college">
          <div class="notice-list">
            <el-card
              v-for="activity in collegeActivities"
              :key="activity.id"
              shadow="hover"
              class="notice-card"
              @click="viewActivityDetail(activity)"
            >
              <div class="notice-header">
                <h3 style="margin: 0; display: flex; align-items: center;">
                  {{ activity.name }}
                </h3>
                <span class="notice-time">{{ activity.startTime }}</span>
              </div>
              <div class="notice-content">{{ activity.details }}</div>
              <div class="notice-footer">
                <span class="notice-publisher">发布单位：{{ activity.organizer }}</span>
                <el-tag type="success">学分：{{ activity.credit }} 分</el-tag>
              </div>
            </el-card>
            <el-empty v-if="collegeActivities.length === 0" description="暂无院级活动" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
    
    <!-- 活动详情弹窗 -->
    <el-dialog
      title="活动详情"
      v-model="detailDialogVisible"
      width="800px"
    >
      <div v-if="currentActivity">
        <h2 style="margin-bottom: 20px;">{{ currentActivity.name }}</h2>
        <div class="detail-info">
          <span>发布单位：{{ currentActivity.organizer || '学校' }}</span>
          <span>开始时间：{{ currentActivity.startTime }}</span>
          <span>截止时间：{{ currentActivity.endTime }}</span>
        </div>
        <div class="detail-content" style="margin-top: 20px; line-height: 1.6;">
          {{ currentActivity.details }}
        </div>
        <div class="detail-credit" style="margin-top: 20px;">
          <el-tag type="success">学分设置：{{ currentActivity.credit }} 分</el-tag>
        </div>
        <div class="detail-info" style="margin-top: 10px;">
          <span>活动类型：{{ currentActivity.type }}</span>
          <span>级别：{{ currentActivity.level }}</span>
        </div>
        <div class="detail-info" style="margin-top: 10px;">
          <span>报名方式：{{ currentActivity.applicationMethod }}</span>
          <span>报名截止：{{ currentActivity.applicationDeadline }}</span>
        </div>
        <div class="detail-info" style="margin-top: 10px;">
          <span>参与要求：{{ currentActivity.participationRequirements }}</span>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElEmpty } from 'element-plus'
import { activityAPI } from '../../api'
import useUserStore from '../../store/user'

const userStore = useUserStore()

// 激活的标签页
const activeTab = ref('school')

// 校级活动数据
const schoolActivities = ref([])

// 院级活动数据
const collegeActivities = ref([])

// 加载状态
const loading = ref(false)

// 详情弹窗
const detailDialogVisible = ref(false)
const currentActivity = ref(null)

// 获取校级活动
const getSchoolActivities = async () => {
  try {
    loading.value = true
    const response = await activityAPI.getSchoolActivities()
    if (response.code === 200 && response.data) {
      schoolActivities.value = response.data || []
    }
  } catch (error) {
    console.error('获取校级活动失败:', error)
    ElMessage.error('获取校级活动失败，请重试')
  } finally {
    loading.value = false
  }
}

// 获取院级活动
const getCollegeActivities = async () => {
  try {
    loading.value = true
    const userInfo = userStore.userInfo
    if (!userInfo || !userInfo.collegeId) {
      ElMessage.error('用户信息不完整，无法获取院级活动')
      return
    }
    const collegeId = userInfo.collegeId
    const response = await activityAPI.getCollegeActivities(collegeId)
    if (response.code === 200 && response.data) {
      collegeActivities.value = response.data || []
    }
  } catch (error) {
    console.error('获取院级活动失败:', error)
    ElMessage.error('获取院级活动失败，请重试')
  } finally {
    loading.value = false
  }
}

// 查看活动详情
const viewActivityDetail = (activity) => {
  currentActivity.value = activity
  detailDialogVisible.value = true
}

// 页面加载时获取活动列表
onMounted(() => {
  getSchoolActivities()
  getCollegeActivities()
})
</script>

<style scoped>
.activity-notice {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.notice-list {
  margin-top: 20px;
}

.notice-card {
  margin-bottom: 15px;
  cursor: pointer;
  transition: all 0.3s;
}

.notice-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.notice-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 10px;
}

.notice-time {
  font-size: 12px;
  color: #909399;
}

.notice-content {
  color: #606266;
  margin-bottom: 15px;
  line-height: 1.5;
}

.notice-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  color: #909399;
}

.notice-publisher {
  font-weight: 500;
}

.detail-info {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
  font-size: 14px;
  color: #606266;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>