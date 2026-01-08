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
    
    <div class="card register-form">
      <div class="card-title">用户注册</div>
      <form @submit.prevent="handleRegister">
        <div class="form-group">
          <label class="form-label" for="reg-username">设置用户名</label>
          <input 
            type="text" 
            class="form-input" 
            id="reg-username" 
            v-model="registerForm.username" 
            placeholder="请输入用户名（4-20位字母、数字或下划线）" 
            required
            :class="{ error: registerForm.usernameError, success: registerForm.usernameValid }"
            @blur="validateUsername"
          >
          <div class="validation-message error" v-if="registerForm.usernameError">
            <i class="fas fa-exclamation-circle"></i>{{ registerForm.usernameError }}
          </div>
          <div class="validation-message success" v-if="registerForm.usernameValid">
            <i class="fas fa-check-circle"></i>用户名格式正确
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-phone">手机号码</label>
          <input 
            type="tel" 
            class="form-input" 
            id="reg-phone" 
            v-model="registerForm.phone" 
            placeholder="请输入手机号码" 
            required
            :class="{ error: registerForm.phoneError, success: registerForm.phoneValid }"
            @blur="validatePhone"
          >
          <div class="validation-message error" v-if="registerForm.phoneError">
            <i class="fas fa-exclamation-circle"></i>{{ registerForm.phoneError }}
          </div>
          <div class="validation-message success" v-if="registerForm.phoneValid">
            <i class="fas fa-check-circle"></i>手机号码格式正确
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-email">电子邮箱</label>
          <input 
            type="email" 
            class="form-input" 
            id="reg-email" 
            v-model="registerForm.email" 
            placeholder="请输入电子邮箱" 
            required
            :class="{ error: registerForm.emailError, success: registerForm.emailValid }"
            @blur="validateEmail"
          >
          <div class="validation-message error" v-if="registerForm.emailError">
            <i class="fas fa-exclamation-circle"></i>{{ registerForm.emailError }}
          </div>
          <div class="validation-message success" v-if="registerForm.emailValid">
            <i class="fas fa-check-circle"></i>邮箱格式正确
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-password">设置密码</label>
          <input 
            type="password" 
            class="form-input" 
            id="reg-password" 
            v-model="registerForm.password" 
            placeholder="请设置登录密码（8-20位，包含字母和数字）" 
            required
            :class="{ error: registerForm.passwordError, success: registerForm.passwordValid }"
            @input="validatePassword"
          >
          <div class="password-strength" id="passwordStrength">
            <div class="password-strength-bar" :class="passwordStrengthClass" :style="{ width: passwordStrengthWidth }"></div>
          </div>
          <div class="validation-message error" v-if="registerForm.passwordError">
            <i class="fas fa-exclamation-circle"></i>{{ registerForm.passwordError }}
          </div>
          <div class="validation-message success" v-if="registerForm.passwordValid">
            <i class="fas fa-check-circle"></i>密码强度足够
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-confirm-password">确认密码</label>
          <input 
            type="password" 
            class="form-input" 
            id="reg-confirm-password" 
            v-model="registerForm.confirmPassword" 
            placeholder="请再次输入密码" 
            required
            :class="{ error: registerForm.confirmPasswordError, success: registerForm.confirmPasswordValid }"
            @blur="validateConfirmPassword"
          >
          <div class="validation-message error" v-if="registerForm.confirmPasswordError">
            <i class="fas fa-exclamation-circle"></i>{{ registerForm.confirmPasswordError }}
          </div>
          <div class="validation-message success" v-if="registerForm.confirmPasswordValid">
            <i class="fas fa-check-circle"></i>密码匹配
          </div>
        </div>
        
        <button type="submit" class="btn btn-login" :disabled="!isFormValid">注册</button>
        <button type="button" class="btn btn-register" @click="goToLogin">返回登录</button>
        <div class="agreement">
          注册即表示同意 <a href="#">《用户协议》</a> 和 <a href="#">《隐私政策》</a>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { calculatePasswordStrength, validators } from '../js/validators.js'
import { authApi } from '../js/api.js' 

const router = useRouter()

