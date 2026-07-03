# Meteor Harvest — Functional Product Specification

**Project:** Meteor Harvest  
**Platform:** Flutter mobile/web demo  
**Recommended engine:** Flutter + Flame  
**Primary goal:** Build a simple but visually impressive arcade game in about one hour using Antigravity + Gemini, while demonstrating how an AI agent can take a product spec, generate assets, implement gameplay, polish the experience, test it, and iterate quickly.

---

## 1. Product Vision

**Meteor Harvest** is a polished, fast-to-understand arcade game where the player pilots a small mining ship through a glowing meteor field, collecting energy crystals while avoiding dangerous asteroids.

The game should feel immediately satisfying:

- The ship glides smoothly.
- Crystals sparkle and pulse.
- Asteroids rotate and drift with weight.
- Collecting crystals creates satisfying particle bursts.
- Near misses, explosions, screen shake, trails, and shader effects make the game look more advanced than its simple mechanics.

The finished demo should make the audience think:  
**“That looks like a real mobile game, and AI helped build it fast.”**

---

## 2. Demo Strategy

This game is intentionally designed for a one-hour AI-agent coding demo.

### What should be built live

Build these during the meetup:

1. Flame project structure
2. Game loop
3. Player movement
4. Crystal collection
5. Asteroid collision
6. Score UI
7. Game over / restart
8. Particle effects
9. Basic polish pass

### What can be pre-generated before the meetup

Pre-generate these assets to avoid losing time:

1. Ship sprite
2. Crystal sprite
3. Asteroid sprites
4. Background starfield layers
5. Explosion sprite/particle images if needed
6. Sound effects
7. Music loop
8. App icon / title logo
9. Optional shader files

### One-hour success criteria

By the end of the demo, the game should have:

- A playable ship
- Collectible crystals
- Dangerous asteroids
- Score tracking
- Game-over state
- Restart button
- At least three visible polish effects
- A visually impressive background
- A clear “wow” moment such as an explosion, crystal burst, or warp background

---

## 3. Target Audience

Meteor Harvest is built for:

- Flutter developers curious about AI-assisted development
- Developers who want to see practical Antigravity + Gemini workflows
- Beginners who need a simple game loop they can understand
- Experienced developers who want to see how far polish can go with small mechanics

---

## 4. Core Game Loop

The player controls a mining ship in space.

1. The ship starts near the bottom-center of the screen.
2. Crystals spawn from the top and drift downward.
3. Asteroids spawn from the top and drift downward.
4. The player moves the ship to collect crystals.
5. The player avoids asteroids.
6. Collecting crystals increases score.
7. Hitting an asteroid causes an explosion and ends the run.
8. The player can restart immediately.

### Game objective

Collect as many crystals as possible before crashing.

### Session length

A normal run should last 30–90 seconds.

### Game feel target

- Easy to start
- Fast to understand
- Satisfying movement
- Slightly tense after 20 seconds
- Visually rewarding every few seconds

---

## 5. Controls

Support both desktop and mobile controls.

### Mobile controls

Use touch/drag control.

- Player touches anywhere on the screen.
- Ship smoothly moves toward the touch position.
- Ship should not instantly teleport.
- Ship should ease toward the target with acceleration/smoothing.

### Desktop/web controls

Support both:

- Mouse drag / mouse follow
- Keyboard arrows or WASD

### Recommended movement behavior

The ship should feel like it has momentum.

- Max speed: medium-fast
- Acceleration: smooth
- Deceleration: smooth
- Rotation/tilt: ship leans slightly toward movement direction
- Clamp ship within safe screen bounds

---

## 6. Gameplay Objects

## 6.1 Player Ship

The player ship is the hero object.

### Behavior

- Starts at bottom-center.
- Moves toward input target.
- Cannot leave screen bounds.
- Has a glowing engine trail.
- Slightly tilts left/right based on horizontal movement.
- Briefly flashes when collecting a crystal.
- Explodes when colliding with an asteroid.

### Collision

Use a forgiving circular hitbox smaller than the visible sprite.

Recommended:

- Visual sprite size: 64x64
- Collision radius: 22–26 px

