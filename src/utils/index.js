// 日期格式化函数
export const formatDate = (date) => {
  if (!date || date === 'null' || date === 'undefined') return ''
  const d = new Date(date)
  if (isNaN(d.getTime())) return ''
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hours = String(d.getHours()).padStart(2, '0')
  const minutes = String(d.getMinutes()).padStart(2, '0')
  const seconds = String(d.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

// 审核状态转换
export const auditStatusMap = {
  0: '待审核',
  1: '审核中',
  2: '通过',
  3: '驳回'
}

// 审核级别映射
export const auditLevelMap = {
  1: '学院',
  2: '学校'
}

// 状态映射
export const statusMap = {
  0: '进行中',
  1: '完成',
  2: '终止'
}

// 状态判断逻辑
export const getStatusText = (auditStatus, auditLevel, status, activityId) => {
  // 以auditStatus为主要状态，auditLevel为审核级别
  if (auditStatus === 0) {
    return '待审核';
  } else if (auditStatus === 1) {
    // 审核中状态，区分等级
    return auditLevel === 1 ? '审核中（学院）' : '审核中（学校）';
  } else if (auditStatus === 2) {
    return activityId ? '免审通过' : '已通过';
  } else if (auditStatus === 3) {
    return '已驳回';
  }
  return '未知状态';
}

// 获取状态类型
export const getStatusType = (auditStatus, auditLevel, status) => {
  // 以auditStatus为主要状态
  if (auditStatus === 0) {
    return 'info';
  } else if (auditStatus === 1) {
    return 'info';
  } else if (auditStatus === 2) {
    return 'success';
  } else if (auditStatus === 3) {
    return 'danger';
  }
  return 'info';
}

// 活动类型转换
export const activityTypeMap = {
  1: '科技竞赛',
  2: '学术论文',
  3: '实践活动',
  4: '志愿服务',
  5: '其他'
}

// 角色类型转换
export const roleTypeMap = {
  1: '学生',
  2: '辅导员',
  3: '管理员'
}

// 错误处理函数
export const handleError = (error) => {
  const errorMessage = error.response?.data?.msg || error.message || '未知错误'
  console.error('Error:', errorMessage)
  return errorMessage
}

// 文件类型验证
export const validateFile = (file) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf', '.doc', '.docx']
  const maxSize = 10 * 1024 * 1024 // 10MB
  
  if (!file) {
    return { valid: false, message: '请选择文件' }
  }
  
  if (file.size > maxSize) {
    return { valid: false, message: '文件大小不能超过10MB' }
  }
  
  if (!allowedTypes.includes(file.type)) {
    const extension = file.name.substring(file.name.lastIndexOf('.'))
    if (!allowedExtensions.includes(extension.toLowerCase())) {
      return { valid: false, message: '文件格式不支持，只支持jpg、jpeg、png、pdf、doc、docx' }
    }
  }
  
  return { valid: true, message: '' }
}

// 学分验证
export const validateCredit = (credit) => {
  if (!credit || isNaN(credit)) {
    return { valid: false, message: '请输入有效的学分' }
  }
  
  const value = parseFloat(credit)
  if (value < 0.1) {
    return { valid: false, message: '申请学分最少为0.1' }
  }
  
  if (Math.abs(Math.round(value * 10) / 10 - value) > 0.0001) {
    return { valid: false, message: '申请学分必须为0.1的倍数' }
  }
  
  return { valid: true, message: '' }
}

// 空值处理函数
export const handleNull = (value, defaultValue = '-') => {
  if (value === null || value === undefined || value === 'null' || value === 'undefined' || value === '') {
    return defaultValue
  }
  return value
}