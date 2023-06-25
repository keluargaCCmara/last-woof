//
//  InventoryManager.swift
//  Last Woof
//
//  Created by Angela Christabel on 23/06/23.
//

import Foundation
import CoreData
import SpriteKit
import GameplayKit

class InventoryManager {
    private var persistenceController = PersistenceController.shared
    private var hasChanges = false
    
    static let shared = InventoryManager()
    
    var inventory = Set<String>()
    var currentHolding: String?
    
    init() {
        loadInventory()
    }
    
    func showInventory(sceneSize: CGSize, position: CGPoint) -> [GKEntity] {
        var inventoryNodes: [GKEntity] = []
        
        var idx = 0
        for inv in inventory {
            let newInvIcon = generateInventoryEntity(name: inv, idx: idx)
            inventoryNodes.append(newInvIcon)
            idx += 1
        }
        
        // overlay
        let overlayEntity = generateOverlayEntity(sceneSize: sceneSize, position: position)
        
        // cloud
        let bubbleEntity = generateBubbleEntity(sceneSize: sceneSize, position: position)
        
        // close button
        let closeEntity = generateCloseEntity(sceneSize: sceneSize, position: position)
        
        inventoryNodes.append(overlayEntity)
        inventoryNodes.append(bubbleEntity)
        inventoryNodes.append(closeEntity)

        return inventoryNodes
    }
    
    func generateCloseEntity(sceneSize: CGSize, position: CGPoint) -> GKEntity {
        let entity = GKEntity()
        
        let size = CGSize(width: 100, height: 100)
        let x = position.x + sceneSize.width/2 - 100
        let y = position.y + sceneSize.height/2 - 200
        
        let vc = VisualComponent(imageName: "CloseButton", size: size, position: CGPoint(x: x, y: y), zPosition: 200, zRotation: 0)
        
        entity.addComponent(vc)
        
        return entity
    }
    
    func generateBubbleEntity(sceneSize: CGSize, position: CGPoint) -> GKEntity {
        let entity = GKEntity()
        
        let width = sceneSize.width - 200
        let height = sceneSize.height - 200
        
        let vc = VisualComponent(imageName: "InventoryBubble", size: CGSize(width: width, height: height), position: position, zPosition: 101, zRotation: 0)
        
        entity.addComponent(vc)
        
        return entity
    }
    
    func generateOverlayEntity(sceneSize: CGSize, position: CGPoint) -> GKEntity {
        let entity = GKEntity()
        
        let vc = VisualComponent(imageName: "Overlays", size: sceneSize, position: position, zPosition: 100, zRotation: 0)
        
        entity.addComponent(vc)
        
        return entity
    }
    
    func generateInventoryEntity(name: String, idx: Int) -> GKEntity {
        let newEntity = GKEntity()
        
        let padding = 20
        let width = 100
        let height = 100
        let row = idx % 4
        let x = 300 + (padding + width) * idx
        let y = 100 - (padding + height) * row
        
        let vc = VisualComponent(imageName: name, size: CGSize(width: width, height: height), position: CGPoint(x: x, y: y), zPosition: 102, zRotation: 0)
        let ric = RemoveInventoryComponent()
        let scc = StateChangeComponent()
        
        newEntity.addComponent(vc)
        newEntity.addComponent(ric)
        newEntity.addComponent(scc)
        
        return newEntity
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
    
    func removeFromInventory(name: String) {
        if inventory.contains(name) {
            inventory.remove(name)
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