This makes the game feel fair.

---

## 6.2 Energy Crystals

Crystals are collectible score objects.

### Behavior

- Spawn from top of screen.
- Drift downward with slight horizontal wobble.
- Rotate slowly.
- Pulse/glow with shader or opacity animation.
- Collected on collision with ship.
- On collection:
  - Add score
  - Play sound
  - Spawn sparkle burst
  - Briefly show floating `+10`
  - Slight score text pop animation

### Scoring

Base crystal score:

- Common crystal: +10
- Rare crystal: +50
- Golden crystal: +100

For the one-hour build, common crystals are enough. Rare/golden crystals are stretch goals.

### Spawn rate

Start with one crystal every 0.8–1.2 seconds.

As difficulty increases, crystal spawn can become slightly more frequent, but asteroids should increase faster.

---

## 6.3 Asteroids

Asteroids are hazards.

### Behavior

- Spawn from top of screen.
- Drift downward.
- Rotate continuously.
- Have random size and speed.
- May drift slightly horizontally.
- Cause game over on collision.

### Collision

Use circular hitboxes.

Recommended asteroid types:

| Type | Visual Size | Speed | Collision Radius | Notes |
|---|---:|---:|---:|---|
| Small | 48 px | Fast | 20 px | Harder to dodge |
| Medium | 72 px | Medium | 32 px | Standard hazard |
| Large | 96 px | Slow | 42 px | Visually impressive |

### Game over collision

When the player hits an asteroid:

1. Freeze player movement.
2. Hide or destroy ship.
3. Spawn explosion particles.
4. Trigger screen shake.
5. Slow game briefly for dramatic effect if feasible.
6. Show Game Over overlay.

---

## 6.4 Background Stars

The background should feel alive even with simple gameplay.

### Required layers

Use at least three background layers:

1. Far stars — small, slow-moving dots
2. Mid stars — slightly larger, medium speed
3. Nebula/cloud layer — subtle gradient or image

### Behavior

- Stars scroll downward to create forward-motion illusion.
- Different layers scroll at different speeds.
- Stars can twinkle subtly.
- Background should not distract from gameplay.

---

## 6.5 Optional Power-Ups

These are stretch goals only.

### Shield Orb

- Blue orb collectible.
- Gives one asteroid collision protection.
- Shield appears as circular glow around ship.

### Magnet Pulse

- Purple collectible.
- Pulls nearby crystals toward ship for 5 seconds.

### Time Warp

- Green collectible.
- Slows asteroids for 4 seconds.

For the live demo, do not build these unless the core game is already stable.

---

## 7. Difficulty Curve

The game should start easy and become more intense.

### Difficulty timer

Increase difficulty every 10 seconds.

### Difficulty variables

Adjust these over time:

- Asteroid spawn rate increases
- Asteroid speed increases
- Chance of larger asteroids increases
- Crystal spawn stays mostly consistent

### Recommended progression

| Time | Asteroid Spawn | Asteroid Speed | Feel |
|---:|---:|---:|---|
| 0–10s | Every 1.5s | Slow | Safe intro |
| 10–20s | Every 1.2s | Medium | Player engaged |
| 20–40s | Every 0.9s | Medium-fast | Arcade challenge |
| 40s+ | Every 0.7s | Fast | High intensity |

### Fairness rules

- Do not spawn asteroids directly on top of the player with no escape.
- Avoid impossible walls of asteroids.
- Leave at least one navigable lane when possible.
- Keep hitboxes smaller than visuals.

---

## 8. Scoring System

### Basic score

- Common crystal: +10
- Survival bonus: +1 per second

### Combo system

Optional but recommended for polish.

- Consecutive crystals collected within 2 seconds increase combo.
- Combo adds visual excitement.
- Example:
  - 1x combo: +10
  - 2x combo: +12
  - 3x combo: +15
  - 5x combo: +20

### UI feedback

When score changes:

- Score number pops slightly.
- Floating score text appears near collected crystal.
- Combo text appears if combo is active.

---

## 9. Screens and UX Flow

## 9.1 Title Screen

### Purpose

