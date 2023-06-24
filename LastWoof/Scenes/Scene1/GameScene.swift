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
    private var character: GKEntity?
    
    let missionSystem = MissionSystem(gameState: GameState())
    private var detectedObject: SKNode?
    private var actionButton: SKSpriteNode?
    private var isActionButtonClicked: Bool = false
    private var analogJoystick: AnalogJoystick?
    private var selectedEntityIndex: Int? = nil
    private var contactPoint: CGPoint?
    private var objectNode: SKNode?
    
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
        setupJoystick()
        setupActionButton()
        
        character = generateEntity(components: [
            VisualComponent(name: "Character",imageName: "DummyCharacter", size: CGSize(width: 200, height: 200), position: CGPoint(x: 140, y: -183), zPosition: 10, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 200, height: 200), imageName: "DummyCharacter", isDynamic: true, categoryBitMask: PhysicsCategory.character, collisionBitMask: PhysicsCategory.obstacle | PhysicsCategory.object, contactTestBitMask: PhysicsCategory.obstacle),
            MovementComponent(analogJoystick: analogJoystick!),
            PlayerControlComponent(entityManager: entityManager)
        ])
        cameraNode.position = (character?.component(ofType: VisualComponent.self)?.visualNode.position)!
        
        let pond = generateEntity(components: [
            VisualComponent(name: "Pond", imageName: "Pond", size: CGSize(width: 1604, height: 844), position: CGPoint(x: 1647, y: -1100), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1604, height: 844), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let leafPond1 = generateEntity(components: [
            VisualComponent(name: "LeafPond1", imageName: "LeafPond1", size: CGSize(width: 932, height: 571), position: CGPoint(x: 1667, y: -1314), zPosition: 5, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 932, height: 571), imageName: "LeafPond1", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "LeafPond1", type: "Side Mission", dependencies: ["NetStick"], failedPrompt: nil, successPrompt: "LeafPond1 Gone"),
            StateChangeComponent()
        ])
        
        let leafPond2 = generateEntity(components: [
            VisualComponent(name: "LeafPond2", imageName: "LeafPond2", size: CGSize(width: 940, height: 499), position: CGPoint(x: 1612, y: -1344), zPosition: 5, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 940, height: 499), imageName: "LeafPond2", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "LeafPond2", type: "Side Mission", dependencies: ["NetStick"], failedPrompt: nil, successPrompt: "LeafPond2 Gone"),
            StateChangeComponent()
        ])
        
        let nameTag = generateEntity(components: [
            VisualComponent(name: "NameTag", imageName: "NameTag", size: CGSize(width: 223, height: 92), position: CGPoint(x: 1612, y: -1406), zPosition: 4, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 233, height: 92), imageName: "NameTag", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "Pond", type: "Side Mission", dependencies: ["leafPond1", "leafPond2"], failedPrompt: "There's something inside but I cant reach it. It's too dirty", successPrompt: "You have acquired a Name Tag"),
            StoreInventoryComponent(),
            StateChangeComponent()
        ])
        
        let sapuGarpu = generateEntity(components: [
            VisualComponent(name: "SapuGarpu", imageName: "SapuGarpu", size: CGSize(width: 241, height: 576), position: CGPoint(x: -1159, y: -448), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 241, height: 576), imageName: "SapuGarpu", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "SapuGarpu", type: "Side Mission", dependencies: [], failedPrompt: nil, successPrompt: "You have acquired a Sapu Garpu"),
            StoreInventoryComponent(),
            StateChangeComponent(),
        ])
        
        let netStick = generateEntity(components: [
            VisualComponent(name: "NetStick", imageName: "NetStick", size: CGSize(width: 144, height: 162), position: CGPoint(x: 214, y: -428), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 144, height: 162), imageName: "NetStick", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "NetStick", type: "Side Mission", dependencies: [], failedPrompt: nil, successPrompt: "You have acquired a Net"),
            StoreInventoryComponent(),
            StateChangeComponent()
        ])
        
        let plant1 = generateEntity(components: [
            VisualComponent(name: "Plant1", imageName: "Plant1-Task", size: CGSize(width: 1288, height: 651), position: CGPoint(x: 1777, y: 325), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1288, height: 651), imageName: "Plant1-Task", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ])
        
        let dogCollar = generateEntity(components: [
            VisualComponent(name: "DogCollar", imageName: "DogCollar", size: CGSize(width: 240, height: 184), position: CGPoint(x: 1660, y: 228), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 240, height: 184), imageName: "DogCollar", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "DogCollar", type: "Side Mission", dependencies: [], failedPrompt: "", successPrompt: "You have acquired the Dog Collar!"),
            StoreInventoryComponent(),
            StateChangeComponent()
        ])
        
        let plant2 = generateEntity(components: [
            VisualComponent(name: "Plant2", imageName: "Plant2-Decoration", size: CGSize(width: 1097, height: 617), position: CGPoint(x: 1932, y: -651), zPosition: 3, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 1097, height: 617), imageName: "Plant2-Decoration", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ])
        
        let leaf1 = generateEntity(components: [
            VisualComponent(name: "Leaf1", imageName: "Leaf1", size: CGSize(width: 2302, height: 1176), position: CGPoint(x: -191, y: -975), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 2302, height: 1176), imageName: "Leaf1", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "Leaf1", type: "Side Mission", dependencies: ["SapuGarpu"], failedPrompt: "This backyard looks so messy", successPrompt: "Leaf 1 is gone"),
            StateChangeComponent()
        ])
        
        let leaf2 = generateEntity(components: [
            VisualComponent(name: "Leaf2", imageName: "Leaf2", size: CGSize(width: 2158, height: 1102), position: CGPoint(x: 520, y: -938), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 2158, height: 1102), imageName: "Leaf2", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "Leaf2", type: "Side Mission", dependencies: ["SapuGarpu"], failedPrompt: "This backyard looks so messy", successPrompt: "Leaf 2 is gone"),
            StateChangeComponent()
        ])
        
        let leaf3 = generateEntity(components: [
            VisualComponent(name: "Leaf3", imageName: "Leaf3", size: CGSize(width: 2086, height: 1090), position: CGPoint(x: 1043, y: -433), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 2086, height: 1090), imageName: "Leaf3", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "Leaf3", type: "Side Mission", dependencies: ["SapuGarpu"], failedPrompt: "This backyard looks so messy", successPrompt: "Leaf 3 is gone"),
            StateChangeComponent()
        ])
        
        let frisbee = generateEntity(components: [
            VisualComponent(name: "Frisbee", imageName: "Frisbee", size: CGSize(width: 338, height: 236), position: CGPoint(x: 519, y: -1097), zPosition: 0, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 338, height: 236), imageName: "Frisbee", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            MissionComponent(missionID: "Frisbee", type: "Side Mission", dependencies: ["SapuGarpu", "Leaf1", "Leaf2"], failedPrompt: "This backyard looks so messy.", successPrompt: "You have acquired a Frisbee"),
            StoreInventoryComponent(),
            StateChangeComponent()
        ])
        
        let fence = generateEntity(components: [
            VisualComponent(name: "Fence", imageName: "Fence", size: CGSize(width: 1340, height: 2481), position: CGPoint(x: 2105, y: -519), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1340, height: 2481), imageName: "Fence", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
    }
    
    private func generateEntity(components: [GKComponent]) -> GKEntity {
        let entity = GKEntity()
        components.forEach { component in
            entity.addComponent(component)
            missionSystem.addComponent(entity: entity)
        }
        entityManager.add(entity)
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
        entityManager.update(deltaTime: currentTime)
        
        cameraNode.position = (character?.component(ofType: VisualComponent.self)?.visualNode.position)!
        scene?.camera = cameraNode
        boundsCheckCamera()
        
        if checkIfCharacterStillContact(characterPosition: character?.component(ofType: VisualComponent.self)?.visualNode.position ?? CGPoint(x: 0, y: 0), contactPoint: contactPoint ?? CGPoint(x: 200, y: 200)) == true {
            isColliding = true
            actionButton?.alpha = 1
        } else {
            isColliding = false
            actionButton?.alpha = 0.5
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if ((actionButton?.frame.contains(touchLocation)) != nil && isColliding) {
            animateActionButton()
        }
    }
    
    // MARK: PhysicsContactDelegate Protocol
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        let interract = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if interract == PhysicsCategory.character | PhysicsCategory.task {
            handleCharacterObstacleCollision(contact: contact)
        }
    }
    
    private func handleCharacterObstacleCollision(contact: SKPhysicsContact) {
        let taskNode = contact.bodyA.categoryBitMask == PhysicsCategory.task ? contact.bodyA.node : contact.bodyB.node
        
        // Perform actions or logic when character collides with an obstacle
        contactPoint = contact.contactPoint
        objectNode = taskNode
        actionButton?.alpha = 1
    }
    
    private func checkIfCharacterStillContact(characterPosition: CGPoint, contactPoint: CGPoint) -> Bool {
        let dx = characterPosition.x - contactPoint.x
        let dy = characterPosition.y - contactPoint.y
        return sqrt(dx*dx + dy*dy) < 100
    }
    
    private func storeItem() {
        if let entity = entityManager.isInventoryAble(node: objectNode!) {
            if missionSystem.checkMission(name: (entity.component(ofType: VisualComponent.self)?.visualNode.name!)!) == true {
                entityManager.storeInventory(entity: entity)
                entityManager.removeEntity(entity: entity)
                contactPoint = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    func setupJoystick() {
        analogJoystick = AnalogJoystick(diameter: 300, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        analogJoystick!.position = CGPoint(x: -450, y: -400)
        analogJoystick!.zPosition = 10
        addChild(analogJoystick!)
    }
    
    func setupActionButton() {
        actionButton = SKSpriteNode(imageNamed: "BeforeGrab")
        actionButton!.position = CGPoint(x: 700, y: -400)
        actionButton!.zPosition = 10
        addChild(actionButton!)
    }
    
    private func animateActionButton() {
        let beforeGrabTexture = SKTexture(imageNamed: "BeforeGrab")
        let afterGrabTexture = SKTexture(imageNamed: "AfterGrab")
        
        let changeToAfterGrab = SKAction.setTexture(afterGrabTexture)
        let wait = SKAction.wait(forDuration: 0.2)
        let changeToBeforeGrab = SKAction.setTexture(beforeGrabTexture)
        
        let sequence = SKAction.sequence([changeToAfterGrab, wait, changeToBeforeGrab])
        
        actionButton?.run(sequence) { [weak self] in
            self?.isActionButtonClicked = false
        }
        storeItem()
    }
}
