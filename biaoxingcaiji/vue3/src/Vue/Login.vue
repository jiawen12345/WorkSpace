<template>
  <div class="container login-container">
    <div class="logo-section">
      <div class="logo-container">
        <div class="logo-icon">
          <i class="fas fa-seedling"></i>
        </div>
        <div class="logo-text">
          <div class="logo">表型采集</div>
          <div class="logo-subtitle">农业信息化管理平台</div>
        </div>
      </div>
    </div>
    
    <div class="card">
      <div class="card-title">用户登录</div>
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label class="form-label" for="username">请输入您的账号</label>
          <input type="text" class="form-input" id="username" v-model="loginForm.username" placeholder="请输入账号" required>
        </div>
        <div class="form-group">
          <label class="form-label" for="password">请输入密码</label>
          <input type="password" class="form-input" id="password" v-model="loginForm.password" placeholder="请输入密码" required>
        </div>
        <div class="options">
          <div class="remember">
            <input type="checkbox" id="remember" v-model="loginForm.remember">
            <label for="remember">记住密码</label>
          </div>
          <a href="#" class="forgot-password">忘记密码？</a>
        </div>
        <button type="submit" class="btn btn-login" @click="handleLogin"> 登录</button>
        <button type="button" class="btn btn-register" @click="goToRegister">注册账号</button>
      </form>
      <div class="version">当前版本：3.0.21.15</div>
      <div class="support">技术支持：研究中心</div>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { authApi } from '../js/api.js'

const router = useRouter()

const loginForm = reactive({
  username: '',
  password: '',
  remember: false
})

const handleLogin = async () => {
  if (loginForm.username && loginForm.password) {
    try {
      const response = await authApi.login({
        username: loginForm.username,
        password: loginForm.password
      })
      
      // 保存token
      localStorage.setItem('token', response.data.token)
      sessionStorage.setItem('user', loginForm.username)
      
      router.push('/dashboard')
    } catch (error) {
      alert('登录失败：' + (error.response?.data?.message || error.message))
    }
  } else {
    alert('请输入账号和密码')
  }
}

const goToRegister = () => {
  router.push('/register')
}
</script>

<style scoped>

</style>