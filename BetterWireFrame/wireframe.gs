#version 330

layout(triangles) in;
layout(triangle_strip) out;
layout(max_vertices = 3) out;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

out vec3 weight;                        // additional vertex attribute

void main()
{
    // Distance in barycentric space
    weight = vec3(1.0, 0.0, 0.0);       // first component
    // Transform the vertex's position into clip space.
    gl_Position = projectionMatrix * modelViewMatrix * gl_in[0].gl_Position;
    EmitVertex();

    weight = vec3(0.0, 1.0, 0.0);       // second component
    gl_Position = projectionMatrix * modelViewMatrix * gl_in[1].gl_Position;
    EmitVertex();

    weight = vec3(0.0, 0.0, 1.0);       // third component
    gl_Position = projectionMatrix * modelViewMatrix * gl_in[2].gl_Position;
    EmitVertex();

    EndPrimitive();
}
