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
Start journey -> clear Dead Garden -> defeat Grave King -> choose a royal gift -> enter Ashen Chapel -> defeat Ash Abbot
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
- For stubborn Telegram WebView cache, also refresh previous `game-*.js/.wasm` payloads and keep
  no-cache meta tags in the generated `index.html`.

## Current Structure

```text
project.godot
assets/
  sprites/
    player_masked_wanderer.png
    player_masked_wanderer_sheet.png
    enemy_crawler.png
    enemy_brute.png
    grave_warden.png
    grave_king.png
    ash_abbot.png
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
- `enemy_crawler_sheet.png` is a real 6-frame limb-pose walk cycle used by crawler-based enemy roles; do not replace it with whole-sprite squash/pulse animation.
- `enemy_brute_sheet.png`, `grave_king_sheet.png`, and `ash_abbot_sheet.png` provide real 4-frame pose cycles for heavy enemies and both journey bosses.
- Enemy sprites stay upright on screen like the player instead of rotating with movement. They only mirror horizontally when changing left/right direction; rotating the three-quarter-view art makes vertical movement look sideways or upside down.
- Keep generated originals outside the repo; commit only cropped project-ready PNG files in `assets/sprites/`.
- Sprite scenes use `Sprite2D`; older polygon placeholders are hidden, not deleted yet, so we can tune scale/collisions safely.
- Player uses a generated 6-frame idle + 6-frame run spritesheet; avoid procedural overlay limbs for hero animation.
- Sprite juice is script-driven: player frame switching plus small bob/lean, role-specific enemy locomotion/attack cycles, hit squash, and blade pulse all preserve each sprite's base scale. Enemy animation distinguishes fast skittering, heavy stomps, ranged charge/recoil, explosive pulsing, floating acolytes, and looming bosses without requiring sprite sheets yet.

`Main`:

- Runs are now short journeys through connected chapters rather than isolated timed arenas.
- The first journey starts in `Мертвый Сад`; clearing 50 enemies stops ordinary waves and summons `Король-Могила`. Killing him pauses combat for one royal-gift choice, then opens one physical gate to `Пепельная Часовня` near the player's current position. The player must walk into it to continue.
- Do not add route choices or intermediary maps unless they contain meaningful distinct gameplay. A decorative empty route only slows the journey.
- Health, level, XP, relics, and auto-weapons persist across areas. Reset the Living Blade to its owner during transitions so it cannot remain offscreen while chasing a deleted enemy, and keep its canvas layer above rebuilt arena backgrounds.
- Garden and Chapel boss deaths must be tracked separately even though both currently use the shared internal `grave_king` enemy slot. Killing `Король-Могила` unlocks the royal-gift choice and then the Chapel gate; killing `Игумен Пепла` opens the final passage.
- Clearing 75 chapel enemies stops ordinary waves and summons `Игумен Пепла`; after killing him, the hero must walk into the final passage to win the journey.
- Bosses should threaten with attacks and positioning rather than simply outrunning the player. Their base chase speed and phase-two acceleration are intentionally restrained.
- Combat areas are currently cleared by objectives rather than a global three-minute survival timer. The HUD shows current area progress.
- Supports chapter selection infrastructure from the earlier standalone-arena format, but the main start screen now launches the connected journey.
- The selected chapter changes arena palette/decor, run lore lines, boss title/entrance/death lines, and light enemy pacing modifiers.
- The selected chapter is saved in the local profile as `chapter_index`, so Web/TWA players keep their last chosen map.
- New chapters should be real gameplay variants, not only menu labels: each chapter should eventually get its own palette, decor motifs, enemy pressure bias, boss identity, and short lore.
- Builds a procedural ruined arena: stone floor tiles, cracks, rubble, gravestones, broken columns, graveblooms, cursed runes, drifting fog, and screen vignette.
- `Пепельная Часовня` is a real gameplay variant: warmer ash tones, long nave/aisle marks, rows of chapel columns, arch debris, ember glows, faster enemies, and bell-ring hazard zones instead of Gravebloom flowers.
- `Пепельная Часовня` now has deliberate level geometry: a fast central nave, roomy side aisles, a wide transept, an altar arena, and physical pew/column/wall obstacles. Keep every route wide enough for mobile movement and dense enemy waves; spawn positions and hazards are pushed out of obstacles.
- `Мертвый Сад` is the open counterpart to the chapel: broad curved paths connect large clearings, grave plots and short physical fences provide landmarks, and a few clearly glowing thorn thickets deal light continuous damage. Preserve multiple wide escape routes around every garden feature.
- Future maps should use distinct route topology, landmarks, and combat spaces rather than only different procedural decor.
- Visual clarity is a hard constraint: background decor must read as low-contrast masses, not repeated lines. Avoid floor grids, outlined paths, dense cracks/runes, fence-like thin strokes, and excessive ambient glows. Reserve bright lines and rings for attacks, warnings, pickups, and major events.
- Physical walls, fences, pews, and columns must read as solid dark silhouettes with strong offset shadows so players notice collisions during dense combat.
- Chapel-exclusive enemies are `Пепельный Послушник` (`ash_acolyte`, dense melee pressure), `Звонарь` (`ash_bellringer`, ranged pressure), and `Быстрый Уголь` (`ash_ember`, fast flanking explosive pressure).
- Bell-ring hazards must be recognizable by shape, not color alone: a large bell silhouette, clapper, and concentric sound waves. They must not reuse Gravebloom petals or flower runes.
- The chapel final boss still uses the shared internal `grave_king` boss slot for compatibility, but appears as `Игумен Пепла` with its own generated `ash_abbot.png` sprite and distinct attack script: ash-wave fans, Last Bell rings, bell zones, chapel summons, and the `Кадило раскололось` second phase.
- Manages run states: start, running, upgrade, game_over, victory.
- Spawns the player.
- Spawns enemy waves.
- Regular enemies should spawn just outside the current camera view and walk in from the screen edge, not materialize inside the active screen.
- Enemy waves now mix roles: crawler, brute, fast runner, flanker, ranged spitter, explosive enemy, final-minute boss, and miniboss.
- Enemy role indicators are intentionally restrained. Ordinary enemies, spitters, bellringers, and fast embers rely on their sprite silhouette; exploders keep only a muted danger ring, and miniboss/boss rings are subdued. Avoid lighting every enemy at once.
- Dead Garden enemies no longer use purple overhead indicators. Spitters rely on a muted toxic-green silhouette and their visible projectile.
- Enemies use light separation so they do not collapse into one harmless blob during circular kiting.
- Spitters use predictive shots, flankers try to cut ahead/sideways, and after the first minute occasional interceptors spawn ahead of the player's movement to break endless clockwise/counterclockwise kiting.
- A pressure director keeps the fight populated around the player: it counts nearby/on-screen threats, spawns edge pressure if the active screen goes empty, and recycles far non-boss enemies when the global enemy cap is filled by harmless distant mobs.
- Gravebloom hazard zones periodically warn, bloom, then damage the player if they keep running through the same route; they should read as large animated cursed flowers with a short Russian warning label. Keep a safe distance from the player on spawn and preserve a clear no-damage warning phase.
- If too many enemies stay packed together after the first minute, the cluster can bloom into a hazard zone to punish harmless enemy balls.
- `Король-Могила` remains implemented as a standalone boss identity and can return in a later journey branch; the first connected journey currently culminates with `Игумен Пепла`.
- Defeating `Король-Могила` pauses the journey for one run-defining royal gift before the Chapel gate opens: `Сердце Короля` gives the Living Blade a larger cleaving hit, `Мёртвая Корона` adds a ghost-blade echo after Nova, and `Королевский Прах` summons an attacking shadow every seven ordinary kills.
- Closing the royal-gift choice must restore the mobile joystick, Nova controls, and combat HUD before the player walks to the Chapel gate.
- Boss attacks include `Похоронный Колокол` radial shock rings, `Королевский Приговор` lane strikes along the player's route, and phase-two `Черная корона` cross strikes.
- Король-Могила has a dedicated top HUD boss HP bar that appears on spawn, updates with damage, flashes on phase two, and hides on boss death/result screens.
- Keeps the player inside visible ruined arena bounds and caps live enemy pressure for early readability.
- Visible UI text is Russian-first; keep menus, HUD, result screens, upgrade choices, and combat notices localized.
- Player-facing terms should explain themselves in-game. Keep `Справка Маски` available from menus and add short local explanations near terms like `Пепел`, `Реликвии`, `Летопись`, objectives, and HUD counters.
- Micro-lore is embedded through the start screen, timed run notices, relic descriptions, relic-pick echo lines, boss entrance lines, and result text.
- Relic cards should keep the lore phrase, then add a short mechanical effect so choices stay understandable.
- Relic choice text must fit on a 540px-wide phone screen; keep descriptions short and mechanical enough to avoid clipped button text.
- Summons `Игумен Пепла` after the player clears the chapel objective.
- Owns enemy and XP shard lists.
- Updates XP collection, level-ups, randomized relic choices, HUD, XP bar, result screens, enemy contact damage, and enemy projectiles.
- Handles screen shake, XP sparkles, and Shadow Spirit secondary weapon.
- Screen shake is applied through `Player/Camera2D.offset`, not by moving `world` with its child camera. Low-intensity events are ignored, strong events are scaled/capped, and offsets are smoothed.
- Handles Gravebloom Nova ultimate charge, UI indicator, staged 85/90/97% visual/audio cues around the player, radial damage, knockback, and burst FX.
- Relics currently include blade damage/cooldown/range, Shadow Spirit, XP magnet, vampiric healing, Nova upgrades, and thorn retaliation.
- `Кровавый Цветок` can heal from Nova kills, but Nova-triggered vampirism is capped per ultimate cast so the combo does not become a full heal button.
- Repeated `Кровавый Цветок` picks should improve the vampirism build by increasing heal amount and reducing kills required, not be a dead duplicate choice.
- `Расширить бледный радиус` should improve blade range and tempo, not only target search radius, so it feels competitive with stronger relics.

`Player`:

- `CharacterBody2D`.
- Camera zoom is tuned for mobile portrait readability.
- Supports keyboard movement via WASD/arrows.
- Keyboard movement is polled every physics frame; do not reintroduce persistent key latch booleans for movement because browser builds can miss key release events and create stuck movement.
- Supports mouse drag movement by polling left mouse button.
- Mouse drag now starts only from unhandled pointer events, so UI clicks do not silently turn into movement input.
- Has early touch input support for mobile-style movement.
- Uses a visible virtual joystick on the running screen for TWA/mobile clarity; joystick is on the right and Nova indicator is on the left.
- Takes damage and dies.

`Enemy`:

- `CharacterBody2D`.
- Chases `target`.
- Rotates toward the player.
- Flashes, squashes, and receives knockback on hit.
- Supports normal, brute, and miniboss tuning from `Main`.
- Supports role behavior: runners move faster, spitters keep distance and fire projectiles, exploders burst on contact.
- Emits `died(enemy_position)` on death.
- Emits `damaged(enemy_position, amount)` for hit feedback.
- Emits `spitting(enemy_position, direction)` so `Main` can spawn simple projectile nodes.
- Spitter projectiles should stay lower-damage ranged pressure; close contact, boss hits, and telegraphed hazards should remain more dangerous than a regular ranged shot.
- Spitter projectiles use a readable toxic core/ring/tail visual rather than a plain dot.

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
- Player cannot leave the arena bounds; boundaries should be visually marked to avoid invisible-wall feel.
- Mouse drag means: hold left mouse button, drag away from the starting point, release to stop.
- The green object around the hero is the Living Blade; it now flies out to hunt enemies and returns.
- Hits now show damage numbers, enemy flash/squash, knockback, and death bursts.
- Ordinary enemy deaths use restrained bursts without role-specific rings. Keep larger rings for minibosses, explosions, hazards, ultimates, and other signals that affect player decisions.
- Combat rays and strikes should not look like flat rectangular debug bars. Use tapered or curved silhouettes, irregular edges, bright cores, and a few restrained fragments while preserving readable hitboxes and telegraphs.
- Combat has a first "meaty" layer: Living Blade finishing hits create stronger bug/Gravebloom death bursts without execution text; use toxic green, amber, and dark violet rather than human-blood red. Kill streaks appear at milestones, and taking damage breaks the streak.
- Living Blade executions lightly heal the player, add a little Nova charge, and have a higher chance to drop a health pack, so aggressive close-range kills feel like a resource loop.
- Incoming damage now shows red numbers over the player, throttled for continuous contact/hazard damage so it does not spam the screen.
- Runs now have a journey start screen, XP bar, area-clear objectives, physical chapter gates, chapter bosses, victory/death screens, and a restart button.
- Starting a journey now shows a short Russian text prologue before controls become active. Keep it brief, phone-readable, and focused on why the Mask enters the ruins.
- Killing `Игумен Пепла` starts a short skippable finale: combat stops, the last bell answers, and a dark passage opens behind the altar. The finale then restores player control, and victory only occurs when the hero walks into that passage. Skipping captions must skip to the interactive gate, not directly to victory.
- Keep the start screen deliberately sparse: journey premise, Ash total, and only `Начать путешествие` and `Еще`. Goals, profile, codex, help, and run history live on separate secondary screens. Navigating menus must not reroll active run goals.
- Result screens should summarize the run: time survived, level, kills, XP progress, and selected relic build with duplicate counts.
- Keep the first result screen compact: outcome, chapter, time, level, kills, best streak, Ash reward, and only `Заново`, `Подробности`, `Главное меню`. Lore, goal progress, reward breakdown, codex unlocks, and relic lists belong on the separate details screen.
- Result screens award `Пепел`, persist it locally, and offer a path into the profile screen.
- Local profile data is saved to `user://save.json`; in Web/TWA this is browser/WebView local storage, not a backend-backed account.
- The profile screen shows total `Пепел`, permanent upgrades, and a short history of recent runs.
- Permanent upgrades currently include stronger starting HP, starting Living Blade damage, starting XP magnet range, and faster Nova charge.
- Permanent upgrades remain beneficial but partially wake the ruins: total profile upgrade levels modestly increase enemy HP/speed/contact damage, late-run wave density, pressure-director targets, and boss HP. This prevents a highly upgraded profile from trivializing runs without fully cancelling progression.
- Each run now rolls 3 short objectives shown on the start screen. Objectives track actions such as kills, level, seeing/killing `Король-Могила`, collecting health packs, casting Nova, unlocking auto-weapons, and evolving `Кровавый Клинок`.
- Completed run objectives award bonus `Пепел`, appear on the result screen, and store their bonus in run history.
- `Летопись Маски` is a profile/codex screen available from the start screen and profile. It stores cumulative stats in `user://save.json`, unlocks short lore entries for milestone achievements, and gives one-time `Пепел` rewards for new entries.
- During runs, the HUD should show a compact active build summary with key weapons/relic counts and short evolution hints.
- Avoid abstract build labels in the combat HUD and relic cards. Show concrete active tools instead: `Клинок`, `Копья`, `Колокол`, `Тень`, `Цветок`, `Серия`. Named builds can remain internal/history data until they have real gameplay bonuses.
- Relic choice descriptions can include short evolution hints when they affect a known evolution, but must stay phone-readable and avoid unclear shorthand such as `Эво`.
- Level-ups automatically increase max HP, heal the player, and add a small global player damage bonus on top of relic choices.
- Relics can unlock Shadow Spirit, a secondary auto-skill that cuts through enemies in a beam.
- Relics can unlock `Колокол Забвения`, an auto-weapon that periodically emits a radial shockwave around the player; repeat picks increase damage/radius and reduce cooldown.
- Relics can unlock `Костяные Копья`, an auto-weapon that fires piercing bone-line attacks toward enemies; repeat picks increase damage, spear count, and tempo.
- Relic evolution exists in a small first form: any 2 Living Blade upgrades plus `Кровавый Цветок` evolves the blade into `Кровавый Клинок`, making it stronger, faster, red-tinted, and lightly vampiric on hits. Keep this reachable inside a normal 3-minute run.
- `Колокол Забвения` should be guaranteed in the first relic choice until unlocked, so players discover the second auto-weapon instead of waiting for random rolls.
- Gravebloom Nova is an automatic ultimate: it charges over time, shows a visible `NOVA` indicator with percent progress, gives peripheral visual/audio cues from 85% onward, then fires by itself and blasts nearby enemies.
- Nova readiness should be readable without staring at HUD: faint aura at 85%, rotating Gravebloom ring at 90%, stronger warning at 97%, then a distinct burst cue at cast.
- Do not spend more time trying to make laptop touchpad tap-to-click control Nova; the game should not depend on that input path.
- Small health potions can drop from enemies, pulse on the ground, heal a little on pickup, and expire after a short time. They use a dark glass bottle with crimson liquid and mint healing sparks instead of a modern red-cross icon.
- Run reset must restore temporary upgrade state such as XP magnet range; upgrades should not leak into the next run after death/restart.
- XP pacing is intentionally slower after the ultimate was added: higher XP thresholds keep Nova kills from over-leveling too quickly.

## Near-Term Roadmap

- Add touch-friendly pause/options and Telegram-specific restart polish.
- Split `Main` further into focused systems when complexity grows: spawner, upgrade manager, HUD, XP collector.
- Add more auto-weapons and relic synergies once `Колокол Забвения` is tuned.
- Improve visuals after the gameplay loop is clearer.
