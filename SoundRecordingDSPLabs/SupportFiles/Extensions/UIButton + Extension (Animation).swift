//
//  UIButton + Extension (Animation).swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 20.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit

extension UIButton {
    
    func pulsate() {
        let pulseAnimation = CASpringAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.6
        pulseAnimation.fromValue = 0.95
        pulseAnimation.toValue = 1
        pulseAnimation.autoreverses = true
        pulseAnimation.initialVelocity = 0.5
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.damping = 1
        layer.add(pulseAnimation, forKey: nil)
    }
}
