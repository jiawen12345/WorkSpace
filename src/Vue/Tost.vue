<template>
  <div class="toast" :class="[type, { show: visible }]" v-if="visible">
    <i :class="iconClass"></i>
    {{ message }}
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { toast } from '../js/toast'

export default {
  name: 'ToastComponent',
  setup() {
    const visible = ref(false)
    const message = ref('')
    const type = ref('success')

    const iconClass = computed(() => {
      return type.value === 'success' 
        ? 'fas fa-check-circle' 
        : 'fas fa-exclamation-circle'
    })

    // 监听全局toast事件
    const showToast = (msg, toastType = 'success') => {
      message.value = msg
      type.value = toastType
      visible.value = true

      setTimeout(() => {
        visible.value = false
      }, 3000)
    }

    // 注册全局方法
    toast.show = showToast

    return {
      visible,
      message,
      type,
      iconClass
    }
  }
}
</script>

<style scoped>
.toast {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background-color: var(--primary-color);
  color: white;
  padding: 12px 20px;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-heavy);
  z-index: 1001;
  display: flex;
  align-items: center;
  gap: 10px;
  transform: translateY(100px);
  opacity: 0;
  transition: all 5s;
}

.toast.show {
  transform: translateY(0);
  opacity: 1;
}

.toast.error {
  background-color: var(--error-color);
}

.toast.success {
  background-color: var(--success-color);
}
</style>