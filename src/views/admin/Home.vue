<template>
  <div class="data-dashboard">
    <!-- 全校总览 - 指标卡片 -->
    <div class="overview-row">
      <div class="stat-card">
        <div class="card-icon icon-blue">
          <i class="el-icon-user"></i>
        </div>
        <div class="card-content">
          <div class="card-value">{{ overviewData.totalStudents || 0 }}</div>
          <div class="card-label">全校总人数</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="card-icon icon-purple">
          <i class="el-icon-s-check"></i>
        </div>
        <div class="card-content">
          <div class="card-value">{{ (overviewData.passRate || 0).toFixed(2) }}%</div>
          <div class="card-label">全校达标率</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="card-icon icon-red">
          <i class="el-icon-warning"></i>
        </div>
        <div class="card-content">
          <div class="card-value">{{ overviewData.pendingAudits || 0 }}</div>
          <div class="card-label">待终审申请数</div>
        </div>
      </div>
    </div>

    <!-- 内容区域 - 两行布局 -->
    <div class="dashboard-content">
      <!-- 第一行：年级选择 -->
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

      <!-- 第二行：各学院达标率排行 + 各专业学分排名 -->
      <div class="content-row">
        <div class="panel panel-lg">
          <div class="panel-header">
            <h3>各学院学分达标率</h3>
          </div>
          <div ref="collegeRankChart" class="chart-container"></div>
        </div>
        <div class="panel panel-lg">
      <div class="panel-header">
        <h3>各专业学分排名TOP10</h3>
        <div style="display: flex; gap: 12px;">
          <el-select
            v-model="selectedCollege"
            placeholder="选择学院"
            size="small"
            style="width: 180px"
            @change="handleCollegeChange"
            clearable
          >
            <el-option
              v-for="college in collegeList"
              :key="college.id"
              :label="college.name"
              :value="college.id"
            ></el-option>
          </el-select>
          <el-select
            v-model="selectedMajor"
            placeholder="选择专业"
            size="small"
            style="width: 180px"
            @change="loadMajorRanking"
            :disabled="!selectedCollege"
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
          <div v-if="majorList.length === 0" style="padding: 20px; color: #999;">
            暂无专业数据，请检查后端学生数据中是否包含专业字段（major / specialty）
          </div>
          <div class="table-container">
            <el-table :data="majorRankingData" style="width: 100%" size="small">
              <el-table-column prop="rank" label="排名" width="60" align="center">
                <template #default="{ row }">
                  <span v-if="row.rank <= 3" style="color: #f5222d; font-weight: bold;">{{ row.rank }}</span>
                  <span v-else>{{ row.rank }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="studentName" label="学生姓名"></el-table-column>
              <el-table-column prop="studentNo" label="学号" width="160"></el-table-column>
              <el-table-column prop="major" label="专业" width="150"></el-table-column>
              <el-table-column prop="totalCredit" label="总学分" width="90" align="center" sortable></el-table-column>
            </el-table>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部装饰 -->
    <div class="footer-decoration"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import { adminAPI } from '../../api'

// 响应式数据
const currentTime = ref('')
const overviewData = ref({})
const collegeRankData = ref([])
const majorRankingData = ref([]) // 各专业学分排名TOP10
const majorList = ref([]) // 专业列表
const selectedMajor = ref('') // 当前选中的专业
const allStudents = ref([]) // 保存所有学生数据
const gradeList = ref([]) // 年级列表，从后端获取
const selectedGrade = ref('') // 当前选中的年级
const collegeList = ref([]) // 学院列表
const selectedCollege = ref('') // 当前选中的学院

// 图表引用
const collegeRankChart = ref(null)

// 图表实例
let collegeRankChartInstance = null

// 更新时间
const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 加载真实数据
const loadData = async () => {
  try {
    // 从API获取数据
    const overviewRes = await adminAPI.getAdminStatsOverview()
    const studentRes = await adminAPI.getStudentList()
    const collegeRes = await adminAPI.getCollegeList()
    
    // 更新概览数据
    overviewData.value = {
      totalStudents: overviewRes.data?.totalStudents || 0,
      totalCredits: overviewRes.data?.totalCredits || 0,
      avgCredits: overviewRes.data?.avgCredits || 0,
      passRate: overviewRes.data?.passRate || 0,
      pendingAudits: overviewRes.data?.pendingAudits || 0
    }
    
    // 更新学院列表 - collegeRes 已经是学院数组了
        collegeList.value = collegeRes || [];    
    // 更新年级列表（先用默认的，如果后端接口正常再替换）
    let gradesFromServer = []
    try {
      const gradeRes = await adminAPI.getGradeList()
      gradesFromServer = gradeRes.data || []
    } catch (e) {
      console.log('获取年级列表失败，使用默认年级')
    }
    gradeList.value = gradesFromServer.length > 0 ? ['全部', ...gradesFromServer] : ['全部', '2021级', '2022级', '2023级', '2024级']
    
    // 保存学生数据
    const students = studentRes.data || studentRes.rows || []
    allStudents.value = students
    
    console.log('加载完成 - 年级列表:', gradeList.value, '学院列表:', collegeList.value, '学生数:', students.length)
    if (students.length > 0) {
      console.log('学生数据第一条 - 完整对象:', students[0])
      console.log('学生数据第一条 - 字段列表:', Object.keys(students[0]))
    }
    
    // 加载第一个年级数据
    if (gradeList.value.length > 0) {
      selectedGrade.value = gradeList.value[0]
      await selectGrade(selectedGrade.value)
    }
    
  } catch (error) {
    console.error('加载数据失败:', error)
  }
}

// 学院选择变化
const handleCollegeChange = async (collegeId) => {
  selectedMajor.value = ''
  majorRankingData.value = []
  
  if (!collegeId) {
    majorList.value = []
    return
  }
  
  try {
    // 使用 API 获取该学院的专业列表
    const response = await adminAPI.getMajorsByCollege(collegeId)
    console.log('获取专业列表API响应:', response)
    
    // 处理响应数据，提取专业名称列表
    let majors = []
    if (response && response.data) {
      if (Array.isArray(response.data)) {
        // 如果响应是数组，直接使用
        majors = response.data.map(item => item.majorName || item.major || item.name || item)
      } else if (response.data.rows) {
        // 如果是分页格式
        majors = response.data.rows.map(item => item.majorName || item.major || item.name || item)
      }
    }
    
    // 过滤掉空值
    majorList.value = majors.filter(m => m)
    
    if (majorList.value.length > 0) {
      selectedMajor.value = majorList.value[0]
      await loadMajorRanking()
    }
  } catch (error) {
    console.error('获取专业列表失败:', error)
    // 如果 API 失败，回退到从学生数据中提取
    console.log('API 获取失败，尝试从学生数据中提取专业列表')
    fallbackExtractMajors(collegeId)
  }
}

// 回退方案：从学生数据中提取专业列表
const fallbackExtractMajors = async (collegeId) => {
  // 先找到学院名称
  const college = collegeList.value.find(c => c.id === collegeId)
  if (!college) {
    majorList.value = []
    return
  }
  
  const collegeName = college.name
  console.log('学院名称:', collegeName)
  
  // 从学生列表中提取该学院的专业列表
  const collegeStudents = allStudents.value.filter(s => 
    s.collegeName === collegeName || s.college === collegeName || s.dept === collegeName
  )
  const uniqueMajors = [...new Set(collegeStudents.map(s => s.major || s.specialty).filter(m => m))]
  majorList.value = uniqueMajors
  
  if (majorList.value.length > 0) {
    selectedMajor.value = majorList.value[0]
    await loadMajorRanking()
  }
}

// 选择年级
const selectGrade = async (grade) => {
  selectedGrade.value = grade
  console.log('选择年级:', grade, '当前专业:', selectedMajor.value)
  
  try {
    // 从后端获取该年级的学院达标率数据
    const collegeRes = await adminAPI.getAllCollegesPassRate(grade)
    
    // 更新学院数据
    collegeRankData.value = (collegeRes.data || []).map(item => ({
      name: item.collegeName || item.name,
      passRate: item.passRate || 0,
      total: item.totalCount || 0
    }))
    
    console.log('学院数据:', collegeRankData.value)
    
    // 刷新学院图表
    initCollegeRankChart()
    
    // 同时更新专业排名
    if (selectedMajor.value) {
      await loadMajorRanking()
    }
    
  } catch (error) {
    console.error('加载年级数据失败:', error)
    // 临时：如果没有后端数据，用学生列表生成
    fallbackToLocalData()
  }
}

// 加载专业学分排名
const loadMajorRanking = async () => {
  if (!selectedMajor.value) {
    majorRankingData.value = []
    return
  }
  
  console.log('加载专业排名 - 年级:', selectedGrade.value, '专业:', selectedMajor.value)
  
  try {
    // 从后端获取该年级该专业的排名数据
    const rankingRes = await adminAPI.getMajorCreditRanking(selectedGrade.value, selectedMajor.value)
    
    majorRankingData.value = (rankingRes.data || []).map((item, index) => ({
      rank: index + 1,
      studentName: item.studentName || item.name,
      studentNo: item.studentNo || item.studentId,
      major: item.major || item.specialty,
      totalCredit: item.totalCredit || item.credit || 0
    }))
    
    console.log('专业排名数据:', majorRankingData.value)
    
  } catch (error) {
    console.error('加载专业排名失败，使用本地数据:', error)
    // 临时：如果没有后端数据，用学生列表生成
    fallbackToLocalData()
  }
}

// 临时函数：从本地学生数据生成
const fallbackToLocalData = () => {
  const grade = selectedGrade.value
  
  // 筛选年级
  let filteredStudents = allStudents.value
  if (grade && grade !== '全部') {
    const gradeYear = grade.replace('级', '')
    filteredStudents = allStudents.value.filter(s => 
      (s.studentNo || '').startsWith(gradeYear) || 
      (s.grade || '') === grade || 
      (s.grade || '') === gradeYear ||
      (s.enrollmentYear || '') === gradeYear
    )
  }
  
  console.log('fallback: 筛选后学生数:', filteredStudents.length)
  
  // 生成学院数据（临时） - 但是学院数据已经从后端获取了，这里只更新专业排名
  if (selectedMajor.value) {
    // 尝试多种字段匹配
    const majorStudents = filteredStudents.filter(s => {
      const studentMajor = s.major || s.specialty || s.department || s.dept || s.college || s.collegeName || ''
      return studentMajor === selectedMajor.value
    })
    
    console.log('fallback: 找到专业学生数:', majorStudents.length, '选中专业:', selectedMajor.value)
    
    majorRankingData.value = majorStudents
      .sort((a, b) => {
        const creditA = a.totalCredit || a.credit || a.credits || 0
        const creditB = b.totalCredit || b.credit || b.credits || 0
        return creditB - creditA
      })
      .slice(0, 10)
      .map((item, index) => ({
        rank: index + 1,
        studentName: item.studentName || item.name || item.username || '未知',
        studentNo: item.studentNo || item.studentId || item.studentIdCard || '',
        major: item.major || item.specialty || item.department || item.dept || item.college || item.collegeName || '',
        totalCredit: item.totalCredit || item.credit || item.credits || 0
      }))
      
    console.log('fallback: 排名数据:', majorRankingData.value)
  }
  
  console.log('使用本地数据 - 排名:', majorRankingData.value)
}

// 初始化各学院达标率排行图表
const initCollegeRankChart = () => {
  if (!collegeRankChart.value) return
  
  // 如果已存在实例，直接更新 option
  if (collegeRankChartInstance) {
    const sortedData = [...collegeRankData.value].sort((a, b) => b.passRate - a.passRate)
    collegeRankChartInstance.setOption({
      yAxis: { data: sortedData.map(item => item.name) },
      series: [{
        data: sortedData.map(item => ({
          value: item.passRate,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: '#52c41a' },
              { offset: 1, color: '#389e0d' }
            ])
          }
        }))
      }]
    })
    return
  }
  
  // 创建新实例
  collegeRankChartInstance = echarts.init(collegeRankChart.value)
  
  const sortedData = [...collegeRankData.value].sort((a, b) => b.passRate - a.passRate)
  
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' }
    },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value', max: 100, axisLabel: { formatter: '{value}%' } },
    yAxis: {
      type: 'category',
      data: sortedData.map(item => item.name),
      axisLabel: { fontSize: 11, color: '#333' }
    },
    series: [
      {
        name: '达标率',
        type: 'bar',
        data: sortedData.map(item => ({
          value: item.passRate,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: '#52c41a' },
              { offset: 1, color: '#389e0d' }
            ])
          }
        })),
        label: { show: true, position: 'right', formatter: '{c}%', color: '#333' },
        barWidth: '60%'
      }
    ]
  }
  
  collegeRankChartInstance.setOption(option)
}

