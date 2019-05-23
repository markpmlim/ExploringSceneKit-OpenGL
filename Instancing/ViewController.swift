//
//  ViewController.swift
//  Instancing2
//
//  Created by mark lim pak mun on 12/2/16.
//  Copyright © 2016 Incremental Innovation. All rights reserved.
// Ref: pg 308 LearnOpenGL 3.3
// To test if SceneKit has support for instanced arrays
// Appears to be working - all 100 rects are displayed now.
// Removing the phrase layout (location=n) from each declaration of
// 4 vertex attributes will work. In other words, let Apple's OpenGL
// implementation takes care of the location of each vertex attribute.
// Alternatively, the shader can be modified to add color to the 4 vertices of each rect.

import SceneKit
import OpenGL.GL3

class ViewController: NSViewController, SCNProgramDelegate, SCNSceneRendererDelegate {
    @IBOutlet var sceneView: OGLSceneView!
    var texture: GLKTextureInfo?
    var offsets: [GLKVector2] = [GLKVector2](repeating: GLKVector2(), count: 100)
    var instanceVBO: GLuint = 0

    // do our initialization here.
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()
        self.sceneView.scene = scene

        let shaderName = "instancing"
        let vertexShaderURL = Bundle.main.url(forResource: shaderName,
                                              withExtension: "vs")
        let fragmentShaderURL = Bundle.main.url(forResource: shaderName,
                                                withExtension: "fs")

        var vertexShader: String?
        do {
            try vertexShader = String(contentsOf: vertexShaderURL!,
                                      encoding: String.Encoding.utf8)
        }
        catch let error {
            Swift.print("Error loading vertex shader source:\(error)")
        }

        var fragmentShader: String?
        do {
            try fragmentShader = String(contentsOf: fragmentShaderURL!,
                                        encoding: String.Encoding.utf8)
        }
        catch let error {
            Swift.print("Error loading fragment shader source:\(error)")
        }

        let quad = createGeometry()
        let quadNode = SCNNode(geometry: quad)
        quadNode.name = "quad0"
        let program = SCNProgram()
        program.vertexShader = vertexShader
        program.fragmentShader = fragmentShader
        program.delegate = self
        sceneView.delegate = self       // SCNSceneRenderer protocol
        quad!.program = program
        scene.rootNode.addChildNode(quadNode)

        //Swift.print("init translation array")
        let offset: GLfloat = 0.1
        var index = 0
        for y in stride(from: -10, to: 10, by: 2) {
            for x in stride(from: -10, to: 10, by: 2) {
                let v = GLKVector2Make(GLfloat(x)/10.0 + offset,
                                       GLfloat(y)/10.0 + offset)
                offsets[index] = v
                index += 1
            }
        }

        // vertex attributes
        program.setSemantic(SCNGeometrySource.Semantic.vertex.rawValue,
                            forSymbol: "position",
                            options: nil)
        // This attribute is not used.
        program.setSemantic(SCNGeometrySource.Semantic.normal.rawValue,
                            forSymbol: "normal",
                            options: nil)

        program.setSemantic(SCNGeometrySource.Semantic.color.rawValue,
                            forSymbol: "color",
                            options: nil)

