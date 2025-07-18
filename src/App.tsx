import { useEffect } from 'react'
import { FileImportZone } from '@/components/features/FileImportZone'
import { DocumentList } from '@/components/features/DocumentList'
import { PlaybackControls } from '@/components/features/PlaybackControls'
import { useDocumentStore } from '@/store'

function App() {
  const { documents, currentDocument, initializeStorage } = useDocumentStore()

  useEffect(() => {
    initializeStorage()
  }, [initializeStorage])

  return (
    <div className="min-h-screen" style={{ backgroundColor: 'hsl(var(--background))' }}>
      <header className="border-b" style={{ borderColor: 'hsl(var(--border))' }}>
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold" style={{ color: 'hsl(var(--foreground))' }}>
            MaxSpeak
          </h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Panel - Document Management */}
          <div className="lg:col-span-1">
            <div className="space-y-6">
              <div>
                <h2
                  className="text-lg font-semibold mb-4"
                  style={{ color: 'hsl(var(--foreground))' }}
                >
                  Import Documents
                </h2>
                <FileImportZone />
              </div>

              <div>
                <h2
                  className="text-lg font-semibold mb-4"
                  style={{ color: 'hsl(var(--foreground))' }}
                >
                  Your Documents ({documents.length})
                </h2>
                <DocumentList />
              </div>
            </div>
          </div>

          {/* Right Panel - Reader */}
          <div className="lg:col-span-2">
            <div className="space-y-6">
              {/* Playback Controls */}
              <PlaybackControls />

              {/* Document Reader */}
              {currentDocument ? (
                <div
                  className="border rounded-lg p-6"
                  style={{ borderColor: 'hsl(var(--border))' }}
                >
                  <h2
                    className="text-xl font-semibold mb-4"
                    style={{ color: 'hsl(var(--foreground))' }}
                  >
                    {currentDocument.title}
                  </h2>
                  <div className="text-sm mb-4" style={{ color: 'hsl(var(--muted-foreground))' }}>
                    {currentDocument.type.toUpperCase()} •{' '}
                    {currentDocument.metadata?.createdAt.toLocaleDateString()}
                    {currentDocument.metadata?.pages &&
                      ` • ${currentDocument.metadata.pages} pages`}
                  </div>
                  <div
                    className="prose max-w-none leading-relaxed whitespace-pre-wrap"
                    style={{ color: 'hsl(var(--foreground))' }}
                  >
                    {currentDocument.content ||
                      'Document content will appear here once processed...'}
                  </div>
                </div>
              ) : (
                <div
                  className="border-2 border-dashed rounded-lg p-12 text-center"
                  style={{ borderColor: 'hsl(var(--border))' }}
                >
                  <div className="text-6xl mb-4">📖</div>
                  <h2
                    className="text-xl font-semibold mb-2"
                    style={{ color: 'hsl(var(--foreground))' }}
                  >
                    No document selected
                  </h2>
                  <p style={{ color: 'hsl(var(--muted-foreground))' }}>
                    Import and select a document to start reading
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

export default App
