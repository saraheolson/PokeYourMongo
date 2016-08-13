//
//  Ball.swift
//  PokeYourMongo
//
//  Created by Floater on 8/13/16.
//  Copyright © 2016 WomenWhoCode. All rights reserved.
//

import UIKit
import SpriteKit

class Ball {
    
    var node: SKSpriteNode?
    
    init() {
        
        // Create a new ball
        node = SKSpriteNode(imageNamed: "ball")
        
        if let ball = node {
            ball.position = CGPointMake(304, 113)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.dynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.categoryBitMask = ballMask
            
            // Define which objects it can collide with or contact
            ball.physicsBody?.collisionBitMask = monsterMask | ballMask
            ball.physicsBody?.contactTestBitMask = wallMask | monsterMask | ballMask
        }
    }
}