        var transferred = false
        // SceneKit may respect the locations indicated in the vertex shader.
        // However, we have removed the phrase "layout (location=n)" from each vertex attribute.
        quad!.handleBinding(ofSymbol: "offset",
                            handler: {

            (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

            if (!transferred) {
                // Normally we need to perform a glBindVertexArray call here.
                // However, it appears that the correct vertex array object (VAO) is already bind.
                glGenBuffers(1, &self.instanceVBO)
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.instanceVBO)
                glBufferData(GLenum(GL_ARRAY_BUFFER),
                             MemoryLayout<GLKVector2>.stride*self.offsets.count,
                             &self.offsets,
                             GLenum(GL_STATIC_DRAW))
                self.checkGLError()
                glVertexAttribPointer(location,
                                      2,                        // size
                                      GLenum(GL_FLOAT),
                                      GLboolean(GL_FALSE),      // not normalized
                                      0,                        // tightly-packed
                                      nil)
                glEnableVertexAttribArray(location)
                // Tell OpenGL the uniform "offset" is an instanced vertex attribute.
                // The content of this attribute is updated whenever we want to
                // render a new instance of the quad. If the value of the 2nd parameter is n,
                // then the contents is updated every n instances.
                glVertexAttribDivisor(location, 1)  // Tell OpenGL "offset" is an instanced vertex attribute.
                self.checkGLError()
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
                self.checkGLError()
                transferred = true
            }

            glDrawArraysInstanced(GLenum(GL_TRIANGLES), 0, 6, 100);
            self.checkGLError()
            //Swift.print("offset")
        })
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // Set up the geometry of a multi-colored quad.
    func createGeometry() -> SCNGeometry? {
        struct Vertex {
            var position: (GLfloat, GLfloat)
            var normal: (GLfloat, GLfloat, GLfloat)
            var color: (GLfloat, GLfloat, GLfloat)
        }

        var sources = [SCNGeometrySource]()
        // use normalized device coords (NDC) for the rectangles
        let vertices = [
            Vertex(position:(0.05, -0.05), normal: (0.0, 0.0, 1.0), color: (0.0, 1.0, 0.0)),
            Vertex(position:(-0.05, 0.05), normal: (0.0, 0.0, 1.0), color: (1.0, 0.0, 0.0)),
            Vertex(position:(-0.05, -0.05), normal: (0.0, 0.0, 1.0), color: (0.0, 0.0, 1.0)),

            Vertex(position:(-0.05, 0.05),  normal: (0.0, 0.0, 1.0), color: (1.0, 0.0, 0.0)),
            Vertex(position:(0.05, -0.05), normal: (0.0, 0.0, 1.0), color: (0.0, 1.0, 0.0)),
            Vertex(position:(0.05, 0.05), normal: (0.0, 0.0, 1.0), color: (0.0, 1.0, 1.0)),
        ]
 
        let vertexData = Data(bytes: UnsafePointer(vertices),
                              count: MemoryLayout<Vertex>.stride * vertices.count)
        let vertexSource = SCNGeometrySource(data: vertexData,
                                             semantic: SCNGeometrySource.Semantic.vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 2,
                                             bytesPerComponent: MemoryLayout<GLfloat>.stride,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Vertex>.stride)
        sources.append(vertexSource)
        let normalSource = SCNGeometrySource(data: vertexData,
                                             semantic: SCNGeometrySource.Semantic.normal,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<GLfloat>.stride,
                                             dataOffset: 2 * MemoryLayout<GLfloat>.stride,
                                             dataStride: MemoryLayout<Vertex>.stride)
        sources.append(normalSource)
        let colorSource = SCNGeometrySource(data: vertexData,
                                            semantic: SCNGeometrySource.Semantic.color,
                                            vectorCount: vertices.count,
                                            usesFloatComponents: true,
                                            componentsPerVector: 3,
                                            bytesPerComponent: MemoryLayout<GLfloat>.stride,
                                            dataOffset: 5 * MemoryLayout<GLfloat>.stride,
                                            dataStride: MemoryLayout<Vertex>.stride)
        sources.append(colorSource)

        let indices: [UInt8] = [0, 1, 2, 3, 4, 5]       // ccw
        let indicesData = Data(bytes: UnsafePointer(indices),
                               count: MemoryLayout<UInt8>.stride * indices.count)
        let geoElem = SCNGeometryElement(data: indicesData,
                                         primitiveType: SCNGeometryPrimitiveType.triangles,
                                         primitiveCount: 2,
                                         bytesPerIndex: MemoryLayout<UInt8>.stride)
        let elements = [geoElem]
        let geo = SCNGeometry(sources: sources, elements: elements)
        return geo
    }

    // Report if an OpenGL function call returns an error.
    func checkGLError() {
        let err = glGetError()
        if err != GLenum(GL_NO_ERROR) {
            NSLog("GL error:0x%0x", err)    // 0x502 - invalid operation
        }
    }

    fileprivate var firstTime = true

    // The view port has been cleared
    // The parameter "renderer" is an instance of SceneView
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        // Currently, we don't have to do anything here.
     }
    
    func program(_ program: SCNProgram, handleError error: Error) {
        NSLog("%@", error.localizedDescription);
    }

    // This might not be necessary.
    deinit {
        //Swift.print("deinit")
        glDeleteBuffers(1, &instanceVBO)
    }
}

