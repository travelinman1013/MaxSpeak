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
  outline?: DocumentOutline[]
  sections?: DocumentSection[]
  tableOfContents?: TOCEntry[]
}

export interface DocumentOutline {
  id: string
  title: string
  level: number
  pageNumber?: number
  children?: DocumentOutline[]
}

export interface DocumentSection {
  id: string
  title: string
  content: string
  level: number
  pageNumber?: number
  startOffset: number
  endOffset: number
}

export interface TOCEntry {
  id: string
  title: string
  level: number
  sectionId: string
  pageNumber?: number
  children?: TOCEntry[]
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
