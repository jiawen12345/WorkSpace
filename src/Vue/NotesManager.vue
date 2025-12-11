<template>
  <div class="modal active">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title">备注管理 - <span>{{ fieldId }}</span></h3>
        <button class="close-modal" @click="closeModal">&times;</button>
      </div>
      <div class="notes-list">
        <div v-if="notes.length === 0" class="no-notes">暂无备注</div>
        <div class="note-item" v-for="(note, index) in notes" :key="index">
          <div class="note-content">{{ note.content }}</div>
          <div class="note-meta">
            <span class="note-author">{{ note.author || '系统管理员' }}</span>
            <span class="note-date">{{ note.date }}</span>
          </div>
        </div>
      </div>
      <div class="add-note-form">
        <h4>添加新备注</h4>
        <textarea v-model="newNoteContent" placeholder="请输入备注内容..."></textarea>
        <div class="modal-actions">
          <button class="cancel-btn" @click="closeModal">取消</button>
          <button class="confirm-btn" @click="addNote" :disabled="!newNoteContent.trim()">添加备注</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'NotesManager',
  props: {
    fieldId: {
      type: String,
      required: true
    },
    notes: {
      type: Array,
      default: () => []
    }
  },
  emits: ['close', 'add-note'],
  setup(props, { emit }) {
    const newNoteContent = ref('')

    const closeModal = () => {
      emit('close')
    }

    const addNote = () => {
      if (newNoteContent.value.trim()) {
        emit('add-note', newNoteContent.value.trim())
        newNoteContent.value = ''
      }
    }

    return {
      newNoteContent,
      closeModal,
      addNote
    }
  }
}
</script>

<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background-color: white;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 80%;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e8f4e3;
}

.modal-title {
  font-size: 20px;
  color: #2d5016;
  font-weight: 600;
}

.close-modal {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #7a8c6a;
  transition: all 0.3s;
}

.close-modal:hover {
  color: #2d5016;
}

.notes-list {
  max-height: 300px;
  overflow-y: auto;
  margin-bottom: 20px;
  border: 1px solid #e8f4e3;
  border-radius: 8px;
  padding: 15px;
}

.no-notes {
  text-align: center;
  color: #7a8c6a;
  padding: 20px;
}

.note-item {
  padding: 12px;
  border-bottom: 1px solid #e8f4e3;
  margin-bottom: 10px;
}

.note-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.note-content {
  margin-bottom: 8px;
  line-height: 1.5;
}

.note-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #7a8c6a;
}

.note-author {
  font-weight: 500;
}

.note-date {
  color: #8a9c7a;
}

.add-note-form {
  margin-top: 20px;
}

.add-note-form h4 {
  margin-bottom: 10px;
  color: #2d5016;
}

.add-note-form textarea {
  width: 100%;
  padding: 12px 15px;
  border: 1px solid #d0e0c3;
  border-radius: 8px;
  font-size: 15px;
  transition: all 0.3s;
  background-color: #f9fdf6;
  resize: vertical;
  min-height: 100px;
  margin-bottom: 15px;
}

.add-note-form textarea:focus {
  outline: none;
  border-color: #7ba052;
  box-shadow: 0 0 0 2px rgba(123, 160, 82, 0.2);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
}

.cancel-btn, .confirm-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.cancel-btn {
  background-color: #f5f5f5;
  color: #666;
}

.cancel-btn:hover {
  background-color: #e0e0e0;
}

.confirm-btn {
  background-color: #5a7d3c;
  color: white;
}

.confirm-btn:hover {
  background-color: #4a6a30;
}

.confirm-btn:disabled {
  background-color: #c0d4b0;
  cursor: not-allowed;
}
</style>