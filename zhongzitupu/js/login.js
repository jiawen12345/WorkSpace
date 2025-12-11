document.addEventListener('DOMContentLoaded', function() {
    // 登录表单提交
    document.getElementById('login').addEventListener('submit', async function(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        
        if (username && password) {
            // 显示主界面 - 使用相对路径
            window.location.href = 'index.html';
            showToast('登录成功！', 'success');
        } else {
            showToast('请输入用户名和密码', 'error');
        }
    });

    
    // 切换到注册页面
    document.getElementById('showRegister').addEventListener('click', function() {
        window.location.href = 'register.html';
    });
    const loginForm = document.getElementById('login');
    
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            handleLogin();
        });
    }
    });