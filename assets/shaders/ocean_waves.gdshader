shader_type spatial;

render_mode diffuse_burley, specular_toon;
//render_mode wireframe;
//render_mode world_vertex_coords;

uniform float amp = 0.5;
uniform float wavelength = 1.0;
uniform float phase = 1.0;
uniform float scroll_speed = 0.08;
uniform vec2 direction = vec2(-0.5, 0.5);
uniform vec2 direction2 = vec2(-0.25, -0.5);
uniform sampler2D noise;
uniform sampler2D tex : filter_nearest;

void vertex() {
	float height = texture(noise, VERTEX.xz / 2.0 + 0.5).x * 0.5;
	VERTEX.y = amp * sin(VERTEX.x * wavelength + phase * TIME) + amp * 2.0 * sin((VERTEX.z * VERTEX.x) * wavelength + phase * TIME) 
		+ amp / 2.0 * sin(VERTEX.x * wavelength * 5.0 + phase * 0.5 * TIME) + amp / 3.0 * sin(VERTEX.z * wavelength * 0.25 + phase * 2.0 * TIME)
		+ amp * 3.0 * max(0.0, sin(VERTEX.z * wavelength * 10.0 + phase * 0.25 * TIME))
		+ height;
}

void fragment() {
	//float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	//ROUGHNESS = 0.01 * (1.0 - fresnel);
	ROUGHNESS = 0.5;
	vec3 scroll1 = texture(tex, UV * vec2(20, 20) + (direction * TIME * scroll_speed)).xyz;
	vec3 scroll2 = texture(tex, vec2(UV.x * cos(45) - UV.y * sin(45), UV.y * cos(45) + UV.x * sin(45)) * vec2(20, 20) + (direction2 * TIME * scroll_speed)).xyz;
	ALBEDO = (scroll1 + scroll2) / vec3(2, 2, 2);
}
