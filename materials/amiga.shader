shader_type spatial;

/* AMIGAAAAAAA! */
uniform float s = .2;

float get_height(vec2 p) {
	return 0.5;
}

void fragment() {
	vec3 c = vec3(1.0);
	float hs = s*.5;

	vec2 pos = mod(UV.xy, vec2(s));
	if ( (pos.x>hs && pos.y>hs) || (pos.x<hs && pos.y<hs)) { 
		c = vec3(1.0,.0,.0); 
	} else {
		c = vec3(1.0);
	}
	
	ALBEDO = c;
	METALLIC = 0.5;
	SPECULAR = 0.8;
	ROUGHNESS = 0.2;
}