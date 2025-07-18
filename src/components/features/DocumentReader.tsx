import React, { useEffect, useRef, useState, useCallback, useMemo } from 'react'
import type { Document } from '@/types'
import { cn } from '@/lib/utils'
import { useTTSStore } from '@/store'

interface DocumentReaderProps {
  document: Document
  className?: string
}

export const DocumentReader = React.memo(function DocumentReader({ document, className }: DocumentReaderProps) {
  const contentRef = useRef<HTMLDivElement>(null)
  const { setPlaying, setPaused } = useTTSStore()
  const [currentPage, setCurrentPage] = useState(1)
  const [fontSize, setFontSize] = useState(16)
  const [selectedText, setSelectedText] = useState('')
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    // Scroll to top when document changes
    if (contentRef.current) {
      contentRef.current.scrollTop = 0
      setCurrentPage(1)
    }
  }, [document.id])

  useEffect(() => {
    // Check initial screen size and set up resize listener
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 640)
    }
    
    checkMobile()
    
    // Throttled resize handler to prevent excessive re-renders
    let timeoutId: NodeJS.Timeout
    const handleResize = () => {
      clearTimeout(timeoutId)
      timeoutId = setTimeout(checkMobile, 150)
    }
    
    window.addEventListener('resize', handleResize)
    return () => {
      window.removeEventListener('resize', handleResize)
      clearTimeout(timeoutId)
    }
  }, [])

  useEffect(() => {
    // Handle text selection with debouncing
    let timeoutId: NodeJS.Timeout
    
    const handleSelection = () => {
      clearTimeout(timeoutId)
      timeoutId = setTimeout(() => {
        const selection = window.getSelection()
        if (selection && selection.toString().trim()) {
          setSelectedText(selection.toString())
        } else {
          setSelectedText('')
        }
      }, 100)
    }

    window.document.addEventListener('selectionchange', handleSelection)
    return () => {
      window.document.removeEventListener('selectionchange', handleSelection)
      clearTimeout(timeoutId)
    }
  }, [])

  const handleReadSection = useCallback(async (sectionContent: string) => {
    try {
      // Stop any current speech gracefully
      if (window.speechSynthesis.speaking) {
        window.speechSynthesis.cancel()
        // Wait a moment for cancellation to complete
        await new Promise((resolve) => setTimeout(resolve, 100))
      }

      // Start reading the section
      const utterance = new SpeechSynthesisUtterance(sectionContent)

      utterance.onstart = () => {
        setPlaying(true)
        setPaused(false)
      }

      utterance.onend = () => {
        setPlaying(false)
        setPaused(false)
      }

      utterance.onerror = (event) => {
        console.warn('Section TTS error:', event.error)
        setPlaying(false)
        setPaused(false)

        // Only show error for unexpected errors, not cancellations
        if (event.error !== 'interrupted' && event.error !== 'canceled') {
          console.error('Unexpected TTS error:', event.error)
        }
      }

      window.speechSynthesis.speak(utterance)
    } catch (error) {
      console.warn('Error starting section reading:', error)
      setPlaying(false)
      setPaused(false)
    }
  }, [setPlaying, setPaused])

  const adjustFontSize = useCallback((delta: number) => {
    setFontSize((prev) => Math.max(12, Math.min(24, prev + delta)))
  }, [])

  const totalPages = useMemo(() => 
    document.metadata?.pages || Math.ceil(document.content.length / 3000),
    [document.metadata?.pages, document.content.length]
  )

  const contentStyle = useMemo(() => ({
    fontSize: `${fontSize}px`,
    lineHeight: 1.6,
    maxWidth: isMobile ? '100%' : '210mm',
    fontFamily: 'Georgia, "Times New Roman", Times, serif',
  }), [fontSize, isMobile])

  const renderContent = useMemo(() => {
    if (!document.sections || document.sections.length === 0) {
      // Render as clean, book-like pages for PDFs
      return (
        <div className="max-w-none">
          <div
            className="bg-white dark:bg-gray-800 shadow-lg p-6 sm:p-12 min-h-[800px] leading-relaxed text-justify mx-4 sm:mx-auto"
            style={contentStyle}
          >
            <div className="whitespace-pre-wrap break-words">{document.content}</div>
          </div>
        </div>
      )
    }

    // Render structured content with clean typography
    return (
      <div className="max-w-none">
        <div
          className="bg-white dark:bg-gray-800 shadow-lg mx-4 sm:mx-auto p-6 sm:p-12 min-h-[800px]"
          style={{
            maxWidth: isMobile ? '100%' : '210mm',
            fontFamily: 'Georgia, "Times New Roman", Times, serif',
          }}
        >
          {document.sections.map((section, index) => {
            const HeadingComponent =
              section.level === 1
                ? 'h1'
                : section.level === 2
                  ? 'h2'
                  : section.level === 3
                    ? 'h3'
                    : section.level === 4
                      ? 'h4'
                      : section.level === 5
                        ? 'h5'
                        : 'h6'

            return (
              <section key={section.id} id={section.id} className="mb-8">
                <div className="flex items-start justify-between mb-6">
                  {React.createElement(
                    HeadingComponent,
                    {
                      className: cn(
                        'font-bold text-gray-900 dark:text-gray-100 leading-tight',
                        section.level === 1 && 'text-3xl mb-4',
                        section.level === 2 && 'text-2xl mb-3',
                        section.level === 3 && 'text-xl mb-3',
                        section.level >= 4 && 'text-lg mb-2'
                      ),
                    },
                    section.title
                  )}
                </div>

                <div
                  className="text-gray-800 dark:text-gray-200 leading-relaxed text-justify"
                  style={{ fontSize: `${fontSize}px`, lineHeight: 1.6 }}
                >
                  {section.content.split('\n\n').map((paragraph, idx) => (
                    <p key={idx} className="mb-4 indent-8 first:indent-0">
                      {paragraph}
                    </p>
                  ))}
                </div>

                {index < document.sections!.length - 1 && (
                  <hr className="my-8 border-gray-200 dark:border-gray-700" />
                )}
              </section>
            )
          })}
        </div>
      </div>
    )
  }, [document.sections, document.content, contentStyle, fontSize, isMobile])

  return (
    <div className={cn('relative', className)}>
      {/* Document Header with controls */}
      <div className="sticky top-0 z-10 bg-gray-50 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-4 sm:px-6 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2 sm:space-x-4 flex-1 min-w-0">
            <h1 className="text-sm sm:text-lg font-semibold text-gray-900 dark:text-gray-100 truncate">
              {document.title}
            </h1>
            <span className="text-xs sm:text-sm text-gray-500 dark:text-gray-400 bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded shrink-0">
              {document.type.toUpperCase()}
            </span>
          </div>

          <div className="flex items-center space-x-2 sm:space-x-4">
            {/* Font Size Controls */}
            <div className="flex items-center space-x-1 sm:space-x-2 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 px-2 sm:px-3 py-1">
              <button
                onClick={() => adjustFontSize(-1)}
                className="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 font-bold text-xs sm:text-sm"
                title="Decrease font size"
              >
                Aa
              </button>
              <div className="w-px h-3 sm:h-4 bg-gray-300 dark:bg-gray-600"></div>
              <button
                onClick={() => adjustFontSize(1)}
                className="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 font-bold text-sm sm:text-lg"
                title="Increase font size"
              >
                Aa
              </button>
            </div>

            {/* Page Counter */}
            <div className="text-xs sm:text-sm text-gray-600 dark:text-gray-400 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 px-2 sm:px-3 py-1">
              {currentPage} / {totalPages}
            </div>

            {/* List View Toggle (hidden on small screens) */}
            <button
              className="hidden sm:block p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600"
              title="Toggle list view"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 10h16M4 14h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Document Content */}
      <div
        ref={contentRef}
        className="overflow-y-auto bg-gray-100 dark:bg-gray-950"
        style={{ height: 'calc(100vh - 200px)' }}
      >
        <div className="py-8">{renderContent}</div>
      </div>

      {/* Selection Context Menu */}
      {selectedText && (
        <div className="fixed bottom-16 sm:bottom-20 left-1/2 transform -translate-x-1/2 z-20 mx-4">
          <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg shadow-lg px-3 sm:px-4 py-2 flex items-center space-x-2">
            <button
              onClick={() => handleReadSection(selectedText)}
              className="flex items-center space-x-1 px-2 sm:px-3 py-1 text-xs sm:text-sm bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
            >
              <svg className="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15.536 8.464a5 5 0 010 7.072M9 9v6"
                />
              </svg>
              <span className="hidden sm:inline">Read Selection</span>
              <span className="sm:hidden">Read</span>
            </button>
            <button
              onClick={() => setSelectedText('')}
              className="p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <svg className="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
      )}
    </div>
  )
})
