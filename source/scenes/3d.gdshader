shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// NTSC & Retro-Effekt Parameter
uniform float saturation : hint_range(0.0, 2.0) = 0.85;        // Hanna-Barbera Farben waren oft etwas verwaschen
uniform float chroma_bleed : hint_range(0.0, 0.01) = 0.004;    // Horizontales Farbbluten (NTSC-Artefakt)
uniform float film_grain : hint_range(0.0, 0.15) = 0.06;       // Altes Filmmaterial/Zelluloid-Körnung
uniform float line_jitter : hint_range(0.0, 0.005) = 0.001;    // Unruhiges Bild (VCR-Tracking/Spulentropfen)
uniform float scanline_opacity : hint_range(0.0, 0.5) = 0.15;  // Sehr dezente, breite Röhren-Scanlines
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3; // Dunkle Ecken für den Röhren-Look

// Pseudo-Zufallsgenerator für das Rauschen und Jitter
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // 1. Line Jitter (Simuliert das leichte vertikale Wackeln alter Filmprojektoren/VHS)
    vec2 uv = SCREEN_UV;
    float time_step = floor(TIME * 12.0); // Limitiert das Wackeln auf ~12 FPS (typische Retro-Animationsrate)
    uv.y += (rand(vec2(time_step, 0.0)) - 0.5) * line_jitter;
    uv.x += (rand(vec2(0.0, time_step)) - 0.5) * (line_jitter * 0.3);

    // 2. NTSC Chroma Bleed (Farbe "läuft" horizontal aus den Konturen heraus)
    float r = texture(screen_texture, uv + vec2(chroma_bleed, 0.0)).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - vec2(chroma_bleed, 0.0)).b;
    vec3 col = vec3(r, g, b);

    // 3. Sättigung anpassen (Retro-Zelluloid-Look)
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(luma), col, saturation);

    // 4. Breite, weiche 70s Scanlines (Niedrigere Auflösung simulieren)
    float scanline = sin(uv.y * 360.0 * 3.14159); // 360 Linien für den alten TV-Standard
    col -= col * (scanline * scanline) * scanline_opacity;

    // 5. Filmkörnung / Zelluloid-Dreck hinzufügen
    float grain = (rand(uv + TIME) - 0.5) * film_grain;
    col += vec3(grain);

    // 6. Vignette (Röhrenkrümmungs-Schatten)
    vec2 d = abs(SCREEN_UV - 0.5) * vignette_intensity;
    col *= (1.0 - dot(d, d));

    COLOR = vec4(col, 1.0);
}
