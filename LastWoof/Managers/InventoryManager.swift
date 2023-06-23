//
//  InventoryManager.swift
//  Last Woof
//
//  Created by Angela Christabel on 23/06/23.
//

import Foundation

class InventoryManager {
    private var persistenceController = PersistenceController.shared
    private var hasChanges = false
    
    static let shared = InventoryManager()
    
    var inventory = Set<String>()
    
    func saveToInventory(name: String) {
        if !inventory.contains(name) {
            inventory.insert(name)
            hasChanges = true
        }
    }
    
    func finalSave() {
        if hasChanges {
            for inv in inventory {
                let newInventory = Inventory(context: persistenceController.viewContext)
                newInventory.name = inv
            }
            
            persistenceController.save()
            hasChanges = false
        }
    }
}
