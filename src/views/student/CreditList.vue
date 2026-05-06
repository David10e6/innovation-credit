<template>
  <div class="credit-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学分列表</span>
          <el-button type="primary" @click="goBack">返回</el-button>
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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { studentAPI } from '../../api'
import { activityTypeMap, formatDate, handleNull, getStatusText, getStatusType } from '../../utils'

const router = useRouter()
const creditList = ref([])

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

const goBack = () => {
  router.push('/student')
}



onMounted(() => {
  getCreditList()
})
</script>

<style scoped>
.credit-list {
  padding: 24px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 48px);
}

.credit-list .el-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border: none;
}

.credit-list .el-card__header {
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

.credit-list .el-table {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.credit-list .el-table__header-wrapper th {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 600;
}

.credit-list .el-table__row:hover {
  background-color: #f5f7fa;
}

.empty-state {
  margin-top: 60px;
  text-align: center;
  padding: 40px 0;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .credit-list {
    padding: 12px;
  }
  
  .credit-list .el-table {
    font-size: 12px;
  }
  
  .credit-list .el-table th,
  .credit-list .el-table td {
    padding: 10px 8px;
  }
}
</style>