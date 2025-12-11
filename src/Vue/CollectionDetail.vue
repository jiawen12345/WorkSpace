<template>
  <div class="container">
    <div class="main-container">
      <div class="app-header">
        <div class="app-logo">
          <div class="app-logo-icon">
            <i class="fas fa-seedling"></i>
          </div>
          <div class="app-logo-text">种子图谱</div>
        </div>
        <div class="app-title">{{ collectionTitle }}</div>
        <div class="app-subtitle">数据采集详情</div>
      </div>
      
      <div class="content-area">
        <div class="collection-detail">
          <!-- 返回按钮 -->
          <div class="back-section">
            <a href="#" class="back-button" @click="goBack">
              <i class="fas fa-arrow-left"></i> 返回主界面
            </a>
          </div>
          
          <!-- 主标题 -->
          <div class="main-header">
            <h1 class="main-title">{{ collectionTitle }}</h1>
          </div>
          <div class="upload-section">
            <div class="upload-header">
            </div>
            <div class="upload-area" @click="triggerFileInput" @dragover.prevent @drop="handleDrop">
              <div class="upload-icon">
                <i class="fas fa-cloud-upload-alt"></i>
              </div>
               <div class="upload-text">上传幼种图像</div>
                  <div class="upload-subtext">支持 JPG、PNG 格式，最大 5MB</div>
                  <div class="upload-subtext">点击区域即可</div>
                     
                <input type="file" id="imageInput" class="file-input" accept="image/*" multiple>     
            </div>
                    
         <!-- 图片预览区域 -->
            <div class="image-preview-container" id="imagePreviewContainer">
               <div class="preview-title">已上传图片</div>
               <div class="image-preview" id="imagePreview"></div>
               </div>
            <input type="file" ref="fileInput"class="file-input" accept="image/*"  multiple @change="handleFileChange" hidden >
          </div>
          
          <!-- 图片预览区域（新增） -->
          <div v-if="uploadedImages.length > 0" class="image-previews">
            <div class="preview-title">已上传图片</div>
            <div class="preview-grid">
              <div 
                v-for="(image, index) in uploadedImages" 
                :key="index" 
                class="preview-item"
                @click="viewImage(index)"
              >
                <img :src="image.url" :alt="image.name" class="preview-img">
                <button class="delete-btn" @click.stop="deleteImage(index)">
                  <i class="fas fa-times"></i>
                </button>
              </div>
            </div>
          </div>
          
          <!-- 表单区域 -->
          <div class="form-sections">
            <!-- 采集名称 -->
            <div class="form-section">
              <div class="section-header">
                <div class="section-title">采集名称</div>
              </div>
              <input type="text" class="form-input large" v-model="collectionForm.name"  placeholder="请输入采集名称">
            </div>
            <div class="divider"></div>
            
            <!-- 采集位置 -->
            <div class="form-section">
              <div class="section-header">
                <div class="section-title">采集位置</div></div>
              <input type="text" class="form-input large" v-model="collectionForm.location" placeholder="请输入采集位置">
            </div>
            <div class="divider"></div>
            
            <!-- 样本数量 + 采集日期 -->
            <div class="form-section dual-column">
              <div class="form-group">
                <div class="section-header">
                  <div class="section-title">样本数量</div>
                </div>
                <input type="number" class="form-input large" v-model="collectionForm.sampleCount" placeholder="请输入样本数量">
              </div>
                    
              <div class="form-group">
                <div class="section-header">
                  <div class="section-title">采集日期</div>
                <input type="date" class="form-input large" id="collection-date" v-model="collectionForm.date">
              </div>
                <div class="date-display"></div>
              </div>
            </div>
            
            
            <div class="divider"></div>
            
            <!-- 备注信息 -->
            <div class="form-section">
              <div class="section-header">
                <div class="section-title">备注信息</div>
              </div>
              <textarea  class="form-textarea large" v-model="collectionForm.notes" placeholder="请输入备注信息"rows="3"></textarea>
            </div>
          </div>
          
          <!-- 提交按钮 -->
          <div class="submit-section">
            <button class="submit-btn" @click="submitCollection">
              提交采集数据
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 图片查看器 -->
    <ImageViewer v-if="showImageModal":images="currentImages":current-index="currentImageIndex"@close="closeImageModal" @prev="prevImage" @next="nextImage"/>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ImageDB } from '../js/indexedDB.js'
