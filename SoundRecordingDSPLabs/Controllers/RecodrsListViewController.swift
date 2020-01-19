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
    
    private func playRecord(indexPath: Int) -> Bool{
        let path = Storage.getDocumentDirectoryUrl().appendingPathComponent(recordsList[indexPath])
        if let player = audioPlayer {
            if !player.isPlaying  {
                if currentRecord.indexPath.row != indexPath {
                    stopPlayerAndOffProgress()
                    playCurrentRecord(for: path)
                    return true
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
                playCurrentRecord(for: path)
                return true
            }
        } else {
            playCurrentRecord(for: path)
            return true
        }
        return false
    }
    
    private func initRecordCell(_ cell: RecordCell, at indexPath: IndexPath) {
        let cellTitle = recordsList[indexPath.row]
        cell.recordName.text = cellTitle
        cell.playRecord = { [weak self] in
            if self?.playRecord(indexPath: self?.recordsList.firstIndex(of: cellTitle) ?? 0) ?? false {
                cell.playButton.setImage(#imageLiteral(resourceName: "icon-pause"), for: .normal)
                self?.initProgress(cell)
            } else {
                cell.playButton.setImage(#imageLiteral(resourceName: "icon-resume"), for: .normal)
                if let timer = self?.progressTimer {
                    timer.invalidate()
                }
            }
            self?.currentRecord = (indexPath: indexPath, cell: cell)
        }
    }
    
    private func initProgress(_ cell: RecordCell) {
        if let player = audioPlayer {
            self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                let normalizedTime = player.currentTime / player.duration
                cell.progressBar.setProgress(Float(normalizedTime), animated: true)
            }
            RunLoop.current.add(self.progressTimer!, forMode: .common)
        }
    }
    
    private func stopPlayerAndOffProgress() {
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
    
    private func playCurrentRecord(for url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            Allert.displayAllert(self, title: "Ошибка!")
        }
    }
}

// Table view delegate
extension RecodrsListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recordsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as? RecordCell
        if let cell = cell {
            initRecordCell(cell, at: indexPath)
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { (_, _) in
            self.deleteRecord(at: indexPath)
            self.stopPlayerAndOffProgress()
            self.audioPlayer = nil
            tableView.reloadData()
        }
        
        return [deleteAction]
    }
    
    func deleteRecord(at indexPath: IndexPath) {
        let fileName = Storage.getDocumentDirectoryUrl().appendingPathComponent(recordsList[indexPath.row])
        recordsList.remove(at: indexPath.row)
        try? FileManager.default.removeItem(at: fileName)
    }
}

extension RecodrsListViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentRecord.cell.playButton.setImage(#imageLiteral(resourceName: "icon-resume"), for: .normal)
        currentRecord.cell.progressBar.setProgress(0, animated: false)
        if let timer = progressTimer {
            timer.invalidate()
        }
    }
}
