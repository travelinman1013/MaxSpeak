# Claude Code Development Workflow for MaxSpeak

## Primary Directive
**ALWAYS read `implementation_plan.md` first when starting any development session.** This file contains the project roadmap and current development phase.

## Session Workflow

### 1. Session Initialization
```
1. Read implementation_plan.md to understand current phase
2. Read tasks.md to check task status
3. Review any session_history.md if --resume flag is used
4. Enter Planning Mode for complex tasks
```

### 2. Task Management Protocol
- **Before Starting Work:**
  - Update tasks.md with "In Progress" status
  - Use TodoWrite tool for session task tracking
  - Break complex tasks into subtasks in Planning Mode

- **During Work:**
  - Update task progress in real-time
  - Document any blockers or discoveries
  - Add new tasks discovered during implementation

- **After Completing Work:**
  - Mark tasks as "Completed" with date stamp
  - Update session_history.md with key decisions
  - Commit changes with descriptive messages

### 3. Planning Mode Optimization
**When to Enter Planning Mode:**
- Tasks with 3+ implementation steps
- Architecture decisions
- Feature implementations
- Refactoring operations

**Planning Mode Best Practices:**
```
1. State: "I'll plan this implementation..."
2. Break down into concrete steps
3. Identify dependencies
4. Exit with clear action items
5. Execute systematically
```

### 4. Context Window Management
- **Prioritize Reading:**
  - Current task files only
  - Directly related dependencies
  - Skip completed components

- **Memory Optimization:**
  - Close files after reading
  - Summarize long files
  - Use search over full reads

### 5. Development Commands
```bash
# Web Development (Primary)
npm install          # Install dependencies
npm run dev          # Start development server
npm run build        # Build production
npm run preview      # Preview production build
npm test             # Run tests

# Desktop Packaging (Secondary)
npm run build:desktop    # Build Electron app
npm run dist            # Package for distribution
```

### 6. File Organization Rules
```
/src
  /components      # React components
  /features        # Feature modules
  /services        # Business logic & APIs
  /hooks          # Custom React hooks
  /utils          # Helper functions
  /types          # TypeScript definitions
  /styles         # Global styles
```

### 7. Code Quality Standards
- **Before Committing:**
  - Run `npm run lint`
  - Run `npm run typecheck`
  - Ensure all tests pass
  - Update relevant documentation

- **Component Creation:**
  - Follow existing patterns
  - Include TypeScript types
  - Add prop validation
  - Document complex logic

### 8. Session Continuity
**For --resume Sessions:**
1. Read session_history.md first
2. Check git status for uncommitted changes
3. Review last task context
4. Continue from documented breakpoint

**Session Documentation:**
- Document major decisions
- Note any architectural changes
- List pending items for next session
- Include any important discoveries

### 9. Error Handling Protocol
1. Read error messages completely
2. Check implementation_plan.md for similar issues
3. Search codebase for patterns
4. Document solution in bug_tracking.md (if exists)

### 10. Testing Workflow
```bash
# Unit Tests
npm test -- --watch     # Run in watch mode
npm test -- --coverage  # Check coverage

# E2E Tests (when implemented)
npm run test:e2e        # Run end-to-end tests
```

## Critical Reminders

### DO:
- ✅ Always read implementation_plan.md first
- ✅ Update tasks.md in real-time
- ✅ Use Planning Mode for complex tasks
- ✅ Test changes before marking complete
- ✅ Commit with descriptive messages

### DON'T:
- ❌ Skip reading the implementation plan
- ❌ Leave tasks in "In Progress" indefinitely
- ❌ Implement without planning complex features
- ❌ Commit broken code
- ❌ Create files unless necessary

## Quick Reference
- **Current Phase:** Check implementation_plan.md
- **Task Status:** Check tasks.md
- **Tech Stack:** React + TypeScript + Electron + TTS APIs
- **Primary Goal:** Web-first TTS reader with desktop packaging

Remember: This is a 3-5 day rapid development project. Focus on MVP features first!