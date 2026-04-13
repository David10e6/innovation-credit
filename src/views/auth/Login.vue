<template>
  <div class="login-container">
    <div class="login-form">
      <h2>创新学分管理系统</h2>
      <el-form :model="loginForm" :rules="rules" ref="loginFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="loginForm.username" placeholder="请输入用户名"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="loginForm.password" type="password" placeholder="请输入密码"></el-input>
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-radio-group v-model="loginForm.role">
            <el-radio :label="1">学生</el-radio>
            <el-radio :label="2">辅导员</el-radio>
            <el-radio :label="3">管理员</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleLogin" :loading="loading">登录</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { authAPI } from '../../api'
import useUserStore from '../../store/user'

const router = useRouter()
const userStore = useUserStore()
const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
  role: 1
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const handleLogin = async () => {
  try {
    if (!loginFormRef.value) return
    await loginFormRef.value.validate()
    loading.value = true
    
    // 1. 调用登录接口
    const res = await authAPI.login(loginForm);
    console.log('登录完整响应', res); // 打印看完整结构，确认路径

    // 2. 加非空判断，安全取数据
    if (res?.data?.token && res?.data?.user) {
      const token = res.data.token;
      const userInfo = res.data.user;
      const role = userInfo.role;

      console.log('用户角色', role);
      console.log('Token', token);

      // 3. 存储到本地（后续页面用）
      userStore.setToken(token, Date.now() + 7 * 24 * 60 * 60 * 1000); // 7天过期
      userStore.setUserInfo(userInfo);

      // 4. 根据角色跳转页面
      if (role === 'student' || role === 1) {
        router.push('/student'); // 跳转到学生首页
      } else if (role === 'college' || role === 2) {
        router.push('/counselor'); // 跳转到辅导员首页
      } else if (role === 'school' || role === 3) {
        router.push('/admin'); // 跳转到管理员首页
      }
    } else {
      console.error('后端返回数据结构异常', res);
      ElMessage.error('登录失败：数据结构异常');
    }
  } catch (err) {
    console.error('Login error:', err);
    ElMessage.error(err.message || '登录失败，请稍后重试');
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f5f7fa;
}

.login-form {
  width: 400px;
  padding: 30px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.login-form h2 {
  text-align: center;
  margin-bottom: 20px;
  color: #303133;
}

.el-form-item {
  margin-bottom: 20px;
}

.el-button {
  width: 100%;
}
</style>