<template>
  <div class="score-rules">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span style="font-size: 16px; font-weight: bold;">创新活动评分规则</span>
        </div>
      </template>
      
      <!-- 团队活动须知 -->
      <div class="team-notice" style="margin-bottom: 20px; padding: 15px; background-color: #f0f9eb; border-radius: 4px; border-left: 4px solid #67c23a;">
        <p style="margin: 0; color: #67c23a; font-weight: 500;">团队活动须知：以团队形式参加活动的学分规则，团队前三名获得该级别学分，第四名和第五名减0.1学分，后续名次减0.2学分。团队内名次的划分按照证明材料中团队名单的人员次序</p>
      </div>
      
      <div v-if="rules.length > 0" class="rules-content">
        <el-collapse v-model="activeNames">
          <el-collapse-item
            v-for="rule in rules"
            :key="rule.id"
            :title="rule.title"
            :name="rule.id"
          >
            <div class="rule-detail">
              <div v-for="(item, index) in rule.items" :key="index" class="rule-item">
                <h4 style="margin: 10px 0;">{{ item.name }}</h4>
                <el-table :data="item.details" style="width: 100%" border>
                  <el-table-column prop="level" label="等级" width="150" />
                  <el-table-column prop="description" label="描述" />
                  <el-table-column prop="credit" label="学分" width="100" />
                </el-table>
              </div>
            </div>
          </el-collapse-item>
        </el-collapse>
      </div>
      <el-empty v-else description="暂无评分规则" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

// 评分规则数据
const rules = ref([])
// 激活的折叠面板
const activeNames = ref(['1'])

