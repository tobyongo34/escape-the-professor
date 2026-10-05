# ESCAPE THE PROFESSOR!

Publication status: Campus Upgrade uploaded October 4 as version 4 of the existing experience. Creator Dashboard confirms Public access with audience reach Ages 16+ and trusted friends. See PUBLISH_STATUS.md for the place/universe IDs.

## Play the saved game

Open ESCAPE THE PROFESSOR - Campus Upgrade.rbxl in Roblox Studio using File > Open from File, then use Test (F5). Click LET'S GET OUT OF HERE to start the timer. Earlier complete saves are preserved. See CAMPUS_UPGRADE.md for the latest changes and checks; CHASE_UPGRADE.md, REPLAY_UPGRADE.md and BUG_REVIEW.md cover preceding passes.

If Studio stays on Loading Studio, use File > Open from File (Ctrl+O) to open the saved game directly. This bypassed the built-in StartPage_24439.rbxm deserialization failure on September 30 and October 2; it does not repair that plugin. Login succeeded in the October 2 log. There is no need to wait at the stuck start screen to open this local place.

Desktop: WASD to move, Space to jump, E to interact, Shift to sprint.
Touch: movement stick, jump, tap interaction prompts, and RUN to toggle sprint.
Controller bindings: left stick, A to jump, X to interact, L3 to sprint.

The professor patrols the far hallway and staff room. Use furniture to break his line of sight. Sprint after grabbing the gold key, then weave around the exam carts and jump all three hurdles on the way to the bus. The finale gives a 1.8-second initial head start and rewards saving stamina for the last stretch. Results include Play Again and Hang Out; the finish area also has a RESULTS / REPLAY button.

Each room now has one optional golden hall pass. Walk near it to collect it. Passes survive falls and catches, reset on replay, and never block a required exit. Results recognize a clean escape and collecting all six. The timer remembers your fastest completed run for the current session only; leaving the server resets it. Settings includes OBJECTIVE HINTS to show or hide the next required target.

See BUILD_STATUS.md for verified tests and remaining limitations. The supplied photo was used as the visual reference for the applied stylized yellow-hoodie professor; studio/VisualUpgrade.luau records that edit-time pass.

## Development ownership

Rojo 7.7.0 serves default.project.json on localhost:34872.

| Local files | Studio objects managed by Rojo |
| --- | --- |
| src/shared | ReplicatedStorage.EscapeShared |
| src/server | ServerScriptService.EscapeServer |
| src/client | StarterPlayer.StarterPlayerScripts.EscapeClient |

Only edit these scripts locally. Parent services preserve unknown children. Workspace.EscapeSchool, Lighting, ServerStorage.EscapeAssets, and runtime-created interfaces/remotes are outside the Rojo mapping.

The shared Course module converts authored coordinates using the classroom floor's current CFrame. Moving the whole school or rotating it horizontally preserves gameplay checks and animated obstacle placement. Keep its room/checkpoint names intact. The older edit-time scenery recipes predate this conversion; do not rerun them over a manually repositioned map. ReplayPolish.luau uses the current classroom transform and replaces only its own ReplayPolish and BonusPasses folders.

Start Rojo from this folder in PowerShell:

    rojo serve default.project.json

Install the Rojo 7.7.0 CLI and Studio plugin using README.md first. Downloaded tools/ executables are local conveniences and are not included in GitHub.

Then connect the Studio Rojo plugin to localhost:34872. Leave the Rojo process running while editing local scripts.

The studio/ files are edit-time recipes executed through Studio MCP. BuildMap.luau creates the map once; RefineMap.luau improves shelves and obstacles; VisualUpgrade.luau applies a second decorative pass and the photo-inspired professor. ChaseUpgrade.luau uses the current classroom transform, replaces only its own ChaseUpgrade folder, widens the existing hurdles and relocates the final optional hall pass. These recipes are not live game scripts. Do not rebuild over manual map changes. Preserve the original Baseplate and SpawnLocation.

A Rojo build includes scripts only because the map is unmanaged. The complete game is the Studio .rbxl file. Keep a fresh Studio local save after map or script updates. scripts-only.rbxlx is an old partial snapshot and must not be used to play the full game.

The Campus Upgrade adds a server-owned Quiz module: three randomized questions per run from nine questions. Never move the answer bank into ReplicatedStorage. CampusPolish.luau safely reapplies only its own scenery folder, room wall colors and existing route header placement using the current classroom transform.

Physical mobile/controller and newcomer timing checks remain useful follow-ups. Current publication details are in PUBLISH_STATUS.md.
