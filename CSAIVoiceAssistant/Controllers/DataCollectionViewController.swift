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
    
    let cellReuseID = "cellReuseID"
    var avSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename: URL!
    var recordings = [URL]() {
        didSet {
            numberOfRecordingsLabel.text = "Number of recordings: \(recordings.count)"
        }
    }
    
    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.rgb(red: 135, green: 180, blue: 255)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Reset local recordings", for: .normal)
        
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.addTarget(self, action: #selector(resetRecordings), for: .touchUpInside)
        
        return button
    }()
    
    let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsTouchWhenHighlighted = true
        button.backgroundColor = .red
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
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
    
    let tableView: UITableView = {
        let table = UITableView()
        table.layer.borderColor = UIColor.black.cgColor
        table.layer.borderWidth = 1
        
        return table;
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecordingsFromStored()
        configureViews()
        configureRecorderSession()
    }
    
    // MARK: - Configuration
    
    private func configureViews() {
        configureGeneralView()
        
        view.addSubview(resetButton)
        view.addSubview(recordButton)
        view.addSubview(numberOfRecordingsLabel)
        view.addSubview(userInputRecordingTextField)
        view.addSubview(playButton)
        
        playButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 16, width: 0, height: 75)
        
        numberOfRecordingsLabel.anchor(top: playButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 30)
        
        userInputRecordingTextField.anchor(top: numberOfRecordingsLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 30)
        
        resetButton.anchor(top: userInputRecordingTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 40)
        
        configureRecordButton()
        
        configureTableView()
    }
    
    private func configureGeneralView() {
        navigationItem.title = "Nimbus Data Collection"
        view.backgroundColor = .white
    }
    
    private func configureRecordButton() {
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 60, height: 60)
        recordButton.layer.cornerRadius = 30
        
        // Poor way to do this, but avoid rendering the layer until after the button has been fully rendered
        if (recordButton.frame.origin.x > 0) {
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: recordButton.frame.origin.x + 30, y: recordButton.frame.origin.y + 30), radius: CGFloat(35), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 3.0

            view.layer.addSublayer(shapeLayer)
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecordingCell.self, forCellReuseIdentifier: cellReuseID)
        
        view.addSubview(tableView)
        
        tableView.anchor(top: resetButton.bottomAnchor, leading: view.leadingAnchor, bottom: recordButton.topAnchor, trailing: view.trailingAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 16, paddingRight: 8, width: 0, height: 0)
    }
    
    private func updateRecordButtonTitle() {
        let title = getRecordButtonText()
        recordButton.setTitle(title, for: .normal)
    }
    
    private func getRecordButtonText() -> String {
        if audioRecorder == nil {
            recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return "Record for \(Constants.RECORD_DURATION) seconds"
        }
        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        return "Recording"
    }
    
    // MARK: - Selectors
    
    @objc func recordTapped() {
//        recordButton.backgroundColor = .blue
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
    
    @objc func resetRecordings() {
        let alert = UIAlertController(title: "Reset local recordings?", message: "Resetting will overwrite any recordings you have already recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: resetLocalRecordings))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Microphone Error Alerts
    
    private func displayAccessError() {
        let alert = UIAlertController(title: "Microphone Access", message: "You have opted to not grant CSAI microphone access. We strictly use the microphone only when you choose so, and only use the data collected for Nimbus wake-word training.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Grant access", style: .default, handler: requestMicrophoneAccess))
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - General Functions
    
    private func requestMicrophoneAccess(alert: UIAlertAction!) {
        // TODO: - Implement requestMicrophoneAccess
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

// MARK: - AVAudioRecorderDelegate

extension DataCollectionViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    fileprivate func configureRecorderSession() {
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
            displayAccessError()
        }
    }
    
    fileprivate func startRecording() {
        audioFilename = getDocumentsDirectory().appendingPathComponent("\(recordings.count).wav")
        let settings: [String : Any] = [
            AVFormatIDKey : Int(kAudioFormatLinearPCM),
            AVSampleRateKey : Constants.SAMPLE_RATE_HZ,
            AVLinearPCMBitDepthKey : Constants.BIT_DEPTH,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : Constants.BIT_RATE
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            
            playButton.setTitle("Recording", for: .normal)
            audioRecorder.record(forDuration: 2.5)
            
        } catch {
            print("Error configuring recorder: \(error)")
        }
    }
    
    // Only used if user is able to stop recording early
    fileprivate func stopRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    fileprivate func startPlaying() {
        if recordings.count == 0 {
            return
        }
        
        audioFilename = recordings[recordings.count - 1]
        if userInputRecordingTextField.text?.count ?? 0 > 0 {
            if let file = userInputRecordingTextField.text {
                audioFilename = URL(string: file)
            }
        }
        
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
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.setTitle("Play", for: .normal)
        audioRecorder = nil
        recordings.append(audioFilename)
        tableView.reloadData()
        
        storeRecordings()
        print("Recorder finished recording")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player finished playing")
    }
    
    func fetchRecordingsFromStored() {
        recordings.removeAll()
        if let storedRecordings = UserDefaults.standard.object(forKey: "recordings") as? [String] {
            for recording in storedRecordings {
                let urlRecording = URL(string: recording)
                recordings.append(urlRecording!)
            }
        }
        tableView.reloadData()
    }
    
    private func storeRecordings() {
        var recordingsAsStrings = [String]()
        for recording in recordings {
            recordingsAsStrings.append(recording.absoluteString)
        }
        UserDefaults.standard.set(recordingsAsStrings, forKey: "recordings")
    }
    
    func resetLocalRecordings(alert: UIAlertAction!) {
        UserDefaults.standard.set(nil, forKey: "recordings")
        recordings.removeAll()
        tableView.reloadData()
        print("Reset local recordings")
    }
    
}

extension DataCollectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! RecordingCell
        cell.recordingNameLabel.text = recordings[indexPath.row].absoluteString
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userInputRecordingTextField.text = recordings[indexPath.row].absoluteString
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
