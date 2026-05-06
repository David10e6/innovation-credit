<template>
  <el-dialog
    v-model="dialogVisible"
    title="选择参与者"
    width="800px"
  >
    <!-- 搜索框 -->
    <div class="search-section">
      <el-input
        v-model="searchKeyword"
        placeholder="请输入学号、姓名、学院或专业进行搜索"
        clearable
        @input="handleSearch"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
    </div>
    
    <!-- 学生列表 -->
    <div class="student-list">
      <el-table
        v-loading="loading"
        :data="filteredStudents"
        style="width: 100%"
        border
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="studentId" label="学号" width="120" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="college" label="学院" />
        <el-table-column prop="major" label="专业" />
      </el-table>
      
      <!-- 空状态 -->
      <div v-if="!loading && filteredStudents.length === 0" class="empty-state">
        <el-empty description="暂无学生数据" />
      </div>
      
      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </div>
    
    <!-- 已选学生 -->
    <div v-if="selectedStudents.length > 0" class="selected-section">
      <h4>已选学生 ({{ selectedStudents.length }})</h4>
      <div class="selected-list">
        <el-tag
          v-for="(student, index) in selectedStudents"
          :key="student.studentId || index"
          closable
          @close="removeSelectedStudent(index)"
          style="margin: 5px"
        >
          {{ student.name }} ({{ student.studentId }})
        </el-tag>
      </div>
    </div>
    
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmSelection">确认添加</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { activityAPI } from '../api'
import { ElMessage } from 'element-plus'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  existingParticipants: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:visible', 'confirm'])

const dialogVisible = computed({
  get: () => props.visible,
  set: (value) => emit('update:visible', value)
})

const searchKeyword = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedStudents = ref([...props.existingParticipants])
const students = ref([])
const loading = ref(false)

// 过滤学生列表
const filteredStudents = computed(() => {
  return students.value
})

// 监听已有参与者变化
watch(() => props.existingParticipants, (newValue) => {
  selectedStudents.value = [...newValue]
}, { deep: true })

// 搜索防抖
let searchTimer = null
const handleSearch = () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    searchStudents()
    currentPage.value = 1
  }, 500)
}

// 搜索学生
const searchStudents = async () => {
  loading.value = true
  try {
    const response = await activityAPI.searchStudents(searchKeyword.value)
    students.value = Array.isArray(response.data) ? response.data : []
    total.value = students.value.length
  } catch (error) {
    console.error('搜索学生失败:', error)
    ElMessage.error('搜索学生失败')
    students.value = []
  } finally {
    loading.value = false
  }
}

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size
}

const handleCurrentChange = (current) => {
  currentPage.value = current
}

// 移除已选学生
const removeSelectedStudent = (index) => {
  selectedStudents.value.splice(index, 1)
}

// 确认选择
const confirmSelection = () => {
  emit('confirm', selectedStudents.value)
  dialogVisible.value = false
}
</script>

<style scoped>
.search-section {
  margin-bottom: 20px;
}

.student-list {
  margin-bottom: 20px;
}

.empty-state {
  margin: 40px 0;
  text-align: center;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}

.selected-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e4e7ed;
}

.selected-section h4 {
  margin-bottom: 10px;
  font-size: 14px;
  font-weight: bold;
  color: #303133;
}

.selected-list {
  flex-wrap: wrap;
  display: flex;
}
</style>