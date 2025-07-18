import { useState, useCallback, useRef } from 'react'
import { useDocumentStore } from '@/store'
import { DocumentProcessor } from '@/services/documentProcessor'
import { cn } from '@/lib/utils'

interface FileImportZoneProps {
  onFileImport?: (files: File[]) => void
  className?: string
}

const ACCEPTED_FILE_TYPES = ['.pdf', '.txt', '.md', '.epub']
const MAX_FILE_SIZE = 50 * 1024 * 1024 // 50MB

export function FileImportZone({ onFileImport, className }: FileImportZoneProps) {
  const [isDragActive, setIsDragActive] = useState(false)
  const [isUploading, setIsUploading] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const { addDocument } = useDocumentStore()

  const validateFile = useCallback((file: File): boolean => {
    // Check file size
    if (file.size > MAX_FILE_SIZE) {
      alert(`File "${file.name}" is too large. Maximum size is 50MB.`)
      return false
    }

    // Check file type
    const extension = '.' + file.name.split('.').pop()?.toLowerCase()
    if (!ACCEPTED_FILE_TYPES.includes(extension)) {
      alert(
        `File type "${extension}" is not supported. Supported types: ${ACCEPTED_FILE_TYPES.join(', ')}`
      )
      return false
    }

    return true
  }, [])

  const processFiles = useCallback(
    async (files: File[]) => {
      const validFiles = files.filter(validateFile)
      if (validFiles.length === 0) return

      setIsUploading(true)
      try {
        for (const file of validFiles) {
          const document = await DocumentProcessor.processFile(file)
          await addDocument(document)
        }

        onFileImport?.(validFiles)
      } catch (error) {
        console.error('Error processing files:', error)
        alert('Error processing files. Please try again.')
      } finally {
        setIsUploading(false)
      }
    },
    [validateFile, addDocument, onFileImport]
  )

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setIsDragActive(true)
  }, [])

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setIsDragActive(false)
  }, [])

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault()
      e.stopPropagation()
      setIsDragActive(false)

      const files = Array.from(e.dataTransfer.files)
      processFiles(files)
    },
    [processFiles]
  )

  const handleFileInput = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const files = e.target.files ? Array.from(e.target.files) : []
      processFiles(files)

      // Reset input
      if (fileInputRef.current) {
        fileInputRef.current.value = ''
      }
    },
    [processFiles]
  )

  const handleClick = useCallback(() => {
    fileInputRef.current?.click()
  }, [])

  return (
    <div
      className={cn(
        'relative border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors',
        isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400',
        isUploading && 'pointer-events-none opacity-50',
        className
      )}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onDrop={handleDrop}
      onClick={handleClick}
    >
      <input
        ref={fileInputRef}
        type="file"
        multiple
        accept={ACCEPTED_FILE_TYPES.join(',')}
        onChange={handleFileInput}
        className="hidden"
      />

      <div className="flex flex-col items-center space-y-4">
        <div className="text-6xl text-gray-400">📄</div>

        {isUploading ? (
          <div className="text-lg font-medium text-gray-700">Processing files...</div>
        ) : (
          <>
            <div className="text-lg font-medium text-gray-700">
              {isDragActive ? 'Drop files here' : 'Drop files here or click to browse'}
            </div>

            <div className="text-sm text-gray-500">Supported formats: PDF, TXT, MD, EPUB</div>

            <div className="text-xs text-gray-400">Maximum file size: 50MB</div>
          </>
        )}
      </div>
    </div>
  )
}
