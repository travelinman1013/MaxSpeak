import React, { useState, useEffect, useCallback, useMemo } from 'react'
import { useTTSStore, useDocumentStore } from '@/store'
import { TTSService } from '@/services/ttsService'
import { cn } from '@/lib/utils'

interface PlaybackControlsProps {
  className?: string
}

export const PlaybackControls = React.memo(function PlaybackControls({ className }: PlaybackControlsProps) {
  const { isPlaying, isPaused, settings, availableVoices, updateSettings } = useTTSStore()
  const { currentDocument } = useDocumentStore()
  const [ttsService] = useState(() => TTSService.getInstance())
  const [currentTime, setCurrentTime] = useState(0)
  const [totalTime, setTotalTime] = useState(0)
  const [showVoiceSelector, setShowVoiceSelector] = useState(false)

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

  useEffect(() => {
    // Estimate total reading time based on content length and speech rate
    if (currentDocument?.content) {
      const wordsPerMinute = 150 * settings.rate // Adjust based on rate
      const wordCount = currentDocument.content.split(' ').length
      const estimatedMinutes = wordCount / wordsPerMinute
      setTotalTime(estimatedMinutes * 60) // Convert to seconds
    }
  }, [currentDocument?.content, settings.rate])

  useEffect(() => {
    // Update current time during playback (reduced frequency to improve performance)
    let interval: NodeJS.Timeout
    if (isPlaying && !isPaused) {
      interval = setInterval(() => {
        setCurrentTime((prev) => prev + 1)
      }, 2000) // Update every 2 seconds instead of 1 second for better performance
    }
    return () => clearInterval(interval)
  }, [isPlaying, isPaused])

  const handlePlay = useCallback(async () => {
    if (!currentDocument?.content) {
      return
    }

    if (isPaused) {
      ttsService.resume()
    } else {
      try {
        setCurrentTime(0)
        await ttsService.speak(currentDocument.content, {
          voice: settings.voice,
          rate: settings.rate,
          pitch: settings.pitch,
          volume: settings.volume,
        })
      } catch (error) {
        console.error('TTS Error:', error)
        // Only show error for non-cancellation errors
        if (
          error instanceof Error &&
          !error.message.includes('interrupted') &&
          !error.message.includes('canceled')
        ) {
          console.warn('Error playing text-to-speech')
        }
      }
    }
  }, [currentDocument?.content, isPaused, ttsService, settings])

  const handlePause = useCallback(() => {
    ttsService.pause()
  }, [ttsService])

  const handleStop = useCallback(() => {
    ttsService.stop()
    setCurrentTime(0)
  }, [ttsService])

  const skipForward = useCallback(() => {
    setCurrentTime((prev) => Math.min(prev + 10, totalTime))
  }, [totalTime])

  const skipBackward = useCallback(() => {
    setCurrentTime((prev) => Math.max(prev - 10, 0))
  }, [])

  const adjustSpeed = useCallback((newRate: number) => {
    updateSettings({ rate: newRate })
  }, [updateSettings])

  const formatTime = useCallback((seconds: number) => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = Math.floor(seconds % 60)

    if (hours > 0) {
      return `-${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    }
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }, [])

  const progressPercentage = useMemo(() => 
    totalTime > 0 ? (currentTime / totalTime) * 100 : 0,
    [currentTime, totalTime]
  )

  const getCurrentVoice = useMemo(() => {
    return availableVoices.find((v) => v.name === settings.voice) || availableVoices[0]
  }, [availableVoices, settings.voice])

  if (!ttsService.isSupported()) {
    return (
      <div className={cn('text-center p-4 bg-red-50 border border-red-200 rounded-lg', className)}>
        <p className="text-red-600">Text-to-speech is not supported in this browser.</p>
      </div>
    )
  }

  if (!currentDocument) {
    return null
  }

  return (
    <div className={cn('fixed bottom-0 left-0 right-0 z-50', className)}>
      {/* Progress Bar */}
      <div className="h-1 bg-gray-200 dark:bg-gray-700">
        <div
          className="h-full bg-blue-500 transition-all duration-300"
          style={{ width: `${progressPercentage}%` }}
        />
      </div>

      {/* Control Bar */}
      <div className="bg-gray-900/95 backdrop-blur-sm text-white px-4 sm:px-6 py-3">
        <div className="flex items-center justify-between max-w-screen-xl mx-auto">
          {/* Left Side - Document Info (hidden on small screens) */}
          <div className="hidden sm:flex items-center space-x-4 flex-1 min-w-0">
            <div className="text-sm">
              <div className="font-medium truncate max-w-64">{currentDocument.title}</div>
              <div className="text-gray-400 text-xs">{currentDocument.type.toUpperCase()}</div>
            </div>
          </div>

          {/* Center - Playback Controls */}
          <div className="flex items-center space-x-2 sm:space-x-4 flex-1 sm:flex-none justify-center">
            <button
              onClick={skipBackward}
              disabled={!isPlaying && !isPaused}
              className="p-2 hover:bg-gray-700 rounded-full transition-colors disabled:opacity-50 disabled:hover:bg-transparent"
              title="Skip backward 10s"
            >
              <svg className="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0019 16V8a1 1 0 00-1.6-.8l-5.334 4zM4.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0011 16V8a1 1 0 00-1.6-.8l-5.334 4z"
                />
              </svg>
            </button>

            <button
              onClick={isPlaying && !isPaused ? handlePause : handlePlay}
              disabled={!currentDocument?.content}
              className="flex items-center justify-center w-10 h-10 sm:w-12 sm:h-12 bg-blue-500 hover:bg-blue-600 rounded-full transition-colors disabled:opacity-50 disabled:hover:bg-blue-500"
            >
              {isPlaying && !isPaused ? (
                <svg className="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
                </svg>
              ) : (
                <svg className="w-5 h-5 sm:w-6 sm:h-6 ml-0.5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 6.82v10.36c0 .79.87 1.27 1.54.84l8.14-5.18c.62-.39.62-1.29 0-1.68L9.54 5.98C8.87 5.55 8 6.03 8 6.82z" />
                </svg>
              )}
            </button>

            <button
              onClick={skipForward}
              disabled={!isPlaying && !isPaused}
              className="p-2 hover:bg-gray-700 rounded-full transition-colors disabled:opacity-50 disabled:hover:bg-transparent"
              title="Skip forward 10s"
            >
              <svg className="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M11.933 12.8a1 1 0 000-1.6L6.6 7.2A1 1 0 005 8v8a1 1 0 001.6.8l5.333-4zM19.933 12.8a1 1 0 000-1.6l-5.333-4A1 1 0 0013 8v8a1 1 0 001.6.8l5.333-4z"
                />
              </svg>
            </button>
          </div>

          {/* Right Side - Voice & Speed Controls */}
          <div className="flex items-center space-x-2 sm:space-x-4 flex-1 justify-end">
            {/* Time Display */}
            <div className="text-xs sm:text-sm font-mono">{formatTime(currentTime)}</div>

            {/* Voice Selector (simplified on mobile) */}
            <div className="relative">
              <button
                onClick={() => setShowVoiceSelector(!showVoiceSelector)}
                className="flex items-center space-x-1 sm:space-x-2 px-2 sm:px-3 py-1 bg-gray-700 hover:bg-gray-600 rounded-lg transition-colors"
              >
                <div className="w-5 h-5 sm:w-6 sm:h-6 bg-gray-500 rounded-full flex items-center justify-center text-xs">
                  {getCurrentVoice?.name?.charAt(0) || '?'}
                </div>
                <svg className="w-3 h-3 sm:w-4 sm:h-4 hidden sm:block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>

              {showVoiceSelector && (
                <div className="absolute bottom-full right-0 mb-2 w-48 sm:w-64 bg-gray-800 rounded-lg shadow-lg border border-gray-600 max-h-48 overflow-y-auto">
                  {availableVoices.map((voice) => (
                    <button
                      key={voice.name}
                      onClick={() => {
                        updateSettings({ voice: voice.name })
                        setShowVoiceSelector(false)
                      }}
                      className={cn(
                        'w-full text-left px-3 sm:px-4 py-2 hover:bg-gray-700 transition-colors',
                        voice.name === settings.voice && 'bg-gray-600'
                      )}
                    >
                      <div className="text-xs sm:text-sm font-medium truncate">{voice.name}</div>
                      <div className="text-xs text-gray-400">{voice.lang}</div>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Speed Control */}
            <div className="flex items-center space-x-1">
              <button
                onClick={() => adjustSpeed(Math.max(0.5, settings.rate - 0.25))}
                className="w-5 h-5 sm:w-6 sm:h-6 flex items-center justify-center text-xs bg-gray-700 hover:bg-gray-600 rounded transition-colors"
              >
                −
              </button>
              <span className="text-xs sm:text-sm font-medium min-w-[2.5rem] sm:min-w-[3rem] text-center">{settings.rate}x</span>
              <button
                onClick={() => adjustSpeed(Math.min(2.0, settings.rate + 0.25))}
                className="w-5 h-5 sm:w-6 sm:h-6 flex items-center justify-center text-xs bg-gray-700 hover:bg-gray-600 rounded transition-colors"
              >
                +
              </button>
            </div>

            {/* Stop Button (hidden on very small screens) */}
            <button
              onClick={handleStop}
              disabled={!isPlaying && !isPaused}
              className="hidden xs:block p-2 hover:bg-gray-700 rounded-full transition-colors disabled:opacity-50 disabled:hover:bg-transparent"
              title="Stop"
            >
              <svg className="w-4 h-4 sm:w-5 sm:h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M6 6h12v12H6z" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
})
