# Meteor Harvest ☄️🌾

A polished, fast-paced space arcade game built using **Flutter** and the **Flame engine**. 

This repository was created as a live demonstration for the [Utah Flutter Meetup](https://www.meetup.com/utah-flutter/) to showcase the power and workflow of AI-assisted software development using **Antigravity + Gemini**.

---

## 🎯 Project Goals

1. **AI-Assisted Development Demo**: Show how a developer pairing with an AI coding assistant (Antigravity) can take a detailed functional specification, generate assets, implement game loops, write test suites, and polish gameplay features in a short timeframe (approx. 1 hour).
2. **Polished Gameplay Mechanics**: Build a simple game loop that feels immediately satisfying with smooth movement, particle effects, satisfying sprite animations, score popups, and weight-based collision.
3. **Multi-Platform Support**: Leverage Flutter's multi-platform capabilities to build and run seamlessly on Mobile (iOS/Android), Web, and Desktop.

---

## 🚀 Why It Was Made

This project was built live during a presentation for the [Utah Flutter Meetup Group](https://www.meetup.com/utah-flutter/). 

The session focused on:
- Utilizing LLM agents (Antigravity) for automated asset generation (such as ship, crystal, and asteroid sprites).
- Architecting a standard Flame game loop with game state management in Flutter.
- Iterative polishing of visual and interactive components to elevate a basic game mechanic to a premium-feeling experience.

---

## 🛠️ Features Built

During the live coding demonstration, we successfully implemented:

* **Parallax Scrolling Background**: Implemented using Flame's `ParallaxComponent` to scroll background nebula, far stars, and mid stars at varying speeds. Includes a fully functional procedural canvas star drawing fallback.
* **Fluid Inertial Spaceship Movement**: Programmed ship flight controls with inertia, tilt leaning animations, screen boundary clamping, and dynamic exhaust flame scaling.
* **Particle Exhaust Trails**: Attached a continuous particle exhaust emitter generating cyan trailing flames from the ship's engine nozzle.
* **Blue Crystals & Score Pops**: Added collectible energy crystals that pulsate in size, wobble sinusoidally, spawn floating "+10" text pops, trigger blue starburst sparkles on contact, and play audio chimes.
* **Asteroid Hazards & Camera Screen Shake**: Designed small, medium, and large asteroid hazards with forgiving circular hitboxes. Crashing triggers viewport screen shake and plays a custom explosion audio cue with orange debris sparks.
* **Dynamic Difficulty Engine**: Implemented `DifficultySystem` that scales asteroid spawn intervals, velocities, and size distributions every 10 seconds.
* **Procedural Spawner with Fairness Spacing**: Created `SpawnSystem` to coordinate crystal and asteroid timers, using horizontal coordinate spacing guards to guarantee navigable pathways and avoid impossible walls.
* **Arcade Score Tracking**: Added a `ScoreSystem` that rewards 1 point per second of survival alongside crystal points. Persists the high score locally via `SharedPreferences`.
* **New Record Celebration**: Plays a distinct celebration chime (`sfx_new_best.mp3`) and overlays a glowing, golden "NEW HIGH SCORE!" banner on the game over screen when the previous high score is beaten.
* **HUD Score Scale Pops**: Added stateful `AnimatedScoreText` to the top-left HUD which scales up to `1.25x` for a tactile "pop" feedback whenever the score increases.
* **UI Polish & Button Tap Scale Animations**: Implemented a responsive button scaling widget (`ScaleButton`) that shrinks on click, a smooth fade-in overlay for game over, and a cubic score count-up text effect.
* **Fragment Shaders Pass**: Integrated 4 custom fragment shaders (`nebula.frag`, `crystal_shimmer.frag`, `warp_stars.frag`, and `shockwave.frag`) to create premium, GPU-accelerated visuals for nebula gas clouds, crystal sheens, warp-speed star overlay, and impact shockwaves.

---

## 🎮 How to Play & Controls

### Objective
Pilot your mining ship through a dense meteor field, collecting glowing **energy crystals** to increase your score while dodging dangerous drifting **asteroids**. Survive as long as you can!

### Controls
The game dynamically supports multiple input configurations:

* **Mobile (Touch/Drag)**: Tap and drag anywhere on the screen to steer the ship. The ship will smoothly ease toward your finger.
* **Desktop/Web (Mouse/Keyboard)**:
  * **Mouse**: Click and drag/move to guide the ship.
  * **Keyboard**: Use **Arrow keys** or **WASD** to fly in all directions.

---

## 🛠️ Getting Started & How to Use

### Prerequisites
Make sure you have the Flutter SDK installed on your system.
* Check your Flutter installation:
  ```bash
  flutter doctor
  ```

### Steps to Run the Project

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd meteor_harvest
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   * To run on your default connected device/emulator:
     ```bash
     flutter run
     ```
   * To run in Chrome/Web:
     ```bash
     flutter run -d chrome
     ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 Kip Lawrence

---

*Made with ❤️ for the Utah Flutter community. Happy harvesting!*
