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

 // 种子数据
  const fieldData = ref([
    { id: '25KY00076', images: 5, note1: '01', note2: '正常生长' },
    { id: '25KY00077', images: 3, note1: '02', note2: '轻度病虫害' },
    { id: '25KY00078', images: 7, note1: '03', note2: '优良品种' },
    { id: '25KY00079', images: 2, note1: '04', note2: '需施肥' },
    { id: '25KY00080', images: 4, note1: '05', note2: '正常生长' },
    { id: '25KY00081', images: 6, note1: '06', note2: '优良品种' },
    { id: '25KY00082', images: 1, note1: '07', note2: '需灌溉' },
    { id: '25KY00083', images: 8, note1: '08', note2: '正常生长' },
    { id: '25KY00084', images: 3, note1: '09', note2: '轻度病虫害' },
    { id: '25KY00085', images: 5, note1: '10', note2: '优良品种' },
    { id: '25KY00086', images: 4, note1: '11', note2: '正常生长' },
    { id: '25KY00087', images: 6, note1: '12', note2: '需除草' },
    { id: '25KY00088', images: 2, note1: '13', note2: '轻度干旱' },
    { id: '25KY00089', images: 7, note1: '14', note2: '优良品种' },
    { id: '25KY00090', images: 3, note1: '15', note2: '正常生长' },
    { id: '25KY00091', images: 5, note1: '16', note2: '需施肥' },
    { id: '25KY00092', images: 8, note1: '17', note2: '生长旺盛' },
    { id: '25KY00093', images: 1, note1: '18', note2: '需灌溉' },
    { id: '25KY00094', images: 4, note1: '19', note2: '正常生长' },
    { id: '25KY00095', images: 6, note1: '20', note2: '优良品种' }
  ]);

  // 采集历史数据
  const historyData = ref([
    { id: 1, title: '种子突变体表型记录', date: '2025-10-19 14:30', info: '样本数: 24', status: '已完成', statusClass: 'status-completed' },
    { id: 2, title: '种子生长数据采集', date: '2025-1-18 09:15', info: '样本数: 36', status: '已完成', statusClass: 'status-completed' },
    { id: 3, title: '种子环境数据记录', date: '2025-1-19 16:45', info: '记录点: 8个', status: '处理中', statusClass: 'status-pending' },
    { id: 4, title: '种子基因型鉴定', date: '2025-1-20 11:20', info: '样本数: 42', status: '已完成', statusClass: 'status-completed' },
    { id: 5, title: '种子病虫害详细记录', date: '2025-1-28 14:30', info: '样本数: 24', status: '已完成', statusClass: 'status-completed' },
    { id: 6, title: '种子生长记录', date: '2025-3-28 14:30', info: '样本数: 4', status: '已完成', statusClass: 'status-completed' }
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