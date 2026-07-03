#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 uCenter;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    // Normalize current pixel coordinates
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Normalize center coordinates (robust handling for absolute pixel or normalized inputs)
    vec2 center = uCenter;
    if (center.x > 1.0 || center.y > 1.0) {
        center = center / uSize;
    }
    
    // Calculate vector from center of shockwave to current pixel
    vec2 diff = uv - center;
    
    // Correct aspect ratio for distance calculation to keep the shockwave perfectly circular
    vec2 aspectDiff = diff;
    aspectDiff.x *= uSize.x / uSize.y;
    float dist = length(aspectDiff);
    
    // Propagation parameters
    float speed = 1.4;       // Speed at which the wave expands
    float duration = 0.75;   // Total duration of the shockwave in seconds
    float thickness = 0.05;  // Thickness of the shockwave ring
    
    vec2 targetUV = uv;
    vec4 texColor;
    
    if (uTime > 0.0 && uTime < duration) {
        float radius = uTime * speed;
        float fade = 1.0 - (uTime / duration); // Fades distortion out over time
        
        // Distance from current pixel to the wave front
        float diffToWave = dist - radius;
        
        // Gaussian envelope peaking at the shockwave radius
        float waveEnvelope = exp(-pow(diffToWave / thickness, 2.0));
        
        if (waveEnvelope > 0.01) {
            vec2 dir = (length(diff) > 0.0) ? normalize(diff) : vec2(1.0, 0.0);
            
            // Refraction distortion: shifts pixel lookups inward and outward
            float displacement = sin(diffToWave * 3.14159 / thickness) * 0.022 * waveEnvelope * fade;
            
            targetUV = uv + dir * displacement;
            targetUV = clamp(targetUV, 0.0, 1.0); // Clamp to avoid edge wrapping artifacts
        }
        
        // Sample texture using potentially distorted coordinates
        texColor = texture(uTexture, targetUV);
        
        // 3. Chromatic Aberration: separate color channels slightly near the wave edge
        if (waveEnvelope > 0.1) {
            vec2 dir = (length(diff) > 0.0) ? normalize(diff) : vec2(1.0, 0.0);
            float aberrationAmount = 0.007 * waveEnvelope * fade;
            
            // Offset red and blue channels in opposite directions along the wave normal
            float rChannel = texture(uTexture, clamp(targetUV + dir * aberrationAmount, 0.0, 1.0)).r;
            float bChannel = texture(uTexture, clamp(targetUV - dir * aberrationAmount, 0.0, 1.0)).b;
            
            texColor.r = rChannel;
            texColor.b = bChannel;
        }
    } else {
        // No shockwave active: sample original texture directly
        texColor = texture(uTexture, uv);
    }
    
    fragColor = texColor;
}
