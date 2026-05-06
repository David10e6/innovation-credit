<template>
  <div class="apply-edit">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>修改申请</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="140px">
        <el-form-item label="活动名称" prop="activityName">
          <el-input v-model="form.activityName" placeholder="请输入活动名称"></el-input>
        </el-form-item>
        
        <el-form-item label="活动类型" prop="activityType">
          <el-select 
            v-model="form.activityType" 
            placeholder="请选择活动类型"
            @change="calculateCredit"
          >
            <el-option v-for="type in activityTypes" :key="type" :label="type" :value="type"></el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="级别" prop="level">
          <el-select 
            v-model="form.level" 
            placeholder="请选择级别"
            @change="calculateCredit"
          >
            <el-option v-for="level in levels" :key="level" :label="level" :value="level"></el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="获奖名次" prop="role">
          <el-select 
            v-model="form.role" 
            placeholder="请选择或输入名次"
            filterable
            allow-create
            @change="calculateCredit"
          >
            <el-option label="一等奖" value="一等奖"></el-option>
            <el-option label="二等奖" value="二等奖"></el-option>
            <el-option label="三等奖" value="三等奖"></el-option>
            <el-option label="优秀奖" value="优秀奖"></el-option>
            <el-option label="参与奖" value="参与奖"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="申请学分" prop="applyCredit">
          <div class="credit-input">
            <el-button @click="decreaseCredit" :disabled="form.applyCredit <= 0.1">-</el-button>
            <el-input v-model="form.applyCredit" type="number" step="0.1" min="0.1" placeholder="请输入申请学分"></el-input>
            <el-button @click="increaseCredit">+</el-button>
          </div>
          <div class="form-tip">学分根据活动类型、级别和名次自动计算，也可手动调整</div>
        </el-form-item>
        
        <el-form-item label="主办方" prop="organizer">
          <el-input v-model="form.organizer" placeholder="请输入主办方"></el-input>
        </el-form-item>
        
        <el-form-item label="参与时间" prop="participationTime">
          <el-date-picker
            v-model="form.participationTime"
            type="date"
            placeholder="选择参与时间"
            value-format="YYYY-MM-DD"
          ></el-date-picker>
        </el-form-item>
        
        <el-form-item label="佐证材料" prop="proofPath">
          <el-upload
            class="upload-demo"
            action=""
            :auto-upload="false"
            :on-change="handleFileChange"
            :on-remove="handleFileRemove"
            :limit="1"
            :file-list="fileList"
            accept=".jpg,.jpeg,.png,.pdf,.doc,.docx"
          >
            <el-button type="primary">点击上传</el-button>
            <template #tip>
              <div class="el-upload__tip">
                只支持jpg、jpeg、png、pdf、doc、docx格式，大小不超过10MB
              </div>
            </template>
          </el-upload>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="submitForm" :loading="loading">保存修改</el-button>
          <el-button @click="goBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElNotification } from 'element-plus'
import { studentAPI, creditRuleAPI, fileUploadAPI, creditApplicationAPI } from '../../api'
import { validateFile } from '../../utils'

const route = useRoute()
const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const fileList = ref([])

// 活动类型和级别
const activityTypes = ref([])
const levels = ref([])

const form = reactive({
  id: '',
  activityName: '',
  activityType: '',
  applyCredit: 0.1,
  role: '',
  level: '',
  organizer: '',
  participationTime: '',
  proofPath: ''
})