Make the game look polished before gameplay starts.

### Content

- Game title: `Meteor Harvest`
- Subtitle: `Mine crystals. Dodge meteors. Survive the field.`
- Primary button: `Start Run`
- Small footer: `Built with Flutter + Flame`

### Visual treatment

- Animated starfield behind title
- Ship gently floating/bobbing
- Crystals drifting behind UI
- Title glow animation

---

## 9.2 Gameplay Screen

### UI elements

- Top-left: Score
- Top-right: Best score
- Optional top-center: Combo indicator
- Optional pause button

### Gameplay area

- Full screen space background
- Ship near lower half
- Objects spawn from top

### UI style

- Futuristic but readable
- White/cyan text with glow/shadow
- Avoid clutter

---

## 9.3 Game Over Screen

### Trigger

Shown after asteroid collision.

### Content

- `Game Over`
- Final score
- Best score
- Optional performance label:
  - `Rookie Miner`
  - `Crystal Chaser`
  - `Meteor Dodger`
  - `Legendary Harvester`
- Primary button: `Play Again`
- Secondary button: `Main Menu`

### Visual treatment

- Dark translucent overlay
- Explosion glow behind text
- Score count-up animation
- Button scale/hover animation

---

## 10. Visual Style

## 10.1 Art Direction

Style: bright arcade sci-fi.

Mood:

- Energetic
- Clean
- Colorful
- Slightly cute, not gritty
- Polished mobile-game feel

### Color palette

Recommended colors:

- Deep navy / black space background
- Cyan ship glow
- Purple nebula accents
- Blue crystals
- Gold rare crystals
- Orange asteroid explosion
- White UI text

### Visual priority

The most important thing is contrast:

- Ship must stand out.
- Crystals must look desirable.
- Asteroids must look dangerous.
- UI must be readable.

---

## 11. Animation and Polish Requirements

This section is critical. The game should feel highly polished even if the mechanics are simple.

## 11.1 Ship polish

Required:

- Smooth movement interpolation
- Subtle ship tilt based on horizontal velocity
- Engine flame animation
- Engine particle trail
- Tiny idle bob when not moving
- Collection flash or pulse

Optional:

- Shield shimmer when shield power-up is active
- Speed streaks when moving fast

---

## 11.2 Crystal polish

Required:

- Continuous slow rotation
- Scale pulse
- Glow aura
- Sparkle particles
- Collection burst
- Floating score text

Optional:

- Fragment shader shimmer
- Color shift over time
- Rare crystals emit stronger glow

---

## 11.3 Asteroid polish

Required:

- Random rotation speed
- Slight scale variation
- Dust particles or small trailing debris
- Impact explosion

Optional:

- Asteroid cracks glow before collision
- Large asteroid breaks into fragments on game over
- Subtle shadow or rim light

---

## 11.4 Camera and screen polish

Required:

- Small screen shake on asteroid impact
- Tiny shake or bump on rare crystal collection
- Background parallax

Optional:

- Brief slow-motion on crash
- Chromatic aberration style shader during game over
- Vignette shader around screen edges

---

## 11.5 UI polish

Required:

- Score pop animation on increase
- Game over overlay fades in
- Buttons scale slightly on hover/tap
- Title glow/pulse

Optional:

- Score count-up animation on game over
- Animated gradient title text
- Best score celebration if new record

---

## 12. Custom Fragment Shaders

Custom fragment shaders are optional but strongly recommended because they make the demo feel advanced.

Use shaders only where they are safe and additive. The game should still work without them.

## 12.1 Nebula Background Shader

### Purpose

Create a moving space nebula background without needing a large image.

### Visual

- Soft purple/blue cloud movement
- Slow time-based animation
- Subtle noise texture look
- Low opacity so gameplay remains readable

### Implementation notes

- Add shader file: `assets/shaders/nebula.frag`
- Pass time uniform
- Render behind all gameplay objects
- Keep performance lightweight

### Acceptance criteria

- Background animates slowly.
- It does not distract.
- It gives the game a premium feel.

---

## 12.2 Crystal Shimmer Shader

### Purpose

