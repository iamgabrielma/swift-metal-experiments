//
//  experiment_metal_triangleApp.swift
//  experiment-metal-triangle
//
//  Created by Gabriel Maldonado Almendra on 25/8/23.
//

import SwiftUI
import MetalKit


final class Renderer: NSObject, MTKViewDelegate {
    
    var parent: TriangleMetalView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    //var vertexBuffer: MTLBuffer
    
    init(_ parent: TriangleMetalView) {
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        // Way into to the graphics unit
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let _: [Vertex] = []
        // init for the vertex buffer:
//        let vertices: [Vertex] = [
//
//        ]
//
//        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: []) as! MTLBuffer
        
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
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

// Coordinator as control structure for the rendering
struct TriangleMetalView: UIViewRepresentable {
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    // context as typealias for UIViewRepresentableContext<Self>, switch for our own thing:
    // we also return an MTKView as the UIView
    func makeUIView(context: UIViewRepresentableContext<TriangleMetalView>) -> MTKView {
        let mtkView = MTKView()
        // Delegate rendering responsibility to the `Renderer` coordinator
        mtkView.delegate = context.coordinator
        mtkView.enableSetNeedsDisplay = true
        // Set the device for the MetalView. Represents the GPU
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<TriangleMetalView>) {
        // no-op
    }
}

@main
struct experiment_metal_triangleApp: App {
    var body: some Scene {
        WindowGroup {
            TriangleMetalView()
        }
    }
}

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        TriangleMetalView()
    }
}
