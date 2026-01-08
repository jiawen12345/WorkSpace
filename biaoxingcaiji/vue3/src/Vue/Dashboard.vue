<template>
  <div class="container">
    <div class="main-container">
      <AppHeader />
      <div class="main-content">
        <Sidebar />
        <div class="content-area">

          
          <!-- 数据采集页面 -->
          <div class="tab-content" :class="{ active: activeTab === 'data-collection' }">
            <h3 class="section-title">数据采集功能</h3>
            <div class="function-cards">
              <div class="function-card" @click="goToCollectionDetail('crop')">
                <i class="fas fa-seedling"></i>
                <h3>实验监测</h3>
                <p>记录实验状态和表型数据</p>
              </div>
              <div class="function-card" @click="goToCollectionDetail('weather')">
                <i class="fas fa-cloud-sun"></i>
                <h3>环境数据</h3>
                <p>采集生长环境数据</p>
              </div>
              <div class="function-card" @click="goToCollectionDetail('pest')">
                <i class="fas fa-bug"></i>
                <h3>病虫害记录</h3>
                <p>记录病虫害发生情况和防治措施</p>
              </div>
              <div class="image-collection" @click="goToImageCollection">
                <i class="fas fa-camera"></i>
                <h3>图像采集</h3>
                <p>上传图像，用于表型分析</p>
              </div>
            </div>
          </div> 
          
          <!-- 快速采集页面 -->
          <div class="tab-content" :class="{ active: activeTab === 'quick-collection' }">
            <h3 class="section-title">快速采集</h3>
            <div class="function-cards">
              <div class="function-card" @click="goToCollectionDetail('quick')">
                <i class="fas fa-bolt"></i>
                <h3>一键采集</h3>
                <p>快速记录基础数据</p>
              </div>
              <div class="function-card" @click="goToCollectionDetail('location')">
                <i class="fas fa-map-marked-alt"></i>
                <h3>位置记录</h3>
                <p>记录采集位置信息</p>
              </div>
              <div class="function-card" @click="goToCollectionDetail('template')">
                <i class="fas fa-clipboard-list"></i>
                <h3>模板采集</h3>
                <p>使用预设模板快速记录</p>
              </div>
              <div class="image-collection" @click="goToImageCollection">
                <i class="fas fa-camera"></i>
                <h3>图像采集</h3>
                <p>上传图像</p>
              </div>
            </div>
          </div>
          
          <!-- 采集历史页面 -->
          <div class="tab-content" :class="{ active: activeTab === 'history' }">
            <h3 class="section-title">采集记录</h3>
            
            <!-- 筛选工具 -->
            <div class="filter-toolbar">
              <div class="filter-group">
                <label class="filter-label">时间范围:</label>
                <select class="filter-select" v-model="timeFilter">
                  <option value="all">全部</option>
                  <option value="today">今日</option>
                  <option value="week">本周</option>
                  <option value="month">本月</option>
                </select>
              </div>
              <div class="filter-group">
                <label class="filter-label">状态:</label>
                <select class="filter-select" v-model="statusFilter">
                  <option value="all">全部</option>
                  <option value="completed">已完成</option>
                  <option value="pending">处理中</option>
                </select>
              </div>
              <button class="filter-reset" @click="resetFilters">重置筛选</button>
            </div>
            
            <div class="data-list">
              <div class="data-item" v-for="item in filteredHistoryData" :key="item.id" @click="viewCollectionDetail(item)">
                <div class="data-info">
                  <h4>{{ item.title }}</h4>
                  <p>{{ item.date }} | {{ item.info }}</p>
                  <div class="data-tags">
                    <span class="data-tag" v-if="item.tags">{{ item.tags }}</span>
                  </div>
                </div>
                <div class="data-status">
                  <span class="status-badge" :class="item.statusClass">{{ item.status }}</span>
                  <div class="data-actions">
                    <button class="action-btn" @click.stop="editCollection(item)" title="编辑">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button class="action-btn" @click.stop="deleteCollection(item)" title="删除">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </div>
              </div>
              
              <!-- 空状态 -->
              <div class="empty-state" v-if="filteredHistoryData.length === 0">
                <i class="fas fa-inbox"></i>
                <p>暂无采集记录</p>
                <button class="btn-primary" @click="goToCollectionDetail('quick')">开始采集</button>
              </div>
            </div>
            
            <!-- 分页 -->
            <div class="pagination" v-if="filteredHistoryData.length > 0">
              <button class="pagination-btn" :disabled="currentPage === 1" @click="prevPage">
                <i class="fas fa-chevron-left"></i> 上一页
              </button>
              <div class="pagination-info">
                第 {{ currentPage }} 页，共 {{ totalPages }} 页
              </div>
              <button class="pagination-btn" :disabled="currentPage === totalPages" @click="nextPage">
                下一页 <i class="fas fa-chevron-right"></i>
              </button>
            </div>
          </div> 
          
        </div> 
      </div> 
    </div> 
  </div> 
</template>


<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../js/app.js'
import { toast } from '../js/toast.js'
import AppHeader from './Header.vue'
import Sidebar from './Sidebar.vue'


