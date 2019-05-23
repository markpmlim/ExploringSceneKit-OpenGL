//
//  OGLSceneView.swift
//  Pulsate
//
//  Created by Mark Lim on 11/2/16.
//  Copyright © 2016 Incremental Innovation. All rights reserved.
//

import SceneKit

let SUPPORT_RETINA_RESOLUTION = false

// A different way of initializing a sub-class of SCNView.
class OGLSceneView: SCNView {

    override var renderingAPI: SCNRenderingAPI {
        return .openGLCore32
    }

    required init?(coder: NSCoder) {
        //Swift.print("init OGLSceneView")
        super.init(coder: coder)

        if SUPPORT_RETINA_RESOLUTION {
            // Opt-In to Retina resolution
            self.wantsBestResolutionOpenGLSurface = true
        }
        self.backgroundColor = NSColor.cyan
        self.allowsCameraControl = true
        self.showsStatistics = true
    }
}
