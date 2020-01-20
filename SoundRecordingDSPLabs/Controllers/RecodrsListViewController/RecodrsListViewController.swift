//
//  RecodrsListViewController.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 18.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit
import AVFoundation

class RecodrsListViewController: UITableViewController, AVAudioRecorderDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    
    var recordsList: [String] = []
    var currentRecord: (indexPath: IndexPath, cell: RecordCell)!
    var progressTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRecordingSession()
        let nib = UINib.init(nibName: "RecordCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RecordCell")
        recordsList = Storage.getListOfRecors()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        title = "Список записей"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stopPlayerAndOffProgress()
    }
    
    private func setRecordingSession() {
        do {
            try recordingSession.setCategory(.playback, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            Allert.displayAllert(self, title: "Ошибка")
        }
    }
    
    func playRecord(indexPath: Int) -> Bool{
        let path = Storage.getDocumentDirectoryUrl().appendingPathComponent(recordsList[indexPath])
        if let player = audioPlayer {
            if !player.isPlaying  {
                if currentRecord.indexPath.row != indexPath {
                    stopPlayerAndOffProgress()
                    return playCurrentRecord(for: path)
                } else {
                    audioPlayer.play()
                    return true
                }
            } else if player.isPlaying && currentRecord.indexPath.row == indexPath {
                audioPlayer.pause()
                return false
            } else if player.isPlaying && currentRecord.indexPath.row != indexPath {
                stopPlayerAndOffProgress()
                currentRecord.cell.playButton.setImage(#imageLiteral(resourceName: "icon-resume"), for: .normal)
                 return playCurrentRecord(for: path)
            }
        } else {
            return playCurrentRecord(for: path)
        }
        return false
    }
    
    private func playCurrentRecord(for url: URL) -> Bool{
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.play()
            return true
        } catch {
            Allert.displayAllert(self, title: "Ошибка!", message: "Не удалось открыть файл!")
            stopPlayerAndOffProgress()
            currentRecord = nil
            audioPlayer = nil
            return false
        }
    }
    
    func stopPlayerAndOffProgress() {
        if let player = audioPlayer {
            player.stop()
        }
        if let record = currentRecord {
            record.cell.progressBar.setProgress(0, animated: false)
        }
        if let timer = self.progressTimer {
            timer.invalidate()
        }
    }
}

extension RecodrsListViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        currentRecord.cell.playButton.setImage(#imageLiteral(resourceName: "icon-resume"), for: .normal)
        currentRecord.cell.progressBar.progress = 0
        if let timer = progressTimer {
            timer.invalidate()
        }
    }
}
