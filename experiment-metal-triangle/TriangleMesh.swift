//
//  TriangleMesh.swift
//  experiment-metal-triangle
//
//  Created by Gabriel Maldonado Almendra on 26/8/23.
//

import Foundation

final class TriangleMesh {
    static let shape: [Vertex] = [
        Vertex(position: [-1,-1], color: [1,0,0,1]),
        Vertex(position: [1,-1], color: [0,1,0,1]),
        Vertex(position: [0,1], color: [0,0,1,1])
    ]
}
