//
//  Int + Extension.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 19.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit

extension Int {
  var degreesToRadians: CGFloat {
    return CGFloat(self) * .pi / 180.0
  }
}
