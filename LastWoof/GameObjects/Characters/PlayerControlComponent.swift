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
}
