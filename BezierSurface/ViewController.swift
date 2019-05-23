//
//  ViewController.swift
//  BezierSurface
//
//  Created by mark lim pak mun on 22/3/19.
//  Copyright © 2019 Incremental Innovation. All rights reserved.
//

import SceneKit

class ViewController: NSViewController, SCNProgramDelegate, SCNSceneRendererDelegate, SCNNodeRendererDelegate {
    @IBOutlet var sceneView: OGLSceneView!
    var scnVAO: GLint = 0           // SceneKit's Vertex Array Object
    var programID: GLint = 0        // SceneKit's OpenGL program object

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()
        self.sceneView.scene = scene

        let shaderName = "beziersurface"
        let vertexShaderURL = Bundle.main.url(forResource: shaderName,
                                              withExtension: "vs")
        let fragmentShaderURL = Bundle.main.url(forResource: shaderName,
                                                withExtension: "fs")
        let geometryShaderURL = Bundle.main.url(forResource: shaderName,
                                                withExtension: "gs")
        let tessControlShaderURL = Bundle.main.url(forResource: shaderName,
                                                   withExtension: "tcs")
        let tessEvaluationShaderURL = Bundle.main.url(forResource: shaderName,
                                                      withExtension: "tes")
        var vertexShader: String?
        do {
            try vertexShader = String(contentsOf: vertexShaderURL!,
                                      encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load vertex shader")
        }
        var fragmentShader: String?
        do {
            try fragmentShader = String(contentsOf: fragmentShaderURL!,
                                        encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load fragment shader")
        }
        var geometryShader: String?
        do {
            try geometryShader = String(contentsOf: geometryShaderURL!,
                                        encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load geometry shader")
        }
        var tessControlShader: String?
        do {
            try tessControlShader = String(contentsOf: tessControlShaderURL!,
                                           encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load tessellation control shader")
        }
        var tessEvaluationShader: String?
        do {
            try tessEvaluationShader = String(contentsOf: tessEvaluationShaderURL!,
                                              encoding: String.Encoding.utf8)
        } catch _ {
            Swift.print("Can't load tessellation evaluation shader")
        }

        // Assumes there are no problems loading the shader source files.
        let program = SCNProgram()
        program.vertexShader = vertexShader
        program.tessellationControlShader = tessControlShader
        program.tessellationEvaluationShader = tessEvaluationShader
        program.geometryShader = geometryShader
        program.fragmentShader = fragmentShader
        program.delegate = self
        // Make this view controller object the "delegate" (SCNSceneRendererDelegate)
        // of the SCNView object.
        sceneView.delegate = self

        // Get the geometry of the patch to be rendered.
        let patch = inputPath()
        let patchNode = SCNNode(geometry: patch)
        patchNode.name = "input-patch"
        scene.rootNode.addChildNode(patchNode)

        // Only 1 vertex attribute
        program.setSemantic(SCNGeometrySource.Semantic.vertex.rawValue,
                            forSymbol: "aVertex",
                            options: nil)

        // The method setSemantic:forSymbol:options can also be called
        // with uniform variables besides vertex attributes.
        // Here we are using it to set OpenGL mat4 uniforms.
        program.setSemantic(SCNProjectionTransform,
                            forSymbol: "uProjectionMatrix",
                            options: nil)

        program.setSemantic(SCNModelViewTransform,
                            forSymbol: "uModelViewMatrix",
                            options: nil)

        // The instance of SCNProgram can also be assigned to the program property of SCNGeometry.
        // Note: if the SCNProgram is assigned to the firstMaterial of the patch,
        // then all handleBindingOfSymbol:usingBlock: calls must also be on the firstMaterial.
        patch!.firstMaterial?.program = program

        // The method handleBindingOfSymbol:usingBlock: can also be called with
        // a (user-defined) attribute name e.g. velocity besides uniform variables.
        patch!.firstMaterial?.handleBinding(ofSymbol: "uOuter02",
                                            handler: {
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

            glUniform1i(Int32(location), 10)
            //Swift.print("uOuter02", programId, location)
        })

        patch!.firstMaterial?.handleBinding(ofSymbol: "uOuter13",
                                            handler: {
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

            glUniform1i(Int32(location), 10)
            //Swift.print("uOuter13", programId, location)
        })

        patch!.firstMaterial?.handleBinding(ofSymbol: "uInner0",
                                            handler: {
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

            glUniform1i(Int32(location), 5)
            //Swift.print("uInner0", programId, location)
            if self.programID == 0 {
                // We need the vertex array object and program name used
                // by SceneKit during rendering.
                glGetIntegerv(GLenum(GL_VERTEX_ARRAY_BINDING), &self.scnVAO)
                glGetIntegerv(GLenum(GL_CURRENT_PROGRAM), &self.programID)
                //Swift.print(self.scnVAO, self.programID, programId)
            }
        })

        patch!.firstMaterial?.handleBinding(ofSymbol: "uInner1",
                                            handler: {
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

            glUniform1i(Int32(location), 5)
            //Swift.print("uInner1", programId, location)
        })

        patch!.firstMaterial?.handleBinding(ofSymbol: "uShrink",
                                            handler: {
            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

            glUniform1f(Int32(location), 0.9)
            //Swift.print("uShrink", programId, location)
        })
        //patch!.firstMaterial?.isDoubleSided = true
    }

    func checkGLError() {
        let err = glGetError()
        if err != GLenum(GL_NO_ERROR) {
            Swift.print("OpenGL error:0x%0x", err)
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }


    // Creates a patch with 16 vertices.
    func inputPath() -> SCNGeometry? {
        struct Vertex {
            let position: (GLfloat, GLfloat, GLfloat)
        }
        // Coords of the positions of the vertices of the input-patch
        let positions = [
            Vertex(position: (0.0, 2.0, 0.0)),  // vert #0
            Vertex(position: (1.0, 1.0, 0.0)),  // vert #1
            Vertex(position: (2.0, 1.0, 0.0)),
            Vertex(position: (3.0, 2.0, 0.0)),

            Vertex(position: (0.0, 1.0, 1.0)),
            Vertex(position: (1.0, -2.0, 1.0)),
            Vertex(position: (2.0, 1.0, 1.0)),
            Vertex(position: (3.0, 0.0, 1.0)),

            Vertex(position: (0.0, 0.0, 2.0)),
            Vertex(position: (1.0, 1.0, 2.0)),
            Vertex(position: (2.0, 0.0, 2.0)),
            Vertex(position: (3.0, -1.0, 2.0)),

            Vertex(position: (0.0, 0.0, 3.0)),
            Vertex(position: (1.0, 1.0, 3.0)),
            Vertex(position: (2.0, -1.0, 3.0)),
            Vertex(position: (3.0, -1.0,  3.0)) // vert #15
        ]

        var sources = [SCNGeometrySource]()
        let vertexData = Data(bytes: UnsafePointer(positions),
                              count: MemoryLayout<Vertex>.stride*positions.count)
        let vertexSource = SCNGeometrySource(data: vertexData,
                                             semantic: SCNGeometrySource.Semantic.vertex,
                                             vectorCount: positions.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<GLfloat>.stride,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Vertex>.stride)
        sources.append(vertexSource)

        // An array used to index the positions array
        let indices: [UInt8] = [
            0, 1, 2, 3,
            4, 5, 6, 7,
            8, 9, 10, 11,
            12, 13, 14, 15
        ]
        let indicesData = Data(bytes: indices)
        let geoElem = SCNGeometryElement(data: indicesData,
                                         primitiveType: SCNGeometryPrimitiveType.point,
                                         primitiveCount: indices.count,
                                         bytesPerIndex: MemoryLayout<UInt8>.stride)
        let elements = [geoElem]
        let geo = SCNGeometry(sources: sources, elements: elements)
        return geo
    }

    fileprivate var firstTime = true
    // The view port has been cleared; the current OpenGL context is SceneKit's
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        // When this method is called the first time, programID & scnVAO are both zeroes.
        if firstTime {
            // This will render both the front and back of the patch i.e. double-sided.
            glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_FILL))
            glEnable(GLenum(GL_DEPTH_TEST))
            checkGLError()
            firstTime = false
         }

        else {
            glDisable(GLenum(GL_CULL_FACE))
            // The OpenGL function below must be called only when both
            // the programID & scnVAO are known i.e. non-zero.
            // Both names are needed before the function "glDrawElements" is called.
            glPatchParameteri(GLenum(GL_PATCH_VERTICES), 16)
            self.checkGLError()

            glUseProgram(GLuint(programID))
            glBindVertexArray(GLuint(scnVAO))
            glDrawElements(GLenum(GL_PATCHES),  // # of elements to ...
                           16,                  // ... be rendered = 16
                           GLenum(GL_UNSIGNED_BYTE),
                           nil)
            checkGLError()
            glEnable(GLenum(GL_CULL_FACE))
        }
    }

    func program(_ program: SCNProgram, handleError error: Error) {
        Swift.print("%@", error.localizedDescription);
    }
}

