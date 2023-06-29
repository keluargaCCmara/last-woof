//
//  CustomEntity.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 25/06/23.
//

import SpriteKit
import GameplayKit

class CustomEntity: GKEntity {
    
    let state: Int
    var interracted: Int = 0
    let imageState: [String]?
    
    init(state: Int, imageState: [String]?) {
        self.state = state
        self.imageState = imageState
        super.init()
    }
    
    func changeState() {
        if interracted < state {
            if let sc = component(ofType: StateChangeComponent.self) {
                sc.changeState(mode: .texture, texture: SKTexture(imageNamed: imageState![interracted]))
                interracted += 1
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
