//
//  OGLSceneView.swift
//  BetterWireFrame
//
//  Created by Mark Lim on 11/28/15.
//  Copyright © 2015 Incremental Innovation. All rights reserved.
//

import SceneKit

let SUPPORT_RETINA_RESOLUTION = false

class OGLSceneView: SCNView
{
    //override var renderingAPI: SCNRenderingAPI {return .OpenGLCore32}
    
    required init?(coder: NSCoder) {
        //Swift.print("init OGLSceneView")
        super.init(coder: coder)
        
        // Ensure CoreProfile 3.2 is used. NSOpenGLProfileVersion4_1Core -> crash if the
        // renderingAPI var is not set to SCNRenderingAPI.OpenGLCore41
        let pixelFormatAttrsBestCase: [NSOpenGLPixelFormatAttribute] =
        [
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFABackingStore),
            UInt32(NSOpenGLPFADepthSize), UInt32(24),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        
        let pf = NSOpenGLPixelFormat(attributes: pixelFormatAttrsBestCase)
        if (pf == nil) {
            NSLog("Couldn't reset opengl attributes")
            abort()
        }
        // the statement below will change the OpenGL context.
        self.pixelFormat = pf

        //self.openGLContext?.makeCurrentContext()
        if SUPPORT_RETINA_RESOLUTION {
            // Opt-In to Retina resolution
            self.wantsBestResolutionOpenGLSurface = true
        }
        // are these set?
        self.backgroundColor = NSColor.gray
        self.allowsCameraControl = true
        self.showsStatistics = true
        self.autoenablesDefaultLighting = true
        self.isPlaying = true
        self.loops = true
    }
}
