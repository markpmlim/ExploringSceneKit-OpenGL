//
//  OGLSceneView.swift
//  Instancing
//
//  Created by Mark Lim on 12/2/16.
//  Copyright © 2016 Incremental Innovation. All rights reserved.
//

import SceneKit

let SUPPORT_RETINA_RESOLUTION = false

class OGLSceneView: SCNView
{
    required init?(coder: NSCoder) {
        //Swift.print("init OGLSceneView")
        super.init(coder: coder)
        
        // Ensure CoreProfile 3.2 is used.
        // The renderingAPI cannot be set to NSOpenGLProfileVersion4_1Core
        let pixelFormatAttrsBestCase: [NSOpenGLPixelFormatAttribute] = [
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
        
        // Change the property below to support OpenGL Core Profile 3.2 or later.
        self.pixelFormat = pf
        // The following statements are not necessary.
        //let glContext = NSOpenGLContext(format: pf!, share: nil)
        //self.openGLContext = glContext
        if SUPPORT_RETINA_RESOLUTION {
            // Opt-In to Retina resolution
            self.wantsBestResolutionOpenGLSurface = true
        }
        self.backgroundColor = NSColor.gray
        self.allowsCameraControl = true
    }
}
