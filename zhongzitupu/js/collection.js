// 全局变量
let currentPage = 1;
const itemsPerPage = 10;
let uploadModalInstance = null;
let downloadModalInstance = null;

document.addEventListener('DOMContentLoaded', async function() {
     // 初始化IndexedDB
        function initIndexedDB() {
            return new Promise((resolve, reject) => {
                const request = indexedDB.open(DB_NAME, DB_VERSION);
                
                request.onerror = () => {
                    console.error('IndexedDB打开失败:', request.error);
                    reject(request.error);
                };
                
                request.onsuccess = () => {
                    db = request.result;
                    console.log('IndexedDB初始化成功');
                    resolve(db);
                };
                
                request.onupgradeneeded = (event) => {
                    const database = event.target.result;
                    
                    // 创建对象存储空间
                    if (!database.objectStoreNames.contains(STORE_NAME)) {
                        const objectStore = database.createObjectStore(STORE_NAME, { keyPath: 'id' });
                        objectStore.createIndex('fieldId', 'fieldId', { unique: false });
                        console.log('对象存储空间创建成功');
                    }
                };
            });
        }
        // 保存图片到IndexedDB
        async function saveImageToDB(imageData) {
            if (!db) {
                await initIndexedDB();
            }
            
            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readwrite');
                const objectStore = transaction.objectStore(STORE_NAME);
                
                const request = objectStore.add(imageData);
                
                request.onsuccess = () => {
                    console.log('图片保存成功:', imageData.id);
                    resolve(request.result);
                };
                
                request.onerror = () => {
                    console.error('图片保存失败:', request.error);
                    reject(request.error);
                };
            });
        }

        // 从IndexedDB获取指定稻田编号的所有图片
        async function getImagesByFieldId(fieldId) {
            if (!db) {
                await initIndexedDB();
            }
            
            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readonly');
                const objectStore = transaction.objectStore(STORE_NAME);
                const index = objectStore.index('fieldId');
                const request = index.getAll(fieldId);
                
                request.onsuccess = () => {
                    console.log(`获取到 ${fieldId} 的图片数量:`, request.result.length);
                    resolve(request.result);
                };
                
                request.onerror = () => {
                    console.error('获取图片失败:', request.error);
                    reject(request.error);
                };
            });
        }

        // 从IndexedDB获取所有图片
        async function getAllImagesFromDB() {
            if (!db) {
                await initIndexedDB();
            }
            
            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readonly');
                const objectStore = transaction.objectStore(STORE_NAME);
                const request = objectStore.getAll();
                
                request.onsuccess = () => {
                    console.log('获取所有图片成功，数量:', request.result.length);
                    resolve(request.result);
                };
                
                request.onerror = () => {
                    console.error('获取所有图片失败:', request.error);
                    reject(request.error);
                };
            });
        }

        // 从IndexedDB删除图片
        async function deleteImageFromDB(imageId) {
            if (!db) {
                await initIndexedDB();
            }
            
            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readwrite');
                const objectStore = transaction.objectStore(STORE_NAME);
                const request = objectStore.delete(imageId);
                
                request.onsuccess = () => {
                    console.log('图片删除成功:', imageId);
                    resolve();
                };
                
                request.onerror = () => {
                    console.error('图片删除失败:', request.error);
                    reject(request.error);
                };
            });
        }

        // 获取所有稻田编号的图片计数
        async function getImageCounts() {
            if (!db) {
                await initIndexedDB();
            }
            
            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readonly');
                const objectStore = transaction.objectStore(STORE_NAME);
                const index = objectStore.index('fieldId');
                const request = index.getAll();
                
                request.onsuccess = () => {
                    const images = request.result;
                    const counts = {};
                    
                    // 统计每个稻田编号的图片数量
                    images.forEach(image => {
                        if (!counts[image.fieldId]) {
                            counts[image.fieldId] = 0;
                        }
                        counts[image.fieldId]++;
                    });
                    
                    resolve(counts);
                };
                
                request.onerror = () => {
                    console.error('获取图片计数失败:', request.error);
                    reject(request.error);
                };
            });
        }

        // DOM 加载完成后执行
        document.addEventListener('DOMContentLoaded', async function() {         
            // 初始化IndexedDB
            try {
                await initIndexedDB();
                console.log('IndexedDB初始化完成');
            } catch (error) {
                console.error('IndexedDB初始化失败:', error);
                showToast('数据存储初始化失败，部分功能可能无法使用', 'error');
            }
    
    // 初始化模态框
    initModals();
    
    // 初始化稻田编号表格
    await renderFieldTable();
    
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
    
    // 功能卡片点击事件
    const functionCards = document.querySelectorAll('.function-card');
    functionCards.forEach(card => {
        card.addEventListener('click', function() {
            const collectionType = this.getAttribute('data-collection');
            const title = this.querySelector('h3').textContent;
            showToast(`进入${title}功能`, 'success');
        });
    });
    
    // 图像采集点击事件
    document.getElementById('imageCollection').addEventListener('click', function() {
        window.location.href = 'collection.html';
    });
    
    document.getElementById('quickImageCollection').addEventListener('click', function() {
        window.location.href = 'collection.html';
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
    
    // 上传下载按钮
    document.getElementById('uploadBtn').addEventListener('click', function() {
        if (uploadModalInstance) {
            uploadModalInstance.show();
        }
    });
    
    document.getElementById('downloadBtn').addEventListener('click', function() {
        if (downloadModalInstance) {
            downloadModalInstance.show();
        }
    });
});

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
        
        row.innerHTML = `
            <td>${item.id}</td>
            <td class="image-count">
                ${totalImages}
                ${totalImages > 0 ? 
                    `<button class="view-images-btn" title="查看图片" onclick="viewImages('${item.id}')">
                     <i class="fas fa-images"></i>
                      </button>` : 
                      '-'
                    }
                <button class="upload-image-btn" title="上传图片" onclick="uploadImageForField('${item.id}')">
                    <i class="fas fa-plus"></i>
                </button>
            </td>
            <td>${item.note1}</td>
            <td>
                ${notesCount}
                <button class="notes-btn" title="管理备注" onclick="manageNotes('${item.id}')">
                    <i class="fas fa-sticky-note"></i>
                </button>
            </td>
            <td class="action-cell">
                <button class="action-btn" title="下载单个数据" onclick="downloadSingle('${item.id}')">
                    <i class="fas fa-download"></i>
                </button>
                <button class="action-btn" title="查看详情" onclick="viewDetails('${item.id}')">
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

// 查看图片
async function viewImages(fieldId) {
    try {
        const item = FIELD_DATA.find(item => item.id === fieldId);
        let allImages = [];
        
        if (item && item.imageUrls && item.imageUrls.length > 0) {
            allImages = allImages.concat(item.imageUrls);
        }
        
        const uploadedImages = await getImagesByFieldId(fieldId);
        if (uploadedImages && uploadedImages.length > 0) {
            const uploadedUrls = uploadedImages.map(img => img.url);
            allImages = allImages.concat(uploadedUrls);
        }
        
        if (allImages.length > 0) {
            if (typeof showImageViewer !== 'undefined') {
                showImageViewer(allImages, 0);
            } else {
                window.open(allImages[0], '_blank');
            }
        } else {
            showToast('该种子编号暂无图片数据', 'error');
        }
    } catch (error) {
        console.error('查看图片失败:', error);
        showToast('查看图片失败', 'error');
    }
}

// 上传图片到指定种子编号
function uploadImageForField(fieldId) {
    window.location.href = `collection.html?fieldId=${fieldId}&action=upload`;
}

// 高亮显示匹配的行
function highlightFieldRow(searchValue) {
    const rows = document.querySelectorAll('#field-table-body tr');
    let found = false;
    
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        const fieldId = cells[0].textContent;
        
        row.classList.remove('highlight');
        
        if (fieldId === searchValue) {
            row.classList.add('highlight');
            found = true;
            row.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });
    
    if (!found) {
        showToast('未找到匹配的种子编号', 'error');
    }
}


// 查看详情
function viewDetails(id) {
    showToast(`查看种子编号 ${id} 的详细信息`, 'success');
}

// 管理备注
function manageNotes(fieldId) {
    window.location.href = `collection.html?fieldId=${fieldId}&action=notes`;
}
})