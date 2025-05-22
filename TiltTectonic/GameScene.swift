//
//  GameScene.swift
//  TiltTectonic
//
//  Created by Mirabella on 22/05/25.
//

import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    var platform: SKShapeNode!
    var shapesDropped = 0
    var externalTiltBinding: Binding<Double> = .constant(0)
    var onWin: (() -> Void)?
    var onLose: (() -> Void)?
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        shapesDropped = 0 // reset counter
        addPlatform()
        startDroppingShapes()
    }
    
    func addPlatform() {
        platform = SKShapeNode(rectOf: CGSize(width: 350, height: 20))
        platform.fillColor = .darkGray
        platform.position = CGPoint(x: frame.midX, y: 100)
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 20))
        platform.physicsBody?.isDynamic = false
        platform.name = "platform"
        addChild(platform)
    }
    
    func startDroppingShapes() {
        let wait = SKAction.wait(forDuration: 2.0)
        let drop = SKAction.run { [weak self] in
            self?.dropShape()
        }
        let sequence = SKAction.sequence([drop, wait])
        run(SKAction.repeatForever(sequence), withKey: "dropLoop")
    }
    
    func dropShape() {
        guard shapesDropped < 10 else { return }
        
        let size = CGFloat.random(in: 30...50)
        let shapeType = Int.random(in: 0...2)
        let shape: SKShapeNode
        
        switch shapeType {
        case 0:
            shape = SKShapeNode(rectOf: CGSize(width: size, height: size))
        case 1:
            shape = SKShapeNode(circleOfRadius: size / 2)
        default:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -size / 2, y: -size / 2))
            path.addLine(to: CGPoint(x: 0, y: size / 2))
            path.addLine(to: CGPoint(x: size / 2, y: -size / 2))
            path.closeSubpath()
            shape = SKShapeNode(path: path)
        }
        
        shape.fillColor = SKColor.random()
        shape.position = CGPoint(x: CGFloat.random(in: 80...320), y: frame.maxY)
        shape.physicsBody = SKPhysicsBody(polygonFrom: shape.path ?? CGPath(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size), transform: nil))
        shape.physicsBody?.restitution = 0.2
        shape.name = "falling"
        addChild(shape)
        
        shapesDropped += 1
        
        if shapesDropped == 10 {
            // delay for stack to settle
            run(SKAction.wait(forDuration: 3.0)) { [weak self] in
                guard let self = self else { return }
                if !self.hasAnyFallen() {
                    DispatchQueue.main.async {
                        self.onWin?()
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // update tilt
        let tiltAngle = CGFloat(externalTiltBinding.wrappedValue) * .pi / 180
        platform.zRotation = tiltAngle
    }
    
    override func didSimulatePhysics() {
        for node in children {
            if node.name == "falling", node.position.y < -50 {
                gameOver()
                break
            }
        }
    }
    
    func gameOver() {
        removeAction(forKey: "dropLoop")
        isPaused = true
        DispatchQueue.main.async {
            self.onLose?()
        }
    }
    
    func hasAnyFallen() -> Bool {
        return children.contains { $0.name == "falling" && $0.position.y < -50 }
    }
}
