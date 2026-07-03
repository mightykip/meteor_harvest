# Custom Fragment Shaders Directory

This directory contains custom fragment shader files (`.frag`) for **Meteor Harvest** that provide advanced visual polish. In Flutter, Flame uses standard GLSL fragment shaders to run on the GPU.

## Shaders Checklist & Implementation Details

All shaders should be loaded asynchronously during game initialization and fail gracefully (falling back to simple paints/sprites) if the platform or hardware does not support them.

---

### 1. Nebula Background Shader
*   **File:** `assets/shaders/nebula.frag`
*   **Purpose:** Renders a slowly shifting, animated cosmic nebula cloud background.
*   **Uniforms:**
    *   `uSize` (vec2) - Dimensions of the canvas/viewport.
    *   `uTime` (float) - Elapsed game time in seconds.
*   **Implementation Prompt:**
    ```text
    Write a GLSL fragment shader for a slow-moving cosmic space nebula. Use fractional Brownian motion (fBm) or simplex noise to generate layered clouds in purple and deep blue colors. The animation should be driven by a time uniform. Keep it performant by using 2-3 noise octaves, and output a low opacity/intensity so it remains subtle behind game objects.
    ```

---

### 2. Crystal Shimmer Shader
*   **File:** `assets/shaders/crystal_shimmer.frag`
*   **Purpose:** Adds a glowing, animated diagonal shimmer sweep effect to crystals.
*   **Uniforms:**
    *   `uSize` (vec2) - Texture bounds.
    *   `uTime` (float) - Elapsed game time in seconds.
    *   `uTexture` (sampler2D) - Crystal sprite image.
*   **Implementation Prompt:**
    ```text
    Write a GLSL fragment shader that applies a diagonal metallic sheen or bright shimmer line sweep across a sprite. The shimmer should sweep across the crystal image on a looping timer. Respect the sprite alpha channel (do not draw sheen over transparent pixels). Add a gentle overall glow pulse matching the crystal color (e.g., cyan/purple/gold).
    ```

---

### 3. Warp Speed Background Shader
*   **File:** `assets/shaders/warp_stars.frag`
*   **Purpose:** Renders streaking star lines that accelerate as game difficulty/score increases.
*   **Uniforms:**
    *   `uSize` (vec2) - Viewport dimensions.
    *   `uTime` (float) - Elapsed game time in seconds.
    *   `uSpeed` (float) - Travel speed multiplier (increases with game difficulty).
*   **Implementation Prompt:**
    ```text
    Write a GLSL fragment shader simulating a warp-speed star travel effect. Stars should stretch into radial or vertical streaks originating from a central point or moving downward. The speed and length of the streaks should scale with a speed uniform.
    ```

---

### 4. Impact Shockwave Shader
*   **File:** `assets/shaders/shockwave.frag`
*   **Purpose:** Displays a brief expanding circular distortion ripple from the asteroid crash center.
*   **Uniforms:**
    *   `uSize` (vec2) - Screen size.
    *   `uCenter` (vec2) - Coordinates of the explosion center.
    *   `uTime` (float) - Time elapsed since the crash.
    *   `uTexture` (sampler2D) - Capture of the active screen.
*   **Implementation Prompt:**
    ```text
    Write a GLSL fragment shader that creates a circular shockwave distortion ripple expanding outwards from a given center point. Use a time uniform to control the radius and fade out the distortion within 1 second. The shader should sample the screen texture and offset uv coordinates along the wave edge to create a refractive glass ripple look.
    ```