Make crystals look valuable and alive.

### Visual

- Diagonal shimmer sweep
- Bright highlight moving across crystal
- Gentle glow pulse

### Implementation notes

- Add shader file: `assets/shaders/crystal_shimmer.frag`
- Apply to crystal sprite or custom painted crystal component
- Fall back to regular sprite if shader fails

### Acceptance criteria

- Crystals are visually distinct from asteroids.
- Shimmer is noticeable but not overpowering.

---

## 12.3 Warp Speed Background Shader

### Purpose

Increase intensity as score/difficulty rises.

### Visual

- Streaking star lines
- Speed increases with difficulty
- Can activate briefly after combos

### Implementation notes

- Add shader file: `assets/shaders/warp_stars.frag`
- Pass time and difficulty uniforms
- Use lightly during gameplay or as an overlay

### Acceptance criteria

- Game feels faster over time.
- Shader does not reduce readability.

---

## 12.4 Impact Shockwave Shader

### Purpose

Make asteroid collision feel impressive.

### Visual

- Circular shockwave expands from explosion point
- Brief distortion/ripple
- Fades out quickly

### Implementation notes

- Add shader file: `assets/shaders/shockwave.frag`
- Trigger on crash
- Pass explosion center, time, radius, intensity

### Acceptance criteria

- Crash feels dramatic.
- Effect lasts less than 1 second.

---

## 13. Asset List and Generation Prompts

All image assets should be generated as transparent PNGs unless noted.

Recommended style for all assets:

> Bright arcade sci-fi mobile game art, clean readable shapes, high contrast, polished casual game style, slightly cute, not realistic, transparent background, centered object, no text, no watermark.

---

## 13.1 Player Ship Sprite

### File

`assets/images/ship_miner.png`

### Size

512x512 source, displayed around 64x64.

### Prompt

> Create a small futuristic crystal-mining spaceship for a polished mobile arcade game. The ship should be compact, readable from a top-down or slightly angled view, with a bright cyan cockpit glow, small mining arms or side pods, blue engine lights, and a friendly sci-fi style. Use clean shapes, high contrast, and a transparent background. No text, no watermark.

---

## 13.2 Ship Engine Flame

### File

`assets/images/ship_engine_flame.png`

### Prompt

> Create a stylized blue-cyan spaceship engine flame for a mobile arcade game. It should be a small glowing flame plume, bright at the center, fading outward, designed to sit behind a spaceship sprite. Transparent background. No text, no watermark.

---

## 13.3 Common Crystal

### File

`assets/images/crystal_blue.png`

### Prompt

> Create a glowing blue energy crystal collectible for a polished mobile arcade space game. The crystal should be faceted, bright cyan-blue, readable at small size, with a soft outer glow and transparent background. Make it look valuable and satisfying to collect. No text, no watermark.

---

## 13.4 Rare Crystal

### File

`assets/images/crystal_purple.png`

### Prompt

> Create a rare purple energy crystal collectible for a polished mobile arcade space game. It should be faceted, magical, bright violet with pink highlights, soft glow, readable at small size, transparent background. No text, no watermark.

---

## 13.5 Golden Crystal

### File

`assets/images/crystal_gold.png`

### Prompt

> Create a legendary golden energy crystal collectible for a polished mobile arcade space game. The crystal should be faceted, bright gold and amber, with a premium glow and sparkle highlights. It must be readable at small size and have a transparent background. No text, no watermark.

---

## 13.6 Small Asteroid

### File

`assets/images/asteroid_small.png`

### Prompt

> Create a small rocky asteroid hazard for a polished mobile arcade space game. It should have an irregular silhouette, dark gray rock with subtle orange cracks, readable at small size, slightly stylized, high contrast, transparent background. No text, no watermark.

---

## 13.7 Medium Asteroid

### File

`assets/images/asteroid_medium.png`

### Prompt

> Create a medium-sized rocky asteroid hazard for a polished mobile arcade space game. The asteroid should look dangerous but stylized, with jagged edges, dark gray and brown rock, subtle glowing orange cracks, and transparent background. No text, no watermark.

---

