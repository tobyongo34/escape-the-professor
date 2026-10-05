# Chase upgrade — October 2, 2026

Open `ESCAPE THE PROFESSOR - Chase Upgrade.rbxl`. It includes the complete map and ten production scripts, with the temporary regression helper removed. Rojo remains authoritative for `src/shared`, `src/server`, and `src/client`; the course and professor template remain unmanaged Studio content.

## What changed

The professor previously selected paths onto staff-room cabinet tops when navigation began at root height. Navigation now starts and ends at foot level, disables cabinet-climbing jumps in patrol areas, keeps useful routes between waypoints, and recovers when movement stalls. He patrols the far hallway as well as the staff room.

The final course has alternating exam carts, three hurdles spanning the lane, and visible hedge boundaries that close the outside bypass. A physical race route keeps the professor moving around carts without repeatedly changing sides as the player weaves. He accelerates from 23.5 to 26 studs/second after a 1.8-second initial head start. There is no chase teleport or rubber-banding. Respawns retain 2.5 seconds of protection.

The HUD shows the head start to a tenth of a second, distance to the chasing professor, and low-stamina/recovery feedback. Signs explain weaving, jumping and sprinting. The optional final hall pass is near the last stretch. The supplied photo's yellow-hoodie character design and the existing scenery are retained.

## Validation

- Hallway and staff-room patrol circuits completed with successful paths and no stuck recoveries.
- On October 2, the scripted physical sprint route finished in 8.1 seconds with zero catches/falls/recoveries; walking was caught in 7.8 seconds. The sprint route's closest professor gap was 19.8 studs.
- Catching, safe-area chase resumption, all six progression checks and all eleven collectible/replay checks passed.
- All ten production files and the edit-time recipe compile. A fresh playtest without the helper starts normally; actual keyboard input moves the player.
- Map layout was inspected from an overview. No new multiplayer, physical touch/controller, or full newcomer playthrough was performed. Human difficulty feedback is still useful.

## Studio opening issue

Studio's built-in `StartPage_24439.rbxm` failed to deserialize again on October 2. File > Open from File (Ctrl+O) opened the complete saved game successfully. This bypasses the start screen; it does not repair the built-in plugin. MCP was available after opening, and restarting the Rojo server restored synchronization on localhost:34872.

The clean place was saved to Replay Upgrade and copied to Chase Upgrade. Both were 141,753 bytes with SHA256 `DDA7D8CBB55D684C58EE2595C3AAC8F2C295B505A0F6A58498DC788A2C54C0D2` when verified. No cloud publication was performed.
