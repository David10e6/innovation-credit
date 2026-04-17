<template>
  <div class="student-management">
    <el-card class="main-card">
      <template #header>
        <div class="card-header">
          <span class="page-title">学生信息管理</span>
        </div>
      </template>
      
      <!-- 搜索和操作区 -->
      <div class="search-and-actions">
        <div class="search-form-wrapper">
          <el-form :inline="true" :model="searchForm" class="search-form">
            <el-form-item label="学号/姓名">
              <el-input 
                v-model="searchForm.keyword" 
                placeholder="请输入学号或姓名" 
                clearable
                @input="handleSearch"
              ></el-input>
            </el-form-item>
            <el-form-item label="学院">
              <el-select 
                v-model="searchForm.collegeId" 
                placeholder="请选择学院" 
                clearable
                @change="handleSearch"
              >
                <el-option
                  v-for="college in colleges"
                  :key="college.id"
                  :label="college.name"
                  :value="college.id"
                ></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="年级">
              <el-select 
                v-model="searchForm.grade" 
                placeholder="请选择年级" 
                clearable
                @change="handleSearch"
              >
                <el-option 
                  v-for="grade in gradeOptions" 
                  :key="grade" 
                  :label="grade + '级'" 
                  :value="grade"
                ></el-option>
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleResetSearch">重置</el-button>
            </el-form-item>
          </el-form>
        </div>
        <div class="action-buttons">
          <el-button type="primary" @click="showAddDialog = true">
            <template #icon>
              <Plus />
            </template>
            添加学生
          </el-button>
          <el-button type="success" @click="showImportDialog = true">
            <template #icon>
              <Upload />
            </template>
            Excel导入
          </el-button>
        </div>
      </div>
      
      <!-- 学生列表 -->
      <div class="student-list-section">
        <el-table 
          :data="filteredStudents" 
          style="width: 100%" 
          v-loading="loading"
          :stripe="true"
        >
          <el-table-column prop="studentId" label="学号" min-width="140"></el-table-column>
          <el-table-column prop="name" label="姓名" min-width="100">
            <template #default="scope">
              <span class="student-name">{{ scope.row.name }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="major" label="专业" min-width="180"></el-table-column>
          <el-table-column prop="className" label="班级" min-width="140"></el-table-column>
          <el-table-column prop="grade" label="年级" width="100" align="center">
            <template #default="scope">
              <el-tag size="small" type="info">{{ scope.row.grade }}级</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100" align="center">
            <template #default="scope">
              <el-tag 
                :type="scope.row.status === '1' ? 'success' : 'danger'" 
                size="small"
              >
                {{ scope.row.status === '1' ? '正常' : '异常' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" fixed="right" align="center">
            <template #default="scope">
              <el-button type="primary" size="small" @click="handleEdit(scope.row)">
                <template #icon>
                  <Edit />
                </template>
                编辑
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <div v-if="!loading && filteredStudents.length === 0" class="empty-state">
          <el-empty description="暂无学生数据"></el-empty>
        </div>
      </div>
    </el-card>
    
    <!-- 添加/编辑学生弹窗 -->
    <el-dialog
      v-model="showAddDialog"
      :title="isEditing ? '编辑学生' : '添加学生'"
      width="500px"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="学号" prop="studentId">
          <el-input v-model="formData.studentId" placeholder="请输入学号"></el-input>
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入姓名"></el-input>
        </el-form-item>
        <el-form-item label="学院" prop="collegeId">
          <el-select v-model="formData.collegeId" placeholder="请选择学院">
            <el-option
              v-for="college in colleges"
              :key="college.id"
              :label="college.name"
              :value="college.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="专业" prop="major">
          <el-input v-model="formData.major" placeholder="请输入专业"></el-input>
        </el-form-item>
        <el-form-item label="班级" prop="className">
          <el-input v-model="formData.className" placeholder="请输入班级"></el-input>
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-input v-model="formData.grade" type="number" placeholder="请输入年级"></el-input>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择状态">
            <el-option label="正常" value="1"></el-option>
            <el-option label="异常" value="0"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- Excel导入弹窗 -->
    <el-dialog
      v-model="showImportDialog"
      title="Excel导入"
      width="500px"
    >
      <div class="import-section">
        <el-upload
          class="upload-demo"
          action="#"
          :auto-upload="false"
          :on-change="handleFileChange"
          :show-file-list="false"
          accept=".xlsx"
        >
          <el-button type="primary">选择Excel文件</el-button>
          <template #tip>
            <div class="el-upload__tip">
              请选择.xlsx格式的Excel文件
            </div>
          </template>
        </el-upload>
        <div v-if="selectedFile" class="file-info">
          已选择文件: {{ selectedFile.name }}
        </div>
        <div v-if="importResult" class="import-result">
          <h4>导入结果</h4>
          <p>成功: {{ importResult.successCount }} 条</p>
          <p>失败: {{ importResult.failCount }} 条</p>
          <div v-if="importResult.errorMessages && importResult.errorMessages.length > 0">
            <h5>错误信息:</h5>
            <ul>
              <li v-for="(error, index) in importResult.errorMessages" :key="index">
                {{ error }}
              </li>
            </ul>
          </div>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showImportDialog = false">取消</el-button>
          <el-button type="primary" @click="handleImport" :loading="importLoading" :disabled="!selectedFile">
            导入
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Upload, Edit } from '@element-plus/icons-vue'
import { adminAPI, excelAPI } from '../../api'

// 数据状态
const colleges = ref([])
const students = ref([])
const loading = ref(false)

// 从学生数据中提取年级选项
const gradeOptions = computed(() => {
  if (!students.value || students.value.length === 0) {
    return []
  }
  // 提取所有唯一的年级值并排序
  const uniqueGrades = [...new Set(students.value.map(s => s.grade).filter(g => g))]
  return uniqueGrades.sort((a, b) => Number(b) - Number(a))
})

// 搜索表单
const searchForm = reactive({
  keyword: '',
  collegeId: null,
  grade: null
})

// 过滤后的学生列表
const filteredStudents = computed(() => {
  let result = students.value
  
  if (searchForm.keyword) {
    const keyword = searchForm.keyword.toLowerCase()
    result = result.filter(student => 
      (student.studentId && student.studentId.toLowerCase().includes(keyword)) ||
      (student.name && student.name.toLowerCase().includes(keyword))
    )
  }
  
  if (searchForm.collegeId) {
    result = result.filter(student => 
      String(student.collegeId) === String(searchForm.collegeId)
    )
  }
  
  if (searchForm.grade) {
    result = result.filter(student => 
      String(student.grade) === String(searchForm.grade)
    )
  }
  
  return result
})

// 弹窗状态
const showAddDialog = ref(false)
const showImportDialog = ref(false)
const isEditing = ref(false)

// 表单数据
const formData = reactive({
  id: null,
  studentId: '',
  name: '',
  collegeId: null,
  major: '',
  className: '',
  grade: null,
  status: '1'
})

// 表单验证规则
const formRules = {
  studentId: [{ required: true, message: '请输入学号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  collegeId: [{ required: true, message: '请选择学院', trigger: 'blur' }],
  major: [{ required: true, message: '请输入专业', trigger: 'blur' }],
  className: [{ required: true, message: '请输入班级', trigger: 'blur' }],
  grade: [{ required: true, message: '请输入年级', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'blur' }]
}

// 表单引用
const formRef = ref(null)

// Excel导入相关
const selectedFile = ref(null)
const importLoading = ref(false)
const importResult = ref(null)

// 加载学院列表
const loadColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    colleges.value = response.data || []
  } catch (error) {
    console.error('加载学院列表失败:', error)
    ElMessage.error('加载学院列表失败')
  }
}

// 加载学生列表
const loadStudents = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getStudentList({})
    students.value = response.data || []
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  } finally {
    loading.value = false
  }
}

