import axios from 'axios';

// 获取 CSRF token 的辅助函数
function getCSRFToken() {
  const name = 'csrftoken';
  let cookieValue = null;
  if (document.cookie && document.cookie !== '') {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim();
      if (cookie.substring(0, name.length + 1) === (name + '=')) {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

// 跨域链接后端链接
const apiClient = axios.create({
  baseURL: 'http://localhost:8000/api/',  
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,  
  xsrfCookieName: 'csrftoken',  
  xsrfHeaderName: 'X-CSRFToken',  
});

// 请求拦截器：添加认证 token 和 CSRF token
apiClient.interceptors.request.use(
  (config) => {
  
    const token = localStorage.getItem('token') || sessionStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
  
    const csrfToken = getCSRFToken();
    if (csrfToken && !config.headers['X-CSRFToken']) {
      config.headers['X-CSRFToken'] = csrfToken;
    }
    
    return config;
  },
  (error) => Promise.reject(error)
);


apiClient.interceptors.response.use(
  (response) => response,
  (error) => {

    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      sessionStorage.removeItem('token');
      window.location.href = '/login';
    }
    

    if (error.response && error.response.status === 403) {
      console.error('CSRF 验证失败，请检查配置');
   
      if (typeof window !== 'undefined') {
        window.location.reload();
      }
    }
    
    return Promise.reject(error);
  }
);


function initializeCSRFToken() {
  if (typeof window !== 'undefined') {
   
    apiClient.get('/auth/login/')
      .then(() => {
        console.log('CSRF token 初始化成功');
      })
      .catch(error => {
        console.warn('CSRF token 初始化失败:', error.message);
      });
  }
}


if (typeof window !== 'undefined') {
  initializeCSRFToken();
}


export const authApi = {
  login: (credentials) => apiClient.post('/auth/login/', credentials),
  register: (userData) => apiClient.post('/auth/register/', userData),
  getCurrentUser: () => apiClient.get('/auth/user/'),
  logout: () => apiClient.post('/auth/logout/'),
  requestPasswordReset: (email) => apiClient.post('/auth/password-reset/', { email }),
  confirmPasswordReset: (data) => apiClient.post('/auth/password-reset/confirm/', data),
  

  testLogin: async (username, password) => {
    try {
   
      await apiClient.get('/auth/login/');
      
     
      const response = await apiClient.post('/auth/login/', {
        username,
        password
      });
      
      console.log('登录测试成功:', response.status);
      return { success: true, data: response.data };
    } catch (error) {
      console.error('登录测试失败:', error.response?.status, error.message);
      return { 
        success: false, 
        error: error.message,
        status: error.response?.status,
        data: error.response?.data
      };
    }
  }
};

// 实验相关 API
export const experimentApi = {
  getExperiments: (params) => apiClient.get('/experiments/', { params }),
  getExperiment: (id) => apiClient.get(`/experiments/${id}/`),
  createExperiment: (data) => apiClient.post('/experiments/', data),
  updateExperiment: (id, data) => apiClient.put(`/experiments/${id}/`, data),
  deleteExperiment: (id) => apiClient.delete(`/experiments/${id}/`),
  getExperimentFields: (experimentId) => apiClient.get(`/experiments/${experimentId}/fields/`),
  getExperimentAnimals: (experimentId) => apiClient.get(`/experiments/${experimentId}/animals/`),
  getExperimentStats: (experimentId) => apiClient.get(`/experiments/${experimentId}/statistics/`)
};

// 小区相关 API
export const fieldApi = {
  getFields: (params) => apiClient.get('/fields/', { params }),
  getField: (id) => apiClient.get(`/fields/${id}/`),
  createField: (data) => apiClient.post('/fields/', data),
  updateField: (id, data) => apiClient.put(`/fields/${id}/`, data),
  batchUpdateFields: (data) => apiClient.post('/fields/batch-update/', data),
  deleteField: (id) => apiClient.delete(`/fields/${id}/`),
  getFieldObservations: (fieldId) => apiClient.get(`/fields/${fieldId}/observations/`)
};


// 导出 apiClient
export default apiClient;