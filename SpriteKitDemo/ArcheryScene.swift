//
//  ArcheryScene.swift
//  
//
//  Created by Neumann, Daniel on 5/24/15.
//
//

import UIKit
import SpriteKit

class ArcheryScene: SKScene {
    var score = 0
    var ballCount = 20
    var archerAnimation = [SKTexture]()
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0, -1.0)
        self.initArcheryScene()
    }
    func createArrowNode() -> SKSpriteNode {
        let archerNode = self.childNodeWithName("archerNode")
        let archerPosition = archerNode?.position
        let archerWidth = archerNode?.frame.size.width
        
        let arrow = SKSpriteNode(imageNamed: "ArrowTexture.png")
        arrow.position = CGPointMake(archerPosition!.x + archerWidth!,
            archerPosition!.y)
        arrow.name = "arrowNode"
        
        arrow.physicsBody = SKPhysicsBody(rectangleOfSize:
            arrow.frame.size)
        
        arrow.physicsBody?.usesPreciseCollisionDetection = true
        
        return arrow
    }
    func createBallNode() {
        let ball = SKSpriteNode(imageNamed: "BallTexture.png")
        ball.position = CGPointMake(randomBetween(0, high:
            self.size.width-200), self.size.height-50)
        
        ball.name = "ballNode"
        ball.physicsBody = SKPhysicsBody(circleOfRadius:
            (ball.size.width/2))
        
        ball.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(ball)
    }
    
    
    func randomBetween(low: CGFloat, high: CGFloat) -> CGFloat
    {
        let lowInt = UInt32(low)
        let highInt = UInt32(high) - UInt32(low)
        let result = arc4random_uniform(highInt) + UInt32(low)
        return CGFloat(result)
    }
    
    func initArcheryScene() {
        let archerAtlas = SKTextureAtlas(named: "archer")
        
        for index in 1...archerAtlas.textureNames.count {
            let texture = String(format: "archer%03d", index)
            archerAnimation += [archerAtlas.textureNamed(texture)]
        }
        
        let releaseBalls = SKAction.sequence([SKAction.runBlock({
            self.createBallNode() }),
            SKAction.waitForDuration(1)])
        
        self.runAction(SKAction.repeatAction(releaseBalls,
            count: ballCount), completion: nil)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let archerNode = self.childNodeWithName("archerNode")
        
        if archerNode != nil {
            let animate = SKAction.animateWithTextures(archerAnimation,
                timePerFrame: 0.05)
            
            let shootArrow = SKAction.runBlock({
                let arrowNode = self.createArrowNode()
                self.addChild(arrowNode)
                arrowNode.physicsBody?.applyImpulse(CGVectorMake(60.0, 0))
            })
            let sequence = SKAction.sequence([animate, shootArrow])
            archerNode?.runAction(sequence)
        }
    }

}
