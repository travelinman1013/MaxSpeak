# Claude Code Development Workflow - MaxSpeak

## 🎯 CRITICAL: First-Read Protocol
**ALWAYS READ `implementation_plan.md` FIRST** before starting any development session. This ensures you understand the current development phase, priorities, and context.

## 📋 Task Management Workflow

### 1. Session Start Protocol
```
1. Read implementation_plan.md → Understand current phase
2. Read tasks.md → Check task status and priorities  
3. Update task status → Mark "In Progress" before starting
4. Implement → Follow phase-specific guidelines
5. Update tasks.md → Mark complete, add discovered tasks
```

### 2. Task Execution Rules
- **One task at a time** - Focus prevents context fragmentation
- **Update status immediately** - Track progress in real-time
- **Document blockers** - Add to tasks.md if blocked
- **Cross-reference constantly** - Link code to plan sections

## 🧠 Planning Mode Optimization

### When to Use Planning Mode
- Features requiring 3+ implementation steps
- Architecture decisions affecting multiple components
- Integration of new technologies (TTS, PDF rendering)
- Refactoring that touches multiple files

### Planning Mode Best Practices
```
1. State the objective clearly
2. Break into concrete, testable steps
3. Identify dependencies upfront
4. Exit planning mode with specific file targets
```

## 🔄 Session Continuity Instructions

### Session Handoff Protocol
When ending a session:
1. Update tasks.md with current status
2. Document any partial implementations
3. Note critical context for next session
4. Update session_history.md (if exists)

### Session Resume Protocol
When continuing work:
1. Read last session summary in tasks.md
2. Check for incomplete tasks
3. Review recent commits
4. Continue from documented stopping point

## 📦 Context Window Management

### File Reading Priority
1. **Always first**: implementation_plan.md, tasks.md
2. **When implementing**: Relevant existing code files
3. **When designing**: project_structure.md (if exists)
4. **When debugging**: bug_tracking.md (if exists)

### Context Conservation Rules
- Read only files directly related to current task
- Use search tools instead of reading entire directories
- Summarize large files instead of reading completely
- Clear context between major task switches

## 🛠️ MaxSpeak-Specific Guidelines

### Flutter Development
- Always check existing widget patterns before creating new ones
- Follow established state management approach (check implementation_plan.md)
- Test on both iOS and Android configurations

### TTS Integration
- Prioritize Coqui TTS implementation
- Always implement fallback to native synthesizers
- Test voice quality at different speeds (0.5x - 3x)

### PDF Handling
- Use PDF.js Flutter plugin as primary renderer
- Implement error handling for edge cases
- Test with various PDF formats and sizes

### Security Considerations
- Implement AES-256 encryption for stored PDFs
- Use OS-level secure keystore for credentials
- Never log sensitive information

## 🚀 Quick Commands Reference

### Development Commands
```bash
# Flutter commands
flutter pub get          # Install dependencies
flutter run             # Run app
flutter test            # Run tests
flutter build ios       # Build for iOS
flutter build apk       # Build for Android

# Code quality
flutter analyze         # Static analysis
flutter format .        # Format code
```

### Git Workflow
```bash
# Feature branches
git checkout -b feature/[task-id]-[brief-description]
git commit -m "feat: [task description] - Implements [plan section]"
```

## 📊 Quality Checkpoints

Before marking any task complete:
1. ✅ Code compiles without errors
2. ✅ Flutter analyze passes
3. ✅ Basic functionality tested
4. ✅ Cross-platform compatibility verified
5. ✅ Security requirements met
6. ✅ Performance acceptable

## 🔗 File Cross-References

- **Development Roadmap**: See implementation_plan.md
- **Current Tasks**: See tasks.md
- **Project Structure**: See project_structure.md (Tier 2)
- **UI/UX Guidelines**: See ui_ux_documentation.md (Tier 2)
- **Bug Tracking**: See bug_tracking.md (Tier 2)

## 💡 Remember

- MaxSpeak is competing with Speechify/Natural Reader
- Focus on MVP features first (Phase 1)
- Keep architecture scalable for AI features
- Optimize for both phones and tablets
- Maintain ~85% lower cost than competitors

## 🎨 UI Design with SuperDesign Plugin

### When to Use SuperDesign
When asked to design UI & frontend interfaces for MaxSpeak, follow the SuperDesign workflow below. This ensures consistent, high-quality designs before Flutter implementation.

### SuperDesign Workflow for MaxSpeak

1. **Layout Design** (ASCII wireframes)
   - Think through screen layout and components
   - Create ASCII wireframes showing UI structure
   - Get user approval before proceeding

