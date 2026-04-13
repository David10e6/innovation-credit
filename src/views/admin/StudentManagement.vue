<template>
  <div class="student-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学生信息管理</span>
        </div>
      </template>
      
      <!-- 搜索和操作区 -->
      <div class="search-and-actions">
        <div class="search-section">
          <el-select
            v-model="selectedCollege"
            placeholder="选择学院"
            style="width: 200px; margin-right: 15px"
            @change="handleCollegeChange"
          >
            <el-option
              v-for="college in colleges"
              :key="college.id"
              :label="college.name"
              :value="college.id"
            ></el-option>
          </el-select>
          <el-input
            v-model="searchKeyword"
            placeholder="搜索学号或姓名"
            prefix-icon="el-icon-search"
            style="width: 300px; margin-right: 15px"
            @keyup.enter="handleSearch"
          ></el-input>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
        </div>
        <div class="action-buttons">
          <el-button type="primary" @click="showAddDialog = true">添加学生</el-button>
          <el-button type="success" @click="showImportDialog = true">Excel导入</el-button>
        </div>
      </div>
      
      <!-- 学生列表 -->
      <div class="student-list-section">
        <el-table :data="students" style="width: 100%" v-loading="loading">
          <el-table-column prop="studentId" label="学号" width="150"></el-table-column>
          <el-table-column prop="name" label="姓名" width="120"></el-table-column>
          <el-table-column prop="major" label="专业" width="200"></el-table-column>
          <el-table-column prop="className" label="班级" width="150"></el-table-column>
          <el-table-column prop="grade" label="年级" width="100"></el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <span>{{ scope.row.status === '1' ? '正常' : '异常' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="scope">
              <el-button type="primary" size="small" @click="handleEdit(scope.row)">
                编辑
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <div v-if="!loading && students.length === 0" class="empty-state">
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
import { ref, onMounted, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { adminAPI, excelAPI } from '../../api'

// 数据状态
const colleges = ref([])
const students = ref([])
const selectedCollege = ref(null)
const searchKeyword = ref('')
const loading = ref(false)

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
const loadStudents = async (collegeId = null) => {
  loading.value = true
  try {
    let response
    if (collegeId) {
      response = await adminAPI.getStudentsByCollege(collegeId)
    } else {
      response = await adminAPI.getStudentList({})
    }
    students.value = response.data || []
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  } finally {
    loading.value = false
  }
}

// 处理学院选择变化
const handleCollegeChange = (value) => {
  loadStudents(value)
}

// 处理搜索
const handleSearch = async () => {
  if (!searchKeyword.value) {
    loadStudents(selectedCollege.value)
    return
  }
  
  loading.value = true
  try {
    const response = await adminAPI.searchStudents(searchKeyword.value)
    students.value = response.data || []
  } catch (error) {
    console.error('搜索学生失败:', error)
    ElMessage.error('搜索学生失败')
  } finally {
    loading.value = false
  }
}

// 处理添加学生
const handleAdd = () => {
  isEditing.value = false
  // 重置表单
  Object.assign(formData, {
    id: null,
    studentId: '',
    name: '',
    collegeId: null,
    major: '',
    className: '',
    grade: null,
    status: '1'
  })
  showAddDialog.value = true
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
    loadStudents(selectedCollege.value)
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
      loadStudents(selectedCollege.value)
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
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.search-and-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 10px;
}

.search-section {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.student-list-section {
  margin-top: 20px;
}

.empty-state {
  margin-top: 30px;
  text-align: center;
}

.import-section {
  padding: 10px 0;
}

.file-info {
  margin-top: 15px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.import-result {
  margin-top: 20px;
  padding: 15px;
  background-color: #f0f9eb;
  border: 1px solid #e1f3d8;
  border-radius: 4px;
}

.import-result h4 {
  margin-top: 0;
  color: #67c23a;
}

.import-result ul {
  margin: 10px 0 0 0;
  padding-left: 20px;
}

.import-result li {
  color: #f56c6c;
  margin: 5px 0;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .student-management {
    padding: 10px;
  }
  
  .search-and-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-section {
    justify-content: stretch;
  }
  
  .el-select,
  .el-input {
    width: 100% !important;
    margin-right: 0 !important;
  }
  
  .action-buttons {
    justify-content: center;
  }
  
  .el-table {
    font-size: 12px;
  }
  
  .el-table th,
  .el-table td {
    padding: 8px;
  }
  
  .el-button {
    font-size: 12px;
    padding: 4px 8px;
  }
}
</style>