#version 330 core
// Shaders are written by Joey de Vries
// Learn OpenGL pg 309
// SceneKit may not respect the locations indicated;
// removing the layout qualifer is recommended.
// These 3 vertex attributes are per-vertex.
in vec2 position;
in vec3 normal;     // unused
in vec3 color;

// "offset" is an instanced array declared as a vertex attribute.
// The contents of "offset" is updated per instance.
in vec2 offset;

out vec3 fColor;


void main()
{
    gl_Position = vec4(position + offset, 0.0f, 1.0f);
    fColor = color;
}
