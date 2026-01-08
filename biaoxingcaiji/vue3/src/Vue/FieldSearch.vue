<template>
    <div class="main-container">
        <Header />
        <div class="main-content">
            <Sidebar />
            <div class="content-area">
                <h3 class="section-title">实验管理</h3>
                
                <!-- 添加上传下载按钮 -->
                <div class="upload-download-buttons">
                    <button class="upload-btn" @click="showUploadModal = true">
                        <i class="fas fa-upload"></i>上传数据
                    </button>
                    <button class="download-btn" @click="showDownloadModal = true">
                        <i class="fas fa-download"></i>下载数据
                    </button>
                </div>
                
                <div class="search-box">
                    <div class="form-group">
                        <label class="form-label">请输入要查找的实验名称</label>
                        <div class="search-input">
                            <input type="text" class="form-input" v-model="experimentSearchInput" placeholder="输入实验名称，如：2025突变体库T0">
                            <button class="search-btn" @click="searchExperiment">查询</button>
                        </div>
                    </div>
                </div>
                
                <div class="experiment-library">
                    <div class="experiment-title">实验数据库</div>
                    
                    <div class="table-container">
                        <table class="experiment-table">
                            <thead>
                                <tr>
                                    <th>实验名称</th>
                                    <th>年份</th>
                                    <th>实验类型</th>
                                    <th>地点</th>
                                    <th>小区数量</th>
                                    <th>动物数量</th>
                                    <th>状态</th>
                                    <th>开始日期</th>
                                    <th>结束日期</th>
                                    <th>创建人</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="(item, index) in paginatedExperimentData" :key="item.id" :class="{ highlight: item.highlight }">
                                    <td class="experiment-name">{{ item.name }}</td>
                                    <td class="year">{{ item.year }}</td>
                                    <td class="experiment-type">{{ getExperimentTypeText(item.experiment_type) }}</td>
                                    <td class="location">{{ item.location }}</td>
                                    <td class="fields-count">{{ item.fields_count }}</td>
                                    <td class="animals-count">{{ item.animals_count }}</td>
                                    <td class="status-cell">
                                        <span :class="`status-badge status-${item.status}`">
                                            {{ getStatusText(item.status) }}
                                        </span>
                                    </td>
                                    <td class="start-date">{{ formatDate(item.start_date) }}</td>
                                    <td class="end-date">{{ formatDate(item.end_date) }}</td>
                                    <td class="created-name">{{ item.created_name }}</td>
                                </tr>
                                <tr v-if="loading">
                                    <td colspan="10" class="loading-cell">
                                        <i class="fas fa-spinner fa-spin"></i> 加载中...
                                    </td>
                                </tr>
                                <tr v-if="!loading && paginatedExperimentData.length === 0">
                                    <td colspan="10" class="empty-cell">
                                        <i class="fas fa-database"></i> 暂无实验数据
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="pagination-row">
                        <div class="pagination-controls">
                            <button class="pagination-btn" @click="prevPage" :disabled="currentPage === 1 || loading">上一页</button>
                            <div class="pagination-info">
                                <span>第 {{ currentPage }} 页 / 共 {{ totalPages }} 页</span>
                                <span class="total-count">(共 {{ totalCount }} 个实验)</span>
                            </div>
                            <button class="pagination-btn" @click="nextPage" :disabled="currentPage === totalPages || loading">下一页</button>
                        </div>
                        
                        <div class="page-size-control">
                            <label for="pageSize" class="page-size-label">每页显示：</label>
                            <div class="page-size-input-group">
                                <input type="number" id="pageSize" v-model.number="tempPageSize" min="1" max="1000" 
                                       class="page-size-input" @keyup.enter="applyPageSize" @blur="applyPageSize">
                                <span class="page-size-unit">条</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 模态框组件 -->
        <UploadModal
            v-if="showUploadModal"
            @close="showUploadModal = false"
            @confirm="confirmUpload"
        />
        
        <DownloadModal
            v-if="showDownloadModal"
            @close="showDownloadModal = false"
            @confirm="confirmDownload"
        />
    </div>
</template>

<script>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from '../js/toast.js'
import Header from './Header.vue'
import Sidebar from './Sidebar.vue'
import UploadModal from './FileUpload.vue'
import DownloadModal from './DownloadModal.vue'
import { experimentApi } from '../js/api.js'

