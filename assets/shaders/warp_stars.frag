#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uSpeed;

out vec4 fragColor;

// Pseudo-random hash function
float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

void main() {
    // Normalize coordinates relative to the component viewport size
    vec2 uv = FlutterFragCoord().xy / uSize;
    vec2 p = uv - vec2(0.5);
    
    // Correct aspect ratio to maintain radial symmetry
    p.x *= uSize.x / uSize.y;
    
    float dist = length(p);
    float angle = atan(p.y, p.x);
    
    // Divide the radial coordinate space into slice paths for stars
    float numSlices = 120.0;
    float slice = floor((angle + 3.14159265) / (2.0 * 3.14159265) * numSlices);
    
    // Generate unique random seed for this slice
    float id = hash(slice * 17.0);
    
    // Calculate star speed and initial position offsets based on slice ID
    float speedMult = 0.6 + 0.8 * hash(slice * 41.0);
    float starOffset = hash(slice * 83.0);
    
    // Track radial travel progress [0.0, 1.0] using time and speed uniforms
    float travel = uTime * 1.6 * uSpeed * speedMult + starOffset * 10.0;
    float cycle = fract(travel * 0.12);
    
    // Map cycle progress exponentially so stars accelerate as they move outward
    float starDist = pow(cycle, 2.0) * 1.5;
    
    // Streaks become longer at higher speeds and further out in the viewport
    float streakLength = 0.04 + 0.18 * uSpeed * starDist;
    
    float intensity = 0.0;
    if (dist > starDist - streakLength && dist < starDist) {
        // Linearly fade the star streak from bright head to thin, faded tail
        float factor = (dist - (starDist - streakLength)) / streakLength;
        intensity = smoothstep(0.0, 1.0, factor);
        
        // Calculate lateral offset from the center ray of the slice
        float angleOffset = (angle + 3.14159265) / (2.0 * 3.14159265) * numSlices - (slice + 0.5);
        float radOffset = angleOffset * (2.0 * 3.14159265) / numSlices;
        float lateralDist = dist * sin(abs(radOffset));
        
        // Star width tapers off at the tail and stays narrow overall
        float maxWidth = 0.002 + 0.004 * id;
        float currentWidth = maxWidth * factor;
        
        intensity *= smoothstep(currentWidth, 0.0, lateralDist);
    }
    
    // Star color varies slightly between white and pale blue
    vec3 starColor = mix(vec3(0.75, 0.9, 1.0), vec3(1.0, 1.0, 1.0), id);
    
    // Smoothly fade out stars near the origin to avoid visual clutter at the center
    intensity *= smoothstep(0.06, 0.18, dist);
    
    // Output star color with intensity as alpha (ideal for transparent overlays)
    vec3 finalColor = starColor * intensity;
    fragColor = vec4(finalColor, intensity);
}
