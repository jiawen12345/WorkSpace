<template>
  <div class="center-upload" v-if="!isHidden">
    <div 
      class="upload-panel" 
      :class="{ 'drag-over': isDragOver }"
      @dragover.prevent="isDragOver = true"
      @dragleave.prevent="isDragOver = false"
      @drop.prevent="handleDrop"
    >
   
      <button class="close-btn" @click="hidePanel">
        <i class="fas fa-times"></i>
      </button>
      <div class="upload-content">
        <div class="upload-icon">
          <i class="fas fa-cloud-upload-alt"></i>
        </div>
        <h3 class="upload-title">上传实验数据</h3>
        <p class="upload-text">点击或拖拽文件到此处上传 </p>
        <p class="upload-hint">
          支持 CSV、Excel 格式文件，最大 10MB</p>
        <button class="upload-btn" @click="triggerFileInput">
          <i class="fas fa-upload"></i>选择文件上传</button>
        <input  ref="fileInput" type="file" accept=".csv,.xls,.xlsx" @change="handleFileSelect" hidden/>
        <div v-if="selectedFile" class="file-info">
          <div class="file-details">
            <i class="fas fa-file-excel"></i>
            <div class="file-text">
              <span class="file-name">{{ selectedFile.name }}</span>
              <span class="file-size">{{ formatFileSize(selectedFile.size) }}</span>
            </div>
          </div>
          <div class="file-actions">
            <button class="action-btn confirm-btn" @click="uploadFile">
              <i class="fas fa-check"></i>
              确认上传
            </button>
            <button class="action-btn cancel-btn" @click="removeFile">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- 显示按钮（当面板隐藏时显示） -->
  <div class="show-upload-btn" v-if="isHidden" @click="showPanel">
    <i class="fas fa-cloud-upload-alt"></i>
    <span>上传数据</span>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const isDragOver = ref(false)
const isHidden = ref(false)
const fileInput = ref(null)
const selectedFile = ref(null)

const handleDrop = (e) => {
  isDragOver.value = false
  const files = e.dataTransfer.files
  if (files.length > 0) {
    selectedFile.value = files[0]
    console.log('拖拽上传:', selectedFile.value)
  }
}

const triggerFileInput = () => {
  fileInput.value.click()
}

const handleFileSelect = (e) => {
  const files = e.target.files
  if (files.length > 0) {
    selectedFile.value = files[0]
    console.log('选择文件:', selectedFile.value)
  }
}

const removeFile = () => {
  selectedFile.value = null
  fileInput.value.value = ''
}

const uploadFile = () => {
  if (selectedFile.value) {
    console.log('开始上传文件:', selectedFile.value.name)
    // 这里添加上传逻辑
    // 上传成功后...
    selectedFile.value = null
    fileInput.value.value = ''
    // 可以选择自动关闭面板
    // hidePanel()
  }
}

const hidePanel = () => {
  isHidden.value = true
}

const showPanel = () => {
  isHidden.value = false
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}
</script>

<style scoped>
.center-upload {
  position: fixed;
  left: 50%;
  bottom: 40px;
  transform: translateX(-50%);
  z-index: 1000;
  width: 100%;
  max-width: 800px;
  padding: 0 20px;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translate(-50%, 20px);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0);
  }
}

.upload-panel {
  position: relative;
  width: 100%;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(15px);
  -webkit-backdrop-filter: blur(15px);
  border-radius: 20px;
  border: 2px solid rgba(76, 175, 80, 0.2);
  box-shadow: 
    0 10px 40px rgba(0, 0, 0, 0.2),
    0 0 0 1px rgba(255, 255, 255, 0.3) inset;
  transition: all 0.3s ease;
}

/* 关闭按钮 */
.close-btn {
  position: absolute;
  top: 15px;
  right: 15px;
  width: 36px;
  height: 36px;
  background: rgba(0, 0, 0, 0.1);
  border: none;
  border-radius: 50%;
  color: #666;
  font-size: 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  z-index: 1001;
}

.close-btn:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #f44336;
  transform: rotate(90deg);
}

.upload-panel.drag-over {
  background: rgba(76, 175, 80, 0.98);
  border-color: rgba(76, 175, 80, 0.8);
  box-shadow: 
    0 15px 50px rgba(76, 175, 80, 0.4),
    0 0 0 2px rgba(76, 175, 80, 0.6) inset;
  transform: translateY(-5px);
}

.upload-panel.drag-over .upload-title,
.upload-panel.drag-over .upload-text,
.upload-panel.drag-over .upload-hint {
  color: white;
}

.upload-panel.drag-over .upload-icon i {
  color: white;
}

.upload-content {
  padding: 40px;
  text-align: center;
}

.upload-icon {
  font-size: 80px;
  color: #4CAF50;
  margin-bottom: 20px;
  opacity: 0.9;
}

.upload-title {
  color: #333;
  font-size: 24px;
  margin: 0 0 15px 0;
  font-weight: 600;
}

.upload-text {
  color: #333;
  font-size: 18px;
  margin: 0 0 10px 0;
  font-weight: 500;
  opacity: 0.9;
}

.upload-hint {
  color: #666;
  font-size: 14px;
  margin: 0 0 30px 0;
  opacity: 0.8;
}

.upload-btn {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 18px 40px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
  min-width: 200px;
}

.upload-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 30px rgba(76, 175, 80, 0.4);
}

.cancel-btn {
  background: rgba(0, 0, 0, 0.1);
  color: #666;
  width: 50px;
  padding: 12px;
}

.cancel-btn:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #f44336;
}

/* 显示上传按钮 */
.show-upload-btn {
  position: fixed;
  right: 30px;
  bottom: 30px;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  padding: 15px 25px;
  border-radius: 50px;
  box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 500;
  transition: all 0.3s;
  z-index: 999;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.show-upload-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 30px rgba(76, 175, 80, 0.4);
}
</style>

