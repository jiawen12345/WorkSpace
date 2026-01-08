import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useAppStore = defineStore('app', () => {
  const currentView = ref('login');
  const activeTab = ref('data-collection');
  const showProfileDropdown = ref(false);
  
  // 模态框状态
  const modals = ref({
    imageViewer: false,
    notesManager: false,
    uploadModal: false,
    downloadModal: false
  });

 // 实验数据
  const fieldData = ref([
  ]);

  // 采集历史数据
  const historyData = ref([
    { id: 1, title: '实验突变体表型记录', date: '2025-10-19 14:30', info: '样本数: 24', status: '已完成', statusClass: 'status-completed' },
    { id: 2, title: '实验生长数据采集', date: '2025-1-18 09:15', info: '样本数: 36', status: '已完成', statusClass: 'status-completed' },
    { id: 3, title: '实验环境数据记录', date: '2025-1-19 16:45', info: '记录点: 8个', status: '处理中', statusClass: 'status-pending' },
    { id: 4, title: '实验基因型鉴定', date: '2025-1-20 11:20', info: '样本数: 42', status: '已完成', statusClass: 'status-completed' },
    { id: 5, title: '实验病虫害详细记录', date: '2025-1-28 14:30', info: '样本数: 24', status: '已完成', statusClass: 'status-completed' },
    { id: 6, title: '实验生长记录', date: '2025-3-28 14:30', info: '样本数: 4', status: '已完成', statusClass: 'status-completed' }
  ]);


  // 备注数据
  const notesData = ref({});

  const setCurrentView = (view) => {
    currentView.value = view;
  };

  const setActiveTab = (tab) => {
    activeTab.value = tab;
  };

  const toggleModal = (modalName, show) => {
    modals.value[modalName] = show;
  };

  const loadNotesFromStorage = () => {
    const storedNotes = localStorage.getItem('fieldNotes');
    if (storedNotes) {
      notesData.value = JSON.parse(storedNotes);
    }
  };

  const saveNotesToStorage = () => {
    localStorage.setItem('fieldNotes', JSON.stringify(notesData.value));
  };

  return {
    currentView,
    activeTab,
    showProfileDropdown,
    modals,
    fieldData,
    historyData,
    notesData,
    setCurrentView,
    setActiveTab,
    toggleModal,
    loadNotesFromStorage,
    saveNotesToStorage
  };
});