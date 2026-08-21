// @author https://github.com (Dein Original-Shader, 1:1 übersetzt)
shader_type canvas_item;

instance uniform vec3 red;
instance uniform vec3 green;
instance uniform vec3 blue;

void fragment() {
  vec4 color = texture(TEXTURE, UV);
  COLOR = vec4(color.r * red + color.g * green + color.b * blue, color.a);
}