export default {
  name: 'Dashboard',
  components: {
    AppHeader,
    Sidebar
  },
  setup() {
    const router = useRouter()
    const appStore = useAppStore()

     const goToCollection = () => {
      router.push('/collection')
    }
    
    const goToFieldSearch = () => {
      router.push('/field-search')
    }

    

    // 本地状态
    const timeFilter = ref('all')
    const statusFilter = ref('all')
    const currentPage = ref(1)
    const itemsPerPage = ref(10)

    // 计算属性
    const activeTab = computed(() => appStore.activeTab)
    const historyData = computed(() => appStore.historyData)

    // 最近采集记录（取前3条）
    const recentCollections = computed(() => {
      return appStore.historyData
        .filter(item => item.status === '已完成')
        .slice(0, 3)
    })

    // 筛选后的历史数据
    const filteredHistoryData = computed(() => {
      let filtered = [...appStore.historyData]

      // 时间筛选
      if (timeFilter.value !== 'all') {
        const now = new Date()
        filtered = filtered.filter(item => {
          const itemDate = new Date(item.date)
          switch (timeFilter.value) {
            case 'today':
              return itemDate.toDateString() === now.toDateString()
            case 'week':
              const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
              return itemDate >= weekAgo
            case 'month':
              const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
              return itemDate >= monthAgo
            default:
              return true
          }
        })
      }

      // 状态筛选
      if (statusFilter.value !== 'all') {
        filtered = filtered.filter(item => {
          if (statusFilter.value === 'completed') {
            return item.status === '已完成'
          } else if (statusFilter.value === 'pending') {
            return item.status === '处理中'
          }
          return true
        })
      }

      // 分页
      const start = (currentPage.value - 1) * itemsPerPage.value
      const end = start + itemsPerPage.value
      return filtered.slice(start, end)
    })

    // 总页数
    const totalPages = computed(() => {
      return Math.ceil(appStore.historyData.length / itemsPerPage.value)
    })

    // 方法
    const goToCollectionDetail = (type) => {
      router.push(`/collection/${type}`)
    }

    const goToImageCollection = () => {
      router.push('/collection/image')
    }

    const viewCollectionDetail = (item) => {
      toast.info(`查看采集记录: ${item.title}`)
      // 这里可以跳转到详情页面
      // router.push(`/collection/detail/${item.id}`)
    }

    const editCollection = (item) => {
      toast.info(`编辑采集记录: ${item.title}`)
      // 编辑逻辑
    }

    const deleteCollection = (item) => {
      if (confirm(`确定要删除采集记录 "${item.title}" 吗？`)) {
        // 这里应该调用 appStore 的删除方法
        toast.success('采集记录已删除')
      }
    }

    const resetFilters = () => {
      timeFilter.value = 'all'
      statusFilter.value = 'all'
      currentPage.value = 1
    }

    const prevPage = () => {
      if (currentPage.value > 1) {
        currentPage.value--
      }
    }

    const nextPage = () => {
      if (currentPage.value < totalPages.value) {
        currentPage.value++
      }
    }


    
   

    return {
      // 状态
      timeFilter,
      statusFilter,
      currentPage,
      
      // 计算属性
      activeTab,
      historyData,
      recentCollections,
      filteredHistoryData,
      totalPages,
      
      // 方法
      goToCollectionDetail,
      goToImageCollection,
      viewCollectionDetail,
      editCollection,
      deleteCollection,
      resetFilters,
      prevPage,
      nextPage,
      goToCollection,
      goToFieldSearch
    }
  }
}
</script>

<style scoped>


/* 采集统计 */
.collection-stats {
  margin-top: 30px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.stat-item {
  background: white;
  border-radius: 10px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  box-shadow: var(--shadow-light);
  border: 1px solid var(--border-light);
}

.stat-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon i {
  font-size: 20px;
  color: white;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: var(--text-primary);
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: var(--text-light);
}

/* 筛选工具栏 */
.filter-toolbar {
  display: flex;
  gap: 20px;
  align-items: center;
  margin-bottom: 20px;
  padding: 15px;
  background: #f9fdf6;
  border-radius: 8px;
  box-shadow: var(--shadow-light);
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-label {
  font-size: 14px;
  color: var(--text-secondary);
  font-weight: 500;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  background: white;
  font-size: 14px;
}

.filter-reset {
  padding: 8px 16px;
  background: var(--bg-secondary);
  color: var(--primary-color);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.filter-reset:hover {
  background: var(--border-color);
}

/* 分页 */

.pagination-btn {
  background-color: var(--bg-secondary);
  color: var(--primary-color);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 10px 20px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.pagination-btn:hover:not(:disabled) {
  background-color: var(--border-color);
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.tab-content.active {
  display: block;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .filter-toolbar {
    flex-direction: column;
    align-items: stretch;
  }
  
  .data-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .data-status {
    width: 100%;
    justify-content: space-between;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .pagination {
    flex-direction: column;
    gap: 15px;
  }
}

.section-title {
    font-size: 20px;
    color: var(--text-dark);
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid var(--border-color);
}

.function-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}
</style>