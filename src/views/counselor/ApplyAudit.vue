<template>
  <div class="apply-audit">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>审核学分申请</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="学生学号">{{ applyDetail.studentId }}</el-descriptions-item>
        <el-descriptions-item label="学生姓名">{{ applyDetail.studentName }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ applyDetail.major }}</el-descriptions-item>
        <el-descriptions-item label="班级">{{ applyDetail.className }}</el-descriptions-item>
        <el-descriptions-item label="活动名称">{{ applyDetail.activityName }}</el-descriptions-item>
        <el-descriptions-item label="活动类型">{{ applyDetail.activityType }}</el-descriptions-item>
        <el-descriptions-item label="级别">{{ applyDetail.level }}</el-descriptions-item>
        <el-descriptions-item label="主办方">{{ applyDetail.organizer }}</el-descriptions-item>
        <el-descriptions-item label="参与时间">{{ applyDetail.participationTime }}</el-descriptions-item>
        <el-descriptions-item label="申请学分">{{ applyDetail.applyCredit }}</el-descriptions-item>
        <el-descriptions-item label="个人角色">{{ applyDetail.role }}</el-descriptions-item>
        <el-descriptions-item label="附件">
          <el-button v-if="applyDetail.proofPath" type="primary" size="small" @click="viewAttachment(applyDetail.proofPath)">
            查看附件
          </el-button>
          <span v-else>无</span>
        </el-descriptions-item>
        <el-descriptions-item label="申请时间">{{ formatDate(applyDetail.applyTime) || '-' }}</el-descriptions-item>
        <el-descriptions-item label="院级审核意见">{{ applyDetail.collegeAuditOpinion || '无' }}</el-descriptions-item>
        <el-descriptions-item label="院级审核时间">{{ formatDate(applyDetail.collegeAuditTime) || '无' }}</el-descriptions-item>
        <el-descriptions-item label="校级审核意见">{{ applyDetail.schoolAuditOpinion || '无' }}</el-descriptions-item>
        <el-descriptions-item label="校级审核时间">{{ formatDate(applyDetail.schoolAuditTime) || '无' }}</el-descriptions-item>
      </el-descriptions>
      
      <div class="audit-section">
        <el-form :model="auditForm" :rules="rules" ref="auditFormRef" label-width="120px">
          <el-form-item label="审核结果" prop="status">
            <el-radio-group v-model="auditForm.status">
              <el-radio label="2">通过</el-radio>
              <el-radio label="3">驳回</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="审核意见" prop="opinion">
            <el-input v-model="auditForm.opinion" type="textarea" rows="3" placeholder="请输入审核意见"></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAudit" :loading="loading">提交审核</el-button>
          </el-form-item>
        </el-form>
      </div>
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
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { PictureFilled } from '@element-plus/icons-vue'
import { counselorAPI, auditAPI } from '../../api'
import { formatDate } from '../../utils'

const route = useRoute()
const router = useRouter()
const applyDetail = ref({})
const auditFormRef = ref(null)
const loading = ref(false)

// 弹窗相关变量
const dialogVisible = ref(false)
const previewUrl = ref('')
const previewType = ref('')

const auditForm = reactive({
  status: '',
  opinion: ''
})

const rules = {
  status: [{ required: true, message: '请选择审核结果', trigger: 'change' }],
  opinion: [{ required: true, message: '请输入审核意见', trigger: 'blur' }]
}

const getApplyDetail = async () => {
  try {
    const applyId = route.params.id
    console.log('获取申请详情:', applyId)
    const response = await counselorAPI.getApplyDetail(applyId)
    applyDetail.value = response.data
  } catch (error) {
    console.error('Get apply detail error:', error)
    ElMessage.error('获取申请详情失败')
  }
}

const handleAudit = async () => {
  if (!auditFormRef.value) return
  
  try {
    await auditFormRef.value.validate()
    loading.value = true
    
    const applyId = route.params.id
    // 从localStorage获取审核人信息
    const userInfoStr = localStorage.getItem('userInfo')
    const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null
    const auditorId = userInfo?.id || userInfo?.username
    const auditorName = userInfo?.name || userInfo?.username
    
    const response = await auditAPI.collegeAudit({
      id: applyId,
      status: auditForm.status,
      opinion: auditForm.opinion,
      auditorId: auditorId,
      auditorName: auditorName
    })
    
    ElMessage.success('审核成功')
    router.push('/counselor/apply/list')
  } catch (error) {
    console.error('Audit apply error:', error)
    ElMessage.error(error.message || '审核失败')
  } finally {
    loading.value = false
  }
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

const goBack = () => {
  router.push('/counselor/apply/list')
}

onMounted(() => {
  getApplyDetail()
})
</script>

<style scoped>
.apply-audit {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.audit-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
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