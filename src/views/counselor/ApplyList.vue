<template>
  <div class="apply-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>待审核列表</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <div v-if="applyList && applyList.length > 0">
        <el-table :data="applyList" style="width: 100%">
          <el-table-column prop="studentId" label="学号" width="120"></el-table-column>
          <el-table-column prop="studentName" label="学生姓名" width="120"></el-table-column>
          <el-table-column prop="major" label="专业" width="150"></el-table-column>
          <el-table-column prop="className" label="班级" width="120"></el-table-column>
          <el-table-column prop="activityName" label="活动名称"></el-table-column>
          <el-table-column prop="activityType" label="活动类型" width="120"></el-table-column>
          <el-table-column prop="level" label="级别" width="80"></el-table-column>
          <el-table-column prop="organizer" label="主办方" width="150"></el-table-column>
          <el-table-column prop="applyCredit" label="申请学分" width="100"></el-table-column>
          <el-table-column prop="applyTime" label="申请时间" width="180">
            <template #default="scope">
              {{ formatDate(scope.row.applyTime) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="审核状态" width="150">
            <template #default="scope">
              <el-tag :type="getStatusType(scope.row.auditStatus, scope.row.auditLevel, scope.row.status)">
                {{ getStatusText(scope.row.auditStatus, scope.row.auditLevel, scope.row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120">
            <template #default="scope">
              <el-button type="primary" size="small" @click="goToApplyAudit(scope.row.id)">
                审核
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div v-else class="empty-state">
        <el-empty description="暂无待审核记录"></el-empty>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { counselorAPI, auditAPI } from '../../api'
import { getStatusText, getStatusType, formatDate } from '../../utils'

const router = useRouter()
const applyList = ref([])
const loading = ref(false)

const getApplyList = async () => {
  loading.value = true
  try {
    // 从localStorage获取用户信息，提取学院ID
    const userInfoStr = localStorage.getItem('userInfo');
    const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
    const collegeId = userInfo?.collegeId || userInfo?.college || '';
    
    if (!collegeId) {
      ElMessage.error('无法获取学院信息');
      applyList.value = []
      return;
    }
    
    console.log('获取待审核列表，collegeId:', collegeId)
    // 调用专门的待审核接口
    const response = await auditAPI.getCollegePending(collegeId)
    console.log('获取待审核列表响应:', response)
    // 确保赋值为数组，兼容不同的返回格式
    applyList.value = Array.isArray(response.data) ? response.data : Array.isArray(response.data?.list) ? response.data.list : []
    console.log('待审核列表数据:', applyList.value)
  } catch (error) {
    console.error('Get apply list error:', error)
    ElMessage.error('获取待审核列表失败')
    // 出错时兜底赋值为空数组
    applyList.value = []
  } finally {
    loading.value = false
  }
}

const goToApplyAudit = (applyId) => {
  router.push(`/counselor/apply/audit/${applyId}`)
}

const goBack = () => {
  router.push('/counselor')
}

onMounted(() => {
  getApplyList()
})
</script>

<style scoped>
.apply-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.empty-state {
  margin-top: 50px;
  text-align: center;
}
</style>