## 13.8 Large Asteroid

### File

`assets/images/asteroid_large.png`

### Prompt

> Create a large dramatic asteroid hazard for a polished mobile arcade space game. The asteroid should have an irregular rocky shape, dark gray surface, crater details, glowing lava-like orange cracks, strong silhouette, and transparent background. No text, no watermark.

---

## 13.9 Explosion Particle

### File

`assets/images/particle_explosion.png`

### Prompt

> Create a small glowing explosion particle for a mobile arcade space game. It should be a bright orange-yellow spark or ember, circular/soft shape, designed for particle effects, transparent background. No text, no watermark.

---

## 13.10 Crystal Sparkle Particle

### File

`assets/images/particle_sparkle_blue.png`

### Prompt

> Create a tiny blue-white sparkle particle for collecting crystals in a mobile arcade game. It should be a small starburst glint with a soft cyan glow, transparent background. No text, no watermark.

---

## 13.11 Engine Trail Particle

### File

`assets/images/particle_engine_cyan.png`

### Prompt

> Create a small soft cyan-blue glowing particle for a spaceship engine trail in a mobile arcade game. It should be circular, bright center, soft fade edges, transparent background. No text, no watermark.

---

## 13.12 Background Nebula Image

### File

`assets/images/background_nebula.png`

### Size

1080x1920 or larger.

### Prompt

> Create a vertical mobile game space background with a deep navy-black starfield and subtle purple-blue nebula clouds. It should be atmospheric but not too bright, leaving room for readable gameplay objects. Polished sci-fi arcade style. No planets, no text, no watermark.

---

## 13.13 Far Star Layer

### File

`assets/images/stars_far.png`

### Prompt

> Create a transparent vertical layer of tiny white distant stars for a mobile space game. Sparse distribution, subtle brightness variation, transparent background, no text, no watermark.

---

## 13.14 Mid Star Layer

### File

`assets/images/stars_mid.png`

### Prompt

> Create a transparent vertical layer of medium-sized white and pale-blue stars for a mobile space game. Moderate distribution, subtle glow, transparent background, no text, no watermark.

---

## 13.15 Title Logo

### File

`assets/images/logo_meteor_harvest.png`

### Prompt

> Create a polished game title logo that says “Meteor Harvest” in a futuristic arcade sci-fi style. Use glowing cyan, blue, and purple accents with a subtle crystal/meteor theme. Transparent background. Make the text highly readable for a mobile game title screen. No watermark.

---

## 13.16 App Icon

### File

`assets/images/app_icon.png`

### Prompt

> Create a mobile game app icon for “Meteor Harvest.” The icon should show a small mining spaceship dodging a fiery asteroid while collecting a glowing blue crystal. Bright arcade sci-fi style, high contrast, polished, readable at small size, no text, no watermark.

---

## 13.17 Shield Power-Up

### File

`assets/images/powerup_shield.png`

### Prompt

> Create a glowing blue shield power-up orb for a polished mobile arcade space game. It should look protective, circular, with a cyan energy ring and transparent background. No text, no watermark.

---

## 13.18 Magnet Power-Up

### File

`assets/images/powerup_magnet.png`

### Prompt

> Create a purple magnet power-up icon for a polished mobile arcade space game. It should look like an energy magnet that attracts crystals, with violet glow, clean readable shape, transparent background. No text, no watermark.

---

## 13.19 Time Warp Power-Up

### File

`assets/images/powerup_time_warp.png`

### Prompt

> Create a green time-warp power-up orb for a polished mobile arcade space game. It should feel like slow motion or time energy, with circular swirl lines, bright green glow, transparent background. No text, no watermark.

---

## 14. Audio Asset List and Generation Prompts

Audio is optional for the live demo but strongly improves perceived polish.

## 14.1 Background Music Loop

### File

`assets/audio/music_space_arcade_loop.mp3`

### Prompt

> Create a short seamless looping background music track for a polished mobile arcade space game. Style: upbeat synthwave, energetic but not distracting, sci-fi adventure mood, 90–110 BPM, clean loop, 30–60 seconds.

---

## 14.2 Crystal Collect Sound

