#version 330

in vec3 weight;                     // interpolated value

out vec4 frag_color;

uniform float color;                // wire color

const float DISCARD_AT = 0.1;       // threshold value
const float BACKGROUND_AT = 0.05;   // threshold value
const float BACKGROUND = 1.0;

void main()
{
    float minDist = min(weight.r, min(weight.g, weight.b));

    if (minDist > DISCARD_AT) {
        // We are far from an edge so discard this fragment.
        discard;
    }

    // Render the background color if we are above the BACKGROUND_AT threshold.
    float intensity = minDist > BACKGROUND_AT ? BACKGROUND : color;
    frag_color = vec4(vec3(intensity), 1.0);
}
