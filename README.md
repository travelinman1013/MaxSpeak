# MaxSpeak - Text-to-Speech Document Reader

A modern web application for reading documents aloud using advanced text-to-speech technology. Built with React, TypeScript, and Vite.

## Features

### 📚 Document Support
- **PDF Files** - Advanced text extraction with PDF.js
- **EPUB Files** - Full EPUB.js integration for e-books
- **Text Files** - Plain text (.txt) and Markdown (.md) support
- **Drag & Drop** - Easy file import with validation (up to 50MB)

### 🎯 Text-to-Speech
- **Web Speech API** - High-quality browser-based TTS
- **Instant Startup** - Begins reading immediately (< 1 second)
- **Chunked Processing** - Optimized for large documents
- **Natural Pacing** - Paragraph-based speech chunks

### 💾 Data Persistence
- **IndexedDB Storage** - Documents persist between sessions
- **Reading Progress** - Track your position in documents
- **Document Library** - Organized collection management

### 🎨 User Experience
- **Responsive Design** - Works on desktop and mobile
- **Clean Interface** - Minimal, focused design
- **Real-time Controls** - Play, pause, stop functionality
- **Format Preservation** - Maintains document structure

## Quick Start

### Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Open http://localhost:5173
```

### Production Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

### Code Quality

```bash
# Run TypeScript checks
npm run typecheck

# Run ESLint
npm run lint

# Format code
npm run format
```

## Tech Stack

- **Frontend**: React 19.1.0 + TypeScript 5.8.3
- **Build Tool**: Vite 7.0.4
- **Styling**: Tailwind CSS v4
- **State Management**: Zustand with persistence
- **Document Processing**: PDF.js + EPUB.js
- **Storage**: IndexedDB for persistence
- **TTS**: Web Speech API

## Project Structure

```
src/
├── components/
│   └── features/           # Feature components
├── services/              # Business logic & APIs
├── store/                 # State management
├── types/                 # TypeScript definitions
├── hooks/                 # Custom React hooks
├── utils/                 # Helper functions
└── styles/                # Global styles
```

## Usage

1. **Import Documents**
   - Drag files into the import zone
   - Or click to browse and select files
   - Supported: PDF, EPUB, TXT, MD (up to 50MB)

2. **Read Documents**
   - Click on any document in your library
   - Use playback controls to start/pause/stop
   - Documents are automatically saved for later

3. **Text-to-Speech**
   - Click "Play" to begin reading
   - Speech starts immediately with first paragraph
   - Pause/resume anytime during playback

## Development Notes

### PDF Processing
- Uses PDF.js for text extraction
- Reconstructs document structure from coordinates
- Handles complex layouts (tables, columns, etc.)

### Performance Optimizations
- Chunked TTS processing for instant startup
- Async document processing
- IndexedDB for efficient storage

### Browser Compatibility
- Modern browsers with Web Speech API support
- Chrome, Firefox, Safari, Edge (latest versions)

## Future Enhancements

- [ ] Voice selection UI
- [ ] Playback speed controls
- [ ] Text highlighting during speech
- [ ] Reading progress tracking
- [ ] Keyboard shortcuts
- [ ] Dark/light theme toggle
- [ ] Mobile app packaging with Capacitor

## Contributing

This is a personal project, but feel free to fork and adapt for your needs.

## License

MIT License - see LICENSE file for details.