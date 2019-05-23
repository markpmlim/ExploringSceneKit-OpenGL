#version 410 core

in float gLightIntensity;   // output from geometry shader

out vec4 fFragColor;		// defaults to color attachment 0

const vec3 COLOR = vec3(1.0f, 0.5, 0.0f);

//https://stackoverflow.com/questions/44033605/why-is-metal-shader-gradient-lighter-as-a-scnprogram-applied-to-a-scenekit-node
float srgbToLinear(float c) {
    if (c <= 0.04045)
        return c / 12.92;
    else
        return pow((c + 0.055) / 1.055, 2.4);
}

void main( )
{
    vec3 color;
    color.r = srgbToLinear(COLOR.r);
    color.g = srgbToLinear(COLOR.g);
    color.b = srgbToLinear(COLOR.b);
    fFragColor = vec4(gLightIntensity * color, 1.0f);
}
