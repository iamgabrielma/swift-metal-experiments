//
//  TriangleMetalView.swift
//  experiment-metal-triangle
//
//  Created by Gabriel Maldonado Almendra on 26/8/23.
//

import Foundation
import SwiftUI
import MetalKit

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

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        TriangleMetalView()
    }
}
