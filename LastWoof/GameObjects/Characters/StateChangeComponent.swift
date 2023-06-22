//
//  ChangeStateComponent.swift
//  Last Woof
//
//  Created by Angela Christabel on 18/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

enum State {
    case fade, texture
}

class StateChangeComponent: GKComponent {
    // MARK: Properties

    /// A convenience property for the entity's visual component
    var visualComponent: VisualComponent? {
        return entity?.component(ofType: VisualComponent.self)
    }

    // MARK: Methods
    func changeState(mode: State, _ texture: SKTexture?) {
        if mode == .fade {
            fade()
        } else {
            changeTexture(texture: texture)
        }
    }
    
    /// Tells this entity's visual  component to fade.
    func fade() {
        let fadeAction = SKAction.fadeOut(withDuration: 1.5)
        visualComponent?.visualNode.run(fadeAction)
    }
    
    /// Tells this entity's visual component to change texture/state
    func changeTexture(texture: SKTexture?) {
        guard let node = visualComponent?.visualNode else {return}
        
//        if node.state == 1 {
//            if let texture = texture {
//                node.state = 2
//                node.texture = texture
//            }
//        }
    }
}

