<template>
  <div class="activity-form">
    <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
      <el-form-item label="活动名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入活动名称" />
      </el-form-item>
      
      <el-form-item label="活动类型" prop="type">
        <el-select v-model="form.type" placeholder="请选择活动类型">
          <el-option label="科技创新" value="科技创新" />
          <el-option label="社会实践" value="社会实践" />
          <el-option label="学术竞赛" value="学术竞赛" />
          <el-option label="文化活动" value="文化活动" />
          <el-option label="其他" value="其他" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="学分" prop="credit">
        <el-input-number v-model="form.credit" :min="0" :step="0.5" placeholder="请输入学分" />
      </el-form-item>
      
      <el-form-item label="主办方" prop="organizer">
        <el-input v-model="form.organizer" placeholder="请输入主办方" />
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
    
    <!-- 参与者管理 -->
    <div class="participants-section">
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

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue', 'open-participant-select', 'import-excel'])

const formRef = ref(null)

const form = reactive({
  id: '',
  name: '',
  type: '',
  credit: 0,
  details: '',
  applicationMethod: '',
  participationRequirements: '',
  applicationDeadline: '',
  startTime: '',
  endTime: '',
  organizer: '',
  participants: []
})

const rules = {
  name: [{ required: true, message: '请输入活动名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择活动类型', trigger: 'change' }],
  credit: [{ required: true, message: '请输入学分', trigger: 'blur' }],
  details: [{ required: true, message: '请输入活动详情', trigger: 'blur' }],
  applicationMethod: [{ required: true, message: '请输入参与方式', trigger: 'blur' }],
  participationRequirements: [{ required: true, message: '请输入参与要求', trigger: 'blur' }],
  applicationDeadline: [{ required: true, message: '请选择报名截止时间', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  organizer: [{ required: true, message: '请输入主办方', trigger: 'blur' }]
}

// 初始化表单数据
const initFormData = () => {
  if (props.modelValue) {
    Object.assign(form, props.modelValue)
  }
}

// 组件挂载时初始化表单数据
onMounted(() => {
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