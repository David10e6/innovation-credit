<template>
  <div class="student-home">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">个人信息</span>
        </div>
      </template>
      <div class="info-section">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="学号">{{ studentInfo.studentId }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ studentInfo.name }}</el-descriptions-item>
          <el-descriptions-item label="学院">{{ studentInfo.college }}</el-descriptions-item>
          <el-descriptions-item label="已获得创新学分">{{ studentInfo.creditTotal }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-card>

    <el-card shadow="hover" style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">学分概览</span>
        </div>
      </template>
      <div class="credit-overview">
        <div class="progress-container">
          <div class="progress-header">
            <span>当前学分：{{ studentInfo.creditTotal }} / 10 分</span>
          </div>
          <div class="progress-bar">
            <div 
              v-for="(item, index) in creditList" 
              :key="index"
              class="progress-segment"
              :class="{ 'hovered': hoveredIndex === index }"
              :style="{ 
                width: (item.applyCredit / 10 * 100) + '%',
                backgroundImage: getGradient(index),
                zIndex: hoveredIndex === index ? 10 : 1
              }"
              @mouseenter="hoveredIndex = index"
              @mouseleave="hoveredIndex = -1"
              @click="showActivityDetail(item)"
              :title="item.activityName + ' (' + item.applyCredit + '分)'"
            >
              <span v-if="(item.applyCredit / 10 * 100) > 15" class="segment-label">
                {{ item.applyCredit }}
              </span>
            </div>
          </div>
          <div class="progress-legend">
            <div 
              v-for="(item, index) in creditList" 
              :key="index"
              class="legend-item"
              @click="showActivityDetail(item)"
            >
              <span class="legend-color" :style="{ backgroundImage: getGradient(index) }"></span>
              <span class="legend-text">{{ item.activityName }} ({{ item.applyCredit }}分)</span>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <el-card shadow="hover" style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">已获得学分列表</span>
        </div>
      </template>
      <el-table :data="creditList" style="width: 100%">
        <el-table-column prop="activityName" label="活动名称">
          <template #default="scope">
            {{ handleNull(scope.row.activityName) }}
          </template>
        </el-table-column>
        <el-table-column prop="activityType" label="活动类型">
          <template #default="scope">
            {{ handleNull(scope.row.activityType) }}
          </template>
        </el-table-column>
        <el-table-column prop="applyCredit" label="学分" width="100">
          <template #default="scope">
            {{ handleNull(scope.row.applyCredit) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="150">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.auditStatus, scope.row.auditLevel, scope.row.status)">
              {{ getStatusText(scope.row.auditStatus, scope.row.auditLevel, scope.row.status, scope.row.activityId) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="auditTime" label="审核时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.auditTime) || '-' }}
          </template>
        </el-table-column>
      </el-table>
      <div v-if="creditList.length === 0" class="empty-state">
        <el-empty description="暂无学分记录"></el-empty>
      </div>
    </el-card>

    <el-dialog
      v-model="activityDialogVisible"
      title="活动详情"
      width="500px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="活动名称">
          {{ currentActivity.activityName }}
        </el-descriptions-item>
        <el-descriptions-item label="活动类型">
          {{ currentActivity.activityType }}
        </el-descriptions-item>
        <el-descriptions-item label="获得学分">
          <el-tag type="success">{{ currentActivity.applyCredit }} 分</el-tag>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="activityDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { studentAPI } from '../../api'
import useUserStore from '../../store/user'
import { activityTypeMap, formatDate, handleNull, getStatusText, getStatusType } from '../../utils'

const router = useRouter()
const userStore = useUserStore()
const studentInfo = ref({
  studentId: '',
  name: '',
  college: '',
  creditTotal: 0
})

// 学分列表数据
const creditList = ref([])

// 悬停索引
const hoveredIndex = ref(-1)

// 活动详情弹窗
const activityDialogVisible = ref(false)
const currentActivity = ref({
  activityName: '',
  activityType: '',
  applyCredit: 0
})

// 渐变色数组
const gradients = [
  'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  'linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)',
  'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
  'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
  'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
  'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)'
]

// 单一颜色数组（用于图例）
const solidColors = [
  '#667eea',
  '#f093fb',
  '#4facfe',
  '#43e97b',
  '#fa709a',
  '#a18cd1',
  '#ffecd2',
  '#ff9a9e',
  '#a8edea',
  '#ffecd2'
]

// 获取渐变色
const getGradient = (index) => {
  return gradients[index % gradients.length]
}

// 获取单一颜色
const getSolidColor = (index) => {
  return solidColors[index % solidColors.length]
}

// 显示活动详情
const showActivityDetail = (item) => {
  currentActivity.value = {
    activityName: item.activityName || '未知活动',
    activityType: item.activityType || '未知类型',
    applyCredit: item.applyCredit || 0
  }
  activityDialogVisible.value = true
}

// 获取已获得的学分之和
const getTotalCredits = async () => {
  try {
    console.log('开始获取学分列表以计算总学分')
    const response = await studentAPI.getCreditList()
    console.log('获取学分列表成功，响应:', response)
    
    const data = response.data || {}
    const externalCredits = data.externalCredits || []
    const internalCredits = data.internalCredits || []
    const allCredits = [...externalCredits, ...internalCredits]
    
    // 过滤出已通过审核的学分记录（免审通过和审核通过）
    const approvedCredits = allCredits.filter(item => {
      // 检查审核状态，只包含免审通过(1)和审核通过(2)的记录
      return item.auditStatus === 1 || item.auditStatus === 2 || item.status === 1 || item.status === 2
    })
    
    // 计算总学分
    const total = approvedCredits.reduce((sum, item) => {
      return sum + (item.applyCredit || 0)
    }, 0)
    
    console.log('过滤后的已通过审核的学分记录:', approvedCredits)
    console.log('计算的总学分:', total)
    return total
  } catch (error) {
    console.error('Get credit list error:', error)
    return 0
  }
}

const getStudentInfo = async () => {
  try {
    console.log('开始获取学生信息')
    const response = await studentAPI.getInfo()
    console.log('获取学生信息成功，响应:', response)
    console.log('学生信息数据:', response.data)
    
    // 处理后端返回的数据，映射到前端期望的字段
    const data = response.data || {}
    
    // 获取总学分
    const totalCredits = await getTotalCredits()
    
    studentInfo.value = {
      studentId: data.studentId || '',
      name: data.name || '',
      college: data.collegeName || '未知学院', // 优先使用collegeName，为空时显示"未知学院"
      creditTotal: totalCredits // 使用计算的总学分
    }
    
    console.log('更新后的学生信息:', studentInfo.value)
  } catch (error) {
    console.error('Get student info error:', error)
    console.error('错误详情:', error.message, error.stack)
    ElMessage.error('获取学生信息失败')
  }
}

// 获取学分列表
const getCreditList = async () => {
  try {
    console.log('开始获取学分列表')
    const response = await studentAPI.getCreditList()
    console.log('获取学分列表成功，响应:', response)
    
    // 后端返回的数据结构
    const data = response.data || {}
    console.log('后端返回的数据:', data)
    
    // 提取 externalCredits 和 internalCredits 数组并合并
    const externalCredits = data.externalCredits || []
    const internalCredits = data.internalCredits || []
    const allCredits = [...externalCredits, ...internalCredits]
    
    // 过滤出已通过审核的学分记录（免审通过和审核通过）
    creditList.value = allCredits.filter(item => {
      // 检查审核状态，只包含免审通过(2)和通过二级审核(1)的记录
      return item.auditStatus === 2 || item.status === 1
    })
    console.log('过滤后的已通过审核的学分记录:', creditList.value)
  } catch (error) {
    console.error('Get credit list error:', error)
    console.error('错误详情:', error.message, error.stack)
    ElMessage.error('获取学分列表失败')
  }
}

onMounted(() => {
  getStudentInfo()
  getCreditList()
})
</script>

<style scoped>
.student-home {
  padding: 24px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 48px);
}

.student-home .el-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
  border: none;
}

