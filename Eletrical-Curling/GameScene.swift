//
//  GameScene.swift
//  Eletrical-Curling
//
//  Created by Mauricio Lorenzetti on 13/07/17.
//  Copyright © 2017 Mauricio Lorenzetti. All rights reserved.
//

import SpriteKit

let initialCharge       :   CGFloat = 0.4
let initialFieldCharge  :   Float = 0.0
let defaulFieldCharge   :   Float = 0.2

let chargeTextureScale  :   CGFloat = 0.5

let TargetCategoryName = "target"
let FieldCategoryName = "field"
let FieldOriginCategoryName = "fieldOrigin"
let AreaCategoryName = "area"

let PositiveChargeCategoryName = "+"
let NegativeChargeCategoryName = "-"
let ChargeCategoryName = "charge"

let PlayButtonCategoryName = "play"
let ResetButtonCategoryName = "reset"

let ChargeCategory  :   UInt32 = 0x1 << 0
let BorderCategory  :   UInt32 = 0x1 << 1
let TargetCategory  :   UInt32 = 0x1 << 2
let FieldCategory   :   UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fields : [SKFieldNode] = []
    var charges : [SKSpriteNode] = []
    
    var running = false
    
    var isFingerOnCharge = false
    
    var whichCharge : String = ""
    
    var gameOverLabel : SKLabelNode!
    var gameOverTextLabel : SKLabelNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        gameOverLabel = childNode(withName: "gameOverLabel") as! SKLabelNode
        gameOverTextLabel = childNode(withName: "gameOverTextLabel") as! SKLabelNode
        gameOverLabel.isHidden = true
        gameOverTextLabel.isHidden = true
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        //self.physicsBody = borderBody
        
        let fieldOrigin = self.childNode(withName: FieldOriginCategoryName)
        
        let field = SKFieldNode.electricField()
        field.categoryBitMask = FieldCategory
        field.name = FieldCategoryName
        field.isEnabled = true
        field.strength = initialFieldCharge
        fieldOrigin?.addChild(field)
        field.region = SKRegion(size: self.size)
        
        fields.removeAll()
        fields.append(field)
        
        charges.removeAll()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        //let hud = childNode(withName: "hud")
        
        let target = childNode(withName: TargetCategoryName)!
        target.physicsBody!.categoryBitMask = TargetCategory
        target.physicsBody!.contactTestBitMask = ChargeCategory
        target.physicsBody!.collisionBitMask = ChargeCategory
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ChargeCategory && secondBody.categoryBitMask == TargetCategory {
            pausePhysicsSimulation()
            gameOverLabel.isHidden = false
            gameOverTextLabel.isHidden = false
        }
    }
    
    func createProbeCharge(charge: Bool) -> SKSpriteNode {
        let newChargeNode = SKSpriteNode(imageNamed:
            charge ? PositiveChargeCategoryName : NegativeChargeCategoryName)
        newChargeNode.position = CGPoint(x: 150, y: 160)
        charges.append(newChargeNode)
        newChargeNode.name = "\(ChargeCategoryName)\(charges.count)"
        newChargeNode.zPosition = 1
        newChargeNode.setScale(chargeTextureScale)
        
        let newCharge = SKPhysicsBody(circleOfRadius:
            chargeTextureScale * newChargeNode.texture!.size().width/2)
        newCharge.isDynamic = true
        newCharge.allowsRotation = false
        newCharge.friction = 0
        newCharge.restitution = 0
        newCharge.charge = initialCharge * (charge ? 1 : -1)
        newCharge.categoryBitMask = ChargeCategory
        newCharge.contactTestBitMask = TargetCategory
        newCharge.collisionBitMask = TargetCategory
        newCharge.fieldBitMask = FieldCategory
        
        newChargeNode.physicsBody = newCharge
        
        return newChargeNode
    }
    
    func startPhysicsSimulation() {
        for f in fields {
            f.strength = defaulFieldCharge
        }
        running = true
    }
    
    func pausePhysicsSimulation() {
        for f in fields {
            f.strength = initialFieldCharge
        }
        for charge in charges {
            charge.removeAllActions()
            charge.speed = 0
        }
        running = false
    }
    
    func resetPhysicsSimulation() {
        for f in fields {
            f.strength = initialFieldCharge
        }
        for charge in charges {
            charge.removeFromParent()
        }
        running = false
        
        gameOverLabel.isHidden = true
        gameOverTextLabel.isHidden = true
    }
    
    func addCharge(_ chargeType: String) {
        if (!running) {
            self.addChild(createProbeCharge(charge: chargeType == PositiveChargeCategoryName))
        }
    }
    
    override func didSimulatePhysics() {
        for charge in charges {
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let scene = self.scene {
            if  !gameOverLabel.isHidden {
                resetPhysicsSimulation()
            }
            
            let viewTouchLocation = touch?.location(in: self.view)
            let sceneTouchPoint = scene.convertPoint(fromView: viewTouchLocation!)
            let touchedNodes = scene.nodes(at: sceneTouchPoint)
            
            for node in touchedNodes {
                if node.name == PlayButtonCategoryName {
                    if running {
                        pausePhysicsSimulation()
                    } else {
                        startPhysicsSimulation()
                    }
                    
                } else if node.name == ResetButtonCategoryName {
                    resetPhysicsSimulation()
                    
                } else if node.name == PositiveChargeCategoryName {
                    addCharge(PositiveChargeCategoryName)
                    
                } else if node.name == NegativeChargeCategoryName {
                    addCharge(NegativeChargeCategoryName)
                    
                } else if let n = node.name {
                    if n.contains(ChargeCategoryName) {
                        isFingerOnCharge = true
                        whichCharge = node.name!
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnCharge {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            let charge = childNode(withName: whichCharge) as! SKSpriteNode
            
            var chargeX = charge.position.x + (touchLocation.x - previousLocation.x)
            let chargeY = charge.position.y + (touchLocation.y - previousLocation.y)
            
            let area = childNode(withName: AreaCategoryName)
            //chargeX = max(chargeX, (area?.frame.minX)!)
            //chargeX = min(chargeX, (area?.frame.maxX)!)
            
            charge.position = CGPoint(x: chargeX, y: chargeY)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnCharge = false
    }
    
    
}
