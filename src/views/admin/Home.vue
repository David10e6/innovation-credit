<template>
  <div class="admin-home">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">个人信息</span>
          <el-button type="primary" @click="handleLogout">退出登录</el-button>
        </div>
      </template>
      <div class="info-section">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="管理员ID">{{ adminInfo.adminId }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ adminInfo.name }}</el-descriptions-item>
          <el-descriptions-item label="角色">学校管理员</el-descriptions-item>
          <el-descriptions-item label="权限">系统管理</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-card>
    
    <el-card shadow="hover" style="margin-top: 20px; min-height: 400px;">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">欢迎使用</span>
        </div>
      </template>
      <div class="welcome-section">
        <el-empty description="请从左侧菜单选择功能" />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import useUserStore from '../../store/user'

const router = useRouter()
const userStore = useUserStore()
const adminInfo = ref({
  adminId: '',
  name: ''
})

const getAdminInfo = () => {
  // 从用户存储中获取管理员信息
  const userInfo = userStore.getUserInfo
  if (userInfo) {
    adminInfo.value = {
      adminId: userInfo.userId,
      name: userInfo.name
    }
  }
}

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}

const goToUserList = () => {
  router.push('/admin/user/list')
}

const goToCreditStatistics = () => {
  router.push('/admin/credit/statistics')
}

const goToActivityManagement = () => {
  router.push('/admin/activity/management')
}

onMounted(() => {
  getAdminInfo()
})
</script>

<style scoped>
.admin-home {
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

.menu-section {
  margin-top: 30px;
}

.menu-card {
  cursor: pointer;
  transition: all 0.3s;
  text-align: center;
  padding: 40px 0;
}

.menu-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.menu-icon {
  font-size: 48px;
  margin-bottom: 15px;
}

.menu-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 10px;
}

.menu-desc {
  color: #606266;
}
</style>