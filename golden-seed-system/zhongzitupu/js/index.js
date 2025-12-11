// 全局变量
let currentPage = 1;
const itemsPerPage = 10;
let uploadModalInstance = null;
let downloadModalInstance = null;
let notesData = JSON.parse(localStorage.getItem('fieldNotes')) || {};

document.addEventListener('DOMContentLoaded', async function() {
   
    
    // 初始化模态框
    initModals();
    
    // 初始化种子编号表格
    await renderFieldTable();
    
    // 设置事件委托来处理动态生成的按钮
    setupEventDelegation();
    
    // 设置数据采集功能卡片事件
    setupCollectionCards();
    
    // 导航标签切换
    const navTabs = document.querySelectorAll('.nav-tab');
    navTabs.forEach(tab => {
        tab.addEventListener('click', function() {
            navTabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            
            const tabContents = document.querySelectorAll('.tab-content');
            tabContents.forEach(content => content.classList.remove('active'));
            
            const tabId = this.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });
    
    // 查询种子编号
    document.getElementById('searchFieldBtn').addEventListener('click', function() {
        const searchValue = document.getElementById('field-search-input').value.trim();
        if (searchValue) {
            highlightFieldRow(searchValue);
        } else {
            showToast('请输入要查询的种子编号', 'error');
        }
    });
    
    // 分页按钮
    document.getElementById('prevPage').addEventListener('click', function() {
        if (currentPage > 1) {
            currentPage--;
            renderFieldTable();
        }
    });
    
    document.getElementById('nextPage').addEventListener('click', function() {
        if (currentPage < Math.ceil(FIELD_DATA.length / itemsPerPage)) {
            currentPage++;
            renderFieldTable();
        }
    });
    
    // 个人中心下拉菜单功能
    const userMenu = document.getElementById('userMenu');
    const profileDropdown = document.getElementById('profileDropdown');
    
    userMenu.addEventListener('click', function(e) {
        e.stopPropagation();
        profileDropdown.classList.toggle('active');     
    });
    
    document.getElementById('dropdownProfile').addEventListener('click', function() {
        window.location.href = 'profile.html';
        profileDropdown.classList.remove('active');
    });
    
    document.getElementById('dropdownLogout').addEventListener('click', function() {
        window.location.href = 'login.html';
        showToast('已退出登录', 'success');
        profileDropdown.classList.remove('active');
    });
    
    document.getElementById('logoutBtn').addEventListener('click', function() {
        window.location.href = 'login.html';
        showToast('已退出登录', 'success');
    });
    
    document.addEventListener('click', function() {
        profileDropdown.classList.remove('active');
    });
    
    profileDropdown.addEventListener('click', function(e) {
        e.stopPropagation();
    });
    
   
// 设置数据采集功能卡片事件
function setupCollectionCards() {
    // 数据采集页面的功能卡片
    const dataCollectionCards = document.querySelectorAll('#data-collection .function-card, #data-collection .image-collection');
    dataCollectionCards.forEach(card => {
        card.addEventListener('click', function() {
            const collectionType = this.getAttribute('data-collection') || 'general';
            const title = this.querySelector('h3').textContent;
            
            // 跳转到数据采集页面，并传递采集类型
            window.location.href = `collection.html?type=${collectionType}&title=${encodeURIComponent(title)}`;
        });
    });
    
    // 快速采集页面的功能卡片
    const quickCollectionCards = document.querySelectorAll('#quick-collection .function-card, #quick-collection .image-collection');
    quickCollectionCards.forEach(card => {
        card.addEventListener('click', function() {
            const collectionType = this.getAttribute('data-collection') || 'quick';
            const title = this.querySelector('h3').textContent;
            
            // 跳转到数据采集页面，并传递采集类型
            window.location.href = `collection.html?type=${collectionType}&title=${encodeURIComponent(title)}&mode=quick`;
        });
    });
}

// 设置事件委托来处理动态生成的按钮
function setupEventDelegation() {
    const tableBody = document.getElementById('field-table-body');
    
    // 使用事件委托处理表格内的按钮点击
    tableBody.addEventListener('click', function(e) {
        const target = e.target;
        
        // 处理查看图片按钮
        if (target.closest('.view-images-btn')) {
            const button = target.closest('.view-images-btn');
            const row = button.closest('tr');
            const fieldId = row.cells[0].textContent;
            viewImages(fieldId);
        }
        
        // 处理上传图片按钮
        if (target.closest('.upload-image-btn')) {
            const button = target.closest('.upload-image-btn');
            const row = button.closest('tr');
            const fieldId = row.cells[0].textContent;
            uploadImageForField(fieldId);
        }
        
        // 处理备注按钮
        if (target.closest('.notes-btn')) {
            const button = target.closest('.notes-btn');
            const row = button.closest('tr');
            const fieldId = row.cells[0].textContent;
            manageNotes(fieldId);
        }
        
        // 处理下载单个数据按钮
        if (target.closest('.action-btn')) {
            const button = target.closest('.action-btn');
            const row = button.closest('tr');
            const fieldId = row.cells[0].textContent;
            
            // 根据按钮图标判断操作类型
            const icon = button.querySelector('i');
            if (icon.classList.contains('fa-download')) {
                downloadSingle(fieldId);
            } else if (icon.classList.contains('fa-eye')) {
                viewDetails(fieldId);
            }
        }
    });
}

// 初始化模态框
function initModals() {
    // 上传模态框
    const uploadTemplate = document.getElementById('uploadModalTemplate');
    if (uploadTemplate) {
        const uploadModalElement = uploadTemplate.content.cloneNode(true).firstElementChild;
        document.body.appendChild(uploadModalElement);
        uploadModalInstance = new UploadModal('uploadModal');
    }
    
    // 下载模态框
    const downloadTemplate = document.getElementById('downloadModalTemplate');
    if (downloadTemplate) {
        const downloadModalElement = downloadTemplate.content.cloneNode(true).firstElementChild;
        document.body.appendChild(downloadModalElement);
        downloadModalInstance = new DownloadModal('downloadModal');
    }
}

// 渲染种子编号表格
async function renderFieldTable() {
    const tableBody = document.getElementById('field-table-body');
    tableBody.innerHTML = '';
    
    let imageCounts = {};
    try {
        imageCounts = await getImageCounts();
    } catch (error) {
        console.error('获取图片计数失败:', error);
    }
    
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, FIELD_DATA.length);
    
    for (let i = startIndex; i < endIndex; i++) {
        const item = FIELD_DATA[i];
        const notesCount = notesData[item.id] ? notesData[item.id].length : 0;
        const uploadedCount = imageCounts[item.id] || 0;
        const totalImages = item.images + uploadedCount;

        const row = document.createElement('tr');
        row.setAttribute('data-field-id', item.id);
        
        row.innerHTML = `
            <td>${item.id}</td>
            <td class="image-count">
                ${totalImages}
                ${totalImages > 0 ? 
                    `<button class="view-images-btn" title="查看图片" type="button">
                     <i class="fas fa-images"></i>
                      </button>` : 
                      '-'
                    }
                <button class="upload-image-btn" title="上传图片" type="button">
                    <i class="fas fa-plus"></i>
                </button>
            </td>
            <td>${item.note1}</td>
            <td>
                ${notesCount}
                <button class="notes-btn" title="管理备注" type="button">
                    <i class="fas fa-sticky-note"></i>
                </button>
            </td>
            <td class="action-cell">
                <button class="action-btn" title="下载单个数据" type="button">
                    <i class="fas fa-download"></i>
                </button>
                <button class="action-btn" title="查看详情" type="button">
                    <i class="fas fa-eye"></i>
                </button>
            </td>
        `;
        tableBody.appendChild(row);
    }
    
    updatePagination();
}

// 更新分页信息
function updatePagination() {
    const totalPages = Math.ceil(FIELD_DATA.length / itemsPerPage);
    document.getElementById('pageInfo').textContent = `${currentPage}/${totalPages}`;
    
    document.getElementById('prevPage').disabled = currentPage === 1;
    document.getElementById('nextPage').disabled = currentPage === totalPages;
}

// 查看图片函数 
async function viewImages(fieldId) {
    try {
        console.log('开始查看图片，种子编号:', fieldId);
        
        // 查找对应的种子数据
        const item = FIELD_DATA.find(item => item.id === fieldId);
        console.log('找到的种子数据:', item);
        
        let allImages = [];
        
        // 添加预置图片
        if (item && item.imageUrls && item.imageUrls.length > 0) {
            allImages = allImages.concat(item.imageUrls);
            console.log('预置图片数量:', item.imageUrls.length);
        }
        
        // 添加IndexedDB中存储的图片
        let uploadedImages = [];
        try {
            uploadedImages = await getImagesByFieldId(fieldId);
            console.log('上传的图片数量:', uploadedImages.length);
            
            if (uploadedImages && uploadedImages.length > 0) {
                const uploadedUrls = uploadedImages.map(img => img.url);
                allImages = allImages.concat(uploadedUrls);
            }
        } catch (dbError) {
            console.error('获取上传图片失败:', dbError);
        }
        
        console.log('总图片数量:', allImages.length);
        console.log('所有图片URL:', allImages);
        
        if (allImages.length > 0) {
            // 使用内置的简单图片查看器
            showSimpleImageViewer(allImages, 0);
        } else {
            showToast('该种子编号暂无图片数据', 'error');
        }
    } catch (error) {
        console.error('查看图片失败:', error);
        showToast('查看图片失败: ' + error.message, 'error');
    }
}

// 简单的图片查看器实现
function showSimpleImageViewer(images, startIndex = 0) {
    // 如果已经存在查看器，先移除
    const existingViewer = document.getElementById('simpleImageViewer');
    if (existingViewer) {
        existingViewer.remove();
    }
    
    if (!images || images.length === 0) {
        showToast('没有可显示的图片', 'error');
        return;
    }
    
    let currentIndex = startIndex;
    
    // 创建图片查看器HTML
    const viewerHtml = `
        <div class="simple-image-viewer" id="simpleImageViewer">
            <div class="simple-viewer-overlay"></div>
            <div class="simple-viewer-container">
                <button class="simple-viewer-close" id="simpleViewerClose">
                    <i class="fas fa-times"></i>
                </button>
                
                <div class="simple-viewer-content">
                    <img class="simple-viewer-image" id="simpleViewerImage" src="${images[currentIndex]}" alt="查看图片">
                    
                    <button class="simple-viewer-nav simple-viewer-prev" id="simpleViewerPrev" ${currentIndex === 0 ? 'disabled' : ''}>
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    
                    <button class="simple-viewer-nav simple-viewer-next" id="simpleViewerNext" ${currentIndex === images.length - 1 ? 'disabled' : ''}>
                        <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
                
                <div class="simple-viewer-footer">
                    <div class="simple-viewer-info">
                        <span class="simple-image-index">${currentIndex + 1} / ${images.length}</span>
                    </div>
                    
                    <div class="simple-viewer-actions">
                        <button class="simple-action-btn" id="simpleViewerDownload" title="下载">
                            <i class="fas fa-download"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // 添加到页面
    document.body.insertAdjacentHTML('beforeend', viewerHtml);
    
    // 设置事件监听器
    setupSimpleImageViewer(images, currentIndex);
}

// 设置简单图片查看器事件
function setupSimpleImageViewer(images, currentIndex) {
    const viewer = document.getElementById('simpleImageViewer');
    const closeBtn = document.getElementById('simpleViewerClose');
    const prevBtn = document.getElementById('simpleViewerPrev');
    const nextBtn = document.getElementById('simpleViewerNext');
    const imageElement = document.getElementById('simpleViewerImage');
    const downloadBtn = document.getElementById('simpleViewerDownload');
    const indexElement = document.querySelector('.simple-image-index');
    
    // 更新图片和状态
    function updateViewer() {
        imageElement.src = images[currentIndex];
        indexElement.textContent = `${currentIndex + 1} / ${images.length}`;
        
        // 更新导航按钮状态
        prevBtn.disabled = currentIndex === 0;
        nextBtn.disabled = currentIndex === images.length - 1;
    }
    
    // 关闭查看器
    function closeViewer() {
        if (viewer) {
            viewer.remove();
        }
    }
    
    // 上一张图片
    function prevImage() {
        if (currentIndex > 0) {
            currentIndex--;
            updateViewer();
        }
    }
    
    // 下一张图片
    function nextImage() {
        if (currentIndex < images.length - 1) {
            currentIndex++;
            updateViewer();
        }
    }
    
    // 下载当前图片
    function downloadImage() {
        const imageUrl = images[currentIndex];
        const link = document.createElement('a');
        link.href = imageUrl;
        link.download = `image_${currentIndex + 1}.jpg`;
        link.click();
        showToast('图片下载成功', 'success');
    }
    
    // 事件监听器
    closeBtn.addEventListener('click', closeViewer);
    prevBtn.addEventListener('click', prevImage);
    nextBtn.addEventListener('click', nextImage);
    downloadBtn.addEventListener('click', downloadImage);
    
    // 点击背景关闭
    viewer.addEventListener('click', function(e) {
        if (e.target === this || e.target.classList.contains('simple-viewer-overlay')) {
            closeViewer();
        }
    });
    
    // 键盘导航
    document.addEventListener('keydown', function(e) {
        if (!viewer || viewer.style.display === 'none') return;
        
        switch(e.key) {
            case 'Escape':
                closeViewer();
                break;
            case 'ArrowLeft':
                prevImage();
                break;
            case 'ArrowRight':
                nextImage();
                break;
            case 'd':
            case 'D':
                downloadImage();
                break;
        }
    });
}
        // 打开图片模态框
        function openImageModal(images, startIndex) {
            currentImages = images;
            currentImageIndex = startIndex;
            
            const modal = document.getElementById('imageModal');
            const modalImage = document.getElementById('modalImage');
            const imageCounter = document.getElementById('imageCounter');
            
            // 确保图片URL正确设置
            modalImage.src = currentImages[currentImageIndex];
            imageCounter.textContent = `${currentImageIndex + 1}/${currentImages.length}`;
            
           // 显示/隐藏导航按钮
            const prevBtn = document.getElementById('prevImage');
            const nextBtn = document.getElementById('nextImage');
            
            if (currentImages.length > 1) {
                prevBtn.style.display = 'flex';
                nextBtn.style.display = 'flex';
            } else {
                prevBtn.style.display = 'none';
                nextBtn.style.display = 'none';
            }
            
            modal.classList.add('active');
            modal.style.display = 'flex'; // 确保模态框显示
        }
  
        // 关闭图片模态框
        function closeImageModal() {
            document.getElementById('imageModal').classList.remove('active');
             document.getElementById('imageModal').style.display = 'none';
            currentImages = [];
            currentImageIndex = 0;
        }
        
        // 导航图片
        function navigateImage(direction) {
            currentImageIndex += direction;
            
            if (currentImageIndex < 0) {
                currentImageIndex = currentImages.length - 1;
            } else if (currentImageIndex >= currentImages.length) {
                currentImageIndex = 0;
            }
            
            const modalImage = document.getElementById('modalImage');
            const imageCounter = document.getElementById('imageCounter');
            
            modalImage.src = currentImages[currentImageIndex];
            imageCounter.textContent = `${currentImageIndex + 1}/${currentImages.length}`;
        }
        
        // 重置上传表单
        function resetUploadForm() {
            document.getElementById('fileInput').value = '';
            document.getElementById('fileInfo').style.display = 'none';
            document.getElementById('confirmUpload').innerHTML = '上传';
            document.getElementById('confirmUpload').disabled = true;
        }
        
        // 下载单个数据
        function downloadSingle(id) {
            const item = fieldData.find(item => item.id === id);
            if (item) {
               
                // 生成CSV内容
                let csvContent = "稻田编号,图像数量,备注1,备注2\n";
                csvContent += `${item.id},${item.images},${item.note1},${item.note2}\n`;
                
                // 创建下载链接
                const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
                const url = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.setAttribute('href', url);
                link.setAttribute('download', `稻田编号_${id}.csv`);
                link.style.visibility = 'hidden';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                
                showToast(`稻田编号 ${id} 的数据已下载`, 'success');
            }
        }
        
        // 查看详情
        function viewDetails(id) {
            showToast(`查看稻田编号 ${id} 的详细信息`, 'success');
            
            // 这里可以跳转到详情页面或显示详情模态框
        }
 
     // 管理备注
function manageNotes(fieldId) {
    currentFieldId = fieldId;
    
    // 创建备注管理模态框
    createNotesModal();
    
    // 渲染备注列表
    renderNotesList(fieldId);
    
    // 显示模态框
    const notesModal = document.getElementById('notesModal');
    if (notesModal) {
        notesModal.style.display = 'flex';
    }
}

// 创建备注管理模态框
function createNotesModal() {
    // 如果模态框已存在，先移除
    const existingModal = document.getElementById('notesModal');
    if (existingModal) {
        existingModal.remove();
    }
    
    // 创建新的模态框
    const modalHtml = `
        <div class="modal" id="notesModal" style="display: none;">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">备注管理 - <span id="fieldIdDisplay">${currentFieldId}</span></h3>
                    <button class="close-modal" id="closeNotesModal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="notes-list-container">
                        <h4>现有备注</h4>
                        <div class="notes-list" id="notesList">
                            <!-- 备注列表将动态生成 -->
                        </div>
                    </div>
                    <div class="add-note-form">
                        <h4>添加新备注</h4>
                        <textarea id="newNoteContent" placeholder="请输入备注内容..." rows="4"></textarea>
                        <div class="modal-actions">
                            <button class="cancel-btn" id="cancelAddNote">取消</button>
                            <button class="confirm-btn" id="confirmAddNote">添加备注</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // 添加到页面
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    
    // 设置事件监听器
    setupNotesModalEvents();
}

// 设置备注模态框事件
function setupNotesModalEvents() {
    // 关闭按钮
    const closeBtn = document.getElementById('closeNotesModal');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeNotesModal);
    }
    
    // 取消按钮
    const cancelBtn = document.getElementById('cancelAddNote');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', closeNotesModal);
    }
    
    // 添加备注按钮
    const confirmBtn = document.getElementById('confirmAddNote');
    if (confirmBtn) {
        confirmBtn.addEventListener('click', addNewNote);
    }
    
    // 点击模态框外部关闭
    const notesModal = document.getElementById('notesModal');
    if (notesModal) {
        notesModal.addEventListener('click', function(e) {
            if (e.target === this) {
                closeNotesModal();
            }
        });
    }
    
    // ESC键关闭
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeNotesModal();
        }
    });
}

