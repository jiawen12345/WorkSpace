<template>
  <div class="image-preview-container" v-if="images.length > 0">
    <div class="preview-title">{{ title }}</div>
    <div class="image-preview">
      <div class="preview-item" v-for="(image, index) in images" :key="getImageKey(image, index)">
        <img :src="getImageUrl(image)" :alt="getImageName(image, index)">
        <div class="preview-actions">
          <button class="preview-action-btn view-btn" title="查看" @click="$emit('view', index)">
            <i class="fas fa-eye"></i>
          </button>
          <button class="preview-action-btn delete-btn" title="删除" @click="$emit('delete', index)">
            <i class="fas fa-trash"></i>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImagePreview',
  props: {
    images: {
      type: Array,
      default: () => []
    },
    title: {
      type: String,
      default: '已上传图片'
    }
  },
  emits: ['view', 'delete'],
  methods: {
    getImageKey(image, index) {
      return image.id || image.name || index
    },
    getImageUrl(image) {
      return image.url || image
    },
    getImageName(image, index) {
      return image.name || `图片 ${index + 1}`
    }
  }
}
</script>

<style scoped>
.image-preview-container {
  margin-top: 20px;
  display: block;
}

.preview-title {
  font-size: 18px;
  color: var(--text-primary);
  margin-bottom: 15px;
  text-align: left;
}

.image-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-top: 10px;
}

.preview-item {
  width: 120px;
  height: 120px;
  border-radius: 8px;
  overflow: hidden;
  position: relative;
  border: 2px solid transparent;
  transition: all 0.3s;
}

.preview-item:hover {
  border-color: var(--primary-color);
  transform: scale(1.05);
}

.preview-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.preview-actions {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: space-around;
  padding: 5px;
  transform: translateY(100%);
  transition: all 0.3s;
}

.preview-item:hover .preview-actions {
  transform: translateY(0);
}

.preview-action-btn {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  font-size: 14px;
  padding: 5px;
  border-radius: 4px;
  transition: all 0.3s;
}

.preview-action-btn:hover {
  background-color: rgba(255, 255, 255, 0.2);
}
</style>