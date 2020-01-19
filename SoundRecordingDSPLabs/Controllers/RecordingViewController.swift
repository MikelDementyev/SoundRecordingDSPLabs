//
//  ViewController.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 18.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit
import AVFoundation

enum AGAudioRecorderState {
    case Pause
    case Play
    case Stop
}

class RecodringViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var startStopRecording: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    private var recorderState: AGAudioRecorderState = .Stop

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setRecordingSession()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openRecordsList" {
            if let nextViewController = segue.destination as?  RecodrsListViewController {
                nextViewController.recordingSession = recordingSession
                stopRecording()
            }
        }
    }
    
    private func unloadUI() {
        startStopRecording.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setRecordingSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        self.unloadUI()
                        Allert.displayAllert(self, title: "Ошибка", message: "Необходим доступ к микрофону")
                    }
                }
            }
        } catch {
            Allert.displayAllert(self, title: "Ошибка")
        }
    }
    
    func startRecording() {
        let format = DateFormatter()
        format.dateFormat="HH-mm-ss-SSS"
        let fileName = Storage.getDocumentDirectoryUrl().appendingPathComponent("record-\(format.string(from: Date())).m4a")
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            startStopRecording.setImage(#imageLiteral(resourceName: "icon-stop"), for: .normal)
            pauseButton.isHidden = false
        } catch {
            Allert.displayAllert(self, title: "Ups!", message: "Recording failed")
        }
        recorderState = .Play
    }
    
    func stopRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
            startStopRecording.setImage(#imageLiteral(resourceName: "icon-play"), for: .normal)
            pauseButton.setImage(#imageLiteral(resourceName: "icon-pause"), for: .normal)
            pauseButton.isHidden = true
            recorderState = .Stop
        }
    }

    @IBAction func record(_ sender: Any) {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    @IBAction func recordPause(_ sender: Any) {
        
        if audioRecorder != nil {
            if recorderState == .Play {
                audioRecorder.pause()
                pauseButton.setImage(#imageLiteral(resourceName: "icon-resume"), for: .normal)
                recorderState = .Pause
            } else if recorderState == .Pause {
                audioRecorder.record()
                pauseButton.setImage(#imageLiteral(resourceName: "icon-pause"), for: .normal)
                recorderState = .Play
            }
        }
        
    }
}

