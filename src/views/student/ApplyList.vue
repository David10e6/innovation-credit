<template>
  <div class="apply-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>申请记录</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <div v-if="applyList && applyList.length > 0">
        <el-table :data="applyList" style="width: 100%">
          <el-table-column prop="id" label="申请ID" width="180">
            <template #default="scope">
              {{ handleNull(scope.row.id) }}
            </template>
          </el-table-column>
          <el-table-column prop="activityName" label="活动名称">
            <template #default="scope">
              {{ handleNull(scope.row.activityName) }}
            </template>
          </el-table-column>
          <el-table-column prop="applyCredit" label="申请学分" width="100">
            <template #default="scope">
              {{ handleNull(scope.row.applyCredit) }}
            </template>
          </el-table-column>
          <el-table-column label="审核状态" width="150">
            <template #default="scope">
              <el-tag :type="getStatusType(scope.row.auditStatus, scope.row.auditLevel, scope.row.status)">
                {{ getStatusText(scope.row.auditStatus, scope.row.auditLevel, scope.row.status, scope.row.activityId) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="auditLevel" label="审核级别" width="100">
            <template #default="scope">
              {{ auditLevelMap[handleNull(scope.row.auditLevel, 0)] || '-' }}
            </template>
          </el-table-column>
          <el-table-column prop="applyTime" label="申请时间" width="180">
            <template #default="scope">
              {{ formatDate(scope.row.applyTime) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="350">
            <template #default="scope">
              <el-button type="primary" size="small" @click="goToApplyDetail(scope.row.id)">
                查看详情
              </el-button>
              <el-button type="warning" size="small" @click="goToEditApply(scope.row.id)" style="margin-left: 10px" v-if="scope.row.auditStatus === 3">
                修改
              </el-button>
              <el-button type="danger" size="small" @click="deleteApply(scope.row.id)" style="margin-left: 10px" v-if="[0, 3].includes(scope.row.auditStatus)">
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div v-else class="empty-state">
        <el-empty description="暂无申请记录"></el-empty>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { studentAPI, creditApplicationAPI } from '../../api'
import { auditStatusMap, auditLevelMap, statusMap, formatDate, handleNull, getStatusText, getStatusType } from '../../utils'

const router = useRouter()
const applyList = ref([])
const loading = ref(false)

const auditStatusType = {
  0: 'info',
  1: 'info',
  2: 'success',
  3: 'danger'
}

const getApplyList = async () => {
  loading.value = true
  try {
    const response = await studentAPI.getApplyList()
    // 确保赋值为数组，兼容不同的返回格式
    applyList.value = Array.isArray(response.data) ? response.data : (response.data?.data || [])
  } catch (error) {
    console.error('Get apply list error:', error)
    ElMessage.error('获取申请记录失败')
    // 出错时兜底赋值为空数组
    applyList.value = []
  } finally {
    loading.value = false
  }
}

const goToApplyDetail = (applyId) => {
  router.push(`/student/apply/detail/${applyId}`)
}

const goToEditApply = (applyId) => {
  router.push(`/student/apply/edit/${applyId}`)
}

const goBack = () => {
  router.push('/student')
}

const deleteApply = async (applyId) => {
  try {
    await ElMessageBox.confirm('确定要删除该申请吗？', '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await creditApplicationAPI.delete(applyId)
    if (response.code === 200) {
      ElMessage.success('删除成功')
      // 刷新申请列表
      getApplyList()
    } else {
      ElMessage.error('删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Delete apply error:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
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