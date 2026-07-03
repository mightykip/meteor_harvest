#!/usr/bin/env python3
"""
Sprite processing script to remove solid black backgrounds and convert them
to true alpha transparency, preserving soft outer glows, anti-aliased edges,
and particle effects. Optionally makes the interior of the sprite fully opaque.
"""

import os
import sys
from PIL import Image

def process_sprite(src_path, dest_path, target_size=(1024, 1024), fill_ratio=0.85, crop_and_center=True, make_solid=False):
    print(f"Processing image: {src_path} -> {dest_path}")
    print(f"Parameters: size={target_size}, fill_ratio={fill_ratio}, crop_and_center={crop_and_center}, make_solid={make_solid}")
    
    # Load source image and ensure RGBA mode
    img = Image.open(src_path).convert("RGBA")
    width, height = img.size
    pixels = list(img.getdata())
    
    new_pixels = []
    bg_threshold = 5  # Black noise threshold
    solid_threshold = 45  # Threshold below which pixels are considered background/glow
    
    # If make_solid is True, we run a flood fill to find the outer background/glow area
    is_bg = None
    if make_solid:
        # Determine which pixels are potential background/glow (brightness < solid_threshold)
        bg_mask = [[False for _ in range(width)] for _ in range(height)]
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[y * width + x]
                if max(r, g, b) < solid_threshold:
                    bg_mask[y][x] = True
                    
        # Flood fill from the edges to find reachable background
        queue = []
        is_bg = [[False for _ in range(width)] for _ in range(height)]
        
        # Push border pixels
        for x in range(width):
            if bg_mask[0][x]:
                is_bg[0][x] = True
                queue.append((x, 0))
            if bg_mask[height - 1][x]:
                is_bg[height - 1][x] = True
                queue.append((x, height - 1))
        for y in range(1, height - 1):
            if bg_mask[y][0]:
                is_bg[y][0] = True
                queue.append((0, y))
            if bg_mask[y][width - 1]:
                is_bg[y][width - 1] = True
                queue.append((width - 1, y))
                
        idx = 0
        while idx < len(queue):
            cx, cy = queue[idx]
            idx += 1
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = cx + dx, cy + dy
                if 0 <= nx < width and 0 <= ny < height:
                    if not is_bg[ny][nx] and bg_mask[ny][nx]:
                        is_bg[ny][nx] = True
                        queue.append((nx, ny))

    # Bounding box trackers
    min_x, min_y = width, height
    max_x, max_y = -1, -1
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[y * width + x]
            val = max(r, g, b)
            
            # Determine if this pixel is part of the solid interior or outer background/glow
            if make_solid and not is_bg[y][x]:
                # Deep inside the object: force full opacity
                new_alpha = 255
                new_r, new_g, new_b = int(r), int(g), int(b)
            else:
                # Background or outer glow: calculate alpha normally
                if val < bg_threshold:
                    new_alpha = 0
                    new_r, new_g, new_b = 0, 0, 0
                else:
                    new_alpha = int(255 * (val - bg_threshold) / (255 - bg_threshold))
                    if new_alpha > 0:
                        denom = new_alpha / 255.0
                        new_r = min(255, int(r / denom))
                        new_g = min(255, int(g / denom))
                        new_b = min(255, int(b / denom))
                    else:
                        new_r, new_g, new_b = 0, 0, 0
            
            if new_alpha > 0:
                # Update bounding box of non-transparent content
                if x < min_x: min_x = x
                if y < min_y: min_y = y
                if x > max_x: max_x = x
                if y > max_y: max_y = y
                
            new_pixels.append((new_r, new_g, new_b, new_alpha))
            
    # Create new image with processed pixels
    processed_img = Image.new("RGBA", (width, height))
    processed_img.putdata(new_pixels)
    
    if not crop_and_center:
        if processed_img.size != target_size:
            processed_img = processed_img.resize(target_size, Image.Resampling.LANCZOS)
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        processed_img.save(dest_path, "PNG")
        print(f"Successfully processed without cropping and saved to {dest_path}")
        return True

    if max_x < min_x or max_y < min_y:
        print("Error: Image is entirely transparent!")
        return False
        
    # Crop to bounding box of content
    bbox = (min_x, min_y, max_x + 1, max_y + 1)
    cropped_img = processed_img.crop(bbox)
    cropped_w, cropped_h = cropped_img.size
    
    # Calculate scale to fit the target size while maintaining aspect ratio
    target_w, target_h = target_size
    max_w = int(target_w * fill_ratio)
    max_h = int(target_h * fill_ratio)
    
    scale = min(max_w / cropped_w, max_h / cropped_h)
    new_w = int(cropped_w * scale)
    new_h = int(cropped_h * scale)
    
    resized_img = cropped_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Create new canvas with transparent background
    canvas = Image.new("RGBA", target_size, (0, 0, 0, 0))
    
    # Paste resized image into the center of the canvas
    paste_x = (target_w - new_w) // 2
    paste_y = (target_h - new_h) // 2
    canvas.paste(resized_img, (paste_x, paste_y), resized_img)
    
    # Save processed image
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    canvas.save(dest_path, "PNG")
    print(f"Successfully processed and saved to {dest_path}")
    return True

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Convert solid black background to alpha transparent PNG.")
    parser.add_argument("src", help="Path to source image (with black background)")
    parser.add_argument("dest", help="Path to destination processed PNG")
    parser.add_argument("--no-crop", action="store_true", help="Do not crop or scale the image; keep the source layout.")
    parser.add_argument("--solid", action="store_true", help="Make the interior of the sprite fully opaque.")
    args = parser.parse_args()
    
    process_sprite(args.src, args.dest, crop_and_center=not args.no_crop, make_solid=args.solid)
