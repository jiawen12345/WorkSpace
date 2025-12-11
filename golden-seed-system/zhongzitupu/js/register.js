document.addEventListener('DOMContentLoaded', function() {
    // 注册表单验证
    document.getElementById('reg-username').addEventListener('input', function() {
        const username = this.value;
        const validation = validateUsername(username);
        updateValidationStatus(this, document.getElementById('regUsernameError'), validation.isValid, validation.message);
        checkRegisterFormValidity();
    });
    
    document.getElementById('reg-phone').addEventListener('input', function() {
        const phone = this.value;
        const validation = validatePhone(phone);
        updateValidationStatus(this, document.getElementById('regPhoneError'), validation.isValid, validation.message);
        checkRegisterFormValidity();
    });
    
    document.getElementById('reg-email').addEventListener('input', function() {
        const email = this.value;
        const validation = validateEmail(email);
        updateValidationStatus(this, document.getElementById('regEmailError'), validation.isValid, validation.message);
        checkRegisterFormValidity();
    });
    
    document.getElementById('reg-password').addEventListener('input', function() {
        const password = this.value;
        const validation = validatePassword(password);
        updateValidationStatus(this, document.getElementById('regPasswordError'), validation.isValid, validation.message);
        checkRegisterFormValidity();
    });
    
    document.getElementById('reg-confirm-password').addEventListener('input', function() {
        const password = document.getElementById('reg-password').value;
        const confirmPassword = this.value;
        const validation = validateConfirmPassword(password, confirmPassword);
        updateValidationStatus(this, document.getElementById('regConfirmPasswordError'), validation.isValid, validation.message);
        checkRegisterFormValidity();
    });
    
    // 注册表单提交
    document.getElementById('register').addEventListener('submit', function(e) {
        e.preventDefault();
        const username = document.getElementById('reg-username').value;
        const phone = document.getElementById('reg-phone').value;
        const email = document.getElementById('reg-email').value;
        const password = document.getElementById('reg-password').value;
        const confirmPassword = document.getElementById('reg-confirm-password').value;
        
        if (!username || !phone || !email || !password || !confirmPassword) {
            showToast('请填写所有必填字段', 'error');
            return;
        }
        
        const usernameValidation = validateUsername(username);
        const phoneValidation = validatePhone(phone);
        const emailValidation = validateEmail(email);
        const passwordValidation = validatePassword(password);
        const confirmPasswordValidation = validateConfirmPassword(password, confirmPassword);
        
        if (!usernameValidation.isValid || !phoneValidation.isValid || 
            !emailValidation.isValid || !passwordValidation.isValid || 
            !confirmPasswordValidation.isValid) {
            showToast('请修正表单中的错误后再提交', 'error');
            return;
        }
        
        // 模拟注册成功
        showToast('注册成功！请使用新账号登录', 'success');
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 1500);
    });
    
    // 检查注册表单是否全部有效
    function checkRegisterFormValidity() {
        const username = document.getElementById('reg-username').value;
        const phone = document.getElementById('reg-phone').value;
        const email = document.getElementById('reg-email').value;
        const password = document.getElementById('reg-password').value;
        const confirmPassword = document.getElementById('reg-confirm-password').value;
        
        const usernameValid = validateUsername(username).isValid;
        const phoneValid = validatePhone(phone).isValid;
        const emailValid = validateEmail(email).isValid;
        const passwordValid = validatePassword(password).isValid;
        const confirmPasswordValid = validateConfirmPassword(password, confirmPassword).isValid;
        
        const registerBtn = document.getElementById('register-btn');
        registerBtn.disabled = !(usernameValid && phoneValid && emailValid && passwordValid && confirmPasswordValid);
    }
});