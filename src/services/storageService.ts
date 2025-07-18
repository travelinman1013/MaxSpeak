import type { Document } from '@/types'

const DB_NAME = 'maxspeak'
const DB_VERSION = 1
const STORE_NAME = 'documents'

export class StorageService {
  private static db: IDBDatabase | null = null

  static async init(): Promise<void> {
    if (this.db) return

    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => {
        this.db = request.result
        resolve()
      }

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result

        if (!db.objectStoreNames.contains(STORE_NAME)) {
          const store = db.createObjectStore(STORE_NAME, { keyPath: 'id' })
          store.createIndex('title', 'title', { unique: false })
          store.createIndex('type', 'type', { unique: false })
          store.createIndex('createdAt', 'metadata.createdAt', { unique: false })
        }
      }
    })
  }

  static async saveDocument(document: Document): Promise<void> {
    await this.init()
    if (!this.db) throw new Error('Database not initialized')

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([STORE_NAME], 'readwrite')
      const store = transaction.objectStore(STORE_NAME)
      const request = store.put(document)

      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }

  static async getDocument(id: string): Promise<Document | null> {
    await this.init()
    if (!this.db) throw new Error('Database not initialized')

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([STORE_NAME], 'readonly')
      const store = transaction.objectStore(STORE_NAME)
      const request = store.get(id)

      request.onsuccess = () => {
        const result = request.result
        if (result && result.metadata) {
          // Convert dates back from strings
          result.metadata.createdAt = new Date(result.metadata.createdAt)
          result.metadata.modifiedAt = new Date(result.metadata.modifiedAt)
        }
        resolve(result || null)
      }
      request.onerror = () => reject(request.error)
    })
  }

  static async getAllDocuments(): Promise<Document[]> {
    await this.init()
    if (!this.db) throw new Error('Database not initialized')

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([STORE_NAME], 'readonly')
      const store = transaction.objectStore(STORE_NAME)
      const request = store.getAll()

      request.onsuccess = () => {
        const results = request.result || []
        // Convert dates back from strings
        results.forEach((doc: Document) => {
          if (doc.metadata) {
            doc.metadata.createdAt = new Date(doc.metadata.createdAt)
            doc.metadata.modifiedAt = new Date(doc.metadata.modifiedAt)
          }
        })
        resolve(results)
      }
      request.onerror = () => reject(request.error)
    })
  }

  static async deleteDocument(id: string): Promise<void> {
    await this.init()
    if (!this.db) throw new Error('Database not initialized')

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([STORE_NAME], 'readwrite')
      const store = transaction.objectStore(STORE_NAME)
      const request = store.delete(id)

      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }

  static async clearAll(): Promise<void> {
    await this.init()
    if (!this.db) throw new Error('Database not initialized')

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([STORE_NAME], 'readwrite')
      const store = transaction.objectStore(STORE_NAME)
      const request = store.clear()

      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }
}