import { toast } from '../js/toast.js'
import ImageViewer from './ImageViewer.vue'

export default {
  name: 'CollectionDetail',
  components: {
    ImageViewer
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const imageDB = new ImageDB()
    const fileInput = ref(null)

    const collectionType = route.params.type
    const uploadedImages = ref([])
    const showImageModal = ref(false)
    const currentImages = ref([])
    const currentImageIndex = ref(0)

    const collectionForm = reactive({
      name: '',
      location: '',
      sampleCount: '',
      date: '',
      notes: ''
    })

    const collectionTitle = computed(() => {
      const titles = {
        'crop': '种子监测',
        'weather': '环境数据',
        'pest': '病虫害记录',
        'quick': '一键采集',
        'location': '位置记录',
        'template': '模板采集',
        'image': '图像采集'
      }
      return titles[collectionType] || '数据采集'
    })

    const formattedDate = computed(() => {
      if (collectionForm.date) {
        const date = new Date(collectionForm.date)
        return `${date.getFullYear()}/${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')}`
      }
      return ''
    })

    const triggerFileInput = () => {
      if (fileInput.value) {
        fileInput.value.click()
      }
    }

    const handleFileChange = async (event) => {
      const files = event.target.files
      if (files.length > 0) {
        await handleFiles(files)
        // 清空input值，允许重复选择相同文件
        event.target.value = ''
      }
    }

    const handleDrop = async (event) => {
      event.preventDefault()
      const files = event.dataTransfer.files
      if (files.length > 0) {
        await handleFiles(files)
      }
    }

    const handleFiles = async (files) => {
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
                id: Date.now() + Math.random(),
                fieldId: 'current',
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
          
          await imageDB.saveImage(imageData)
          uploadedImages.value.push(imageData)
          
        } catch (error) {
          console.error('处理文件失败:', error)
          toast.error(`处理文件 ${file.name} 失败`)
        }
      }
      
      toast.success(`成功上传 ${validFiles.length} 张图片`)
    }

    const viewImage = (index) => {
      currentImages.value = uploadedImages.value.map(img => img.url)
      currentImageIndex.value = index
      showImageModal.value = true
    }

    const deleteImage = async (index) => {
      const imageId = uploadedImages.value[index].id
      
      try {
        await imageDB.deleteImage(imageId)
        uploadedImages.value.splice(index, 1)
        toast.success('图片已删除')
      } catch (error) {
        console.error('删除图片失败:', error)
        toast.error('删除图片失败')
      }
    }

    const closeImageModal = () => {
      showImageModal.value = false
      currentImages.value = []
      currentImageIndex.value = 0
    }

    const prevImage = () => {
      currentImageIndex.value = (currentImageIndex.value - 1 + currentImages.value.length) % currentImages.value.length
    }

    const nextImage = () => {
      currentImageIndex.value = (currentImageIndex.value + 1) % currentImages.value.length
    }

    const submitCollection = () => {
      // 验证表单
      if (!collectionForm.name.trim()) {
        toast.error('请输入采集名称')
        return
      }
      
      if (!collectionForm.location.trim()) {
        toast.error('请输入采集位置')
        return
      }
      
      if (!collectionForm.sampleCount) {
        toast.error('请输入样本数量')
        return
      }
      
      // 这里可以添加数据提交逻辑
      console.log('提交数据:', {
        ...collectionForm,
        images: uploadedImages.value,
        type: collectionType
      })
      
      toast.success('数据提交成功！')
      
      // 延迟返回，让用户看到成功提示
      setTimeout(() => {
        router.back()
      }, 1500)
    }

    const goBack = () => {
      router.back()
    }

    onMounted(() => {
      // 设置当前日期为采集日期默认值
      const today = new Date()
      collectionForm.date = today.toISOString().split('T')[0]
    })

    return {
      collectionTitle,
      collectionForm,
      formattedDate,
      uploadedImages,
      showImageModal,
      currentImages,
      currentImageIndex,
      fileInput,
      triggerFileInput,
      handleFileChange,
      handleDrop,
      viewImage,
      deleteImage,
      closeImageModal,
      prevImage,
      nextImage,
      submitCollection,
      goBack
    }
  }
}
</script>

