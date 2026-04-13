<template>
  <div class="credit-statistics">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学分统计</span>
          <el-button type="primary" @click="goBack">返回</el-button>
        </div>
      </template>
      
      <div class="college-pass-rate-section">
        <h3>各学院达标率</h3>
        <el-table :data="collegePassRates" border stripe v-loading="loading">
          <el-table-column prop="collegeName" label="学院" />
          <el-table-column prop="totalCount" label="学生总数" />
          <el-table-column prop="passCount" label="达标人数" />
          <el-table-column prop="passRate" label="达标率">
            <template #default="{ row }">
              <el-tag type="success">{{ row.passRate }}%</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </div>
      
      <div class="credit-distribution-section">
        <h3>学院学分种类分布</h3>
        <el-select v-model="selectedCollegeId" placeholder="请选择学院" @change="onCollegeChange" style="margin-bottom: 20px;">
          <el-option
            v-for="college in collegePassRates"
            :key="college.collegeId"
            :label="college.collegeName"
            :value="college.collegeId"
          />
        </el-select>
        
        <div ref="pieChartRef" style="width: 100%; height: 400px;"></div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { adminAPI } from '../../api'

const router = useRouter()
const loading = ref(false)
const collegePassRates = ref([])
const selectedCollegeId = ref(null)
const pieChartRef = ref(null)
let chart = null

const loadCollegePassRates = async () => {
  loading.value = true
  try {
    const response = await adminAPI.getAllCollegesPassRate()
    console.log('后端返回的学院达标率数据:', response)
    const rawData = response.data || []
    collegePassRates.value = rawData.map(item => ({
      collegeId: item.collegeId || item.id,
      collegeName: item.collegeName || item.name,
      totalCount: item.totalCount,
      passCount: item.passCount,
      passRate: item.passRate
    }))
    console.log('处理后的学院列表:', collegePassRates.value)
    if (collegePassRates.value.length > 0) {
      selectedCollegeId.value = collegePassRates.value[0].collegeId
      await loadPieChart(selectedCollegeId.value)
    }
  } catch (error) {
    console.error('获取学院达标率失败:', error)
    ElMessage.error('获取学院达标率失败')
  } finally {
    loading.value = false
  }
}

const onCollegeChange = async (collegeId) => {
  if (collegeId) {
    await loadPieChart(collegeId)
  }
}

const loadPieChart = async (collegeId) => {
  try {
    const response = await adminAPI.getCollegeCreditTypeDistribution(collegeId)
    const data = response.data || []
    
    if (!chart) {
      chart = echarts.init(pieChartRef.value)
    }
    
    chart.setOption({
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        left: 'left'
      },
      series: [{
        name: '学分种类',
        type: 'pie',
        radius: '50%',
        data: data.map(item => ({
          name: item.creditType,
          value: item.totalCredit
        })),
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }]
    })
  } catch (error) {
    console.error('获取学院学分种类分布失败:', error)
    ElMessage.error('获取学院学分种类分布失败')
  }
}

const goBack = () => {
  router.push('/admin')
}

onMounted(() => {
  loadCollegePassRates()
})

onUnmounted(() => {
  if (chart) {
    chart.dispose()
    chart = null
  }
})
</script>

<style scoped>
.credit-statistics {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.college-pass-rate-section {
  margin-bottom: 40px;
}

.college-pass-rate-section h3,
.credit-distribution-section h3 {
  margin-bottom: 20px;
  color: #303133;
}
</style>