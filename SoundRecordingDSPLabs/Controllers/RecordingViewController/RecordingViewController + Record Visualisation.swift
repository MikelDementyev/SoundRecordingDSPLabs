//
//  RecordingViewController + Record Visualisation.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 20.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

extension RecodringViewController {
    
    func visualisingRecord() {
        
        self.recordingTs = NSDate().timeIntervalSince1970
        let inputNode = self.audioEngine.inputNode
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer, time) in
            let level: Float = -50
            let length: UInt32 = 1024
            buffer.frameLength = length
            let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
            var value: Float = 0
            vDSP_meamgv(channels[0], 1, &value, vDSP_Length(length))
            var average: Float = ((value == 0) ? -100 : 20.0 * log10f(value))
            if average > 0 {
                average = 0
            } else if average < -100 {
                average = -100
            }
            let silent = average < level
            let ts = NSDate().timeIntervalSince1970
            if ts - self.renderTs > 0.1 {
                let floats = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
                let frame = floats.map({ (f) -> Int in
                    return Int(f * Float(Int16.max))
                })
                DispatchQueue.main.async {
                    self.renderTs = ts
                    let len = self.audioView.waveforms.count
                    for i in 0 ..< len {
                        let idx = ((frame.count - 1) * i) / len
                        let f: Float = sqrt(1.5 * abs(Float(frame[idx])) / Float(Int16.max))
                        self.audioView.waveforms[i] = min(49, Int(f * 50))
                    }
                    self.audioView.active = !silent
                    self.audioView.setNeedsDisplay()
                }
            }
        }
        do {
            audioView.isHidden = false
            self.audioEngine.prepare()
            try self.audioEngine.start()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    func stopEngine() {
        audioView.isHidden = true
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
