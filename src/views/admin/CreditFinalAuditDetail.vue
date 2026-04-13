<template>
  <div class="credit-final-audit-detail">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学分终审详情</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-loading v-loading="loading" element-loading-text="加载中..." fullscreen>
        <el-descriptions :column="1" border v-if="Object.keys(applyDetail).length > 0">
          <el-descriptions-item label="申请ID">{{ applyDetail.id }}</el-descriptions-item>
          <el-descriptions-item label="学生学号">{{ applyDetail.studentId }}</el-descriptions-item>
          <el-descriptions-item label="学生姓名">{{ applyDetail.studentName }}</el-descriptions-item>
          <el-descriptions-item label="活动名称">{{ applyDetail.activityName }}</el-descriptions-item>
          <el-descriptions-item label="活动类型">{{ applyDetail.activityType }}</el-descriptions-item>
          <el-descriptions-item label="申请学分">{{ applyDetail.applyCredit }}</el-descriptions-item>
          <el-descriptions-item label="活动级别">{{ applyDetail.level }}</el-descriptions-item>
          <el-descriptions-item label="主办方">{{ applyDetail.organizer }}</el-descriptions-item>
          <el-descriptions-item label="参与时间">{{ applyDetail.participationTime }}</el-descriptions-item>
          <el-descriptions-item label="角色">{{ applyDetail.role }}</el-descriptions-item>
          <el-descriptions-item label="附件">
            <el-button v-if="applyDetail.proofPath" type="primary" size="small" @click="viewAttachment(applyDetail.proofPath)">
              查看附件
            </el-button>
            <span v-else>无</span>
          </el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ applyDetail.applyTime }}</el-descriptions-item>
          <el-descriptions-item label="学院审核意见">{{ applyDetail.collegeAuditOpinion || '无' }}</el-descriptions-item>
          <el-descriptions-item label="学院审核人">{{ applyDetail.collegeAuditorUsername || '无' }}</el-descriptions-item>
          <el-descriptions-item label="学院审核时间">{{ applyDetail.collegeAuditTime || '无' }}</el-descriptions-item>
        </el-descriptions>
        <el-empty v-else description="暂无详情数据"></el-empty>
        
        <div class="audit-section" v-if="Object.keys(applyDetail).length > 0">
          <el-form :model="auditForm" :rules="rules" ref="auditFormRef" label-width="120px">
            <el-form-item label="审核结果" prop="status">
            <el-radio-group v-model="auditForm.status">
              <el-radio label="2">通过</el-radio>
              <el-radio label="3">驳回</el-radio>
            </el-radio-group>
          </el-form-item>
            <el-form-item label="审核意见" prop="comment">
              <el-input v-model="auditForm.comment" type="textarea" rows="3" placeholder="请输入审核意见"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleAudit" :loading="loading">提交审核</el-button>
              <el-button @click="goBack">取消</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-loading>
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
import { activityTypeMap } from '../../utils'
import useUserStore from '../../store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const applyDetail = ref({})
const auditFormRef = ref(null)
const loading = ref(false)

// 弹窗相关变量
const dialogVisible = ref(false)
const previewUrl = ref('')
const previewType = ref('')

const auditForm = reactive({
  status: '',
  comment: ''
})

const rules = {
  status: [{ required: true, message: '请选择审核结果', trigger: 'change' }],
  comment: [{ required: true, message: '请输入审核意见', trigger: 'blur' }]
}

const getApplyDetail = async () => {
  loading.value = true
  try {
    const applyId = route.params.id
    const response = await counselorAPI.getApplyDetail(applyId)
    applyDetail.value = response.data || {}
  } catch (error) {
    console.error('Get apply detail error:', error)
    ElMessage.error('获取申请详情失败')
    applyDetail.value = {}
  } finally {
    loading.value = false
  }
}

const handleAudit = async () => {
  if (!auditFormRef.value) return
  
  try {
    await auditFormRef.value.validate()
    loading.value = true
    
    const applyId = route.params.id
    const userInfo = userStore.getUserInfo
    
    // 直接使用状态值，因为模板中已经设置为正确的状态码（2-通过，3-驳回）
    const status = parseInt(auditForm.status)
    
    const response = await auditAPI.schoolAudit({
      id: applyId,
      status: status,
      opinion: auditForm.comment,
      auditorId: userInfo.id,
      auditorName: userInfo.name
    })
    
    if (response.code === 200) {
      ElMessage.success('审核操作成功')
      
      // 如果审核通过，显示学分同步提示
      if (status === 2) {
        ElMessage.success('学分已同步')
      }
      
      router.push('/admin/credit/final-audit')
    } else {
      ElMessage.error(response.msg || '审核操作失败')
    }
  } catch (error) {
    console.error('Audit apply error:', error)
    ElMessage.error('网络错误，请稍后重试')
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/admin/credit/final-audit')
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
.credit-final-audit-detail {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.audit-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .credit-final-audit-detail {
    padding: 10px;
  }
  
  .el-card {
    padding: 10px;
  }
  
  .el-descriptions {
    font-size: 12px;
  }
  
  .el-descriptions__label {
    width: 80px !important;
  }
  
  .el-form-item {
    margin-bottom: 15px;
  }
  
  .el-form-item__label {
    width: 100px !important;
    font-size: 12px;
  }
  
  .el-form-item__content {
    margin-left: 110px !important;
  }
  
  .el-button {
    font-size: 12px;
    padding: 4px 8px;
  }
  
  .el-input__textarea {
    font-size: 12px;
  }
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