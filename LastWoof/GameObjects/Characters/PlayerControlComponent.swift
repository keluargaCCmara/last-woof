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
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        let inventoryAbleEntities = entityManager.inventoryAbleEntities()
        
        for invEntity in inventoryAbleEntities {
            // Get required components
            guard let inventoryComponent = invEntity.component(ofType: VisualComponent.self) else { continue }

            if (visualComponent?.visualNode.calculateAccumulatedFrame().intersects(inventoryComponent.visualNode.calculateAccumulatedFrame())) == true {
                print("bump into inventoryable")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
