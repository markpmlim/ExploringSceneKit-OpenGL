// This set of shaders were on www.twodee.org; the link is not longer available
// or has changed.
#version 330 core

layout(location = 0) in vec3 position;

void main()
{
    gl_Position = vec4(position, 1.0);
}
