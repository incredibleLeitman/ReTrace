shader_type canvas_item;

uniform sampler2D true_view;
uniform sampler2D masked_view;

uniform float mask_factor;

void fragment() {
	// Add the masked view and the true view depending on the factor
    COLOR = (1.0f - mask_factor) * texture(true_view, SCREEN_UV) + mask_factor * texture(masked_view, SCREEN_UV);
}