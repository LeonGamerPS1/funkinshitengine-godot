shader_type canvas_item;

// Controls the direction and intensity of the blur
uniform vec2 linear_velocity = vec2(0.0, 0.0);
// Controls how many samples to take (higher = smoother but slower)
uniform int samples = 15;

void fragment() {
    vec4 color = vec4(0.0);
    vec2 blur_vector = linear_velocity * SCREEN_PIXEL_SIZE;
    
    // Sample the texture along the velocity vector
    for(int i = 0; i < samples; i++) {
        float offset = float(i) / float(samples - 1) - 0.5;
        color += texture(TEXTURE, UV + blur_vector * offset);
    }
    
    // Average the samples
    COLOR = color / float(samples);
}
