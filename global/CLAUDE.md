# Global Engineering Rules

## Thinking order
Always break work into these layers when applicable.
1. Input normalization
2. Pure transformation
3. State transition
4. Effect execution

## Core principles
- Prefer pure functions for calculation, validation, normalization, mapping, filtering, and aggregation.
- Isolate side effects at boundaries.
- Default to immutability.
- Keep state minimal.
- Do not store derived state when it can be computed.
- Avoid hidden global state and implicit dependencies.
- Prefer explicit state transitions over ad-hoc mutation.
- Prefer composition over inheritance.
- Prefer small, safe, reversible diffs.
- Separate refactor from behavior change when possible.

## JavaScript / React
- Single source of truth for state.
- Do not store derived state.
- Keep hook dependencies complete.
- Separate rendering, transformation, and effects.
- Put network / storage / timer / browser APIs behind boundaries.
- Use cleanup for long-lived effects.
- Use request cancellation when appropriate.
- Avoid premature memoization.

## Cross-boundary work
- If frontend and backend both change, choose one owner.
- The other side performs peer boundary review.
- Do not proceed to final review until Boundary Sync passes.
