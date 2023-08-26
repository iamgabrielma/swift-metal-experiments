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
    var vertexBuffer: MTLBuffer!
    
    var pipelineState: MTLRenderPipelineState!
    
    init(parent: TriangleMetalView) {
        self.parent = parent
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }

        super.init()

        // 1 Creates the render pipeline
        self.pipelineState = self.makeRenderPipeline()
        // 2. Creates the command queue for a given device
        self.metalCommandQueue = self.makeCommandQueue(for: metalDevice)
        // 3. Creates the array that holds all the vertices we'll want to draw
        let vertices = self.createVertexCollection()
        // 4. Creates the buffer allocation needed for the vertices array
        vertexBuffer = self.createVertexBufferAllocation(using: metalDevice, forVertices: vertices)
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            fatalError()
        }
        
        // A bunch of commands will be stored
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            fatalError("Unable to make command buffer")
        }
        
        // Color buffer
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Unable to make render pass descriptor")
        }
        configure(renderPassDescriptor: renderPassDescriptor)
        
        // Enconde all those commands into the rendereconder and pass the to the buffer
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Unable to make render encoder")
        }
        configure(renderCommandEncoder: renderEncoder,
                  setPipelineState: pipelineState,
                  setVertexBuffer: vertexBuffer)

        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Protocol conformance
//
extension Renderer {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
     
    }
}

// MARK: Helpers
//
private extension Renderer {
    enum ShapeType {
        case triangle
    }
    
    private func makeShape(_ shape: ShapeType) -> [Vertex] {

        if shape == .triangle {
            return TriangleMesh.shape
        }
        return []
    }
    
    private func configure(renderPassDescriptor: MTLRenderPassDescriptor) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
    }
    
    private func configure(renderCommandEncoder: MTLRenderCommandEncoder,
                   setPipelineState pipelineState: MTLRenderPipelineState,
                   setVertexBuffer vertexBuffer: MTLBuffer) {
        renderCommandEncoder.setRenderPipelineState(pipelineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderCommandEncoder.endEncoding()
    }

    private func makeCommandQueue(for device: MTLDevice) -> MTLCommandQueue {
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError()
        }
        return commandQueue
    }
    
    private func makeRenderPipeline() -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        // Finds these into Shaders.metal and bind them into the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
            return pipelineState
        } catch {
            fatalError()
        }
    }
    
    private func createVertexCollection() -> [Vertex] {
        return makeShape(.triangle)
    }
    
    private func createVertexBufferAllocation(using: MTLDevice, forVertices vertices: [Vertex]) -> MTLBuffer {
        metalDevice.makeBuffer(bytes: vertices,
                               length: vertices.count * MemoryLayout<Vertex>.stride,
                               options: [])!
        
    }
}
