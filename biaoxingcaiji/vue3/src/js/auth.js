import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authApi } from './api.js'; 

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null);
  const isLoggedIn = ref(false);
  const accessToken = ref(localStorage.getItem('access_token'));
  const refreshToken = ref(localStorage.getItem('refresh_token'));

  const login = async (username, password) => {
    try {
      const response = await authApi.login(username, password)
      const { access, refresh } = response.data
      
      user.value = { username };           // 存储用户名
      isLoggedIn.value = true;             // 标记为已登录
      accessToken.value = access;          // 存储 access token
      refreshToken.value = refresh;        // 存储 refresh token
      
      localStorage.setItem('access_token', access)
      localStorage.setItem('refresh_token', refresh)
      localStorage.setItem('user', JSON.stringify({ username }))
      
      return response
    } catch (error) {
      throw error
    }
  };

  const logout = () => {
    user.value = null;
    isLoggedIn.value = false;
    accessToken.value = null;
    refreshToken.value = null;
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('user');
  };

  const initialize = async () => {
    const savedAccessToken = localStorage.getItem('access_token');
    const savedUser = localStorage.getItem('user');
    
    if (savedAccessToken && savedUser) {
      try {
        // 验证 token 是否有效
        await authApi.verifyToken()
        user.value = JSON.parse(savedUser);
        isLoggedIn.value = true;
        accessToken.value = savedAccessToken;
        refreshToken.value = localStorage.getItem('refresh_token')
      } catch (error) {
        // Token 无效，清除存储
        logout()
      }
    }
  };

  return {
    user,
    isLoggedIn,
    accessToken,
    refreshToken,
    login,
    logout,
    initialize
  };
});