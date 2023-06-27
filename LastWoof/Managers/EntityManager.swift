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
    
    func add(scene: SKScene, _ entity: GKEntity) {
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
        let inventoryComp = entity.component(ofType: StoreInventoryComponent.self)
        inventoryComp?.storeInventory()
    }
    
    func removeEntity(scene: SKScene, entity: GKEntity) {
        // fade out
        let stateChangeComp = entity.component(ofType: StateChangeComponent.self)
        let visComp = entity.component(ofType: VisualComponent.self)
        stateChangeComp?.changeState(mode: .fade)
        // remove from entity list
        scene.removeChildren(in: [visComp!.visualNode as SKNode])
        entities.remove(entity)
    }
    
    func removeEntities(scene: SKScene) {
        for entity in toRemove {
            let vn = entity.component(ofType: VisualComponent.self)
            scene.removeChildren(in: [vn!.visualNode as SKNode])
            entities.remove(entity)
        }
    }

    func update(deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
    }
}
