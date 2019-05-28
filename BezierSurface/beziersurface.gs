#version 410 core
// This shader will "shrink" the triangles sent by the
// tessellation evaluation shader.
layout( triangles ) in;
layout( triangle_strip, max_vertices=200 ) out;

uniform mat4 uProjectionMatrix;

// These 2 uniforms must be passed by program
uniform float uShrink;

in vec3 teNormal[3];                    // output by tes

out float gLightIntensity;

// Variables used by this shader.
vec3 LightPos = vec3(0.0, 10.0, 10.0);

vec3 V[3];
vec3 CG;


void ProduceVertex( int v )
{
    // Compute the light intensity at the vertex first.
    gLightIntensity  = abs(dot(normalize(LightPos - V[v]), teNormal[v]));

    // The vertex is moved toward the centroid and then output to the fragment shader.
    gl_Position = uProjectionMatrix * vec4(CG + uShrink * ( V[v] - CG ), 1.0);
    EmitVertex( );
}


void main()
{
    // Make a copy of the vertices of the tessellated triangle
    // output by the TPG for easier access.
    V[0]  =   gl_in[0].gl_Position.xyz;
    V[1]  =   gl_in[1].gl_Position.xyz;
    V[2]  =   gl_in[2].gl_Position.xyz;

    // Compute the centroid.
    CG = 0.33333 * ( V[0] + V[1] + V[2] );

    ProduceVertex( 0 );
    ProduceVertex( 1 );
    ProduceVertex( 2 );
}
