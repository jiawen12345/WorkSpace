<template>
  <div class="download-modal-overlay" @click.self="$emit('close')">
    <div class="download-modal">
      <div class="modal-header">
        <h3>采集记录</h3>
      </div>
      
      <div class="search-section">
        <div class="search-input">
          <input 
            type="text" 
            v-model="searchNumber" 
            placeholder="输入编号，如：25KY00076"
            @keyup.enter="handleSearch"
          />
          <button class="search-btn" @click="handleSearch">搜索</button>
        </div>
        <div class="search-hint" v-if="searchNumber">当前编号：{{ searchNumber }}</div>
      </div>
      
      <div class="download-section">
        <div class="download-options">
          <label class="download-option">
            <input type="radio" v-model="downloadType" value="all">
            <span class="option-content">
              <span class="option-title">下载全部数据</span>
              <span class="option-desc">包含所有编号信息</span>
            </span>
          </label>
          
          <label class="download-option">
            <input type="radio" v-model="downloadType" value="current">
            <span class="option-content">
              <span class="option-title">下载当前页面数据</span>
              <span class="option-desc">仅包含当前显示的数据</span>
            </span>
          </label>
          
          <label class="download-option">
            <input type="radio" v-model="downloadType" value="selected">
            <span class="option-content">
              <span class="option-title">下载选中数据</span>
              <span class="option-desc">仅包含选中的数据行</span>
            </span>
          </label>
        </div>
      </div>
      
      <div class="modal-footer">
        <button class="btn cancel" @click="$emit('close')">取消</button>
        <button class="btn download" @click="startDownload">下载</button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'DownloadModal',
  emits: ['close', 'confirm', 'search'],
  setup(props, { emit }) {
    const searchNumber = ref('')
    const downloadType = ref('current')

    const handleSearch = () => {
      if (searchNumber.value.trim()) {
        emit('search', searchNumber.value.trim())
      }
    }

    const startDownload = () => {
      console.log('开始下载:', downloadType.value)
      
      // 模拟下载文件
      const data = {
        type: downloadType.value,
        searchNumber: searchNumber.value,
        timestamp: new Date().toISOString()
      }
      
      const jsonString = JSON.stringify(data, null, 2)
      const blob = new Blob([jsonString], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `采集数据_${new Date().getTime()}.json`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)
      
      emit('confirm')
      emit('close')
    }

    return {
      searchNumber,
      downloadType,
      handleSearch,
      startDownload
    }
  }
}
</script>

<style scoped>
.download-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
}

.download-modal {
  background: white;
  width: 480px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  overflow: hidden;
}

.modal-header {
  padding: 20px 24px 16px;
  border-bottom: 1px solid #e8e8e8;
}

.modal-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
  line-height: 24px;
}

.search-section {
  padding: 20px 24px;
  border-bottom: 1px solid #e8e8e8;
}
.search-input input {
  flex: 1;
  height: 32px;
  padding: 4px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  color: #333;
  outline: none;
  transition: all 0.3s;
}

.search-input input:focus {
  border-color: #5a7d3c;
  box-shadow: 0 0 0 2px rgba(111, 148, 64, 0.2);
}

.search-input input::placeholder {
  color: #999;
}

.search-btn:hover {
  background: #5a7d3c;
  border-color: #5a7d3c;
}

.search-hint {
  font-size: 12px;
  color: #666;
  line-height: 20px;
  padding-left: 4px;
}

.download-section {
  padding: 20px 24px;
}

.download-options {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.download-option:hover {
  border-color: #5a7d3c;
  background: #f0f9ff;
}

.download-option input {
  margin: 2px 12px 0 0;
  cursor: pointer;
}

.option-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.option-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  line-height: 22px;
}

.option-desc {
  font-size: 12px;
  color: #666;
  line-height: 20px;
}

.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid #e8e8e8;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  background: #fafafa;
}

.btn {
  height: 32px;
  padding: 0 15px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  line-height: 30px;
}

.btn.cancel {
  background: white;
  color: #333;
}

.btn.cancel:hover {
  color: #5a7d3c;
  border-color: #5a7d3c;
}

.btn.download {
  background: #5a7d3c;
  border-color: #5a7d3c;
  color: white;
}

.btn.download:hover {
  background: #5a7d3c;
  border-color: #5a7d3c;
}
</style>