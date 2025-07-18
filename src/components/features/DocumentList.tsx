import { useDocumentStore } from '@/store'
import { cn } from '@/lib/utils'
import type { Document } from '@/types'

interface DocumentListProps {
  className?: string
}

export function DocumentList({ className }: DocumentListProps) {
  const { documents, currentDocument, setCurrentDocument, removeDocument } = useDocumentStore()

  const handleDocumentClick = (document: Document) => {
    setCurrentDocument(document)
  }

  const handleRemoveDocument = async (e: React.MouseEvent, documentId: string) => {
    e.stopPropagation()
    await removeDocument(documentId)
  }

  const getFileIcon = (type: string) => {
    switch (type) {
      case 'pdf':
        return '📄'
      case 'txt':
        return '📝'
      case 'md':
        return '📋'
      case 'epub':
        return '📚'
      default:
        return '📄'
    }
  }

  if (documents.length === 0) {
    return (
      <div className={cn('text-center py-8', className)}>
        <div className="text-gray-400 text-lg">No documents imported yet</div>
        <div className="text-gray-500 text-sm mt-2">Import files to get started</div>
      </div>
    )
  }

  return (
    <div className={cn('space-y-2', className)}>
      {documents.map((document) => (
        <div
          key={document.id}
          className={cn(
            'flex items-center justify-between p-3 rounded-lg border cursor-pointer transition-colors',
            currentDocument?.id === document.id
              ? 'border-blue-500 bg-blue-50'
              : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
          )}
          onClick={() => handleDocumentClick(document)}
        >
          <div className="flex items-center space-x-3">
            <div className="text-2xl">{getFileIcon(document.type)}</div>
            <div className="min-w-0 flex-1">
              <div className="font-medium text-gray-900 truncate">{document.title}</div>
              <div className="text-sm text-gray-500 capitalize">
                {document.type} • {document.metadata?.createdAt.toLocaleDateString()}
              </div>
            </div>
          </div>

          <button
            onClick={(e) => handleRemoveDocument(e, document.id)}
            className="text-gray-400 hover:text-red-500 transition-colors p-1"
            title="Remove document"
          >
            ✕
          </button>
        </div>
      ))}
    </div>
  )
}
