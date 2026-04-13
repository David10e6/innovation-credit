<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import useUserStore from '../store/user'
import { Message, Notification, Bell, EditPen, Document, List, Reading, Plus, Check, UserFilled, Management, DataAnalysis, ArrowDown } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()

// 侧边栏折叠状态
const isCollapse = ref(false)

// 当前用户角色
const userRole = computed(() => {
  const role = userStore.userInfo && userStore.userInfo.role ? userStore.userInfo.role : undefined
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

// 菜单配置 - 可扩展数组格式
const menuConfig = {
  // 学生菜单
  1: [
    {
      index: '/student',
      label: '首页',
      icon: 'Message'
    },
    {
      index: '/student/school-notice',
      label: '消息通知',
      icon: 'Notification'
    },
    {
      index: '/student/activity/notice',
      label: '创新活动',
      icon: 'Bell'
    },
    {
      index: '/student/credit/apply',
      label: '学分申请',
      icon: 'EditPen'
    },
    {
      index: '/student/apply/list',
      label: '申请记录',
      icon: 'List'
    },
    {
      index: '/student/score/rules',
      label: '评分规则',
      icon: 'Reading'
    }
  ],
  // 辅导员菜单
  2: [
    {
      index: '/counselor',
      label: '首页',
      icon: 'Message'
    },
    {
      index: '/counselor/apply/list',
      label: '学院初审',
      icon: 'Check'
    },
    {
      index: '/counselor/student/list',
      label: '本院统计',
      icon: 'UserFilled'
    },
    {
      index: '/counselor/activity/management',
      label: '活动管理',
      icon: 'Management'
    },
    {
      index: '/counselor/notice/management',
      label: '院级通知管理',
      icon: 'Bell'
    },
    {
      index: '/counselor/score/rules',
      label: '评分规则',
      icon: 'Reading'
    }
  ],
  // 管理员菜单
    3: [
      {
        index: '/admin',
        label: '首页',
        icon: 'Message'
      },
      {
        index: '/admin/credit/statistics',
        label: '学分统计',
        icon: 'DataAnalysis'
      },
    {
      index: '/admin/credit/final-audit',
      label: '学分终审',
      icon: 'DataAnalysis'
    },
    { 
      index: '/admin/activity/management',
      label: '活动管理',
      icon: 'Management'
    },
    { 
      index: '/admin/activity/import-participants',
      label: '导入活动参与者',
      icon: 'Plus'
    },
    {
      index: '/admin/student/management',
      label: '学生信息管理',
      icon: 'UserFilled'
    },
    {
      index: '/admin/notice/management',
      label: '校级通知管理',
      icon: 'Bell'
    },
    {
      index: '/admin/score/rules',
      label: '评分规则',
      icon: 'Reading'
    }
  ]
}

// 当前角色的菜单
const currentMenu = computed(() => {
  return menuConfig[userRole.value] || []
})

// 当前激活的菜单
const activeMenu = computed(() => {
  return router.currentRoute.value.path
})

// 根据用户角色返回首页路径
const homePath = computed(() => {
  switch (userRole.value) {
    case 1:
      return '/student'
    case 2:
      return '/counselor'
    case 3:
      return '/admin'
    default:
      return '/login'
  }
})

// 切换侧边栏折叠状态
const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

// 退出登录
const logout = () => {
  userStore.logout()
  router.push('/login')
}


</script>

<template>
  <el-container direction="vertical" style="height: 100vh; width: 100vw; overflow: hidden;">
    <el-container style="flex: 1; overflow: hidden;">
      <!-- 侧边栏 -->
      <el-aside
        :width="isCollapse ? '64px' : '240px'"
        style="background-color: #001529; transition: width 0.3s; overflow: hidden; min-width: 64px;"
      >
        <div style="height: 60px; display: flex; align-items: center; justify-content: space-between; padding: 0 20px;">
          <div v-if="!isCollapse" style="color: white; font-size: 16px; font-weight: bold;">
            创新学分管理系统
          </div>
          <el-button
            link
            icon="Menu"
            @click="toggleCollapse"
            style="color: white"
          ></el-button>
        </div>
        <el-menu
          :default-active="activeMenu"
          class="el-menu-vertical-demo"
          :collapse="isCollapse"
          background-color="#001529"
          text-color="#fff"
          active-text-color="#409EFF"
          router
          style="height: calc(100% - 60px); border-right: none"
        >
          <!-- 动态渲染菜单 -->
          <el-menu-item
            v-for="item in currentMenu"
            :key="item.index"
            :index="item.index"
            :disabled="item.disabled"
          >
            <el-icon>
              <Message v-if="item.icon === 'Message'" />
              <Notification v-else-if="item.icon === 'Notification'" />
              <Bell v-else-if="item.icon === 'Bell'" />
              <EditPen v-else-if="item.icon === 'EditPen'" />
              <Document v-else-if="item.icon === 'Document'" />
              <List v-else-if="item.icon === 'List'" />
              <Reading v-else-if="item.icon === 'Reading'" />
              <Plus v-else-if="item.icon === 'Plus'" />
              <Check v-else-if="item.icon === 'Check'" />
              <UserFilled v-else-if="item.icon === 'UserFilled'" />
              <Management v-else-if="item.icon === 'Management'" />
              <DataAnalysis v-else-if="item.icon === 'DataAnalysis'" />
            </el-icon>
            <template #title>{{ item.label }}</template>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <!-- 主内容区 -->
      <el-container direction="vertical" style="flex: 1; overflow: hidden;">
        <!-- 顶部页头 -->
        <el-header style="background-color: #fff; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); height: 60px; padding: 0 30px;">
          <div style="display: flex; align-items: center; justify-content: space-between; height: 100%;">
            <!-- 面包屑导航 -->
            <el-breadcrumb separator="/">
              <el-breadcrumb-item :to="homePath">首页</el-breadcrumb-item>
              <el-breadcrumb-item>{{ (currentMenu.find(item => item.index === activeMenu) && currentMenu.find(item => item.index === activeMenu).label) ? currentMenu.find(item => item.index === activeMenu).label : '当前页面' }}</el-breadcrumb-item>
            </el-breadcrumb>

            <!-- 用户信息和操作 -->
            <div style="display: flex; align-items: center; gap: 20px;">
              <el-dropdown>
                <span class="el-dropdown-link" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                  <el-avatar size="small" :src="(userStore.userInfo && userStore.userInfo.avatar) ? userStore.userInfo.avatar : ''">
                    {{ (userStore.userInfo && userStore.userInfo.name && userStore.userInfo.name.charAt) ? userStore.userInfo.name.charAt(0) : 'U' }}
                  </el-avatar>
                  <span>{{ (userStore.userInfo && userStore.userInfo.name) ? userStore.userInfo.name : '用户' }}</span>
                  <el-icon><ArrowDown /></el-icon>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>


            </div>
          </div>
        </el-header>

        <!-- 主内容 -->
        <el-main style="padding: 30px; background-color: #f0f2f5; overflow-y: auto; flex: 1; width: 100%;">
          <router-view />
        </el-main>

        <!-- 底部版权栏 -->
        <el-footer style="background-color: #fff; text-align: center; padding: 10px; border-top: 1px solid #e4e7ed; height: 40px;">
          创新学分管理系统 ©2026 版权所有：戴文昊
        </el-footer>
      </el-container>
    </el-container>
  </el-container>
</template>

<style scoped>
.el-menu-vertical-demo:not(.el-menu--collapse) {
  width: 240px;
}
</style>