export default {
    name: 'FieldSearch',
    components: {
        Header,
        Sidebar,
        UploadModal,
        DownloadModal
    },
    setup() {
        const router = useRouter()

        const goToDashboard = () => {
            router.push('/dashboard')
        }
        
        // 响应式数据
        const experimentSearchInput = ref('')
        const currentPage = ref(1)
        const itemsPerPage = ref(10)
        const tempPageSize = ref(10) // 临时存储输入的值
        const showUploadModal = ref(false)
        const showDownloadModal = ref(false)
        
        const experimentData = ref([])
        const totalCount = ref(0)
        const loading = ref(false)

        // 状态映射
        const statusMap = {
            'ongoing': '进行中',
            'completed': '已完成',
            'planned': '计划中',
            'cancelled': '已取消'
        }

        // 实验类型映射
        const experimentTypeMap = {
            'plant': '植物实验',
            'animal': '动物实验',
            'field': '田间实验',
            'lab': '实验室实验'
        }

        // 从后端加载实验数据
        const loadExperimentData = async () => {
            loading.value = true
            try {
                const response = await experimentApi.getExperiments({
                    page: currentPage.value,
                    page_size: itemsPerPage.value,
                    search: experimentSearchInput.value || ''
                })
                
                // 处理响应数据
                const data = response.data
                
                if (data && data.results && Array.isArray(data.results)) {
                    // 分页格式
                    experimentData.value = data.results.map(item => ({
                        ...item,
                        highlight: false
                    }))
                    totalCount.value = data.count || 0
                } else if (Array.isArray(data)) {
                    experimentData.value = data.map(item => ({
                        ...item,
                        highlight: false
                    }))
                    totalCount.value = data.length
                } else {
                    experimentData.value = []
                    totalCount.value = 0
                }
                
            } catch (error) {
                console.error('加载实验数据失败:', error)
                toast.error('加载实验数据失败，请重试')
            } finally {
                loading.value = false
            }
        }

        // 应用页面大小
        const applyPageSize = () => {
            let newSize = parseInt(tempPageSize.value)
            
            // 验证输入
            if (isNaN(newSize) || newSize < 1) {
                newSize = 10
            } else if (newSize > 1000) {
                newSize = 1000
            }
            
            tempPageSize.value = newSize
            itemsPerPage.value = newSize
            
            // 重置到第一页并重新加载数据
            currentPage.value = 1
            loadExperimentData()
            
            toast.info(`每页显示 ${newSize} 条数据`)
        }

        // 获取日期
        const formatDate = (dateString) => {
            if (!dateString) return '无'
            try {
                const date = new Date(dateString)
                return date.toLocaleDateString('zh-CN')
            } catch (error) {
                return dateString
            }
        }

        // 获取状态文本
        const getStatusText = (status) => {
            return statusMap[status] || status
        }

        // 获取实验类型文本
        const getExperimentTypeText = (type) => {
            return experimentTypeMap[type] || type
        }

        // 计算属性
        const totalPages = computed(() => {
            return Math.ceil(totalCount.value / itemsPerPage.value)
        })
        
        const paginatedExperimentData = computed(() => {
            return experimentData.value
        })

        // 页面导航方法
        const prevPage = async () => {
            if (currentPage.value > 1) {
                currentPage.value--
                await loadExperimentData()
            }
        }
        
        const nextPage = async () => {
            if (currentPage.value < totalPages.value) {
                currentPage.value++
                await loadExperimentData()
            }
        }
        
        // 搜索实验
        const searchExperiment = async () => {
            if (!experimentSearchInput.value.trim()) {
                currentPage.value = 1
                experimentSearchInput.value = ''
                await loadExperimentData()
                return
            }
            
            // 有搜索条件时，重置到第一页并搜索
            currentPage.value = 1
            await loadExperimentData()
            
            // 查找精确匹配项
            const foundItem = experimentData.value.find(item => 
                item.name === experimentSearchInput.value
            )
            
            if (foundItem) {
                experimentData.value.forEach(item => {
                    item.highlight = false
                })
                foundItem.highlight = true
                toast.success(`找到实验: ${experimentSearchInput.value}`)
            } else if (experimentData.value.length > 0) {
                toast.info('未找到完全匹配的实验，显示相关结果')
            } else {
                toast.error('未找到匹配的实验')
            }
        }
        
        // 上传确认
        const confirmUpload = () => {
            toast.success('数据上传成功！')
            // 上传后刷新数据
            loadExperimentData()
        }
        
        // 下载确认
        const confirmDownload = () => {
            toast.success('数据下载完成！')
        }
        
        // 监听页码变化
        watch(currentPage, () => {
            loadExperimentData()
        })
        
        // 监听每页条数变化
        watch(itemsPerPage, () => {
            // 同步临时值
            tempPageSize.value = itemsPerPage.value
        })
        
        // 监听搜索条件变化
        watch(experimentSearchInput, (newValue) => {
            if (!newValue.trim()) {
                // 搜索框清空时，重置到第一页并重新加载
                currentPage.value = 1
                loadExperimentData()
            }
        })
        
        // 生命周期
        onMounted(async () => {
            // 加载实验数据
            await loadExperimentData()
        })
        
        return {
            experimentSearchInput,
            currentPage,
            itemsPerPage,
            tempPageSize,
            showUploadModal,
            showDownloadModal,
            experimentData: paginatedExperimentData,
            totalPages,
            paginatedExperimentData,
            totalCount,
            loading,
            goToDashboard,
            searchExperiment,
            prevPage,
            nextPage,
            confirmUpload,
            confirmDownload,
            applyPageSize,
            getStatusText,
            getExperimentTypeText,
            formatDate
        }
    }
}
</script>

