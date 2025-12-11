<template>
  <div id="app">
    <!-- 使用 router-view 让路由生效 -->
    <router-view />
  </div>
</template>
<script>
import { ref, onMounted } from 'vue'

// 修复导入路径 - 根据实际文件结构调整
import LoginView from './Vue/Login.vue'
import DashboardView from './Vue/Dashboard.vue'

export default {
  name: 'App',
  components: {
    LoginView,
    DashboardView
  },
  setup() {
    const isLoggedIn = ref(false)

    onMounted(() => {
      const token = localStorage.getItem('token')
      isLoggedIn.value = !!token
      console.log('App mounted, isLoggedIn:', isLoggedIn.value)
    })

    return {
      isLoggedIn
    }
  },
}
</script>



<style>
body {
  font-family: "Microsoft YaHei", sans-serif;
  margin: 0;
  padding: 0;
}

#app {
  min-height: 100vh;
}
</style> 