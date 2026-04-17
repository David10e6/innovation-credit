<script setup>
import { ref, computed, onMounted } from 'vue'
import useUserStore from '../../store/user'
import { studentAPI } from '../../api'

const userStore = useUserStore()

// 用户信息
const userInfo = computed(() => userStore.userInfo || {})

// 用户角色
const userRole = computed(() => {
  const role = userStore.userInfo?.role
  if (typeof role === 'string') {
    switch (role) {
      case 'student': return 1
      case 'college': return 2
      case 'school': return 3
      default: return 0
    }
  }
  return role || 0
})

// 学分数据
const creditData = ref({
  total: 4, // 总学分要求
  acquired: 0,
  pending: 0,
  categories: []
})

const getCreditData = async () => {
  try {
    console.log('获取学分数据')
    const response = await studentAPI.getCreditList()
    console.log('获取学分列表响应:', response)
    
    const data = response.data || {}
    
    // 检查数据结构
    if (data.totalCredit !== undefined) {
      // API返回的是学分统计信息
      creditData.value.acquired = data.totalCredit || 0
      creditData.value.pending = data.pendingCredit || 0
    } else {
      // API返回的是学分列表
      const externalCredits = data.externalCredits || []
      const internalCredits = data.internalCredits || []
      const allCredits = [...externalCredits, ...internalCredits]
      
      // 计算已获得学分（审核通过的）
      const acquiredCredits = allCredits.filter(item => 
        item.auditStatus === 1 || item.auditStatus === 2 || item.status === 1 || item.status === 2
      )
      creditData.value.acquired = acquiredCredits.reduce((sum, item) => sum + (item.applyCredit || 0), 0)
      
      // 计算待审核学分
      const pendingCredits = allCredits.filter(item => 
        item.auditStatus === 0 || item.status === 0
      )
      creditData.value.pending = pendingCredits.reduce((sum, item) => sum + (item.applyCredit || 0), 0)
      
      // 按分类统计学分
      const categories = {}
      allCredits.forEach(item => {
        const category = item.activityType || '其他'
        if (!categories[category]) {
          categories[category] = 0
        }
        if (item.auditStatus === 1 || item.auditStatus === 2 || item.status === 1 || item.status === 2) {
          categories[category] += item.applyCredit || 0
        }
      })
      
      creditData.value.categories = Object.entries(categories).map(([name, score]) => ({
        name,
        score
      }))
    }
    
    console.log('学分数据:', creditData.value)
  } catch (error) {
    console.error('获取学分数据失败:', error)
  }
}

onMounted(() => {
  if (userRole.value === 1) {
    getCreditData()
  }
})
</script>

<template>
  <div class="profile-container">
    <el-card class="profile-card">
      <template #header>
        <div class="card-header">
          <span>个人中心</span>
        </div>
      </template>
      
      <div class="profile-content">
        <!-- 用户基本信息 -->
        <div class="info-section">
          <h3>基本信息</h3>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="姓名">{{ userInfo.name || '未知' }}</el-descriptions-item>
            <el-descriptions-item v-if="userRole === 1" label="学号">{{ userInfo.studentId || '未知' }}</el-descriptions-item>
            <el-descriptions-item v-else-if="userRole === 2" label="工号">{{ userInfo.username || '未知' }}</el-descriptions-item>
            <el-descriptions-item label="学院">{{ userInfo.collegeName || userInfo.college || '未知' }}</el-descriptions-item>
            <el-descriptions-item v-if="userRole === 1" label="专业">{{ userInfo.major || '未知' }}</el-descriptions-item>
            <el-descriptions-item v-if="userRole === 1" label="年级">{{ userInfo.grade || '未知' }}</el-descriptions-item>
            <el-descriptions-item v-if="userRole === 1" label="班级">{{ userInfo.className || '未知' }}</el-descriptions-item>
          </el-descriptions>
        </div>
        
        <!-- 学分情况（仅学生显示） -->
        <div v-if="userRole === 1" class="credit-section">
          <h3>学分情况</h3>
          <el-card class="credit-card">
            <div class="credit-overview">
              <div class="credit-item">
                <span class="credit-label">总学分要求</span>
                <span class="credit-value">{{ creditData.total }} 分</span>
              </div>
              <div class="credit-item">
                <span class="credit-label">已获得学分</span>
                <span class="credit-value acquired">{{ creditData.acquired }} 分</span>
              </div>
              <div class="credit-item">
                <span class="credit-label">待审核学分</span>
                <span class="credit-value pending">{{ creditData.pending }} 分</span>
              </div>
            </div>
            

          </el-card>
        </div>
      </div>
    </el-card>
  </div>
</template>

<style scoped>
.profile-container {
  width: 100%;
  max-width: 1000px;
  margin: 0 auto;
  padding: 24px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 48px);
}

.profile-container .el-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
  border: none;
}

.profile-container .el-card__header {
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
  margin-bottom: 30px;
}

.info-section h3,
.credit-section h3 {
  margin-bottom: 15px;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  padding-left: 12px;
  border-left: 4px solid #409eff;
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

.credit-section {
  margin-top: 30px;
}

.credit-card {
  margin-top: 10px;
  border-radius: 8px;
  border: none;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.credit-overview {
  display: flex;
  justify-content: space-around;
  margin-bottom: 20px;
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #eef2f7 100%);
  border-radius: 8px;
}

.credit-item {
  text-align: center;
}

.credit-label {
  display: block;
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
  font-weight: 500;
}

.credit-value {
  display: block;
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.credit-value.acquired {
  color: #67c23a;
}

.credit-value.pending {
  color: #e6a23c;
}

.credit-categories h4 {
  margin-bottom: 10px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .profile-container {
    padding: 12px;
  }
  
  .credit-overview {
    flex-direction: column;
    gap: 20px;
  }
  
  .credit-value {
    font-size: 24px;
  }
}
</style>