.student-home .el-card__header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px 12px 0 0;
  padding: 16px 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header span {
  font-size: 18px;
  font-weight: 600;
  color: white;
  padding-left: 12px;
  border-left: 4px solid rgba(255, 255, 255, 0.6);
}

.info-section {
  margin-top: 20px;
}

.info-section .el-descriptions {
  border-radius: 8px;
  overflow: hidden;
}

.info-section .el-descriptions__label {
  font-weight: 500;
  color: #606266;
  background-color: #f5f7fa;
}

.credit-overview {
  padding: 10px 0;
}

.progress-container {
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #eef2f7 100%);
  border-radius: 12px;
  border: 1px solid #e4e7ed;
}

.progress-header {
  margin-bottom: 20px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  display: flex;
  align-items: center;
}

.progress-header span {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.progress-bar {
  display: flex;
  height: 70px;
  background-color: white;
  border-radius: 12px;
  overflow: visible;
  margin-bottom: 24px;
  padding: 6px;
  box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.06);
}

.progress-segment {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.12);
  margin: 0 2px;
}

.progress-segment:first-child {
  margin-left: 0;
}

.progress-segment:last-child {
  margin-right: 0;
}

.progress-segment.hovered {
  transform: scaleY(1.3) scaleX(1.03);
  filter: brightness(1.1);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.25);
  z-index: 100;
}

.segment-label {
  color: white;
  font-weight: bold;
  font-size: 15px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.progress-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 8px 14px;
  border-radius: 8px;
  transition: all 0.3s ease;
  background-color: white;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.legend-item:hover {
  background-color: #f5f7fa;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.legend-color {
  width: 18px;
  height: 18px;
  border-radius: 4px;
  margin-right: 10px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
}

.legend-text {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.empty-state {
  margin-top: 60px;
  text-align: center;
  padding: 40px 0;
}

.student-home .el-table {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.student-home .el-table__header-wrapper th {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 600;
}

.student-home .el-table__row:hover {
  background-color: #f5f7fa;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .student-home {
    padding: 12px;
  }
  
  .progress-container {
    padding: 16px;
  }
  
  .progress-bar {
    height: 50px;
  }
  
  .segment-label {
    font-size: 12px;
  }
  
  .legend-item {
    padding: 6px 10px;
  }
  
  .legend-text {
    font-size: 13px;
  }
  
  .student-home .el-table {
    font-size: 12px;
  }
  
  .student-home .el-table th,
  .student-home .el-table td {
    padding: 10px 8px;
  }
}
</style>