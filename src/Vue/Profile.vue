<template>
  <div class="container">
    <div class="main-container">
      <div class="app-header">
        <div class="app-logo">
          <div class="app-logo-icon">
            <i class="fas fa-seedling"></i>
          </div>
          <div class="app-logo-text">种子图谱</div>
        </div>
        <div class="app-title">个人信息</div>
        <div class="app-subtitle">个人资料与账户设置</div>
      </div>

      <div class="content-area">
        <div class="profile-detail-page">
          <a href="#" class="back-button" @click="goBack">
            <i class="fas fa-arrow-left"></i> 返回主界面
          </a>
          <div class="profile-detail-header">
            <div class="profile-detail-avatar">
              <i class="fas fa-user"></i>
            </div>
            <h2 class="profile-detail-title">{{ user?.displayName || '种子图谱' }}</h2>
            <p class="profile-detail-subtitle">{{ user?.role || '农业研究员' }} | {{ user?.department || '种子图谱项目组' }}</p>
          </div>
          
          <div class="profile-detail-stats">
            <div class="profile-detail-stat">
              <div class="profile-detail-stat-number">156</div>
              <div class="profile-detail-stat-label">采集任务</div>
            </div>
            <div class="profile-detail-stat">
              <div class="profile-detail-stat-number">2,847</div>
              <div class="profile-detail-stat-label">样本数量</div>
            </div>
            <div class="profile-detail-stat">
              <div class="profile-detail-stat-number">98%</div>
              <div class="profile-detail-stat-label">完成率</div>
            </div>                   
          </div>
          <div class="profile-detail-form">
            <h3 class="section-title">个人信息</h3>
            <div class="form-group">
              <label class="form-label" for="profile-username">用户名</label>
              <input type="text" class="form-input" id="profile-username" :value="user?.username || 'jinzhongzi'" readonly>
            </div>
            <div class="form-group">
              <label class="form-label" for="profile-displayname">显示名称</label>
              <input type="text" class="form-input" id="profile-displayname" v-model="profileForm.displayName">
            </div>
            <div class="form-group">
              <label class="form-label" for="profile-phone">手机号码</label>
              <input type="tel" class="form-input" id="profile-phone" v-model="profileForm.phone">
            </div>
            <div class="form-group">
              <label class="form-label" for="profile-email">电子邮箱</label>
              <input type="email" class="form-input" id="profile-email" v-model="profileForm.email">
            </div>
            <div class="form-group">
              <label class="form-label" for="profile-department">所属部门</label>
              <input type="text" class="form-input" id="profile-department" v-model="profileForm.department">
            </div>
            <div class="form-group">
              <label class="form-label" for="profile-register-time">注册时间</label>
              <input type="text" class="form-input" id="profile-register-time" value="2025-03-15" readonly>
            </div>
            <div class="form-group">
              <label class="form-label" for="profile-last-login">最后登录</label>
              <input type="text" class="form-input" id="profile-last-login" value="2025-05-20 14:30" readonly>
            </div>
            
            <h3 class="section-title" style="margin-top: 30px;">账户设置</h3>
            <div class="form-group">
              <label class="form-label" for="profile-notifications">通知设置</label>
              <select class="form-input" id="profile-notifications" v-model="profileForm.notifications">
                <option value="all">接收所有通知</option>
                <option value="important">仅接收重要通知</option>
                <option value="none">不接收通知</option>
              </select>
            </div>
            <div class="profile-detail-actions">
              <button class="profile-cancel-btn" @click="goBack">取消</button>
              <button class="profile-save-btn" @click="saveProfile">保存更改</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../js/auth'
import { toast } from '../js/toast'

export default {
  name: 'Profile',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()

    const profileForm = reactive({
      displayName: '',
      phone: '',
      email: '',
      department: '',
      notifications: 'important'
    })

    const saveProfile = () => {
      // 更新用户信息
      if (authStore.user) {
        authStore.user.displayName = profileForm.displayName
        authStore.user.phone = profileForm.phone
        authStore.user.email = profileForm.email
        authStore.user.department = profileForm.department
      }
      
      toast.success('个人信息保存成功！')
      goBack()
    }

    const goBack = () => {
      router.back()
    }

    onMounted(() => {
      // 初始化表单数据
      if (authStore.user) {
        profileForm.displayName = authStore.user.displayName || '种子图谱'
        profileForm.phone = authStore.user.phone || '138****5678'
        profileForm.email = authStore.user.email || 'jinzhongzi@qq.com'
        profileForm.department = authStore.user.department || '农业信息化研究中心'
      }
    })

    return {
      user: authStore.user,
      profileForm,
      saveProfile,
      goBack
    }
  }
}
</script>

<style scoped>

.main-content {
    display: flex;
    flex: 1;
    overflow: hidden;
}


.section-title {
    font-size: 20px;
    color: var(--text-dark);
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid var(--border-color);
}

.function-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}
</style>