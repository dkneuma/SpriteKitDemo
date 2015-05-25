//
//  ArcheryScene.swift
//  
//
//  Created by Neumann, Daniel on 5/24/15.
//
//

import UIKit
import SpriteKit

class ArcheryScene: SKScene, SKPhysicsContactDelegate {

    let arrowCategory: UInt32 = 0x1 << 0
    let ballCategory: UInt32 = 0x1 << 1
    
    var score = 0
    var ballCount = 20
    var archerAnimation = [SKTexture]()
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0, -1.0)
        self.physicsWorld.contactDelegate = self
        
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
        arrow.physicsBody?.categoryBitMask = arrowCategory
        arrow.physicsBody?.collisionBitMask = arrowCategory | ballCategory
        arrow.physicsBody?.contactTestBitMask = arrowCategory | ballCategory
        
        return arrow
    }
    func createBallNode() {
        let ball = SKSpriteNode(imageNamed: "BallTexture.png")
        ball.position = CGPointMake(randomBetween(100, high:
            self.size.width-200), self.size.height-50)
        
        ball.name = "ballNode"
        ball.physicsBody = SKPhysicsBody(circleOfRadius:
            (ball.size.width/2))
        
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = ballCategory
        self.addChild(ball)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
        if (contact.bodyA.categoryBitMask == arrowCategory) &&
            (contact.bodyB.categoryBitMask == ballCategory) {
                
                let contactPoint = contact.contactPoint
                let contact_y = contactPoint.y
                let target_x = secondNode.position.x
                let target_y = secondNode.position.y
                let margin = secondNode.frame.size.height/2 - 25
                
                if (contact_y > (target_y - margin))
                    && (contact_y < (target_y + margin)) {
                        
                        let burstPath = NSBundle.mainBundle().pathForResource(
                            "BurstParticle", ofType: "sks")
                        
                        if burstPath != nil {
                            let burstNode =
                            NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
                                as! SKEmitterNode
                            burstNode.position = CGPointMake(target_x, target_y)
                            secondNode.removeFromParent()
                            self.addChild(burstNode)
                        }
                        score++
                }
        }
    }
    
    func createScoreNode() -> SKLabelNode {
        let scoreNode = SKLabelNode(fontNamed: "Bradley Hand")
        scoreNode.name = "scoreNode"
        
        let newScore = "Score \(score)"
        
        scoreNode.text = newScore
        scoreNode.fontSize = 60
        scoreNode.fontColor = SKColor.redColor()
        scoreNode.position = CGPointMake(CGRectGetMidX(self.frame),
            CGRectGetMidY(self.frame))
        return scoreNode
    }
    func gameOver() {
        let scoreNode = self.createScoreNode()
        self.addChild(scoreNode)
        let fadeOut = SKAction.sequence([SKAction.waitForDuration(3.0),
            SKAction.fadeOutWithDuration(3.0)])
        
        let welcomeReturn =  SKAction.runBlock({
            let transition = SKTransition.revealWithDirection(
                SKTransitionDirection.Down, duration: 1.0)
            let welcomeScene = GameScene(fileNamed: "GameScene")
            self.scene!.view?.presentScene(welcomeScene,
                transition: transition)
        })
        
        let sequence = SKAction.sequence([fadeOut, welcomeReturn])
        
        self.runAction(sequence)
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
            count: ballCount), completion: {
                let sequence =
                SKAction.sequence([SKAction.waitForDuration(5.0),
                    SKAction.runBlock({ self.gameOver() })])
                self.runAction(sequence)
        })
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let archerNode = self.childNodeWithName("archerNode")
        
        if archerNode != nil {
            let animate = SKAction.animateWithTextures(archerAnimation,
                timePerFrame: 0.02)
            
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
