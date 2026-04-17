<template>
  <div class="school-notice">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>消息通知</span>
        </div>
      </template>
    <div class="notice-tabs">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="学院通知" name="college">
          <div class="notice-list">
            <el-timeline v-if="collegeNotices.length > 0">
              <el-timeline-item
                v-for="notice in collegeNotices"
                :key="notice.id"
                :timestamp="notice.publishTime"
                type="success"
                placement="top"
              >
                <el-card class="notice-card" @click="viewNoticeDetail(notice)">
                  <h3 style="margin-bottom: 10px;">{{ notice.title }}</h3>
                  <p style="color: #606266; line-height: 1.5;">{{ notice.content }}</p>
                </el-card>
              </el-timeline-item>
            </el-timeline>
            <div v-else class="empty-notice">
              <el-empty description="暂无学院通知" />
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="学校通知" name="school">
          <div class="notice-list">
            <el-timeline v-if="schoolNotices.length > 0">
              <el-timeline-item
                v-for="notice in schoolNotices"
                :key="notice.id"
                :timestamp="notice.publishTime"
                type="primary"
                placement="top"
              >
                <el-card class="notice-card" @click="viewNoticeDetail(notice)">
                  <h3 style="margin-bottom: 10px;">{{ notice.title }}</h3>
                  <p style="color: #606266; line-height: 1.5;">{{ notice.content }}</p>
                </el-card>
              </el-timeline-item>
            </el-timeline>
            <div v-else class="empty-notice">
              <el-empty description="暂无学校通知" />
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 消息详情弹窗 -->
    <el-dialog
      title="消息详情"
      v-model="detailDialogVisible"
      width="600px"
    >
      <div v-if="currentNotice">
        <h2 style="margin-bottom: 20px;">{{ currentNotice.title }}</h2>
        <div class="detail-info">
          <span>发布时间：{{ currentNotice.publishTime }}</span>
          <span>
            通知类型：
            <el-tag :type="currentNotice.type === 'college' ? 'success' : 'primary'">
              {{ currentNotice.type === 'college' ? '学院通知' : '学校通知' }}
            </el-tag>
          </span>
        </div>
        <div class="detail-content" style="margin-top: 20px; line-height: 1.8;">
          {{ currentNotice.content }}
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElEmpty } from 'element-plus'
import { noticeAPI } from '../../api'
import useUserStore from '../../store/user'

const userStore = useUserStore()

// 当前激活的标签页
const activeTab = ref('college')

// 学院通知数据
const collegeNotices = ref([])

// 学校通知数据
const schoolNotices = ref([])

// 加载状态
const loading = ref(false)

// 详情弹窗
const detailDialogVisible = ref(false)
const currentNotice = ref(null)

// 获取通知列表
const getNotices = async () => {
  try {
    loading.value = true
    const userInfo = userStore.userInfo
    if (!userInfo || !userInfo.collegeId) {
      ElMessage.error('用户信息不完整，无法获取通知')
      return
    }
    
    const collegeId = userInfo.collegeId
    const response = await noticeAPI.getStudentNotices(collegeId)
    
    if (response.code === 200 && response.data) {
      // 直接获取学院通知和学校通知，并添加type字段
      const collegeList = (response.data.collegeNotices || []).map(item => ({
        ...item,
        type: 'college'
      }))
      const schoolList = (response.data.schoolNotices || []).map(item => ({
        ...item,
        type: 'school'
      }))
      collegeNotices.value = collegeList
      schoolNotices.value = schoolList
    }
  } catch (error) {
    console.error('获取通知列表失败:', error)
    ElMessage.error('获取通知失败，请重试')
  } finally {
    loading.value = false
  }
}

// 查看消息详情
const viewNoticeDetail = (notice) => {
  currentNotice.value = notice
  detailDialogVisible.value = true
}

// 页面加载时获取通知列表
onMounted(() => {
  getNotices()
})
</script>

<style scoped>
.school-notice {
  padding: 24px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 48px);
}

.school-notice .el-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border: none;
}

.school-notice .el-card__header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px 12px 0 0;
  padding: 16px 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header span {
  font-size: 18px;
  font-weight: 600;
  color: white;
  padding-left: 12px;
  border-left: 4px solid rgba(255, 255, 255, 0.6);
}

.notice-list {
  margin-top: 20px;
}

.el-timeline-item {
  margin-bottom: 24px;
}

.notice-card {
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.notice-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.notice-card h3 {
  margin: 0 0 12px 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.notice-card p {
  margin: 0;
  color: #606266;
  line-height: 1.6;
}

.detail-info {
  display: flex;
  flex-wrap: wrap;
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

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .school-notice {
    padding: 12px;
  }
  
  .notice-card {
    padding: 12px;
  }
  
  .notice-card h3 {
    font-size: 14px;
  }
  
  .notice-card p {
    font-size: 13px;
  }
}
</style>