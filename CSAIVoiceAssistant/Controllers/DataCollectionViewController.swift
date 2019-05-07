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
    
    var avSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecodings = 0
    
    let recordButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.rgb(red: 135, green: 180, blue: 255)
        button.setTitle("Record", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.rgb(red: 135, green: 180, blue: 255)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureRecorderSession()
        self.configureViews()
    }
    
    // MARK: - Configuration
    
    private func configureViews() {
        navigationItem.title = "Nimbus Data Collection"
        view.backgroundColor = .white
        
        view.addSubview(recordButton)
        view.addSubview(playButton)
        
        recordButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 100, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 75)
        playButton.anchor(top: recordButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 32, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 75)
    }
    
    // MARK: - Recording
    
    private func configureRecorderSession() {
        avSession = AVAudioSession.sharedInstance()
        
        do {
            try avSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
            try avSession.setActive(true)
            avSession.requestRecordPermission() { [unowned self] allowed in
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(numberOfRecodings).m4a")
        let settings = [
            AVFormatIDKey : kAudioFormatAppleLossless,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : Constants.BIT_RATE,
            AVSampleRateKey : Constants.SAMPLE_RATE_HZ,
            AVLinearPCMBitDepthKey : Constants.BIT_DEPTH
            ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            recordButton.setTitle("Stop", for: .normal)
        } catch {
            print("Error configuring recorder: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder.stop()
        recordButton.setTitle("Record", for: .normal)
    }
    
    private func startPlaying() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(numberOfRecodings).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
        } catch {
            print("Error configuring player: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: - Selectors
    
    @objc func recordTapped() {
        if recordButton.titleLabel?.text == "Record" {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    @objc func playTapped() {
        startPlaying()
    }
    
    // MARK: - Microphone Error Alerts
    
    private func displayAccessError() {
        let alert = UIAlertController(title: "Microphone Access", message: "You have opted to not grant CSAI microphone access. We strictly use the microphone only when you choose so, and only use the data collected for Nimbus wake-word training.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Grant access", style: .default, handler: requestMicrophoneAccess))
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func requestMicrophoneAccess(alert: UIAlertAction!) {
        // TODO: - Implement requestMicrophoneAccess
    }
    
}

// MARK: - AVAudioRecorderDelegate

extension DataCollectionViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Recorder finished recording")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player finished playing")
    }
    
}
