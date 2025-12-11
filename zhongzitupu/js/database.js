// IndexedDB相关函数
let db;
const DB_NAME = 'RiceFieldImageDB';
const DB_VERSION = 1;
const STORE_NAME = 'uploadedImages';

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

        
       // 上传图片到指定稻田编号
function uploadImageForField(fieldId) {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.multiple = true;
    
    input.onchange = function(e) {
        const files = e.target.files;
        if (files.length > 0) {
            handleFilesForField(files, fieldId);
        }
    };
    
    input.click();
}

// 处理上传的文件
async function handleFilesForField(files, fieldId) {
    const validFiles = Array.from(files).filter(file => {
        if (!file.type.startsWith('image/')) {
            showToast('只能上传图片文件', 'error');
            return false;
        }
        
        if (file.size > 5 * 1024 * 1024) {
            showToast('图片大小不能超过5MB', 'error');
            return false;
        }
        
        return true;
    });
    
    if (validFiles.length === 0) return;
    
    showToast(`正在为 ${fieldId} 上传图片...`, 'success');
    
    for (const file of validFiles) {
        try {
            const imageData = await new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = function(e) {
                    resolve({
                        id: Date.now() + Math.random(),
                        fieldId: fieldId,
                        name: file.name,
                        url: e.target.result,
                        uploadTime: new Date().toISOString()
                    });
                };
                reader.onerror = () => reject(new Error('文件读取失败'));
                reader.readAsDataURL(file);
            });
            
            // 保存到IndexedDB（如果有这个函数）
            if (typeof saveImageToDB === 'function') {
                await saveImageToDB(imageData);
            }
            
        } catch (error) {
            console.error('处理文件失败:', error);
            showToast(`处理文件 ${file.name} 失败`, 'error');
        }
    }
    
    // 重新渲染表格
    setTimeout(async () => {
        await renderFieldTable();
        showToast(`成功为 ${fieldId} 上传 ${validFiles.length} 张图片`, 'success');
    }, 1000);
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
        })

        

        
