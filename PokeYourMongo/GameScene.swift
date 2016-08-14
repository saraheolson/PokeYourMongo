//
//  GameScene.swift
//  PokeYourMongo
//
//  Created by Floater on 8/5/16.
//  Copyright (c) 2016 WomenWhoCode. All rights reserved.
//

import SpriteKit
import AVFoundation

let wallMask:UInt32 = 0x1 << 0 // 1
let ballMask:UInt32 = 0x1 << 1 // 2
let monsterMask:UInt32 = 0x1 << 2 // 4

protocol MonsterHitCountDelegate {
    func hitCountUpdated(hitCount: Int)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Define our sprites
    var monster: Monster?
    var ball: Ball?
    var label: SKLabelNode?
    
    // Defines where user touched
    var touchLocation: CGPoint = CGPointZero

    var monsters: [Monster] = []
    
    var hitCount = 0
    var hitCountDelegate: MonsterHitCountDelegate?
    
    override func didMoveToView(view: SKView) {
        
        // Set this scene as transparent so we can see the camera view behind it
        view.backgroundColor = UIColor.clearColor()
        view.allowsTransparency = true
        
        monsters = Monster.allMonsters(UInt32(frame.height), screenWidth: UInt32(frame.width))
        
        createMonster()
        createBall()
        
        label = childNodeWithName("label") as? SKLabelNode
        label?.hidden = true
        
        // Assign this scene as a delegate so we get collision event notifications
        self.physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ball?.node?.physicsBody?.applyImpulse(CGVectorMake(0.0, 100.0))
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let ball = (contact.bodyA.categoryBitMask == ballMask) ? contact.bodyA : contact.bodyB
        let other = (ball == contact.bodyA) ? contact.bodyB : contact.bodyA
        if other.categoryBitMask == monsterMask {
            print("hit monster!")
            self.didHitMonster()
        } else if other.categoryBitMask == wallMask {
            print("hit wall!")
            resetBallPosition()
        }
        resetBallPosition()
    }
    
    func didHitMonster() {
        
        if let monster = monster, node = monster.node {
            
            let spark:SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
            spark.position = node.position
            spark.particleColor = monster.hitColor
            self.addChild(spark)

            resetBallPosition()

            monster.directHit()
            label?.hidden = false
            
            self.monster = nil

            hitCount += 1
            hitCountDelegate?.hitCountUpdated(hitCount)
            
            // Create a new monster after a short delay
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                if self.monster == nil {
                    self.createMonster()
                }
                self.label?.hidden = true
            }
        }
    }
    
    func resetBallPosition() {
        ball?.node?.removeFromParent()
        createBall()
    }
    
    func pauseGamePlay() {
        ball?.node?.removeAllActions()
        monster?.stopMovement()
    }
    
    func startGamePlay() {
        monster?.startMovement()
    }
    
    // MARK: - Sprite Creation methods
    
    func createBall() {
        
        ball = Ball()
        
        if let node = ball?.node {
            addChild(node)
        }
    }
    
    func createMonster() {
        
        monster = randomMonster()
        monster?.configureMonster()
        
        if let node = monster?.node {
            addChild(node)
        }
    }
    
    func randomMonster() -> Monster {
        let monsterCount = UInt32(monsters.count)
        let imageNumber = Int(arc4random_uniform(monsterCount))
        return monsters[imageNumber]
    }
}
