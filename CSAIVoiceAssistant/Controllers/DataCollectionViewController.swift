//
//  DataCollectionViewController.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/6/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit
import AVFoundation

class DataCollectionViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    var avSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecordings = 0 {
        didSet {
            numberOfRecordingsLabel.text = "Number of recordings: \(numberOfRecordings)"
        }
    }
    
    let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.rgb(red: 135, green: 180, blue: 255)
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
    
    let numberOfRecordingsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Number of recordings: 0"
        
        return label
    }()
    
    let userInputRecordingTextField: UITextField = {
        let placeholderColor = UIColor.rgba(red: 255, green: 255, blue: 255, alpha: 0.6)
        let field = UITextField()
        field.backgroundColor = UIColor.rgb(red: 135, green: 180, blue: 255)
        field.textAlignment = .center
        field.textColor = .white
        field.attributedPlaceholder = NSAttributedString(string: "Enter recording number to play", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        
        field.layer.cornerRadius = 8
        
        return field
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        self.configureTapGestureRecognizers()
        self.configureRecorderSession()
    }
    
    // MARK: - Configuration
    
    private func configureViews() {
        let title = self.getRecordButtonText()
        if let recordingsCount = UserDefaults.standard.object(forKey: "numberOfRecordings") as? Int {
            numberOfRecordings = recordingsCount
        }
        
        self.configureGeneralView()
        
        view.addSubview(recordButton)
        view.addSubview(numberOfRecordingsLabel)
        view.addSubview(userInputRecordingTextField)
        view.addSubview(playButton)
        
        recordButton.setTitle(title, for: .normal)
        recordButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 100, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 75)
        
        numberOfRecordingsLabel.anchor(top: recordButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 30)
        
        userInputRecordingTextField.anchor(top: numberOfRecordingsLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 30)
        
        playButton.anchor(top: userInputRecordingTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 75)
    }
    
    private func configureGeneralView() {
        navigationItem.title = "Nimbus Data Collection"
        view.backgroundColor = .white
    }
    
    private func configureTapGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func dismissKeyboard() {
        self.view.endEditing(true)
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(numberOfRecordings).m4a")
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
            audioRecorder.record(forDuration: 2.5)
            recordButton.setTitle("Recording", for: .normal)
        } catch {
            print("Error configuring recorder: \(error)")
        }
    }
    
    // Only used if user is able to stop recording early
    private func stopRecording() {
        audioRecorder.stop()
    }
    
    private func startPlaying() {
        let index: String = userInputRecordingTextField.text?.count == 0 ? String(self.numberOfRecordings - 1) : userInputRecordingTextField.text ?? String(self.numberOfRecordings - 1)
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(index).m4a")
        
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
    
    // MARK: - Selectors
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            // Uncomment this to allow the user to record for less than 2.5 seconds
            // stopRecording()
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
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let title = self.getRecordButtonText()
        recordButton.setTitle(title, for: .normal)
        numberOfRecordings += 1
        audioRecorder = nil
        print("Recorder finished recording")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player finished playing")
    }
    
    // MARK: - General Functions
    
    private func requestMicrophoneAccess(alert: UIAlertAction!) {
        // TODO: - Implement requestMicrophoneAccess
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getRecordButtonText() -> String {
        let text = "Record for \(Constants.RECORD_DURATION) seconds"
        return text
    }
    
}
