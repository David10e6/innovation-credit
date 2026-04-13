<template>
  <div class="notice-management">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">校级通知管理</span>
          <el-button type="primary" @click="openAddNoticeDialog">发布通知</el-button>
        </div>
      </template>
      
      <!-- 搜索和筛选 -->
      <div class="search-section">
        <el-form :inline="true" :model="searchForm" class="mb-4">
          <el-form-item label="标题">
            <el-input v-model="searchForm.title" placeholder="请输入通知标题" style="width: 300px;"></el-input>
          </el-form-item>
          <el-form-item label="发布时间">
            <el-date-picker
              v-model="searchForm.dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              style="width: 300px;"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>
      
      <!-- 通知列表 -->
      <el-table :data="notices" style="width: 100%" border v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="content" label="活动详情" show-overflow-tooltip />
        <el-table-column prop="publishTime" label="发布时间" width="180" />
        <el-table-column prop="endTime" label="截止时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEditNoticeDialog(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row.id)">删除</el-button>
            <el-button size="small" @click="viewNoticeDetail(row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination" style="margin-top: 20px;">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
    
    <!-- 发布/编辑通知弹窗 -->
    <el-dialog
      :title="dialogTitle"
      v-model="dialogVisible"
      width="800px"
    >
      <el-form :model="noticeForm" :rules="rules" ref="noticeFormRef" label-width="100px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="noticeForm.title" placeholder="请输入通知标题" />
        </el-form-item>
        <el-form-item label="活动详情" prop="content">
          <el-input
            v-model="noticeForm.content"
            type="textarea"
            :rows="5"
            placeholder="请输入活动详情"
          />
        </el-form-item>
        <el-form-item label="参与范围" prop="scope">
          <el-select v-model="noticeForm.scope" placeholder="请选择参与范围">
            <el-option label="全校" value="all" />
          </el-select>
        </el-form-item>
        <el-form-item label="发布时间" prop="publishTime">
          <el-date-picker
            v-model="noticeForm.publishTime"
            type="datetime"
            placeholder="请选择发布时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="截止时间" prop="endTime">
          <el-date-picker
            v-model="noticeForm.endTime"
            type="datetime"
            placeholder="请选择截止时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="附件">
          <el-upload
            class="upload-demo"
            action="#"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :file-list="fileList"
            :auto-upload="false"
          >
            <el-button type="primary">点击上传</el-button>
            <template #tip>
              <div class="el-upload__tip">
                只能上传jpg/png文件，且不超过500kb
              </div>
            </template>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitNotice" :loading="submitLoading">
            {{ dialogTitle === '发布通知' ? '发布' : '保存' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { noticeAPI } from '../../api'

// 搜索表单
const searchForm = reactive({
  title: '',
  dateRange: []
})

// 通知列表数据
const notices = ref([])

// 分页数据
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 加载状态
const loading = ref(false)
const submitLoading = ref(false)

// 弹窗数据
const dialogVisible = ref(false)
const dialogTitle = ref('发布通知')
const noticeFormRef = ref(null)
const noticeForm = reactive({
  title: '',
  content: '',
  scope: 'all',
  publishTime: new Date(),
  endTime: ''
})

// 表单验证规则
const rules = {
  title: [{ required: true, message: '请输入通知标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入活动详情', trigger: 'blur' }],
  publishTime: [{ required: true, message: '请选择发布时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择截止时间', trigger: 'change' }]
}

// 文件上传
const fileList = ref([])

// 打开添加通知弹窗
const openAddNoticeDialog = () => {
  dialogTitle.value = '发布通知'
  Object.assign(noticeForm, {
    id: '',
    title: '',
    content: '',
    scope: 'all',
    publishTime: new Date(),
    endTime: ''
  })
  fileList.value = []
  dialogVisible.value = true
}

// 打开编辑通知弹窗
const openEditNoticeDialog = (row) => {
  dialogTitle.value = '编辑通知'
  Object.assign(noticeForm, {
    id: row.id,
    title: row.title,
    content: row.content,
    scope: row.scope,
    publishTime: new Date(row.publishTime),
    endTime: new Date(row.endTime)
  })
  fileList.value = []
  dialogVisible.value = true
}

// 获取通知列表
const getNotices = async () => {
  try {
    loading.value = true
    const response = await noticeAPI.getAdminNotices(currentPage.value, pageSize.value)
    
    if (response.code === 200 && response.data) {
      notices.value = response.data.records || response.data.rows || []
      total.value = response.data.total || 0
    }
  } catch (error) {
    console.error('获取通知列表失败:', error)
    ElMessage.error('获取通知列表失败')
  } finally {
    loading.value = false
  }
}

// 提交通知
const submitNotice = async () => {
  if (!noticeFormRef.value) return
  
  try {
    await noticeFormRef.value.validate()
    submitLoading.value = true
    
    const noticeData = {
      title: noticeForm.title,
      content: noticeForm.content,
      scope: noticeForm.scope,
      publishTime: noticeForm.publishTime,
      endTime: noticeForm.endTime,
      type: 'school' // 标记为校级通知
    }
    
    let response
    if (noticeForm.id) {
      // 编辑操作
      response = await noticeAPI.updateNotice(noticeData)
    } else {
      // 新增操作
      response = await noticeAPI.publishNotice(noticeData)
    }
    
    if (response.code === 200) {
      ElMessage.success(noticeForm.id ? '通知编辑成功' : '通知发布成功')
      dialogVisible.value = false
      // 重新获取通知列表
      await getNotices()
    } else {
      ElMessage.error(response.msg || '操作失败')
    }
  } catch (error) {
    console.error('提交通知失败:', error)
    ElMessage.error('操作失败，请重试')
  } finally {
    submitLoading.value = false
  }
}

// 删除通知
const handleDelete = (id) => {
  ElMessageBox.confirm('是否确认删除该通知？删除后不可恢复', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await noticeAPI.deleteNotice(id)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        // 重新获取通知列表
        await getNotices()
      } else {
        ElMessage.error(response.msg || '删除失败')
      }
    } catch (error) {
      console.error('删除通知失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }).catch(() => {
    // 取消删除
  })
}

// 查看通知详情
const viewNoticeDetail = (row) => {
  // 这里可以实现查看详情的逻辑
  console.log('查看通知详情:', row)
  ElMessage.info('查看通知详情功能开发中')
}

// 撤回通知
const withdrawNotice = (id) => {
  ElMessageBox.confirm('是否确认撤回该通知？', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await noticeAPI.withdrawNotice(id)
      if (response.code === 200) {
        ElMessage.success('通知已撤回')
        // 重新获取通知列表
        await getNotices()
      } else {
        ElMessage.error(response.msg || '撤回失败')
      }
    } catch (error) {
      console.error('撤回通知失败:', error)
      ElMessage.error('撤回失败，请重试')
    }
  }).catch(() => {
    // 取消撤回
  })
}

// 搜索
const handleSearch = async () => {
  try {
    loading.value = true
    // 这里可以添加搜索参数
    const response = await noticeAPI.getAdminNotices(currentPage.value, pageSize.value)
    
    if (response.code === 200 && response.data) {
      notices.value = response.data.records || response.data.rows || []
      total.value = response.data.total || 0
    }
  } catch (error) {
    console.error('搜索通知失败:', error)
    ElMessage.error('搜索失败，请重试')
  } finally {
    loading.value = false
  }
}

// 重置搜索
const resetSearch = () => {
  Object.assign(searchForm, {
    title: '',
    dateRange: []
  })
  getNotices()
}

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size
  getNotices()
}

const handleCurrentChange = (current) => {
  currentPage.value = current
  getNotices()
}

// 文件上传处理
const handlePreview = (file) => {
  console.log('预览文件:', file)
}

const handleRemove = (file, fileList) => {
  console.log('移除文件:', file, fileList)
}

// 页面加载时获取通知列表
onMounted(() => {
  getNotices()
})
</script>

<style scoped>
.notice-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-section {
  margin-bottom: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>