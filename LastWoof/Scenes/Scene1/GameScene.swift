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
    private var background: SKSpriteNode?
    private var entities: [GKEntity] = []
    private var lastTouchLocation: CGPoint?
    private var isColliding: Bool = false
    private var lastDidBeginTime: TimeInterval = 0
    private var character: GKEntity?
    
    let missionSystem = MissionSystem(gameState: GameState())
    private var detectedObject: SKNode?
    private var actionButton: SKSpriteNode?
    private var thoughtItem: SKSpriteNode?
    private var isActionButtonClicked: Bool = false
    private var analogJoystick: AnalogJoystick?
    private var isInventoryOpen = false
    private var currentlyHolding: String?
    private var inventoryBtnNode: SKSpriteNode!
    private var inventoryEntities: [GKEntity] = []
    private var contactPoint: CGPoint?
    private var objectNode: SKNode?
    
    private var entityManager = EntityManager.shared
    private var inventoryManager = InventoryManager.shared
    
    override func didMove(to view: SKView) {
        entityManager.scene = self
        physicsWorld.contactDelegate = self
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        setupCamera()
        setupJoystick()
        setupActionButton()
        setupInventoryButton()
        generateEntities()
        generateMissions()
        dogThought()
    }
    
    private func generateEntities() {
        
        
        character = generateEntity(components: [
            VisualComponent(name: "Character",imageName: "DummyCharacter", size: CGSize(width: 80, height: 173), position: CGPoint(x: 140, y: -183), zPosition: 10, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 50, height: 173), imageName: "DummyCharacter", isDynamic: true, categoryBitMask: PhysicsCategory.character, collisionBitMask: PhysicsCategory.obstacle | PhysicsCategory.object, contactTestBitMask: PhysicsCategory.obstacle),
            MovementComponent(analogJoystick: analogJoystick!),
            PlayerControlComponent(entityManager: entityManager)
        ], state: 0, imageState: nil)
        
        self.camera?.position = (character?.component(ofType: VisualComponent.self)?.visualNode.position)!
        
        let pond = generateEntity(components: [
            VisualComponent(name: "Pond", imageName: "Pond", size: CGSize(width: 376, height: 192), position: CGPoint(x: 345, y: -433), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 376, height: 192), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.task , collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StateChangeComponent(),
            StoreInventoryComponent()
        ], state: 2, imageState: ["Pond2", "Pond3"])
        
        let pond2 = generateEntity(components: [
            VisualComponent(name: "Pond2", imageName: "Pond", size: CGSize(width: 317, height: 172), position: CGPoint(x: 349, y: -446), zPosition: -1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 317, height: 172), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
            StateChangeComponent(),
            StoreInventoryComponent()
        ], state: 0, imageState: nil)
        
        let nameTag = generateEntity(components: [
            VisualComponent(name: "NameTag", imageName: "NameTag", size: CGSize(width: 0, height: 0), position: CGPoint(x: 0, y: 0), zPosition: -2, zRotation: 0)
        ], state: 0, imageState: nil)

        let sapuGarpu = generateEntity(components: [
            VisualComponent(name: "SapuGarpu", imageName: "SapuGarpu", size: CGSize(width: 67, height: 170), position: CGPoint(x: -572, y: -148), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 67, height: 170), imageName: "SapuGarpu", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent(),
        ], state: 0, imageState: nil)
        
        let leaves = generateEntity(components: [
            VisualComponent(name: "Leaves", imageName: "Leaves", size: CGSize(width: 820, height: 332), position: CGPoint(x: -251, y: -362), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 820, height: 332), imageName: "Leaves", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StateChangeComponent(),
            StoreInventoryComponent()
        ], state: 2, imageState: ["Leaves2", "Leaves3"])

        let netStick = generateEntity(components: [
            VisualComponent(name: "NetStick", imageName: "NetStick", size: CGSize(width: 52, height: 55), position: CGPoint(x: -120, y: -140), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 52, height: 55), imageName: "NetStick", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)
        
        let plant1 = generateEntity(components: [
            VisualComponent(name: "Plant1", imageName: "Plant1-Task", size: CGSize(width: 273, height: 189), position: CGPoint(x: 391, y: 100), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 273, height: 189), imageName: "Plant1-Task", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ], state: 0, imageState: nil)

        let dogCollar = generateEntity(components: [
            VisualComponent(name: "DogCollar", imageName: "DogCollar", size: CGSize(width: 100, height: 50), position: CGPoint(x: 327, y: 41), zPosition: 1, zRotation: 56),
            PhysicsComponent(size: CGSize(width: 100, height: 50), imageName: "DogCollar", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)
        
        let plant2 = generateEntity(components: [
            VisualComponent(name: "Plant2", imageName: "Plant2-Decoration", size: CGSize(width: 233, height: 280), position: CGPoint(x: 486, y: -220), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 233, height: 280), imageName: "Plant2-Decoration", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ], state: 0, imageState: nil)
        
        let plant2shadow = generateEntity(components: [
            VisualComponent(name: "Plant2Shadow", imageName: "Plant2-Decoration-Shadow", size: CGSize(width: 228, height: 190), position: CGPoint(x: 463, y: -247), zPosition: 2, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 228, height: 190), imageName: "Plant2-Decoration-Shadow", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character),
        ], state: 0, imageState: nil)
        
        let frisbee = generateEntity(components: [
            VisualComponent(name: "Frisbee", imageName: "Frisbee", size: CGSize(width: 90, height: 58), position: CGPoint(x: -16, y: -371), zPosition: 0, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 90, height: 58), imageName: "Frisbee", isDynamic: false, categoryBitMask: PhysicsCategory.task, collisionBitMask: PhysicsCategory.none, contactTestBitMask: PhysicsCategory.character),
            StoreInventoryComponent(),
            StateChangeComponent()
        ], state: 0, imageState: nil)

        let fence = generateEntity(components: [
            VisualComponent(name: "Fence", imageName: "Fence", size: CGSize(width: 328, height: 715), position: CGPoint(x: 529, y: -162), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 328, height: 715), imageName: "Fence", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ], state: 0, imageState: nil)
        
        let terrace = generateEntity(components: [
                   VisualComponent(name: "Terrace", imageName: "terrace", size: CGSize(width: 873, height: 373), position: CGPoint(x: -270, y: 8), zPosition: 0, zRotation: 0)
               ], state: 0, imageState: nil)
        
        let rectangle = generateEntity(components: [
            VisualComponent(name: "rectangle", imageName: "rectangle", size: CGSize(width: 207, height: 648), position: CGPoint(x: -385, y: 96), zPosition: -1, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 207, height: 648), imageName: "rectangle", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ], state: 0, imageState: nil)
        
        let triangle = generateEntity(components: [
            VisualComponent(name: "triangle", imageName: "triangle", size: CGSize(width: 164, height: 206), position: CGPoint(x: 5, y: 96), zPosition: -1, zRotation: 0.267),
            PhysicsComponent(size: CGSize(width: 164, height: 206), imageName: "triangle", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ], state: 0, imageState: nil)
        
        
        let bubble = generateEntity(components: [
                  VisualComponent(name: "bubble", imageName: "DogBubbleOfThought", size: CGSize(width: 230, height: 191), position: CGPoint(x: -134, y: 31), zPosition: 1, zRotation: 0)
              ], state: 0, imageState: nil)
        
        let dog = generateEntity(components: [
            VisualComponent(name: "Dog", imageName: "ShibaInu", size: CGSize(width: 68, height: 107), position: CGPoint(x: -217, y: -41), zPosition: 3, zRotation: 0)
        ], state: 0, imageState: nil)
    }
    
    private func generateEntity(components: [GKComponent], state: Int, imageState: [String]?) -> GKEntity {
        let entity = CustomEntity(state: state, imageState: imageState)
        components.forEach { component in
            entity.addComponent(component)
        }
        entityManager.add(entity)
        return entity
    }
    
    private func generateMissions() {
        let plant1Mission = MissionComponent(missionID: "DogCollar", type: .side, interractObject: ["DogCollar"], neededObject: nil, failedPrompt: nil, successState: ["DogCollar" : "Store"], successPrompt: "You acquired a Dog Collar", sideMissionNeedToBeDone: nil)
        missionSystem.addComponent(mission: plant1Mission)
        
        let getRake = MissionComponent(missionID: "Rake", type: .side, interractObject: ["SapuGarpu"], neededObject: nil, failedPrompt: nil, successState: ["SapuGarpu" : "Store"], successPrompt: "You acquired a rake", sideMissionNeedToBeDone: nil)
        missionSystem.addComponent(mission: getRake)
        
        let swipeLeaves = MissionComponent(missionID: "Leaves", type: .side, interractObject: ["Leaves"], neededObject: "SapuGarpu", failedPrompt: "This backyard could have some cleaning", successState: ["Leaves" : "Change"], successPrompt: "Now this backyard looks better", sideMissionNeedToBeDone: [getRake])
        missionSystem.addComponent(mission: swipeLeaves)
        
        let swipeLeaves2 = MissionComponent(missionID: "Leaves2", type: .side, interractObject: ["Leaves"], neededObject: "SapuGarpu", failedPrompt: "This backyard could have some cleaning", successState: ["Leaves" : "Change"], successPrompt: "Now this backyard looks better", sideMissionNeedToBeDone: [getRake, swipeLeaves])
        missionSystem.addComponent(mission: swipeLeaves2)
        
        let swipeLeaves3 = MissionComponent(missionID: "Leaves3", type: .side, interractObject: ["Leaves"], neededObject: "SapuGarpu", failedPrompt: "This backyard could have some cleaning", successState: ["Leaves" : "Remove"], successPrompt: "Now this backyard looks better", sideMissionNeedToBeDone: [getRake, swipeLeaves, swipeLeaves2])
        missionSystem.addComponent(mission: swipeLeaves3)
        
        let getFrisbee = MissionComponent(missionID: "Frisbee", type: .side, interractObject: ["Frisbee"], neededObject: nil, failedPrompt: "This backyard could have some cleaning", successState: ["Frisbee" : "Store"], successPrompt: "You have acquired a Frisbee", sideMissionNeedToBeDone: [swipeLeaves, swipeLeaves2, swipeLeaves3])
        missionSystem.addComponent(mission: getFrisbee)
        
        let getFishNet = MissionComponent(missionID: "NetStick", type: .side, interractObject: ["NetStick"], neededObject: nil, failedPrompt: nil, successState: ["NetStick" : "Store"], successPrompt: "You have acquired a Net Stick", sideMissionNeedToBeDone: nil)
        missionSystem.addComponent(mission: getFishNet)
        
        let pondMission = MissionComponent(missionID: "Pond", type: .side, interractObject: ["Pond"], neededObject: "NetStick", failedPrompt: "I couldn't see the bottom of the pond", successState: ["Pond" : "Change"], successPrompt: "Now I can see the bottom of the pond", sideMissionNeedToBeDone: [getFishNet])
        missionSystem.addComponent(mission: pondMission)
        
        let pondMission2 = MissionComponent(missionID: "Pond2", type: .side, interractObject: ["Pond"], neededObject: "NetStick", failedPrompt: "I couldn't see the bottom of the pond", successState: ["Pond" : "Change", "NameTag" : "Store"], successPrompt: "You have acquired a name tag", sideMissionNeedToBeDone: [pondMission])
        missionSystem.addComponent(mission: pondMission2)
        
        let mainMission = MissionComponent(missionID: "MainMissioin", type: .main, interractObject: nil, neededObject: nil, failedPrompt: nil, successState: ["":""], successPrompt: "Main Mission succeeded", sideMissionNeedToBeDone: [getFrisbee, pondMission2, plant1Mission])
        missionSystem.addComponent(mission: mainMission)
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
        
        self.camera?.position = (character!.component(ofType: VisualComponent.self)?.visualNode.position)!
        boundsCheckCamera()
        
        if checkIfCharacterStillContact(characterPosition: character?.component(ofType: VisualComponent.self)?.visualNode.position ?? CGPoint(x: 0, y: 0), contactPoint: contactPoint ?? CGPoint(x: 200, y: 200)) == true {
            isColliding = true
            actionButton?.alpha = 1
        } else {
            isColliding = false
            actionButton?.alpha = 0.5
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
                            self.inventoryEntities = inventoryManager.showInventory(sceneSize: self.frame.size, position: camera.position)
                            for inv in self.inventoryEntities {
                                entityManager.add(inv)
                            }
                            isInventoryOpen = true
                        }
                    }
                }
                
                if node.name == "CloseButton" {
                    if isInventoryOpen {
                        // entities to be removed in bulk
                        entityManager.toRemove = Set(self.inventoryEntities)
                        entityManager.removeEntities()
                        isInventoryOpen = false
                    }
                }
                
                if node.name?.contains("InventoryItem") == true {
                    if let entity = entityManager.isInventoryItem(node: node) {
                        if let realName = node.name?.split(separator: "_").dropFirst().first.map({ String($0) }) {
                            currentlyHolding = realName
                            entityManager.toRemove = Set(self.inventoryEntities)
                            entityManager.removeEntities()
                        }
                    }
                }
                
                if node == actionButton {
                    if isColliding {
                        animateActionButton()
                    }
                }
            }
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
    
    private func interractToMission() {
        guard let objectNode = objectNode else { return }
        if let entity = entityManager.isInventoryAble(node: objectNode) as? CustomEntity {
            if let result = missionSystem.checkMission(entity: entity, characterHolding: currentlyHolding ?? nil) {
                result.position = CGPoint(x: -200, y: 150)
                self.camera?.addChild(result)
                contactPoint = CGPoint(x: 0, y: 0)
            } else {
                contactPoint = CGPoint(x: 0, y: 0)
            }
            
        }
    }
    
    func setupJoystick() {
        analogJoystick = AnalogJoystick(diameter: 110, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        analogJoystick!.position = CGPoint(x: -330, y: -100)
        analogJoystick!.zPosition = 2
        self.camera?.addChild(analogJoystick!)
    }
    
    func setupActionButton() {
        actionButton = SKSpriteNode(imageNamed: "BeforeGrab")
        actionButton!.position = CGPoint(x: 300, y: -100)
        actionButton!.size = CGSize(width: 110, height: 120)
        actionButton!.zPosition = 10
        self.camera?.addChild(actionButton!)
    }
    
    func setupInventoryButton() {
        let backpackNode = SKSpriteNode(imageNamed: "Inventory")
        backpackNode.name = "Inventory"
        backpackNode.size = CGSize(width: 100, height: 120)
        backpackNode.position = CGPoint(x: 300, y: 100)
        backpackNode.zPosition = 50
        self.camera?.addChild(backpackNode)
        self.inventoryBtnNode = backpackNode
    }
    
    func dogThought() {
        thoughtItem = SKSpriteNode(imageNamed: "Frisbee")
        thoughtItem!.size = CGSize(width: 52, height: 33)
        thoughtItem!.position = CGPoint(x: -115, y: 52)
        thoughtItem!.zPosition = 2
        addChild(thoughtItem!)
        
        let frisbeeTexture = SKTexture(imageNamed: "Frisbee")
        let dogCollarTexture = SKTexture(imageNamed: "DogCollar")
        let nameTagTexture = SKTexture(imageNamed: "NameTag")
        
        let textureArray = [frisbeeTexture, dogCollarTexture, nameTagTexture]
        let fadeDuration = 0.5
        let waitDuration = 10.0
        
        var sequenceArray: [SKAction] = []
        for texture in textureArray {
            let fadeInAction = SKAction.fadeIn(withDuration: fadeDuration)
            let textureAction = SKAction.setTexture(texture)
            let waitAction = SKAction.wait(forDuration: waitDuration)
            let fadeOutAction = SKAction.fadeOut(withDuration: fadeDuration)
            let textureSequence = SKAction.sequence([textureAction, fadeInAction, textureAction, waitAction, fadeOutAction])
            sequenceArray.append(textureSequence)
        }
        
        let animateAction = SKAction.sequence(sequenceArray)
        let repeatAction = SKAction.repeatForever(animateAction)
        
        thoughtItem!.run(repeatAction)
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
        interractToMission()
    }
}
