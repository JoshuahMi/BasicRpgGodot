// Copyright 2026 Joshuah Skyseed, all rights reserved  

shader_type canvas_item;

uniform bool is_circular;
uniform float fillage: hint_range(0.0, 1.0, 0.1);
uniform float clamp_size: hint_range(0.0, 1.0, 0.01);
uniform float time_scale: hint_range(0.0, 1.0, 0.01);
uniform vec3 colour: source_color;
uniform sampler2D noise_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	// Called for every pixel the material is visible on.
	
	// POLAR COORDINATES:
	
	vec2 base_uv = UV;
	base_uv -= 0.5;
	base_uv *= 2.0;
	
	// this I don't understand ._.				// but here I added "scale", and it works somehow.
	float angle = atan(base_uv.y, base_uv.x) / (1.0 * PI);
	
	float dist = length(base_uv);
	
	vec2 polar_uv = vec2(angle, dist);
	

	
	// NEW CODE
	
	
	
	float fillage_local = (1.0 - fillage * 2.0) * 0.6 - 0.1;
	float gradient = length(UV + vec2(-0.5)) * 2.0;
	gradient = 1.0 - gradient;
	

	gradient -= fillage_local;
	
	gradient *= 20.0 * clamp_size;
	gradient -= (20.0 * clamp_size) / 2.0 - 0.5 - clamp_size;
	// gradient -= 1.0;
	
	// UV.x ist quasi wenn fillage = 0.5 und clamp_size = 1.0 ist
	// gradient += 1.0;
	
	// Also verschieben wir den Gradient um die fillage.
	
	// je höher die Zahl, desto näher kommt die Kante dem fillage-Wert.
	// Das muss später ausgeglichen werden.
	//float clamp_size_local = 1.0 - clamp_size; 
	//
	//float clamp_strength = 1.0 * clamp_size_local;
	
	
	// gradient *= clamp_strength;
	
	// Offsets the gradient by the fillage value
	// gradient -= fillage_local * 1.0 * clamp_strength;

	// NOISE
	
	float time_scale_local = time_scale;
	float noise;
	
	noise = texture(noise_texture, vec2(fract(polar_uv.x ), fract(polar_uv.y - TIME * time_scale_local))).r;
	// gradient -= noise;
	
	 gradient -= noise;




	if (fillage == 1.0) {
		COLOR.a = 1.0;
	}
	else if (fillage == 0.0) {
		COLOR.a = 0.0;
	}
	else {
		COLOR.a = gradient;
	}

	if (is_circular) {
		float mask = length(UV + vec2(-0.5));
		mask = step(mask, 0.5);
		mask = 1.0 - mask;
		COLOR.a = COLOR.a - mask;
	}
	
	COLOR.rgb = texture(TEXTURE, UV).rgb * colour;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}