// 关闭备注模态框
function closeNotesModal() {
    const notesModal = document.getElementById('notesModal');
    if (notesModal) {
        notesModal.style.display = 'none';
        // 可选：移除模态框
        // notesModal.remove();
    }
    currentFieldId = null;
}

// 渲染备注列表
function renderNotesList(fieldId) {
    const notesList = document.getElementById('notesList');
    if (!notesList) {
        console.error('备注列表容器未找到');
        return;
    }
    
    notesList.innerHTML = '';
    
    const notes = notesData[fieldId] || [];
    
    if (notes.length === 0) {
        notesList.innerHTML = '<div class="no-notes">暂无备注</div>';
        return;
    }
    
    notes.forEach((note, index) => {
        const noteItem = document.createElement('div');
        noteItem.className = 'note-item';
        noteItem.innerHTML = `
            <div class="note-content">${note.content}</div>
            <div class="note-meta">
                <span class="note-author">${note.author || '系统管理员'}</span>
                <span class="note-date">${note.date}</span>
            </div>
        `;
        notesList.appendChild(noteItem);
    });
}

// 添加新备注
function addNewNote() {
    const contentInput = document.getElementById('newNoteContent');
    if (!contentInput) {
        console.error('备注输入框未找到');
        return;
    }
    
    const content = contentInput.value.trim();
    
    if (!content) {
        showToast('请输入备注内容', 'error');
        return;
    }
    
    if (!currentFieldId) {
        showToast('未选择有效的字段ID', 'error');
        return;
    }
    
    // 创建新备注
    const newNote = {
        content: content,
        author: '当前用户',
        date: new Date().toLocaleString('zh-CN')
    };
    
    // 添加到数据
    if (!notesData[currentFieldId]) {
        notesData[currentFieldId] = [];
    }
    
    notesData[currentFieldId].unshift(newNote);
    
    // 保存到本地存储
    localStorage.setItem('fieldNotes', JSON.stringify(notesData));
    
    // 重新渲染备注列表
    renderNotesList(currentFieldId);
    
    // 清空输入框
    contentInput.value = '';
    
    // 重新渲染表格以更新备注数量
    renderFieldTable();
    
    showToast('备注添加成功', 'success');
}

// 显示提示消息（安全版本）
function showToast(message, type) {
    const toast = document.getElementById('toast');
    if (!toast) {
        console.warn('Toast元素未找到，无法显示消息:', message);
        return;
    }
    
    toast.textContent = message;
    toast.className = 'toast';
    toast.classList.add(type);
    toast.classList.add('show');
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
})