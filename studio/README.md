# Studio scene recipes

These six Luau files record edit-time construction and visual upgrades. They are outside the Rojo-managed `src/` folders and are not runtime scripts.

1. `BuildMap.luau`: creates the base school and professor assets.
2. `RefineMap.luau`: refines the initial course geometry.
3. `VisualUpgrade.luau`: adds scenery and the stylized yellow-hoodie professor.
4. `ReplayPolish.luau`: adds hall passes and replay-related scenery.
5. `ChaseUpgrade.luau`: adds the harder final course and updates its route.
6. `CampusPolish.luau`: applies room colors, route labels, and school posters.

To play or edit the existing game, open `ESCAPE THE PROFESSOR - Campus Upgrade.rbxl` from the repository root. Do not run these recipes just to start the game. The complete save already includes their results and later Studio placement changes.

Before deliberately using a recipe on another place, read its ownership assumptions and save a backup. Some recipes preserve or replace specific named folders, and older ones predate support for a repositioned school.
