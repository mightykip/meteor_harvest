#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

// Simple hash function for pseudo-random numbers
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 2D Value Noise with smoothstep interpolation
float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 fp = fract(p);
    fp = fp * fp * (3.0 - 2.0 * fp); // Hermite interpolation / smoothstep
    
    float a = hash(ip);
    float b = hash(ip + vec2(1.0, 0.0));
    float c = hash(ip + vec2(0.0, 1.0));
    float d = hash(ip + vec2(1.0, 1.0));
    
    return mix(mix(a, b, fp.x), mix(c, d, fp.x), fp.y);
}

// Fractional Brownian Motion with 3 octaves for organic cloud textures
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 3; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    // Normalize coordinates based on uSize uniform
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Scale coordinate space to adjust nebula cloud density
    vec2 p = uv * 2.5;
    
    // Slow animations rates
    float timeSlow = uTime * 0.015;
    
    // Domain warping: offset coords using noise to create swirling gas currents
    vec2 warp1 = vec2(
        fbm(p + vec2(0.0, 0.0) + timeSlow),
        fbm(p + vec2(5.2, 1.3) + timeSlow * 0.8)
    );
    
    vec2 warp2 = vec2(
        fbm(p + 4.0 * warp1 + vec2(1.7, 9.2) - timeSlow * 0.5),
        fbm(p + 4.0 * warp1 + vec2(8.3, 2.8) + timeSlow * 0.6)
    );
    
    // Final noise value for nebula cloud shapes
    float cloudNoise = fbm(p + 3.0 * warp2);
    
    // Base space color (extremely dark blue-black)
    vec3 baseSpace = vec3(0.01, 0.01, 0.03);
    
    // Deep purple/magenta nebula colors
    vec3 purpleNebula = vec3(0.12, 0.04, 0.22);
    
    // Cyan/teal gas highlights
    vec3 cyanNebula = vec3(0.02, 0.10, 0.18);
    
    // Mix colors based on warped noise levels
    vec3 color = mix(baseSpace, purpleNebula, cloudNoise);
    
    // Overlay cyan highlights onto the denser parts of the purple clouds
    float cyanFactor = clamp(warp2.x * warp2.y * 1.5, 0.0, 1.0);
    color = mix(color, cyanNebula, cyanFactor * cloudNoise);
    
    // Keep brightness low and subtle so it acts perfectly as a background
    color = clamp(color, 0.0, 1.0);
    
    fragColor = vec4(color, 1.0);
}