### File

`assets/audio/sfx_crystal_collect.mp3`

### Prompt

> Create a short satisfying crystal collection sound effect for a mobile arcade game. It should be bright, sparkly, magical, and positive. Duration under 0.5 seconds.

---

## 14.3 Rare Crystal Collect Sound

### File

`assets/audio/sfx_rare_collect.mp3`

### Prompt

> Create a premium rare-item collection sound effect for a mobile arcade game. It should sound magical, sparkly, and rewarding, with a quick upward chime. Duration under 1 second.

---

## 14.4 Explosion Sound

### File

`assets/audio/sfx_explosion.mp3`

### Prompt

> Create a short arcade spaceship explosion sound effect. It should be punchy, dramatic, and not too harsh. Duration under 1 second.

---

## 14.5 Button Tap Sound

### File

`assets/audio/sfx_button_tap.mp3`

### Prompt

> Create a clean futuristic UI button tap sound for a sci-fi mobile game. Short, soft, responsive, duration under 0.3 seconds.

---

## 14.6 New Best Score Sound

### File

`assets/audio/sfx_new_best.mp3`

### Prompt

> Create a celebratory new high score sound effect for a mobile arcade game. It should be short, exciting, sparkly, and positive, duration under 1.5 seconds.

---

## 15. Technical Architecture

## 15.1 Recommended packages

Use:

- `flame`
- `flame_audio`
- `shared_preferences`
- `flutter/services.dart` for shader loading if needed

Optional:

- `flutter_animate` for menu/UI animation outside Flame

---

## 15.2 Suggested file structure

```text
lib/
  main.dart
  game/
    meteor_harvest_game.dart
    components/
      player_ship.dart
      asteroid.dart
      crystal.dart
      scrolling_starfield.dart
      floating_score_text.dart
      explosion_effect.dart
      engine_trail.dart
      powerup.dart
    systems/
      spawn_system.dart
      difficulty_system.dart
      score_system.dart
      audio_system.dart
    overlays/
      title_overlay.dart
      hud_overlay.dart
      game_over_overlay.dart
    shaders/
      nebula_background_component.dart
      crystal_shimmer_component.dart
      shockwave_component.dart
  theme/
    app_theme.dart
assets/
  images/
  audio/
  shaders/
```

---

## 15.3 Game states

Use a clear enum:

```dart
enum MeteorHarvestState {
  title,
  playing,
  gameOver,
  paused,
}
```

### State behavior

| State | Behavior |
|---|---|
| title | Background animates, no hazards, start button visible |
| playing | Spawning, collisions, movement, scoring active |
| gameOver | Gameplay stopped, overlay visible, restart available |
| paused | Gameplay stopped, pause overlay visible |

---

## 15.4 Core components

### MeteorHarvestGame

Responsibilities:

- Load assets
- Manage game state
- Add/remove components
- Start runs
- End runs
- Restart runs
- Store score and best score
- Coordinate overlays

### PlayerShip

Responsibilities:

- Input target tracking
- Smooth movement
- Screen bounds clamping
- Tilt animation
- Engine trail emission
- Collision detection

### Crystal

Responsibilities:

- Drift movement
- Rotation/pulse animation
- Collision with player
- Collection effects

### Asteroid

Responsibilities:

- Drift movement
- Rotation
- Collision with player
- Offscreen cleanup

### SpawnSystem

Responsibilities:

- Spawn crystals
- Spawn asteroids
- Apply difficulty values
- Avoid unfair spawn patterns where feasible

### ScoreSystem

Responsibilities:

- Current score
- Best score
- Combo tracking
- Score events
- SharedPreferences persistence

---

## 16. Implementation Details

## 16.1 Game initialization

On launch:

1. Load image assets.
2. Load audio assets if present.
3. Load best score from local storage.
4. Show title overlay.
5. Start animated background.

---

## 16.2 Start run

When player taps `Start Run`:

1. Set state to `playing`.
2. Reset score.
3. Reset difficulty.
4. Clear old asteroids/crystals/effects.
5. Add player ship.
6. Start spawn timers.
7. Show HUD overlay.

