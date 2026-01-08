<template>
    <div class="main-container">
        <Header />
        <div class="main-content">
            <Sidebar />
            <div class="content-area">
                <h3 class="section-title">小区编号查询</h3>
                
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
                        <label class="form-label">请输入要查找的小区编号</label>
                        <div class="search-input">
                            <input type="text" class="form-input" v-model="fieldSearchInput" placeholder="输入小区编号，如：25KY00076">
                            <button class="search-btn" @click="searchField">查询</button>
                        </div>
                    </div>
                </div>
                <div class="gene-library">
                    <div class="gene-title">2025小区数据库</div>
                    <div class="table-container">
                        <table class="field-table">
                            <thead>
                                <tr>
                                    <th>小区编号</th>
                                    <th>小区名称</th>
                                    <th>观测次数</th>
                                    <th>突变体编号</th>
                                    <th>状态</th>
                                    <th>上次采集</th>
                                    <th>创建时间</th>
                                    <th>更新时间</th>
                                    <th>小区ID</th>
                                    <th>突变体ID</th>
                                    <th>图像管理</th>
                                    <th>备注</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="(item, index) in paginatedFieldData" :key="item.id" :class="{ highlight: item.highlight }">
                                    <td class="field-code">{{ item.field_code }}</td>
                                    <td class="experiment-name">{{ item.experiment_name }}</td>
                                    <td class="observations-count">{{ item.observations_count }}</td>
                                    <td class="mutant-code">{{ item.mutant_code || '无' }}</td>
                                    <td class="status-cell">
                                        <span :class="`status-badge status-${item.status}`">
                                            {{ getStatusText(item.status) }}
                                        </span>
                                    </td>
                                    <td class="last-collected">{{ formatDate(item.last_collected) }}</td>
                                    <td class="created-at">{{ formatDateTime(item.created_at) }}</td>
                                    <td class="updated-at">{{ formatDateTime(item.updated_at) }}</td>
                                    <td class="experiment-id">{{ formatId(item.experiment) }}</td>
                                    <td class="mutant-id">{{ formatId(item.mutant) || '无' }}</td>
                                    <td class="image-count">
                                        {{ item.imageCount || 0 }}
                                        <div class="image-buttons">
                                            <button class="view-images-btn" title="查看图片" @click="viewImages(item.field_code)" v-if="(item.imageCount || 0) > 0">
                                                <i class="fas fa-images"></i>
                                            </button>
                                            <button class="upload-image-btn" title="上传图片" @click="uploadImageForField(item.field_code)">
                                                <i class="fas fa-plus"></i>
                                            </button>
                                        </div>
                                    </td>
                                    <!-- 备注列 -->
                                    <td class="notes-management">
                                        <div class="notes-count-display">
                                            {{ getNotesCount(item.id) }}
                                        </div>
                                        <div class="notes-button">
                                            <button class="notes-btn" title="管理备注" @click="manageNotes(item.id)">
                                                <i class="fas fa-sticky-note"></i>
                                            </button>
                                        </div>
                                    </td>
                                    <!-- 操作列 -->
                                    <td class="operations">
                                        <div class="operation-buttons">
                                            <button class="operation-btn view-btn" title="查看详情" @click="viewDetails(item.id)">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="operation-btn download-btn" title="下载数据" @click="downloadSingle(item.id)">
                                                <i class="fas fa-download"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <tr v-if="loading">
                                    <td colspan="16" class="loading-cell">
                                        <i class="fas fa-spinner fa-spin"></i> 加载中...
                                    </td>
                                </tr>
                                <tr v-if="!loading && paginatedFieldData.length === 0">
                                    <td colspan="16" class="empty-cell">
                                        <i class="fas fa-database"></i> 暂无数据
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="pagination">
                        <button class="pagination-btn" @click="prevPage" :disabled="currentPage === 1 || loading">上一页</button>
                        <div class="pagination-info">
                            <span>第 {{ currentPage }} 页 / 共 {{ totalPages }} 页</span>
                            <span class="total-count">(共 {{ totalCount }} 条记录)</span>
                        </div>
                        <button class="pagination-btn" @click="nextPage" :disabled="currentPage === totalPages || loading">下一页</button>
                          
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
        <ImageViewer  v-if="showImageModal" :images="currentImages" :current-index="currentImageIndex" @close="closeImageModal" @prev="prevImage" @next="nextImage" @delete="deleteImage"/>
        <NotesManager v-if="showNotesModal" :field-id="currentFieldId" :notes="currentNotes" @close="showNotesModal = false" @add-note="addNewNote"/>
        <UploadModal v-if="showUploadModal" @close="showUploadModal = false" @confirm="confirmUpload"/>
        <DownloadModal v-if="showDownloadModal" @close="showDownloadModal = false" @confirm="confirmDownload"/>
    </div>