// 处理搜索
const handleSearch = () => {
  // 计算属性会自动处理
}

// 重置搜索
const handleResetSearch = () => {
  searchForm.keyword = ''
  searchForm.collegeId = null
  searchForm.grade = null
}

// 处理编辑学生
const handleEdit = (row) => {
  isEditing.value = true
  // 填充表单数据，排除totalCredit字段
  const { totalCredit, ...rest } = row
  Object.assign(formData, rest)
  showAddDialog.value = true
}

// 处理表单提交
const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    if (isEditing.value) {
      // 编辑学生
      await adminAPI.updateStudent(formData)
      ElMessage.success('编辑成功')
    } else {
      // 添加学生
      await adminAPI.addStudent(formData)
      ElMessage.success('添加成功')
    }
    
    showAddDialog.value = false
    // 重新加载学生列表
    loadStudents()
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('提交失败')
  }
}

// 处理文件选择
const handleFileChange = (file) => {
  selectedFile.value = file.raw
  importResult.value = null
}

// 处理Excel导入
const handleImport = async () => {
  if (!selectedFile.value) {
    ElMessage.warning('请选择文件')
    return
  }
  
  importLoading.value = true
  try {
    // 验证文件
    await excelAPI.validateExcel(selectedFile.value)
    
    // 导入文件
    const response = await excelAPI.importExcel(selectedFile.value, 'student')
    importResult.value = response.data
    
    if (importResult.value.successCount > 0) {
      ElMessage.success('导入成功')
      // 重新加载学生列表
      loadStudents()
    }
  } catch (error) {
    console.error('导入失败:', error)
    ElMessage.error('导入失败')
  } finally {
    importLoading.value = false
  }
}

