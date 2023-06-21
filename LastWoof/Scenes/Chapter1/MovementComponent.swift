//
//  MovementComponent.swift
//  Last Woof
//
//  Created by Angelica Patricia on 21/06/23.
//

import SpriteKit
import GameplayKit

class MovementComponent: GKComponentSystem<GKComponent> {
    
    var node: SKNode
    var joystick: AnalogJoystick
    
    init(node: SKNode, joystick: AnalogJoystick) {
        self.node = node
        self.joystick = joystick
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
