import axios from 'axios'

// 创建 axios 实例
const api = axios.create({
  baseURL: '',
  timeout: 10000,
  withCredentials: true
})

// 请求拦截器
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    
    // 当请求数据是 FormData 时，不设置 Content-Type，让浏览器自动处理
    if (!(config.data instanceof FormData)) {
      // 添加必要的请求头
      config.headers['Content-Type'] = 'application/json'
      config.headers['Accept'] = 'application/json'
    }
    
    // 登录请求不需要携带Authorization头
    if (token && !config.url.includes('/api/auth/login')) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  response => {
    const res = response.data
    console.log('响应数据:', res)
    
    // 检查响应是否包含code字段
    if (res.code !== undefined) {
      // 标准格式，需要检查code
      if (res.code !== 200) {
        console.error('响应错误:', res)
        console.error('错误信息:', res.msg || '未知错误')
        return Promise.reject(new Error(res.msg || 'Error'))
      }
      return res
    } else {
      // 非标准格式（如学分列表接口），直接返回数据
      console.log('非标准响应格式，直接返回数据')
      return {
        code: 200,
        msg: 'success',
        data: res
      }
    }
  },
  error => {
    console.error('网络错误:', error)
    if (error.response) {
      const status = error.response.status
      if (status === 401) {
        localStorage.removeItem('token')
        window.location.href = '/login'
      } else if (status === 403) {
        console.error('无权限访问')
      } else if (status === 500) {
        console.error('服务端错误')
      }
    }
    return Promise.reject(error)
  }
)

// 认证相关 API
export const authAPI = {
  login: (data) => api.post('/api/auth/login', data),
  register: (data) => api.post('/api/auth/register', data)
}

// 学生相关 API
export const studentAPI = {
  // 获取学生信息
  getInfo: () => {
    try {
      const userInfoStr = localStorage.getItem('userInfo');
      const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
      const studentId = userInfo && userInfo.studentId ? userInfo.studentId : (userInfo && userInfo.id ? userInfo.id : null);
      console.log('获取学生信息，studentId:', studentId);
      if (!studentId) {
        console.error('学生ID不存在:', userInfo);
        return Promise.reject(new Error('学生ID不存在'));
      }
      return api.get('/api/student/info')
        .then(response => {
          console.log('获取学生信息API响应:', response);
          return response;
        })
        .catch(error => {
          console.error('获取学生信息API请求错误:', error);
          // 如果是403错误，尝试使用学生ID作为参数
          if (error.response && error.response.status === 403) {
            console.log('尝试使用学生ID作为参数获取学生信息');
            return api.get(`/api/student/info/${studentId}`);
          }
          throw error;
        });
    } catch (e) {
      console.error('解析 userInfo 失败:', e);
      return Promise.reject(e);
    }
  },
  // 申请学分
  applyCredit: (data) => api.post('/api/credit-application/external', data),
  // 获取申请列表
  getApplyList: () => {
    try {
      const userInfoStr = localStorage.getItem('userInfo');
      const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
      const studentId = userInfo?.studentId || '';
      if (!studentId) {
        return Promise.reject(new Error('学生ID不存在'));
      }
      return api.get('/api/credit-application/student/' + studentId + '/all');
    } catch (e) {
      console.error('解析 userInfo 失败:', e);
      return Promise.reject(e);
    }
  },
  // 获取申请详情
  getApplyDetail: (id) => api.get(`/api/credit-application/detail/${id}`),
  // 获取学分列表
  getCreditList: () => {
    try {
      const userInfoStr = localStorage.getItem('userInfo');
      const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
      const studentId = userInfo?.studentId || '';
      console.log('获取学分列表，studentId:', studentId);
      if (!studentId) {
        console.error('学生ID不存在:', userInfo);
        return Promise.reject(new Error('学生ID不存在'));
      }
      console.log('调用接口:/api/credit-stats/student/' + studentId);
      return api.get('/api/credit-stats/student/' + studentId)
        .then(response => {
          console.log('API响应:', response);
          return response;
        })
        .catch(error => {
          console.error('API请求错误:', error);
          throw error;
        });
    } catch (e) {
      console.error('解析 userInfo 失败:', e);
      return Promise.reject(e);
    }
  },
  // 同步学分
  syncCredit: () => {
    try {
      const userInfoStr = localStorage.getItem('userInfo');
      const userInfo = userInfoStr ? JSON.parse(userInfoStr) : null;
      const studentId = userInfo?.studentId || '';
      console.log('同步学分，studentId:', studentId);
      if (!studentId) {
        console.error('学生ID不存在:', userInfo);
        return Promise.reject(new Error('学生ID不存在'));
      }
      console.log('调用接口:/api/credit-stats/sync/' + studentId);
      return api.post('/api/credit-stats/sync/' + studentId)
        .then(response => {
          console.log('API响应:', response);
          return response;
        })
        .catch(error => {
          console.error('API请求错误:', error);
          throw error;
        });
    } catch (e) {
      console.error('解析 userInfo 失败:', e);
      return Promise.reject(e);
    }
  },
  // 更新申请信息
  updateApply: (data) => api.put('/api/credit-application/update', data),
  // 根据学生ID获取学生信息
  getStudentById: (studentId) => {
    console.log('根据学生ID获取学生信息，studentId:', studentId);
    return api.get(`/api/student/info/${studentId}`)
      .then(response => {
        console.log('根据学生ID获取学生信息API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('根据学生ID获取学生信息API请求错误:', error);
        throw error;
      });
  }
}

// 学分规则相关 API
export const creditRuleAPI = {
  // 获取活动类型和级别列表
  getActivityTypes: () => {
    console.log('获取活动类型和级别列表');
    return api.get('/api/credit-rule/activity-types')
      .then(response => {
        console.log('获取活动类型和级别列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取活动类型和级别列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动类型列表');
          return {
            code: 200,
            msg: 'success',
            data: {
              activityTypes: [],
              levels: [],
              creditRules: []
            }
          };
        }
        throw error;
      });
  },
  // 根据活动类型、级别、名次获取学分规则
  getCreditRule: (params) => {
    console.log('获取学分规则，参数:', params);
    return api.get('/api/credit-rule/calculate', { params })
      .then(response => {
        console.log('获取学分规则API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学分规则API请求错误:', error);
        // 如果是500错误，返回默认学分
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回默认学分');
          return {
            code: 200,
            msg: 'success',
            data: {
              credit: 0.1
            }
          };
        }
        throw error;
      });
  }
}

