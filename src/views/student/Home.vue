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
                backgroundColor: getColor(index),
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
              <span class="legend-color" :style="{ backgroundColor: getColor(index) }"></span>
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

// 颜色数组
const colors = [
  '#409EFF',
  '#67C23A',
  '#E6A23C',
  '#F56C6C',
  '#909399',
  '#00CED1',
  '#FF69B4',
  '#9370DB',
  '#20B2AA',
  '#FF7F50'
]

// 获取颜色
const getColor = (index) => {
  return colors[index % colors.length]
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
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-section {
  margin-top: 20px;
}

.progress-container {
  padding: 20px 0;
}

.progress-header {
  margin-bottom: 15px;
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}

.progress-bar {
  display: flex;
  height: 60px;
  background-color: #f5f7fa;
  border-radius: 10px;
  overflow: visible;
  margin-bottom: 20px;
  padding: 5px 0;
}

.progress-segment {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  border-radius: 6px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.progress-segment.hovered {
  transform: scaleY(1.25) scaleX(1.02);
  filter: brightness(1.05);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
  z-index: 100;
}

.segment-label {
  color: white;
  font-weight: bold;
  font-size: 14px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.progress-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.legend-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 5px 10px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.legend-item:hover {
  background-color: #f5f7fa;
}

.legend-color {
  width: 16px;
  height: 16px;
  border-radius: 3px;
  margin-right: 8px;
}

.legend-text {
  font-size: 14px;
  color: #606266;
}

.empty-state {
  margin-top: 50px;
  text-align: center;
}
</style>