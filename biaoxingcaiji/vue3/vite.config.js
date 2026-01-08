import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    host: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8000', // Django 后端
        changeOrigin: true,
        secure: false
      }
    }
  },
  resolve: {
    alias: {
      '@': '/src'  
    }
  }
})