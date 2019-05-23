// Shaders are written by Joey de Vries
// Learn OpenGL pg 300
// ================
// Vertex shader:
// ================
#version 330 core
// The vertex normal is not used; the face normal is computed
// by the geometry shader
in vec3 position;
in vec2 texCoords;

// custom struct
out VS_OUT {
    vec2 texCoords;
} vs_out;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    // Transform incoming position into clip space.
    gl_Position = projection * view * model * vec4(position, 1.0f);
    // Pass the tex coords to the geometry shader.
    vs_out.texCoords = texCoords;
}
