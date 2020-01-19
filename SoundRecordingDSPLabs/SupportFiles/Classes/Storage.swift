//
//  Storage.swift
//  SoundRecordingDSPLabs
//
//  Created by Михаил Дементьев on 18.01.2020.
//  Copyright © 2020 Михаил Дементьев. All rights reserved.
//

import Foundation

class Storage {
    
    static func getDocumentDirectoryUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    static func getListOfRecors() -> [String] {
        let dirPath = Storage.getDocumentDirectoryUrl().path
        let directoryContents: NSArray = try! FileManager.default.contentsOfDirectory(atPath: dirPath) as NSArray
        return directoryContents.count > 0 ? directoryContents.compactMap({$0 as? String}).sorted() : []
    }
}
