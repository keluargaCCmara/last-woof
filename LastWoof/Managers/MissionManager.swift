//
//  MissionManager.swift
//  Last Woof
//
//  Created by Angela Christabel on 02/07/23.
//

import Foundation

class MissionManager {
    static let shared = MissionManager()
    let persistenceController = PersistenceController.shared
    
    var state: GameState?
    
    func saveGameState() {
        guard let completed = state?.sideMissionsCompleted else {return}
        
        for mission in completed {
            let new = Mission(context: persistenceController.viewContext)
        }
    }
    
    func loadGameState() {
        
    }
}
