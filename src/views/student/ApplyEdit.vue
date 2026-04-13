<template>
  <div class="apply-edit">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>修改申请</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="活动名称" prop="activityName">
          <el-input v-model="form.activityName" placeholder="请输入活动名称"></el-input>
        </el-form-item>
        <el-form-item label="活动类型" prop="activityType">
          <el-select v-model="form.activityType" placeholder="请选择活动类型">
            <el-option v-for="(value, key) in activityTypeMap" :key="key" :label="value" :value="key"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="申请学分" prop="applyCredit">
          <div class="credit-input">
            <el-button @click="decreaseCredit" :disabled="form.applyCredit <= 0.1">-</el-button>
            <el-input v-model.number="form.applyCredit" type="number" step="0.1" min="0.1" placeholder="请输入申请学分" readonly></el-input>
            <el-button @click="increaseCredit">+</el-button>
          </div>
          <div class="form-tip">学分必须为0.1的倍数，最少为0.1</div>
        </el-form-item>
        <el-form-item label="个人角色" prop="role">
          <el-input v-model="form.role" placeholder="请输入个人角色"></el-input>
        </el-form-item>
        <el-form-item label="级别" prop="level">
          <el-input v-model="form.level" placeholder="请输入级别"></el-input>
        </el-form-item>
        <el-form-item label="主办方" prop="organizer">
          <el-input v-model="form.organizer" placeholder="请输入主办方"></el-input>
        </el-form-item>
        <el-form-item label="参与时间" prop="participationTime">
          <el-date-picker v-model="form.participationTime" type="date" placeholder="请选择参与时间" style="width: 100%"></el-date-picker>
        </el-form-item>
        <el-form-item label="附件">
          <el-upload
            class="upload-demo"
            action="http://localhost:8080/api/upload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :file-list="fileList"
            :auto-upload="false"
            ref="uploadRef"
          >
            <template #trigger>
              <el-button type="primary">选择文件</el-button>
            </template>
            <template #tip>
              <div class="el-upload__tip">
                支持上传jpg、jpeg、png、pdf、doc、docx格式文件，大小不超过10MB
              </div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm">保存修改</el-button>
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
import { studentAPI } from '../../api'
import { activityTypeMap, validateCredit } from '../../utils'

const route = useRoute()
const router = useRouter()
const formRef = ref(null)
const uploadRef = ref(null)
const form = reactive({
  id: '',
  activityName: '',
  activityType: '',
  applyCredit: '',
  role: '',
  level: '',
  organizer: '',
  participationTime: '',
  proofPath: ''
})
const fileList = ref([])

const rules = {
  activityName: [
    { required: true, message: '请输入活动名称', trigger: 'blur' }
  ],
  activityType: [
    { required: true, message: '请选择活动类型', trigger: 'change' }
  ],
  applyCredit: [
    { required: true, message: '请输入申请学分', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        const result = validateCredit(value)
        if (!result.valid) {
          callback(new Error(result.message))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  role: [
    { required: true, message: '请输入个人角色', trigger: 'blur' }
  ],
  level: [
    { required: true, message: '请输入级别', trigger: 'blur' }
  ],
  organizer: [
    { required: true, message: '请输入主办方', trigger: 'blur' }
  ],
  participationTime: [
    { required: true, message: '请选择参与时间', trigger: 'change' }
  ]
}

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

const handleUploadSuccess = (response, file, fileList) => {
  if (response.code === 200) {
    form.proofPath = response.data
    ElNotification.success('上传成功')
  } else {
    ElNotification.error('上传失败')
  }
}

const handleUploadError = (error, file, fileList) => {
  ElNotification.error('上传失败')
}

const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    // 提交修改
    const response = await studentAPI.updateApply(form)
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
  }
}

const goBack = () => {
  router.push('/student/apply/list')
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

onMounted(() => {
  getApplyDetail()
})
</script>

<style scoped>
.apply-edit {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.upload-demo {
  margin-top: 10px;
}

.credit-input {
  display: flex;
  align-items: center;
  width: 300px;
}

.credit-input .el-button {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.credit-input .el-input {
  width: 100px;
  margin: 0 10px;
}

.credit-input .el-input__wrapper {
  text-align: center;
}

.form-tip {
  color: #909399;
  font-size: 12px;
  margin-top: 5px;
}
</style>