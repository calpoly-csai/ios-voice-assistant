//
//  DataCollectionViewController.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/6/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit
import AVFoundation

class DataCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    let recordButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Tap to Record", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureRecording()
    }
    
    // MARK: - Configuration
    
    private func configureViews() {
        view.backgroundColor = .white
        
        view.addSubview(recordButton)
        print(view.centerXAnchor)
        recordButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 350, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 100)
        view.addSubview(recordButton)
    }
    
    // MARK: - Recording
    
    private func configureRecording() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setPreferredSampleRate(Constants.SAMPLE_RATE_HZ)
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.configureViews()
                    } else {
                        self.displayAccessError()
                    }
                }
            }
        } catch {
            self.displayAccessError()
        }
    }
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVSampleRateKey: Constants.SAMPLE_RATE_HZ,
            AVLinearPCMBitDepthKey: Constants.BIT_DEPTH,
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        let title = success ? "Tap to Re-record" : "Tap to Record"
        recordButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Selectors
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    // MARK: - Microphone Error Alerts
    
    private func displayAccessError() {
        recordingSession = AVAudioSession.sharedInstance()
        let alert = UIAlertController(title: "Microphone Access", message: "You have opted to not grant CSAI microphone access. We strictly use the microphone only when you choose so, and only use the data collected for Nimbus wake-word training.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Grant access", style: .default, handler: requestMicrophoneAccess))
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func requestMicrophoneAccess(alert: UIAlertAction!) {
        
    }
    
}

// MARK: - AVAudioRecorderDelegate

extension DataCollectionViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
}
