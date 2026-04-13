<template>
  <div class="apply-detail">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>申请详情</span>
          <div>
            <el-button type="primary" @click="goBack">返回</el-button>
            <el-button type="success" @click="resubmitApply" style="margin-left: 10px" v-if="applyDetail.auditStatus === 3">
              重新提交
            </el-button>
          </div>
        </div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="申请ID">{{ handleNull(applyDetail.id) }}</el-descriptions-item>
        <el-descriptions-item label="活动名称">{{ handleNull(applyDetail.activityName) }}</el-descriptions-item>
        <el-descriptions-item label="活动类型">{{ handleNull(applyDetail.activityType) }}</el-descriptions-item>
        <el-descriptions-item label="申请学分">{{ handleNull(applyDetail.applyCredit) }}</el-descriptions-item>
        <el-descriptions-item label="个人角色">{{ handleNull(applyDetail.role) }}</el-descriptions-item>
        <el-descriptions-item label="级别">{{ handleNull(applyDetail.level) }}</el-descriptions-item>
        <el-descriptions-item label="主办方">{{ handleNull(applyDetail.organizer) }}</el-descriptions-item>
        <el-descriptions-item label="参与时间">{{ formatDate(applyDetail.participationTime) || '-' }}</el-descriptions-item>
        <el-descriptions-item label="附件">
          <el-button v-if="applyDetail.proofPath" type="primary" size="small" @click="viewAttachment(applyDetail.proofPath)">
            查看附件
          </el-button>
          <span v-else>无</span>
        </el-descriptions-item>
        <el-descriptions-item label="审核状态">
          <el-tag :type="getStatusType(applyDetail.auditStatus, applyDetail.auditLevel, applyDetail.status)">
            {{ getStatusText(applyDetail.auditStatus, applyDetail.auditLevel, applyDetail.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="申请时间">{{ formatDate(applyDetail.applyTime) || '-' }}</el-descriptions-item>
        <el-descriptions-item label="院级审核意见">{{ handleNull(applyDetail.collegeAuditOpinion, '无') }}</el-descriptions-item>
        <el-descriptions-item label="院级审核时间">{{ formatDate(applyDetail.collegeAuditTime) || '无' }}</el-descriptions-item>
        <el-descriptions-item label="校级审核意见">{{ handleNull(applyDetail.schoolAuditOpinion, '无') }}</el-descriptions-item>
        <el-descriptions-item label="校级审核时间">{{ formatDate(applyDetail.schoolAuditTime) || '无' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>
    
    <!-- 附件预览弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      title="附件预览"
      width="80%"
    >
      <div v-if="previewType === 'image'">
        <el-image
          :src="previewUrl"
          fit="contain"
          style="width: 100%; height: 600px"
        >
          <template #error>
            <div class="image-slot">
              <el-icon><PictureFilled /></el-icon>
              <span>图片加载失败</span>
            </div>
          </template>
        </el-image>
      </div>
      <div v-else-if="previewType === 'document'">
        <iframe :src="previewUrl" style="width: 100%; height: 600px; border: none"></iframe>
      </div>
      <div v-else>
        <a :href="previewUrl" target="_blank">下载附件</a>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { PictureFilled } from '@element-plus/icons-vue'
import { studentAPI, creditApplicationAPI } from '../../api'
import { auditStatusMap, activityTypeMap, formatDate, handleNull, getStatusText, getStatusType } from '../../utils'

const route = useRoute()
const router = useRouter()
const applyDetail = ref({})

// 弹窗相关变量
const dialogVisible = ref(false)
const previewUrl = ref('')
const previewType = ref('')

const auditStatusType = {
  0: 'info',
  1: 'success',
  2: 'success',
  3: 'danger',
  4: 'success',
  5: 'danger'
}

const getApplyDetail = async () => {
  try {
    const applyId = route.params.id
    const response = await studentAPI.getApplyDetail(applyId)
    applyDetail.value = response.data
  } catch (error) {
    console.error('Get apply detail error:', error)
    ElMessage.error('获取申请详情失败')
  }
}

const resubmitApply = async () => {
  try {
    const response = await creditApplicationAPI.resubmit({ id: applyDetail.value.id })
    if (response.code === 200) {
      ElMessage.success('重新提交成功')
      // 刷新申请详情
      getApplyDetail()
    } else {
      ElMessage.error('重新提交失败')
    }
  } catch (error) {
    console.error('Resubmit apply error:', error)
    ElMessage.error('重新提交失败')
  }
}

const goBack = () => {
  router.push('/student/apply/list')
}

const viewAttachment = (filePath) => {
  try {
    // 构建完整的附件URL
    const url = 'http://localhost:8080/api' + filePath
    previewUrl.value = url
    
    // 判断文件类型
    const extension = filePath.split('.').pop().toLowerCase()
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(extension)) {
      previewType.value = 'image'
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(extension)) {
      previewType.value = 'document'
    } else {
      previewType.value = 'other'
    }
    
    // 打开弹窗
    dialogVisible.value = true
  } catch (error) {
    console.error('查看附件失败:', error)
    ElMessage.error('查看附件失败，请重试')
  }
}

onMounted(() => {
  getApplyDetail()
})
</script>

<style scoped>
.apply-detail {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.image-slot {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background-color: #f0f0f0;
  color: #909399;
}

.image-slot .el-icon {
  font-size: 48px;
  margin-bottom: 10px;
}
</style>