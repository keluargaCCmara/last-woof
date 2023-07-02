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
        AudioManager.shared.playAudio(fileName: "BGM For Menu", isBGM: true)
        
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        
        let playButton = generateEntity(components: [
            VisualComponent(name: "Home-Play", imageName: "home-play", size: CGSize(width: 217, height: 44), position: CGPoint(x: frame.midX, y: frame.midY-15), zPosition: 2, zRotation: 0)
        ])
        playButtonNode = playButton.component(ofType: VisualComponent.self)?.visualNode
        
//        let memoriesButton = generateEntity(components: [
//            VisualComponent(name: "Home-Memories", imageName: "home-memories", size: CGSize(width: 217, height: 44), position: CGPoint(x: frame.midX, y: frame.midY-60), zPosition: 2, zRotation: 0)
//        ])
//        memoriesButtonNode = memoriesButton.component(ofType: VisualComponent.self)?.visualNode
        
        let creditsButton = generateEntity(components: [
            VisualComponent(name: "Home-Credit", imageName: "home-credit", size: CGSize(width: 217, height: 44), position: CGPoint(x: frame.midX, y: frame.midY-85), zPosition: 2, zRotation: 0)
        ])
        creditsButtonNode = creditsButton.component(ofType: VisualComponent.self)?.visualNode
        
        let title = generateEntity(components: [
            VisualComponent(name: "Home-Title", imageName: "home-title", size: CGSize(width: 500, height: 232), position: CGPoint(x: frame.midX, y: frame.midY+90), zPosition: 0, zRotation: 0)
        ])
        
        let colar = generateEntity(components: [
            VisualComponent(name: "Home-Colar", imageName: "home-colar", size: CGSize(width: 150, height: 180), position: CGPoint(x: -260, y: -20), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1200, height: 513), imageName: "home-colar", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        colarNode = colar.component(ofType: VisualComponent.self)?.visualNode
        moveElements()
        
        let bone = generateEntity(components: [
            VisualComponent(name: "Home-Bone", imageName: "home-bone", size: CGSize(width: 90, height: 55), position: CGPoint(x: 320, y: -4), zPosition: 1, zRotation: 0)
        ])
        boneNode = bone.component(ofType: VisualComponent.self)?.visualNode
        
        
        let dogfood = generateEntity(components: [
            VisualComponent(name: "Home-DogFood", imageName: "home-dogfood", size: CGSize(width: 90, height: 70), position: CGPoint(x: 260, y: -112), zPosition: 1, zRotation: 0)
        ])
        dogfoodNode = dogfood.component(ofType: VisualComponent.self)?.visualNode
        moveElements()
        
        entities = [playButton, creditsButton, title, colar, bone, dogfood]
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
            AudioManager.shared.playAudio(fileName: "Click 2 Sound", isBGM: false)
            
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
            
            [playButtonNode, creditsButtonNode].compactMap { $0 }.forEach { node in
                if node.contains(t.location(in: self)) {
                    node.run(SKAction.sequence([
                        SKAction.scale(by: 1.1, duration: 0.05),
                        SKAction.scale(by: 0.9, duration: 0.05)
                    ])
                    )
                    
                    let smokeParticleRight = SKEmitterNode(fileNamed: "SubHomeSmoke")!
                    smokeParticleRight.position = CGPoint(x: frame.minX, y: frame.midY)
                    smokeParticleRight.run(SKAction.moveTo(x: frame.midX, duration: 2))
                    smokeParticleRight.zPosition = 99
                    addChild(smokeParticleRight)
                    
                    let smokeParticleLeft = SKEmitterNode(fileNamed: "SubHomeSmoke")!
                    smokeParticleLeft.position = CGPoint(x: frame.maxX, y: frame.midY)
                    smokeParticleLeft.run(SKAction.moveTo(x: frame.midX, duration: 2))
                    smokeParticleLeft.zPosition = 99
                    addChild(smokeParticleLeft)
                    
                    
                    if let playButtonNode = playButtonNode, playButtonNode.contains(t.location(in: self)) {
                        let defaults = UserDefaults.standard
                        let opened = defaults.bool(forKey: "OpenedBefore")
    
                        // Add a transition to the CreditsScene
                        let wait = SKAction.wait(forDuration: 1)
                        let transition = SKTransition.fade(with: .white, duration: 0.5)
                        
                        if opened {
                            let scene = GameScene(fileNamed: "GameScene")!
                            let sequence = SKAction.sequence([wait, SKAction.run {
                                self.view?.presentScene(scene, transition: transition)
                            }])
                            self.run(sequence)
                        } else {
                            let prologue = StoryScene()
                            let sequence = SKAction.sequence([wait, SKAction.run {
                                prologue.nFrames = 17
                                prologue.sceneName = "Prologue"
                                prologue.size = CGSize(width: 844, height: 390)
                                self.view?.presentScene(prologue, transition: transition)
                            }])
                            self.run(sequence)
                        }
                        
                        AudioManager.shared.stopBGM()
                        return
                    }
                    
//                    if let memoriesButtonNode = memoriesButtonNode, memoriesButtonNode.contains(t.location(in: self)) {
//                        // Add a transition to the CreditsScene
//                        let wait = SKAction.wait(forDuration: 1)
//                        let transition = SKTransition.crossFade(withDuration: 0.001)
//                        let memoriesScene = MemoriesScene(fileNamed: "MemoriesScene")!
//                        let sequence = SKAction.sequence([wait, SKAction.run {
//                            memoriesScene.size = self.size
//                            self.view?.presentScene(memoriesScene, transition: transition)
//                        }])
//                        self.run(sequence)
//                        AudioManager.shared.stopBGM()
//                        return
//                    }
                    
                    
                    if let creditsButtonNode = creditsButtonNode, creditsButtonNode.contains(t.location(in: self)) {
                        // Add a transition to the CreditsScene
                        let wait = SKAction.wait(forDuration: 1)
                        let transition = SKTransition.crossFade(withDuration: 0.001)
                        let creditsScene = CreditsScene(fileNamed: "CreditsScene")!
                        let sequence = SKAction.sequence([wait, SKAction.run {
                            creditsScene.size = self.size
                            self.view?.presentScene(creditsScene, transition: transition)
                        }])
                        self.run(sequence)
                        AudioManager.shared.stopBGM()
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
        
        //        let wait1 = SKAction.wait(forDuration: 0.5)
        //        let wait2 = SKAction.wait(forDuration: 0.1)
        let moveDownAction = SKAction.move(by: CGVector(dx: 0.0, dy: -20.0), duration: 1)
        let moveUpAction = SKAction.move(by: CGVector(dx: 0.0, dy: 20.0), duration: 1)
        
        let moveDownActionColar = SKAction.move(by: CGVector(dx: 0.0, dy: -50.0), duration: 2)
        let moveUpActionColar = SKAction.move(by: CGVector(dx: 0.0, dy: 50.0), duration: 2)
        
        let sequence = SKAction.sequence([moveDownActionColar, moveUpActionColar])
        let repeatAction = SKAction.repeatForever(sequence)
        colarNode.run(repeatAction)
        
        
        let dogfoodSequence = SKAction.sequence([moveDownAction, moveUpAction])
        let dogfoodRepeatAction = SKAction.repeatForever(dogfoodSequence)
        dogfoodNode.run(dogfoodRepeatAction)
        
        let boneSequence = SKAction.sequence([moveUpAction, moveDownAction])
        let boneRepeatAction = SKAction.repeatForever(boneSequence)
        boneNode.run(boneRepeatAction)
    }
}
