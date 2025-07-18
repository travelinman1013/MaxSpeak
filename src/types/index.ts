export interface Document {
  id: string
  title: string
  content: string
  type: 'pdf' | 'txt' | 'md' | 'epub'
  metadata?: {
    author?: string
    pages?: number
    createdAt: Date
    modifiedAt: Date
  }
  lastReadPosition?: number
  bookmarks?: Bookmark[]
}

export interface Bookmark {
  id: string
  documentId: string
  position: number
  label?: string
  createdAt: Date
}

export interface ReadingProgress {
  documentId: string
  position: number
  percentage: number
  lastRead: Date
}

export interface TTSSettings {
  voice: string
  rate: number
  pitch: number
  volume: number
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'system'
  fontSize: number
  fontFamily: string
  readingWidth: 'narrow' | 'medium' | 'wide'
  ttsSettings: TTSSettings
}
