# Meteor Harvest ☄️💎

A polished, fast-paced vertical arcade game built using **Flutter** and the **Flame** engine. Pilot a mining vessel through an active meteor field, harvest valuable energy crystals, dodge floating debris, and survive the escalating intensity!

---

## 🎮 Game Rules & Objective

- **Objective:** Collect as many energy crystals as possible without colliding with incoming asteroids.
- **Controls:**
  - **Mobile/Touch:** Drag or tap anywhere on the screen. The ship will smoothly ease toward your finger position with realistic inertia.
  - **Desktop/Keyboard:** Use **W/A/S/D** or the **Arrow Keys** to steer the ship.
- **Scoring:**
  - **Common Blue Crystal:** +10 points
  - **Rare Purple Crystal:** +50 points
  - **Legendary Golden Crystal:** +100 points
  - **Survival:** +1 point per second of survival.
  - **Combo Multiplier:** Harvest crystals in quick succession (under 2 seconds) to build up multipliers (+2, +5, +8, or +10 points per collect).
- **Difficulty Curve:**
  - Every **10 seconds**, the meteor field becomes denser and faster:
    - **0–10s:** Safe intro, slow asteroids.
    - **10–20s:** Moderate density, medium speeds.
    - **20–40s:** Arcade challenge, medium-fast speeds.
    - **40s+:** High-intensity storm, fast asteroids.

---

## 💎 Features & Visual Polish

- **Parallax Starfield:** Multiple layers of stars scroll at varying speeds to create a sense of forward velocity.
- **Custom Shaders:** An animated fragment shader renders a shifting nebula background with glowing gaseous clouds.
- **Responsive Easing:** Controls use exponential decay interpolation for smooth ship movement instead of instant teleports.
- **Visual Banking:** The ship tilts dynamically left and right depending on horizontal movement speed.
- **Engine Particles:** A continuous particle emitter spawns a glowing trail behind the ship's engine.
- **Floating Indicators:** Point rewards (+10, +50, etc.) pop up on collection and drift upwards while fading.
- **Juicy Screen Shake:** Colliding with asteroids triggers a viewport vibration effect.
- **Particle Explosions:** Crashes spawn a realistic burst of fiery orange and yellow debris.
- **High-Score Persistence:** Uses `SharedPreferences` to save and display your best runs.
- **celebratory SFX:** Distinct chimes for collections, rare milestones, record breaks, and crashes.

---

## 📁 Project Architecture

All source code is located in `lib/`:

```text
lib/
  main.dart                              # Application setup, orientation settings, immersive full-screen
  theme/
    app_theme.dart                       # Space palette (cyan, violet, gold) and text styles
  game/
    meteor_harvest_game.dart             # Core coordinator, state machine (Title, Playing, GameOver)
    components/
      scrolling_starfield.dart           # Parallax star layer component
      player_ship.dart                   # Mining ship controller, input ease, tilt, engine flame trail
      crystal.dart                       # Wobbling collectibles, sparkle bursts, collection logic
      asteroid.dart                      # Small/Medium/Large obstacles, explosion physics, camera shake
      floating_text.dart                 # Floating collection indicator (+10)
    systems/
      spawn_system.dart                  # Spawns crystals & asteroids; manages difficulty ramping
    overlays/
      title_overlay.dart                 # Main menu with start run button
      hud_overlay.dart                   # Score tracker, high score, and combo pop scale anim
      game_over_overlay.dart             # Statistics page, rank labels, restart button
    shaders/
      nebula_shader_component.dart       # compiled GLSL fragment shader renderer
```

---

## 🚀 Running the Game

To launch the project locally:

1. Ensure you have the Flutter SDK installed (`^3.11.4` or newer).
2. Clone the repository and fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
