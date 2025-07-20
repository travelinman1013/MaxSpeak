# MaxSpeak 🎧📖

**Affordable text-to-speech reader app built with Flutter**

MaxSpeak is a cross-platform mobile text-to-speech (TTS) reader designed to compete with premium apps like Speechify and Natural Reader at ~85% lower cost. Built with Flutter for iOS/Android compatibility, it features local PDF management, clean reading interface, and tap-to-read functionality with future AI assistant capabilities.

## 🎯 Core Value Proposition

- **Affordable**: Significantly cheaper than $139/year competitors
- **Self-contained**: Works offline with local storage
- **Cross-platform**: Single codebase for phones and tablets
- **AI-ready**: Architecture designed for future enhancements

## ✨ Features (MVP)

- 📱 **Local PDF Management** - Import and store documents securely
- 👀 **Clean PDF Viewer** - Smooth scrolling, zoom, dark mode
- 🎤 **Tap-to-Read TTS** - Start playback from any text selection
- ⏯️ **Playback Controls** - Play/pause, speed control (0.5x-3x), skip
- 🌙 **Reading Optimized** - High contrast themes for extended reading
- 🔒 **Security First** - AES-256 encryption for stored documents

## 🚀 Technology Stack

| Component | Technology | Why |
|-----------|------------|-----|
| **Framework** | Flutter 3.x | Single codebase, 60+ FPS, mature ecosystem |
| **Language** | Dart | Flutter native, strong typing, async support |
| **Architecture** | Clean Architecture | Scalable, testable, maintainable |
| **State Management** | Riverpod | Better performance and testing support |
| **TTS Engine** | Coqui TTS + Native | Open-source primary, platform fallback |
| **PDF Rendering** | PDF.js (Flutter plugin) | Proven performance, Apache 2.0 license |
| **Local Storage** | Hive | Lightweight, offline-first, encrypted |
| **Security** | AES-256 + Keystore | Industry-standard encryption |

## 🏗️ Development Status

**Current Phase**: Phase 1 - MVP Core (Month 1-3)  
**Active Milestone**: 1.2 - Local Storage & Security  
**Progress**: 25% of Phase 1 complete

### ✅ Completed (Milestone 1.1)
- Flutter project with Clean Architecture structure
- SuperDesign theme system with reading optimization
- Responsive library UI with document grid
- Navigation system with go_router
- Document entity and data layer foundations
- Error handling strategy

### 🔄 In Progress (Milestone 1.2)
- Hive database setup and initialization
- Document import and storage implementation
- AES-256 encryption service
- PDF page count detection

### 📋 Upcoming
- PDF viewer integration (pdfx)
- TTS engine setup (Coqui + native fallback)
- Reader interface with word highlighting
- Playback controls and audio management

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- iOS development: Xcode
- Android development: Android Studio

### Installation
```bash
# Clone the repository
git clone https://github.com/travelinman1013/MaxSpeak.git
cd MaxSpeak

# Install dependencies
flutter pub get

# Generate code (after adding models)
flutter packages pub run build_runner build

# Run the app
flutter run
```

## 📁 Project Structure

```
lib/
├── core/                 # Core utilities and constants
│   ├── constants/        # App-wide constants
│   ├── errors/          # Error handling
│   ├── usecases/        # Base use case classes
│   └── utils/           # Service locator, helpers
├── features/            # Feature-based modules
│   ├── library/         # Document library management
│   ├── reader/          # PDF reading and TTS
│   ├── settings/        # App configuration
│   └── tts/             # Text-to-speech engine
└── shared/              # Shared UI components and utilities
    ├── utils/           # App theme, routing
    └── widgets/         # Reusable widgets
```

## 🎨 Design System

MaxSpeak uses a custom design system optimized for reading:
- **Colors**: Orange/green palette avoiding generic blues
- **Typography**: Inter for UI, Merriweather for reading
- **Accessibility**: WCAG 2.1 AA compliance, large touch targets
- **Performance**: 60 FPS animations, smooth transitions

Design mockups and iterations are stored in `.superdesign/design_iterations/`

## 📊 Roadmap

| Phase | Timeline | Goals |
|-------|----------|-------|
| **Phase 1 - MVP Core** | Months 1-3 | PDF viewer, local storage, TTS, basic controls |
| **Phase 2 - Enhanced UX** | Months 4-5 | Polish UI, cloud sync, advanced features |
| **Phase 3 - AI Assistant** | Months 6-9 | Summaries, Q&A, premium features |
| **Phase 4 - Growth** | Months 10-12 | Internationalization, marketing |

## 🤝 Contributing

This is currently a private development project. For questions or collaboration:

- **Developer**: @travelinman1013
- **Architecture**: Clean Architecture with feature-based structure
- **Workflow**: Feature branches, conventional commits
- **Documentation**: See `tasks.md` and `implementation_plan.md`

## 📝 License

TBD - Will be determined based on business model decisions.

---

**MaxSpeak** - Making quality text-to-speech accessible to everyone 🎯