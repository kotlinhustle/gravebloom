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
Move -> kite enemies -> auto-attack -> collect XP shards -> level up -> choose relic upgrades -> survive longer
```

## Tech

- Engine: Godot 4.6.3.
- Renderer target: Compatibility / GL Compatibility.
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

## Current Structure

```text
project.godot
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

`Main`:

- Builds a simple dark arena.
- Spawns the player.
- Spawns enemy waves.
- Owns enemy and XP shard lists.
- Updates XP collection, level-ups, upgrade UI, HUD, and enemy contact damage.

`Player`:

- `CharacterBody2D`.
- Supports keyboard movement via WASD/arrows.
- Supports mouse drag movement by polling left mouse button.
- Has early touch input support for mobile-style movement.
- Takes damage and dies.

`Enemy`:

- `CharacterBody2D`.
- Chases `target`.
- Rotates toward the player.
- Flashes, squashes, and receives knockback on hit.
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

- Shared static helper for damage numbers, death bursts, and level-up rings.
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

## Near-Term Roadmap

- Add visible virtual joystick for TWA/mobile clarity.
- Add a proper run objective: survive timer, death screen, and later a first boss/miniboss.
- Split `Main` further into focused systems when complexity grows: spawner, upgrade manager, HUD, XP collector.
- Add 2-3 more relic upgrades, including a first secondary weapon or spirit attack.
- Improve visuals after the gameplay loop is clearer.
