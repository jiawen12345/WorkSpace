<template>
  <div class="modal active">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title">上传实验编号数据</h3>
        <button class="close-modal" @click="$emit('close')">&times;</button>
      </div>
      <div class="upload-area" @click="triggerFileInput">
        <i class="fas fa-cloud-upload-alt"></i>
        <h3>点击或拖拽文件到此处上传</h3>
        <p>支持 CSV、Excel 格式文件，最大 10MB</p>
        <input type="file" id="fileInput" class="file-input" accept=".csv,.xlsx,.xls" @change="handleFileUpload">
      </div>
      <div class="file-info" v-if="uploadFile">
        <i class="fas fa-file"></i>
        <span>{{ uploadFile.name }}</span>
        <span>{{ (uploadFile.size / 1024 / 1024).toFixed(2) }} MB</span>
      </div>
      <div class="modal-actions">
        <button class="cancel-btn" @click="$emit('close')">取消</button>
        <button class="confirm-btn" @click="confirmUpload" :disabled="!uploadFile">上传</button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'UploadModal',
  emits: ['close', 'confirm'],
  setup(props, { emit }) {
    const uploadFile = ref(null)

    const triggerFileInput = () => {
      document.getElementById('fileInput').click()
    }

    const handleFileUpload = (event) => {
      uploadFile.value = event.target.files[0]
    }

    const confirmUpload = () => {
      if (uploadFile.value) {
        emit('confirm', uploadFile.value)
      }
    }

    return {
      uploadFile,
      triggerFileInput,
      handleFileUpload,
      confirmUpload
    }
  }
}
</script>

<style scoped>
.upload-area {
  border: 2px dashed #c0d4b0;
  border-radius: 10px;
  padding: 40px 20px;
  text-align: center;
  margin-bottom: 20px;
  cursor: pointer;
  transition: all 0.3s;
  background-color: var(--bg-primary);
}

.upload-area:hover {
  background-color: var(--bg-secondary);
}

.upload-area i {
  font-size: 48px;
  color: var(--primary-light);
  margin-bottom: 15px;
}

.upload-area h3 {
  font-size: 18px;
  color: var(--text-primary);
  margin-bottom: 10px;
}

.upload-area p {
  font-size: 14px;
  color: var(--text-light);
}

.file-input {
  display: none;
}

.file-info {
  margin-top: 15px;
  padding: 10px;
  background-color: var(--bg-tertiary);
  border-radius: 8px;
  font-size: 14px;
  color: var(--primary-color);
  display: flex;
  align-items: center;
  gap: 10px;
}
</style>