// 评分规则数据
const rulesData = [
  {
    id: '1',
    title: '学科竞赛',
    items: [
      {
        name: '院级',
        details: [
          { level: '参与奖', description: '院级学科竞赛参与即可获得，不设获奖要求', credit: 0.2 },
          { level: '优秀奖', description: '院级学科竞赛优秀奖', credit: 0.4 },
          { level: '三等奖', description: '院级学科竞赛三等奖', credit: 0.6 },
          { level: '二等奖', description: '院级学科竞赛二等奖', credit: 0.8 },
          { level: '一等奖', description: '院级学科竞赛一等奖', credit: 1.0 }
        ]
      },
      {
        name: '校级',
        details: [
          { level: '参与奖', description: '校级学科竞赛参与即可获得，不设获奖要求', credit: 0.8 },
          { level: '优秀奖', description: '校级学科竞赛优秀奖', credit: 1.5 },
          { level: '三等奖', description: '校级学科竞赛三等奖', credit: 2.5 },
          { level: '二等奖', description: '校级学科竞赛二等奖', credit: 3.0 },
          { level: '一等奖', description: '校级学科竞赛一等奖，达到创新学分合格线（4.0分）', credit: 4.0 }
        ]
      },
      {
        name: '市级',
        details: [
          { level: '参与奖', description: '市级学科竞赛参与即可获得，不设获奖要求', credit: 1.5 },
          { level: '优秀奖', description: '市级学科竞赛优秀奖', credit: 2.0 },
          { level: '三等奖', description: '市级学科竞赛三等奖', credit: 3.0 },
          { level: '二等奖', description: '市级学科竞赛二等奖', credit: 3.5 },
          { level: '一等奖', description: '市级学科竞赛一等奖', credit: 4.5 }
        ]
      },
      {
        name: '省级',
        details: [
          { level: '参与奖', description: '省级学科竞赛参与即可获得，不设获奖要求', credit: 2.0 },
          { level: '优秀奖', description: '省级学科竞赛优秀奖', credit: 2.5 },
          { level: '三等奖', description: '省级学科竞赛三等奖', credit: 3.5 },
          { level: '二等奖', description: '省级学科竞赛二等奖，达到创新学分合格线（4.0分）', credit: 4.0 },
          { level: '一等奖', description: '省级学科竞赛一等奖', credit: 5.0 }
        ]
      },
      {
        name: '国家级',
        details: [
          { level: '参与奖', description: '国家级学科竞赛参与即可获得，不设获奖要求', credit: 2.5 },
          { level: '优秀奖', description: '国家级学科竞赛优秀奖', credit: 3.0 },
          { level: '三等奖', description: '国家级学科竞赛三等奖，达到创新学分合格线（4.0分）', credit: 4.0 },
          { level: '二等奖', description: '国家级学科竞赛二等奖', credit: 4.5 },
          { level: '一等奖', description: '国家级学科竞赛一等奖，年度最高可认定6.0分', credit: 5.5 }
        ]
      }
    ]
  },
  {
    id: '2',
    title: '科研创新',
    items: [
      {
        name: '院级',
        details: [
          { level: '参与奖', description: '院级科研立项/专利申报参与奖', credit: 0.2 },
          { level: '优秀奖', description: '院级科研立项/专利申报优秀奖', credit: 0.6 },
          { level: '三等奖', description: '院级科研立项/专利申报三等奖', credit: 0.9 },
          { level: '二等奖', description: '院级科研立项/专利申报二等奖', credit: 1.2 },
          { level: '一等奖', description: '院级科研立项/专利申报一等奖', credit: 1.5 }
        ]
      },
      {
        name: '校级',
        details: [
          { level: '参与奖', description: '校级科研立项/专利申报参与奖', credit: 1.2 },
          { level: '优秀奖', description: '校级科研立项/专利申报优秀奖', credit: 2.3 },
          { level: '三等奖', description: '校级科研立项/专利申报三等奖', credit: 3.8 },
          { level: '二等奖', description: '校级科研立项/专利申报二等奖', credit: 4.5 },
          { level: '一等奖', description: '校级科研创新一等奖', credit: 6.0 }
        ]
      },
      {
        name: '市级',
        details: [
          { level: '参与奖', description: '市级科研立项/专利申报参与奖', credit: 2.3 },
          { level: '优秀奖', description: '市级科研立项/专利申报优秀奖', credit: 3.0 },
          { level: '三等奖', description: '市级科研立项/专利申报三等奖', credit: 4.5 },
          { level: '二等奖', description: '市级科研立项/专利申报二等奖', credit: 5.3 },
          { level: '一等奖', description: '市级科研创新一等奖', credit: 6.8 }
        ]
      },
      {
        name: '省级',
        details: [
          { level: '参与奖', description: '省级科研立项/专利申报参与奖', credit: 3.0 },
          { level: '优秀奖', description: '省级科研立项/专利申报优秀奖', credit: 3.8 },
          { level: '三等奖', description: '省级科研立项/专利申报三等奖', credit: 5.3 },
          { level: '二等奖', description: '省级科研立项/专利申报二等奖', credit: 6.0 },
          { level: '一等奖', description: '省级科研创新一等奖', credit: 7.5 }
        ]
      },
      {
        name: '国家级',
        details: [
          { level: '参与奖', description: '国家级科研立项/专利申报参与奖', credit: 3.8 },
          { level: '优秀奖', description: '国家级科研立项/专利申报优秀奖', credit: 4.5 },
          { level: '三等奖', description: '国家级科研立项/专利申报三等奖', credit: 6.0 },
          { level: '二等奖', description: '国家级科研立项/专利申报二等奖', credit: 6.8 },
          { level: '一等奖', description: '国家级科研创新一等奖', credit: 8.3 }
        ]
      }
    ]
  },
  {
    id: '3',
    title: '学术论文',
    items: [
      {
        name: '院级',
        details: [
          { level: '参与奖', description: '院级论文征集参与奖', credit: 0.2 },
          { level: '优秀奖', description: '院级论文征集优秀奖', credit: 0.6 },
          { level: '三等奖', description: '院级论文征集三等奖', credit: 0.9 },
          { level: '二等奖', description: '院级论文征集二等奖', credit: 1.2 },
          { level: '一等奖', description: '院级论文征集一等奖', credit: 1.5 }
        ]
      },
      {
        name: '校级',
        details: [
          { level: '参与奖', description: '校级论文征集参与奖', credit: 1.2 },
          { level: '优秀奖', description: '校级论文征集优秀奖', credit: 2.3 },
          { level: '三等奖', description: '校级论文征集三等奖', credit: 3.8 },
          { level: '二等奖', description: '校级论文征集二等奖', credit: 4.5 },
          { level: '一等奖', description: '校级论文征集一等奖', credit: 6.0 }
        ]
      },
      {
        name: '市级',
        details: [
          { level: '参与奖', description: '市级期刊论文投稿参与奖', credit: 2.3 },
          { level: '优秀奖', description: '市级期刊论文投稿优秀奖', credit: 3.0 },
          { level: '三等奖', description: '市级期刊论文投稿三等奖', credit: 4.5 },
          { level: '二等奖', description: '市级期刊论文投稿二等奖', credit: 5.3 },
          { level: '一等奖', description: '市级期刊论文投稿一等奖', credit: 6.8 }
        ]
      },
      {
        name: '省级',
        details: [
          { level: '参与奖', description: '省级期刊论文投稿参与奖', credit: 3.0 },
          { level: '优秀奖', description: '省级期刊论文投稿优秀奖', credit: 3.8 },
          { level: '三等奖', description: '省级期刊论文投稿三等奖', credit: 5.3 },
          { level: '二等奖', description: '省级期刊论文投稿二等奖', credit: 6.0 },
          { level: '一等奖', description: '省级期刊论文投稿一等奖', credit: 7.5 }
        ]
      },
      {
        name: '国家级',
        details: [
          { level: '参与奖', description: '核心期刊论文投稿参与奖', credit: 3.8 },
          { level: '优秀奖', description: '核心期刊论文投稿优秀奖', credit: 4.5 },
          { level: '三等奖', description: '核心期刊论文投稿三等奖', credit: 6.0 },
          { level: '二等奖', description: '核心期刊论文投稿二等奖', credit: 6.8 },
          { level: '一等奖', description: '核心期刊论文投稿一等奖', credit: 8.3 }
        ]
      }
    ]
  },
  {
    id: '4',
    title: '社会实践',
    items: [
      {
        name: '院级',
        details: [
          { level: '参与奖', description: '院级社会实践参与奖', credit: 0.1 },
          { level: '优秀奖', description: '院级社会实践优秀奖', credit: 0.3 },
          { level: '三等奖', description: '院级社会实践三等奖', credit: 0.4 },
          { level: '二等奖', description: '院级社会实践二等奖', credit: 0.6 },
          { level: '一等奖', description: '院级社会实践一等奖', credit: 0.7 }
        ]
      },
      {
        name: '校级',
        details: [
          { level: '参与奖', description: '校级社会实践参与奖', credit: 0.6 },
          { level: '优秀奖', description: '校级社会实践优秀奖', credit: 1.1 },
          { level: '三等奖', description: '校级社会实践三等奖', credit: 1.8 },
          { level: '二等奖', description: '校级社会实践二等奖', credit: 2.1 },
          { level: '一等奖', description: '校级社会实践一等奖', credit: 2.8 }
        ]
      },
      {
        name: '市级',
        details: [
          { level: '参与奖', description: '市级社会实践参与奖', credit: 1.1 },
          { level: '优秀奖', description: '市级社会实践优秀奖', credit: 1.4 },
          { level: '三等奖', description: '市级社会实践三等奖', credit: 2.1 },
          { level: '二等奖', description: '市级社会实践二等奖', credit: 2.5 },
          { level: '一等奖', description: '市级社会实践一等奖', credit: 3.2 }
        ]
      },
      {
        name: '省级',
        details: [
          { level: '参与奖', description: '省级社会实践参与奖', credit: 1.4 },
          { level: '优秀奖', description: '省级社会实践优秀奖', credit: 1.8 },
          { level: '三等奖', description: '省级社会实践三等奖', credit: 2.5 },
          { level: '二等奖', description: '省级社会实践二等奖', credit: 2.8 },
          { level: '一等奖', description: '省级社会实践一等奖', credit: 3.5 }
        ]
      },
      {
        name: '国家级',
        details: [
          { level: '参与奖', description: '国家级社会实践参与奖', credit: 1.8 },
          { level: '优秀奖', description: '国家级社会实践优秀奖', credit: 2.1 },
          { level: '三等奖', description: '国家级社会实践三等奖', credit: 2.8 },
          { level: '二等奖', description: '国家级社会实践二等奖', credit: 3.2 },
          { level: '一等奖', description: '国家级社会实践一等奖', credit: 3.9 }
        ]
      }
    ]
  },
  {
    id: '5',
    title: '技能证书',
    items: [
      {
        name: '院级',
        details: [
          { level: '参与奖', description: '院级技能认证参与奖', credit: 0.1 },
          { level: '优秀奖', description: '院级技能认证优秀奖', credit: 0.2 },
          { level: '三等奖', description: '院级技能认证三等奖', credit: 0.4 },
          { level: '二等奖', description: '院级技能认证二等奖', credit: 0.5 },
          { level: '一等奖', description: '院级技能认证一等奖', credit: 0.6 }
        ]
      },
      {
        name: '校级',
        details: [
          { level: '参与奖', description: '校级技能证书参与奖', credit: 0.5 },
          { level: '优秀奖', description: '校级技能证书优秀奖', credit: 0.9 },
          { level: '三等奖', description: '校级技能证书三等奖', credit: 1.5 },
          { level: '二等奖', description: '校级技能证书二等奖', credit: 1.8 },
          { level: '一等奖', description: '校级技能证书一等奖', credit: 2.4 }
        ]
      },
      {
        name: '市级',
        details: [
          { level: '参与奖', description: '市级技能证书参与奖', credit: 0.9 },
          { level: '优秀奖', description: '市级技能证书优秀奖', credit: 1.2 },
          { level: '三等奖', description: '市级技能证书三等奖', credit: 1.8 },
          { level: '二等奖', description: '市级技能证书二等奖', credit: 2.1 },
          { level: '一等奖', description: '市级技能证书一等奖', credit: 2.7 }
        ]
      },
      {
        name: '省级',
        details: [
          { level: '参与奖', description: '省级技能证书参与奖', credit: 1.2 },
          { level: '优秀奖', description: '省级技能证书优秀奖', credit: 1.5 },
          { level: '三等奖', description: '省级技能证书三等奖', credit: 2.1 },
          { level: '二等奖', description: '省级技能证书二等奖', credit: 2.4 },
          { level: '一等奖', description: '省级技能证书一等奖', credit: 3.0 }
        ]
      },
      {
        name: '国家级',
        details: [
          { level: '参与奖', description: '国家级技能证书参与奖', credit: 1.5 },
          { level: '优秀奖', description: '国家级技能证书优秀奖', credit: 1.8 },
          { level: '三等奖', description: '国家级技能证书三等奖', credit: 2.4 },
          { level: '二等奖', description: '国家级技能证书二等奖', credit: 2.7 },
          { level: '一等奖', description: '国家级技能证书一等奖', credit: 3.3 }
        ]
      }
    ]
  },
  {
    id: '6',
    title: '其他',
    items: [
      {
        name: '院级',
        details: [
          { level: '参与奖', description: '未明确归类的其他活动参与奖', credit: 0.2 },
          { level: '优秀奖', description: '未明确归类的其他活动优秀奖', credit: 0.2 },
          { level: '三等奖', description: '未明确归类的其他活动三等奖', credit: 0.3 },
          { level: '二等奖', description: '未明确归类的其他活动二等奖', credit: 0.4 },
          { level: '一等奖', description: '未明确归类的其他活动一等奖', credit: 0.5 }
        ]
      },
      {
        name: '校级',
        details: [
          { level: '参与奖', description: '未明确归类的其他活动参与奖', credit: 0.4 },
          { level: '优秀奖', description: '未明确归类的其他活动优秀奖', credit: 0.8 },
          { level: '三等奖', description: '未明确归类的其他活动三等奖', credit: 1.3 },
          { level: '二等奖', description: '未明确归类的其他活动二等奖', credit: 1.5 },
          { level: '一等奖', description: '未明确归类的其他活动一等奖', credit: 2.0 }
        ]
      },
      {
        name: '市级',
        details: [
          { level: '参与奖', description: '未明确归类的其他活动参与奖', credit: 0.8 },
          { level: '优秀奖', description: '未明确归类的其他活动优秀奖', credit: 1.0 },
          { level: '三等奖', description: '未明确归类的其他活动三等奖', credit: 1.5 },
          { level: '二等奖', description: '未明确归类的其他活动二等奖', credit: 1.8 },
          { level: '一等奖', description: '未明确归类的其他活动一等奖', credit: 2.3 }
        ]
      },
      {
        name: '省级',
        details: [
          { level: '参与奖', description: '未明确归类的其他活动参与奖', credit: 1.0 },
          { level: '优秀奖', description: '未明确归类的其他活动优秀奖', credit: 1.3 },
          { level: '三等奖', description: '未明确归类的其他活动三等奖', credit: 1.8 },
          { level: '二等奖', description: '未明确归类的其他活动二等奖', credit: 2.0 },
          { level: '一等奖', description: '未明确归类的其他活动一等奖', credit: 2.5 }
        ]
      },
      {
        name: '国家级',
        details: [
          { level: '参与奖', description: '未明确归类的其他活动参与奖', credit: 1.3 },
          { level: '优秀奖', description: '未明确归类的其他活动优秀奖', credit: 1.5 },
          { level: '三等奖', description: '未明确归类的其他活动三等奖', credit: 2.0 },
          { level: '二等奖', description: '未明确归类的其他活动二等奖', credit: 2.3 },
          { level: '一等奖', description: '未明确归类的其他活动一等奖', credit: 2.8 }
        ]
      }
    ]
  }
]

// 获取评分规则数据
const fetchRules = async () => {
  try {
    // 这里应该调用API获取评分规则数据
    console.log('获取评分规则数据')
    // 暂时使用静态数据
    rules.value = rulesData
  } catch (error) {
    console.error('获取评分规则失败:', error)
    ElMessage.error('获取评分规则失败，请重试')
  }
}

onMounted(() => {
  fetchRules()
})
</script>

<style scoped>
.score-rules {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.rules-content {
  margin-top: 20px;
}

.rule-detail {
  padding: 10px 0;
}

.rule-item {
  margin-bottom: 20px;
}
</style>