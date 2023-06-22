//
//  MainMenu.swift
//  Last Woof
//
//  Created by Angelica Patricia on 21/06/23.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene, SKPhysicsContactDelegate {
    private var cursor : SKSpriteNode!
    private var entities: [GKEntity] = []
    private var background: SKSpriteNode?
    private var colarNode: SKNode?
    private var dogfoodNode: SKNode?
    private var boneNode: SKNode?
    private var playButtonNode: SKNode?
    private var memoriesButtonNode: SKNode?
    private var creditsButtonNode: SKNode?
    
    let physicsComponentSystem = GKComponentSystem(componentClass: PhysicsComponent.self)
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        
        let playButton = generateEntity(components: [
            VisualComponent(imageName: "home-play", size: CGSize(width: 592, height: 103), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: 2, zRotation: 0)
        ])
        playButtonNode = playButton.component(ofType: VisualComponent.self)?.visualNode
        
        let memoriesButton = generateEntity(components: [
            VisualComponent(imageName: "home-memories", size: CGSize(width: 592, height: 103), position: CGPoint(x: frame.midX, y: frame.midY-140), zPosition: 2, zRotation: 0)
        ])
        memoriesButtonNode = memoriesButton.component(ofType: VisualComponent.self)?.visualNode
        
        let creditsButton = generateEntity(components: [
            VisualComponent(imageName: "home-credit", size: CGSize(width: 592, height: 103), position: CGPoint(x: frame.midX, y: frame.midY-280), zPosition: 2, zRotation: 0)
        ])
        creditsButtonNode = creditsButton.component(ofType: VisualComponent.self)?.visualNode
        
        let title = generateEntity(components: [
            VisualComponent(imageName: "home-title", size: CGSize(width: 1300, height: 590), position: CGPoint(x: frame.midX, y: frame.midY+250), zPosition: 0, zRotation: 0)
        ])
        
        let colar = generateEntity(components: [
            VisualComponent(imageName: "home-colar", size: CGSize(width: 370, height: 437), position: CGPoint(x: -658, y: -82), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1200, height: 513), imageName: "home-colar", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        colarNode = colar.component(ofType: VisualComponent.self)?.visualNode
        moveElements()
        
        let bone = generateEntity(components: [
            VisualComponent(imageName: "home-bone", size: CGSize(width: 272, height: 163), position: CGPoint(x: 650, y: -34), zPosition: 1, zRotation: 0)
        ])
        boneNode = bone.component(ofType: VisualComponent.self)?.visualNode
        
        
        let dogfood = generateEntity(components: [
            VisualComponent(imageName: "home-dogfood", size: CGSize(width: 231, height: 180), position: CGPoint(x: 489, y: -260), zPosition: 1, zRotation: 0)
        ])
        dogfoodNode = dogfood.component(ofType: VisualComponent.self)?.visualNode
        moveElements()
        
        entities = [playButton, memoriesButton, creditsButton, title, colar, bone, dogfood]
        entities.forEach { entity in
            if let visualComponent = entity.component(ofType: VisualComponent.self) {
                addChild(visualComponent.visualNode)
                physicsComponentSystem.addComponent(foundIn: entity)
            }
        }
        
        self.cursor = SKSpriteNode(imageNamed: "home-cursor")
        if let cursor = self.cursor {
            cursor.size = CGSize(width: 40, height: 40)
            cursor.zPosition = 3
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            
            [boneNode, colarNode, dogfoodNode].compactMap { $0 }.forEach { node in
                if node.contains(t.location(in: self)) {
                    node.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 1.3),
                        SKAction.wait(forDuration: 0.75),
                        SKAction.fadeIn(withDuration: 1.8)
                    ]))
                    return
                }
            }
            
            [playButtonNode, memoriesButtonNode, creditsButtonNode].compactMap { $0 }.forEach { node in
                if node.contains(t.location(in: self)) {
                    node.run(SKAction.sequence([
                        SKAction.scale(by: 1.1, duration: 0.05),
                        SKAction.scale(by: 0.9, duration: 0.05)
                    ])
                    )
                    
                    let smokeParticleRight = SKEmitterNode(fileNamed: "HomeSmoke")!
                    smokeParticleRight.position = CGPoint(x: frame.minX-500, y: frame.midY)
                    smokeParticleRight.run(SKAction.moveTo(x: frame.midX, duration: 2.5))
                    smokeParticleRight.zPosition = 99
                    addChild(smokeParticleRight)
                    
                    let smokeParticleLeft = SKEmitterNode(fileNamed: "HomeSmoke")!
                    smokeParticleLeft.position = CGPoint(x: frame.maxX+500, y: frame.midY)
                    smokeParticleLeft.run(SKAction.moveTo(x: frame.midX, duration: 2.5))
                    smokeParticleLeft.zPosition = 99
                    addChild(smokeParticleLeft)
                    
                    
                    if let creditsButtonNode = creditsButtonNode, creditsButtonNode.contains(t.location(in: self)) {
                        
                        // Add a transition to the CreditsScene
                        let wait = SKAction.wait(forDuration: 2.5)
                        let transition = SKTransition.crossFade(withDuration: 0.001)
                        let creditsScene = CreditsScene(fileNamed: "CreditsScene")!
                        let sequence = SKAction.sequence([wait, SKAction.run {
                            self.view?.presentScene(creditsScene, transition: transition)
                        }])
                                self.run(sequence)
                        return
                    }
                    return
                }
                
            }
            

            
        }
    }
    
    private func moveElements() {
        guard let colarNode = colarNode,
              let dogfoodNode = dogfoodNode,
              let boneNode = boneNode
        else {
            return
        }
        
        let wait1 = SKAction.wait(forDuration: 0.5)
        let wait2 = SKAction.wait(forDuration: 0.1)
        let moveDownAction = SKAction.move(by: CGVector(dx: 0.0, dy: -20.0), duration: 1)
        let moveUpAction = SKAction.move(by: CGVector(dx: 0.0, dy: 20.0), duration: 1)
        
        let sequence = SKAction.sequence([wait1, moveDownAction, moveUpAction])
        let repeatAction = SKAction.repeatForever(sequence)
        colarNode.run(repeatAction)
        
        
        let dogfoodSequence = SKAction.sequence([moveDownAction,wait2,  moveUpAction])
        let dogfoodRepeatAction = SKAction.repeatForever(dogfoodSequence)
        dogfoodNode.run(dogfoodRepeatAction)
        
        let boneSequence = SKAction.sequence([wait1, moveUpAction, moveDownAction])
        let boneRepeatAction = SKAction.repeatForever(boneSequence)
        boneNode.run(boneRepeatAction)
    }
}
