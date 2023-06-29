//
//  EntityManager.swift
//  Last Woof
//
//  Created by Angela Christabel on 22/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    var scene: SKScene?
    
    static let shared = EntityManager()
    
    lazy var componentSystems: [GKComponentSystem] = {
        let visualSystem = GKComponentSystem(componentClass: VisualComponent.self)
        let playerControlSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
        let physicsSystem = GKComponentSystem(componentClass: PhysicsComponent.self)
        let stateChangeSystem = GKComponentSystem(componentClass: StateChangeComponent.self)
        let storeInventorySystem = GKComponentSystem(componentClass: StoreInventoryComponent.self)
        let removeInventorySystem = GKComponentSystem(componentClass: RemoveInventoryComponent.self)
        return [visualSystem, playerControlSystem, physicsSystem, stateChangeSystem, storeInventorySystem, removeInventorySystem]
    }()
    
    func add(_ entity: GKEntity) {
        guard let scene = self.scene else { return }
        entities.insert(entity)

        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }

       if let visualNode = entity.component(ofType: VisualComponent.self)?.visualNode {
           scene.addChild(visualNode)
       }
    }
    
    func isInventoryAble(node: SKNode) -> GKEntity? {
        for entity in entities {
            if let vn = entity.component(ofType: VisualComponent.self)?.visualNode {
                if vn == node {
                    if let _ = entity.component(ofType: StoreInventoryComponent.self) {
                        return entity
                    }
                }
            }
        }
        return nil
    }
    
    func isInventoryItem(node: SKNode) -> GKEntity? {
        for entity in entities {
            if let vn = entity.component(ofType: VisualComponent.self)?.visualNode {
                if vn == node {
                    if let _ = entity.component(ofType: RemoveInventoryComponent.self) {
                        return entity
                    }
                }
            }
        }
        return nil
    }
    
    func storeInventory(entity: GKEntity) {
        guard let scene = scene else { return }
        
        let inventoryBtn = scene.camera?.childNode(withName: "Inventory") as! SKSpriteNode
        inventoryBtn.texture = SKTexture(imageNamed: "InventoryOpen")
        inventoryBtn.size.height = 300
        
        let inventorySi = entity.component(ofType: StoreInventoryComponent.self)
        let inventoryVc = entity.component(ofType: VisualComponent.self)?.visualNode
        
        let posBtn = scene.convertPoint(fromView: CGPoint(x: 700, y: 50))
    
        inventoryVc?.zPosition = 100
        let moveToCenter = SKAction.move(to: scene.convertPoint(fromView: scene.view!.center), duration: 0.5)
        let zoomWidth = inventoryVc!.size.width * 1.5
        let zoomHeight = inventoryVc!.size.height * 1.5
        let zoom = SKAction.resize(toWidth: zoomWidth, height: zoomHeight, duration: 0.5)
        let zoomCenter = SKAction.group([moveToCenter, zoom])
        
        let unzoomWidth = inventoryVc!.size.width * 0.4
        let unzoomHeight = inventoryVc!.size.height * 0.4
        let unzoom = SKAction.resize(toWidth: unzoomWidth, height: unzoomHeight, duration: 0.5)
        let moveAction = SKAction.move(to: posBtn, duration: 0.5)
        moveAction.timingMode = SKActionTimingMode.easeOut
        let unzoomMove = SKAction.group([moveAction, unzoom])
        
        let wait = SKAction.wait(forDuration: 0.5)
        
        let removeAction = SKAction.run({
            inventorySi?.storeInventory()
            self.removeEntity(entity: entity)
            inventoryBtn.texture = SKTexture(imageNamed: "Inventory")
            inventoryBtn.size.height = 244
        })
        let sequence = SKAction.sequence([zoomCenter, wait, unzoomMove, removeAction])

        inventoryVc?.run(sequence)
    }
    
    func removeEntity(entity: GKEntity) {
        guard let scene = self.scene else { return }
        // fade out
        let stateChangeComp = entity.component(ofType: StateChangeComponent.self)
        let visComp = entity.component(ofType: VisualComponent.self)
        stateChangeComp?.changeState(mode: .fade)
        // remove from entity list
//        let physicsComponent = entity.component(ofType: PhysicsComponent.self)
//        physicsComponent?.visualComponent?.visualNode.physicsBody = nil
//        scene.removeChildren(in: [visComp!.visualNode as SKNode])
//        entities.remove(entity as! CustomEntity)
    }
    
    func removeEntities() {
        guard let scene = self.scene else { return }
        for entity in toRemove {
            let vn = entity.component(ofType: VisualComponent.self)
            scene.removeChildren(in: [vn!.visualNode as SKNode])
            entities.remove(entity)
        }
    }
    
    func getEntity(name: String) -> GKEntity? {
        for entity in entities {
            if let vc = entity.component(ofType: VisualComponent.self) {
                if vc.visualNode.name == name {
                    return entity
                }
            }
        }
        return nil
    }
    
    func getEntity(node: SKNode) -> GKEntity? {
        for entity in entities {
            if let vc = entity.component(ofType: VisualComponent.self) {
                if vc.visualNode == node {
                    return entity
                }
            }
        }
        return nil
    }
    
    func showSelected(location: CGPoint) {
        guard let scene = scene else { return }
        let selectedNodes = scene.nodes(at: location)
        
        for node in selectedNodes {
            if let sprite = node as? SKSpriteNode {
                if sprite.name == "InventoryArray" {
                    if let entity = getEntity(node: sprite) {
                        if let changeComp = entity.component(ofType: StateChangeComponent.self) {
                            let texture = SKTexture(imageNamed: "InventorySelected")
                            changeComp.changeState(mode: .texture, texture: texture)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func showUnselected(location: CGPoint) {
        guard let scene = scene else { return }
        let selectedNodes = scene.nodes(at: location)
        
        for node in selectedNodes {
            if let sprite = node as? SKSpriteNode {
                if sprite.name == "InventoryArray" {
                    if let entity = getEntity(node: sprite) {
                        if let changeComp = entity.component(ofType: StateChangeComponent.self) {
                            let texture = SKTexture(imageNamed: "InventoryArray")
                            changeComp.changeState(mode: .texture, texture: texture)
                            return
                        }
                    }
                }
            }
        }
    }

    func update(deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
    }
}
