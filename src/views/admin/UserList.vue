<template>
  <div class="user-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-table :data="userList" style="width: 100%">
        <el-table-column prop="userId" label="用户ID" width="150"></el-table-column>
        <el-table-column prop="username" label="用户名" width="150"></el-table-column>
        <el-table-column prop="name" label="姓名" width="120"></el-table-column>
        <el-table-column prop="college" label="学院"></el-table-column>
        <el-table-column prop="role" label="角色" width="100">
          <template #default="scope">
            {{ roleTypeMap[scope.row.role] }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleEdit(scope.row)">
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(scope.row.userId)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="add-user">
        <el-button type="primary" @click="handleAdd">添加用户</el-button>
      </div>
      <div v-if="userList.length === 0" class="empty-state">
        <el-empty description="暂无用户记录"></el-empty>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { adminAPI } from '../../api'
import { roleTypeMap } from '../../utils'

const router = useRouter()
const userList = ref([])

const getUserList = async () => {
  try {
    const response = await adminAPI.getUserList()
    userList.value = response.data
  } catch (error) {
    console.error('Get user list error:', error)
    ElMessage.error('获取用户列表失败')
  }
}

const handleAdd = () => {
  // 这里可以打开添加用户的对话框
  ElMessage.info('添加用户功能开发中')
}

const handleEdit = (user) => {
  // 这里可以打开编辑用户的对话框
  ElMessage.info('编辑用户功能开发中')
}

const handleDelete = async (userId) => {
  try {
    await ElMessageBox.confirm('确定要删除该用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await adminAPI.deleteUser(userId)
    ElMessage.success('删除成功')
    getUserList()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Delete user error:', error)
      ElMessage.error('删除失败')
    }
  }
}

const goBack = () => {
  router.push('/admin')
}

onMounted(() => {
  getUserList()
})
</script>

<style scoped>
.user-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.add-user {
  margin-top: 20px;
  text-align: right;
}

.empty-state {
  margin-top: 50px;
  text-align: center;
}
</style>