2. **Theme Design** (Using generateTheme tool)
   - Generate consistent color schemes
   - Select readable fonts (avoid generic blues)
   - Define spacing and shadows
   - Save to `.superdesign/design_iterations/theme_{n}.css`

3. **Animation Design** (Micro-interactions)
   - Define smooth, non-distracting transitions
   - Specify timing for all interactions
   - Document loading states and feedback

4. **HTML Mockup Generation**
   - Create interactive HTML prototypes
   - Test responsive behavior (phone & tablet)
   - Save as `.superdesign/design_iterations/{screen}_{n}.html`
   - Get final approval before Flutter implementation

### File Naming Convention
- Themes: `theme_{n}.css`
- Screens: `{screen_name}_{n}.html` (e.g., `reader_ui_1.html`, `library_view_2.html`)
- Iterations: `{current_file}_{n}.html` (e.g., `reader_ui_1_1.html`)

## Styling
1. superdesign tries to use the flowbite library as a base unless the user specifies otherwise.
2. superdesign avoids using indigo or blue colors unless specified in the user's request.
3. superdesign MUST generate responsive designs.
4. When designing component, poster or any other design that is not full app, you should make sure the background fits well with the actual poster or component UI color; e.g. if component is light then background should be dark, vice versa.
5. Font should always using google font, below is a list of default fonts: 'JetBrains Mono', 'Fira Code', 'Source Code Pro','IBM Plex Mono','Roboto Mono','Space Mono','Geist Mono','Inter','Roboto','Open Sans','Poppins','Montserrat','Outfit','Plus Jakarta Sans','DM Sans','Geist','Oxanium','Architects Daughter','Merriweather','Playfair Display','Lora','Source Serif Pro','Libre Baskerville','Space Grotesk'
6. When creating CSS, make sure you include !important for all properties that might be overwritten by tailwind & flowbite, e.g. h1, body, etc.
7. Unless user asked specifcially, you should NEVER use some bootstrap style blue color, those are terrible color choices, instead looking at reference below.
8. Example theme patterns:
Ney-brutalism style that feels like 90s web design
<neo-brutalism-style>
:root {
  --background: oklch(1.0000 0 0);
  --foreground: oklch(0 0 0);
  --card: oklch(1.0000 0 0);
  --card-foreground: oklch(0 0 0);
  --popover: oklch(1.0000 0 0);
  --popover-foreground: oklch(0 0 0);
  --primary: oklch(0.6489 0.2370 26.9728);
  --primary-foreground: oklch(1.0000 0 0);
  --secondary: oklch(0.9680 0.2110 109.7692);
  --secondary-foreground: oklch(0 0 0);
  --muted: oklch(0.9551 0 0);
  --muted-foreground: oklch(0.3211 0 0);
  --accent: oklch(0.5635 0.2408 260.8178);
  --accent-foreground: oklch(1.0000 0 0);
  --destructive: oklch(0 0 0);
  --destructive-foreground: oklch(1.0000 0 0);
  --border: oklch(0 0 0);
  --input: oklch(0 0 0);
  --ring: oklch(0.6489 0.2370 26.9728);
  --chart-1: oklch(0.6489 0.2370 26.9728);
  --chart-2: oklch(0.9680 0.2110 109.7692);
  --chart-3: oklch(0.5635 0.2408 260.8178);
  --chart-4: oklch(0.7323 0.2492 142.4953);
  --chart-5: oklch(0.5931 0.2726 328.3634);
  --sidebar: oklch(0.9551 0 0);
  --sidebar-foreground: oklch(0 0 0);
  --sidebar-primary: oklch(0.6489 0.2370 26.9728);
  --sidebar-primary-foreground: oklch(1.0000 0 0);
  --sidebar-accent: oklch(0.5635 0.2408 260.8178);
  --sidebar-accent-foreground: oklch(1.0000 0 0);
  --sidebar-border: oklch(0 0 0);
  --sidebar-ring: oklch(0.6489 0.2370 26.9728);
  --font-sans: DM Sans, sans-serif;
  --font-serif: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
  --font-mono: Space Mono, monospace;
  --radius: 0px;
  --shadow-2xs: 4px 4px 0px 0px hsl(0 0% 0% / 0.50);
  --shadow-xs: 4px 4px 0px 0px hsl(0 0% 0% / 0.50);
  --shadow-sm: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 1px 2px -1px hsl(0 0% 0% / 1.00);
  --shadow: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 1px 2px -1px hsl(0 0% 0% / 1.00);
  --shadow-md: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 2px 4px -1px hsl(0 0% 0% / 1.00);
  --shadow-lg: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 4px 6px -1px hsl(0 0% 0% / 1.00);
  --shadow-xl: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 8px 10px -1px hsl(0 0% 0% / 1.00);
  --shadow-2xl: 4px 4px 0px 0px hsl(0 0% 0% / 2.50);
  --tracking-normal: 0em;
  --spacing: 0.25rem;

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
}
</neo-brutalism-style>

