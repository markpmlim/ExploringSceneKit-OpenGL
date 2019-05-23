//
//  OGLSceneView.swift
//  BezierSurface
//
//  Created by Mark Lim on 22/3/19.
//  Copyright © 2019 Incremental Innovation. All rights reserved.
//

import SceneKit

let SUPPORT_RETINA_RESOLUTION = false

class OGLSceneView: SCNView
{
    override var renderingAPI: SCNRenderingAPI {return .openGLCore32}
    
    required init?(coder: NSCoder) {
        //Swift.print("init OGLSceneView")
        super.init(coder: coder)

        if SUPPORT_RETINA_RESOLUTION {
            // Opt-In to Retina resolution
            self.wantsBestResolutionOpenGLSurface = true
        }
        self.backgroundColor = NSColor.blue
        // Use a free camera to view the object.
        self.allowsCameraControl = true
        self.showsStatistics = true
    }
}
