//
//  MovementComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 19/06/23.
//

import GameplayKit

class MovementComponent: GKComponent {
    
    var visualComponent: VisualComponent? {
        return entity?.component(ofType: VisualComponent.self)
    }
    
    private let velocityMultiplier: CGFloat = 0.0375
    private var analogJoystick: AnalogJoystick?
    
    init(analogJoystick: AnalogJoystick) {
        self.analogJoystick = analogJoystick
        super.init()
        
        analogJoystick.trackingHandler = { [unowned self] data in
            self.move(data)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(_ data: AnalogJoystickData) {
        guard let visualComponent = visualComponent else { return }
        
        visualComponent.moveCharacter(data, velocityMultiplier: velocityMultiplier)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        analogJoystick!.trackingHandler = { [unowned self] data in
            self.move(data)
        }
    }
}
