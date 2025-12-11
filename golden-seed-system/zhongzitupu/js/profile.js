document.addEventListener('DOMContentLoaded', function() {
    // 加载用户数据
    loadUserData();
    
    // 保存按钮点击事件
    document.getElementById('profileSaveBtn').addEventListener('click', function() {
        saveProfileData();
    });
    
    // 取消按钮点击事件
    document.getElementById('profileCancelBtn').addEventListener('click', function() {
        if (confirm('确定要放弃已做的修改吗？')) {
            window.location.href = 'index.html';
        }
    });
}); 

// 加载用户数据
function loadUserData() {
    // 从本地存储加载用户数据，如果没有则使用默认值
    const userData = JSON.parse(localStorage.getItem('userProfile')) || {
        username: 'jinzhongzi',
        displayName: '种子计划',
        phone: '138****5678',
        email: 'jinzhongzi@qq.com',
        department: '农业信息化研究中心',
        registerTime: '2025-03-15',
        lastLogin: '2025-05-20 14:30',
        notifications: 'important'
    };
    
    // 填充表单数据
    document.getElementById('profile-username').value = userData.username;
    document.getElementById('profile-displayname').value = userData.displayName;
    document.getElementById('profile-phone').value = userData.phone;
    document.getElementById('profile-email').value = userData.email;
    document.getElementById('profile-department').value = userData.department;
    document.getElementById('profile-register-time').value = userData.registerTime;
    document.getElementById('profile-last-login').value = userData.lastLogin;
    document.getElementById('profile-notifications').value = userData.notifications;
}

// 保存个人资料数据
function saveProfileData() {
    const displayName = document.getElementById('profile-displayname').value;
    const phone = document.getElementById('profile-phone').value;
    const email = document.getElementById('profile-email').value;
    const department = document.getElementById('profile-department').value;
    const notifications = document.getElementById('profile-notifications').value;
    
    const currentPassword = document.getElementById('profile-current-password').value;
    const newPassword = document.getElementById('profile-new-password').value;
    const confirmPassword = document.getElementById('profile-confirm-password').value;
    
    // 基本验证
    if (!displayName.trim()) {
        showToast('请输入显示名称', 'error');
        return;
    }
    
    if (!phone.trim()) {
        showToast('请输入手机号码', 'error');
        return;
    }
    
    if (!email.trim()) {
        showToast('请输入电子邮箱', 'error');
        return;
    }
    
    // 邮箱格式验证
    const emailValidation = validateEmail(email);
    if (!emailValidation.isValid) {
        showToast('请输入有效的电子邮箱', 'error');
        return;
    }
    
    // 手机号格式验证
    const phoneValidation = validatePhone(phone);
    if (!phoneValidation.isValid) {
        showToast('请输入有效的手机号码', 'error');
        return;
    }
    
    // 密码修改验证
    if (currentPassword || newPassword || confirmPassword) {
        if (!currentPassword) {
            showToast('请输入当前密码', 'error');
            return;
        }
        
        if (!newPassword) {
            showToast('请输入新密码', 'error');
            return;
        }
        
        if (!confirmPassword) {
            showToast('请确认新密码', 'error');
            return;
        }
        
        const passwordValidation = validatePassword(newPassword);
        if (!passwordValidation.isValid) {
            showToast('新密码强度不足，请满足更多要求', 'error');
            return;
        }
        
        if (newPassword !== confirmPassword) {
            showToast('两次输入的新密码不一致', 'error');
            return;
        }
        
        // 模拟密码验证（在实际应用中需要与服务器验证）
        if (currentPassword !== 'pjwsyj2535164092') {
            showToast('当前密码错误', 'error');
            return;
        }
    }
    
    // 保存数据
    const userData = {
        username: document.getElementById('profile-username').value,
        displayName: displayName,
        phone: phone,
        email: email,
        department: department,
        registerTime: document.getElementById('profile-register-time').value,
        lastLogin: new Date().toLocaleString('zh-CN'),
        notifications: notifications
    };
    
    // 保存到本地存储
    localStorage.setItem('userProfile', JSON.stringify(userData));
    
    // 显示保存成功消息
    showToast('个人资料保存成功！', 'success');
    
    // 清空密码字段
    document.getElementById('profile-current-password').value = '';
    document.getElementById('profile-new-password').value = '';
    document.getElementById('profile-confirm-password').value = '';
    
    // 更新最后登录时间显示
    document.getElementById('profile-last-login').value = userData.lastLogin;
    
    // 如果是密码修改，显示成功消息
    if (newPassword) {
        showToast('密码修改成功！', 'success');
    }
}

// 验证密码修改
function validatePasswordChange() {
    const newPassword = document.getElementById('profile-new-password').value;
    const confirmPassword = document.getElementById('profile-confirm-password').value;
    
    if (newPassword && confirmPassword) {
        if (newPassword !== confirmPassword) {
            document.getElementById('profile-confirm-password').classList.add('error');
            document.getElementById('profile-confirm-password').classList.remove('success');
        } else {
            document.getElementById('profile-confirm-password').classList.remove('error');
            document.getElementById('profile-confirm-password').classList.add('success');
        }
    }
}