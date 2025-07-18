import type { Document, DocumentSection, TOCEntry } from '@/types'

export class DocumentProcessor {
  static async processFile(file: File): Promise<Document> {
    const fileType = file.name.split('.').pop()?.toLowerCase() as 'pdf' | 'txt' | 'md' | 'epub'

    let content = ''
    let sections: DocumentSection[] = []
    let tableOfContents: TOCEntry[] = []

    const metadata = {
      createdAt: new Date(),
      modifiedAt: new Date(),
      pages: 1,
    }

    try {
      switch (fileType) {
        case 'txt':
        case 'md':
          content = await this.processTextFile(file)
          sections = this.extractSectionsFromText(content)
          tableOfContents = this.generateTOCFromSections(sections)
          break
        case 'pdf': {
          const pdfResult = await this.processPDFFile(file)
          content = pdfResult.content
          sections = pdfResult.sections
          tableOfContents = pdfResult.tableOfContents
          metadata.pages = pdfResult.pages || 1
          break
        }
        case 'epub':
          content = await this.processEPUBFile(file)
          sections = this.extractSectionsFromText(content)
          tableOfContents = this.generateTOCFromSections(sections)
          break
        default:
          throw new Error(`Unsupported file type: ${fileType}`)
      }

      // Calculate estimated pages if not set (assuming ~300 words per page)
      if (!metadata.pages || metadata.pages === 1) {
        const wordCount = content.split(/\s+/).filter((word) => word.length > 0).length
        metadata.pages = Math.max(1, Math.ceil(wordCount / 300))
      }

      return {
        id: crypto.randomUUID(),
        title: file.name.replace(/\.[^/.]+$/, ''),
        content,
        type: fileType,
        metadata,
        sections,
        tableOfContents,
      }
    } catch (error) {
      console.error('Error processing file:', error)
      throw new Error(`Failed to process file: ${file.name}`)
    }
  }

