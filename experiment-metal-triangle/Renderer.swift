//
//  Renderer.swift
//  experiment-metal-triangle
//
//  Created by Gabriel Maldonado Almendra on 26/8/23.
//

import Foundation
import MetalKit

final class Renderer: NSObject, MTKViewDelegate {
    
    var parent: TriangleMetalView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let vertexBuffer: MTLBuffer
    
    let pipelineState: MTLRenderPipelineState
    
    init(_ parent: TriangleMetalView) {
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        // Way into to the graphics unit
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        // Finds these into Shaders.metal and bind them into the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        //init for the vertex buffer:
        let vertices: [Vertex] = [
            Vertex(position: [-1,-1], color: [1,0,0,1]),
            Vertex(position: [1,1], color: [0,1,0,1]),
            Vertex(position: [0,1], color: [0,0,1,1])
        ]
        // MemoryLayout as kinda C's sizeOf
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices,
                                              length: vertices.count * MemoryLayout<Vertex>.stride,
                                              options: [])!
        
        super.init()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        
        // A bunch of commands will be stored
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        // Color buffer
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        // Enconde all those commands into the rendereconder and pass the to the buffer
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
