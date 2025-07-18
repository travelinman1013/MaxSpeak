import { useState, useEffect } from 'react'
import { useTTSStore, useDocumentStore } from '@/store'
import { TTSService } from '@/services/ttsService'
import { cn } from '@/lib/utils'

interface PlaybackControlsProps {
  className?: string
}

export function PlaybackControls({ className }: PlaybackControlsProps) {
  const { isPlaying, isPaused, settings } = useTTSStore()
  const { currentDocument } = useDocumentStore()
  const [ttsService] = useState(() => TTSService.getInstance())

  useEffect(() => {
    // Load available voices when component mounts
    const loadVoices = () => {
      const voices = ttsService.getAvailableVoices()
      useTTSStore.getState().setAvailableVoices(voices)
    }

    loadVoices()

    // Some browsers load voices asynchronously
    if (speechSynthesis.onvoiceschanged !== undefined) {
      speechSynthesis.onvoiceschanged = loadVoices
    }
  }, [ttsService])

  const handlePlay = async () => {
    if (!currentDocument?.content) {
      alert('No document selected or content available')
      return
    }

    if (isPaused) {
      ttsService.resume()
    } else {
      try {
        await ttsService.speak(currentDocument.content, {
          voice: settings.voice,
          rate: settings.rate,
          pitch: settings.pitch,
          volume: settings.volume,
        })
      } catch (error) {
        console.error('TTS Error:', error)
        alert('Error playing text-to-speech. Please try again.')
      }
    }
  }

  const handlePause = () => {
    ttsService.pause()
  }

  const handleStop = () => {
    ttsService.stop()
  }

  if (!ttsService.isSupported()) {
    return (
      <div className={cn('text-center p-4 bg-red-50 border border-red-200 rounded-lg', className)}>
        <p className="text-red-600">Text-to-speech is not supported in this browser.</p>
      </div>
    )
  }

  return (
    <div
      className={cn(
        'flex items-center justify-center space-x-4 p-4 bg-gray-50 border rounded-lg',
        className
      )}
    >
      <button
        onClick={handlePlay}
        disabled={!currentDocument?.content || (isPlaying && !isPaused)}
        className={cn(
          'px-6 py-2 rounded-lg font-medium transition-colors',
          isPlaying && !isPaused
            ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
            : 'bg-blue-500 hover:bg-blue-600 text-white'
        )}
      >
        {isPaused ? '▶️ Resume' : '▶️ Play'}
      </button>

      <button
        onClick={handlePause}
        disabled={!isPlaying || isPaused}
        className={cn(
          'px-6 py-2 rounded-lg font-medium transition-colors',
          !isPlaying || isPaused
            ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
            : 'bg-yellow-500 hover:bg-yellow-600 text-white'
        )}
      >
        ⏸️ Pause
      </button>

      <button
        onClick={handleStop}
        disabled={!isPlaying && !isPaused}
        className={cn(
          'px-6 py-2 rounded-lg font-medium transition-colors',
          !isPlaying && !isPaused
            ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
            : 'bg-red-500 hover:bg-red-600 text-white'
        )}
      >
        ⏹️ Stop
      </button>

      <div className="text-sm text-gray-600">
        {isPlaying ? (isPaused ? 'Paused' : 'Playing') : 'Stopped'}
      </div>
    </div>
  )
}