const rules = {
  activityName: [{ required: true, message: '请输入活动名称', trigger: 'blur' }],
  activityType: [{ required: true, message: '请选择活动类型', trigger: 'change' }],
  applyCredit: [
    { required: true, message: '请输入申请学分', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value < 0.1) {
          callback(new Error('学分最少为0.1'))
        } else if (Math.abs(Math.round(value * 10) / 10 - value) > 0.0001) {
          callback(new Error('学分必须为0.1的倍数'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  level: [{ required: true, message: '请选择级别', trigger: 'change' }],
  organizer: [{ required: true, message: '请输入主办方', trigger: 'blur' }],
  participationTime: [{ required: true, message: '请选择参与时间', trigger: 'change' }],
  role: [{ required: true, message: '请选择或输入名次', trigger: 'change' }]
}

// 计算学分
const calculateCredit = async () => {
  if (!form.activityType || !form.level || !form.role) {
    return
  }
  
  try {
    const response = await creditRuleAPI.getCreditRule({
      activityType: form.activityType,
      level: form.level,
      role: form.role
    })
    
    if (response.code === 200 && response.data) {
      form.applyCredit = parseFloat(response.data.credit) || 0.1
    }
  } catch (error) {
    console.error('获取学分规则失败:', error)
  }
}

// 获取活动类型和级别
const getActivityTypes = async () => {
  try {
    const response = await creditRuleAPI.getActivityTypes()
    if (response.code === 200 && response.data) {
      activityTypes.value = response.data.activityTypes || []
      levels.value = response.data.levels || []
    }
  } catch (error) {
    console.error('获取活动类型和级别失败:', error)
  }
}

// 获取申请详情
const getApplyDetail = async () => {
  try {
    const applyId = route.params.id
    const response = await studentAPI.getApplyDetail(applyId)
    const data = response.data
    form.id = data.id
    form.activityName = data.activityName
    form.activityType = data.activityType
    form.applyCredit = data.applyCredit
    form.role = data.role
    form.level = data.level
    form.organizer = data.organizer
    form.participationTime = data.participationTime
    form.proofPath = data.proofPath
    
    // 如果有附件，添加到文件列表
    if (data.proofPath) {
      fileList.value = [{
        name: data.proofPath.split('/').pop(),
        url: data.proofPath
      }]
    }
  } catch (error) {
    console.error('Get apply detail error:', error)
    ElMessage.error('获取申请详情失败')
  }
}

// 学分调整方法
const decreaseCredit = () => {
  if (form.applyCredit > 0.1) {
    form.applyCredit = parseFloat((form.applyCredit - 0.1).toFixed(1))
  }
}

const increaseCredit = () => {
  form.applyCredit = parseFloat((form.applyCredit + 0.1).toFixed(1))
}

// 文件处理方法
const handleFileChange = async (file) => {
  try {
    const validation = validateFile(file.raw)
    if (!validation.valid) {
      ElMessage.error(validation.message)
      fileList.value = []
      form.proofPath = ''
      return
    }
    
    loading.value = true
    const response = await fileUploadAPI.uploadProof(file.raw)
    if (response.code === 200 && response.data) {
      form.proofPath = response.data
      fileList.value = [file]
      ElMessage.success('文件上传成功')
    }
  } catch (error) {
    console.error('文件上传失败:', error)
    ElMessage.error('文件上传失败，请重试')
    fileList.value = []
    form.proofPath = ''
  } finally {
    loading.value = false
  }
}

const handleFileRemove = () => {
  fileList.value = []
  form.proofPath = ''
}

// 提交修改
const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    loading.value = true
    
    // 使用新的带名次的API接口
    const response = await creditApplicationAPI.modifyRejectedWithRank(form, form.role)
    if (response.code === 200) {
      ElMessage.success('修改成功')
      router.push('/student/apply/list')
    } else {
      ElMessage.error('修改失败')
    }
  } catch (error) {
    console.error('Submit form error:', error)
    if (error.name === 'Error') {
      ElMessage.error(error.message)
    } else {
      ElMessage.error('修改失败')
    }
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/student/apply/list')
}

onMounted(() => {
  getActivityTypes()
  getApplyDetail()
})
</script>

<style scoped>
.apply-edit {
  padding: 24px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 48px);
}

.apply-edit .el-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header span {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  padding-left: 12px;
  border-left: 4px solid #409eff;
}

.form-tip {
  color: #909399;
  font-size: 13px;
  margin-top: 8px;
}

.upload-demo {
  margin-top: 10px;
}

.credit-input {
  display: flex;
  align-items: center;
  width: 280px;
}

.credit-input .el-button {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  font-size: 18px;
  font-weight: bold;
  transition: all 0.3s ease;
}

.credit-input .el-button:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);
}

.credit-input .el-input {
  width: 120px;
  margin: 0 12px;
}

.credit-input .el-input__wrapper {
  text-align: center;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}

.credit-input .el-input__wrapper.is-focus {
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.apply-edit .el-form-item__label {
  font-weight: 500;
  color: #606266;
}

.apply-edit .el-input__wrapper,
.apply-edit .el-select__wrapper {
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
}

.apply-edit .el-input__wrapper:hover,
.apply-edit .el-select__wrapper:hover {
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.15);
}

.apply-edit .el-input__wrapper.is-focus,
.apply-edit .el-select__wrapper.is-focus {
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .apply-edit {
    padding: 12px;
  }
  
  .credit-input {
    width: 100%;
    max-width: 280px;
  }
}
</style>