---

## 16.3 End run

When player collides with asteroid:

1. Set state to `gameOver`.
2. Stop spawning.
3. Trigger explosion.
4. Trigger screen shake.
5. Hide player ship.
6. Save best score if needed.
7. Show game over overlay.
8. Play explosion/new-best audio as appropriate.

---

## 16.4 Restart run

When player taps `Play Again`:

1. Clear all gameplay objects.
2. Reset score and difficulty.
3. Add player ship.
4. Set state to `playing`.
5. Resume spawning.

---

## 17. Acceptance Criteria

The game is ready for the meetup demo when all of these are true:

### Core gameplay

- Player can start a run.
- Player can move ship with touch/mouse.
- Crystals spawn and can be collected.
- Asteroids spawn and cause game over.
- Score increases when crystals are collected.
- Final score appears on game over.
- Player can restart.

### Polish

- Background is animated.
- Ship has engine trail.
- Crystals glow/pulse or sparkle.
- Collection effect appears.
- Asteroid impact creates explosion.
- Screen shake occurs on crash.
- UI looks intentional and polished.

### Stability

- No Flutter analyzer errors.
- No crashes during a 2-minute play session.
- Offscreen objects are removed.
- Game can restart repeatedly without duplicating components or leaking state.

---

## 18. Testing Checklist

### Manual gameplay testing

- Start game from title screen.
- Move ship in all directions.
- Confirm ship stays inside screen bounds.
- Collect at least 10 crystals.
- Confirm score updates correctly.
- Hit asteroid and verify game over.
- Restart and confirm score resets.
- Confirm best score persists after app restart.
- Confirm no objects remain stuck after restart.

### Visual testing

- Confirm ship is readable over background.
- Confirm crystals are easy to distinguish from asteroids.
- Confirm UI is readable on small screens.
- Confirm effects do not obscure gameplay.
- Confirm game over overlay is readable.

### Performance testing

- Play for 2 minutes.
- Confirm no slowdown from particles.
- Confirm offscreen asteroids/crystals are removed.
- Confirm shader effects do not break on target platform.

---

## 19. AI Agent Build Plan

Use this section directly with Antigravity + Gemini.

### Prompt 1 — Project setup

> Create a new Flutter game called Meteor Harvest using Flame. Set up the project structure from the specification. Add the required folders for game components, systems, overlays, assets, audio, and shaders. Configure pubspec.yaml for Flame, Flame Audio, SharedPreferences, image assets, audio assets, and shader assets. Do not implement gameplay yet. Run flutter analyze and fix all issues.

### Prompt 2 — Core game shell

> Implement MeteorHarvestGame with game states: title, playing, paused, and gameOver. Add a GameWidget in main.dart. Create basic overlays for title, HUD, and game over. The title overlay should have the game title and Start Run button. The game over overlay should show final score, best score, Play Again, and Main Menu. Use clean Material 3 styling. Run flutter analyze and fix all issues.

### Prompt 3 — Background

> Implement an animated space background for Meteor Harvest. Use parallax star layers and the background nebula image if available. The background should animate even on the title screen. Keep it performant and visually readable. Add fallback generated stars if image assets are missing. Run flutter analyze and fix all issues.

### Prompt 4 — Player ship movement

> Implement the PlayerShip component. The ship should start near the bottom center, move smoothly toward touch/mouse input, support keyboard movement on desktop, stay inside screen bounds, tilt slightly based on horizontal velocity, and emit a cyan engine trail. Use a forgiving circular hitbox. Run flutter analyze and fix all issues.

### Prompt 5 — Crystals

> Implement collectible Energy Crystal components. Crystals should spawn from the top, drift downward with slight wobble, rotate, pulse/glow, collide with the player, increase score, show floating +10 text, play a collection effect, and remove themselves when collected or offscreen. Run flutter analyze and fix all issues.

### Prompt 6 — Asteroids

> Implement Asteroid hazard components. Asteroids should spawn from the top, have random sizes, speeds, rotation, and horizontal drift. They should collide with the player using forgiving circular hitboxes. On collision, trigger game over, explosion particles, and screen shake. Run flutter analyze and fix all issues.

