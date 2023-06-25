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
}

protocol PhysicsContactDelegate: AnyObject {
    func didBegin(_ contact: SKPhysicsContact)
}

class GameScene: SKScene, SKPhysicsContactDelegate, PhysicsContactDelegate {
//    private var cameraNode: SKCameraNode!
    private var background: SKSpriteNode?
    private var entities: [GKEntity] = []
    private var lastTouchLocation: CGPoint?
    private var isColliding: Bool = false
    private var lastDidBeginTime: TimeInterval = 0
    
    private var analogJoystick: AnalogJoystick?
    private var inventoryNode: SKNode!
    private var isInventoryOpen = false
    
    private var entityManager: EntityManager!
    private var inventoryManager = InventoryManager.shared
    
    override func didMove(to view: SKView) {
        entityManager = EntityManager(scene: self)
        
        physicsWorld.contactDelegate = self
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        setupCamera()
        setupJoystick()
        
        let character = generateEntity(components: [
            VisualComponent(imageName: "DummyCharacter", size: CGSize(width: 200, height: 200), position: CGPoint(x: 140, y: -183), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 200, height: 200), imageName: "DummyCharacter", isDynamic: true, categoryBitMask: PhysicsCategory.character, collisionBitMask: PhysicsCategory.obstacle | PhysicsCategory.object, contactTestBitMask: PhysicsCategory.obstacle),
            MovementComponent(analogJoystick: analogJoystick!),
            PlayerControlComponent(entityManager: entityManager)
        ])
        self.camera?.position = (character.component(ofType: VisualComponent.self)?.visualNode.position)!
        
        let pond = generateEntity(components: [
            VisualComponent(imageName: "Pond", size: CGSize(width: 1604, height: 844), position: CGPoint(x: 1647, y: -1100), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1604, height: 844), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ])
        
        let plant1 = generateEntity(components: [
            VisualComponent(imageName: "Plant1-Task", size: CGSize(width: 1288, height: 651), position: CGPoint(x: 1777, y: 325), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1288, height: 651), imageName: "Plant1-Task", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent()
        ])
        
        let plant2 = generateEntity(components: [
            VisualComponent(imageName: "Plant2-Decoration", size: CGSize(width: 1097, height: 617), position: CGPoint(x: 1932, y: -651), zPosition: 2, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 1097, height: 617), imageName: "Plant2-Decoration", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let fence = generateEntity(components: [
            VisualComponent(imageName: "Fence", size: CGSize(width: 1340, height: 2481), position: CGPoint(x: 2105, y: -519), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1340, height: 2481), imageName: "Fence", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        // icon inventory
        let backpackVC = VisualComponent(imageName: "Inventory", size: CGSize(width: 211, height: 244), position: CGPoint(x: 745.5, y: 270), zPosition: 50, zRotation: 0)
        
        let backpack = generateEntity(components: [
            backpackVC
        ])
        self.camera?.addChild(backpackVC.visualNode)
        self.inventoryNode = backpackVC.visualNode
        
        entities = [character, pond, plant1, plant2, fence]
        entities.forEach { entity in
            entityManager.add(entity)
        }
    }
    
    private func generateEntity(components: [GKComponent]) -> GKEntity {
        let entity = GKEntity()
        components.forEach { component in
            entity.addComponent(component)
        }
        return entity
    }
    
    private func setupCamera() {
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint.zero
            
        self.addChild(cameraNode)
        self.camera = cameraNode
    }

    private func boundsCheckCamera() {
        guard let camera = self.camera else {return}
        
        let minX = background!.position.x - background!.size.width / 2 + size.width / 2
        let minY = background!.position.y - background!.size.height / 2 + size.height / 2
        let maxX = background!.position.x + background!.size.width / 2 - size.width / 2
        let maxY = background!.position.y + background!.size.height / 2 - size.height / 2

        let cameraX = camera.position.x
        let cameraY = camera.position.y

        if cameraX < minX {
            camera.position.x = minX
        } else if cameraX > maxX {
            camera.position.x = maxX
        }

        if cameraY < minY {
            camera.position.y = minY
        } else if cameraY > maxY {
            camera.position.y = maxY
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        entityManager.update(deltaTime: currentTime)
        
        self.camera?.position = (entities[0].component(ofType: VisualComponent.self)?.visualNode.position)!
        
        boundsCheckCamera()
        let elapsedDidBeginTime = currentTime - lastDidBeginTime
        if elapsedDidBeginTime > 0.5 {
            isColliding = false
        }
    }
    
    // MARK: Handle touch input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
        
            for node in touchedNodes {
                if node.name == "Inventory" {
                    // mau open inventory
                    if !isInventoryOpen {
                        if let camera = self.camera {
                            let inventoryEntities = inventoryManager.showInventory(sceneSize: self.frame.size, position: camera.position)
                            for inv in inventoryEntities {
                                entityManager.add(inv)
                            }
                            entityManager.inventoryEntities = inventoryEntities
                            isInventoryOpen = true
                        }
                    }
                }
                
                if node.name == "CloseButton" {
                    if isInventoryOpen {
                        entityManager.removeInventoryView()
                        isInventoryOpen = false
                    }
                }
            }
        }
    }
    
    // MARK: PhysicsContactDelegate Protocol
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        self.lastDidBeginTime = CACurrentMediaTime()
        
        if collision == PhysicsCategory.character | PhysicsCategory.obstacle {
            isColliding = true
            handleCharacterObstacleCollision(contact: contact)
        }
    }
    
    private func handleCharacterObstacleCollision(contact: SKPhysicsContact) {
        let characterNode = contact.bodyA.categoryBitMask == PhysicsCategory.character ? contact.bodyA.node : contact.bodyB.node
        let obstacleNode = contact.bodyA.categoryBitMask == PhysicsCategory.obstacle ? contact.bodyA.node : contact.bodyB.node
        
        // Perform actions or logic when character collides with an obstacle
        if let entity = entityManager.isInventoryAble(node: obstacleNode!) {
            entityManager.storeInventory(entity: entity)
            let pc = entity.component(ofType: PhysicsComponent.self)
            pc?.removePhysics()
            entityManager.removeEntity(entity: entity)
        }
    }
    
    private func handleCharacterObstacleSeparation(contact: SKPhysicsContact) {
        print("Character separated with obstacle")
    }
    
    func setupJoystick() {
        analogJoystick = AnalogJoystick(diameter: 300, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        analogJoystick!.position = CGPoint(x: -600, y: -200)
        analogJoystick!.zPosition = 2
        self.camera?.addChild(analogJoystick!)
    }
}
