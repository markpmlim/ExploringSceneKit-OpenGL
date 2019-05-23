#version 410 core

layout(location = 0) in vec4 aVertex;

uniform mat4 uModelViewMatrix;

void main( )
{
	gl_Position = uModelViewMatrix * aVertex;
}
