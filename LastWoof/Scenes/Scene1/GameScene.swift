//
//  GameScene.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 15/06/23.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let object: UInt32 = 0b1
    static let character: UInt32 = 0b10
    static let obstacle: UInt32 = 0b100
    static let task: UInt32 = 0b1000
}

protocol PhysicsContactDelegate: AnyObject {
    func didBegin(_ contact: SKPhysicsContact)
}

class GameScene: SKScene, SKPhysicsContactDelegate, PhysicsContactDelegate {
    private var cameraNode: SKCameraNode = SKCameraNode()
    private var background: SKSpriteNode?
    private var entities: [GKEntity] = []
    private var lastTouchLocation: CGPoint?
    private var isColliding: Bool = false
    private var lastDidBeginTime: TimeInterval = 0
    private var detectedObject: SKNode?
    private var actionButton: SKSpriteNode?
    private var isActionButtonClicked: Bool = false

    
    let visualComponentSystem = GKComponentSystem(componentClass: VisualComponent.self)
    let physicsComponentSystem = GKComponentSystem(componentClass: PhysicsComponent.self)
    let movementComponentSystem = GKComponentSystem(componentClass: MovementComponent.self)
    private var analogJoystick: AnalogJoystick?
    private var selectedEntityIndex: Int? = nil
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        setupJoystick()
        setupActionButton()
        
