<template>
  <div class="activity-form">
    <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
      <el-form-item label="活动名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入活动名称" />
      </el-form-item>
      
      <el-form-item label="活动类型" prop="type">
        <el-select v-model="form.type" placeholder="请选择活动类型">
          <el-option 
            v-for="type in activityTypes" 
            :key="getTypeKey(type)" 
            :label="getTypeName(type)" 
            :value="getTypeValue(type)" 
          />
        </el-select>
      </el-form-item>
      
      <el-form-item label="活动级别" prop="level">
        <el-select v-model="form.level" placeholder="请选择活动级别">
          <el-option label="院级" value="院级" />
          <el-option label="校级" value="校级" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="主办方" prop="collegeId">
        <el-select v-model="form.collegeId" placeholder="请选择主办方">
          <el-option 
            v-for="college in colleges" 
            :key="getCollegeKey(college)" 
            :label="getCollegeName(college)" 
            :value="getCollegeId(college)" 
          />
        </el-select>
      </el-form-item>
      
      <el-form-item label="活动详情" prop="details">
        <el-input v-model="form.details" type="textarea" placeholder="请输入活动详情" />
      </el-form-item>
      
      <el-form-item label="参与方式" prop="applicationMethod">
        <el-input v-model="form.applicationMethod" placeholder="请输入参与方式" />
      </el-form-item>
      
      <el-form-item label="参与要求" prop="participationRequirements">
        <el-input v-model="form.participationRequirements" placeholder="请输入参与要求" />
      </el-form-item>
      
      <el-form-item label="报名截止时间" prop="applicationDeadline">
        <el-date-picker
          v-model="form.applicationDeadline"
          type="datetime"
          placeholder="选择报名截止时间"
          style="width: 100%"
        />
      </el-form-item>
      
      <el-form-item label="开始时间" prop="startTime">
        <el-date-picker
          v-model="form.startTime"
          type="datetime"
          placeholder="选择开始时间"
          style="width: 100%"
        />
      </el-form-item>
      
      <el-form-item label="结束时间" prop="endTime">
        <el-date-picker
          v-model="form.endTime"
          type="datetime"
          placeholder="选择结束时间"
          style="width: 100%"
        />
      </el-form-item>
    </el-form>
    
    <!-- 参与者管理 (仅在 showParticipants 为 true 时显示) -->
    <div v-if="showParticipants" class="participants-section">
      <div class="section-header">
        <h4>参与者管理 ({{ form.participants?.length || 0 }})</h4>
        <div class="action-buttons">
          <el-upload
            class="upload-demo"
            action=""
            :auto-upload="false"
            :on-change="handleFileChange"
            accept=".xlsx"
            :show-file-list="false"
          >
            <el-button type="success" size="small">Excel批量导入</el-button>
          </el-upload>
          <el-button type="primary" size="small" @click="openParticipantSelect">添加参与者</el-button>
        </div>
      </div>
      
      <div v-if="form.participants && form.participants.length > 0" class="participants-list">
        <el-tag
          v-for="(participant, index) in form.participants"
          :key="participant.studentId || participant['学号'] || participant.id || index"
          closable
          @close="removeParticipant(index)"
          style="margin: 5px"
        >
          {{ participant.studentName || participant.name || participant['姓名'] }} ({{ participant.studentId || participant['学号'] || participant.id }})
        </el-tag>
      </div>
      
      <div v-else class="empty-participants">
        暂无参与者，请点击上方按钮添加
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { creditRuleAPI, adminAPI } from '../api'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },
  showParticipants: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:modelValue', 'open-participant-select', 'import-excel'])

const formRef = ref(null)
const activityTypes = ref([])
const colleges = ref([])

const form = reactive({
  id: '',
  name: '',
  type: '',
  level: '',
  details: '',
  applicationMethod: '',
  participationRequirements: '',
  applicationDeadline: '',
  startTime: '',
  endTime: '',
  collegeId: '',
  organizer: '',
  participants: []
})

