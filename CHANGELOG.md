# Changelog

## [1.0.0] - 2025-07-18

### 🎉 Initial Release

#### Features
- **Multi-format Document Support**
  - PDF files with advanced text extraction (PDF.js)
  - EPUB files with full e-book support (EPUB.js)
  - Text files (.txt, .md) with immediate processing
  - Drag & drop file import with validation (up to 50MB)

- **Advanced Text-to-Speech**
  - Web Speech API integration
  - Instant startup (< 1 second) with chunked processing
  - Natural paragraph-based speech pacing
  - Play/pause/stop controls

- **Data Persistence**
  - IndexedDB storage for documents
  - Session persistence with Zustand
  - Document library management
  - Reading progress tracking (planned)

- **User Experience**
  - Responsive design for desktop and mobile
  - Clean, minimal interface
  - Real-time playback controls
  - Format preservation in document display

#### Technical Implementation
- **Frontend**: React 19.1.0 + TypeScript 5.8.3
- **Build**: Vite 7.0.4 with optimized production builds
- **Styling**: Tailwind CSS v4 with custom design system
- **State**: Zustand with persistence middleware
- **Storage**: IndexedDB for client-side document storage

#### Performance Optimizations
- Chunked TTS processing for immediate playback
- Async document processing pipeline
- PDF structure reconstruction from coordinates
- Efficient IndexedDB operations

#### Development Features
- TypeScript with strict type checking
- ESLint + Prettier for code quality
- Hot module replacement for development
- Production-ready build configuration

### 🔧 Technical Details

#### PDF Processing
- Advanced text extraction using PDF.js
- Coordinate-based structure reconstruction
- Line grouping and paragraph detection
- Proper spacing and formatting preservation

#### TTS Performance
- First paragraph plays immediately
- Remaining content processed asynchronously
- Sentence-based chunking for natural flow
- Seamless continuation between chunks

#### Storage Architecture
- IndexedDB for document persistence
- Zustand for application state
- Automatic save/load functionality
- Error handling and recovery

### 📁 Project Structure
```
src/
├── components/features/    # React components
├── services/              # Business logic
├── store/                 # State management
├── types/                 # TypeScript definitions
├── hooks/                 # Custom hooks
├── utils/                 # Helper functions
└── styles/                # Global styles
```

### 🚀 Getting Started
1. Clone the repository
2. Run `npm install`
3. Run `npm run dev`
4. Open http://localhost:5173

### 🎯 Next Steps
See README.md for planned future enhancements including voice selection, playback speed controls, and text highlighting.