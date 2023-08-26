//
//  Shaders.metal
//  experiment-metal-triangle
//
//  Created by Gabriel Maldonado Almendra on 26/8/23.
//

// Standard Metal library
#include <metal_stdlib>
// Header where shared types and functions are defined
#include "shaders.h"

// Tells the compiler we intend to use definitions from the Metal namespace without explicitly specifying it every time
// We don't really need it in this case.
// using namespace metal;

struct Fragment {
    // Represents the position of the vertex in screen space. Will hold the clip-space position of the vertex.
    float4 position [[position]];
    // Represents the color of the vertex.
    float4 color;
};

// We'll in an array of vertices, processes each vertex to determine its position and color, and then colors each pixel on the screen based on the vertex colors.
// For this we need a Vertex Shader (1), a Fragment Shader (2), and a common structure (Fragment) to pass data through.
// Each Fragment represents a pixel

// 1. Vertex Shader
// Responsible for transforming each vertex.
//
// The `device` qualifier indicates that this data resides on the GPU
// `Vertex *vertexArray[[buffer(0)]]` represents an array of vertices that the shader will process
// `[[buffer(0)]]` specifies that it's the first buffer in the list of resources provided to the shader
// `vertexID [[vertex_id]]` is the ID of the vertex being processed
vertex Fragment vertexShader(const device Vertex *vertexArray[[buffer(0)]], unsigned int vertexID [[vertex_id]]) {
    // Fetches the input vertex from the array for a given vertexID
    Vertex input = vertexArray[vertexID];
    
    // Instantiate a Fragment struct, so we can transfer the color property from the Vertex input to the Fragment output
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    output.color = input.color;
    
    return output;
}

// 2. Fragment Shader
// Responsible for determining the color of each pixel (Fragment) on the screen:

// The VertexShader passes data to Fragment shader via Fragment struct
// `[[stage_in]]` receives the interpolated data output from the Vertex Shader (1) into the current Fragment, via a Fragment struct
fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    // Simply returns the color value.
    // The pixels are colored based on the colors of the vertices and are interpolated across primitives (in this case triangles)
    return  input.color;
}
