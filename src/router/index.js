import { createRouter, createWebHashHistory } from 'vue-router'
import store from '../store'

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/auth/Login.vue'),
    meta: { requiresAuth: false }
  },
  // 学生路由
  {
    path: '/student',
    name: 'StudentHome',
    component: () => import('../views/student/Home.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/school-notice',
    name: 'SchoolNotice',
    component: () => import('../views/student/SchoolNotice.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/credit/apply',
    name: 'CreditApply',
    component: () => import('../views/student/CreditApply.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/credit/list',
    name: 'CreditList',
    component: () => import('../views/student/CreditList.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/apply/list',
    name: 'ApplyList',
    component: () => import('../views/student/ApplyList.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/apply/detail/:id',
    name: 'ApplyDetail',
    component: () => import('../views/student/ApplyDetail.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/apply/edit/:id',
    name: 'ApplyEdit',
    component: () => import('../views/student/ApplyEdit.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/activity/notice',
    name: 'StudentActivityNotice',
    component: () => import('../views/student/ActivityNotice.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/score/rules',
    name: 'StudentScoreRules',
    component: () => import('../views/student/ScoreRules.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  {
    path: '/student/profile',
    name: 'StudentProfile',
    component: () => import('../views/student/Profile.vue'),
    meta: { requiresAuth: true, role: 1 }
  },
  // 辅导员路由
  {
    path: '/counselor',
    name: 'CounselorHome',
    component: () => import('../views/counselor/Home.vue'),
    meta: { requiresAuth: true, role: 2 }
  },
  {
    path: '/counselor/apply/list',
    name: 'CounselorApplyList',
    component: () => import('../views/counselor/ApplyList.vue'),
    meta: { requiresAuth: true, role: 2 }
  },
  {
    path: '/counselor/apply/audit/:id',
    name: 'ApplyAudit',
    component: () => import('../views/counselor/ApplyAudit.vue'),
    meta: { requiresAuth: true, role: 2 }
  },
  {
    path: '/counselor/student/list',
    name: 'CounselorStudentList',
    component: () => import('../views/counselor/StudentList.vue'),
    meta: { requiresAuth: true, role: 2 }
  },
  {
    path: '/counselor/activity/management',
    name: 'CounselorActivityManagement',
    component: () => import('../views/counselor/ActivityManagement.vue'),
    meta: { requiresAuth: true, role: 2 }
  },
  { path: '/counselor/notice/management', name: 'CounselorNoticeManagement', component: () => import('../views/counselor/NoticeManagement.vue'), meta: { requiresAuth: true, role: 2 } },
  { path: '/counselor/profile', name: 'CounselorProfile', component: () => import('../views/student/Profile.vue'), meta: { requiresAuth: true, role: 2 } },
  { path: '/counselor/score/rules', name: 'CounselorScoreRules', component: () => import('../views/counselor/ScoreRules.vue'), meta: { requiresAuth: true, role: 2 } },
  // 管理员路由
  {
    path: '/admin',
    name: 'AdminHome',
    component: () => import('../views/admin/Home.vue'),
    meta: { requiresAuth: true, role: 3 }
  },

  {
    path: '/admin/credit/statistics',
    name: 'CreditStatistics',
    component: () => import('../views/admin/CreditStatistics.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  {
    path: '/admin/credit/final-audit',
    name: 'CreditFinalAudit',
    component: () => import('../views/admin/CreditFinalAudit.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  {
    path: '/admin/credit/final-audit/:id',
    name: 'CreditFinalAuditDetail',
    component: () => import('../views/admin/CreditFinalAuditDetail.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  {
    path: '/admin/activity/management',
    name: 'AdminActivityManagement',
    component: () => import('../views/admin/ActivityManagement.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  {
    path: '/admin/activity/import-participants',
    name: 'ImportParticipants',
    component: () => import('../views/admin/ImportParticipants.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  {
    path: '/admin/notice/management',
    name: 'AdminNoticeManagement',
    component: () => import('../views/admin/NoticeManagement.vue'),
    meta: { requiresAuth: true, role: 3 }
  },

  {
    path: '/admin/score/rules',
    name: 'AdminScoreRules',
    component: () => import('../views/admin/ScoreRules.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  {
    path: '/admin/student/management',
    name: 'StudentManagement',
    component: () => import('../views/admin/StudentManagement.vue'),
    meta: { requiresAuth: true, role: 3 }
  },
  // 404页面
  {
    path: '/:pathMatch(.*)*',
    redirect: '/login'
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from) => {
  const requiresAuth = to.meta.requiresAuth
  
  // 不需要认证的路由直接放行
  if (!requiresAuth) {
    return true
  }
  
  // 需要认证的路由，暂时直接放行，避免在路由守卫中使用 composable 函数
  return true
})

export default router