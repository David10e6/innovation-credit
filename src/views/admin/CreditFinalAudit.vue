<template>
  <div class="credit-final-audit">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>待终审列表</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-loading v-loading="loading" element-loading-text="加载中..." fullscreen>
        <div v-if="applyList && applyList.length > 0">
          <el-table :data="applyList" style="width: 100%" stripe border>
            <el-table-column prop="studentId" label="学号" width="120"></el-table-column>
            <el-table-column prop="studentName" label="学生姓名" width="120"></el-table-column>
            <el-table-column prop="major" label="专业" width="150"></el-table-column>
            <el-table-column prop="className" label="班级" width="120"></el-table-column>
            <el-table-column prop="activityName" label="活动名称" show-overflow-tooltip></el-table-column>
            <el-table-column prop="activityType" label="活动类型" width="120"></el-table-column>
            <el-table-column prop="level" label="级别" width="80"></el-table-column>
            <el-table-column prop="organizer" label="主办方" width="150"></el-table-column>
            <el-table-column prop="applyCredit" label="申请学分" width="100"></el-table-column>


            <el-table-column label="操作" width="120" fixed="right">
              <template #default="scope">
                <el-button type="primary" size="small" @click="goToAudit(scope.row.id)">
                  审核
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div v-else class="empty-state">
          <el-empty description="暂无待终审记录"></el-empty>
        </div>
      </el-loading>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { auditAPI, studentAPI } from '../../api'

const router = useRouter()
const applyList = ref([])
const loading = ref(false)

const getPendingList = async () => {
  loading.value = true
  try {
    const response = await auditAPI.getSchoolPending()
    // 确保赋值为数组，兼容不同的返回格式
    const rawList = Array.isArray(response.data) ? response.data : Array.isArray(response.data?.list) ? response.data.list : []
    
    // 根据studentId获取学生详细信息
    const enhancedList = await Promise.all(rawList.map(async (item) => {
      try {
        // 调用学生信息接口获取详细信息
        const studentResponse = await studentAPI.getStudentById(item.studentId)
        if (studentResponse.data) {
          return {
            ...item,
            studentName: studentResponse.data.name || '',
            major: studentResponse.data.major || '',
            className: studentResponse.data.className || ''
          }
        }
        return item
      } catch (error) {
        console.error(`获取学生 ${item.studentId} 信息失败:`, error)
        return item
      }
    }))
    
    applyList.value = enhancedList
  } catch (error) {
    console.error('Get pending list error:', error)
    ElMessage.error('获取待终审列表失败')
    // 出错时兜底赋值为空数组
    applyList.value = []
  } finally {
    loading.value = false
  }
}

const goToAudit = (applyId) => {
  router.push(`/admin/credit/final-audit/${applyId}`)
}



const goBack = () => {
  router.push('/admin')
}

onMounted(() => {
  getPendingList()
})
</script>

<style scoped>
.credit-final-audit {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.empty-state {
  margin-top: 50px;
  text-align: center;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .credit-final-audit {
    padding: 10px;
  }
  
  .el-table {
    font-size: 12px;
  }
  
  .el-table-column {
    width: auto !important;
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