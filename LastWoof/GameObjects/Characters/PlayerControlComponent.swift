//
//  PlayerControlComponent.swift
//  Last Woof
//
//  Created by Angela Christabel on 22/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class PlayerControlComponent: GKComponent {
    // MARK: Properties
    var visualComponent: VisualComponent? {
        return entity?.component(ofType: VisualComponent.self)
    }
    let entityManager: EntityManager
    
    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        super.init()
    }
    
    // MARK: Methods
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func animatePlayerDirection(direction: CGPoint){
        updateCharacterOrientation(frameName: setPlayerOrientation(direction: direction))
    }
    
//    private func updateCharacterOrientation(frameName: String) {
//        guard let characterEntity = getCharacterEntity(),
//              let visualComponent = characterEntity.component(ofType: VisualComponent.self)
//        else {
//            return
//        }
//        visualComponent.visualNode.texture = SKTexture(imageNamed: "\(frameName)_0")
//    }
    private func updateCharacterOrientation(frameName: String) {
        guard let characterEntity = getCharacterEntity(),
              let visualComponent = characterEntity.component(ofType: VisualComponent.self)
        else {
            return
        }
        
        var currentFrameSuffix = "_0"
        if let currentTexture = visualComponent.visualNode.texture,
           currentTexture.description.contains("_0") {
            currentFrameSuffix = "_1"
        }
        
        let newTextureName = "\(frameName)\(currentFrameSuffix)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35){
            visualComponent.visualNode.texture = SKTexture(imageNamed: newTextureName)
        }
    }


    private func setPlayerOrientation(direction: CGPoint) -> String {
        var directionInString: String = "right"

        if(direction.x > 30){
            directionInString = "right"
        }
        else if(direction.x < -30) {
            directionInString = "left"
        }
        else if(direction.y > 30) {
            directionInString = "up"
        }
        else if (direction.y < -30){
            directionInString = "down"
        }
        return directionInString
    }
    
    private func getCharacterEntity() -> GKEntity? {
        for entity in entityManager.entities {
            if entity.component(ofType: VisualComponent.self)?.visualNode.name == "Character" {
                return entity
            }
        }
        return nil
    }

}