Modern dark mode style like vercel, linear
<modern-dark-mode-style>
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.1450 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.1450 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.1450 0 0);
  --primary: oklch(0.2050 0 0);
  --primary-foreground: oklch(0.9850 0 0);
  --secondary: oklch(0.9700 0 0);
  --secondary-foreground: oklch(0.2050 0 0);
  --muted: oklch(0.9700 0 0);
  --muted-foreground: oklch(0.5560 0 0);
  --accent: oklch(0.9700 0 0);
  --accent-foreground: oklch(0.2050 0 0);
  --destructive: oklch(0.5770 0.2450 27.3250);
  --destructive-foreground: oklch(1 0 0);
  --border: oklch(0.9220 0 0);
  --input: oklch(0.9220 0 0);
  --ring: oklch(0.7080 0 0);
  --chart-1: oklch(0.8100 0.1000 252);
  --chart-2: oklch(0.6200 0.1900 260);
  --chart-3: oklch(0.5500 0.2200 263);
  --chart-4: oklch(0.4900 0.2200 264);
  --chart-5: oklch(0.4200 0.1800 266);
  --sidebar: oklch(0.9850 0 0);
  --sidebar-foreground: oklch(0.1450 0 0);
  --sidebar-primary: oklch(0.2050 0 0);
  --sidebar-primary-foreground: oklch(0.9850 0 0);
  --sidebar-accent: oklch(0.9700 0 0);
  --sidebar-accent-foreground: oklch(0.2050 0 0);
  --sidebar-border: oklch(0.9220 0 0);
  --sidebar-ring: oklch(0.7080 0 0);
  --font-sans: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  --font-serif: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  --radius: 0.625rem;
  --shadow-2xs: 0 1px 3px 0px hsl(0 0% 0% / 0.05);
  --shadow-xs: 0 1px 3px 0px hsl(0 0% 0% / 0.05);
  --shadow-sm: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 1px 2px -1px hsl(0 0% 0% / 0.10);
  --shadow: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 1px 2px -1px hsl(0 0% 0% / 0.10);
  --shadow-md: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 2px 4px -1px hsl(0 0% 0% / 0.10);
  --shadow-lg: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 4px 6px -1px hsl(0 0% 0% / 0.10);
  --shadow-xl: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 8px 10px -1px hsl(0 0% 0% / 0.10);
  --shadow-2xl: 0 1px 3px 0px hsl(0 0% 0% / 0.25);
  --tracking-normal: 0em;
  --spacing: 0.25rem;

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
}
</modern-dark-mode-style>

## Images & icons
1. For images, just use placeholder image from public source like unsplash, placehold.co or others that you already know exact image url; Don't make up urls
2. For icons, we should use lucid icons or other public icons, import like <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>

## Script
1. When importing tailwind css, just use <script src="https://cdn.tailwindcss.com"></script>, don't load CSS directly as a stylesheet resource like <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
2. When using flowbite, import like <script src="https://cdn.jsdelivr.net/npm/flowbite@2.0.0/dist/flowbite.min.js"></script>

### MaxSpeak-Specific Design Considerations

**Reading-Focused UI**
- High contrast for extended reading sessions
- Adjustable text size and spacing
- Minimal distractions during reading
- Clear visual hierarchy

**Accessibility First**
- WCAG 2.1 AA compliance minimum
- Screen reader compatibility
- High contrast mode support
- Large touch targets (48x48dp minimum)

**Performance Requirements**
- Smooth 60 FPS animations
- Fast page transitions
- Minimal battery drain
- Efficient memory usage

### Important SuperDesign Rules

1. **ALWAYS use actual tool calls** - Never output text like 'Called tool: write...'
2. **Get approval at each phase** - Don't proceed without user confirmation
3. **Use correct file paths** - All designs go in `.superdesign/design_iterations/`
4. **Follow the workflow** - Layout → Theme → Animation → HTML
5. **MaxSpeak focus** - Prioritize readability and accessibility

### Available SuperDesign Tools
- **generateTheme**: Create consistent theme CSS files
- **write**: Save HTML/CSS files to design iterations folder
- **edit/multiedit**: Iterate on existing designs
- All standard Claude Code tools (read, grep, bash, etc.)

---

*Last Updated: 2025-01-20*
*Version: 1.1*