// 文件上传相关 API
export const fileUploadAPI = {
  // 上传佐证材料
  uploadProof: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/api/file-upload/upload', formData)
      .then(response => {
        console.log('上传佐证材料API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('上传佐证材料API请求错误:', error);
        throw error;
      });
  }
}

// 学分申请相关 API
export const creditApplicationAPI = {
  // 申请校内活动学分
  applyInternal: (data) => api.post('/api/credit-application/internal', data),
  // 申请校外活动学分
  applyExternal: (data) => api.post('/api/credit-application/external', data),
  // 撤回学分申请
  withdraw: (id) => api.post(`/api/credit-application/withdraw/${id}`),
  // 重新提交学分申请
  resubmit: (data) => api.post('/api/credit-application/resubmit', data),
  // 删除学分申请
  delete: (id) => api.delete(`/api/credit-application/delete/${id}`),
  // 获取学生的学分申请记录
  getStudentRecords: (studentId) => api.get(`/api/credit-application/student/${studentId}/all`),
  // 获取学院的学分申请记录
  getCollegeRecords: (collegeId) => {
    // 修复：处理collegeId参数，确保是数字或字符串
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    return api.get(`/api/credit-application/college/${realId}`);
  },
  // 获取学校的学分申请记录
  getSchoolRecords: () => api.get('/api/credit-application/school')
}

// 审核管理相关 API
export const auditAPI = {
  // 学院审核学分申请
  collegeAudit: (data) => api.post('/api/audit/college', data),
  // 学校审核学分申请
  schoolAudit: (data) => api.post('/api/audit/final', data),
  // 获取学院待审核的学分申请
  getCollegePending: (collegeId) => {
    // 修复：处理collegeId参数，确保是数字或字符串
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    return api.get(`/api/audit/college/pending-with-info/${realId}`);
  },
  // 获取学校待审核的学分申请
  getSchoolPending: () => api.get('/api/audit/final/pending')
}

