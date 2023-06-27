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
    func changeState(mode: State, texture: SKTexture? = nil, size: CGSize? = nil) {
        if mode == .fade {
            fade()
        } else {
            changeTexture(texture: texture, size: size)
        }
    }
    
    /// Tells this entity's visual  component to fade.
    private func fade() {
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        if let vc = visualComponent {
            vc.visualNode.run(fadeAction)
        }
    }
    
    /// Tells this entity's visual component to change texture/state
    private func changeTexture(texture: SKTexture?, size: CGSize?) {
        guard let node = visualComponent?.visualNode else {return}
        node.texture = texture
        if let s = size {
            node.size = s
        }
    }
}

