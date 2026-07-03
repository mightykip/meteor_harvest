#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    // Normalize coordinates relative to the component size
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Sample the crystal sprite texture
    vec4 texColor = texture(uTexture, uv);
    
    // If the pixel is fully transparent, discard/output transparent
    if (texColor.a < 0.01) {
        fragColor = vec4(0.0);
        return;
    }
    
    // 1. Gentle color-based glow pulse
    // Pulses between 0.0 and 0.15 over time to simulate a sparkling crystal
    float pulse = 0.07 * sin(uTime * 4.0) + 0.08;
    
    // Boost the base colors based on the pulse
    vec3 baseColor = texColor.rgb * (1.0 + pulse);
    
    // 2. Diagonal sheen sweep
    // Diagonal position coordinate (slanted line equation)
    float diagonal = uv.x + uv.y;
    
    // Looping sweep timeline: 3.5 seconds total cycle
    // 1.0 second for the sheen to sweep across, 2.5 seconds of rest
    float cycleDuration = 3.5;
    float sweepTime = 1.0;
    float timeInCycle = mod(uTime, cycleDuration);
    
    vec3 sheen = vec3(0.0);
    if (timeInCycle < sweepTime) {
        float progress = timeInCycle / sweepTime;
        
        // Map progress from [-0.3, 2.3] to cover start and end of diagonal
        float shimmerPos = mix(-0.3, 2.3, progress);
        
        // Distance to the center of the sweep line
        float dist = abs(diagonal - shimmerPos);
        
        // Outer soft glow of the sheen
        float softSheen = smoothstep(0.18, 0.0, dist) * 0.4;
        
        // Intense bright core of the sheen
        float coreSheen = smoothstep(0.04, 0.0, dist) * 0.6;
        
        // Combine sheen strengths
        float sheenStrength = softSheen + coreSheen;
        
        // Tint the sheen slightly toward the crystal's color to make it look realistic
        vec3 sheenTint = mix(vec3(1.0), normalize(texColor.rgb + 0.2), 0.35);
        sheen = sheenTint * sheenStrength;
    }
    
    // Add sheen to the base color, scaled by the texture's alpha channel
    vec3 finalColor = baseColor + sheen * texColor.a;
    
    // Clamp values to remain in valid color space
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    fragColor = vec4(finalColor, texColor.a);
}
