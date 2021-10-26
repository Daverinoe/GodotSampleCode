shader_type canvas_item;

uniform sampler2D screenTex;
uniform sampler2D normalMap;

void fragment(){
	
	vec2 perspectiveCorrection = vec2(2.0 * (0.5 - UV.x) * (UV.y - 0.7), 0.0);
	
	vec2 point = UV;
	
	if (point.y > 0.7) {
		point.y = 1.4 - point.y;
//		point.x += TIME * 0.05;
		point = point + perspectiveCorrection;
		point.x -= 0.012;
		point.x = mod(point.x, 1.0);
		NORMALMAP = texture(normalMap, point + TIME * 0.05 * vec2(1.0, 0.0)).xyz;
	} else {
		COLOR.a = 0.0;
	}
	COLOR.rgb = texture(screenTex, point).rgb;
}