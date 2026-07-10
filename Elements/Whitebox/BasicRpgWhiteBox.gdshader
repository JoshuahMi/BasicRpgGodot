shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 local_uv = UV;
	
	local_uv *= 100.0;
	
	local_uv = fract(local_uv);
	
	local_uv = vec2((local_uv.x + local_uv.y) * 0.5) ;
	
	vec3 final_color = vec3((local_uv.x + local_uv.y + 1.0) * 0.333);
	
	ALBEDO = final_color;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
