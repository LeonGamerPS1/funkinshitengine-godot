shader_type canvas_item;

instance uniform vec3 red;
instance uniform vec3 green;
instance uniform vec3 blue;
instance uniform bool use;
instance uniform float alpha = 1;
varying vec4 v_modulate;

void vertex() {
	// Speichert die Modulate-Farbe des Sprites sauber ab
	v_modulate = COLOR;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	if(use) {
		COLOR = vec4(color.r * red + color.g * green + color.b * blue, color.a * alpha) * v_modulate * alpha;
	} else {
		// KORREKTUR: Wenn der Effekt aus ist, müssen wir die Textur 
		// ebenfalls mit v_modulate multiplizieren, damit Modulate/Alpha nicht verloren gehen!
		color.a = color.a * alpha;
		COLOR = color * v_modulate;
	}
}