// 窗口大小改变时调整图表
const handleResize = () => {
  collegeRankChartInstance?.resize()
}

// 挂载时初始化
onMounted(() => {
  loadData()
  updateTime()
  setInterval(updateTime, 1000)
  
  // 延迟初始化图表，确保DOM已渲染
  setTimeout(() => {
    initCollegeRankChart()
  }, 200)
  
  window.addEventListener('resize', handleResize)
})

// 卸载时销毁图表
onUnmounted(() => {
  collegeRankChartInstance?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.data-dashboard {
  min-height: 100vh;
  background: #f5f7fa;
  color: #333;
  padding: 0 20px 20px;
  position: relative;
}

.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 2px solid #e8e8e8;
  margin-bottom: 20px;
}

.title {
  font-size: 28px;
  font-weight: bold;
  color: #52c41a;
  margin: 0;
  letter-spacing: 2px;
}

.time-display {
  font-size: 16px;
  color: #666;
  font-weight: 500;
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
.icon-green { background: linear-gradient(135deg, #1890ff 0%, #096dd9 100%); }
.icon-orange { background: linear-gradient(135deg, #faad14 0%, #d48806 100%); }
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

.dashboard-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.content-row {
  display: flex;
  gap: 20px;
}

.panel {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.panel-md { flex: 1; }
.panel-lg { flex: 2; }
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

.chart-container {
  width: 100%;
  height: 300px;
}

.table-container {
  padding: 10px;
  max-height: 280px;
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

.footer-decoration {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, transparent, #52c41a, #1890ff, transparent);
}
</style>
