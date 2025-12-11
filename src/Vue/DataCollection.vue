<template>
    <div class="main-container">
        <Header />
        <div class="main-content">
            <Sidebar />
            <div class="content-area">
                <h3 class="section-title">数据采集功能</h3>
                <div class="function-cards">
                    <div class="function-card" @click="goToCollectionDetail('crop')">
                        <i class="fas fa-seedling"></i>
                        <h3>种子监测</h3>
                        <p>记录种子生长状态和表型数据</p>
                    </div>
                    <div class="function-card" @click="goToCollectionDetail('weather')">
                        <i class="fas fa-cloud-sun"></i>
                        <h3>环境数据</h3>
                        <p>采集生长环境数据</p>
                    </div>
                    <div class="function-card" @click="goToCollectionDetail('pest')">
                        <i class="fas fa-bug"></i>
                        <h3>病虫害记录</h3>
                        <p>记录病虫害发生情况和防治措施</p>
                    </div>
                    <div class="image-collection" @click="goToImageCollection">
                        <i class="fas fa-camera"></i>
                        <h3>图像采集</h3>
                        <p>上传种子图像，用于表型分析</p>
                    </div>
                </div>
                
             
                <div class="function-cards">
                  
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { useRouter } from 'vue-router'
import Header from './Header.vue'
import Sidebar from './Sidebar.vue'


export default {
    name: 'DataCollection',
    components: {
        Header,
        Sidebar
    },
    setup() {
        const router = useRouter()
        
        const goToCollectionDetail = (type) => {
            router.push({ name: 'CollectionDetail', params: { type } })
        }
        
        const goToImageCollection = () => {
            router.push({ name: 'CollectionDetail', params: { type: 'image' } })
        }
        
        return {
            goToCollectionDetail,
            goToImageCollection
        }
    }
}
</script>

<style scoped>
.main-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    max-height: 100%;
    background-color: white;
    border-radius: 0;
    box-shadow: none;
    overflow: hidden;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width: 100%;
}

.main-content {
    display: flex;
    flex: 1;
    overflow: hidden;
}

.content-area {
    flex: 1;
    padding: 25px;
    overflow-y: auto;
  
}

.section-title {
    font-size: 20px;
    color: var(--text-dark);
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid var(--border-color);
}

.function-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}

</style>