</template>

<script>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from '../js/toast.js'
import { initIndexedDB, getImagesByFieldId, saveImageToDB, deleteImageFromDB } from '../js/indexedDB.js'
import Header from './Header.vue'
import Sidebar from './Sidebar.vue'
import ImageViewer from './ImageViewer.vue'
import NotesManager from './NotesManager.vue'
import UploadModal from './FileUpload.vue'
import DownloadModal from './DownloadModal.vue'
import { fieldApi } from '../js/api.js'

export default {
    name: 'FieldSearch',
    components: {
        Header,
        Sidebar,
        ImageViewer,
        NotesManager,
        UploadModal,
        DownloadModal
    },
    setup() {
        const router = useRouter()

        const goToDashboard = () => {
            router.push('/dashboard')
        }
        
        // 响应式数据
        const fieldSearchInput = ref('')
        const currentPage = ref(1)
        const itemsPerPage = ref(10)
        const tempPageSize = ref(10) // 临时存储页面大小输入值
        const showImageModal = ref(false)
        const showNotesModal = ref(false)
        const showUploadModal = ref(false)
        const showDownloadModal = ref(false)
        
        const currentImages = ref([])
        const currentImageIndex = ref(0)
        const currentFieldId = ref('')
        const currentNotes = ref([])
        
        const fieldData = ref([])
        const totalCount = ref(0)
        const loading = ref(false)

        const imageCounts = ref({})
        const notesData = ref({})

        // 状态映射
        const statusMap = {
            'not_collected': '未采集',
            'collected': '已采集',
            'pending': '待处理',
            'processing': '处理中',
            'completed': '已完成'
        }

        // 加载小区数据
        const loadFieldData = async () => {
            loading.value = true
            try {
                console.log('开始调用API，参数:', {
                    page: currentPage.value,
                    page_size: itemsPerPage.value,
                    search: fieldSearchInput.value || ''
                })
                
                const response = await fieldApi.getFields({
                    page: currentPage.value,
                    page_size: itemsPerPage.value,
                    search: fieldSearchInput.value || ''
                })
                
                console.log('API完整响应对象:', response)
                console.log('响应状态:', response.status)
                console.log('响应状态文本:', response.statusText)
                console.log('响应headers:', response.headers)
                console.log('响应配置:', response.config)
                
                // axios响应对象的数据在response.data中
                const responseData = response.data
                console.log('API响应数据 (response.data):', responseData)
                console.log('响应数据类型:', typeof responseData)
                
                // 处理响应数据
                let dataArray = []
                let total = 0
                if (Array.isArray(responseData)) {
                    dataArray = responseData
                    total = responseData.length
                    console.log('API直接返回数组，长度:', total)
                } else if (responseData && responseData.results && Array.isArray(responseData.results)) {
                    dataArray = responseData.results
                    total = responseData.count || responseData.results.length
                    console.log('使用DRF分页格式，总数:', total, '当前页数据:', dataArray.length)
                } else if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    dataArray = responseData.data
                    total = responseData.total || responseData.data.length
                    console.log('使用data格式，总数:', total, '当前页数据:', dataArray.length)
                } else {
                    console.warn('无法识别的API响应格式:', responseData)
                    if (responseData && typeof responseData === 'object') {
                        const keys = Object.keys(responseData)
                        console.log('响应数据键:', keys)
                        
                        for (const key of keys) {
                            if (Array.isArray(responseData[key])) {
                                dataArray = responseData[key]
                                total = dataArray.length
                                console.log('找到数组属性:', key, '长度:', total)
                                break
                            }
                        }
                    }
                }
                
                if (dataArray.length === 0) {
                    console.log('没有获取到数据，检查API响应格式')
                }
                
                totalCount.value = total
                
                // 处理数据
                fieldData.value = dataArray.map(item => {
                    // 添加调试信息
                    console.log('处理单个数据项:', item)
                    console.log('字段代码:', item.field_code)
                    console.log('小区名称:', item.experiment_name)
                    
                    return {
                        ...item,
                        highlight: false,
                        imageCount: imageCounts.value[item.field_code] || 0
                    }
                })
                
                console.log('最终处理的数据:', fieldData.value.length, '条')
                console.log('第一条数据示例:', fieldData.value[0])
                
            } catch (error) {
                console.error('加载小区数据失败:', error)
                console.error('错误详情:', error.message)
                console.error('错误响应:', error.response)
                
                if (error.response) {
                    console.error('错误状态:', error.response.status)
                    console.error('错误数据:', error.response.data)
                }
                
                toast.error('加载小区数据失败，请重试')
                fieldData.value = []
                totalCount.value = 0
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
            loadFieldData()
            
            toast.info(`每页显示 ${newSize} 条数据`)
        }
       
        const formatId = (id) => {
            if (!id) return '无'
            return id.substring(0, 8) + '...'
        }

        // 格式化日期
        const formatDate = (dateString) => {
            if (!dateString) return '无'
            try {
                const date = new Date(dateString)
                return date.toLocaleDateString('zh-CN')
            } catch (e) {
                return '无效日期'
            }
        }

        // 格式化日期时间
        const formatDateTime = (dateTimeString) => {
            if (!dateTimeString) return '无'
            try {
                const date = new Date(dateTimeString)
                return date.toLocaleString('zh-CN')
            } catch (e) {
                return '无效日期'
            }
        }

        // 获取状态文本
        const getStatusText = (status) => {
            return statusMap[status] || status
        }

        // 计算属性
        const totalPages = computed(() => {
            return Math.ceil(totalCount.value / itemsPerPage.value)
        })
        
        const paginatedFieldData = computed(() => {
            return fieldData.value
        })

        // 页面导航方法
        const prevPage = async () => {
            if (currentPage.value > 1) {
                currentPage.value--
                await loadFieldData()
            }
        }
        
        const nextPage = async () => {
            if (currentPage.value < totalPages.value) {
                currentPage.value++
                await loadFieldData()
            }
        }
        
        // 搜索字段
        const searchField = async () => {
            if (!fieldSearchInput.value.trim()) {
                currentPage.value = 1
                fieldSearchInput.value = ''
                await loadFieldData()
                return
            }
            
            currentPage.value = 1
            await loadFieldData()
            
            const foundItem = fieldData.value.find(item => 
                item.field_code === fieldSearchInput.value
            )
            
            if (foundItem) {
                fieldData.value.forEach(item => {
                    item.highlight = false
                })
                foundItem.highlight = true
                toast.success(`找到小区编号: ${fieldSearchInput.value}`)
            } else if (fieldData.value.length > 0) {
                toast.info('未找到完全匹配的小区编号，显示相关结果')
            } else {
                toast.error('未找到匹配的小区编号')
            }
        }

        // 图片模态框相关方法
        const closeImageModal = () => {
            showImageModal.value = false
        }
        
        const prevImage = () => {
            if (currentImageIndex.value > 0) {
                currentImageIndex.value--
            }
        }
        
        const nextImage = () => {
            if (currentImageIndex.value < currentImages.value.length - 1) {
                currentImageIndex.value++
            }
        }
        
        // 上传图片方法
        const uploadImageForField = (fieldCode) => {
            const input = document.createElement('input')
            input.type = 'file'
            input.accept = 'image/*'
            input.multiple = true
            input.onchange = (e) => {
                if (e.target.files.length > 0) {
                    handleFilesForField(e.target.files, fieldCode)
                }
            }
            input.click()
        }
        
        // 加载所有字段的图片数量
        const loadImageCounts = async () => {
            try {
                await initIndexedDB()
                
                for (const item of fieldData.value) {
                    const images = await getImagesByFieldId(item.field_code)
                    imageCounts.value[item.field_code] = images ? images.length : 0
                }
                
                // 更新图片数量显示
                fieldData.value = fieldData.value.map(item => ({
                    ...item,
                    imageCount: imageCounts.value[item.field_code] || 0
                }))
            } catch (error) {
                console.error('加载图片数量失败:', error)
                toast.error('加载图片数据失败')
            }
        }
        
        // 更新单个字段的图片数量
        const updateFieldImageCount = async (fieldCode) => {
            try {
                const images = await getImagesByFieldId(fieldCode)
                const count = images ? images.length : 0
                imageCounts.value[fieldCode] = count
                
                const index = fieldData.value.findIndex(item => item.field_code === fieldCode)
                if (index !== -1) {
                    fieldData.value[index].imageCount = count
                    // 确保触发响应式更新
                    fieldData.value = [...fieldData.value]
                }
            } catch (error) {
                console.error(`更新字段 ${fieldCode} 图片数量失败:`, error)
            }
        }
        
        // 查看图片方法
        const viewImages = async (fieldCode) => {
            try {
                currentFieldId.value = fieldCode
                
                const images = await getImagesByFieldId(fieldCode)
                
                if (images && images.length > 0) {
                    currentImages.value = images.map(img => img.url)
                    currentImageIndex.value = 0
                    showImageModal.value = true
                } else {
                    toast.error('该小区编号暂无图片数据')
                }
            } catch (error) {
                console.error('查看图片失败:', error)
                toast.error('查看图片失败')
            }
        }
        
        // 处理文件上传
        const handleFilesForField = async (files, fieldCode) => {
            const validFiles = Array.from(files).filter(file => {
                if (!file.type.startsWith('image/')) {
                    toast.error('只能上传图片文件')
                    return false
                }
                
                if (file.size > 5 * 1024 * 1024) {
                    toast.error('图片大小不能超过5MB')
                    return false
                }
                
                return true
            })
            
            if (validFiles.length === 0) return
            
            for (const file of validFiles) {
                try {
                    const reader = new FileReader()
                    
                    const imageData = await new Promise((resolve, reject) => {
                        reader.onload = (e) => {
                            const imageData = {
                                id: Date.now() + Math.random().toString(36).substr(2, 9),
                                fieldId: fieldCode,
                                name: file.name,
                                url: e.target.result,
                                uploadTime: new Date().toISOString()
                            }
                            resolve(imageData)
                        }
                        
                        reader.onerror = () => {
                            reject(new Error('文件读取失败'))
                        }
                        
                        reader.readAsDataURL(file)
                    })
                    
                    await saveImageToDB(imageData)
                    
                } catch (error) {
                    console.error('处理文件失败:', error)
                    toast.error(`处理文件 ${file.name} 失败`)
                }
            }
            
            await updateFieldImageCount(fieldCode)
            toast.success(`成功为 ${fieldCode} 上传 ${validFiles.length} 张图片`)
        }

        const deleteImage = async (imageIndex) => {
            try {
                const fieldCode = currentFieldId.value
                
                if (confirm('确定要删除这张图片吗？删除后无法恢复。')) {
                    await deleteImageFromDB(fieldCode, imageIndex)
                    
                    const images = await getImagesByFieldId(fieldCode)
                    currentImages.value = images ? images.map(img => img.url) : []
                    
                    await updateFieldImageCount(fieldCode)
                    
                    if (currentImages.value.length === 0) {
                        showImageModal.value = false
                        toast.success('图片已删除')
                    } else {
                        if (currentImageIndex.value >= currentImages.value.length) {
                            currentImageIndex.value = currentImages.value.length - 1
                        }
                        toast.success('图片删除成功')
                    }
                }
            } catch (error) {
                console.error('删除图片失败:', error)
                toast.error('删除图片失败')
            }
        }
        
        // 备注相关方法
        const getNotesCount = (fieldId) => {
            return notesData.value[fieldId] ? notesData.value[fieldId].length : 0
        }
        
        const manageNotes = (fieldId) => {
            currentFieldId.value = fieldId
            currentNotes.value = notesData.value[fieldId] || []
            showNotesModal.value = true
        }
        
        const addNewNote = (noteContent) => {
            if (!notesData.value[currentFieldId.value]) {
                notesData.value[currentFieldId.value] = []
            }
            
            const newNote = {
                content: noteContent,
                author: '当前用户',
                date: new Date().toLocaleString('zh-CN')
            }
            
            notesData.value[currentFieldId.value].unshift(newNote)
            currentNotes.value = notesData.value[currentFieldId.value]
            
            localStorage.setItem('fieldNotes', JSON.stringify(notesData.value))
            toast.success('备注添加成功')
        }
        
        const downloadSingle = (id) => {
            const fieldItem = fieldData.value.find(item => item.id === id)
            const fieldCode = fieldItem ? fieldItem.field_code : id
            toast.success(`小区编号 ${fieldCode} 的数据已下载`)
        }
        
        const viewDetails = (id) => {
            const fieldItem = fieldData.value.find(item => item.id === id)
            const fieldCode = fieldItem ? fieldItem.field_code : id
            toast.success(`查看小区编号 ${fieldCode} 的详细信息`)
        }
        
        const confirmUpload = () => {
            toast.success('数据上传成功！')
        }
        
        const confirmDownload = () => {
            toast.success('数据下载完成！')
        }
        
        // 监听页码变化
        watch(currentPage, () => {
            loadFieldData()
        })
        
        // 监听每页条数变化
        watch(itemsPerPage, () => {
            // 同步临时值
            tempPageSize.value = itemsPerPage.value
        })
        
        // 生命周期
        onMounted(async () => {
            // 初始化临时值
            tempPageSize.value = itemsPerPage.value
            
            const storedNotes = localStorage.getItem('fieldNotes')
            if (storedNotes) {
                notesData.value = JSON.parse(storedNotes)
            }
            
            await loadFieldData()
            await loadImageCounts()
        })
        
        return {
            fieldSearchInput,
            currentPage,
            itemsPerPage,
            tempPageSize,
            showImageModal,
            showNotesModal,
            showUploadModal,
            showDownloadModal,
            currentImages,
            currentImageIndex,
            currentFieldId,
            currentNotes,
            fieldData: paginatedFieldData, 
            notesData,
            totalPages,
            paginatedFieldData,
            totalCount,
            loading,
            goToDashboard,
            searchField,
            applyPageSize,
            prevPage,
            nextPage,
            viewImages,
            closeImageModal,
            prevImage,
            nextImage,
            uploadImageForField,
            getNotesCount,
            manageNotes,
            addNewNote,
            downloadSingle,
            viewDetails,
            confirmUpload,
            confirmDownload,
            loadImageCounts,
            deleteImage,
            getStatusText,
            formatId,
            formatDate,
            formatDateTime
        }
    }
}
</script>

