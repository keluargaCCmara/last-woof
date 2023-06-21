//
//  MainMenuScene.swift
//  Last Woof
//
//  Created by Angelica Patricia on 19/06/23.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let object: UInt32 = 0b1
    static let character: UInt32 = 0b1
    static let obstacle: UInt32 = 0b10
}

class MainMenuScene: SKScene, SKPhysicsContactDelegate {
    
    private var entities: [GKEntity] = []
    
    enum NodesZPosition: CGFloat {
        case background, title, elements, buttons
    }
    
    private var cursor : SKSpriteNode!

    lazy var background: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-Background")
        sprite.position = CGPoint.zero
        sprite.zPosition = NodesZPosition.background.rawValue
        sprite.setScale(0.4)
        return sprite
    }()
    
    
    lazy var title: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-Title")
        sprite.position = CGPoint(x: frame.midX, y: frame.midY+100)
        sprite.zPosition = NodesZPosition.title.rawValue
        sprite.setScale(0.18)
        return sprite
    }()
    
    lazy var bone: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-Bone")
        sprite.position = CGPoint(x: frame.midX+270, y: frame.midY+5)
        sprite.zPosition = NodesZPosition.elements.rawValue
        sprite.setScale(0.1)
        sprite.run(
            SKAction.repeatForever(
                SKAction.sequence(
                    [
                        SKAction.move(by: CGVector(dx: 0.0, dy: -10.0), duration: 1.5),
                        SKAction.move(by: CGVector(dx: 0.0, dy: +10.0), duration: 1.5)
                    ]
                )
            )
        )
        sprite.name = "bone"
        return sprite
    }()
    
    lazy var dogfood: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-DogFood")
        sprite.position = CGPoint(x: frame.midX+180, y: frame.midY-100)
        sprite.zPosition = NodesZPosition.elements.rawValue
        sprite.setScale(0.08)
        sprite.run(
            SKAction.repeatForever(
                SKAction.sequence(
                    [
                        SKAction.move(by: CGVector(dx: 0.0, dy: +10.0), duration: 1.5),
                        SKAction.move(by: CGVector(dx: 0.0, dy: -10.0), duration: 1.5)
                    ]
                )
            )
        )
        sprite.name = "dogfood"
        return sprite
    }()

    lazy var colar: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-Colar")
        sprite.position = CGPoint(x: frame.midX-250, y: frame.midY-20)
        sprite.zPosition = NodesZPosition.elements.rawValue
        sprite.setScale(0.15)
        sprite.run(
            SKAction.repeatForever(
                SKAction.sequence(
                    [
                        SKAction.wait(forDuration: 0.4),
                        SKAction.move(by: CGVector(dx: 0.0, dy: -15.0), duration: 1.5),
                        SKAction.move(by: CGVector(dx: 0.0, dy: +15.0), duration: 1.5)
                    ]
                )
            )
        )
        sprite.name = "colar"
        return sprite
    }()
    
    lazy var playbutton: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-PlayButton")
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        sprite.zPosition = NodesZPosition.buttons.rawValue
        sprite.setScale(0.1)
        sprite.name = "PlayButton"
        return sprite
    }()
    
    lazy var memoriesbutton: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-MemoriesButton")
        sprite.position = CGPoint(x: frame.midX, y: frame.midY-55)
        sprite.zPosition = NodesZPosition.buttons.rawValue
        sprite.setScale(0.1)
        sprite.name = "MemoriesButton"
        return sprite
    }()
    
    lazy var creditbutton: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "MainMenu-CreditButton")
        sprite.position = CGPoint(x: frame.midX, y: frame.midY-110)
        sprite.zPosition = NodesZPosition.buttons.rawValue
        sprite.setScale(0.1)
        sprite.name = "CreditButton"
        return sprite
    }()
    
    private var smokeParticleRight : SKEmitterNode!
    private var smokeParticleLeft : SKEmitterNode!


    
    override func sceneDidLoad() {
        
        physicsWorld.contactDelegate = self
        
        setupNodes()

        // Set the cursor image using an SKSpriteNode
        self.cursor = SKSpriteNode(imageNamed: "MainMenu-Tap")
        if let cursor = self.cursor {
            cursor.size = CGSize(width: 20, height: 20)
            cursor.zPosition = 1 // Ensure the background is above other nodes
            cursor.run(SKAction.sequence([SKAction.scale(by: 1.5, duration: 0.1),
                                          SKAction.fadeOut(withDuration: 0.1),
                                          SKAction.removeFromParent()]))
        }
    }
    
    private func generateEntity(components: [GKComponent]) -> GKEntity {
            let entity = GKEntity()
            components.forEach { component in
                entity.addComponent(component)
            }
            return entity
        }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.cursor?.copy() as! SKSpriteNode? {
            n.position = pos
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let touch = t
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name {
                if name == "PlayButton" || name == "MemoriesButton" || name == "CreditButton" {
                    print(name)
                    touchedNode.run(SKAction.sequence([
                        SKAction.scale(by: 1.1, duration: 0.05),
                        SKAction.scale(by: 0.9, duration: 0.05)
                    ])
                    )
                    
                    // Set the smoke particle using an SKSpriteNode
                    let smokeParticleRight = SKEmitterNode(fileNamed: "HomeSmoke")!
                    smokeParticleRight.position = CGPoint(x: frame.minX-500, y: frame.midY)
                    smokeParticleRight.zPosition = 100
                    smokeParticleRight.run(SKAction.moveTo(x: frame.midX, duration: 2.5))
                    addChild(smokeParticleRight)
                    
                    let smokeParticleLeft = SKEmitterNode(fileNamed: "HomeSmoke")!
                    smokeParticleLeft.position = CGPoint(x: frame.maxX+500, y: frame.midY)
                    smokeParticleRight.zPosition = 100
                    smokeParticleLeft.run(SKAction.moveTo(x: frame.midX, duration: 2.5))
                    addChild(smokeParticleLeft)
                    
                    if name == "PlayButton" {
                        
                        let wait = SKAction.wait(forDuration: 2.5)
                        let transition = SKTransition.crossFade(withDuration: 0.0001)
                        let scene = Chapter1(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
                        scene.scaleMode = .aspectFit
                        let sequence = SKAction.sequence([wait, SKAction.run {
                            self.view?.presentScene(scene, transition: transition)
                        }])
                        
                        self.run(sequence)
                    }
                }
                
                if name == "colar" || name == "bone" || name == "dogfood" {
                    touchedNode.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 1.3),
                        SKAction.wait(forDuration: 1),
                        SKAction.fadeIn(withDuration: 1.8)
                    ])
                    )
                }
            }
            
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        addChild(title)
        addChild(bone)
        addChild(dogfood)
        addChild(colar)
        addChild(playbutton)
        addChild(memoriesbutton)
        addChild(creditbutton)
    }
}
