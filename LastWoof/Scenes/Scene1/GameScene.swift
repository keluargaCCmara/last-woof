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
        entityManager = EntityManager.shared
        
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
        ], state: 0, imageState: nil)
        
        cameraNode.position = (character?.component(ofType: VisualComponent.self)?.visualNode.position)!
        
        let pond = generateEntity(components: [
            VisualComponent(name: "Pond", imageName: "Pond3", size: CGSize(width: 1289, height: 700), position: CGPoint(x: 1596, y: -1232), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1339, height: 735), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ], state: 2, imageState: ["Pond2", "Pond"])
        
        let leafPond = generateEntity(components: [
            VisualComponent(name: "LeafPond1", imageName: "LeafPond1", size: CGSize(width: 1071, height: 545), position: CGPoint(x: 1704, y: -1290), zPosition: 4, zRotation: 0)
        ], state: 0, imageState: nil)
        
        let nameTag = generateEntity(components: [
            VisualComponent(name: "NameTag", imageName: "NameTag", size: CGSize(width: 265, height: 131), position: CGPoint(x: 1620, y: -1418), zPosition: 3, zRotation: 0),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let sapuGarpu = generateEntity(components: [
            VisualComponent(name: "SapuGarpu", imageName: "SapuGarpu", size: CGSize(width: 241, height: 576), position: CGPoint(x: -1159, y: -448), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 241, height: 576), imageName: "SapuGarpu", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent(),
        ], state: 0, imageState: nil)

        let leaf1 = generateEntity(components: [
            VisualComponent(name: "Leaf1", imageName: "Leaf1", size: CGSize(width: 2302, height: 1176), position: CGPoint(x: -191, y: -975), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 2302, height: 1176), imageName: "Leaf1", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let leaf2 = generateEntity(components: [
            VisualComponent(name: "Leaf2", imageName: "Leaf2", size: CGSize(width: 2158, height: 1102), position: CGPoint(x: 520, y: -938), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 2158, height: 1102), imageName: "Leaf2", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let leaf3 = generateEntity(components: [
            VisualComponent(name: "Leaf3", imageName: "Leaf2", size: CGSize(width: 2086, height: 1090), position: CGPoint(x: 1043, y: -433), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 2086, height: 1090), imageName: "Leaf2", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let netStick = generateEntity(components: [
            VisualComponent(name: "NetStick", imageName: "NetStick", size: CGSize(width: 144, height: 162), position: CGPoint(x: 214, y: -428), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 144, height: 162), imageName: "NetStick", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)
        
        let plant1 = generateEntity(components: [
            VisualComponent(name: "Plant1", imageName: "Plant1-Task", size: CGSize(width: 1288, height: 651), position: CGPoint(x: 1777, y: 325), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1288, height: 651), imageName: "Plant1-Task", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ], state: 0, imageState: nil)

        let dogCollar = generateEntity(components: [
            VisualComponent(name: "DogCollar", imageName: "DogCollar", size: CGSize(width: 240, height: 184), position: CGPoint(x: 1660, y: 228), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 240, height: 184), imageName: "DogCollar", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let plant2 = generateEntity(components: [
            VisualComponent(name: "Plant2", imageName: "Plant2-Decoration", size: CGSize(width: 1097, height: 617), position: CGPoint(x: 1932, y: -651), zPosition: 3, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 1097, height: 617), imageName: "Plant2-Decoration", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ], state: 0, imageState: nil)
        
        let frisbee = generateEntity(components: [
            VisualComponent(name: "Frisbee", imageName: "Frisbee", size: CGSize(width: 338, height: 236), position: CGPoint(x: 519, y: -1097), zPosition: 0, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 338, height: 236), imageName: "Frisbee", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let fence = generateEntity(components: [
            VisualComponent(name: "Fence", imageName: "Fence", size: CGSize(width: 1340, height: 2481), position: CGPoint(x: 2105, y: -519), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1340, height: 2481), imageName: "Fence", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ], state: 0, imageState: nil)
        
        generateMissions()
    }
    
    private func generateEntity(components: [GKComponent], state: Int, imageState: [String]?) -> GKEntity {
        let entity = CustomEntity(state: state, imageState: imageState)
        components.forEach { component in
            entity.addComponent(component)
        }
        addChild(entity.component(ofType: VisualComponent.self)!.visualNode)
        entityManager.add(entity)
        return entity
    }
    
    private func generateMissions() {
        let mainMission = MissionComponent(missionID: "Main", type: "Main Mission", interractObject: nil, neededObject: ["Frisbee", "NameTag", "DogCollar"], failedPrompt: nil, successState: ["":""], successPrompt: "You have completed the Main Mission", stateRequirement: 0)
        missionSystem.addComponent(mission: mainMission)
        
        let plant1Mission = MissionComponent(missionID: "DogCollar", type: "Side Mission", interractObject: "DogCollar", neededObject: nil, failedPrompt: nil, successState: ["DogCollar" : "Store"], successPrompt: "You acquired a Dog Collar", stateRequirement: 0)
        missionSystem.addComponent(mission: plant1Mission)
        
        let getRake = MissionComponent(missionID: "Rake", type: "Side Mission", interractObject: "SapuGarpu", neededObject: nil, failedPrompt: nil, successState: ["SapuGarpu" : "Store"], successPrompt: "You acquired a rake", stateRequirement: 0)
        missionSystem.addComponent(mission: getRake)
        
        let swipeLeaves = MissionComponent(missionID: "Leaf1", type: "Side Mission", interractObject: "Leaf1", neededObject: ["SapuGarpu"], failedPrompt: "This backyard could have some cleaning", successState: ["Leaf1" : "Remove", "Leaf2" : "Remove", "Leaf3" : "Remove"], successPrompt: "Now this backyard looks better", stateRequirement: 0)
        missionSystem.addComponent(mission: swipeLeaves)
        
        let frisbee = MissionComponent(missionID: "Frisbee", type: "Side Mission", interractObject: "Frisbee", neededObject: nil, failedPrompt: nil, successState: ["Frisbee" : "Store"], successPrompt: "You have acquired a Frisbee", stateRequirement: 0)
        missionSystem.addComponent(mission: frisbee)
        
        let fishNet = MissionComponent(missionID: "NetStick", type: "Side Mission", interractObject: "NetStick", neededObject: nil, failedPrompt: nil, successState: ["NetStick" : "Store"], successPrompt: "You have acquired a Net Stick", stateRequirement: 0)
        missionSystem.addComponent(mission: fishNet)
        
        let pondMission = MissionComponent(missionID: "Pond", type: "Side Mission", interractObject: "Pond", neededObject: ["NetStick"], failedPrompt: "I couldn't see the bottom of the pond", successState: ["LeafPond1": "Remove"], successPrompt: "Now I can see the bottom of the pond", stateRequirement: 0)
        missionSystem.addComponent(mission: pondMission)
        
        let pondMission2 = MissionComponent(missionID: "Pond2", type: "Side Mission", interractObject: "Pond", neededObject: nil, failedPrompt: nil, successState: ["NameTag" : "Store"], successPrompt: "You have acquired a name tag", stateRequirement: 1)
        missionSystem.addComponent(mission: pondMission2)
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
            if missionSystem.checkMission(entity: entity) == true {
                entity.changeState()
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
