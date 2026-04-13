<template>
  <div class="credit-apply">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学分申请</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-form :model="applyForm" :rules="rules" ref="applyFormRef" label-width="120px">
        <el-form-item label="活动名称" prop="activityName">
          <el-input v-model="applyForm.activityName" placeholder="请输入活动名称"></el-input>
        </el-form-item>

        <el-form-item label="申请学分" prop="applyCredit">
          <div class="credit-input">
            <el-button @click="decreaseCredit" :disabled="applyForm.applyCredit <= 0.1">-</el-button>
            <el-input v-model="applyForm.applyCredit" type="number" step="0.1" min="0.1" placeholder="请输入申请学分" readonly></el-input>
            <el-button @click="increaseCredit">+</el-button>
          </div>
          <div class="form-tip">学分必须为0.1的倍数，最少为0.1</div>
        </el-form-item>
        
        <el-form-item label="活动类型" prop="activityType">
          <el-select v-model="applyForm.activityType" placeholder="请选择活动类型">
            <el-option v-for="type in activityTypes" :key="type" :label="type" :value="type"></el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="级别" prop="level">
          <el-select v-model="applyForm.level" placeholder="请选择级别">
            <el-option v-for="level in levels" :key="level" :label="level" :value="level"></el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="主办方" prop="organizer">
          <el-input v-model="applyForm.organizer" placeholder="请输入主办方"></el-input>
        </el-form-item>
        
        <el-form-item label="参与时间" prop="participationTime">
          <el-date-picker
            v-model="applyForm.participationTime"
            type="date"
            placeholder="选择参与时间"
            value-format="YYYY-MM-DD"
          ></el-date-picker>
        </el-form-item>
        
        <el-form-item label="个人角色" prop="role">
          <el-input v-model="applyForm.role" placeholder="请输入个人角色"></el-input>
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
          <el-button type="primary" @click="handleSubmit" :loading="loading">提交申请</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { studentAPI, creditRuleAPI, fileUploadAPI } from '../../api'
import { validateFile } from '../../utils'

const router = useRouter()
const applyFormRef = ref(null)
const loading = ref(false)
const fileList = ref([])

// 活动类型和级别
const activityTypes = ref([])
const levels = ref([])

const applyForm = reactive({
  activityName: '',
  activityType: '',
  applyCredit: 0.1,
  role: '',
  participationTime: '',
  level: '',
  organizer: '',
  proofPath: '',
  collegeId: (() => {
    try {
      const userInfoStr = localStorage.getItem('userInfo');
      const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
      return userInfo?.collegeId || '';
    } catch (e) {
      console.error('解析 userInfo 失败:', e);
      return '';
    }
  })()
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
  role: [{ required: true, message: '请输入个人角色', trigger: 'blur' }],
  proofPath: [{ required: true, message: '请上传佐证材料', trigger: 'change' }]
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
    ElMessage.error('获取活动类型和级别失败，请重试')
  }
}

// 学分调整方法
const decreaseCredit = () => {
  if (applyForm.applyCredit > 0.1) {
    applyForm.applyCredit = parseFloat((applyForm.applyCredit - 0.1).toFixed(1))
  }
}

const increaseCredit = () => {
  applyForm.applyCredit = parseFloat((applyForm.applyCredit + 0.1).toFixed(1))
}

// 文件处理方法
const handleFileChange = async (file) => {
  try {
    const validation = validateFile(file.raw)
    if (!validation.valid) {
      ElMessage.error(validation.message)
      fileList.value = []
      applyForm.proofPath = ''
      return
    }
    
    loading.value = true
    const response = await fileUploadAPI.uploadProof(file.raw)
    if (response.code === 200 && response.data) {
      applyForm.proofPath = response.data
      fileList.value = [file]
      ElMessage.success('文件上传成功')
    }
  } catch (error) {
    console.error('文件上传失败:', error)
    ElMessage.error('文件上传失败，请重试')
    fileList.value = []
    applyForm.proofPath = ''
  } finally {
    loading.value = false
  }
}

const handleFileRemove = () => {
  fileList.value = []
  applyForm.proofPath = ''
}

// 提交申请
const handleSubmit = async () => {
  if (!applyFormRef.value) return
  
  try {
    await applyFormRef.value.validate()
    loading.value = true
    
    // 构建请求数据
    const studentId = (() => {
      try {
        const userInfoStr = localStorage.getItem('userInfo');
        const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
        return userInfo?.studentId || '';
      } catch (e) {
        console.error('解析 userInfo 失败:', e);
        return '';
      }
    })()
    
    const requestData = {
      studentId,
      activityName: applyForm.activityName,
      activityType: applyForm.activityType,
      level: applyForm.level,
      organizer: applyForm.organizer,
      participationTime: applyForm.participationTime,
      applyCredit: applyForm.applyCredit,
      role: applyForm.role,
      proofPath: applyForm.proofPath,
      collegeId: applyForm.collegeId
    }
    
    const response = await studentAPI.applyCredit(requestData)
    ElMessage.success('申请成功')
    router.push('/student/apply/list')
  } catch (error) {
    console.error('Apply credit error:', error)
    ElMessage.error(error.message || '申请失败')
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/student')
}

// 页面加载时获取活动类型和级别
onMounted(() => {
  getActivityTypes()
})
</script>

<style scoped>
.credit-apply {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.form-tip {
  color: #909399;
  font-size: 12px;
  margin-top: 5px;
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
</style>