//
//  RemoveInventoryComponent.swift
//  Last Woof
//
//  Created by Angela Christabel on 20/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class RemoveInventoryComponent: GKComponent {
    // MARK: Properties
    var visualComponent: VisualComponent? {
        return entity?.component(ofType: VisualComponent.self)
    }
    
    // MARK: Methods
    func removeFromInventory() {
        // remove from users inventory
    }
}
