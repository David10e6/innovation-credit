<template>
  <div class="counselor-dashboard">
    <!-- 指标卡片 -->
    <div class="overview-row">
      <div class="stat-card">
        <div class="card-icon icon-blue">
          <i class="el-icon-user"></i>
        </div>
        <div class="card-content">
          <div class="card-value">{{ overviewData.totalStudents || 0 }}</div>
          <div class="card-label">本院学生数</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="card-icon icon-purple">
          <i class="el-icon-s-check"></i>
        </div>
        <div class="card-content">
          <div class="card-value">{{ (overviewData.passRate || 0).toFixed(2) }}%</div>
          <div class="card-label">本院达标率</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="card-icon icon-red">
          <i class="el-icon-warning"></i>
        </div>
        <div class="card-content">
          <div class="card-value">{{ overviewData.pendingAudits || 0 }}</div>
          <div class="card-label">待初审申请数</div>
        </div>
      </div>
    </div>

    <!-- 年级选择 -->
    <div class="content-row">
      <div class="panel panel-xl">
        <div class="panel-header">
          <h3>年级选择</h3>
          <div class="panel-tabs">
            <span 
              v-for="grade in gradeList" 
              :key="grade" 
              :class="{ active: selectedGrade === grade }" 
              @click="selectGrade(grade)"
            >
              {{ grade }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- 数据分析区域 -->
    <div v-if="selectedGrade && selectedGrade !== '全部'" class="analysis-section">
      <!-- 专业选择 -->
      <div class="content-row">
        <div class="panel panel-xl">
          <div class="panel-header">
            <h3>选择专业</h3>
            <el-select
              v-model="selectedMajor"
              placeholder="请选择专业"
              style="width: 300px"
              @change="onMajorChange"
              clearable
            >
              <el-option
                v-for="major in majorList"
                :key="major"
                :label="major"
                :value="major"
              ></el-option>
            </el-select>
          </div>
        </div>
      </div>
      
      <!-- 没有找到专业时的提示 -->
      <div v-if="selectedGrade && selectedGrade !== '全部' && majorList.length === 0" class="content-row">
        <div class="panel panel-xl" style="padding: 30px; text-align: center;">
          <el-empty description="该年级暂无数据，检查学生数据是否正确"></el-empty>
        </div>
      </div>

      <!-- 图表区域 - 左右布局 -->
      <div v-if="selectedMajor" class="content-row">
        <div class="panel panel-lg">
          <div class="panel-header">
            <h3>{{ selectedMajor }} 达标率</h3>
          </div>
          <div ref="majorPieChart" class="chart-container"></div>
        </div>
        <div class="panel panel-lg">
          <div class="panel-header">
            <h3>{{ selectedMajor }} 各班级达标率</h3>
          </div>
          <div ref="classBarChart" class="chart-container"></div>
        </div>
      </div>

      <!-- 学生学分信息表格 -->
      <div v-if="selectedMajor" class="content-row">
        <div class="panel panel-xl">
          <div class="panel-header">
            <h3>{{ selectedMajor }} 学生学分信息</h3>
          </div>
          <div class="table-container">
            <el-table :data="studentCreditData" style="width: 100%" stripe>
              <el-table-column prop="rank" label="排名" width="70" align="center">
                <template #default="{ row }">
                  <span v-if="row.rank <= 3" style="color: #f5222d; font-weight: bold;">{{ row.rank }}</span>
                  <span v-else>{{ row.rank }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="name" label="姓名" width="120"></el-table-column>
              <el-table-column prop="studentNo" label="学号" width="160"></el-table-column>
              <el-table-column prop="className" label="班级" width="150"></el-table-column>
              <el-table-column prop="totalCredit" label="总学分" width="100" align="center"></el-table-column>
              <el-table-column prop="status" label="达标状态" width="100" align="center">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'passed' ? 'success' : 'danger'">
                    {{ row.status === 'passed' ? '已达标' : '未达标' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="progress" label="进度" width="120" align="center">
                <template #default="{ row }">
                  <el-progress :percentage="row.progress" :color="row.status === 'passed' ? '#67C23A' : '#E6A23C'" />
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </div>
    </div>

    <!-- 未选择年级时的提示 -->
    <div v-else class="empty-tip">
      <el-empty description="请先选择年级查看数据分析" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import * as echarts from 'echarts'
import { counselorAPI } from '../../api'
import useUserStore from '../../store/user'

const userStore = useUserStore()

// 响应式数据
const overviewData = ref({})
const gradeList = ref([])
const selectedGrade = ref('')
const majorList = ref([])
const selectedMajor = ref('')
const classList = ref([])
const allStudents = ref([])

// 图表引用
const majorPieChart = ref(null)
const classBarChart = ref(null)

// 图表实例
let majorPieChartInstance = null
let classBarChartInstance = null

// 获取学院ID
const getCollegeId = () => {
  const userInfo = userStore.getUserInfo
  return userInfo?.collegeId || userInfo?.id || userInfo?.college_id
}

// 计算当前专业学生数据
const studentCreditData = computed(() => {
  if (!selectedMajor.value || !selectedGrade.value) return []
  
  const grade = String(selectedGrade.value).replace('级', '')
  let filtered = allStudents.value.filter(s => {
    const studentGradeStr = String(s.grade)
    const studentNoStr = String(s.studentNo || s.studentId || '')
    const matchGrade = (studentGradeStr === grade) || (studentGradeStr === grade + '级') || studentNoStr.startsWith(grade)
    
    // 使用后端返回的专业字段
    const studentMajor = s.major || s.specialty || s.dept || s.department || s.collegeName || s.college
    const matchMajor = studentMajor === selectedMajor.value
    return matchMajor && matchGrade
  })
  
  return filtered
    .sort((a, b) => (b.totalCredit || 0) - (a.totalCredit || 0))
    .map((item, index) => ({
      rank: index + 1,
      name: item.studentName || item.name,
      studentNo: item.studentNo || item.studentId,
      className: item.className || item.class,
      totalCredit: item.totalCredit || 0,
      status: (item.passRate || 0) >= 70 ? 'passed' : 'unpassed',
      progress: Math.min(item.passRate || 0, 100)
    }))
})

// 计算当前专业达标数据
const majorPassData = computed(() => {
  const data = studentCreditData.value
  const total = data.length
  const passed = data.filter(s => s.status === 'passed').length
  const passRate = total > 0 ? Math.round((passed / total) * 100) : 0
  
  return {
    total,
    passed,
    unpassed: total - passed,
    passRate
  }
})

// 计算当前专业各班级达标数据
const classPassData = computed(() => {
  const data = studentCreditData.value
  const classMap = new Map()
  
  data.forEach(student => {
    const className = student.className || '未分配'
    if (!classMap.has(className)) {
      classMap.set(className, { total: 0, passed: 0 })
    }
    const classData = classMap.get(className)
    classData.total++
    if (student.status === 'passed') {
      classData.passed++
    }
  })
  
  return Array.from(classMap.entries()).map(([className, stats]) => ({
    className,
    total: stats.total,
    passed: stats.passed,
    passRate: stats.total > 0 ? Math.round((stats.passed / stats.total) * 100) : 0
  }))
})

// 加载数据
const loadData = async () => {
  try {
    const collegeId = getCollegeId()
    
    // 从API获取数据
    const overviewRes = await counselorAPI.getCounselorStatsOverview(collegeId)
    const studentRes = await counselorAPI.getStudentsWithFilter(collegeId, {})
    
    // 更新概览数据
    overviewData.value = {
      totalStudents: overviewRes.data?.totalStudents || 0,
      passRate: overviewRes.data?.passRate || 0,
      pendingAudits: overviewRes.data?.pendingAudits || 0
    }
    
    // 获取年级列表
    let gradesFromServer = []
    try {
      const gradeRes = await counselorAPI.getGrades(collegeId)
      gradesFromServer = Array.isArray(gradeRes) ? gradeRes : (gradeRes.data || [])
    } catch (e) {
      console.log('获取年级列表失败')
    }
    
    gradeList.value = gradesFromServer.length > 0 ? ['全部', ...gradesFromServer] : ['全部', '2021级', '2022级', '2023级', '2024级']
    
    // 保存学生数据
    const students = Array.isArray(studentRes) ? studentRes : (studentRes.data || studentRes.rows || [])
    allStudents.value = students
    
    console.log('加载完成 - 年级列表:', gradeList.value, '学生数:', students.length)
    
  } catch (error) {
    console.error('加载数据失败:', error)
  }
}

// 选择年级
const selectGrade = async (grade) => {
  selectedGrade.value = grade
  selectedMajor.value = ''
  majorList.value = []
  classList.value = []
  
  if (String(grade) === '全部') return
  
  // 从学生数据中提取该年级的专业列表
  const gradeYear = String(grade).replace('级', '')
  
  const gradeStudents = allStudents.value.filter(s => {
    const studentGradeStr = String(s.grade)
    const studentNoStr = String(s.studentNo || s.studentId || '')
    const match1 = studentGradeStr === gradeYear
    const match2 = studentGradeStr === String(grade)
    const match3 = studentNoStr.startsWith(gradeYear)
    return match1 || match2 || match3
  })
  
  // 从学生数据中提取专业（使用后端返回的major字段）
  const uniqueMajors = [...new Set(
    gradeStudents.map(s => {
      return s.major || s.specialty || s.dept || s.department || s.collegeName || s.college
    }).filter(m => m)
  )]
  
  majorList.value = uniqueMajors
}

// 专业选择变化
const onMajorChange = (major) => {
  if (major) {
    // 延迟渲染图表，确保DOM已更新
    setTimeout(() => {
      initMajorPieChart()
      initClassBarChart()
    }, 200)
  }
}

// 初始化专业达标率环形图
const initMajorPieChart = () => {
  if (!majorPieChart.value) return
  
  if (majorPieChartInstance) {
    majorPieChartInstance.dispose()
    majorPieChartInstance = null
  }
  
  majorPieChartInstance = echarts.init(majorPieChart.value)
  
  const data = majorPassData.value
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      top: 'center'
    },
    series: [
      {
        name: '达标情况',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}\n{c}人'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '16',
            fontWeight: 'bold'
          }
        },
        data: [
          { value: data.passed, name: '已达标', itemStyle: { color: '#67C23A' } },
          { value: data.unpassed, name: '未达标', itemStyle: { color: '#E6A23C' } }
        ]
      }
    ]
  }
  
  majorPieChartInstance.setOption(option)
}

