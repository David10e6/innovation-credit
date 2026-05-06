<template>
  <el-dialog
    v-model="dialogVisible"
    title="导入学生数据预览"
    width="90%"
    :close-on-click-modal="false"
  >
    <div class="preview-container">
      <!-- 文件信息 -->
      <div v-if="selectedFile" class="file-info">
        <el-icon><Document /></el-icon>
        <span>已选择文件: {{ selectedFile.name }}</span>
      </div>
      
      <!-- 学生数据表格 -->
      <div class="student-table">
        <el-table
          v-loading="loading"
          :data="studentData"
          style="width: 100%"
          border
          @selection-change="handleSelectionChange"
          ref="studentTableRef"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column label="学号" width="150">
            <template #default="{ row }">
              {{ row.studentId || row['学号'] || row.id || '' }}
            </template>
          </el-table-column>
          <el-table-column label="姓名" width="120">
            <template #default="{ row }">
              {{ row.studentName || row.name || row['姓名'] || '' }}
            </template>
          </el-table-column>
          <el-table-column label="学院">
            <template #default="{ row }">
              {{ row.college || row['学院'] || '' }}
            </template>
          </el-table-column>
          <el-table-column label="专业">
            <template #default="{ row }">
              {{ row.major || row['专业'] || '' }}
            </template>
          </el-table-column>
          <el-table-column label="班级" width="180">
            <template #default="{ row }">
              {{ row.className || row['班级'] || row.class || '' }}
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 空状态 -->
        <div v-if="!loading && studentData.length === 0" class="empty-state">
          <el-empty description="暂无学生数据" />
        </div>
      </div>
      
      <!-- 已选学生 -->
      <div v-if="selectedStudents.length > 0" class="selected-section">
        <div class="selected-header">
          <span>已选择 <strong>{{ selectedStudents.length }}</strong> 名学生</span>
          <el-button type="text" size="small" @click="clearSelection">清空选择</el-button>
        </div>
        <div class="selected-list">
          <el-tag
            v-for="(student, index) in selectedStudents"
            :key="student.studentId || student['学号'] || student.id || index"
            closable
            @close="removeSelectedStudent(index)"
            style="margin: 5px"
          >
            {{ student.studentName || student.name || student['姓名'] }} ({{ student.studentId || student['学号'] || student.id }})
          </el-tag>
        </div>
      </div>
    </div>
    
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button 
          type="primary" 
          @click="handleConfirm" 
          :disabled="selectedStudents.length === 0"
        >
          确认导入 ({{ selectedStudents.length }})
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Document } from '@element-plus/icons-vue'
import { excelAPI } from '../api'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  file: {
    type: File,
    default: null
  }
})

const emit = defineEmits(['update:visible', 'confirm'])

const dialogVisible = computed({
  get: () => props.visible,
  set: (value) => emit('update:visible', value)
})

const selectedFile = ref(null)
const studentData = ref([])
const selectedStudents = ref([])
const loading = ref(false)
const studentTableRef = ref(null)

// 监听文件变化
watch(() => props.file, (newFile) => {
  if (newFile) {
    selectedFile.value = newFile
    fetchExcelPreview(newFile)
  }
}, { immediate: true })

// 调用后端接口获取预览数据
const fetchExcelPreview = async (file) => {
  loading.value = true
  try {
    const response = await excelAPI.parseExcelPreview(file)
    
    console.log('Excel预览接口返回完整数据:', response)
    console.log('Excel预览接口返回的data:', response.data)
    
    if (response.code === 200) {
      studentData.value = response.data || []
      
      console.log('解析后的studentData:', studentData.value)
      if (studentData.value.length > 0) {
        console.log('第一个学生对象:', studentData.value[0])
        console.log('第一个学生对象的所有属性:', Object.keys(studentData.value[0]))
      }
      
      // 默认全选
      setTimeout(() => {
        if (studentTableRef.value && studentData.value.length > 0) {
          studentData.value.forEach(row => {
            studentTableRef.value.toggleRowSelection(row, true)
          })
        }
      }, 100)
    } else {
      ElMessage.error(response.msg || '获取预览数据失败')
      studentData.value = []
    }
  } catch (error) {
    console.error('获取Excel预览数据失败:', error)
    ElMessage.error('获取预览数据失败，请检查文件格式或网络连接')
    studentData.value = []
  } finally {
    loading.value = false
  }
}

// 处理选择变化
const handleSelectionChange = (selection) => {
  selectedStudents.value = selection
}

// 移除已选学生
const removeSelectedStudent = (index) => {
  const student = selectedStudents.value[index]
  selectedStudents.value.splice(index, 1)
  
  // 同步取消表格中的选择
  if (studentTableRef.value) {
    studentTableRef.value.toggleRowSelection(student, false)
  }
}

// 清空选择
const clearSelection = () => {
  selectedStudents.value = []
  if (studentTableRef.value) {
    studentTableRef.value.clearSelection()
  }
}

// 确认导入
const handleConfirm = () => {
  if (selectedStudents.value.length === 0) {
    ElMessage.warning('请至少选择一名学生')
    return
  }
  
  emit('confirm', selectedStudents.value)
  dialogVisible.value = false
}

// 监听弹窗关闭，重置数据
watch(dialogVisible, (newVal) => {
  if (!newVal) {
    selectedFile.value = null
    studentData.value = []
    selectedStudents.value = []
  }
})
</script>

<style scoped>
.preview-container {
  max-height: 60vh;
  overflow-y: auto;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  margin-bottom: 16px;
  background-color: #f0f9ff;
  border: 1px solid #b3d8ff;
  border-radius: 4px;
  color: #409eff;
}

.student-table {
  margin-bottom: 16px;
}

.empty-state {
  margin: 40px 0;
  text-align: center;
}

.selected-section {
  padding: 16px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.selected-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.selected-list {
  flex-wrap: wrap;
  display: flex;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
