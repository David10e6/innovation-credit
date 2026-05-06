<template>
  <div class="student-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学生信息管理</span>
          <div class="header-buttons">
            <el-button type="success" @click="showImportDialog = true">Excel导入</el-button>
            <el-button type="primary" @click="openAddDialog">添加学生</el-button>
          </div>
        </div>
      </template>
      
      <div class="search-form-wrapper">
        <el-form :model="searchForm" class="search-form">
          <div class="search-row">
            <el-form-item label="搜索">
              <el-input 
                v-model="searchForm.keyword" 
                placeholder="请输入学号/姓名/专业/班级进行搜索" 
                clearable
                class="wide-input"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </el-form-item>
            <el-form-item label="学院">
              <el-select 
                v-model="searchForm.collegeId" 
                placeholder="请选择学院" 
                clearable
                @change="handleSearchCollegeChange"
                class="wide-select"
              >
                <el-option
                  v-for="college in colleges"
                  :key="college.id"
                  :label="college.name"
                  :value="college.id"
                ></el-option>
              </el-select>
            </el-form-item>
          </div>
          <div class="search-row">
            <el-form-item label="专业">
              <el-select 
                v-model="searchForm.major" 
                placeholder="请选择专业" 
                clearable
                :disabled="!searchForm.collegeId"
                class="wide-select"
              >
                <el-option
                  v-for="major in searchMajors"
                  :key="major"
                  :label="major"
                  :value="major"
                ></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="年级">
              <el-select 
                v-model="searchForm.grade" 
                placeholder="请选择年级" 
                clearable
                class="wide-select"
              >
                <el-option
                  v-for="grade in gradeOptions"
                  :key="grade"
                  :label="grade + '级'"
                  :value="grade"
                ></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="班级">
              <el-select 
                v-model="searchForm.className" 
                placeholder="请选择班级" 
                clearable
                class="wide-select"
              >
                <el-option
                  v-for="cls in classOptions"
                  :key="cls"
                  :label="cls"
                  :value="cls"
                ></el-option>
              </el-select>
            </el-form-item>
          </div>
          <div class="search-buttons">
            <el-button type="primary" @click="handleResetSearch">
              <el-icon><RefreshLeft /></el-icon>
              重置
            </el-button>
          </div>
        </el-form>
      </div>
      
      <div class="student-list-section">
        <el-table 
          :data="filteredStudents" 
          style="width: 100%" 
          v-loading="loading"
          :stripe="true"
        >
          <el-table-column type="index" label="#" width="60" align="center"></el-table-column>
          <el-table-column prop="studentId" label="学号" width="160">
            <template #default="scope">
              <span>{{ scope.row.studentId || scope.row.studentNo }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="name" label="姓名" width="120">
            <template #default="scope">
              <span>{{ scope.row.name || scope.row.studentName }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="major" label="专业" min-width="180"></el-table-column>
          <el-table-column prop="className" label="班级" min-width="140">
            <template #default="scope">
              <span>{{ scope.row.className || scope.row.class || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="grade" label="年级" width="100" align="center">
            <template #default="scope">
              <span>{{ scope.row.grade ? scope.row.grade + '级' : '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="totalCredit" label="总学分" width="100" align="center">
            <template #default="scope">
              <span>{{ scope.row.totalCredit || 0 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" align="center" fixed="right">
            <template #default="scope">
              <el-button type="primary" size="small" @click="handleEdit(scope.row)">编辑</el-button>
            </template>
          </el-table-column>
        </el-table>
        <div v-if="!loading && filteredStudents.length === 0" class="empty-state">
          <el-empty description="暂无学生数据"></el-empty>
        </div>
      </div>
    </el-card>
    
    <el-dialog
      v-model="showAddDialog"
      :title="isEditing ? '编辑学生' : '添加学生'"
      width="600px"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="学号" prop="studentId">
          <el-input v-model="formData.studentId" :disabled="isEditing"></el-input>
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name"></el-input>
        </el-form-item>
        <el-form-item label="学院" prop="collegeId">
          <el-select v-model="formData.collegeId" placeholder="请选择学院" @change="handleCollegeChange">
            <el-option
              v-for="college in colleges"
              :key="college.id"
              :label="college.name"
              :value="college.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="专业" prop="major">
          <el-select v-model="formData.major" placeholder="请选择专业" :disabled="!formData.collegeId">
            <el-option
              v-for="major in majors"
              :key="major.id || major.majorCode"
              :label="major.majorName || major.name"
              :value="major.majorName || major.name"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="班级" prop="className">
          <el-input v-model="formData.className"></el-input>
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-input v-model="formData.grade" placeholder="如：2023"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
    
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
        </el-upload>
        <div v-if="selectedFile" class="file-info">已选择文件：{{ selectedFile.name }}</div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showImportDialog = false">取消</el-button>
          <el-button type="primary" @click="handleImport" :loading="importLoading" :disabled="!selectedFile">导入</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, RefreshLeft } from '@element-plus/icons-vue'
import { adminAPI, excelAPI } from '../../api'

const colleges = ref([])
const students = ref([])
const majors = ref([])
const loading = ref(false)
const submitLoading = ref(false)

const searchForm = reactive({
  keyword: '',
  collegeId: null,
  major: '',
  grade: null,
  className: ''
})

// 年级选项（从学生数据中提取）
const gradeOptions = computed(() => {
  if (!students.value || students.value.length === 0) {
    return []
  }
  const uniqueGrades = [...new Set(students.value.map(s => s.grade).filter(g => g))]
  return uniqueGrades.sort((a, b) => Number(b) - Number(a))
})

// 根据选择的学院获取专业选项
const searchMajors = computed(() => {
  if (searchForm.collegeId) {
    // 从majors（从后端获取的专业列表）中提取专业名称
    return majors.value.map(m => m.majorName || m.name).filter(m => m)
  }
  // 如果没有选择学院，从学生数据中提取所有专业
  if (!students.value || students.value.length === 0) {
    return []
  }
  const uniqueMajors = [...new Set(students.value.map(s => s.major).filter(m => m))]
  return uniqueMajors.sort()
})

// 班级选项（从学生数据中提取）
const classOptions = computed(() => {
  if (!students.value || students.value.length === 0) {
    return []
  }
  let filteredStudents = students.value
  
  // 根据筛选条件过滤
  if (searchForm.collegeId) {
    filteredStudents = filteredStudents.filter(s => {
      const studentCollegeId = s.collegeId || s.college_id || ''
      return String(studentCollegeId) === String(searchForm.collegeId)
    })
  }
  
  if (searchForm.major) {
    filteredStudents = filteredStudents.filter(s => s.major === searchForm.major)
  }
  
  if (searchForm.grade) {
    filteredStudents = filteredStudents.filter(s => {
      const gradeStr = s.grade || ''
      const gradeNum = gradeStr.replace('级', '')
      return String(gradeNum) === String(searchForm.grade)
    })
  }
  
  const uniqueClasses = [...new Set(filteredStudents.map(s => s.className || s.class || '').filter(c => c))]
  return uniqueClasses.sort()
})

// 处理搜索表单中的学院选择变化
const handleSearchCollegeChange = async (collegeId) => {
  if (collegeId) {
    // 选择学院时，从后端获取该学院的专业列表
    await loadMajorsByCollege(collegeId)
    searchForm.major = ''
    searchForm.className = ''
    // 清空专业和班级选项
    classOptions.value = []
  } else {
    searchForm.major = ''
    searchForm.className = ''
    majors.value = []
    classOptions.value = []
  }
}

// 监听专业变化，清除班级选择
watch(() => searchForm.major, (newVal) => {
  if (!newVal) {
    searchForm.className = ''
  }
})

// 监听年级变化，清除班级选择
watch(() => searchForm.grade, (newVal) => {
  if (!newVal) {
    searchForm.className = ''
  }
})

const filteredStudents = computed(() => {
  let result = students.value
  
  // 模糊查询：学号/姓名/专业/班级
  if (searchForm.keyword) {
    const keyword = searchForm.keyword.toLowerCase()
    result = result.filter(student => {
      const studentId = student.studentId || student.studentNo || ''
      const studentName = student.name || student.studentName || ''
      const major = student.major || ''
      const className = student.className || student.class || ''
      const grade = student.grade || ''
      
      return studentId.toLowerCase().includes(keyword) || 
             studentName.toLowerCase().includes(keyword) || 
             major.toLowerCase().includes(keyword) || 
             className.toLowerCase().includes(keyword) ||
             grade.toLowerCase().includes(keyword)
    })
  }
  
  // 精确筛选：学院
  if (searchForm.collegeId) {
    result = result.filter(student => {
      const studentCollegeId = student.collegeId || student.college_id || ''
      return String(studentCollegeId) === String(searchForm.collegeId)
    })
  }
  
  // 精确筛选：专业
  if (searchForm.major) {
    result = result.filter(student => student.major === searchForm.major)
  }
  
  // 精确筛选：年级
  if (searchForm.grade) {
    result = result.filter(student => {
      const gradeStr = student.grade || ''
      const gradeNum = gradeStr.replace('级', '')
      return String(gradeNum) === String(searchForm.grade)
    })
  }
  
  // 精确筛选：班级
  if (searchForm.className) {
    result = result.filter(student => {
      const className = student.className || student.class || ''
      return className === searchForm.className
    })
  }
  
  return result
})

const showAddDialog = ref(false)
const showImportDialog = ref(false)
const isEditing = ref(false)

const formData = reactive({
  id: null,
  studentId: '',
  name: '',
  collegeId: null,
  major: '',
  className: '',
  grade: ''
})

const formRules = {
  studentId: [{ required: true, message: '请输入学号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  collegeId: [{ required: true, message: '请选择学院', trigger: 'change' }],
  major: [{ required: true, message: '请选择专业', trigger: 'change' }],
  className: [{ required: true, message: '请输入班级', trigger: 'blur' }],
  grade: [{ required: true, message: '请输入年级', trigger: 'blur' }]
}

const formRef = ref(null)

const selectedFile = ref(null)
const importLoading = ref(false)
const importResult = ref(null)

const loadColleges = async () => {
  try {
    const response = await adminAPI.getCollegeList()
    // API返回的是 {code: 200, data: [...]} 格式
    colleges.value = response.data || response || []
  } catch (error) {
    console.error('加载学院列表失败:', error)
  }
}

const loadMajorsByCollege = async (collegeId) => {
  if (!collegeId) {
    majors.value = []
    return
  }
  try {
    const response = await adminAPI.getMajorsByCollege(collegeId)
    majors.value = response.data || response || []
  } catch (error) {
    console.error('加载专业列表失败:', error)
    majors.value = []
  }
}

const handleCollegeChange = (collegeId) => {
  formData.major = ''
  loadMajorsByCollege(collegeId)
}

const loadStudents = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getStudentList()
    const studentData = response.data || response || []
    
    // 映射API返回的字段到前端期望的字段
    students.value = studentData.map(student => ({
      ...student,
      id: student.id,
      studentId: student.studentNo || student.studentId,
      name: student.studentName || student.name,
      className: student.className || student.class || '',
      grade: (student.grade || '').replace('级', '')
    }))
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  } finally {
    loading.value = false
  }
}

const handleResetSearch = () => {
  searchForm.keyword = ''
  searchForm.collegeId = null
  searchForm.major = ''
  searchForm.grade = null
  searchForm.className = ''
}

const resetForm = () => {
  isEditing.value = false
  majors.value = []
  Object.assign(formData, {
    id: null,
    studentId: '',
    name: '',
    collegeId: null,
    major: '',
    className: '',
    grade: ''
  })
}

const openAddDialog = () => {
  resetForm()
  showAddDialog.value = true
}

const handleEdit = async (row) => {
  isEditing.value = true
  Object.assign(formData, {
    id: row.id,
    studentId: row.studentId || row.studentNo,
    name: row.name || row.studentName,
    collegeId: row.collegeId,
    major: row.major,
    className: row.className || row.class,
    grade: (row.grade || '').replace('级', '')
  })
  if (row.collegeId) {
    await loadMajorsByCollege(row.collegeId)
  }
  showAddDialog.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    if (isEditing.value) {
      await adminAPI.updateStudent(formData)
      ElMessage.success('编辑成功')
    } else {
      await adminAPI.addStudent(formData)
      ElMessage.success('添加成功')
    }
    
    showAddDialog.value = false
    await loadStudents()
  } catch (error) {
    console.error('提交失败:', error)
    if (error !== false) {
      ElMessage.error('提交失败')
    }
  }
}

const handleFileChange = (file) => {
  selectedFile.value = file.raw
}

const handleImport = async () => {
  if (!selectedFile.value) {
    ElMessage.warning('请选择文件')
    return
  }
  
  importLoading.value = true
  try {
    await excelAPI.importExcel(selectedFile.value, 'student')
    ElMessage.success('导入成功')
    showImportDialog.value = false
    await loadStudents()
  } catch (error) {
    console.error('导入失败:', error)
    ElMessage.error('导入失败')
  } finally {
    importLoading.value = false
  }
}

onMounted(async () => {
  await loadColleges()
  await loadStudents()
})
</script>

<style scoped>
.student-management {
  padding: 20px;
  background: #f5f7fa;
  min-height: calc(100vh - 48px);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-buttons {
  display: flex;
  gap: 10px;
}

.search-form-wrapper {
  margin-bottom: 20px;
  padding: 20px;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.search-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.search-row {
  display: flex;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

.search-buttons {
  display: flex;
  justify-content: flex-start;
  margin-top: 8px;
}

.search-form .el-form-item {
  margin-bottom: 0;
}

.wide-input {
  width: 280px;
}

.wide-select {
  width: 200px;
}

/* 覆盖 Element Plus 组件样式 */
.search-form-wrapper :deep(.el-form-item__label) {
  color: #333;
  font-weight: 500;
}

.search-form-wrapper :deep(.el-input__wrapper),
.search-form-wrapper :deep(.el-select__wrapper) {
  background-color: #fff;
  border-radius: 6px;
  box-shadow: 0 0 0 1px #e8e8e8;
  transition: all 0.3s ease;
}

.search-form-wrapper :deep(.el-input__wrapper:hover),
.search-form-wrapper :deep(.el-select__wrapper:hover) {
  box-shadow: 0 0 0 1px #52c41a;
}

.search-form-wrapper :deep(.el-input__wrapper.is-focus),
.search-form-wrapper :deep(.el-select__wrapper.is-focus) {
  box-shadow: 0 0 0 2px rgba(82, 196, 26, 0.2);
}

.search-form-wrapper :deep(.el-select__wrapper.is-disabled) {
  background-color: #f5f7fa;
}

.search-form-wrapper :deep(.el-button--primary) {
  background-color: #52c41a;
  border-color: #52c41a;
  border-radius: 6px;
  font-weight: 500;
  padding: 10px 24px;
  transition: all 0.3s ease;
}

.search-form-wrapper :deep(.el-button--primary:hover) {
  background-color: #389e0d;
  border-color: #389e0d;
}

.student-list-section {
  margin-top: 20px;
}

.empty-state {
  margin-top: 50px;
  text-align: center;
}

.import-section {
  padding: 10px 0;
}

.file-info {
  margin-top: 15px;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
