# AGENTS.md

Guidance for agents working in this package.

## Scope

This package provides app-wide lifecycle state for Swift apps using the Composable Architecture and Sharing. Keep changes focused on the requested behavior and avoid broad refactors unless they are necessary for the task.

## Project Layout

- `Package.swift`: Swift package manifest and product definitions.
- `Sources/AppGlobalState`: Core dependency, reducer, and scene-phase domain types.
- `Sources/AppGlobalStateUI`: SwiftUI integration for observing `ScenePhase`.
- `Tests/AppGlobalStateTests`: Unit tests using the Swift Testing framework and TCA `TestStore`.

## Coding Guidelines

- Use Swift 6 style and preserve 4-space indentation.
- Prefer SwiftUI, async/await, and TCA patterns already present in the package.
- Avoid force unwraps and avoid introducing Combine unless explicitly required.
- Keep public API additions small, documented by clear naming, and backed by tests when behavior changes.
- Preserve thread-safety around shared mutable test state.

## Testing

- Add or update tests in `Tests/AppGlobalStateTests` for reducer, dependency, or persistence behavior changes.
- Prefer the Swift Testing framework (`@Suite`, `@Test`, `#expect`).
- Use `.serialized` for tests that touch shared app storage or global state.
- Validate compile-sensitive changes with Xcode diagnostics or a package build when practical.

## Dependencies

The package depends on Point-Free libraries including Composable Architecture, Dependencies, and Sharing. Prefer existing APIs from these dependencies over new local abstractions.
