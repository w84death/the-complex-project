shader_type spatial;
render_mode depth_test_disable,  unshaded, depth_draw_never, cull_disabled;

uniform float light : hint_range(0, 1);
uniform float extend : hint_range(0, 1);

uniform float offset : hint_range(0, 10);

void fragment() {
    vec2 uv = UV;
    vec3 chroma;
    float amount = offset * 0.0005;
    vec3 og_color = textureLod( SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
    chroma.r = textureLod( SCREEN_TEXTURE, SCREEN_UV + vec2(amount, 0.), 0.0).r;
    chroma.g = og_color.g;
    chroma.b = textureLod( SCREEN_TEXTURE, SCREEN_UV - vec2(amount, 0.), 0.0).b;
    
    uv *=  1.0 - uv.yx;
    float vig = uv.x*uv.y * 15.;
    vig = pow(vig, extend);
    vig = 1.0 - vig;
    chroma = mix(og_color, chroma, vig * 2.);
    
    ALBEDO = mix(chroma, chroma * vec3(light), vig);
    //ALPHA = vig;
}