  private static async processTextFile(file: File): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = (e) => {
        const content = e.target?.result as string
        resolve(content)
      }
      reader.onerror = () => reject(new Error('Failed to read text file'))
      reader.readAsText(file)
    })
  }

  private static async processPDFFile(file: File): Promise<{
    content: string
    sections: DocumentSection[]
    tableOfContents: TOCEntry[]
    pages?: number
  }> {
    try {
      const pdfjsLib = await import('pdfjs-dist')

      // Use local worker file to avoid CDN issues
      pdfjsLib.GlobalWorkerOptions.workerSrc = '/pdf.worker.min.js'

      return new Promise((resolve, reject) => {
        const reader = new FileReader()

        reader.onload = async (e) => {
          try {
            const arrayBuffer = e.target?.result as ArrayBuffer

            // Try loading PDF with different configurations
            let pdf
            const configs = [
              {
                data: arrayBuffer,
                useWorkerFetch: false,
                isEvalSupported: false,
                useSystemFonts: true,
                disableAutoFetch: true,
                disableStream: true,
              },
              {
                data: arrayBuffer,
                verbosity: 0,
              },
              {
                data: arrayBuffer,
              },
            ]

            for (const config of configs) {
              try {
                const loadingTask = pdfjsLib.getDocument(config)
                pdf = await loadingTask.promise
                break
              } catch (loadError) {
                console.warn('PDF loading config failed:', loadError)
                continue
              }
            }

            if (!pdf) {
              throw new Error('Could not load PDF with any configuration')
            }

            let fullText = ''
            const potentialTOCItems: Array<{
              title: string
              pageNum: number
              fontSize: number
              y: number
            }> = []

            // Extract text from each page with reconstructed structure
            // Limit processing to prevent browser freeze
            const maxPages = Math.min(pdf.numPages, 100) // Limit to 100 pages for performance
            
            for (let pageNum = 1; pageNum <= maxPages; pageNum++) {
              try {
                // Yield control every 5 pages to prevent blocking
                if (pageNum % 5 === 0) {
                  await new Promise(resolve => setTimeout(resolve, 10))
                }
                
                const page = await pdf.getPage(pageNum)
                const textContent = await page.getTextContent()

                // Group text items by lines based on Y position
                const lines: Array<{ y: number; items: any[]; fontSize?: number }> = []

                for (const item of textContent.items) {
                  const y = Math.round((item as any).transform[5])
                  const fontSize = (item as any).height || 12
                  let lineGroup = lines.find((line) => Math.abs(line.y - y) < 3)

                  if (!lineGroup) {
                    lineGroup = { y, items: [], fontSize }
                    lines.push(lineGroup)
                  }

                  lineGroup.items.push(item)
                  // Track the largest font size in the line
                  if (fontSize > (lineGroup.fontSize || 0)) {
                    lineGroup.fontSize = fontSize
                  }
                }

                // Sort lines by Y position (top to bottom)
                lines.sort((a, b) => b.y - a.y)

                let pageText = ''
                let lastLineY = -1
                const avgFontSize =
                  lines.reduce((sum, l) => sum + (l.fontSize || 12), 0) / lines.length

                for (const line of lines) {
                  // Sort items in line by X position (left to right)
                  line.items.sort((a: any, b: any) => a.transform[4] - b.transform[4])

                  // Build line text
                  let lineText = ''
                  for (const item of line.items) {
                    const text = (item as any).str
                    if (text) {
                      lineText += text
                      // Add space if text doesn't end with whitespace or punctuation
                      if (!text.match(/[\s\-.,;:!?]$/)) {
                        lineText += ' '
                      }
                    }
                  }

                  lineText = lineText.trim()
                  if (lineText) {
                    // Check for paragraph breaks (larger Y gap)
                    if (lastLineY !== -1 && lastLineY - line.y > 15) {
                      pageText += '\n\n'
                    } else if (pageText && !pageText.endsWith('\n')) {
                      pageText += '\n'
                    }

                    // Detect potential headings based on font size
                    if (line.fontSize && line.fontSize > avgFontSize * 1.2) {
                      potentialTOCItems.push({
                        title: lineText,
                        pageNum: pageNum,
                        fontSize: line.fontSize,
                        y: line.y,
                      })
                    }

                    pageText += lineText
                    lastLineY = line.y
                  }
                }

                if (pageText.trim()) {
                  fullText += pageText.trim() + '\n\n'
                  
                  // Prevent excessive memory usage - limit content size
                  if (fullText.length > 500000) { // 500KB limit
                    console.warn(`Document too large, truncating at page ${pageNum}`)
                    fullText += '\n\n[Document truncated for performance...]'
                    break
                  }
                }
              } catch (pageError) {
                console.warn(`Failed to process page ${pageNum}:`, pageError)
              }
            }

            // Process detected headings into sections
            const processedSections = this.processPDFSections(fullText, potentialTOCItems)
            const toc = this.generateTOCFromSections(processedSections)

            resolve({
              content: fullText.trim() || 'No text content found in PDF',
              sections: processedSections,
              tableOfContents: toc,
              pages: pdf.numPages,
            })
          } catch (error) {
            console.error('Error processing PDF:', error)
            reject(new Error(`Failed to extract text from PDF: ${error}`))
          }
        }

        reader.onerror = () => reject(new Error('Failed to read PDF file'))
        reader.readAsArrayBuffer(file)
      })
    } catch (error) {
      console.error('Error importing PDF.js:', error)
      // Fallback: return basic info about the PDF
      const fallbackContent = `PDF file uploaded: ${file.name}\n\nPDF text extraction is temporarily unavailable. This is a PDF file with ${Math.ceil(file.size / 1024)}KB of content.\n\nPlease try uploading a text file (.txt) or markdown file (.md) for full text-to-speech functionality.`
      return {
        content: fallbackContent,
        sections: [],
        tableOfContents: [],
        pages: 1,
      }
    }
  }

  private static async processEPUBFile(file: File): Promise<string> {
    const ePub = await import('epubjs')

    return new Promise((resolve, reject) => {
      const reader = new FileReader()

      reader.onload = async (e) => {
        try {
          const arrayBuffer = e.target?.result as ArrayBuffer
          const book = ePub.default(arrayBuffer)

          await book.ready

          let fullText = ''

          // Get all spine items
          const spine = book.spine as any
          const spineItems = spine.spineItems || []

          // Extract text from each chapter
          for (const item of spineItems) {
            try {
              const doc = await book.load(item.href)
              const text = (doc as any).body?.textContent || (doc as any).textContent || ''
              if (text.trim()) {
                fullText += text.trim() + '\n\n'
              }
            } catch (chapterError) {
              console.warn(`Failed to load chapter ${item.href}:`, chapterError)
            }
          }

          resolve(fullText.trim() || 'No text content found in EPUB')
        } catch (error) {
          console.error('Error processing EPUB:', error)
          reject(new Error(`Failed to extract text from EPUB: ${error}`))
        }
      }

      reader.onerror = () => reject(new Error('Failed to read EPUB file'))
      reader.readAsArrayBuffer(file)
    })
  }

  private static processPDFSections(
    content: string,
    potentialHeadings: Array<{ title: string; pageNum: number; fontSize: number; y: number }>
  ): DocumentSection[] {
    const sections: DocumentSection[] = []

    // Sort headings by font size to determine hierarchy
    const sortedHeadings = potentialHeadings.sort((a, b) => b.fontSize - a.fontSize)
    const fontSizes = [...new Set(sortedHeadings.map((h) => h.fontSize))].sort((a, b) => b - a)

    // Map font sizes to heading levels (1-6)
    const fontSizeToLevel = new Map<number, number>()
    fontSizes.forEach((size, index) => {
      fontSizeToLevel.set(size, Math.min(index + 1, 6))
    })

    // Create sections from headings
    sortedHeadings.forEach((heading, index) => {
      const level = fontSizeToLevel.get(heading.fontSize) || 3
      const startOffset = content.indexOf(heading.title)

      if (startOffset !== -1) {
        // Find the end offset (start of next section or end of content)
        let endOffset = content.length
        for (let i = index + 1; i < sortedHeadings.length; i++) {
          const nextOffset = content.indexOf(
            sortedHeadings[i].title,
            startOffset + heading.title.length
          )
          if (nextOffset !== -1) {
            endOffset = nextOffset
            break
          }
        }

        sections.push({
          id: crypto.randomUUID(),
          title: heading.title,
          content: content.substring(startOffset, endOffset).trim(),
          level,
          pageNumber: heading.pageNum,
          startOffset,
          endOffset,
        })
      }
    })

    // Sort sections by their position in the document
    return sections.sort((a, b) => a.startOffset - b.startOffset)
  }

  private static extractSectionsFromText(content: string): DocumentSection[] {
    const sections: DocumentSection[] = []
    const lines = content.split('\n')
    let currentOffset = 0

    // Simple heuristic: lines that are short and followed by blank lines might be headings
    lines.forEach((line, index) => {
      const trimmedLine = line.trim()
      if (trimmedLine && trimmedLine.length < 80) {
        const nextLine = lines[index + 1]
        const prevLine = lines[index - 1]

        // Check if this looks like a heading
        if ((!nextLine || !nextLine.trim()) && (!prevLine || !prevLine.trim())) {
          const startOffset = currentOffset
          let endOffset = content.length

          // Find where this section ends
          for (let i = index + 2; i < lines.length; i++) {
            if (
              lines[i].trim() &&
              lines[i].trim().length < 80 &&
              (!lines[i + 1] || !lines[i + 1].trim())
            ) {
              endOffset = content.indexOf(lines[i], startOffset + trimmedLine.length)
              break
            }
          }

          sections.push({
            id: crypto.randomUUID(),
            title: trimmedLine,
            content: content.substring(startOffset, endOffset).trim(),
            level: 2, // Default level for text files
            startOffset,
            endOffset,
          })
        }
      }
      currentOffset += line.length + 1 // +1 for newline
    })

    return sections
  }

  private static generateTOCFromSections(sections: DocumentSection[]): TOCEntry[] {
    const toc: TOCEntry[] = []
    const stack: { entry: TOCEntry; level: number }[] = []

    sections.forEach((section) => {
      const entry: TOCEntry = {
        id: crypto.randomUUID(),
        title: section.title,
        level: section.level,
        sectionId: section.id,
        pageNumber: section.pageNumber,
        children: [],
      }

      // Find the appropriate parent
      while (stack.length > 0 && stack[stack.length - 1].level >= section.level) {
        stack.pop()
      }

      if (stack.length === 0) {
        toc.push(entry)
      } else {
        const parent = stack[stack.length - 1].entry
        if (!parent.children) parent.children = []
        parent.children.push(entry)
      }

      stack.push({ entry, level: section.level })
    })

    return toc
  }
}
