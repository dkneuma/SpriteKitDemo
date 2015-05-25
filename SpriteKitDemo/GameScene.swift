//
//  GameScene.swift
//  SpriteKitDemo
//
//  Created by Neumann, Daniel on 5/24/15.
//  Copyright (c) 2015 Neumann, Daniel. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
       
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
    let welcomeNode = childNodeWithName("welcomeNode")
        
        if (welcomeNode != nil) {
            let fadeAway = SKAction.fadeOutWithDuration(1.0)
            
            welcomeNode?.runAction(fadeAway, completion: {
                let doors = SKTransition.doorwayWithDuration(1.0)
                let archeryScene = ArcheryScene(fileNamed: "ArcheryScene")
                self.view?.presentScene(archeryScene, transition: doors)
            })
        }
    
    
    }
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
