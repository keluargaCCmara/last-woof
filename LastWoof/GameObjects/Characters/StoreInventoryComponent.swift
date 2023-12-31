//
//  StoreInventoryComponent.swift
//  Last Woof
//
//  Created by Angela Christabel on 20/06/23.
//

import Foundation
import SpriteKit
import GameplayKit


class StoreInventoryComponent: GKComponent {
    // MARK: Properties
    var inventoryManager = InventoryManager.shared
    
    var visualComponent: VisualComponent? {
        return entity?.component(ofType: VisualComponent.self)
    }
    
    // MARK: Methods
    func storeInventory() {
        // store in users inventory
        let name = visualComponent?.visualNode.name
        inventoryManager.saveToInventory(name: name!)
    }
}
