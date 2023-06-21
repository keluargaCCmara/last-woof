//
//  Chapter2Scene.swift
//  Last Woof
//
//  Created by Angelica Patricia on 19/06/23.
//

import SpriteKit
import GameplayKit

class Chapter1: SKScene {
    private var character: SKSpriteNode?
    private var entities: [GKEntity] = []
    let velocityMultiplier: CGFloat = 0.0375
    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: ScreenSize.width * -0.5 + js.radius + 45, y: ScreenSize.height * -0.5 + js.radius + 45)
        js.zPosition = NodesZPosition.controller.rawValue
        js.alpha = 1
        return js
    }()
    
    enum NodesZPosition: CGFloat {
        case whiteBackground, background, player, controller
    }
    
    lazy var whiteBackground: SKSpriteNode = {
        var sprite = SKSpriteNode(color: .white, size: self.size)
        sprite.position = CGPoint.zero
        sprite.zPosition = NodesZPosition.whiteBackground.rawValue
        sprite.scaleTo(screenWidthPercentage: 1.0)
        return sprite
    }()
    
    lazy var background: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "Chapter1-Background")
        sprite.position = CGPoint.zero
        sprite.zPosition = NodesZPosition.background.rawValue
        sprite.scaleTo(screenWidthPercentage: 1.0)
        sprite.alpha = 0
        return sprite
    }()
    
    override func sceneDidLoad() {
        setupNodes()
        let playerComponent = PlayerComponent(imagedName: "Chapter1-Player", width: 80, height: 80, position: CGPoint(x: 0, y: -30), zPosition: 1, zRotation: 0, isDynamic: true)
        let characterEntity = generateCharacter(components: [
            playerComponent
        ])
        if let character = characterEntity.component(ofType: PlayerComponent.self) {
            addChild(character.node)
//            addChild(analogJoystick)
        }
        setupJoystick()
    }
    
    private func generateCharacter(components: [GKComponent?]) -> GKEntity {
        let entity = GKEntity()
        components.forEach { component in
            if let component = component {
                entity.addComponent(component)
                
                if let playerComponent = component as? PlayerComponent {
                    character = playerComponent.node
                }
            }
        }
        return entity
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        for entity in entities {
            entity.update(deltaTime: currentTime)
        }
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(whiteBackground)
        addChild(background)
        background.run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.fadeIn(withDuration: 3)]))
    }
    
    func setupJoystick() {
        addChild(analogJoystick)
         analogJoystick.trackingHandler = { [unowned self] data in
             self.character!.position = CGPoint(x: self.character!.position.x + (data.velocity.x * self.velocityMultiplier),
                                            y: self.character!.position.y + (data.velocity.y * self.velocityMultiplier))
             self.character!.zRotation = data.angular
         }
     }
}

