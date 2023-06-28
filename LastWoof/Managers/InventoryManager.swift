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
    
    init() {
        loadInventory()
    }
    
    func showInventory(sceneSize: CGSize, position: CGPoint) -> [GKEntity] {
        var inventoryNodes: [GKEntity] = []
        
        var idx = 0
        for inv in inventory {
            let newInvIcon = generateInventoryEntity(name: inv, idx: idx, position: position)
            let newInvArray = generateInventoryArrayEntity(idx: idx, position: position)
            inventoryNodes.append(newInvIcon)
            inventoryNodes.append(newInvArray)
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
        
        let size = CGSize(width: 50, height: 50)
        let x = position.x + sceneSize.width/2 - 75
        let y = position.y + sceneSize.height/2 - 50
        
        let vc = VisualComponent(name: "CloseButton", imageName: "CloseButton", size: size, position: CGPoint(x: x, y: y), zPosition: 200, zRotation: 0)
        
        entity.addComponent(vc)
        
        return entity
    }
    
    func generateBubbleEntity(sceneSize: CGSize, position: CGPoint) -> GKEntity {
        let entity = GKEntity()
        
        let width = sceneSize.width
        let height = sceneSize.height
        
        let vc = VisualComponent(name: "InventoryBubble", imageName: "InventoryBubble", size: CGSize(width: width, height: height), position: position, zPosition: 101, zRotation: 0)
        
        entity.addComponent(vc)
        
        return entity
    }
    
    func generateOverlayEntity(sceneSize: CGSize, position: CGPoint) -> GKEntity {
        let entity = GKEntity()
        
        let vc = VisualComponent(name: "Overlays", imageName: "Overlays", size: sceneSize, position: position, zPosition: 100, zRotation: 0)
        
        entity.addComponent(vc)
        
        return entity
    }
    
    func generateInventoryArrayEntity(idx: Int, position pos: CGPoint) -> GKEntity {
        let newEntity = GKEntity()
        
        let padding = 40
        let width = 162
        let height = 84
        let row = idx / 4
        let x = (pos.x - CGFloat(170)) + CGFloat((padding + width/2)) * CGFloat(idx)
        let y = (pos.y + CGFloat(54)) - CGFloat((padding + height/2)) * CGFloat(row)
        
        let vc = VisualComponent(name: "InventoryArray", imageName: "InventoryArray", size: CGSize(width: width, height: height), position: CGPoint(x: x, y: y), zPosition: 102, zRotation: 0)
        
        newEntity.addComponent(vc)
        
        return newEntity
    }
    
    func generateInventoryEntity(name: String, idx: Int, position pos: CGPoint) -> GKEntity {
        let newEntity = GKEntity()
        
        let padding = 40
        let width = 50
        let height = 45
        let row = idx / 4
        let x = (pos.x - CGFloat(170)) + CGFloat((padding + width)) * CGFloat(idx)
        let y = (pos.y + CGFloat(54)) - CGFloat((padding + height)) * CGFloat(row)
        
        let vc = VisualComponent(name: "InventoryItem_\(name)", imageName: name, size: CGSize(width: width, height: height), position: CGPoint(x: x, y: y), zPosition: 103, zRotation: 0)
        let ric = RemoveInventoryComponent()
        let scc = StateChangeComponent()
        
        newEntity.addComponent(vc)
        newEntity.addComponent(ric)
        newEntity.addComponent(scc)
        
        return newEntity
    }
    
    func loadInventory() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Inventory")
        request.returnsObjectsAsFaults = false
        do {
            let result = try persistenceController.viewContext.fetch(request)
            for data in result as! [Inventory] {
                let d = data.value(forKey: "name") as! String
                saveToInventory(name: d)
            }
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
        inventory = Set<String>()
    }
}
