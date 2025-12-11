// Toast提示组件
class Toast {
    constructor() {
        this.container = document.getElementById('toastContainer');
        if (!this.container) {
            this.createContainer();
        }
        this.setupCloseHandler();
    }
    
    createContainer() {
        this.container = document.createElement('div');
        this.container.id = 'toastContainer';
        this.container.className = 'toast-container';
        document.body.appendChild(this.container);
    }
    
    setupCloseHandler() {
        // 全局点击关闭处理
        document.addEventListener('click', (e) => {
            if (e.target.closest('.toast-close')) {
                const toast = e.target.closest('.toast');
                if (toast) {
                    this.hide(toast);
                }
            }
        });
    }
    
    show(message, type = 'info', duration = 3000) {
        const toast = this.createToast(message, type);
        this.container.appendChild(toast);
        
        // 触发动画
        setTimeout(() => {
            toast.classList.add('show');
        }, 10);
        
        // 自动隐藏
        if (duration > 0) {
            setTimeout(() => {
                this.hide(toast);
            }, duration);
        }
        
        return toast;
    }
    
    createToast(message, type) {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const iconClass = this.getIconClass(type);
        const title = this.getTitle(type);
        
        toast.innerHTML = `
            <div class="toast-icon">
                <i class="${iconClass}"></i>
            </div>
            <div class="toast-content">
                ${title ? `<div class="toast-title">${title}</div>` : ''}
                <div class="toast-message">${message}</div>
            </div>
            <button class="toast-close">
                <i class="fas fa-times"></i>
            </button>
        `;
        
        return toast;
    }
    
    getIconClass(type) {
        const icons = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };
        return icons[type] || 'fas fa-info-circle';
    }
    
    getTitle(type) {
        const titles = {
            success: '成功',
            error: '错误',
            warning: '警告',
            info: '提示'
        };
        return titles[type] || '';
    }
    
    hide(toast) {
        if (!toast) return;
        
        toast.classList.remove('show');
        toast.classList.add('hiding');
        
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    }
    
    success(message, duration = 3000) {
        return this.show(message, 'success', duration);
    }
    
    error(message, duration = 4000) {
        return this.show(message, 'error', duration);
    }
    
    warning(message, duration = 3000) {
        return this.show(message, 'warning', duration);
    }
    
    info(message, duration = 3000) {
        return this.show(message, 'info', duration);
    }
    
    // 显示加载中的Toast
    loading(message = '处理中...') {
        const toast = document.createElement('div');
        toast.className = 'toast info';
        
        toast.innerHTML = `
            <div class="toast-icon">
                <i class="fas fa-spinner fa-spin"></i>
            </div>
            <div class="toast-content">
                <div class="toast-message">${message}</div>
            </div>
        `;
        
        this.container.appendChild(toast);
        
        setTimeout(() => {
            toast.classList.add('show');
        }, 10);
        
        return {
            hide: () => this.hide(toast),
            update: (newMessage) => {
                const messageEl = toast.querySelector('.toast-message');
                if (messageEl) {
                    messageEl.textContent = newMessage;
                }
            }
        };
    }
    
    // 显示带进度的Toast
    progress(message, progress) {
        const toast = document.createElement('div');
        toast.className = 'toast info';
        
        toast.innerHTML = `
            <div class="toast-icon">
                <i class="fas fa-spinner fa-spin"></i>
            </div>
            <div class="toast-content">
                <div class="toast-message">${message}</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${progress}%"></div>
                </div>
            </div>
        `;
        
        // 添加进度条样式
        const style = document.createElement('style');
        style.textContent = `
            .progress-bar {
                width: 100%;
                height: 4px;
                background-color: #e0e0e0;
                border-radius: 2px;
                margin-top: 8px;
                overflow: hidden;
            }
            .progress-fill {
                height: 100%;
                background-color: var(--primary-color);
                border-radius: 2px;
                transition: width 0.3s ease;
            }
        `;
        document.head.appendChild(style);
        
        this.container.appendChild(toast);
        
        setTimeout(() => {
            toast.classList.add('show');
        }, 10);
        
        return {
            hide: () => this.hide(toast),
            update: (newMessage, newProgress) => {
                const messageEl = toast.querySelector('.toast-message');
                const progressEl = toast.querySelector('.progress-fill');
                
                if (messageEl && newMessage) {
                    messageEl.textContent = newMessage;
                }
                
                if (progressEl && newProgress !== undefined) {
                    progressEl.style.width = `${newProgress}%`;
                }
            }
        };
    }
    
    // 清除所有Toast
    clearAll() {
        const toasts = this.container.querySelectorAll('.toast');
        toasts.forEach(toast => {
            this.hide(toast);
        });
    }
}

// 全局Toast实例
let toastInstance = null;

function getToast() {
    if (!toastInstance) {
        toastInstance = new Toast();
    }
    return toastInstance;
}

// 全局快捷方法
function showToast(message, type = 'info', duration = 3000) {
    return getToast().show(message, type, duration);
}

function showSuccess(message, duration = 3000) {
    return getToast().success(message, duration);
}

function showError(message, duration = 4000) {
    return getToast().error(message, duration);
}

function showWarning(message, duration = 3000) {
    return getToast().warning(message, duration);
}

function showInfo(message, duration = 3000) {
    return getToast().info(message, duration);
}

function showLoading(message = '处理中...') {
    return getToast().loading(message);
}

function showProgress(message, progress = 0) {
    return getToast().progress(message, progress);
}

// 在DOM加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    getToast();
});