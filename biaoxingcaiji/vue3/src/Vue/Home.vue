<template>  
    <LoginForm />
</template>
<script>
import LoginForm from './Login.vue'

export default {
  name: 'LoginView',
  components: {
    LoginForm
  }
}
</script>

<style scoped>
/* 继承登录页面基础样式，保持与整体风格一致 */
.container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 20px;
  background: linear-gradient(135deg, rgba(245, 247, 241, 0.8) 0%, rgba(241, 252, 238, 0.8) 100%),
              url('https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2000&q=80') no-repeat center center fixed;
  background-size: cover;
}

.login-container {
  width: 100%;
  max-width: 400px;
  margin: 0 auto;
}

.logo-section {
  text-align: center;
  margin-bottom: 30px;
}

.logo-container {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 15px;
}

.logo-icon {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  box-shadow: 0 4px 10px rgba(90, 125, 60, 0.3);
}

.logo-icon i {
  font-size: 28px;
  color: white;
}

.logo-text {
  text-align: left;
}

.logo {
  font-size: 28px;
  font-weight: bold;
  color: var(--secondary-color);
  line-height: 1;
}

.logo-subtitle {
  color: var(--primary-color);
  font-size: 14px;
  margin-top: 5px;
}
</style>