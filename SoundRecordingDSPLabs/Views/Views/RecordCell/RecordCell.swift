//
//  RecordCell.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 19.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {
    
    @IBOutlet weak var recordName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var playRecord: (() -> Void)?
    
    @IBAction func playRecord(_ sender: Any) {
        playRecord?()
    }
    
}
