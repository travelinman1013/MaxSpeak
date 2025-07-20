# Product Requirements Document (PRD)

## Project Overview
**Project Name:** MaxSpeak 
**Type:** Cross-Platform Mobile & Tablet Application  
**Purpose:** Deliver a fully-featured, affordable text-to-speech (TTS) reader that rivals premium apps (e.g., Speechify, Natural Reader) while remaining self-contained and optimized for future AI integrations.

---

## Target Users
| Segment | Needs / Pain Points |
|---------|--------------------|
| Students & Academics | Consume large reading loads hands-free; budget constraints |
| Professionals | Listen during commutes; multitask efficiently |
| Accessibility Users | Overcome dyslexia, visual impairments |
| Audiobook Enthusiasts | Cheaper alternative to costly audiobooks |
| Language Learners | Pronunciation practice; variable speeds |
| Seniors | Vision challenges; prefer audio |

---

## MVP Features (Essential)
1. **Local PDF Management**  
   • Import PDFs via file picker/cloud share  
   • Store documents locally (encrypted)  
2. **Clean PDF Viewer**  
   • Smooth page scrolling, zoom, dark mode  
3. **Tap-to-Read TTS**  
   • Start playback from any text selection  
   • Real-time word highlighting  
4. **Playback Controls**  
   • Rewind 10 s / Play-Pause / FF 10 s  
   • Adjustable speed 0.5× – 3×  
5. **Cross-Platform Support**  
   • Single codebase for iOS & Android (phone + tablet)  
6. **Scalable Architecture**  
   • Designed to plug in future AI assistant modules

---

## Future Enhancements
| Category | Feature |
|----------|---------|
| AI Assistant | Summaries, Q&A, quiz generation |
| Study Tools | Annotations, highlights, export notes |
| Voice Tech | Neural voices, voice cloning |
| Sharing | Reading lists, social progress |
| Analytics | Reading time, comprehension metrics |

---

## Technical Stack

| Layer | Primary Choice | Rationale |
|-------|---------------|-----------|
| **Mobile Framework** | **Flutter** | Single codebase, high FPS, strong ecosystem |
| **TTS Engine** | **Coqui TTS** (open-source) with fallback to native iOS/Android synthesizers | Zero per-character fees; good quality |
| **PDF Rendering** | **PDF.js** (via Flutter plugin) | Proven performance, Apache 2.0 license |
| **Local DB** | **Hive / SQLite** | Lightweight, offline-first |
| **Cloud Sync (opt-in)** | Firebase / App write | Low cost, easy auth |
| **Security** | AES-256 encrypted file storage; OS-level secure keystore |

---

## User Flow
1. **Launch App** → Welcome / sign-in (optional)  
2. **Onboarding** → 3-screen tutorial (skip available)  
3. **Import Document** → File picker → Library  
4. **Library View** → Tap document → Reader  
5. **Reader** → Tap text → TTS starts → Use controls  
6. **Exit** → Progress auto-saved → Library

---

## Development Roadmap

| Phase | Duration | Goals | Key Deliverables |
|-------|----------|-------|------------------|
| **Phase 1 – MVP Core** | Months 1-3 | Build foundation | PDF viewer, local storage, open-source TTS, basic controls, internal alpha |
| **Phase 2 – Enhanced UX** | Months 4-5 | Polish & stabilize | Word highlighting sync, dark mode, cloud backup beta |
| **Phase 3 – AI Assistant** | Months 6-9 | Differentiate | Summaries, Q&A, quiz engine, premium paywall |
| **Phase 4 – Growth & Scale** | Months 10-12 | Expand market | More languages, voice customization, marketing push |

---

## Team & Responsibilities
| Role | FTE | Core Responsibilities |
|------|-----|-----------------------|
| Product Manager | 1 | Vision, backlog, KPIs |
| Flutter Devs | 2 | Front-end, PDF viewer, UI |
| Back-end / DevOps | 1 | Sync, storage, CI/CD |
| ML / TTS Engineer | 0.5 (part-time) | Integrate Coqui, optimize voices |
| QA Engineer | 0.5 | Manual + automated testing |
| UX/UI Designer | 0.5 | Flows, prototypes, design system |

---

## Budget Snapshot (MVP)

| Line Item | Cost (USD) |
|-----------|-----------:|
| Design & Prototyping | 8 k – 15 k |
| Flutter Development | 15 k – 25 k |
| TTS Integration | 5 k – 8 k |
| PDF Rendering | 3 k – 5 k |
| QA & Testing | 4 k – 7 k |
| Deployment & Ops | 2 k – 3 k |
| **Total** | **37 k – 63 k** |

Annual operational spend (hosting, monitoring, store fees) projected at **< $3 k** in year 1.

---

## Success Metrics
- **DAU / MAU Ratio** ≥ 25 %  
- **Avg. Session Length** ≥ 15 min  
- **Crash-Free Sessions** ≥ 99.9 %  
- **Premium Conversion** ≥ 15 % within 12 months  
- **Churn (Premium)** ≤ 5 % monthly

---

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|-----------|
| TTS quality not competitive | Medium | Offer multiple engines; gather user feedback early |
| PDF edge-case rendering | Low | Extensive test suite; fallback to native renderers |
| Store policy changes | Medium | Continuous compliance monitoring |
| Competitor price drops | Medium | Emphasize AI-driven features + superior UX |

---

## Conclusion
MaxSpeak aims to democratize high-quality TTS reading by combining open-source technology, a single Flutter codebase, and a clear freemium model at **~85 % lower cost** than current market leaders—while laying the groundwork for powerful AI-assisted study tools.
