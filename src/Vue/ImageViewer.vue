<template>
  <div class="image-modal active" @click.self="$emit('close')">
    <div class="modal-image-container">
      <button class="modal-close" @click="$emit('close')">
        <i class="fas fa-times"></i>
      </button>
      
      <!-- 工具栏 -->
      <div class="image-toolbar">
        <button class="tool-btn" @click="downloadImage" title="下载">
          <i class="fas fa-download"></i>
        </button>
        <button class="tool-btn delete-btn" @click="deleteImage" title="删除">
          <i class="fas fa-trash"></i>
        </button>
      </div>
      
      <img class="modal-image" :src="currentImageUrl" alt="查看图片">
      
      <div class="modal-nav" v-if="images.length > 1">
        <button class="nav-btn" @click="$emit('prev')">
          <i class="fas fa-chevron-left"></i>
        </button>
        <div class="image-counter">{{ currentIndex + 1 }}/{{ images.length }}</div>
        <button class="nav-btn" @click="$emit('next')">
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import { toast } from '../js/toast.js'

export default {
  name: 'ImageViewer',
  props: {
    images: {
      type: Array,
      default: () => []
    },
    currentIndex: {
      type: Number,
      default: 0
    }
  },
  emits: ['close', 'prev', 'next', 'delete'],
  setup(props, { emit }) {
    const currentImageUrl = computed(() => {
      return props.images[props.currentIndex] || ''
    })
    
    // 下载图片
    const downloadImage = () => {
      try {
        const imageUrl = currentImageUrl.value
        if (!imageUrl) {
          toast.error('无法获取图片')
          return
        }
        
        const link = document.createElement('a')
        link.href = imageUrl
        link.download = `种子图片_${Date.now()}.jpg`
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        
        toast.success('图片下载成功')
      } catch (error) {
        console.error('下载失败:', error)
        toast.error('下载失败')
      }
    }
    
    const deleteImage = () => {
      emit('delete', props.currentIndex)
    }
    
    return {
      currentImageUrl,
      downloadImage,
      deleteImage
    }
  }
}
</script>

<style scoped>

/* 工具栏 */
.image-toolbar {
  position: absolute;
  top: 10px;
  right: 60px;
  display: flex;
  gap: 10px;
  z-index: 10;
}

.tool-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  transition: all 0.3s;
}

.tool-btn:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: scale(1.1);
}

.delete-btn:hover {
  background: rgba(220, 53, 69, 0.8);
}


.modal-close:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: scale(1.1);
}

.modal-nav {
  position: absolute;
  bottom: 20px;
  left: 0;
  width: 100%;
  display: flex;
  align-items: center;
  gap: 30px;
}



.nav-btn:hover {
  background: rgba(255, 255, 255, 0.4);
}


</style>