<style scoped>


.main-content {
    display: flex;
    flex: 1;
    overflow: hidden;
}



.function-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}



/* 返回按钮区域 */

.back-button {
  display: inline-flex;
  align-items: center;
  color: #4CAF50;
  text-decoration: none;
  font-size: 16px;
  font-weight: 500;
  padding: 8px 0;
  transition: all 0.3s;
}



/* 主标题 */
.main-header {
  margin-bottom: 30px;
  text-align: center;
}

.main-title {
  font-size: 24px;
  color: #333;
  margin: 0;
  font-weight: 600;
}

/* 上传区域 */
.upload-section {
  background: #f9fdf6;
  border-radius: 12px;

  margin-bottom: 30px;
}


.upload-title {
  font-size: 16px;
  color: #000000;
  font-weight: 500;
  margin: 0 0 5px 0;
  text-align: center;
}

.upload-subtitle {
  font-size: 14px;
  color: #000000;
  margin: 0;
  text-align: center;
}

.upload-area {
  background: #f9fdf6;
  border: 2px dashed #ddd;
  border-radius: 10px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
}

.upload-area:hover {
  border-color: #4CAF50;
  background: #f8fff8;
}

.upload-icon {
  font-size: 48px;
  color: #4CAF50;
  margin-bottom: 10px;
}

.upload-text {
  font-size: 16px;
  color: #666;
  margin: 0;
  font-weight: 500;
}


/* 图片预览区域 */


.preview-title {
  font-size: 16px;
  color: #333;
  font-weight: 500;
  margin-bottom: 15px;
}

.preview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  gap: 10px;
}

.preview-item {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
}

.preview-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.preview-item:hover .preview-img {
  transform: scale(1.05);
}

.delete-btn {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 24px;
  height: 24px;
  background: rgba(0, 0, 0, 0.6);
  border: none;
  border-radius: 50%;
  color: white;
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all 0.3s;
}

.preview-item:hover .delete-btn {
  opacity: 1;
}

.delete-btn:hover {
  background: rgba(244, 67, 54, 0.8);
}



/* 表单区域 */
.form-sections {
  margin-bottom: 40px;
}

.form-section {
  margin-bottom: 20px;
}

.form-section.dual-column {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.section-header {
  margin-bottom: 8px;
}

.section-title {
  font-size: 16px;
  color: #333;
  font-weight: 500;
}

/* 输入框样式 */
.form-textarea {
  width: 100%;
  padding: 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  color: #333;
  background: white;
  resize: vertical;
  box-sizing: border-box;
  transition: all 0.3s;
  font-family: inherit;
}

、


/* 日期显示 */
.date-display {
  padding: 15px;
  border: 1px solid #f9fdf6;
  border-radius: 8px;
  font-size: 16px;
  color: #333;
  background: #f9fdf6;
  
}

/* 提交按钮区域 */
.submit-section {
  text-align: center;
  margin-top: 40px;
}



.submit-btn:hover {
  background: #45a049;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(76, 175, 80, 0.2);
}

/* 适配移动端 */
@media (max-width: 768px) {
  .collection-detail {
    padding: 0 15px;
  }
  
  .form-section.dual-column {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .submit-btn {
    width: 100%;
  }
}
</style>