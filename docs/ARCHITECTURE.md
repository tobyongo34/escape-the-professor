# Architecture and source guide

## Server source

| File | Responsibility |
| --- | --- |
| `src/server/Main.server.luau` | Starts game systems, receives remote input, updates sprint stamina and movement. |
| `src/server/Progression.luau` | Owns player run state, checkpoints, catches, results, replay, hall passes, and session records. |
| `src/server/Interactions.luau` | Handles homework, keys, quiz boards, and exits. Validates stage, distance, and cooldowns. |
| `src/server/ProfessorAI.luau` | Creates professor instances and controls patrol, sight, chase, navigation, and recovery. |
| `src/server/Quiz.luau` | Stores nine questions on the server, selects three per run, shuffles choices, and returns only the visible question payload. |

## Client source

| File | Responsibility |
| --- | --- |
| `src/client/Main.client.luau` | Sends input requests and updates the display from server events. |
| `src/client/UI.luau` | Creates menus, HUD, quiz, settings, results, and responsive layouts. |
| `src/client/Effects.luau` | Local visual and audio feedback. |
| `src/client/Guidance.luau` | Objective guidance and target presentation. |

## Shared source

- `src/shared/Config.luau`: names, objectives, colors, movement speeds, chase settings, and grading thresholds.
- `src/shared/Course.luau`: converts authored course coordinates using the current classroom-floor transform. This supports moving or horizontally rotating the whole school while keeping gameplay checks aligned.

## Data flow

1. The player uses keyboard, touch, or configured controller input.
2. Client code sends a request through the runtime-created `EscapeEvent` remote.
3. Server code validates the request against the player's state and applicable distance/timing rules.
4. The server updates progress or sends feedback.
5. Client code displays the new objective, quiz response, stamina, or result.

Roblox ProximityPrompts also trigger server interaction handling. The client does not own the correct quiz answers or decide that a stage is complete.

## Scene content

The full `.rbxl` save includes `Workspace.EscapeSchool` and `ServerStorage.EscapeAssets.Professor`. The server creates runtime professor clones from that template. The map and template are outside the Rojo project mapping. Keep a complete Studio save alongside the local scripts.

The `studio/` folder records six edit-time construction and upgrade recipes: BuildMap, RefineMap, VisualUpgrade, ReplayPolish, ChaseUpgrade, and CampusPolish. They are development tools and can change scene content. Use the supplied complete save to run the game without executing these recipes again.

## Multiplayer and persistence

Progression state and professor ownership are per player. The game does not use a persistent database for records: best times are session-only. The latest verification pass did not repeat multiplayer testing. Do not interpret individual automated tests as proof of all multiplayer or physical-device behavior.