// 辅导员相关 API
export const counselorAPI = {
  // 获取申请列表
  getApplyList: (collegeId) => {
    // 修复：处理collegeId参数，确保是数字或字符串
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    return api.get(`/api/credit-application/college/${realId}`);
  },
  // 获取申请详情
  getApplyDetail: (id) => api.get(`/api/credit-application/detail/${id}`),
  // 审核申请
  auditApply: (data) => api.post('/api/audit/college', data),
  // 获取学生列表
  getStudentList: (collegeId) => {
    // 修复：处理collegeId参数，确保是数字或字符串
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    console.log('获取学生列表，collegeId:', realId);
    console.log('调用接口:/api/student/college/' + realId);
    return api.get(`/api/student/college/${realId}`)
      .then(response => {
        console.log('获取学生列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学生列表API请求错误:', error);
        // 如果是403错误，尝试其他可能的API路径
        if (error.response && error.response.status === 403) {
          console.log('尝试使用替代API路径获取学生列表');
          return api.get(`/api/student/list/college/${realId}`)
            .catch(err => {
              console.error('替代API路径也失败:', err);
              // 403错误时返回空数组，避免页面空白
              return {
                code: 200,
                msg: 'success',
                data: []
              };
            });
        }
        throw error;
      });
  },
  // 获取学院所有班级
  getCollegeClasses: (collegeId) => {
    // 修复：处理collegeId参数，确保是数字或字符串
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    console.log('获取学院班级列表，collegeId:', realId);
    return api.get(`/api/student/college/${realId}/classes`);
  },
  // 获取按班级分组的学生列表
  getStudentClassGroups: (collegeId) => {
    // 修复：处理collegeId参数，确保是数字或字符串
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    console.log('获取按班级分组的学生列表，collegeId:', realId);
    return api.get(`/api/student/college/${realId}/class-group`);
  },
  // 获取年级列表
  getGrades: (collegeId) => {
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    console.log('获取年级列表，collegeId:', realId);
    return api.get(`/api/student/college/${realId}/grades`)
      .then(response => {
        console.log('获取年级列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取年级列表API请求错误:', error);
        throw error;
      });
  },
  // 获取某年级的班级列表
  getClassesByGrade: (collegeId, grade) => {
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    console.log('获取班级列表，collegeId:', realId, 'grade:', grade);
    return api.get(`/api/student/college/${realId}/grades/${grade}/classes`)
      .then(response => {
        console.log('获取班级列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取班级列表API请求错误:', error);
        throw error;
      });
  },
  // 获取年级+班级对应的学生
  getStudentsByGradeAndClass: (collegeId, grade, className) => {
    const realId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (typeof realId !== 'number' && typeof realId !== 'string') {
      console.error('学院ID格式错误，应为数字/字符串');
      return Promise.reject(new Error('学院ID参数错误'));
    }
    console.log('获取学生列表，collegeId:', realId, 'grade:', grade, 'className:', className);
    return api.get(`/api/student/college/${realId}/students`, {
      params: { grade, className }
    })
      .then(response => {
        console.log('获取学生列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学生列表API请求错误:', error);
        throw error;
      });
  }
}

