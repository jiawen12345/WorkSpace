<template>
    <div class="main-container">
        <Header />
        <div class="main-content">
            <Sidebar />
            <div class="content-area">
                <h3 class="section-title">种子编号查询</h3>
                
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
                        <label class="form-label">请输入要查找的种子编号</label>
                        <div class="search-input">
                            <input type="text" class="form-input" v-model="fieldSearchInput" placeholder="输入种子编号，如：25KY00076">
                            <button class="search-btn" @click="searchField">查询</button>
                        </div>
                    </div>
                </div>
                
                <div class="gene-library">
                    <div class="gene-title">2025种子数据库</div>
                    <table class="field-table">
                        <thead>
                            <tr>
                                <th>种子编号(全部)</th>
                                <th>图像的查看与下载</th>
                                <th>序号</th>
                                <th>备注1</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(item, index) in paginatedFieldData" :key="item.id" :class="{ highlight: item.highlight }">
                                <td>{{ item.id }}</td>
                                <td class="image-count">
                                    {{ item.images }}
                                    <button class="view-images-btn" title="查看图片" @click="viewImages(item.id)" v-if="item.images > 0">
                                        <i class="fas fa-images"></i>
                                    </button>
                                    <button class="upload-image-btn" title="上传图片" @click="uploadImageForField(item.id)">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </td>
                                <td>{{ item.note1 }}</td>
                                <td>
                                    {{ getNotesCount(item.id) }}
                                    <button class="notes-btn" title="管理备注" @click="manageNotes(item.id)">
                                        <i class="fas fa-sticky-note"></i>
                                    </button>
                                </td>
                                <td class="action-cell">
                                    <button class="action-btn" title="下载单个数据" @click="downloadSingle(item.id)">
                                        <i class="fas fa-download"></i>
                                    </button>
                                    <button class="action-btn" title="查看详情" @click="viewDetails(item.id)">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="pagination">
                        <button class="pagination-btn" @click="prevPage" :disabled="currentPage === 1">上一页</button>
                        <div class="pagination-info">{{ currentPage }}/{{ totalPages }}</div>
                        <button class="pagination-btn" @click="nextPage" :disabled="currentPage === totalPages">下一页</button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 模态框组件 -->
        <ImageViewer 
            v-if="showImageModal"
            :images="currentImages"
            :current-index="currentImageIndex"
            @close="closeImageModal"
            @prev="prevImage"
            @next="nextImage"
            @delete="deleteImage"  
        />
        
        <NotesManager
            v-if="showNotesModal"
            :field-id="currentFieldId"
            :notes="currentNotes"
            @close="showNotesModal = false"
            @add-note="addNewNote"
        />
        
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
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from '../js/toast.js'
import { initIndexedDB, getImagesByFieldId, saveImageToDB, deleteImageFromDB } from '../js/indexedDB.js'
import Header from './Header.vue'
import Sidebar from './Sidebar.vue'
import ImageViewer from './ImageViewer.vue'
import NotesManager from './NotesManager.vue'
import UploadModal from './FileUpload.vue'
import DownloadModal from './DownloadModal.vue'

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
        const showImageModal = ref(false)
        const showNotesModal = ref(false)
        const showUploadModal = ref(false)
        const showDownloadModal = ref(false)
        
        const currentImages = ref([])
        const currentImageIndex = ref(0)
        const currentFieldId = ref('')
        const currentNotes = ref([])
        
        // 种子编号数据
        const fieldData = ref([
            { id: '25KY00076', note1: '01', note2: '正常生长' },
            { id: '25KY00077', note1: '02', note2: '轻度病虫害' },
            { id: '25KY00078', note1: '03', note2: '优良品种' },
            { id: '25KY00079', note1: '04', note2: '需施肥' },
            { id: '25KY00080', note1: '05', note2: '正常生长' },
            { id: '25KY00081', note1: '06', note2: '优良品种' },
            { id: '25KY00082', note1: '07', note2: '需灌溉' },
            { id: '25KY00083', note1: '08', note2: '正常生长' },
            { id: '25KY00084', note1: '09', note2: '轻度病虫害' },
            { id: '25KY00085', note1: '10', note2: '优良品种' },
            { id: '25KY00086', note1: '11', note2: '正常生长' },
            { id: '25KY00087', note1: '12', note2: '需除草' },
            { id: '25KY00088', note1: '13', note2: '轻度干旱' },
            { id: '25KY00089', note1: '14', note2: '优良品种' },
            { id: '25KY00090', note1: '15', note2: '正常生长' }
        ])
        
        // 存储每个字段的图片数量
        const imageCounts = ref({})
        
        // 备注数据
        const notesData = ref({})
        
        // 计算属性 - 动态组合图片数量
        const fieldDataWithImages = computed(() => {
            return fieldData.value.map(item => ({
                ...item,
                images: imageCounts.value[item.id] || 0,
                highlight: item.highlight || false
            }))
        })
        
        // 分页数据
        const totalPages = computed(() => Math.ceil(fieldDataWithImages.value.length / itemsPerPage.value))
        
        const paginatedFieldData = computed(() => {
            const start = (currentPage.value - 1) * itemsPerPage.value
            const end = start + itemsPerPage.value
            return fieldDataWithImages.value.slice(start, end)
        })
        
        // 页面导航方法
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
        const uploadImageForField = (fieldId) => {
            const input = document.createElement('input')
            input.type = 'file'
            input.accept = 'image/*'
            input.multiple = true
            input.onchange = (e) => {
                if (e.target.files.length > 0) {
                    handleFilesForField(e.target.files, fieldId)
                }
            }
            input.click()
        }
        
        // 加载所有字段的图片数量
        const loadImageCounts = async () => {
            try {
                // 确保数据库已初始化
                await initIndexedDB()
                
                // 为每个字段获取图片数量
                for (const item of fieldData.value) {
                    const images = await getImagesByFieldId(item.id)
                    imageCounts.value[item.id] = images ? images.length : 0
                }
            } catch (error) {
                console.error('加载图片数量失败:', error)
                toast.error('加载图片数据失败')
            }
        }
        
        // 更新单个字段的图片数量
        const updateFieldImageCount = async (fieldId) => {
            try {
                const images = await getImagesByFieldId(fieldId)
                imageCounts.value[fieldId] = images ? images.length : 0
            } catch (error) {
                console.error(`更新字段 ${fieldId} 图片数量失败:`, error)
            }
        }
        
        // 搜索字段
        const searchField = () => {
            if (!fieldSearchInput.value.trim()) {
                toast.error('请输入要查询的种子编号')  
                return
            }
            
            // 清除之前的高亮
            fieldData.value.forEach(item => {
                item.highlight = false
            })
            
            // 高亮匹配的行
            const foundItem = fieldData.value.find(item => item.id === fieldSearchInput.value)
            if (foundItem) {
                foundItem.highlight = true
                toast.success(`找到种子编号: ${fieldSearchInput.value}`)  
                
                // 跳转到包含该项目的页面
                const index = fieldData.value.indexOf(foundItem)
                currentPage.value = Math.floor(index / itemsPerPage.value) + 1
            } else {
                toast.error('未找到匹配的种子编号')  
            }
        }
        
        // 查看图片方法
        const viewImages = async (fieldId) => {
            try {
                // 设置当前字段ID
                currentFieldId.value = fieldId
                
                const images = await getImagesByFieldId(fieldId)
                
                if (images && images.length > 0) {
                    currentImages.value = images.map(img => img.url)
                    currentImageIndex.value = 0
                    showImageModal.value = true
                } else {
                    toast.error('该种子编号暂无图片数据')  
                }
            } catch (error) {
                console.error('查看图片失败:', error)
                toast.error('查看图片失败')  
            }
        }
        
        // 处理文件上传
        const handleFilesForField = async (files, fieldId) => {
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
                                fieldId: fieldId,
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
                    
                    // 保存到数据库
                    await saveImageToDB(imageData)
                    
                } catch (error) {
                    console.error('处理文件失败:', error)
                    toast.error(`处理文件 ${file.name} 失败`)  
                }
            }
            
            // 上传完成后更新该字段的图片数量
            await updateFieldImageCount(fieldId)
            
            toast.success(`成功为 ${fieldId} 上传 ${validFiles.length} 张图片`)  
        }

    const deleteImage = async (imageIndex) => {
         try {
        const fieldId = currentFieldId.value
        
        if (confirm('确定要删除这张图片吗？删除后无法恢复。')) {

            await deleteImageFromDB(fieldId, imageIndex)
            
            const images = await getImagesByFieldId(fieldId)
            
            currentImages.value = images ? images.map(img => img.url) : []
            
            await updateFieldImageCount(fieldId)
            
            if (currentImages.value.length === 0) {
                showImageModal.value = false
                toast.success('图片已删除')
            } else {
                // 调整当前图片索引
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
            
            // 保存到本地存储
            localStorage.setItem('fieldNotes', JSON.stringify(notesData.value))
            
            toast.success('备注添加成功') 
        }
        
        const downloadSingle = (id) => {
            toast.success(`种子编号 ${id} 的数据已下载`) 
        }
        
        const viewDetails = (id) => {
            toast.success(`查看种子编号 ${id} 的详细信息`) 
        }
        
        const confirmUpload = () => {
            toast.success('数据上传成功！') 
        }
        
        const confirmDownload = () => {
            toast.success('数据下载完成！') 
        }
        
        // 生命周期
        onMounted(async () => {
            // 加载备注数据
            const storedNotes = localStorage.getItem('fieldNotes')
            if (storedNotes) {
                notesData.value = JSON.parse(storedNotes)
            }
            
            // 加载图片数量
            await loadImageCounts()
        })
        
        return {
            fieldSearchInput,
            currentPage,
            itemsPerPage,
            showImageModal,
            showNotesModal,
            showUploadModal,
            showDownloadModal,
            currentImages,
            currentImageIndex,
            currentFieldId,
            currentNotes,
            fieldData: fieldDataWithImages, 
            notesData,
            totalPages,
            paginatedFieldData,
            goToDashboard,
            searchField,
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
            deleteImage 
        }
    }
}
</script>


<style scoped>
    .upload-btn[data-v-2049aac5], .download-btn[data-v-2049aac5] {
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
}

.upload-btn:hover, .download-btn:hover {
        background-color: var(--primary-color);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 12px 25px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    
}


.search-btn:hover {
    background-color: var(--primary-dark);
}

.field-table {
    width: 100%;
    
    margin-bottom: 20px;
    font-size: 14px;
}

.field-table th {
    background-color: var(--primary-color);
    color: white;
    padding: 12px 15px;
    text-align: left;
}

.field-table td {
    padding: 12px 15px;
    border-bottom: 1px solid var(--border-color);
}

.field-table tr:hover {
    background-color: var(--secondary-color);
}

.pagination-btn {
    background-color: var(--secondary-color);
    color: var(--primary-color);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: 10px 20px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
}

.pagination-btn:hover {
    background-color: var(--border-color);
}

.pagination-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.pagination-info {
    font-size: 14px;
    color: var(--text-light);
}

.highlight {
    background-color: #fff8e1 !important;
    font-weight: bold;
}

.view-images-btn:hover, .upload-image-btn:hover {
    background-color: var(--border-color);
}

.notes-btn:hover {
    background-color: var(--primary-dark);
}

.action-btn:hover {
    background-color: var(--secondary-color);
}

@media (max-width: 768px) {
    .upload-download-buttons {
        flex-direction: column;
    }
    
    .search-input {
        flex-direction: column;
        gap: 10px;
    }
    
    .search-btn {
        padding: 12px;
    }
    
    .field-table {
        font-size: 12px;
    }
    
    .field-table th,
    .field-table td {
        padding: 8px 10px;
    }
    }

.page-header {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
}

.back-btn {
    background-color: var(--bg-secondary);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: 8px 12px;
    cursor: pointer;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 5px;
    transition: all 0.3s;
}

.back-btn:hover {
    background-color: var(--border-color);
}

.section-title {
    margin: 0;
    flex: 1;
}




.function-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}


</style>