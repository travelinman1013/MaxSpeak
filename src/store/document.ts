import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Document, ReadingProgress } from '@/types'
import { StorageService } from '@/services/storageService'

interface DocumentState {
  documents: Document[]
  currentDocument: Document | null
  readingProgress: Record<string, ReadingProgress>
  isLoading: boolean
  error: string | null

  // Actions
  addDocument: (document: Document) => Promise<void>
  removeDocument: (id: string) => Promise<void>
  setCurrentDocument: (document: Document | null) => void
  updateReadingProgress: (documentId: string, position: number, percentage: number) => void
  clearDocuments: () => Promise<void>
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  loadDocuments: () => Promise<void>
  initializeStorage: () => Promise<void>
}

export const useDocumentStore = create<DocumentState>()(
  persist(
    (set, get) => ({
      documents: [],
      currentDocument: null,
      readingProgress: {},
      isLoading: false,
      error: null,

      initializeStorage: async () => {
        try {
          await StorageService.init()
          await get().loadDocuments()
        } catch (error) {
          console.error('Failed to initialize storage:', error)
          set({ error: 'Failed to initialize storage' })
        }
      },

      loadDocuments: async () => {
        try {
          set({ isLoading: true, error: null })
          const documents = await StorageService.getAllDocuments()
          set({ documents, isLoading: false })
        } catch (error) {
          console.error('Failed to load documents:', error)
          set({ error: 'Failed to load documents', isLoading: false })
        }
      },

      addDocument: async (document) => {
        try {
          await StorageService.saveDocument(document)
          set((state) => ({
            documents: [...state.documents, document],
          }))
        } catch (error) {
          console.error('Failed to save document:', error)
          set({ error: 'Failed to save document' })
        }
      },

      removeDocument: async (id) => {
        try {
          await StorageService.deleteDocument(id)
          set((state) => ({
            documents: state.documents.filter((doc) => doc.id !== id),
            currentDocument: state.currentDocument?.id === id ? null : state.currentDocument,
          }))
        } catch (error) {
          console.error('Failed to remove document:', error)
          set({ error: 'Failed to remove document' })
        }
      },

      setCurrentDocument: (document) => set({ currentDocument: document }),

      updateReadingProgress: (documentId, position, percentage) =>
        set((state) => ({
          readingProgress: {
            ...state.readingProgress,
            [documentId]: {
              documentId,
              position,
              percentage,
              lastRead: new Date(),
            },
          },
        })),

      clearDocuments: async () => {
        try {
          await StorageService.clearAll()
          set({
            documents: [],
            currentDocument: null,
            readingProgress: {},
          })
        } catch (error) {
          console.error('Failed to clear documents:', error)
          set({ error: 'Failed to clear documents' })
        }
      },

      setLoading: (loading) => set({ isLoading: loading }),

      setError: (error) => set({ error }),
    }),
    {
      name: 'maxspeak-documents',
      partialize: (state) => ({
        currentDocument: state.currentDocument,
        readingProgress: state.readingProgress,
      }),
    }
  )
)
