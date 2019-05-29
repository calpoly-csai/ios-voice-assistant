//
//  Recording.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/18/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import Foundation

enum Gender: String {
    case male
    case female
    case unassigned
}

enum NoiseLevel: String {
    case quiet
    case moderate
    case loud
    case unassigned
}

struct Recording {
    
    var speakerGender: Gender? {
        didSet {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMddyyyyHHmmss"
            currentTime = formatter.string(from: date)
        }
    }
    var firstName: String?
    var lastName: String?
    var description: String?
    var noiseLevel: NoiseLevel?
    var location: String?
    var currentTime: String?
    var recordingURL: URL?
    var recordingName: String? {
        get {
            // Removes: spaces and commas with '-'. If ', ', only one - is used
            return "ww_\(speakerGender ?? .unassigned)_\(description ?? "")_\(location ?? "")_\(noiseLevel ?? .unassigned)_\(lastName ?? "")_\(firstName ?? "")_\(currentTime ?? "")_elliott.wav".replacingOccurrences(of: ", ", with: "-").replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: ",", with: "-").lowercased()
        }
    }
    
}
