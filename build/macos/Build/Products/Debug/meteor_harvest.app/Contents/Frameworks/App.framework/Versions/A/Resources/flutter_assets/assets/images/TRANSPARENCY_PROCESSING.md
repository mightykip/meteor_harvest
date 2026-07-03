# Transparency & Sprite Processing Guide

This guide explains how the game assets for **Meteor Harvest** were processed to remove solid black backgrounds and convert them into true alpha transparency. 

It also documents the use of the helper script [process_sprite.py](file:///Users/kiplawrence/meetup/meteor_harvest/assets/images/process_sprite.py).

---

## 1. Why Solid Backgrounds?

AI image generators (like Imagen, Midjourney, or DALL-E) frequently struggle with requests for a `"transparent background"`. Instead of actual alpha transparency, they often generate:
*   A fake gray-and-white **checkerboard pattern** rendered directly into the pixels.
*   Fuzzy **white/gray silhouettes** around the object.

To solve this, we generate sprites on a **solid black background** (e.g., using `isolated on a solid black background` in the prompt) and then use a mathematical un-blending script to extract a clean transparency layer.

---

## 2. The Un-blending Math (How it Works)

When a glowing or anti-aliased object is rendered on a solid black background, its color values are blended with the black.

For any pixel:
$$\text{Observed Color} = \text{Original Sprite Color} \times \text{Alpha}$$

Because the background is pure black $(0, 0, 0)$, we can mathematically reverse this blending process to extract the original color and its correct transparency:

1.  **Estimate Alpha**: We estimate the alpha transparency $A$ as the maximum intensity of the Red, Green, or Blue channels:
    $$A = \max(R, G, B) / 255.0$$
2.  **Filter Noise**: Image compression or generator anomalies can leave faint noise on the black background. We apply a threshold (e.g., intensity < 5 out of 255 is mapped to 0 alpha).
3.  **Un-blend Colors**: We divide the observed color channels by the estimated alpha to restore the original full-intensity color:
    $$\text{Original Color} = \frac{\text{Observed Color}}{\text{Alpha}}$$
    This prevents the sprite from looking dark or muddy when placed over lighter backgrounds in the game.

This approach perfectly preserves **translucent outer glows**, **fire plumes**, **electric sparkles**, and **smooth anti-aliased borders**.

---

## 3. Script Features

The [process_sprite.py](file:///Users/kiplawrence/meetup/meteor_harvest/assets/images/process_sprite.py) script performs:
1.  **Transparency Extraction**: Converts black pixels to transparent and un-blends glowing parts.
2.  **Bounding Box Detection**: Automatically detects the boundary of the visible object.
3.  **Cropping and Centering**: Crops out empty space, centers the object, and resizes it to fill a defined ratio (default: $85\%$) of the canvas.
4.  **No-Crop Mode**: Useful for parallax layers (like `stars_far.png` or `stars_mid.png`) where we want to remove the black background but preserve the exact spatial distribution of elements across the canvas.
5.  **Solid Interior Mode (`--solid`)**: Uses a flood-fill connectivity algorithm starting from the edges to find the boundary of the true background and outer glow. Any dark pixels inside the boundary (like creases, shadows, or metallic ship bodies) are automatically filled and kept $100\%$ opaque, avoiding inner transparency.

---

## 4. How to Use the Script

### Prerequisites
The script requires Python 3 and the **Pillow** image library.
```bash
pip3 install pillow
```

### Basic Command Structure
```bash
python3 process_sprite.py <path_to_source> <path_to_destination> [flags]
```

### Examples

#### 1. Processing a Standard Sprite (Crop & Center)
For characters, power-ups, collectibles, and projectiles, you want them centered and scaled to fill $85\%$ of the $1024 \times 1024$ canvas:
```bash
python3 process_sprite.py raw_shield_on_black.png powerup_shield.png
```

#### 2. Processing a Background Layer (No Cropping)
For stars or nebulas where the spatial distribution must remain exactly as generated:
```bash
python3 process_sprite.py raw_stars_on_black.png stars_far.png --no-crop
```

#### 3. Processing a Solid Sprite (Opaque Interior)
For hazard obstacles and spaceships where the interior body should be solid/opaque:
```bash
python3 process_sprite.py raw_asteroid_on_black.png asteroid_large.png --solid
```
