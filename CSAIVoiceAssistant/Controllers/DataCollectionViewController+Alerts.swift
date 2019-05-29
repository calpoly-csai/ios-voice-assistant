//
//  DataCollectionViewController+Alerts.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/18/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit

extension DataCollectionViewController {

    func getPreappendingPath() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentDirectory = URL(fileURLWithPath: path)
        return documentDirectory
    }

    func renameFile() {
        do {
            let documentDirectory = getPreappendingPath()
            let originPath = audioFilename!
            let destinationPath = documentDirectory.appendingPathComponent(recording!.recordingName!)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
            audioFilename = URL(string: recording!.recordingName!)
            recordings.removeLast()
            recordings.append(destinationPath)
            storeRecordings()
        } catch {
            print("Error renaming file:", error)
        }
    }
    
}
