# General Rules

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

# Model Context Protocol (MCP) Usage

## Core Rule: Use MCPs Before Guessing

When working with libraries, frameworks, or packages, query the appropriate MCP FIRST. Don't rely on training data.

## Available MCPs

**rails** - Rails API docs, methods, conventions, gems (use first for Rails projects)
**context7** - JS/TS/Python libraries, frameworks, APIs (call resolve-library-id, then query-docs)
**exa** - Current info, troubleshooting, best practices (use descriptive queries, not keywords)
**nixos** - Nix packages, NixOS/Home Manager/Darwin options, flake inputs

## Quick Reference

### When to Use Each MCP
- Rails code? → **rails** (fallback to context7 if needed)
- React/Vue/Next.js/Django/etc? → **context7**
- Post-2023 info or error troubleshooting? → **exa**
- NixOS packages or options? → **nixos**

### Common Patterns
```
# context7: resolve first, then query
context7_resolve-library-id(libraryName: "React", query: "...")
context7_query-docs(libraryId: "/facebook/react", query: "useState hook usage")

# nixos: common actions
nixos(action: "search", query: "package-name")
nixos(action: "info", query: "package-name")
nixos(action: "search", query: "option", type: "options")
nixos(action: "search", query: "option", source: "home-manager")

# exa: descriptive queries
exa_web_search_exa(query: "blog post comparing React and Vue performance")
```

## Key Rules

1. **MCP First**: Query MCP before writing code with external dependencies
2. **Be Specific**: Include framework/version/feature context in queries
3. **Verify Results**: Apply MCP info directly; don't mix with outdated training data

MCPs are your source of truth. Training data is outdated. When in doubt, query the MCP.
