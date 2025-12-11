import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null);
  const isLoggedIn = ref(false);
  const token = ref(localStorage.getItem('token'));

  const login = (userData, authToken) => {
    user.value = userData;
    isLoggedIn.value = true;
    token.value = authToken;
    localStorage.setItem('token', authToken);
    localStorage.setItem('user', JSON.stringify(userData));
  };

  const logout = () => {
    user.value = null;
    isLoggedIn.value = false;
    token.value = null;
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  };

  const initialize = () => {
    const savedToken = localStorage.getItem('token');
    const savedUser = localStorage.getItem('user');
    
    if (savedToken && savedUser) {
      user.value = JSON.parse(savedUser);
      isLoggedIn.value = true;
      token.value = savedToken;
    }
  };

  return {
    user,
    isLoggedIn,
    token,
    login,
    logout,
    initialize
  };
});