<style scoped>

    .main-content {
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
        justify-content: center
    }

    .upload-btn:hover, .download-btn:hover {
        background: #3d5c27;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(79, 119, 52, 0.2);
    }

    .form-input:focus {
        outline: none;
        border-color: #4f7734;
    }

    .search-btn:hover {
        background: #3d5c27;
    }

    .table-container {
        overflow-x: auto;
        margin-bottom: 20px;
         
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
        width: 80px;
        padding: 8px 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        text-align: center;
        font-size: 14px;
        transition: border-color 0.3s;
    }

    .page-size-input:focus {
        outline: none;
        border-color: #4f7734;
    }

    .page-size-unit {
        font-size: 14px;
        color: #666;
    }

    .apply-btn {
        background: #4f7734;
        color: white;
        border: none;
        border-radius: 4px;
        padding: 8px 15px;
        font-size: 14px;
        cursor: pointer;
        transition: background 0.3s;
        margin-left: 10px;
    }

    .apply-btn:hover {
        background: #3d5c27;
    }

    .field-table {
        width: 100%;
        min-width: 1600px;
        border-collapse: collapse;
        font-size: 13px;
        text-align: center;
        
    }

    .field-table th {
        background-color: #4f7734;
        color: white;
        padding: 12px 10px;
        text-align: left;
        font-weight: 600;
        white-space: nowrap;
        position: sticky;
        top: 0;
        z-index: 10;
        text-align: center;
    }

    .highlight {
        background-color: #fff8e1 !important;
        font-weight: 500;
    }

    /* 特定列的样式 */
    .id-cell, .experiment-id, .mutant-id {
        font-family: 'Courier New', monospace;
        font-size: 12px;
        color: #666;
    }

    .field-code {
        font-weight: 600;
        color: #4f7734;
    }

    .experiment-name {
        font-weight: 500;
        color: #333;
    }

    .status-cell {
        text-align: center;
    }

    .status-not_collected {
        background-color: #f0f0f0;
        color: #666;
    }

    .status-collected {
        background-color: #d4edda;
        color: #155724;
    }

    .status-pending {
        background-color: #fff3cd;
        color: #856404;
    }

    .status-processing {
        background-color: #cce5ff;
        color: #004085;
    }

    .status-completed {
        background-color: #d1ecf1;
        color: #0c5460;
    }

    .visibility-badge {
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
        display: inline-block;
        min-width: 50px;
    }

    .visible {
        background-color: #d4edda;
        color: #155724;
    }

    .invisible {
        background-color: #f8d7da;
        color: #721c24;
    }

    .description, .comment {
        max-width: 200px;
        white-space: normal;
        word-break: break-word;
    }

    .created-at, .updated-at, .last-collected {
        font-size: 12px;
        color: #666;
    }

    .image-count {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 5px;
      
    }

    .image-buttons {
        display: flex;
        gap: 5px;
        
    }

    .view-images-btn, .upload-image-btn, .action-btn {
        background: none;
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 5px 8px;
        cursor: pointer;
        transition: all 0.3s;
       
        font-size: 12px;
    }

    .view-images-btn:hover, .upload-image-btn:hover {
        background-color: #4f7734;
        color: white;
        border-color: #4f7734;
    }

    .action-cell {
        display: flex;
        gap: 5px;
        justify-content: center;
    }

    .action-btn:hover {
        background-color: #4f7734;
        color: white;
        border-color: #4f7734;
    }

    .loading-cell, .empty-cell {
        text-align: center;
        padding: 40px !important;
        color: #999;
        font-size: 14px;
    }

    .loading-cell i, .empty-cell i {
        margin-right: 8px;
    }

    .pagination-btn {
        background-color: white;
        color: #4f7734;
        border: 1px solid #4f7734;
        border-radius: 6px;
        padding: 8px 20px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s;
    }

    .pagination-btn:hover:not(:disabled) {
        background-color: #4f7734;
        color: white;
    }

    /* 操作列样式 */
    .operations {
        text-align: center;
        padding: 8px 5px !important;
        min-width: 100px;
    }

    .operation-buttons {
        display: flex;
        justify-content: center;
        gap: 8px;
        text-align: center
    }

    .operation-btn {
        background: none;
        border: 1px solid #5a7d3c;
        border-radius: 4px;
        padding: 6px 10px;
        cursor: pointer;
        transition: all 0.3s;
        color: #5a7d3c;
        font-size: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 32px;
        height: 32px;
    }

    .view-btn:hover {
        background-color: #17a2b8;
        color: white;
        border-color: #17a2b8;
    }

    .download-btn:hover {
        background-color: #28a745;
        color: white;
        border-color: #28a745;
    }

    .loading-cell, .empty-cell {
        text-align: center;
        padding: 40px !important;
        color: #999;
        font-size: 14px;
    }

    .loading-cell i, .empty-cell i {
        margin-right: 8px;
    }

    .pagination-btn:hover:not(:disabled) {
        background-color: #4f7734;
        color: white;
    }

    @media (max-width: 800px) {
    
        .upload-download-buttons {
            flex-direction: column;
        }
        
        .search-input {
            flex-direction: column;
        }
    }
</style>