        let character = generateEntity(components: [
            VisualComponent(imageName: "DummyCharacter", size: CGSize(width: 200, height: 200), position: CGPoint(x: 140, y: -183), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 200, height: 200), imageName: "DummyCharacter", isDynamic: true, categoryBitMask: PhysicsCategory.character, collisionBitMask: PhysicsCategory.obstacle | PhysicsCategory.object, contactTestBitMask: PhysicsCategory.obstacle | PhysicsCategory.task),
            MovementComponent(analogJoystick: analogJoystick!)
        ])
        cameraNode.position = (character.component(ofType: VisualComponent.self)?.visualNode.position)!
        
        let pond = generateEntity(components: [
            VisualComponent(imageName: "Pond", size: CGSize(width: 1604, height: 844), position: CGPoint(x: 1647, y: -1217), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1604, height: 844), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let plant1 = generateEntity(components: [
            VisualComponent(imageName: "Plant1-Task", size: CGSize(width: 1288, height: 651), position: CGPoint(x: 1777, y: 325), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1288, height: 651), imageName: "Plant1-Task", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let plant2 = generateEntity(components: [
            VisualComponent(imageName: "Plant2-Decoration", size: CGSize(width: 1097, height: 617), position: CGPoint(x: 1932, y: -651), zPosition: 2, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 1097, height: 617), imageName: "Plant2-Decoration", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let task1 = generateEntity(components: [
            VisualComponent(imageName: "DogCollar", size: CGSize(width: 399, height: 200), position: CGPoint(x: 518, y: -444), zPosition: 0, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 399, height: 200), imageName: "DogCollar", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let task2 = generateEntity(components: [
            VisualComponent(imageName: "Frisbee", size: CGSize(width: 399, height: 200), position: CGPoint(x: -200, y: -604), zPosition: 0, zRotation: 0)
        ])
        
        let fence = generateEntity(components: [
            VisualComponent(imageName: "Fence", size: CGSize(width: 1340, height: 2481), position: CGPoint(x: 2105, y: -519), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1340, height: 2481), imageName: "Fence", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        entities = [character, pond, plant1, plant2, fence, task1, task2]
        entities.forEach { entity in
            if let visualComponent = entity.component(ofType: VisualComponent.self) {
                visualComponentSystem.addComponent(foundIn: entity)
                addChild(visualComponent.visualNode)
                physicsComponentSystem.addComponent(foundIn: entity)
                if entity.component(ofType: MovementComponent.self) != nil {
                    movementComponentSystem.addComponent(foundIn: entity)
                }
            }
        }
        
    }
    
    private func generateEntity(components: [GKComponent]) -> GKEntity {
        let entity = GKEntity()
        components.forEach { component in
            entity.addComponent(component)
        }
        return entity
    }
    
    private func boundsCheckCamera() {
        let minX = background!.position.x - background!.size.width / 2 + size.width / 2
        let minY = background!.position.y - background!.size.height / 2 + size.height / 2
        let maxX = background!.position.x + background!.size.width / 2 - size.width / 2
        let maxY = background!.position.y + background!.size.height / 2 - size.height / 2
        
        let cameraX = cameraNode.position.x
        let cameraY = cameraNode.position.y
        
        if cameraX < minX {
            cameraNode.position.x = minX
        } else if cameraX > maxX {
            cameraNode.position.x = maxX
        }
        
        if cameraY < minY {
            cameraNode.position.y = minY
        } else if cameraY > maxY {
            cameraNode.position.y = maxY
        }
        
        analogJoystick?.position = CGPoint(x: cameraNode.position.x - 700, y: cameraNode.position.y - 220)
        
        actionButton?.position = CGPoint(x: cameraNode.position.x + 650, y: cameraNode.position.y - 220)
    }
    
    override func update(_ currentTime: TimeInterval) {
        physicsComponentSystem.update(deltaTime: currentTime)
        movementComponentSystem.update(deltaTime: currentTime)
        visualComponentSystem.update(deltaTime: currentTime)
        
        cameraNode.position = (entities[0].component(ofType: VisualComponent.self)?.visualNode.position)!
        scene?.camera = cameraNode
        boundsCheckCamera()
        
        let elapsedDidBeginTime = currentTime - lastDidBeginTime
        if elapsedDidBeginTime > 0.5 {
            isColliding = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
    }
    
    // MARK: PhysicsContactDelegate Protocol
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        let interract = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        self.lastDidBeginTime = CACurrentMediaTime()
        
        if collision == PhysicsCategory.character | PhysicsCategory.obstacle {
            isColliding = true
            handleCharacterObstacleCollision(contact: contact)
        }
        if interract == PhysicsCategory.character | PhysicsCategory.task {
            handleCharacterObstacleCollision(contact: contact)
        }
    }
    
    private func handleCharacterObstacleCollision(contact: SKPhysicsContact) {
        let characterNode = contact.bodyA.categoryBitMask == PhysicsCategory.character ? contact.bodyA.node : contact.bodyB.node
        let obstacleNode = contact.bodyA.categoryBitMask == PhysicsCategory.obstacle ? contact.bodyA.node : contact.bodyB.node
        let taskNode = contact.bodyA.categoryBitMask == PhysicsCategory.task ? contact.bodyA.node : contact.bodyB.node
        
        print("Character collided with obstacle")
        print(taskNode?.position)
    }
    
    private func handleCharacterObstacleSeparation(contact: SKPhysicsContact) {
        print("Character separated with obstacle")
    }
    
    func setupJoystick() {
        analogJoystick = AnalogJoystick(diameter: 300, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        analogJoystick!.position = CGPoint(x: -450, y: -400)
        analogJoystick!.zPosition = 2
        addChild(analogJoystick!)
    }
    
    func setupActionButton() {
        actionButton = SKSpriteNode(imageNamed: "BeforeGrab")
        actionButton!.position = CGPoint(x: 700, y: -400)
        actionButton!.zPosition = 3
        addChild(actionButton!)
    }
    
    private func animateActionButton() {
        let beforeGrabTexture = SKTexture(imageNamed: "BeforeGrab")
        let afterGrabTexture = SKTexture(imageNamed: "AfterGrab")
        
        let changeToAfterGrab = SKAction.setTexture(afterGrabTexture)
        let wait = SKAction.wait(forDuration: 0.1)
        let changeToBeforeGrab = SKAction.setTexture(beforeGrabTexture)
        
        let sequence = SKAction.sequence([changeToAfterGrab, wait, changeToBeforeGrab])
        
        actionButton?.run(sequence) { [weak self] in
            self?.isActionButtonClicked = false
        }
    }
}
