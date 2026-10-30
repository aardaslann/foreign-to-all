shader_type canvas_item;
uniform bool painted_metal = false;
uniform bool blue_handles = false;
uniform bool wood_branches = false;
uniform bool pink_blossoms = false;

// Within an authored plant outline, retain the original green pixel clusters.
// Pale wall/floor pixels in the gaps must not be painted over an actor.
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	float leaf = step(pixel.r + 0.025, pixel.g) * step(pixel.b + 0.012, pixel.g);
	if (pink_blossoms) {
		// Opt-in for a measured bougainvillea crown; retain its pink petals
		// without filling the pale wall visible between the flower clusters.
		float flower = step(pixel.g + 0.16, pixel.r) * step(pixel.g + 0.08, pixel.b);
		leaf = max(leaf, flower);
	}
	if (wood_branches) {
		float branch = step(0.10, pixel.r) * (1.0 - step(0.46, pixel.r))
			* step(pixel.g + 0.018, pixel.r) * step(pixel.b + 0.026, pixel.g);
		leaf = max(leaf, branch);
	}
	// Canal iron is green/blue; the paving seen through it is warm gray.
	// Use only inside the tightly bounded rail region, preserving each exact
	// diagonal, rounded joint and gap rather than approximating its pattern.
	if (painted_metal) {
		leaf = step(pixel.r + 0.006, pixel.g) * step(pixel.r + 0.006, pixel.b);
	}
	if (blue_handles) {
		leaf = step(pixel.r + 0.08, pixel.b) * step(pixel.g + 0.025, pixel.b);
	}
	COLOR *= vec4(vec3(1.0), leaf);
}
