import { create } from 'zustand'
import type { TTSSettings } from '@/types'

interface TTSState {
  isPlaying: boolean
  isPaused: boolean
  currentPosition: number
  settings: TTSSettings
  availableVoices: SpeechSynthesisVoice[]

  setPlaying: (playing: boolean) => void
  setPaused: (paused: boolean) => void
  setPosition: (position: number) => void
  updateSettings: (settings: Partial<TTSSettings>) => void
  setAvailableVoices: (voices: SpeechSynthesisVoice[]) => void
}

export const useTTSStore = create<TTSState>((set) => ({
  isPlaying: false,
  isPaused: false,
  currentPosition: 0,
  settings: {
    voice: '',
    rate: 1,
    pitch: 1,
    volume: 1,
  },
  availableVoices: [],

  setPlaying: (playing) => set({ isPlaying: playing }),
  setPaused: (paused) => set({ isPaused: paused }),
  setPosition: (position) => set({ currentPosition: position }),
  updateSettings: (newSettings) =>
    set((state) => ({
      settings: { ...state.settings, ...newSettings },
    })),
  setAvailableVoices: (voices) => set({ availableVoices: voices }),
}))
