import { useEffect } from 'react'
import { FileImportZone } from '@/components/features/FileImportZone'
import { DocumentList } from '@/components/features/DocumentList'
import { PlaybackControls } from '@/components/features/PlaybackControls'
import { DocumentReader } from '@/components/features/DocumentReader'
import { TOCNavigation } from '@/components/features/TOCNavigation'
import { useDocumentStore } from '@/store'

function App() {
  const { documents, currentDocument, initializeStorage } = useDocumentStore()

  useEffect(() => {
    initializeStorage()
  }, [initializeStorage])

  const handleNavigateToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId)
    if (element) {
      // Scroll with offset to account for sticky header
      const headerOffset = 120
      const elementPosition = element.getBoundingClientRect().top
      const offsetPosition = elementPosition + window.pageYOffset - headerOffset

      window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth',
      })
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950">
      <header className="sticky top-0 z-30 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">MaxSpeak</h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8">
          {/* Left Panel - Document Management */}
          <div className="lg:col-span-3 order-1 lg:order-1">
            <div className="space-y-6 lg:sticky lg:top-24">
              <div className="bg-white dark:bg-gray-900 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">
                  Import Documents
                </h2>
                <FileImportZone />
              </div>

              <div className="bg-white dark:bg-gray-900 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">
                  Your Documents ({documents.length})
                </h2>
                <DocumentList />
              </div>
            </div>
          </div>

          {/* Middle Panel - Document Reader */}
          <div className="lg:col-span-6 order-3 lg:order-2">
            {/* Document Reader */}
            {currentDocument ? (
              <DocumentReader document={currentDocument} />
            ) : (
              <div className="bg-white dark:bg-gray-900 border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-8 lg:p-12 text-center">
                <div className="text-4xl lg:text-6xl mb-4">📖</div>
                <h2 className="text-lg lg:text-xl font-semibold mb-2 text-gray-900 dark:text-gray-100">
                  No document selected
                </h2>
                <p className="text-gray-600 dark:text-gray-400 text-sm lg:text-base">
                  Import and select a document to start reading
                </p>
              </div>
            )}
          </div>

          {/* Right Panel - Table of Contents */}
          <div className="lg:col-span-3 order-2 lg:order-3">
            {currentDocument?.tableOfContents && currentDocument.tableOfContents.length > 0 && (
              <div className="lg:sticky lg:top-24">
                <TOCNavigation
                  tableOfContents={currentDocument.tableOfContents}
                  onNavigate={handleNavigateToSection}
                />
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Floating Playback Controls */}
      <PlaybackControls />
    </div>
  )
}

export default App
