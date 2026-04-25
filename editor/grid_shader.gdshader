shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform vec2 world_scale = vec2(1.0, 1.0);
uniform int scale_0 : hint_range(1, 4, 1) = 1;
uniform float line_scale_0 : hint_range(0.001, 0.1, 0.001) = 0.02;
uniform vec4 color_0 : source_color = vec4(1.0);

uniform float dashed_scale_mult : hint_range(2.0, 5.0, 1.0) = 2.0;
uniform float dashed_line_width : hint_range(0.001, 0.1, 0.001) = 0.04;
uniform float dash_count : hint_range(1.0, 10.0, 1.0) = 4.0;
uniform vec4 dashed_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float border_width : hint_range(0.0, 0.5, 0.001) = 0.001;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec2 v_base_uv;
varying vec2 v_dashed_uv;

void vertex() {
    v_base_uv = UV * world_scale * float(scale_0);
    v_dashed_uv = v_base_uv * dashed_scale_mult;
}

float get_grid_logic(vec2 uv, vec2 deriv, float lineWidth) {
    vec2 targetWidth = vec2(lineWidth);
    vec2 drawWidth = clamp(targetWidth, deriv, vec2(0.5));
    vec2 lineAA = deriv * 1.5;
    vec2 gridUV = 1.0 - abs(fract(uv) * 2.0 - 1.0);
    
    vec2 grid2 = smoothstep(drawWidth + lineAA, drawWidth - lineAA, gridUV);
    grid2 *= clamp(targetWidth / drawWidth, 0.0, 1.0);
    grid2 = mix(grid2, targetWidth, clamp(deriv * 2.0 - 1.0, 0.0, 1.0));
    
    return mix(grid2.x, 1.0, grid2.y);
}

void fragment() {
    vec2 ddx = dFdx(UV);
    vec2 ddy = dFdy(UV);
    vec2 uv_deriv = vec2(length(vec2(ddx.x, ddy.x)), length(vec2(ddx.y, ddy.y)));
    
    vec2 grid_deriv = uv_deriv * world_scale * float(scale_0);
    vec2 dash_deriv = grid_deriv * dashed_scale_mult;

    float grid_val = get_grid_logic(v_base_uv, grid_deriv, line_scale_0);

    vec2 dist_to_edge = min(UV, 1.0 - UV);
    float d = min(dist_to_edge.x, dist_to_edge.y);
    float b_deriv = max(uv_deriv.x, uv_deriv.y);
    float b_draw_width = clamp(border_width, b_deriv, 0.5);
    float border_mask = smoothstep(b_draw_width + (b_deriv * 1.5), b_draw_width - (b_deriv * 1.5), d);
    border_mask *= clamp(border_width / b_draw_width, 0.0, 1.0);

    vec2 d_drawWidth = clamp(vec2(dashed_line_width), dash_deriv, vec2(0.5));
    vec2 d_lineAA = dash_deriv * 1.5;
    vec2 d_gridUV = 1.0 - abs(fract(v_dashed_uv) * 2.0 - 1.0);
    
    vec2 d_grid2 = smoothstep(d_drawWidth + d_lineAA, d_drawWidth - d_lineAA, d_gridUV);
    d_grid2 *= clamp(dashed_line_width / d_drawWidth, 0.0, 1.0);
    
    vec2 dash_aa = vec2(dash_deriv.y, dash_deriv.x) * dash_count * 1.5;
    vec2 dash_mask = smoothstep(0.5 + dash_aa, 0.5 - dash_aa, abs(fract(v_dashed_uv.yx * dash_count) * 2.0 - 1.0));
    
    float dashed_grid_val = max(d_grid2.x * dash_mask.x, d_grid2.y * dash_mask.y);
    float dashed_grid_masked = dashed_grid_val * clamp(1.0 - grid_val - border_mask, 0.0, 1.0);

    vec4 final = mix(vec4(0.0), dashed_color, dashed_grid_masked);
    final = mix(final, color_0, grid_val);
    final = mix(final, border_color, border_mask);

    ALBEDO = final.rgb;
    ALPHA = final.a;
}