// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './js/index' // 导入路由配置
import { createPinia } from 'pinia'

const app = createApp(App)
const pinia = createPinia()

// 关键步骤：安装路由和Pinia
app.use(router) // 必须先安装路由
app.use(pinia)

app.mount('#app')