import { useState } from 'react'
import type { TOCEntry } from '@/types'
import { cn } from '@/lib/utils'

interface TOCNavigationProps {
  tableOfContents: TOCEntry[]
  onNavigate: (sectionId: string) => void
  className?: string
}

export function TOCNavigation({ tableOfContents, onNavigate, className }: TOCNavigationProps) {
  const [expandedItems, setExpandedItems] = useState<Set<string>>(new Set())
  const [isMobileOpen, setIsMobileOpen] = useState(false)

  const toggleExpanded = (id: string) => {
    const newExpanded = new Set(expandedItems)
    if (newExpanded.has(id)) {
      newExpanded.delete(id)
    } else {
      newExpanded.add(id)
    }
    setExpandedItems(newExpanded)
  }

  const handleNavigate = (sectionId: string) => {
    onNavigate(sectionId)
    // Close mobile menu after navigation
    setIsMobileOpen(false)
  }

  const renderTOCItem = (entry: TOCEntry, depth = 0) => {
    const hasChildren = entry.children && entry.children.length > 0
    const isExpanded = expandedItems.has(entry.id)

    return (
      <li key={entry.id} className="w-full">
        <div
          className={cn('flex items-center w-full', depth > 0 && `pl-${Math.min(depth * 4, 12)}`)}
        >
          {hasChildren && (
            <button
              onClick={() => toggleExpanded(entry.id)}
              className="p-1 mr-1 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
              aria-label={isExpanded ? 'Collapse' : 'Expand'}
            >
              <svg
                className={cn('w-3 h-3 transition-transform', isExpanded && 'rotate-90')}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </button>
          )}

          <button
            onClick={() => handleNavigate(entry.sectionId)}
            className={cn(
              'flex-1 text-left py-2 px-3 rounded-md transition-colors',
              'hover:bg-gray-100 dark:hover:bg-gray-800',
              'text-sm text-gray-700 dark:text-gray-300',
              entry.level === 1 && 'font-semibold',
              entry.level === 2 && 'font-medium',
              !hasChildren && depth === 0 && 'ml-6'
            )}
          >
            <span className="line-clamp-2">{entry.title}</span>
            {entry.pageNumber && (
              <span className="text-xs text-gray-500 dark:text-gray-400 ml-2">
                p. {entry.pageNumber}
              </span>
            )}
          </button>
        </div>

        {hasChildren && isExpanded && (
          <ul className="mt-1">
            {entry.children!.map((child) => renderTOCItem(child, depth + 1))}
          </ul>
        )}
      </li>
    )
  }

  return (
    <>
      {/* Mobile Toggle Button */}
      <button
        onClick={() => setIsMobileOpen(!isMobileOpen)}
        className="lg:hidden fixed bottom-4 right-4 z-50 p-3 bg-blue-600 text-white rounded-full shadow-lg hover:bg-blue-700"
        aria-label="Toggle Table of Contents"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M4 6h16M4 12h16M4 18h16"
          />
        </svg>
      </button>

      {/* Desktop Sidebar */}
      <nav
        className={cn(
          'hidden lg:block w-80 sticky top-4 max-h-[calc(100vh-8rem)]',
          'bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700',
          'overflow-y-auto',
          className
        )}
      >
        <div className="p-4">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">
            Table of Contents
          </h2>

          {tableOfContents.length > 0 ? (
            <ul className="space-y-1">{tableOfContents.map((entry) => renderTOCItem(entry))}</ul>
          ) : (
            <p className="text-sm text-gray-500 dark:text-gray-400">
              No table of contents available
            </p>
          )}
        </div>
      </nav>

      {/* Mobile Drawer */}
      <div
        className={cn(
          'lg:hidden fixed inset-0 z-40 transition-opacity',
          isMobileOpen ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'
        )}
      >
        {/* Backdrop */}
        <div
          onClick={() => setIsMobileOpen(false)}
          className="absolute inset-0 bg-black bg-opacity-50"
        />

        {/* Drawer */}
        <nav
          className={cn(
            'absolute right-0 top-0 h-full w-80 max-w-[80vw]',
            'bg-white dark:bg-gray-900 shadow-xl',
            'transform transition-transform',
            isMobileOpen ? 'translate-x-0' : 'translate-x-full'
          )}
        >
          <div className="p-4 h-full overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                Table of Contents
              </h2>
              <button
                onClick={() => setIsMobileOpen(false)}
                className="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                aria-label="Close"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>

            {tableOfContents.length > 0 ? (
              <ul className="space-y-1">{tableOfContents.map((entry) => renderTOCItem(entry))}</ul>
            ) : (
              <p className="text-sm text-gray-500 dark:text-gray-400">
                No table of contents available
              </p>
            )}
          </div>
        </nav>
      </div>
    </>
  )
}
