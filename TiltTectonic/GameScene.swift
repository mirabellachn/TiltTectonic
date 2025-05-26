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
    var hasEnded = false

    var externalTiltBinding: Binding<Double> = .constant(0)
    var onWin: (() -> Void)?
    var onLose: (() -> Void)?
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        shapesDropped = 0
        hasEnded = false
        addPlatform()
        addWeight()
        startDroppingShapes()
    }
    
    func addPlatform() {
        let platformSize = CGSize(width: 350, height: 30)
        platform = SKShapeNode(rectOf: platformSize)
        platform.fillColor = .darkGray
        platform.position = CGPoint(x: frame.midX, y: 100)
        let body = SKPhysicsBody(rectangleOf: platformSize)
        body.isDynamic = false
        body.categoryBitMask = 0x1 << 0
        body.contactTestBitMask = 0x1 << 1
        body.collisionBitMask = 0x1 << 1 | 0x1 << 2
        platform.physicsBody = body
        platform.name = "platform"
        addChild(platform)
    }
    
    func addWeight() {
        let weightSize = CGSize(width: 60, height: 60)
        let weight = SKShapeNode(circleOfRadius: weightSize.width / 2)
        weight.fillColor = .black
        // Posisi tepat di atas platform
        weight.position = CGPoint(x: frame.midX, y: platform.position.y + 50)
        
        let body = SKPhysicsBody(circleOfRadius: weightSize.width / 2)
        body.mass = 5.0            // Massa pemberat lebih besar
        body.friction = 0.9
        body.restitution = 0.1
        body.linearDamping = 0.3
        body.categoryBitMask = 0x1 << 2
        body.contactTestBitMask = 0x1 << 1
        body.collisionBitMask = 0x1 << 0 | 0x1 << 1 | 0x1 << 2
        weight.physicsBody = body
        
        weight.name = "weight"
        addChild(weight)
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
        
        let body = SKPhysicsBody(polygonFrom: shape.path ?? CGPath(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size), transform: nil))
        body.restitution = 0.2
        body.friction = 0.8
        body.linearDamping = 0.5
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 0x1 << 1
        body.contactTestBitMask = 0x1 << 0 | 0x1 << 2
        body.collisionBitMask = 0x1 << 0 | 0x1 << 2
        shape.physicsBody = body
        
        shape.name = "falling"
        addChild(shape)
        shapesDropped += 1
        
        if shapesDropped == 10 {
            run(SKAction.wait(forDuration: 3.0)) { [weak self] in
                guard let self = self else { return }
                if !self.hasAnyFallen() && !self.hasEnded {
                    self.hasEnded = true
                    DispatchQueue.main.async {
                        self.onWin?()
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let tiltAngle = CGFloat(externalTiltBinding.wrappedValue) * .pi / 180
        platform.zRotation = tiltAngle
    }
    
    override func didSimulatePhysics() {
        guard !hasEnded else { return }
        
        for node in children {
            if node.name == "falling", node.position.y < -50 {
                gameOver()
                break
            }
        }
    }
    
    func gameOver() {
        guard !hasEnded else { return }
        hasEnded = true
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
