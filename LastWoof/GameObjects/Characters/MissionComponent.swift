//
//  MissionComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class MissionComponent: GKComponent {
    
    var entityManager: EntityManager = EntityManager.shared
    
    let missionID: String
    let type: String
    let interractObject: String?
    let neededObject: [String]?
    let failedPrompt: String?
    let successState: [String : String]
    let successPrompt: String
    let stateRequirement: Int
    
    init(missionID: String, type: String, interractObject: String?, neededObject: [String]?, failedPrompt: String?, successState: [String : String], successPrompt: String, stateRequirement: Int) {
        self.missionID = missionID
        self.type = type
        self.interractObject = interractObject
        self.neededObject = neededObject
        self.failedPrompt = failedPrompt
        self.successState = successState
        self.successPrompt = successPrompt
        self.stateRequirement = stateRequirement
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func succes() {
        for (object, action) in successState {
            if action == "Remove" {
                guard let entity = entitySearcher(name: object) else { return }
                entityManager.removeEntity(entity: entity)
            } else if action == "Store" {
                guard let entity = entitySearcher(name: object) else { return }
                entityManager.storeInventory(entity: entity)
                entityManager.removeEntity(entity: entity)
            }
        }
    }
    
    private func entitySearcher(name: String) -> GKEntity? {
        for entity in entityManager.entities {
            if entity.component(ofType: VisualComponent.self)?.visualNode.name == name {
                return entity
            }
        }
        return nil
    }
    
}

