<template>
  <div class="sidebar">
    <div class="nav-tabs">               
      <!-- 数据采集 -->
      <div  class="nav-tab" :class="{ active: isActive('/collection') }"  @click="goToDataCollection">
        <i class="fas fa-database"></i>
        <span class="nav-text">数据采集</span>
      </div>
      
      <!-- 快速采集 -->
      <div class="nav-tab" :class="{ active: isActive('/dashboard') && activeTab === 'quick-collection' }" @click="setActiveTab('quick-collection')">
        <i class="fas fa-bolt"></i>
        <span class="nav-text">快速采集</span>
      </div>
      
      <!-- 采集记录 -->
      <div class="nav-tab" :class="{ active: isActive('/dashboard') && activeTab === 'history' }" @click="setActiveTab('history')">
        <i class="fas fa-history"></i>
        <span class="nav-text">采集记录</span>
      </div>

      <!-- 实验管理 -->
      <div class="nav-tab" :class="{ active: isActive('/field-search') }" @click="goToFieldSearch">
        <i class="fas fa-search"></i>
        <span class="nav-text">实验管理</span>
      </div>

      <!-- 田间小区 -->
      <div class="nav-tab" :class="{ active: isActive('/field-plot') }" @click="goToFieldPlot">
        <i class="fas fa-map-marked-alt"></i>
        <span class="nav-text">田间小区</span>
      </div>                      
    </div>
  </div>
</template>

<script>
import { useRouter, useRoute } from 'vue-router'
import { useAppStore } from '../js/app.js'

export default {
  name: 'Sidebar',
  setup() {
    const router = useRouter()
    const route = useRoute()
    const appStore = useAppStore()
    
    const setActiveTab = (tab) => {
      appStore.setActiveTab(tab)
      
      // 如果是history或quick-collection，跳转到dashboard
      if (tab === 'history' || tab === 'quick-collection') {
        router.push('/dashboard')
      }
    }
    
    const goToDataCollection = () => {
      router.push('/collection')
    }
    
    const goToFieldSearch = () => {
      router.push('/field-search')
    }
    
    const goToFieldPlot = () => {
      router.push('/field-plot')
    }
    
    // 检查当前路由是否激活
    const isActive = (path) => {
      return route.path.startsWith(path)
    }
    
    return {
      activeTab: appStore.activeTab,
      setActiveTab,
      goToDataCollection,
      goToFieldSearch,
      goToFieldPlot, 
      isActive
    }
  }
}
</script>

<style scoped>

.nav-text {
  margin-left: 8px;
}

.nav-tab:hover {
  background-color: #f5f5f5;
}

.nav-tab.active {
  background-color: #e8f4ff;
  color: #1890ff;
  border-right: 3px solid #1890ff;
}
</style>