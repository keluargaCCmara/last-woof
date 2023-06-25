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
    let scene: SKScene
    
    static let shared = EntityManager(scene: scene)
    
    lazy var componentSystems: [GKComponentSystem] = {
        let visualSystem = GKComponentSystem(componentClass: VisualComponent.self)
        let playerControlSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
        let physicsSystem = GKComponentSystem(componentClass: PhysicsComponent.self)
        let stateChangeSystem = GKComponentSystem(componentClass: StateChangeComponent.self)
        let storeInventorySystem = GKComponentSystem(componentClass: StoreInventoryComponent.self)
        let removeInventorySystem = GKComponentSystem(componentClass: RemoveInventoryComponent.self)
        return [visualSystem, playerControlSystem, physicsSystem, stateChangeSystem, storeInventorySystem, removeInventorySystem]
    }()
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(_ entity: GKEntity) {
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
                    return entity
                }
            }
        }
        return nil
    }
    
    func storeInventory(entity: GKEntity) {
        let inventoryComp = entity.component(ofType: StoreInventoryComponent.self)
        inventoryComp?.storeInventory()
    }
    
    func removeEntity(entity: GKEntity) {
        // fade out
        let stateChangeComp = entity.component(ofType: StateChangeComponent.self)
        stateChangeComp?.changeState(mode: .fade)
        // remove from entity list
        let physicsComponent = entity.component(ofType: PhysicsComponent.self)
        physicsComponent?.visualComponent?.visualNode.physicsBody = nil
        entities.remove(entity)
    }
    
//    func inventoryAbleEntities() -> [GKEntity] {
//        var inventories: [GKEntity] = []
//        for entity in entities {
//            if let _ = entity.component(ofType: StoreInventoryComponent.self) {
//                inventories.append(entity)
//            }
//        }
//        return inventories
//    }

    func update(deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
    }
}
