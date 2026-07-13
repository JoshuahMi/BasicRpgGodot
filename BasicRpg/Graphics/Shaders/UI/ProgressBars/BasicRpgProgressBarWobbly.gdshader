// Copyright 2026 Joshuah Skyseed, all rights reserved  

shader_type canvas_item;

uniform bool fill_right_to_left;
uniform bool fill_from_middle;
uniform float visibility_loc: hint_range(0.0, 1.0, 0.1);
uniform float fillage: hint_range(0.0, 1.0, 0.01);
uniform float clamp_size: hint_range(0.0, 1.0, 0.1);
uniform float time_scale: hint_range(0.0, 1.0, 0.01);
uniform vec3 colour: source_color;
uniform sampler2D noise_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	
	float fillage_local = fillage * 0.7;
	// No clue why, but it works only between the values 0.8 and 0.2
	fillage_local = (1.0 - fillage_local) * 0.7  + 0.03;
	
	
	
	
	float gradient = 1.0 - UV.x;
	
	if (fill_right_to_left) {
		gradient = UV.x;
	} else {
		gradient = 1.0 - UV.x;
	}
	
	if (fill_from_middle) {
		
		if (UV.x > 0.5) {
			gradient = 1.0 - UV.x;
		}
		else {
			gradient = UV.x;
		}
		gradient *= 2.0;
		
		
		
	}
	
	
	// UV.x ist quasi wenn fillage = 0.5 und clamp_size = 1.0 ist
	gradient += 1.0;
	
	// Also verschieben wir den Gradient um die fillage.
	
	// je höher die Zahl, desto näher kommt die Kante dem fillage-Wert.
	// Das muss später ausgeglichen werden.
	float clamp_size_local = 1.0 - clamp_size;
	
	float clamp_strength = 20.0 * clamp_size_local;
	
	
	gradient *= clamp_strength;
	
	// Offsets the gradient by the fillage value
	gradient -= fillage_local * 2.0 * clamp_strength;
	
	
	// Found out through debugging.
	// corrects the offset
	gradient -= clamp_strength * 0.5 - 0.5;

	// NOISE
	
	float time_scale_local = time_scale * 0.5;
	float noise;
	
	if (fill_right_to_left) {
		noise = texture(noise_texture, vec2(fract(UV.x + TIME * time_scale_local), UV.y)).r;
	
	}
	else {
		noise = texture(noise_texture, vec2(fract(UV.x - TIME * time_scale_local), UV.y)).r;
	
	}
	
	if (fill_from_middle) {
		
		if (UV.x > 0.5) {
			noise = texture(noise_texture, vec2(fract(UV.x - TIME * time_scale_local), UV.y)).r;
	
		}
		else {
			noise = texture(noise_texture, vec2(fract(UV.x + TIME * time_scale_local), UV.y)).r;
	
		}
		
		
	}
	
	gradient -= noise;
	// Offset correction because Noise
	// comment this line when no noise is used.
	gradient += 2.0 * clamp_size * clamp_size_local;
	
	
	
	COLOR.a = gradient;
	
	if (fillage == 0.0) {
		COLOR.a = 0.0;
	}
	else if (fillage == 1.0) {
		COLOR.a = 1.0;
	}
	
	COLOR.a *= texture(TEXTURE, UV).a;
	
	COLOR.a = clamp(COLOR.a, 0.0, 1.0);
	
	
	
	COLOR.a *= visibility_loc;
	
	
	COLOR.rgb = colour * texture(TEXTURE, UV).rgb;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}