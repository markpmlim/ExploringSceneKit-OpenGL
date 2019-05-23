//
//  ViewController.swift
//  BetterWireframe
//
//  Created by mark lim pak mun on 7/2/16.
//  Copyright © 2016 Incremental Innovation. All rights reserved.
//
//


import SceneKit
import SceneKit.ModelIO

class ViewController: NSViewController, SCNProgramDelegate, SCNSceneRendererDelegate {
    @IBOutlet var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.backgroundColor = NSColor.gray
        sceneView.autoenablesDefaultLighting = true
        let scene = SCNScene()
        sceneView.scene = scene

        // load our shaders
        let shaderName = "wireframe"
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
        } catch _ {
            Swift.print("Can't load vertex shader")
        }
        
        var geometryShader: String?
        do {
            try geometryShader = String(contentsOf: geometryShaderURL!,
                                        encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load geometry shader")
        }

        var fragmentShader: String?
        do {
            try fragmentShader = String(contentsOf: fragmentShaderURL!,
                                        encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load fragment shader")
        }
        
        let program = SCNProgram()
        program.vertexShader = vertexShader
        program.fragmentShader = fragmentShader
        program.geometryShader = geometryShader
        program.delegate = self
        sceneView.delegate = self
        
        // load the model; we ignore its color attributes
        let modelURL = Bundle.main.url(forResource: "teapotLowRes",
                                       withExtension: "dae")
        let teapotData = try? Data(contentsOf: modelURL!)
        let sceneSource = SCNSceneSource(data: teapotData!, options: nil)
        let teapotNode = sceneSource!.entryWithIdentifier("node-TeapotLowRes",
                                                          withClass: SCNNode.self)! as SCNNode
        // We need the teapot's geometry for binding
        let teapot = teapotNode.geometry
        teapot!.program = program
        scene.rootNode.addChildNode(teapotNode)

        // vertex attributes
        program.setSemantic(SCNGeometrySource.Semantic.vertex.rawValue,
                            forSymbol: "position",
                            options: nil)

        program.setSemantic(SCNModelViewTransform,
                            forSymbol: "modelViewMatrix",
                            options: nil)
        
        program.setSemantic(SCNProjectionTransform,
                            forSymbol: "projectionMatrix",
                            options: nil)
        
        // Color of the wireframe
        teapot!.handleBinding(ofSymbol: "color",
                              handler: {
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in
            glUniform1f(GLint(location), 0.3)
        })
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // The view port has been cleared
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        //sceneView.openGLContext?.makeCurrentContext()
        //glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_LINE));    // GL_FRONT is invalid!
    }
    
    func program(_ program: SCNProgram, handleError error: Error) {
        NSLog("%@", error.localizedDescription);
        
    }
}

