<template>
  <div class="student-statistics">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>本院统计</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      
      <!-- 筛选区域 -->
      <div class="filter-section">
        <el-select v-model="selectedGrade" placeholder="请选择年级" @change="onGradeChange" style="margin-right: 15px;">
          <el-option v-for="grade in grades" :key="grade" :label="grade + '级'" :value="grade"></el-option>
        </el-select>
        <el-select v-model="selectedClass" placeholder="请选择班级" :disabled="!selectedGrade" @change="onClassChange">
          <el-option v-for="cls in classes" :key="cls" :label="cls" :value="cls"></el-option>
        </el-select>
        <el-button type="primary" @click="resetFilter" style="margin-left: 15px;">重置</el-button>
      </div>
      
      <!-- 饼状图区域 -->
      <div class="chart-section">
        <div ref="pieChartRef" class="pie-chart"></div>
      </div>
      
      <!-- 学生列表 -->
      <div class="table-section" style="margin-top: 30px;">
        <el-loading v-loading="loading" element-loading-text="加载中...">
          <div v-if="students && students.length > 0">
            <el-table :data="students" style="width: 100%">
              <el-table-column prop="studentId" label="学号" width="150"></el-table-column>
              <el-table-column prop="name" label="姓名" width="120"></el-table-column>
              <el-table-column prop="className" label="班级" width="120"></el-table-column>
              <el-table-column prop="major" label="专业"></el-table-column>
              <el-table-column prop="totalCredit" label="总学分" width="100"></el-table-column>
              <el-table-column label="学分完成情况" width="150">
                <template #default="scope">
                  <el-tag :type="getCreditStatus(scope.row) === '完成' ? 'success' : 'warning'">
                    {{ getCreditStatus(scope.row) }}
                  </el-tag>
                </template>
              </el-table-column>
            </el-table>
          </div>
          <div v-else-if="selectedGrade && selectedClass" class="empty-state">
            <el-empty description="暂无学生记录"></el-empty>
          </div>
          <div v-else class="empty-state">
            <el-empty description="请先选择年级和班级"></el-empty>
          </div>
        </el-loading>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { counselorAPI } from '../../api'
import useUserStore from '../../store/user'
import * as echarts from 'echarts'

const router = useRouter()
const loading = ref(false)
const grades = ref([])
const classes = ref([])
const selectedGrade = ref(null)
const selectedClass = ref(null)
const students = ref([])
const pieChartRef = ref(null)
let pieChart = ref(null)

const userStore = useUserStore()

const getCollegeId = () => {
  const userInfoStr = localStorage.getItem('userInfo');
  const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
  return userInfo?.collegeId || userInfo?.college || '';
}

// 存储全院学生数据，用于本地过滤
const allCollegeStudents = ref([])

// 获取全院学生数据
const getAllStudents = async () => {
  loading.value = true
  try {
    const collegeId = getCollegeId()
    if (!collegeId) {
      ElMessage.error('无法获取学院信息');
      return;
    }
    
    const response = await counselorAPI.getStudentList(collegeId)
    allCollegeStudents.value = response.data || []
    updateStudentsByFilter()
  } catch (error) {
    console.error('获取全院学生失败:', error)
    ElMessage.error('获取全院学生失败')
    allCollegeStudents.value = []
    students.value = []
  } finally {
    loading.value = false
  }
}

// 根据筛选条件更新学生列表
const updateStudentsByFilter = () => {
  if (!selectedGrade.value && !selectedClass.value) {
    // 没有筛选条件，显示全院学生
    students.value = allCollegeStudents.value
  } else if (selectedGrade.value && !selectedClass.value) {
    // 只选择了年级
    students.value = allCollegeStudents.value.filter(s => s.grade === selectedGrade.value)
  } else if (selectedGrade.value && selectedClass.value) {
    // 选择了年级和班级
    students.value = allCollegeStudents.value.filter(s => 
      s.grade === selectedGrade.value && s.className === selectedClass.value
    )
  }
  updatePieChart()
}

const loadGrades = async () => {
  try {
    const collegeId = getCollegeId()
    if (!collegeId) {
      ElMessage.error('无法获取学院信息');
      grades.value = []
      return;
    }
    
    const response = await counselorAPI.getGrades(collegeId)
    grades.value = response.data || []
  } catch (error) {
    console.error('Get grades error:', error)
    ElMessage.error('获取年级列表失败')
    grades.value = []
  }
}

const onGradeChange = async () => {
  selectedClass.value = null
  
  if (selectedGrade.value) {
    loading.value = true
    try {
      // 获取班级列表
      const collegeId = getCollegeId()
      const response = await counselorAPI.getClassesByGrade(collegeId, selectedGrade.value)
      classes.value = response.data || []
      
      // 根据筛选条件更新学生列表
      updateStudentsByFilter()
    } catch (error) {
      console.error('Get classes error:', error)
      ElMessage.error('获取班级列表失败')
      classes.value = []
    } finally {
      loading.value = false
    }
  } else {
    classes.value = []
    // 重置为全院学生
    updateStudentsByFilter()
  }
}

const onClassChange = async () => {
  // 根据筛选条件更新学生列表
  updateStudentsByFilter()
}

const resetFilter = async () => {
  selectedGrade.value = null
  selectedClass.value = null
  classes.value = []
  // 重置为全院学生
  updateStudentsByFilter()
}

const getCreditStatus = (student) => {
  if (student.creditStatus) {
    return student.creditStatus
  }
  
  const totalCredit = student.totalCredit || 0
  if (totalCredit >= 4) {
    return '完成'
  } else {
    return '未完成'
  }
}

const initPieChart = () => {
  if (!pieChartRef.value) return
  
  pieChart.value = echarts.init(pieChartRef.value)
  
  updatePieChart()
  
  window.addEventListener('resize', handleResize)
}

const updatePieChart = () => {
  if (!pieChart.value) return
  
  let completedCount = 0
  let uncompletedCount = 0
  
  if (students.value && students.value.length > 0) {
    students.value.forEach(student => {
      const status = getCreditStatus(student)
      if (status === '完成') {
        completedCount++
      } else {
        uncompletedCount++
      }
    })
  }
  
  const option = {
    title: {
      text: '学分完成情况统计',
      left: 'center'
    },
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '学分完成情况',
        type: 'pie',
        radius: '50%',
        data: [
          { value: completedCount, name: '完成', itemStyle: { color: '#67C23A' } },
          { value: uncompletedCount, name: '未完成', itemStyle: { color: '#E6A23C' } }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
  
  pieChart.value.setOption(option)
}

const handleResize = () => {
  if (pieChart.value) {
    pieChart.value.resize()
  }
}

const goBack = () => {
  router.push('/counselor')
}

onMounted(async () => {
  await loadGrades()
  await getAllStudents()
  initPieChart()
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  if (pieChart.value) {
    pieChart.value.dispose()
  }
})

watch([selectedGrade, selectedClass], () => {
  updatePieChart()
})
</script>

<style scoped>
.student-statistics {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-section {
  margin-bottom: 20px;
}

.chart-section {
  margin-bottom: 20px;
}

.pie-chart {
  width: 100%;
  height: 400px;
}

.table-section {
  margin-top: 20px;
}

.empty-state {
  margin-top: 50px;
  text-align: center;
}
</style>