// 初始化班级达标率柱状图
const initClassBarChart = () => {
  if (!classBarChart.value) return
  
  if (classBarChartInstance) {
    classBarChartInstance.dispose()
    classBarChartInstance = null
  }
  
  classBarChartInstance = echarts.init(classBarChart.value)
  
  const data = classPassData.value
  
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: (params) => {
        const item = params[0]
        const classData = data.find(d => d.className === item.name)
        return `${item.name}<br/>达标率: ${item.value}%<br/>达标: ${classData?.passed}/${classData?.total}`
      }
    },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'value',
      max: 100,
      axisLabel: { formatter: '{value}%' }
    },
    yAxis: {
      type: 'category',
      data: data.map(item => item.className),
      axisLabel: { fontSize: 12, color: '#333' }
    },
    series: [
      {
        name: '达标率',
        type: 'bar',
        data: data.map(item => ({
          value: item.passRate,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: '#52c41a' },
              { offset: 1, color: '#389e0d' }
            ])
          }
        })),
        label: {
          show: true,
          position: 'right',
          formatter: '{c}%',
          color: '#333'
        },
        barWidth: '50%'
      }
    ]
  }
  
  classBarChartInstance.setOption(option)
}

// 窗口大小改变时调整图表
const handleResize = () => {
  majorPieChartInstance?.resize()
  classBarChartInstance?.resize()
}

