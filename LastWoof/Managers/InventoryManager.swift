//
//  InventoryManager.swift
//  Last Woof
//
//  Created by Angela Christabel on 23/06/23.
//

import Foundation
import CoreData

class InventoryManager {
    private var persistenceController = PersistenceController.shared
    private var hasChanges = false
    
    static let shared = InventoryManager()
    
    var inventory = Set<String>()
    
    init() {
        loadInventory()
    }
    
    func loadInventory() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Inventory")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try persistenceController.viewContext.fetch(request)
            for data in result as! [Inventory] {
                let d = data.value(forKey: "name") as! String
                saveToInventory(name: d)
            }
//            print("========================")
//            print("inventory: \(inventory)")
        } catch {
            print("Failed to load Inventory")
        }
    }
    
    func saveToInventory(name: String) {
        if !inventory.contains(name) {
            inventory.insert(name)
            hasChanges = true
        }
    }
    
    func finalSave() {
        if hasChanges {
            persistenceController.deleteAllData("Inventory")
            
            for inv in inventory {
                let newInventory = Inventory(context: persistenceController.viewContext)
                newInventory.name = inv
            }
            
            persistenceController.save()
            hasChanges = false
        }
    }
}
