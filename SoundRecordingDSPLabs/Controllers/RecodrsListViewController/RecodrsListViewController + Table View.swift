//
//  RecodrsListViewController + Table View.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 20.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import UIKit

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
    
    private func deleteRecord(at indexPath: IndexPath) {
        let fileName = Storage.getDocumentDirectoryUrl().appendingPathComponent(recordsList[indexPath.row])
        recordsList.remove(at: indexPath.row)
        try? FileManager.default.removeItem(at: fileName)
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
            self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                let normalizedTime = player.currentTime / player.duration
                if normalizedTime > 0.99 {
                    self.progressTimer?.invalidate()
                }
                cell.progressBar.setProgress(Float(normalizedTime), animated: true)
            }
            RunLoop.current.add(self.progressTimer!, forMode: .common)
        }
    }
}
