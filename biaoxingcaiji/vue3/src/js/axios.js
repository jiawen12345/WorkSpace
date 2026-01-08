import axios from 'axios';
import { toast } from './toast';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 30000,
});

api.interceptors.request.use(config => {
  
  const username = import.meta.env.VITE_DEV_USER || 'admin';
  const password = import.meta.env.VITE_DEV_PASS || 'admin';
  config.headers.Authorization = `Basic ${btoa(`${username}:${password}`)}`;
  return config;
});

api.interceptors.response.use(
  response => response,
  error => {
    const message = error.response?.data?.error || '请求失败';
    toast.error(message);
    return Promise.reject(error);
  }
);

export default api;  