// 页面加载时初始化
onMounted(() => {
  loadColleges()
  loadStudents()
})
</script>

<style scoped>
.student-management {
  padding: 24px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 48px);
}

.main-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  padding-left: 12px;
  border-left: 4px solid #409eff;
}

.search-and-actions {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  padding: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #eef2f7 100%);
  border-radius: 12px;
  border: 1px solid #e4e7ed;
  flex-wrap: wrap;
  gap: 16px;
}

.search-form-wrapper {
  flex: 1;
  min-width: 0;
}

.search-form {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.search-form .el-form-item {
  margin-bottom: 0;
}

.search-form .el-input__wrapper,
.search-form .el-select__wrapper {
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
}

.search-form .el-input__wrapper:hover,
.search-form .el-select__wrapper:hover {
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.15);
}

.search-form .el-input__wrapper.is-focus,
.search-form .el-select__wrapper.is-focus {
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.search-form .el-select {
  min-width: 180px;
}

.search-form .el-select__wrapper {
  min-width: 180px;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.action-buttons .el-button {
  border-radius: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
}

.action-buttons .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.student-list-section {
  margin-top: 20px;
}

.student-list-section .el-table {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.student-name {
  font-weight: 500;
  color: #303133;
}

.empty-state {
  margin-top: 40px;
  padding: 40px 0;
}

.import-section {
  padding: 10px 0;
}

.file-info {
  margin-top: 15px;
  padding: 12px 16px;
  background: linear-gradient(135deg, #f5f7fa 0%, #eef2f7 100%);
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  font-weight: 500;
  color: #606266;
}

.import-result {
  margin-top: 20px;
  padding: 20px;
  background: linear-gradient(135deg, #f0f9eb 0%, #e6f7e6 100%);
  border: 1px solid #c2e7b0;
  border-radius: 8px;
}

.import-result h4 {
  margin-top: 0;
  margin-bottom: 12px;
  color: #67c23a;
  font-size: 16px;
  font-weight: 600;
}

.import-result p {
  margin: 8px 0;
  font-size: 14px;
  color: #606266;
}

.import-result h5 {
  margin: 16px 0 8px 0;
  color: #f56c6c;
  font-size: 14px;
  font-weight: 600;
}

.import-result ul {
  margin: 0;
  padding-left: 20px;
}

.import-result li {
  color: #f56c6c;
  margin: 4px 0;
  font-size: 13px;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .student-management {
    padding: 12px;
  }
  
  .search-and-actions {
    flex-direction: column;
    align-items: stretch;
    padding: 16px;
  }
  
  .search-form {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-form .el-form-item {
    width: 100%;
  }
  
  .search-form .el-input,
  .search-form .el-select {
    width: 100% !important;
  }
  
  .action-buttons {
    width: 100%;
    justify-content: center;
  }
  
  .action-buttons .el-button {
    flex: 1;
  }
  
  .student-list-section .el-table {
    font-size: 12px;
  }
  
  .student-list-section .el-table th,
  .student-list-section .el-table td {
    padding: 10px 8px;
  }
}
</style>