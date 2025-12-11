import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from './auth.js';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../Vue/Home.vue'),
    meta: { requiresGuest: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../Vue/Home.vue'),
    meta: { requiresGuest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../Vue/Register.vue'), 
    meta: { requiresGuest: true }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('../Vue/Dashboard.vue'), 
    meta: { requiresAuth: true }
  },
  {
    path: '/collection',
    name: 'DataCollection',
    component: () => import('../Vue/DataCollection.vue'), 
    meta: { requiresAuth: true }
  },
  {
    path: '/field-search',
    name: 'FieldSearch',
    component: () => import('../Vue/FieldSearch.vue'), 
    meta: { requiresAuth: true }
  },
  {
    path: '/collection/:type',
    name: 'CollectionDetail',
    component: () => import('../Vue/CollectionDetail.vue'), 
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../Vue/Profile.vue'), 
    meta: { requiresAuth: true }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  console.log(`路由跳转: ${from.path} -> ${to.path}`)
  next() // 直接放行，不做任何检查
})

export default router