const registerForm = reactive({
  username: '',
  phone: '',
  email: '',
  password: '',
  confirmPassword: '',
  usernameError: '',
  phoneError: '',
  emailError: '',
  passwordError: '',
  confirmPasswordError: '',
  usernameValid: false,
  phoneValid: false,
  emailValid: false,
  passwordValid: false,
  confirmPasswordValid: false
})

// 添加加载状态
const isLoading = reactive({
  register: false
})

// 添加消息状态
const message = reactive({
  text: '',
  type: '' // 'success' 或 'error'
})

const passwordStrength = computed(() => {
  return calculatePasswordStrength(registerForm.password)
})

const passwordStrengthClass = computed(() => passwordStrength.value.class)
const passwordStrengthWidth = computed(() => passwordStrength.value.width)

const isFormValid = computed(() => {
  return registerForm.usernameValid && 
         registerForm.phoneValid && 
         registerForm.emailValid && 
         registerForm.passwordValid && 
         registerForm.confirmPasswordValid
})

const validateUsername = () => {
  registerForm.usernameError = validators.username(registerForm.username)
  registerForm.usernameValid = !registerForm.usernameError
}

const validatePhone = () => {
  registerForm.phoneError = validators.phone(registerForm.phone)
  registerForm.phoneValid = !registerForm.phoneError
}

const validateEmail = () => {
  registerForm.emailError = validators.email(registerForm.email)
  registerForm.emailValid = !registerForm.emailError
}

const validatePassword = () => {
  registerForm.passwordError = validators.password(registerForm.password)
  registerForm.passwordValid = !registerForm.passwordError
}

const validateConfirmPassword = () => {
  registerForm.confirmPasswordError = validators.confirmPassword(
    registerForm.password, 
    registerForm.confirmPassword
  )
  registerForm.confirmPasswordValid = !registerForm.confirmPasswordError
}

// 修改 handleRegister 函数，添加后端调用
const handleRegister = async () => {
  // 验证所有字段
  validateUsername()
  validatePhone()
  validateEmail()
  validatePassword()
  validateConfirmPassword()

  if (!isFormValid.value) {
    showMessage('请正确填写所有必填字段', 'error')
    return
  }

  // 设置加载状态
  isLoading.register = true
  showMessage('注册中...', '')

  try {
    // 调用后端注册API
    const response = await authApi.register({
      username: registerForm.username,
      phone: registerForm.phone,
      email: registerForm.email,
      password: registerForm.password,
      confirmPassword: registerForm.confirmPassword  
    })

    console.log('注册成功:', response.data)
    
    // 显示成功消息
    showMessage('注册成功！请使用新账号登录', 'success')
    
    // 3秒后跳转到登录页
    setTimeout(() => {
      router.push('/login')
    }, 3000)

  } catch (error) {
    console.error('注册失败:', error)
    
    // 处理错误响应
    let errorMessage = '注册失败，请重试'
    
    if (error.response) {
      // 从后端获取错误信息
      const errorData = error.response.data
      
      if (errorData.username) {
        errorMessage = `用户名错误: ${errorData.username.join(', ')}`
      } else if (errorData.email) {
        errorMessage = `邮箱错误: ${errorData.email.join(', ')}`
      } else if (errorData.password) {
        errorMessage = `密码错误: ${errorData.password.join(', ')}`
      } else if (errorData.non_field_errors) {
        errorMessage = errorData.non_field_errors.join(', ')
      } else if (typeof errorData === 'object') {
        // 尝试提取第一个错误
        const firstError = Object.values(errorData)[0]
        errorMessage = Array.isArray(firstError) ? firstError[0] : firstError
      }
    }
    
    showMessage(errorMessage, 'error')
  } finally {
    isLoading.register = false
  }
}

// 添加显示消息的函数
const showMessage = (text, type) => {
  message.text = text
  message.type = type
  
  // 5秒后清除消息
  if (text) {
    setTimeout(() => {
      message.text = ''
      message.type = ''
    }, 5000)
  }
}

const goToLogin = () => {
  router.push('/login')
}
</script>

<style scoped>
.container {
  max-width: 400vw;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
}
</style>