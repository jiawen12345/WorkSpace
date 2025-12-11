export const validators = {
  username: (username) => {
    if (!username) return '用户名不能为空';
    if (username.length < 4 || username.length > 20) return '用户名长度必须在4-20位之间';
    if (!/^[a-zA-Z0-9_]+$/.test(username)) return '用户名只能包含字母、数字或下划线';
    if (username.startsWith('_') || username.endsWith('_')) return '用户名不能以下划线开头或结尾';
    return '';
  },

  phone: (phone) => {
    if (!phone) return '手机号码不能为空';
    if (!/^1[3-9]\d{9}$/.test(phone)) return '请输入有效的手机号码';
    return '';
  },

  email: (email) => {
    if (!email) return '电子邮箱不能为空';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return '请输入有效的电子邮箱';
    return '';
  },

  password: (password) => {
    if (!password) return '密码不能为空';
    if (password.length < 8 || password.length > 20) return '密码长度必须在8-20位之间';
    if (!/[A-Za-z]/.test(password)) return '密码必须包含字母';
    if (!/[0-9]/.test(password)) return '密码必须包含数字';
    return '';
  },

  confirmPassword: (password, confirmPassword) => {
    if (!confirmPassword) return '请确认密码';
    if (confirmPassword !== password) return '两次输入的密码不一致';
    return '';
  }
};

export const calculatePasswordStrength = (password) => {
  if (!password) return { strength: 0, class: '', width: '0%' };
  
  let strength = 0;
  if (password.length >= 8) strength++;
  if (/[A-Z]/.test(password)) strength++;
  if (/[a-z]/.test(password)) strength++;
  if (/[0-9]/.test(password)) strength++;
  if (/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) strength++;
  
  let strengthClass = '';
  let width = '0%';
  
  if (strength <= 2) {
    strengthClass = 'strength-weak';
    width = '33%';
  } else if (strength <= 4) {
    strengthClass = 'strength-medium';
    width = '66%';
  } else {
    strengthClass = 'strength-strong';
    width = '100%';
  }
  
  return { strength, class: strengthClass, width };
};