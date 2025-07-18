import type { Document } from '@/types'

export class DocumentProcessor {
  static async processFile(file: File): Promise<Document> {
    const fileType = file.name.split('.').pop()?.toLowerCase() as 'pdf' | 'txt' | 'md' | 'epub'

    let content = ''
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
          break
        case 'pdf':
          content = await this.processPDFFile(file)
          break
        case 'epub':
          content = await this.processEPUBFile(file)
          break
        default:
          throw new Error(`Unsupported file type: ${fileType}`)
      }

      // Calculate estimated pages (assuming ~300 words per page)
      const wordCount = content.split(/\s+/).filter((word) => word.length > 0).length
      metadata.pages = Math.max(1, Math.ceil(wordCount / 300))

      return {
        id: crypto.randomUUID(),
        title: file.name.replace(/\.[^/.]+$/, ''),
        content,
        type: fileType,
        metadata,
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

  private static async processPDFFile(file: File): Promise<string> {
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

            // Extract text from each page with reconstructed structure
            for (let pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
              try {
                const page = await pdf.getPage(pageNum)
                const textContent = await page.getTextContent()

                // Group text items by lines based on Y position
                const lines: Array<{ y: number; items: any[] }> = []

                for (const item of textContent.items) {
                  const y = Math.round((item as any).transform[5])
                  let lineGroup = lines.find((line) => Math.abs(line.y - y) < 3)

                  if (!lineGroup) {
                    lineGroup = { y, items: [] }
                    lines.push(lineGroup)
                  }

                  lineGroup.items.push(item)
                }

                // Sort lines by Y position (top to bottom)
                lines.sort((a, b) => b.y - a.y)

                let pageText = ''
                let lastLineY = -1

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

                    pageText += lineText
                    lastLineY = line.y
                  }
                }

                if (pageText.trim()) {
                  fullText += pageText.trim() + '\n\n'
                }
              } catch (pageError) {
                console.warn(`Failed to process page ${pageNum}:`, pageError)
              }
            }

            resolve(fullText.trim() || 'No text content found in PDF')
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
      return `PDF file uploaded: ${file.name}\n\nPDF text extraction is temporarily unavailable. This is a PDF file with ${Math.ceil(file.size / 1024)}KB of content.\n\nPlease try uploading a text file (.txt) or markdown file (.md) for full text-to-speech functionality.`
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
}
