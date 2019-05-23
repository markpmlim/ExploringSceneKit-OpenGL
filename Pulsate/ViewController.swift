//
//  ViewController.swift
//  Pulsate
//
//  Created by mark lim pak mun on 11/2/16.
//  Copyright © 2016 Incremental Innovation. All rights reserved.
//
// Pulsate rather than explode

import SceneKit

class ViewController: NSViewController, SCNProgramDelegate, SCNSceneRendererDelegate {
    @IBOutlet var sceneView: OGLSceneView!
    var time: TimeInterval?
    var texture: GLKTextureInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        time = 0.0
        let scene = SCNScene()
        self.sceneView.scene = scene

        let torus = SCNTorus(ringRadius: 5.0, pipeRadius: 1.5)
        torus.ringSegmentCount = 48
        torus.pipeSegmentCount = 48
        SCNTransaction.flush()
        let torusNode = SCNNode(geometry: torus)
        torusNode.name = "torus0"
        torusNode.rotation = SCNVector4Make(1, 0, 0, CGFloat.pi/12)
        let shaderName = "pulsate"
        let vertexShaderURL = Bundle.main.url(forResource: shaderName,
                                              withExtension: "vs")
        let fragmentShaderURL = Bundle.main.url(forResource: shaderName,
                                                withExtension: "fs")
        let geometryShaderURL = Bundle.main.url(forResource: shaderName,
                                                withExtension: "gs")
        
        var vertexShader: String?
        do {
            try vertexShader = String(contentsOf: vertexShaderURL!,
                                      encoding: String.Encoding.utf8)
        }
        catch let error {
            Swift.print("Can't load vertex shader source:\(error)")
        }
        
        var geometryShader: String?
        do {
            try geometryShader = String(contentsOf: geometryShaderURL!,
                                        encoding: String.Encoding.utf8)
        }
        catch let error {
            Swift.print("Can't load geometry shader source:\(error)")
        }
        
        var fragmentShader: String?
        do {
            try fragmentShader = String(contentsOf: fragmentShaderURL!,
                                        encoding: String.Encoding.utf8)
        }
        catch let error {
            Swift.print("Can't load fragment shader source:\(error)")
        }

        let program = SCNProgram()
        program.vertexShader = vertexShader
        program.fragmentShader = fragmentShader
        program.geometryShader = geometryShader
        program.delegate = self
        sceneView.delegate = self
        // vertex attributes
        program.setSemantic(SCNGeometrySource.Semantic.vertex.rawValue,
                            forSymbol: "position",
                            options: nil)

        program.setSemantic(SCNGeometrySource.Semantic.texcoord.rawValue,
                            forSymbol: "texCoords",
                            options: nil)

        // uniforms
        program.setSemantic(SCNModelViewProjectionTransform,
                            forSymbol: "projection",
                            options: nil)
        program.setSemantic(SCNModelTransform,
                            forSymbol: "model",
                            options: nil)
        program.setSemantic(SCNViewTransform,
                            forSymbol: "view",
                            options: nil)

        torus.firstMaterial!.handleBinding(ofSymbol: "time",
                                           handler: {

            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in
            self.time! += 0.02
            glUniform1f(Int32(location), GLfloat(self.time!))
        })

        torus.firstMaterial!.handleBinding(ofSymbol: "texture_diffuse1",
                                           handler: {
                
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in
            if self.texture == nil {
                //Swift.print("loading the texture")
                let imagePath = Bundle.main.path(forResource: "checkertile",
                                                 ofType:"jpg")
                var texture: GLKTextureInfo?
                do {
                    try texture = GLKTextureLoader.texture(withContentsOfFile: imagePath!,
                                                            options: nil)
                }
                catch let error1 as NSError  {
                    Swift.print("error:", error1)
                }

                if texture == nil {
                    Swift.print("texture not loaded")
                }
                else {
                    //Swift.print("texture loaded")
                    self.texture = texture
                }
            }
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture!.name);
        })

        torus.firstMaterial!.program = program
        scene.rootNode.addChildNode(torusNode)

        // This sequence of instructions will make the renderer delegate loop
        // indefinitely. This in turn will cause the torus to pulsate.
        // The states can also be set in IB.
        sceneView.loops = true
        sceneView.play(nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // The view port has been cleared
    // This method gets called only when there is a frame update
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval)
    {
        glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_FILL));    // GL_FRONT is invalid!
        //Swift.print("render:", self.time)
    }
}

