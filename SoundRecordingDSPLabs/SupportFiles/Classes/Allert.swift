//
//  Allert.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 18.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import Foundation
import UIKit

class Allert {
    
    static func displayAllert(_ sender: UIViewController, title: String, message: String = "") {
        
        let allert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        sender.present(allert, animated: true, completion: nil)
    }
}
