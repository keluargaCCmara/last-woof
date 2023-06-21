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
    static let character: UInt32 = 0b1
    static let obstacle: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var cameraNode: SKCameraNode = SKCameraNode()
    private var background: SKSpriteNode?
    private var obstacles: [SKSpriteNode] = []
    private var character: SKSpriteNode?
    
    private let characterMovePointsPerSec: CGFloat = 480.0
    private var characterVelocity = CGPoint.zero
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: TimeInterval = 0
    
    private var lastTouchLocation: CGPoint?
    
    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        character = generateCharacter(imageNamed: "DummyCharacter", xPosition: 140, yPosition: -183)
        addChild(character!)
        let pond = generateObstacle(imagedName: "Pond", width: 1604, height: 844, xPosition: 1647, yPosition: -1217)
        let plant1 = generateObstacle(imagedName: "Plant1-Task", width: 1288, height: 651, xPosition: 1777, yPosition: 325)
        
        obstacles = [pond, plant1]
        for obstacle in obstacles {
            addChild(obstacle)
        }
        
        cameraNode.position = character!.position
    }
    
    private func generateCharacter(imageNamed: String, xPosition: Double, yPosition: Double) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imageNamed)
        let character = SKSpriteNode(texture: texture)
        character.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        character.physicsBody?.isDynamic = true
        character.physicsBody?.affectedByGravity = false
        character.physicsBody?.categoryBitMask = PhysicsCategory.character
        character.position = CGPoint(x: xPosition, y: yPosition)
        
        return character
    }
    
    private func generateObstacle(imagedName: String, width: Double, height: Double, xPosition: Double, yPosition: Double) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imagedName)
        let textureSize = CGSize(width: width, height: height)
        let obstacle = SKSpriteNode(texture: texture, size: textureSize)
        obstacle.physicsBody = SKPhysicsBody(texture: texture, size: textureSize)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        
        return obstacle
    }
    
    private func boundsCheckCharacter() {
            let minX = background!.position.x - background!.size.width / 2 + character!.size.width / 2
            let minY = background!.position.y - background!.size.height / 2 + character!.size.height / 2
            let maxX = background!.position.x + background!.size.width / 2 - character!.size.width / 2
            let maxY = background!.position.y + background!.size.height / 2 - character!.size.height / 2
            
            if character!.position.x < minX {
                character!.position.x = minX
            } else if character!.position.x > maxX {
                character!.position.x = maxX
            }
            
            if character!.position.y < minY {
                character!.position.y = minY
            } else if character!.position.y > maxY {
                character!.position.y = maxY
            }
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
        }
    
    func moveCharacterToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - character!.position.x, y: location.y - character!.position.y)
        let xSquared = offset.x * offset.x
        let ySquared = offset.y * offset.y
        let sumOfSquares = xSquared + ySquared
        let length = sqrt(Double(sumOfSquares))
        
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        
        characterVelocity = CGPoint(x: direction.x * characterMovePointsPerSec, y: direction.y * characterMovePointsPerSec)
    }
    
    func moveCharacter(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        print("Amount to move: \(amountToMove)")
        
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveCharacterToward(location: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveCharacterToward(location: touchLocation)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
        
        if let lastTouchLocation = lastTouchLocation {
            let diff = CGPoint(x: lastTouchLocation.x - character!.position.x, y: lastTouchLocation.y - character!.position.y )
            let diffLength = hypot(diff.x, diff.y)
            if (diffLength <= characterMovePointsPerSec * CGFloat(dt)) {
                character!.position = lastTouchLocation
                characterVelocity = CGPointZero
            } else {
                moveCharacter(sprite: character!, velocity: characterVelocity)
            }
        }
        cameraNode.position = character!.position
        scene?.camera = cameraNode
        boundsCheckCamera()
        boundsCheckCharacter()
    }
    
}
