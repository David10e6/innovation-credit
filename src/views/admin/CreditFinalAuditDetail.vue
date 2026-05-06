&lt;template&gt;
  &lt;div class="credit-final-audit-detail"&gt;
    &lt;el-card&gt;
      &lt;template #header&gt;
        &lt;div class="card-header"&gt;
          &lt;span&gt;学分终审详情&lt;/span&gt;
          &lt;el-button type="primary" @click="goBack"&gt;返回&lt;/el-button&gt;
        &lt;/div&gt;
      &lt;/template&gt;
      &lt;el-loading v-loading="loading" element-loading-text="加载中..." fullscreen&gt;
        &lt;el-descriptions :column="1" border v-if="Object.keys(applyDetail).length &gt; 0"&gt;
          &lt;el-descriptions-item label="申请ID"&gt;{{ applyDetail?.id || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="学生学号"&gt;{{ applyDetail?.studentId || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="学生姓名"&gt;{{ applyDetail?.studentName || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="活动名称"&gt;{{ applyDetail?.activityName || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="活动类型"&gt;{{ applyDetail?.activityType || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="申请学分"&gt;{{ applyDetail?.applyCredit || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="活动级别"&gt;{{ applyDetail?.level || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="主办方"&gt;{{ applyDetail?.organizer || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="参与时间"&gt;{{ applyDetail?.participationTime || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="角色"&gt;{{ applyDetail?.role || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="附件"&gt;
            &lt;el-button v-if="applyDetail?.proofPath" type="primary" size="small" @click="viewAttachment(applyDetail.proofPath)"&gt;
              查看附件
            &lt;/el-button&gt;
            &lt;span v-else&gt;无&lt;/span&gt;
          &lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="申请时间"&gt;{{ applyDetail?.applyTime || '-' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="学院审核意见"&gt;{{ applyDetail?.collegeAuditOpinion || '无' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="学院审核人"&gt;{{ applyDetail?.collegeAuditorUsername || '无' }}&lt;/el-descriptions-item&gt;
          &lt;el-descriptions-item label="学院审核时间"&gt;{{ applyDetail?.collegeAuditTime || '无' }}&lt;/el-descriptions-item&gt;
        &lt;/el-descriptions&gt;
        &lt;el-empty v-else description="暂无详情数据"&gt;&lt;/el-empty&gt;
        
        &lt;div class="audit-section" v-if="Object.keys(applyDetail).length &gt; 0"&gt;
          &lt;el-form :model="auditForm" :rules="rules" ref="auditFormRef" label-width="120px"&gt;
            &lt;el-form-item label="审核结果" prop="status"&gt;
            &lt;el-radio-group v-model="auditForm.status"&gt;
              &lt;el-radio value="2"&gt;通过&lt;/el-radio&gt;
              &lt;el-radio value="3"&gt;驳回&lt;/el-radio&gt;
            &lt;/el-radio-group&gt;
          &lt;/el-form-item&gt;
          &lt;el-form-item label="审核意见" prop="comment"&gt;
              &lt;el-input v-model="auditForm.comment" type="textarea" :rows="3" placeholder="请输入审核意见"&gt;&lt;/el-input&gt;
          &lt;/el-form-item&gt;
          &lt;el-form-item&gt;
              &lt;el-button type="primary" @click="handleAudit" :loading="loading"&gt;提交审核&lt;/el-button&gt;
              &lt;el-button @click="goBack"&gt;取消&lt;/el-button&gt;
          &lt;/el-form-item&gt;
          &lt;/el-form&gt;
        &lt;/div&gt;
      &lt;/el-loading&gt;
    &lt;/el-card&gt;
    
    &lt;!-- 附件预览弹窗 --&gt;
    &lt;el-dialog
      v-model="dialogVisible"
      title="附件预览"
      width="80%"
    &gt;
      &lt;div v-if="previewType === 'image'"&gt;
        &lt;el-image
          :src="previewUrl"
          fit="contain"
          style="width: 100%; height: 600px"
        &gt;
          &lt;template #error&gt;
            &lt;div class="image-slot"&gt;
              &lt;el-icon&gt;&lt;PictureFilled /&gt;&lt;/el-icon&gt;
              &lt;span&gt;图片加载失败&lt;/span&gt;
            &lt;/div&gt;
          &lt;/template&gt;
        &lt;/el-image&gt;
      &lt;/div&gt;
      &lt;div v-else-if="previewType === 'document'"&gt;
        &lt;iframe :src="previewUrl" style="width: 100%; height: 600px; border: none"&gt;&lt;/iframe&gt;
      &lt;/div&gt;
      &lt;div v-else&gt;
        &lt;a :href="previewUrl" target="_blank"&gt;下载附件&lt;/a&gt;
      &lt;/div&gt;
    &lt;/el-dialog&gt;
  &lt;/div&gt;
&lt;/template&gt;

&lt;script setup&gt;
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

const getApplyDetail = async () =&gt; {
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

const handleAudit = async () =&gt; {
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

const goBack = () =&gt; {
  router.push('/admin/credit/final-audit')
}

const viewAttachment = (filePath) =&gt; {
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

onMounted(() =&gt; {
  getApplyDetail()
})
&lt;/script&gt;

&lt;style scoped&gt;
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
&lt;/style&gt;