<style scoped>
    .main-content {
        display: flex;
        height: calc(100vh - 60px);
    }

    .upload-btn, .download-btn {
        background: #4f7734;
        color: white;
        border: none;
        border-radius: 6px;
        padding: 12px 25px;
        font-size: 16px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.3s;
    }

    .upload-btn:hover, .download-btn:hover {
        background: #3d5c27;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(79, 119, 52, 0.2);
    }

    .form-group {
        margin-bottom: 0;
    }

    .form-input:focus {
        outline: none;
        border-color: #4f7734;
    }

    .search-btn:hover {
        background: #3d5c27;
    }

    .experiment-library {
        background: #f9fdf6;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    .experiment-title {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 20px;
        color: #333;
        padding-bottom: 10px;
        border-bottom: 2px solid #4f7734;
    }

   .pagination-row {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 20px;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #eee;
   }

    .pagination-controls {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .page-size-control {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        color: #333;
        height: 44px;
    }

    .page-size-label {
        white-space: nowrap;
    }

    .page-size-input-group {
        display: flex;
        align-items: center;
        gap: 5px;
        height: 44px; 
    }

    .page-size-input {
        width: 70px;
        height: 44px;
        padding: 0 0px;
        border: 1px solid #a4ba95;
        border-radius: 4px;
        text-align: center;
        font-size: 14px;
        transition: border-color 0.3s;
        box-sizing: border-box;
    }

    .page-size-input:focus {
        outline: none;
        border-color: #4f7734;
    }

    .page-size-unit {
        font-size: 14px;
        color: #666;
        white-space: nowrap;
    }

    .table-container {
        overflow-x: auto;
        margin-bottom: 20px;
        border-radius: 6px;
        border: 1px solid #eaeaea;
    }

    .experiment-table {
        width: 100%;
        min-width: 1100px;
        border-collapse: collapse;
        font-size: 14px;
    }

    .experiment-table th {
        background-color: #4f7734;
        color: white;
        padding: 14px 12px;
        text-align: center;
        font-weight: 600;
        white-space: nowrap;
        position: sticky;
        top: 0;
        z-index: 10;
        border-right: 1px solid rgba(255,255,255,0.1);
    }

    .experiment-table th:last-child {
        border-right: none;
    }

    .experiment-table td {
        padding: 12px 10px;
        border-bottom: 1px solid #eee;
        vertical-align: middle;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 150px;
        text-align: center;
    }

    .experiment-table tr:hover td {
        background-color: #f8f9fa;
    }

    .highlight {
        background-color: #fff8e1 !important;
        font-weight: 500;
    }

    /* 特定列的样式 */
    .experiment-name {
        font-weight: 600;
        color: #4f7734;
        text-align: left;
        padding-left: 15px;
    }

    .year, .fields-count, .animals-count {
        text-align: center;
        font-weight: 500;
    }

    .experiment-type, .location, .created-name {
        font-weight: 500;
        color: #333;
        text-align: center;
    }

    .status-cell {
        text-align: center;
    }

    .status-badge {
        display: inline-block;
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        min-width: 70px;
    }

    .status-ongoing {
        background-color: #e8f5e9;
        color: #2e7d32;
        border: 1px solid #c8e6c9;
    }

    .status-completed {
        background-color: #e3f2fd;
        color: #1565c0;
        border: 1px solid #bbdefb;
    }

    .status-planned {
        background-color: #fff8e1;
        color: #ff8f00;
        border: 1px solid #ffe082;
    }

    .status-cancelled {
        background-color: #ffebee;
        color: #c62828;
        border: 1px solid #ffcdd2;
    }

    .start-date, .end-date {
        color: #666;
        font-size: 13px;
    }

    .loading-cell, .empty-cell {
        text-align: center;
        padding: 60px !important;
        color: #999;
        font-size: 16px;
        background-color: white;
    }

    .loading-cell i, .empty-cell i {
        margin-right: 10px;
        font-size: 18px;
    }

    .fa-spinner {
        color: #4f7734;
    }

    .fa-database {
        color: #ddd;
    }

    .pagination-btn {
        background-color: white;
        color: #4f7734;
        border: 1px solid #4f7734;
        border-radius: 6px;
        padding: 10px 24px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s;
        min-width: 100px;
        height: 44px;
        box-sizing: border-box;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .pagination-btn:hover:not(:disabled) {
        background-color: #4f7734;
        color: white;
    }

    /* 响应式设计 */

    @media (max-width: 768px) {
        .upload-download-buttons {
            flex-direction: column;
        }
        
        .upload-btn, .download-btn {
            width: 100%;
            justify-content: center;
        }
        
        .search-input {
            flex-direction: column;
        }
        
        .search-btn {
            width: 100%;
        }
        
        .pagination-controls {
            flex-direction: column;
            gap: 15px;
        }
        
        .pagination-info {
            order: -1;
            height: auto;
        }
    }

    @media (max-width: 480px) {
        .section-title {
            font-size: 20px;
        }
    }
</style>