// 挂载时初始化
onMounted(() => {
  loadData()
  
  window.addEventListener('resize', handleResize)
})

// 卸载时销毁图表
onUnmounted(() => {
  majorPieChartInstance?.dispose()
  classBarChartInstance?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.counselor-dashboard {
  min-height: 100vh;
  background: #f5f7fa;
  color: #333;
  padding: 0 20px 20px;
  position: relative;
}

.overview-row {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  flex: 1;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  transition: all 0.3s;
  position: relative;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(82, 196, 26, 0.1), transparent);
  transition: 0.5s;
}

.stat-card:hover::before {
  left: 100%;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(82, 196, 26, 0.15);
  border-color: #52c41a;
}

.card-icon {
  width: 60px;
  height: 60px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;
}

.icon-blue { background: linear-gradient(135deg, #52c41a 0%, #389e0d 100%); }
.icon-purple { background: linear-gradient(135deg, #722ed1 0%, #531dab 100%); }
.icon-red { background: linear-gradient(135deg, #f5222d 0%, #cf1322 100%); }

.card-content {
  flex: 1;
}

.card-value {
  font-size: 32px;
  font-weight: bold;
  color: #333;
  line-height: 1.2;
}

.card-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.content-row {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.panel {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.panel-lg { flex: 1; }
.panel-xl { flex: 3; width: 100%; }

.panel-header {
  padding: 15px 20px;
  background: #fafafa;
  border-bottom: 1px solid #e8e8e8;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
  font-weight: 600;
}

.panel-tabs {
  display: flex;
  gap: 15px;
}

.panel-tabs span {
  cursor: pointer;
  padding: 5px 12px;
  border-radius: 5px;
  font-size: 13px;
  color: #666;
  transition: all 0.3s;
}

.panel-tabs span:hover,
.panel-tabs span.active {
  color: #52c41a;
  background: #f6ffed;
}

.panel-tabs span.active {
  color: #52c41a;
  background: #f6ffed;
  border: 1px solid #b7eb8f;
}

.analysis-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.chart-container {
  width: 100%;
  height: 350px;
}

.table-container {
  padding: 10px;
  max-height: 400px;
  overflow-y: auto;
}

.table-container :deep(.el-table) {
  background: transparent;
}

.table-container :deep(.el-table th),
.table-container :deep(.el-table td) {
  background: transparent;
  border-color: #e8e8e8;
  color: #333;
}

.table-container :deep(.el-table tr:hover > td) {
  background: #f6ffed !important;
}

.table-container :deep(.el-table--striped .el-table__body tr.el-table__row--striped td) {
  background: #fafafa;
}

.empty-tip {
  padding: 60px 0;
  text-align: center;
}
</style>