### Prompt 7 — Spawning and difficulty

> Implement SpawnSystem and DifficultySystem. Crystals and asteroids should spawn on timers. Difficulty should increase every 10 seconds by increasing asteroid spawn rate and asteroid speed. Avoid impossible spawn patterns when possible. Clean up offscreen objects. Run flutter analyze and fix all issues.

### Prompt 8 — Score and best score

> Implement ScoreSystem. Score increases from crystals and survival time. Save best score using SharedPreferences. Add HUD score pop animation when score changes. On game over, show final score and best score. If the player gets a new best score, show a visual celebration and play optional sound. Run flutter analyze and fix all issues.

### Prompt 9 — Polish pass

> Add a polish pass to Meteor Harvest. Add collection sparkle bursts, explosion particles, screen shake, ship collection flash, button tap animation, title glow, game over fade-in, and score count-up animation. Keep effects performant. Run flutter analyze and fix all issues.

### Prompt 10 — Shader pass

> Add optional custom fragment shader support for the nebula background, crystal shimmer, warp star overlay, and crash shockwave. The game must gracefully fall back if shaders are unavailable. Use time uniforms and keep shader effects subtle. Run flutter analyze and fix all issues.

### Prompt 11 — Final demo cleanup

> Review the full Meteor Harvest game for demo readiness. Fix bugs, simplify anything fragile, ensure repeated restart works, improve comments where helpful, verify assets load correctly, verify no analyzer errors, and produce a short README explaining how to run the game and what features were built.

---

## 20. Scope Control

For the meetup, do not let the AI agent overbuild.

### Must-have

- Start screen
- Ship movement
- Crystals
- Asteroids
- Score
- Game over
- Restart
- Particles
- Animated background

### Should-have

- Best score
- Engine trail
- Screen shake
- Score pop animation
- Crystal glow
- Game over fade

### Could-have

- Rare crystals
- Combo system
- Power-ups
- Shaders
- Audio
- New best celebration

### Do not build for the demo

- Accounts
- Leaderboards
- In-app purchases
- Level editor
- Multiplayer
- Ads
- Backend
- Complex progression

---

## 21. Product Manager Notes

Meteor Harvest should succeed because it demonstrates the most important AI-agent lesson:  
**A clear spec plus small implementation prompts produces a better result than vague instructions.**

The game is intentionally simple, but the polish makes it impressive. During the meetup, highlight how each prompt narrows the AI agent’s job:

- First create structure.
- Then build one system at a time.
- Then test.
- Then polish.
- Then optionally add shaders.

This makes the demo useful even for people who do not care about games, because the workflow applies to any Flutter product.

---

## 22. Open Decisions

These can be decided before the meetup, but the default choices are good enough to proceed.

1. **Orientation:** Default to portrait mobile.
2. **Art style:** Default to bright arcade sci-fi.
3. **Engine:** Default to Flutter + Flame.
4. **Input:** Default to touch/mouse follow plus keyboard support.
5. **Audio:** Recommended, but optional for live build.
6. **Shaders:** Recommended as stretch goal or prebuilt enhancement.
7. **Power-ups:** Stretch goal only.

---

## 23. Recommended Pre-Meetup Prep

Before the meetup:

1. Generate all required image assets.
2. Generate at least three sound effects:
   - crystal collect
   - explosion
   - button tap
3. Test that assets load in a blank Flutter project.
4. Prepare shader files if using them.
5. Prepare the AI agent prompts in order.
6. Prepare a fallback branch with a working version in case the live demo hits issues.
7. Prepare a short talking outline explaining why the prompts are structured the way they are.

---

## 24. Final Product Summary

Meteor Harvest is a simple arcade space game where players collect glowing crystals while dodging asteroids. The game is intentionally small enough to build quickly, but designed with enough polish — particles, animation, parallax, shaders, score feedback, and dramatic crashes — to feel impressive in a live Flutter + AI coding demo.

The result should be fun, readable, visually exciting, and a strong demonstration of how Antigravity + Gemini can help developers move from product idea to playable game quickly.
