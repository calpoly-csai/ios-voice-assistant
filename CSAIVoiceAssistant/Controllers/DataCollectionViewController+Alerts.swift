//
//  DataCollectionViewController+Alerts.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/18/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit

extension DataCollectionViewController {
    
    func getAudioRecordingName() {
        getRecordingGender()
    }
    
    func presentAlertTF(withTitle title: String, message: String, action: @escaping (_ textField: UITextField) -> Void, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in
            self.recordings.removeLast()
        }))
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0] {
                action(textField)
            }
            completion()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func getRecordingGender() {
        presentAlertTF(withTitle: "Gender", message: "Enter the speaker's gender (male/female)", action: { (textField) in
            let text = textField.text?.lowercased() ?? ""
            if text.contains("f") {
                self.recording?.speakerGender = .female
            } else {
                self.recording?.speakerGender = .male
            }
        }) {
            self.getRecordingFirstName()
        }
    }
    
    func getRecordingFirstName() {
        presentAlertTF(withTitle: "First Name", message: "Enter the speaker's first name", action: { (textField) in
            self.recording?.firstName = textField.text ?? ""
        }) {
            self.getRecordingLastName()
        }
    }
    
    func getRecordingLastName() {
        presentAlertTF(withTitle: "Last Name", message: "Enter the speaker's last name", action: { (textField) in
            self.recording?.lastName = textField.text ?? ""
        }) {
            self.getRecordingDescription()
        }
    }
    
    func getRecordingDescription() {
        presentAlertTF(withTitle: "Description", message: "Enter the recording's setting", action: { (textField) in
            self.recording?.description = textField.text ?? ""
        }) {
            self.getRecordingNoiseLevel()
        }
    }
    
    func getRecordingNoiseLevel() {
        presentAlertTF(withTitle: "Noise Level", message: "Enter the noise level (quiet (q), moderate (m), loud (l))", action: { (textField) in
            let text = textField.text?.lowercased() ?? ""
            if text.contains("q") {
                self.recording?.noiseLevel = .quiet
            } else if text.contains("m") {
                self.recording?.noiseLevel = .moderate
            } else if text.contains("l") {
                self.recording?.noiseLevel = .loud
            }
        }) {
            self.getRecordingLocation()
        }
    }
    
    func getRecordingLocation() {
        presentAlertTF(withTitle: "Location", message: "Enter the location (to determine accent)", action: { (textField) in
            self.recording?.location = textField.text ?? ""
        }) {
            self.renameFile()
        }
    }
    
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
