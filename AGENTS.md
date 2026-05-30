# Gravebloom Agent Notes

## Project

Gravebloom is a Godot 4.6 2D arena-battler prototype for future Telegram Web Apps export.

Core fantasy:

- Dark fairy-tale fantasy in the ruins of a dead kingdom.
- The hero is The Masked Wanderer.
- The main weapon is the Living Blade.
- Visual direction is simple dark pixel/shape art for now, with readable silhouettes before imported assets.

Core gameplay loop:

```text
Start run -> move -> kite enemies -> auto-attack -> collect XP shards -> level up -> choose relic upgrades -> survive 3:00
```

## Tech

- Engine: Godot 4.6.3.
- Renderer target: Compatibility / GL Compatibility.
- Primary layout target: Telegram mobile portrait, 540x960 viewport.
- Mobile readability currently uses enlarged sprite scales and larger HP/XP bars; keep Telegram as the truth over desktop sizing.
- Language: GDScript only.
- No AI gameplay code.
- Repository: https://github.com/kotlinhustle/gravebloom

Local Godot executable currently used for checks:

```powershell
C:\Users\user\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe
```

## Important Workflow

- Keep this file updated when project structure, gameplay direction, major systems, or verification commands change.
- Prefer small commits with clear messages.
- After meaningful code changes, run a Godot headless smoke check:

```powershell
& "C:\Users\user\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe" --headless --path "C:\Users\user\dev\game" --quit-after 2
```

- Push successful milestones to GitHub.
- Do not commit `.godot/`, `.vscode/`, `.import`, export builds, or local editor settings.
- For Telegram/WebView cache problems, deploy versioned Pages payload filenames on `gh-pages`
  (for example `game-<commit>.js/.pck/.wasm`) and point `index.html` `executable` to that prefix.
- If Telegram appears stuck on an older cached `index.html`, also overwrite previous `game-*.pck`
  payloads on `gh-pages` with the latest exported `.pck` so cached HTML still loads current gameplay.

## Current Structure

```text
project.godot
assets/
  sprites/
    player_masked_wanderer.png
    enemy_crawler.png
    enemy_brute.png
    grave_warden.png
    living_blade.png
    xp_shard.png
scenes/
  main.tscn
  player.tscn
  enemy.tscn
  xp_shard.tscn
  living_blade.tscn
scripts/
  combat_fx.gd
  main.gd
  player.gd
  enemy.gd
  xp_shard.gd
  living_blade.gd
```

## Current Systems

`Assets`:

- Core sprites are generated bitmap assets with transparent backgrounds.
- Keep generated originals outside the repo; commit only cropped project-ready PNG files in `assets/sprites/`.
- Sprite scenes use `Sprite2D`; older polygon placeholders are hidden, not deleted yet, so we can tune scale/collisions safely.
- Sprite juice is script-driven: player bob/lean plus procedural footstep motion, enemy crawl wobble, hit squash, and blade pulse all preserve each sprite's base scale.

`Main`:

- Builds a procedural ruined arena: stone floor tiles, cracks, rubble, gravestones, broken columns, graveblooms, cursed runes, drifting fog, and screen vignette.
- Manages run states: start, running, upgrade, game_over, victory.
- Spawns the player.
- Spawns enemy waves.
- Spawns a miniboss near the end of the 3-minute run.
- Owns enemy and XP shard lists.
- Updates XP collection, level-ups, upgrade UI, HUD, XP bar, result screens, and enemy contact damage.
- Handles screen shake, XP sparkles, and Shadow Spirit secondary weapon.

`Player`:

- `CharacterBody2D`.
- Camera zoom is tuned for mobile portrait readability.
- Supports keyboard movement via WASD/arrows.
- Supports mouse drag movement by polling left mouse button.
- Has early touch input support for mobile-style movement.
- Uses a visible virtual joystick on the running screen for TWA/mobile clarity.
- Takes damage and dies.

`Enemy`:

- `CharacterBody2D`.
- Chases `target`.
- Rotates toward the player.
- Flashes, squashes, and receives knockback on hit.
- Supports normal, brute, and miniboss tuning from `Main`.
- Emits `died(enemy_position)` on death.
- Emits `damaged(enemy_position, amount)` for hit feedback.

`LivingBlade`:

- Separate weapon scene and script.
- Uses a hunting state machine: `orbit -> dash -> hit -> return -> cooldown`.
- Orbits near the player while idle.
- Automatically chooses the nearest enemy inside range.
- Physically flies to the target, hits, leaves a trail, then returns to orbit.
- Supports upgrades for damage, cooldown, and range.

`CombatFx`:

- Shared static helper for damage numbers, death bursts, level-up rings, and small sparkles.
- Keep FX simple and procedural until the game loop settles.

`XPShard`:

- Rotates visually.
- Collection and attraction logic currently lives in `Main`.

## Current Known UX

- Attack is automatic; there is no manual shooting.
- Player controls only movement and positioning.
- Mouse drag means: hold left mouse button, drag away from the starting point, release to stop.
- The green object around the hero is the Living Blade; it now flies out to hunt enemies and returns.
- Hits now show damage numbers, enemy flash/squash, knockback, and death bursts.
- Runs now have a start screen, XP bar, 3:00 survival goal, miniboss event, victory screen, death screen, and restart button.
- Relics can unlock Shadow Spirit, a secondary auto-skill that cuts through enemies in a beam.

## Near-Term Roadmap

- Add touch-friendly pause/options and Telegram-specific restart polish.
- Split `Main` further into focused systems when complexity grows: spawner, upgrade manager, HUD, XP collector.
- Add 2-3 more relic upgrades, including a first secondary weapon or spirit attack.
- Improve visuals after the gameplay loop is clearer.
