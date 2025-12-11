// indexedDB.js
const DB_NAME = 'SeedDatabase'
const DB_VERSION = 1
const STORE_NAME = 'images'

// 初始化数据库
export const initIndexedDB = () => {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION)
        
        request.onupgradeneeded = (event) => {
            const db = event.target.result
            
            // 创建图片存储
            if (!db.objectStoreNames.contains(STORE_NAME)) {
                const store = db.createObjectStore(STORE_NAME, { 
                    keyPath: 'id',
                    autoIncrement: true 
                })
                
                // 创建字段ID索引
                store.createIndex('fieldId', 'fieldId', { unique: false })
                
                // 创建上传时间索引
                store.createIndex('uploadTime', 'uploadTime', { unique: false })
            }
        }
        
        request.onsuccess = (event) => {
            resolve(event.target.result)
        }
        
        request.onerror = (event) => {
            reject(new Error('打开数据库失败: ' + event.target.error))
        }
    })
}

// 保存图片到数据库
export const saveImageToDB = (imageData) => {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION)
        
        request.onsuccess = (event) => {
            const db = event.target.result
            const transaction = db.transaction([STORE_NAME], 'readwrite')
            const store = transaction.objectStore(STORE_NAME)
            
            // 确保有唯一的ID
            if (!imageData.id) {
                imageData.id = Date.now() + Math.random().toString(36).substr(2, 9)
            }
            
            const addRequest = store.add(imageData)
            
            addRequest.onsuccess = () => {
                resolve(imageData.id)
            }
            
            addRequest.onerror = (event) => {
                reject(new Error('保存图片失败: ' + event.target.error))
            }
        }
        
        request.onerror = (event) => {
            reject(new Error('打开数据库失败: ' + event.target.error))
        }
    })
}

// 根据字段ID获取图片
export const getImagesByFieldId = (fieldId) => {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION)
        
        request.onsuccess = (event) => {
            const db = event.target.result
            const transaction = db.transaction([STORE_NAME], 'readonly')
            const store = transaction.objectStore(STORE_NAME)
            const index = store.index('fieldId')
            
            const getRequest = index.getAll(fieldId)
            
            getRequest.onsuccess = () => {
                // 按上传时间倒序排列（最新的在前面）
                const images = getRequest.result.sort((a, b) => {
                    return new Date(b.uploadTime) - new Date(a.uploadTime)
                })
                resolve(images)
            }
            
            getRequest.onerror = () => {
                reject(new Error('获取图片失败'))
            }
        }
        
        request.onerror = (event) => {
            reject(new Error('打开数据库失败: ' + event.target.error))
        }
    })
}

// 删除图片
export const deleteImageFromDB = async (fieldId, imageIndex) => {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION)
        
        request.onsuccess = (event) => {
            const db = event.target.result
            const transaction = db.transaction([STORE_NAME], 'readwrite')
            const store = transaction.objectStore(STORE_NAME)
            const index = store.index('fieldId')
            
            // 先获取该字段的所有图片
            const getRequest = index.getAll(fieldId)
            
            getRequest.onsuccess = () => {
                const images = getRequest.result
                if (images && images.length > imageIndex) {
                    // 找到要删除的图片
                    const imageToDelete = images[imageIndex]
                    
                    // 根据主键删除
                    const deleteRequest = store.delete(imageToDelete.id)
                    
                    deleteRequest.onsuccess = () => {
                        resolve(true)
                    }
                    
                    deleteRequest.onerror = () => {
                        reject(new Error('删除图片失败'))
                    }
                } else {
                    reject(new Error('未找到要删除的图片'))
                }
            }
            
            getRequest.onerror = () => {
                reject(new Error('查询图片失败'))
            }
        }
        
        request.onerror = (event) => {
            reject(new Error('打开数据库失败: ' + event.target.error))
        }
    })
}

// 根据图片ID删除图片
export const deleteImageById = (imageId) => {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION)
        
        request.onsuccess = (event) => {
            const db = event.target.result
            const transaction = db.transaction([STORE_NAME], 'readwrite')
            const store = transaction.objectStore(STORE_NAME)
            
            const deleteRequest = store.delete(imageId)
            
            deleteRequest.onsuccess = () => {
                resolve(true)
            }
            
            deleteRequest.onerror = () => {
                reject(new Error('删除图片失败'))
            }
        }
        
        request.onerror = (event) => {
            reject(new Error('打开数据库失败: ' + event.target.error))
        }
    })
}

// 获取所有图片数量
export const getAllImagesCount = () => {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION)
        
        request.onsuccess = (event) => {
            const db = event.target.result
            const transaction = db.transaction([STORE_NAME], 'readonly')
            const store = transaction.objectStore(STORE_NAME)
            
            const countRequest = store.count()
            
            countRequest.onsuccess = () => {
                resolve(countRequest.result)
            }
            
            countRequest.onerror = () => {
                reject(new Error('获取图片数量失败'))
            }
        }
        
        request.onerror = (event) => {
            reject(new Error('打开数据库失败: ' + event.target.error))
        }
    })
}

export class ImageDB {
    constructor() {
        // 初始化数据库
        initIndexedDB()
    }
    
    async saveImage(imageData) {
        return await saveImageToDB(imageData)
    }
    
    async deleteImage(imageId) {
        return await deleteImageById(imageId)
    }
    
    // 可以根据需要添加其他方法
    async getImagesByFieldId(fieldId) {
        return await getImagesByFieldId(fieldId)
    }
}