const rules = {
  name: [{ required: true, message: '请输入活动名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择活动类型', trigger: 'change' }],
  level: [{ required: true, message: '请选择活动级别', trigger: 'change' }],
  collegeId: [{ required: true, message: '请选择主办方', trigger: 'change' }],
  details: [{ required: true, message: '请输入活动详情', trigger: 'blur' }],
  applicationMethod: [{ required: true, message: '请输入参与方式', trigger: 'blur' }],
  participationRequirements: [{ required: true, message: '请输入参与要求', trigger: 'blur' }],
  applicationDeadline: [{ required: true, message: '请选择报名截止时间', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }]
}

// 辅助函数：获取活动类型的key
const getTypeKey = (type) => {
  return type.id || JSON.stringify(type)
}

// 辅助函数：获取活动类型名称
const getTypeName = (type) => {
  return type.name || String(type)
}

// 辅助函数：获取活动类型值
const getTypeValue = (type) => {
  return type.id || type.name || String(type)
}

// 获取活动类型
const getActivityTypes = async () => {
  try {
    const response = await creditRuleAPI.getActivityTypes()
    console.log('getActivityTypes响应:', response)
    activityTypes.value = response.data?.activityTypes || []
    console.log('活动类型数据:', activityTypes.value)
  } catch (error) {
    console.error('获取活动类型失败:', error)
    // 如果获取失败，使用默认值
    activityTypes.value = ['科技创新', '社会实践', '学术竞赛', '文化活动', '其他']
  }
}

// 辅助函数：获取学院的key
const getCollegeKey = (college) => {
  return college.id || college.collegeId || JSON.stringify(college)
}

// 辅助函数：获取学院名称
const getCollegeName = (college) => {
  return college.name || college.collegeName || String(college)
}

// 辅助函数：获取学院ID
const getCollegeId = (college) => {
  return college.id || college.collegeId || String(college)
}

// 获取学院列表
const getColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    console.log('getColleges响应:', response)
    // 适配不同的数据格式
    if (response.data) {
      if (Array.isArray(response.data)) {
        colleges.value = response.data
      } else if (response.data.rows) {
        colleges.value = response.data.rows
      } else if (Array.isArray(response)) {
        colleges.value = response
      }
    } else {
      colleges.value = response || []
    }
    console.log('学院数据:', colleges.value)
  } catch (error) {
    console.error('获取学院列表失败:', error)
    ElMessage.error('获取学院列表失败')
    colleges.value = []
  }
}

// 初始化表单数据
const initFormData = () => {
  if (props.modelValue) {
    Object.assign(form, props.modelValue)
  }
}

// 组件挂载时初始化表单数据
onMounted(async () => {
  await Promise.all([
    getActivityTypes(),
    getColleges()
  ])
  initFormData()
})

// 监听modelValue变化，更新表单数据
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    Object.assign(form, newValue)
  }
}, { deep: true })

// 监听表单变化，更新modelValue
watch(form, (newValue) => {
  emit('update:modelValue', { ...newValue })
}, { deep: true })

// 打开参与者选择对话框
const openParticipantSelect = () => {
  emit('open-participant-select')
}

// 处理文件选择
const handleFileChange = (file) => {
  emit('import-excel', file.raw)
}

// 移除参与者
const removeParticipant = (index) => {
  form.participants.splice(index, 1)
}

// 验证表单
defineExpose({
  validate: async () => {
    if (!formRef.value) return false
    try {
      await formRef.value.validate()
      return true
    } catch (error) {
      return false
    }
  },
  resetFields: () => {
    if (formRef.value) {
      formRef.value.resetFields()
    }
  }
})
</script>

<style scoped>
.activity-form {
  padding: 20px;
}

.participants-section {
  margin-top: 10px;
}

.participants-list {
  margin-top: 15px;
  flex-wrap: wrap;
  display: flex;
}

.empty-participants {
  margin-top: 15px;
  color: #909399;
  font-size: 14px;
}
</style>
