import { useTTSStore } from '@/store'

export class TTSService {
  private static instance: TTSService
  private synthesis: SpeechSynthesis
  private textChunks: string[] = []
  private currentChunkIndex: number = 0
  private isPlaying: boolean = false
  private currentUtterance: SpeechSynthesisUtterance | null = null

  constructor() {
    this.synthesis = window.speechSynthesis
  }

  static getInstance(): TTSService {
    if (!TTSService.instance) {
      TTSService.instance = new TTSService()
    }
    return TTSService.instance
  }

  getAvailableVoices(): SpeechSynthesisVoice[] {
    return this.synthesis.getVoices()
  }

  private splitTextIntoChunks(text: string): string[] {
    // Split by paragraphs first for better natural breaks
    const paragraphs = text.split('\n\n').filter((p) => p.trim().length > 0)
    const chunks: string[] = []

    for (const paragraph of paragraphs) {
      const trimmed = paragraph.trim()
      if (trimmed.length === 0) continue

      // If paragraph is short enough, use it as a chunk
      if (trimmed.length <= 300) {
        chunks.push(trimmed)
        continue
      }

      // Split long paragraphs by sentences
      const sentences = trimmed.match(/[^.!?]+[.!?]+/g) || [trimmed]
      let currentChunk = ''

      for (const sentence of sentences) {
        const sentenceTrimmed = sentence.trim()
        if (sentenceTrimmed.length === 0) continue

        if (currentChunk.length + sentenceTrimmed.length > 300 && currentChunk.length > 0) {
          chunks.push(currentChunk.trim())
          currentChunk = sentenceTrimmed
        } else {
          currentChunk += (currentChunk.length > 0 ? ' ' : '') + sentenceTrimmed
        }
      }

      if (currentChunk.trim().length > 0) {
        chunks.push(currentChunk.trim())
      }
    }

    return chunks.length > 0 ? chunks : [text]
  }

  async speak(
    text: string,
    options?: {
      voice?: string
      rate?: number
      pitch?: number
      volume?: number
    }
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!text.trim()) {
        reject(new Error('No text to speak'))
        return
      }

      // Stop any current speech
      this.stop()

      // Get first paragraph immediately for instant startup
      const firstParagraph = text.split('\n\n')[0]?.trim()
      if (!firstParagraph) {
        reject(new Error('No content to speak'))
        return
      }

      // Start with first paragraph immediately
      this.isPlaying = true
      useTTSStore.getState().setPlaying(true)

      // Create first utterance
      this.currentUtterance = new SpeechSynthesisUtterance(firstParagraph)

      // Apply options
      if (options?.voice) {
        const voice = this.getAvailableVoices().find((v) => v.name === options.voice)
        if (voice) this.currentUtterance.voice = voice
      }
      if (options?.rate) this.currentUtterance.rate = options.rate
      if (options?.pitch) this.currentUtterance.pitch = options.pitch
      if (options?.volume) this.currentUtterance.volume = options.volume

      // Split remaining text into chunks while first paragraph is speaking
      setTimeout(() => {
        this.textChunks = this.splitTextIntoChunks(text)
        this.currentChunkIndex = 0
      }, 0)

      const speakNextChunk = () => {
        this.currentChunkIndex++

        if (this.currentChunkIndex >= this.textChunks.length || !this.isPlaying) {
          // Finished all chunks
          this.isPlaying = false
          useTTSStore.getState().setPlaying(false)
          resolve()
          return
        }

        const chunk = this.textChunks[this.currentChunkIndex]
        this.currentUtterance = new SpeechSynthesisUtterance(chunk)

        // Apply options
        if (options?.voice) {
          const voice = this.getAvailableVoices().find((v) => v.name === options.voice)
          if (voice) this.currentUtterance.voice = voice
        }
        if (options?.rate) this.currentUtterance.rate = options.rate
        if (options?.pitch) this.currentUtterance.pitch = options.pitch
        if (options?.volume) this.currentUtterance.volume = options.volume

        // Set up event listeners
        this.currentUtterance.onend = () => {
          speakNextChunk() // Continue with next chunk
        }

        this.currentUtterance.onerror = (event) => {
          this.isPlaying = false
          useTTSStore.getState().setPlaying(false)
          reject(new Error(`Speech synthesis error: ${event.error}`))
        }

        this.currentUtterance.onpause = () => {
          useTTSStore.getState().setPaused(true)
        }

        this.currentUtterance.onresume = () => {
          useTTSStore.getState().setPaused(false)
        }

        // Start speaking this chunk
        this.synthesis.speak(this.currentUtterance)
      }

      // Set up first paragraph event handlers
      this.currentUtterance.onend = () => {
        if (this.textChunks.length > 0) {
          speakNextChunk() // Continue with remaining chunks
        } else {
          // Only had one paragraph
          this.isPlaying = false
          useTTSStore.getState().setPlaying(false)
          resolve()
        }
      }

      this.currentUtterance.onerror = (event) => {
        this.isPlaying = false
        useTTSStore.getState().setPlaying(false)
        reject(new Error(`Speech synthesis error: ${event.error}`))
      }

      this.currentUtterance.onpause = () => {
        useTTSStore.getState().setPaused(true)
      }

      this.currentUtterance.onresume = () => {
        useTTSStore.getState().setPaused(false)
      }

      // Start speaking the first paragraph immediately
      this.synthesis.speak(this.currentUtterance)
    })
  }

  pause(): void {
    if (this.synthesis.speaking && !this.synthesis.paused) {
      this.synthesis.pause()
    }
  }

  resume(): void {
    if (this.synthesis.paused) {
      this.synthesis.resume()
    }
  }

  stop(): void {
    if (this.synthesis.speaking) {
      this.synthesis.cancel()
    }
    this.isPlaying = false
    this.currentUtterance = null
    this.textChunks = []
    this.currentChunkIndex = 0
    useTTSStore.getState().setPlaying(false)
    useTTSStore.getState().setPaused(false)
  }

  isSupported(): boolean {
    return 'speechSynthesis' in window
  }
}
