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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // List of monster sprite atlases
    var monsterNames = ["BlueMonster", "PurpleMonster", "BlackMonster", "GreenMonster"]
    
    // Define our sprites
    var monster: SKSpriteNode?
    var ball: SKSpriteNode?
    
    // Defines where user touched
    var touchLocation: CGPoint = CGPointZero

    // Define colors used for spark particle
    let sparkColor = UIColor(red: 0.16, green: 0.73, blue: 0.78, alpha: 1.0)
    
    // Stores the array of sprite images for animations
    var spriteArray = Array<SKTexture>();

    
    override func didMoveToView(view: SKView) {
        
        // Set this scene as transparent so we can see the camera view behind it
        view.backgroundColor = UIColor.clearColor()
        view.allowsTransparency = true
        
        createMonster()
        createBall()
        
        // Assign this scene as a delegate so we get collision event notifications
        self.physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ball?.physicsBody?.applyImpulse(CGVectorMake(0.0, 100.0))
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let ball = (contact.bodyA.categoryBitMask == ballMask) ? contact.bodyA : contact.bodyB
        let other = (ball == contact.bodyA) ? contact.bodyB : contact.bodyA
        if other.categoryBitMask == monsterMask {
            print("hit monster!")
            self.didHitMonster(other)
        } else if other.categoryBitMask == wallMask {
            print("hit wall!")
            resetBallPosition()
        }
        resetBallPosition()
    }
    
    func didHitMonster(monsterBody:SKPhysicsBody) {
        
        if let monsterNode = monsterBody.node {
            
            let spark:SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
            spark.position = monsterNode.position
            spark.particleColor = sparkColor
            self.addChild(spark)

            resetBallPosition()

            monsterNode.removeAllActions()
            monsterNode.removeFromParent()
            self.monster = nil

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                if self.monster == nil {
                    self.createMonster()
                }
            }
        }
    }
    
    func resetBallPosition() {
        ball?.removeFromParent()
        createBall()
    }
    
    func pauseGamePlay() {
        ball?.removeAllActions()
        monster?.removeAllActions()
    }
    
    func startGamePlay() {
        runMonsterActions()
    }
    
    // MARK: - Sprite Creation methods
    
    func createBall() {
        
        // Create a new ball
        ball = SKSpriteNode(imageNamed: "ball")
        
        if let ball = ball {
            ball.position = CGPointMake(304, 113)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.dynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.categoryBitMask = ballMask
            
            // Define which objects it can collide with or contact
            ball.physicsBody?.collisionBitMask = monsterMask | ballMask
            ball.physicsBody?.contactTestBitMask = wallMask | monsterMask | ballMask
            
            addChild(ball)
        }
    }
    
    func createMonster() {
        
        print("Create Monster")
        
        let monsterName = randomMonsterImageName()

        let textureAtlas = SKTextureAtlas(named:"\(monsterName).atlas")
        
        // Programmatically add sprite animation
        spriteArray = [textureAtlas.textureNamed("\(monsterName)1"),
                       textureAtlas.textureNamed("\(monsterName)2")]

        monster = SKSpriteNode(texture:spriteArray[0]);
        
        if let monster = monster {
            monster.position = CGPoint(x: frame.width/2, y: frame.height/2)
            monster.zPosition = 2
            monster.physicsBody = SKPhysicsBody(texture: monster.texture!, size: monster.frame.size)
            monster.physicsBody?.dynamic = true
            monster.physicsBody?.affectedByGravity = false
            monster.physicsBody?.allowsRotation = false
            monster.physicsBody?.categoryBitMask = monsterMask
            monster.physicsBody?.collisionBitMask = ballMask
            monster.physicsBody?.contactTestBitMask = ballMask
            
            let scale = randomScale()
            monster.xScale = scale;
            monster.yScale = scale;

            runMonsterActions()
            
            addChild(monster);
        }
    }
    
    func runMonsterActions() {
        
        if let monster = monster {
            let forwardAction = SKAction.moveToX(frame.width, duration: 1.0)
            let reverseAction = SKAction.moveToX(0, duration: 1.0)
            let moveSequence = SKAction.sequence([forwardAction, reverseAction])
            let repeatMoves = SKAction.repeatActionForever(moveSequence)
            monster.runAction(repeatMoves)
            
            let animateAction = SKAction.animateWithTextures(spriteArray, timePerFrame: 0.20);
            let repeatAnimation = SKAction.repeatActionForever(animateAction)
            monster.runAction(repeatAnimation)
        }
    }
    
    func randomMonsterImageName() -> String {
        let monsterCount = UInt32(monsterNames.count)
        let imageNumber = Int(arc4random_uniform(monsterCount))
        return monsterNames[imageNumber]
    }
    
    func randomScale() -> CGFloat {
        
        // Number between 0.2 and 1
        return (CGFloat(arc4random()) /  CGFloat(UInt32.max)) + 0.2
    }
}
