import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { UserPreferences } from '@/types'

interface PreferencesState {
  preferences: UserPreferences
  updatePreferences: (prefs: Partial<UserPreferences>) => void
  resetPreferences: () => void
}

const defaultPreferences: UserPreferences = {
  theme: 'system',
  fontSize: 16,
  fontFamily: 'system-ui',
  readingWidth: 'medium',
  ttsSettings: {
    voice: '',
    rate: 1,
    pitch: 1,
    volume: 1,
  },
}

export const usePreferencesStore = create<PreferencesState>()(
  persist(
    (set) => ({
      preferences: defaultPreferences,

      updatePreferences: (prefs) =>
        set((state) => ({
          preferences: { ...state.preferences, ...prefs },
        })),

      resetPreferences: () => set({ preferences: defaultPreferences }),
    }),
    {
      name: 'maxspeak-preferences',
    }
  )
)
