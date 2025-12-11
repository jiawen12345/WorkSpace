<template>
  <div class="sidebar">
    <div class="nav-tabs">
      <div 
        class="nav-tab" 
        :class="{ active: isActive('/collection') }" 
        @click="goToDataCollection"
      >
        <i class="fas fa-database"></i>数据采集
      </div>
      <div 
        class="nav-tab" 
        :class="{ active: isActive('/dashboard') && activeTab === 'quick-collection' }" 
        @click="setActiveTab('quick-collection')"
      >
        <i class="fas fa-bolt"></i>快速采集
      </div>
      <div 
        class="nav-tab" 
        :class="{ active: isActive('/field-search') }" 
        @click="goToFieldSearch"
      >
        <i class="fas fa-search"></i>种子编号查询
      </div>
      <div 
        class="nav-tab" 
        :class="{ active: isActive('/dashboard') && activeTab === 'history' }" 
        @click="setActiveTab('history')"
      >
        <i class="fas fa-history"></i>采集记录
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
    
    // 检查当前路由是否激活
    const isActive = (path) => {
      return route.path.startsWith(path)
    }
    
    return {
      activeTab: appStore.activeTab,
      setActiveTab,
      goToDataCollection,
      goToFieldSearch,
      isActive
    }
  }
}
</script>

<style scoped>

</style>