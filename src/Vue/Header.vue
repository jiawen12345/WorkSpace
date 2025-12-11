<template>
  <div class="app-header">
    <div class="app-logo">
      <div class="app-logo-icon">
        <i class="fas fa-seedling"></i>
      </div>
      <div class="app-logo-text">种子图谱</div>
    </div>
    <div class="app-title">移动采集系统</div>
    <div class="app-subtitle">便捷高效的农业数据采集工具</div>
    <div class="user-menu" @click="toggleProfileDropdown">
      <i class="fas fa-user"></i>
    </div>

    <!-- 个人中心下拉菜单 -->
    <div class="profile-dropdown" :class="{ active: showProfileDropdown }">
      <div class="dropdown-header">
        <div class="dropdown-avatar">
          <i class="fas fa-user"></i>
        </div>
        <div class="dropdown-user-info">
          <h4>{{ user?.displayName || '种子图谱' }}</h4>
          <p>{{ user?.role || '农业研究员' }} | {{ user?.department || '种子图谱项目组' }}</p>
        </div>
      </div>
      <div class="dropdown-stats">
        <div class="dropdown-stat">
          <div class="dropdown-stat-number">156</div>
          <div class="dropdown-stat-label">采集任务</div>
        </div>
        <div class="dropdown-stat">
          <div class="dropdown-stat-number">2,847</div>
          <div class="dropdown-stat-label">样本数量</div>
        </div>
        <div class="dropdown-stat">
          <div class="dropdown-stat-number">98%</div>
          <div class="dropdown-stat-label">完成率</div>
        </div>
      </div>
      <div class="dropdown-menu">
        <div class="dropdown-item" @click="goToProfile">
          <i class="fas fa-user-circle"></i>
          <span>个人信息</span>
        </div>
        <div class="dropdown-item">
          <i class="fas fa-cog"></i>
          <span>消息通知</span>
        </div>
      </div>
      <div class="dropdown-footer">
        <button class="dropdown-logout" @click="logout">
          <i class="fas fa-sign-out-alt">退出登入</i> 
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../js/auth.js'


export default {
  name: 'AppHeader',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    const showProfileDropdown = ref(false)

    const toggleProfileDropdown = () => {
      showProfileDropdown.value = !showProfileDropdown.value
    }

    const goToProfile = () => {
      router.push('/profile')
      showProfileDropdown.value = false
    }

    const logout = () => {
      authStore.logout()
      router.push('/login')
      showProfileDropdown.value = false
    }

    return {
      user: authStore.user,
      showProfileDropdown,
      toggleProfileDropdown,
      goToProfile,
      logout
    }
  }
}

const handleLogout = async () => {
  try {
    authStore.logout()
    // 同样使用 replace 方法
    router.replace('/login')
  } catch (error) {
    console.error('退出登录失败:', error)
    router.replace('/login')
  }
}
</script>

<style scoped>


</style>