// 活动相关 API
export const activityAPI = {
  // 批量导入活动
  importActivities: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/api/activity/import-activities', formData)
  },
  // 批量导入活动证明
  importActivityProof: (activityFile, participantFile) => {
    const formData = new FormData()
    formData.append('activityFile', activityFile)
    formData.append('participantFile', participantFile)
    return api.post('/api/activity/import-proof', formData)
  },
  // 导入活动参与者
  importParticipants: (activityId, file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post(`/api/activity/import/${activityId}`, formData)
  },
  // 获取活动列表
  getActivities: () => {
    console.log('获取活动列表');
    return api.get('/api/activity/list')
      .then(response => {
        console.log('获取活动列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取活动列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取校级活动
  getSchoolActivities: () => {
    console.log('获取校级活动');
    return api.get('/api/activity/school')
      .then(response => {
        console.log('获取校级活动API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取校级活动API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取院级活动
  getCollegeActivities: (collegeId) => {
    console.log('获取院级活动，collegeId:', collegeId);
    return api.get(`/api/activity/college/${collegeId}`)
      .then(response => {
        console.log('获取院级活动API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取院级活动API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取学生活动
  getStudentActivities: (studentId) => {
    console.log('获取学生活动，studentId:', studentId);
    return api.get(`/api/activity/student/${studentId}`)
      .then(response => {
        console.log('获取学生活动API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学生活动API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  getCounselorCollegeActivities: () => {
    console.log('辅导员获取本院活动列表');
    return api.get('/api/activity/counselor/college')
      .then(response => {
        console.log('辅导员获取本院活动列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('辅导员获取本院活动列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取活动详情
  getActivityDetail: (id) => api.get(`/api/activity/detail/${id}`),
  // 新增活动
  createActivity: (data) => api.post('/api/activity/create', data),
  // 更新活动
  updateActivity: (data) => api.put('/api/activity/update', data),
  // 删除活动
  deleteActivity: (id) => api.delete(`/api/activity/delete/${id}`),
  // 搜索学生
  searchStudents: (keyword) => api.get(`/api/student/search?keyword=${keyword}`),
  // 获取活动参与者
  getActivityParticipants: (activityId) => api.get(`/api/activity/participants/${activityId}`),
  // 添加活动参与者
  addActivityParticipants: (activityId, data) => api.post(`/api/activity/participants/${activityId}`, data),
  // 移除活动参与者
  removeActivityParticipant: (activityId, studentId) => api.delete(`/api/activity/participants/${activityId}/${studentId}`),
  // 管理员获取校级活动列表
  getAdminActivities: () => {
    console.log('管理员获取校级活动列表');
    return api.get('/api/activity/admin/list')
      .then(response => {
        console.log('管理员获取校级活动列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('管理员获取校级活动列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空活动列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 管理员新增校级活动
  createAdminActivity: (data) => api.post('/api/activity/admin/create', data),
  // 管理员修改校级活动
  updateAdminActivity: (data) => api.put('/api/activity/admin/update', data),
  // 管理员删除校级活动
  deleteAdminActivity: (id) => api.delete(`/api/activity/admin/delete/${id}`),
  // 获取所有活动列表（管理员）
  getAllActivities: () => api.get('/api/activity/admin/all'),
  // 获取学生列表（管理员）
  getStudents: (keyword) => api.get(`/api/activity/admin/students?keyword=${keyword}`),
  // 按班级获取学生列表（管理员）
  getStudentsByClass: () => api.get('/api/activity/admin/students-by-class'),
  // 添加活动参与者
  addParticipants: (activityId, data) => {
    console.log('Add participants called with:', activityId, data)
    
    // 直接发送学生ID数组
    const studentIds = Array.isArray(data) ? data : (data.studentIds || [])
    console.log('Sending student IDs:', studentIds)
    return api.post(`/api/activity/participants/${activityId}`, studentIds)
  },
  // 删除活动参与者
  removeParticipant: (activityId, studentId) => api.delete(`/api/activity/participants/${activityId}/${studentId}`)
}

// 通知相关 API
export const noticeAPI = {
  // 获取学生通知列表（本院和校级）
  getStudentNotices: (collegeId) => {
    console.log('获取学生通知，collegeId:', collegeId);
    if (!collegeId) {
      console.error('学院ID不存在');
      return Promise.reject(new Error('学院ID不存在'));
    }
    // 确保collegeId是数字或字符串
    const realCollegeId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (!realCollegeId) {
      console.error('学院ID格式错误');
      return Promise.reject(new Error('学院ID格式错误'));
    }
    console.log('调用接口:/api/notice/student/' + realCollegeId);
    return api.get(`/api/notice/student/${realCollegeId}`)
      .then(response => {
        console.log('获取学生通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学生通知API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空通知列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取辅导员通知列表（本院）
  getCounselorNotices: (collegeId, pageNum, pageSize) => {
    console.log('获取辅导员通知，collegeId:', collegeId, 'pageNum:', pageNum, 'pageSize:', pageSize);
    if (!collegeId) {
      console.error('学院ID不存在');
      return Promise.reject(new Error('学院ID不存在'));
    }
    // 确保collegeId是数字或字符串
    const realCollegeId = typeof collegeId === 'object' ? (collegeId.id || collegeId.collegeId) : collegeId;
    if (!realCollegeId) {
      console.error('学院ID格式错误');
      return Promise.reject(new Error('学院ID格式错误'));
    }
    console.log('调用接口:/api/notice/counselor/' + realCollegeId);
    return api.get(`/api/notice/counselor/${realCollegeId}`, {
      params: { pageNum, pageSize }
    })
      .then(response => {
        console.log('获取辅导员通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取辅导员通知API请求错误:', error);
        // 如果是500错误，返回空列表，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空通知列表');
          return {
            code: 200,
            msg: 'success',
            data: {
              rows: [],
              total: 0
            }
          };
        }
        throw error;
      });
  },
  // 获取管理员通知列表（校级）
  getAdminNotices: (pageNum, pageSize) => {
    console.log('获取管理员通知，pageNum:', pageNum, 'pageSize:', pageSize);
    return api.get('/api/notice/admin', {
      params: { pageNum, pageSize }
    })
      .then(response => {
        console.log('获取管理员通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取管理员通知API请求错误:', error);
        // 如果是500错误，返回空列表，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空通知列表');
          return {
            code: 200,
            msg: 'success',
            data: {
              records: [],
              total: 0
            }
          };
        }
        throw error;
      });
  },
  // 发布通知
  publishNotice: (data) => {
    console.log('发布通知，数据:', data);
    return api.post('/api/notice/publish', data)
      .then(response => {
        console.log('发布通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('发布通知API请求错误:', error);
        throw error;
      });
  },
  // 编辑通知
  updateNotice: (data) => api.put('/api/notice/update', data),
  // 删除通知
  deleteNotice: (id) => api.delete(`/api/notice/delete/${id}`),
  // 撤回通知
  withdrawNotice: (id) => api.post(`/api/notice/withdraw/${id}`),
  // 辅导员端院级通知管理接口
  // 发布院级通知
  publishCollegeNotice: (data) => {
    console.log('发布院级通知，数据:', data);
    return api.post('/api/college/notice/college/publish', data)
      .then(response => {
        console.log('发布院级通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('发布院级通知API请求错误:', error);
        throw error;
      });
  },
  // 编辑院级通知
  editCollegeNotice: (id, data) => {
    console.log('编辑院级通知，id:', id, '数据:', data);
    return api.put(`/api/college/notice/college/edit/${id}`, data)
      .then(response => {
        console.log('编辑院级通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('编辑院级通知API请求错误:', error);
        throw error;
      });
  },
  // 删除院级通知
  deleteCollegeNotice: (id) => {
    console.log('删除院级通知，id:', id);
    return api.delete(`/api/college/notice/college/delete/${id}`)
      .then(response => {
        console.log('删除院级通知API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('删除院级通知API请求错误:', error);
        throw error;
      });
  },
  // 获取院级通知列表
  getCollegeNoticeList: (params) => {
    console.log('获取院级通知列表，参数:', params);
    return api.get('/api/college/notice/college/list', { params })
      .then(response => {
        console.log('获取院级通知列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取院级通知列表API请求错误:', error);
        // 如果是500错误，返回空列表，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空通知列表');
          return {
            code: 200,
            msg: 'success',
            data: {
              records: [],
              total: 0,
              size: params?.size || 10,
              current: params?.page || 1,
              pages: 0
            }
          };
        }
        throw error;
      });
  }
}

// Excel导入相关 API
export const excelAPI = {
  // 导入Excel文件
  importExcel: (file, importType, activityId) => {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('importType', importType)
    if (activityId) {
      formData.append('activityId', activityId)
    }
    return api.post('/api/excel/import', formData)
      .then(response => {
        console.log('导入Excel API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('导入Excel API请求错误:', error);
        throw error;
      });
  },
  // 验证Excel文件
  validateExcel: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/api/excel/validate', formData)
      .then(response => {
        console.log('验证Excel API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('验证Excel API请求错误:', error);
        throw error;
      });
  },
  // 解析Excel文件并返回预览数据（不入库）
  parseExcelPreview: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/api/excel/parse', formData)
      .then(response => {
        console.log('解析Excel预览 API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('解析Excel预览 API请求错误:', error);
        throw error;
      });
  }
}

// 管理员相关 API
export const adminAPI = {
  // 获取用户列表
  getUserList: () => {
    console.log('获取用户列表');
    return api.get('/api/user/list')
      .then(response => {
        console.log('获取用户列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取用户列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空用户列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取学院列表
  getCollegeList: () => {
    console.log('获取学院列表');
    return api.get('/api/college/list')
      .then(response => {
        console.log('获取学院列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学院列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空学院列表');
          return {
            code: 200,
            msg: 'success',
            data: []
          };
        }
        throw error;
      });
  },
  // 获取学分统计
  getCreditStatistics: () => api.get('/api/credit-application/school'),
  // 获取学生列表
  getStudentList: (params) => {
    console.log('获取学生列表，参数:', params);
    return api.get('/api/student/list', { params })
      .then(response => {
        console.log('获取学生列表API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学生列表API请求错误:', error);
        // 如果是500错误，返回空数组，避免页面空白
        if (error.response && error.response.status === 500) {
          console.log('后端返回500错误，返回空学生列表');
          return {
            code: 200,
            msg: 'success',
            data: {
              rows: [],
              total: 0
            }
          };
        }
        throw error;
      });
  },
  // 添加学生
  addStudent: (data) => {
    console.log('添加学生，数据:', data);
    return api.post('/api/student/save', data)
      .then(response => {
        console.log('添加学生API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('添加学生API请求错误:', error);
        throw error;
      });
  },
  // 编辑学生
  updateStudent: (data) => {
    console.log('编辑学生，数据:', data);
    return api.put('/api/student/update', data)
      .then(response => {
        console.log('编辑学生API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('编辑学生API请求错误:', error);
        throw error;
      });
  },
  // 删除学生
  deleteStudent: (studentId) => {
    console.log('删除学生，studentId:', studentId);
    return api.delete(`/api/student/delete/${studentId}`)
      .then(response => {
        console.log('删除学生API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('删除学生API请求错误:', error);
        throw error;
      });
  },
  // 搜索学生
  searchStudents: (keyword) => {
    console.log('搜索学生，keyword:', keyword);
    return api.get(`/api/student/admin/search?keyword=${keyword}`)
      .then(response => {
        console.log('搜索学生API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('搜索学生API请求错误:', error);
        throw error;
      });
  },
  // 按学院获取学生
  getStudentsByCollege: (collegeId) => {
    console.log('按学院获取学生，collegeId:', collegeId);
    return api.get(`/api/student/college/${collegeId}`)
      .then(response => {
        console.log('按学院获取学生API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('按学院获取学生API请求错误:', error);
        throw error;
      });
  },
  // 按班级分组获取学生
  getStudentsByClassGroup: (collegeId) => {
    console.log('按班级分组获取学生，collegeId:', collegeId);
    return api.get(`/api/student/college/${collegeId}/class-group`)
      .then(response => {
        console.log('按班级分组获取学生API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('按班级分组获取学生API请求错误:', error);
        throw error;
      });
  },
  // 获取学院所有班级
  getCollegeClasses: (collegeId) => {
    console.log('获取学院所有班级，collegeId:', collegeId);
    return api.get(`/api/student/college/${collegeId}/classes`)
      .then(response => {
        console.log('获取学院所有班级API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学院所有班级API请求错误:', error);
        throw error;
      });
  },
  // 获取所有学院达标率
  getAllCollegesPassRate: () => {
    console.log('获取所有学院达标率');
    return api.get('/api/credit/all-colleges-pass-rate')
      .then(response => {
        console.log('获取所有学院达标率API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取所有学院达标率API请求错误:', error);
        throw error;
      });
  },
  // 获取某学院的学分种类占比（用于饼图）
  getCollegeCreditTypeDistribution: (collegeId) => {
    console.log('获取学院学分种类占比，collegeId:', collegeId);
    return api.get(`/api/credit/college/${collegeId}/credit-type-distribution`)
      .then(response => {
        console.log('获取学院学分种类占比API响应:', response);
        return response;
      })
      .catch(error => {
        console.error('获取学院学分种类占比API请求错误:', error);
        throw error;
      });
  }
}

export default api