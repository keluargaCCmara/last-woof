//
//  MovementComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 19/06/23.
//

import GameplayKit

class MovementComponent: GKComponent {
    
    let node: SKShapeNode
    var velocity = CGPoint.zero
    var movePointsPerSec: CGFloat = 480.0
    var dt: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0

    init(node: SKShapeNode) {
        self.node = node
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveCharacterToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - node.position.x, y: location.y - node.position.y)
        let xSquared = offset.x * offset.x
        let ySquared = offset.y * offset.y
        let sumOfSquares = xSquared + ySquared
        let length = sqrt(Double(sumOfSquares))

        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))

        velocity = CGPoint(x: direction.x * movePointsPerSec, y: direction.y * movePointsPerSec)
    }

    func moveCharacter(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        print("Amount to move: \(amountToMove)")

        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
}
