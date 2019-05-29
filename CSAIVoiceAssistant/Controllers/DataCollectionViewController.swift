//
//  DataCollectionViewController.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/6/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

// TODO: - Refactor this entire app lol

import UIKit
import AVFoundation

class DataCollectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    fileprivate let cellReuseID = "cellReuseID"
    fileprivate var avSession: AVAudioSession!
    fileprivate var audioRecorder: AVAudioRecorder!
    fileprivate var audioPlayer: AVAudioPlayer!
    fileprivate let genders: [Gender] = [.male, .female]
    fileprivate let noiseLevels: [NoiseLevel] = [.quiet, .moderate, .loud]
    fileprivate var recordingsLength = 0
    var dataDelegate: DataViewController?
    var audioFilename: URL!
    var recording: Recording?
    var recordings = [URL]() {
        didSet {
            if recordingsLength <= recordings.count {
                dataDelegate?.tableView.reloadData()
            }
            recordingsLength = recordings.count
        }
    }
    
    private let speakerFirstNameInputField: UITextField = {
        let placeholderColor = UIColor.rgba(red: 10, green: 10, blue: 10, alpha: 0.6)
        let field = UITextField()
        field.textAlignment = .left
        field.textColor = .black
        field.attributedPlaceholder = NSAttributedString(string: "Speaker's First Name", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        
        field.layer.cornerRadius = 8
        return field
    }()
    
    private let speakerLastNameInputField: UITextField = {
        let placeholderColor = UIColor.rgba(red: 10, green: 10, blue: 10, alpha: 0.6)
        let field = UITextField()
        field.textAlignment = .left
        field.textColor = .black
        field.attributedPlaceholder = NSAttributedString(string: "Speaker's Last Name", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        
        field.layer.cornerRadius = 8
        return field
    }()
    
    private let speakerDescriptionInputField: UITextField = {
        let placeholderColor = UIColor.rgba(red: 10, green: 10, blue: 10, alpha: 0.6)
        let field = UITextField()
        field.textAlignment = .left
        field.textColor = .black
        field.attributedPlaceholder = NSAttributedString(string: "Description", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        
        field.layer.cornerRadius = 8
        return field
    }()
    
    private let speakerLocationInputField: UITextField = {
        let placeholderColor = UIColor.rgba(red: 10, green: 10, blue: 10, alpha: 0.6)
        let field = UITextField()
        field.textAlignment = .left
        field.textColor = .black
        field.attributedPlaceholder = NSAttributedString(string: "Location (for accent)", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        
        field.layer.cornerRadius = 8
        return field
    }()
    
    private let genderPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = 0
        
        return picker
    }()
    
    private let noiseLevelPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = 1
        
        return picker
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsTouchWhenHighlighted = true
        button.backgroundColor = .red
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecordingsFromStored()
        configureViews()
        configureRecorderSession()
    }
    
    // MARK: - Configuration
    
    // TODO: - Encapsulate all the anchoring
    private func configureViews() {
        configureGeneralView()
        
        view.addSubview(recordButton)
        view.addSubview(speakerFirstNameInputField)
        view.addSubview(speakerLastNameInputField)
        view.addSubview(speakerDescriptionInputField)
        view.addSubview(speakerLocationInputField)
        view.addSubview(genderPicker)
        view.addSubview(noiseLevelPicker)
        
        speakerFirstNameInputField.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 30)
        speakerFirstNameInputField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speakerFirstNameInputField.underlined()
        
        speakerLastNameInputField.anchor(top: speakerFirstNameInputField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 30)
        speakerLastNameInputField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speakerLastNameInputField.underlined()
        
        speakerDescriptionInputField.anchor(top: speakerLastNameInputField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 30)
        speakerDescriptionInputField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speakerDescriptionInputField.underlined()
        
        speakerLocationInputField.anchor(top: speakerDescriptionInputField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 30)
        speakerLocationInputField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speakerLocationInputField.underlined()
        
        genderPicker.anchor(top: speakerLocationInputField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, paddingTop: 0, paddingLeft: 22, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        genderPicker.dataSource = self
        genderPicker.delegate = self
        
        noiseLevelPicker.anchor(top: speakerLocationInputField.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 22, width: 150, height: 150)
        noiseLevelPicker.dataSource = self
        noiseLevelPicker.delegate = self
        
        configureRecordButton()
    }
    
    private func configureGeneralView() {
        navigationItem.title = "Data Collection"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
    }
    
    private func configureRecordButton() {
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 32, paddingRight: 0, width: 60, height: 60)
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
        UIView.animate(withDuration: 2.5, delay: 0.0, options: [.autoreverse], animations: {
            self.recordButton.backgroundColor = UIColor.rgb(red: 126, green: 0, blue: 0)
        }) { (success) in
            self.recordButton.backgroundColor = .red
        }
        if audioRecorder == nil {
            startRecording()
        } else {
            // Uncomment this to allow the user to record for less than 2.5 seconds
            // stopRecording()
        }
    }
    
    @objc func resetRecordings() {
        let alert = UIAlertController(title: "Reset local recordings?", message: "Resetting will overwrite any recordings you have already recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: resetLocalRecordings))
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0: return genders.count
        case 1: return noiseLevels.count
        default: return 0
        }
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0: return genders[row].rawValue.firstCapitalized
        case 1: return noiseLevels[row].rawValue.firstCapitalized
        default: return nil
        }
    }
    
}

// MARK: - AVAudioRecorder

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
    
    func startRecording() {
        recording = Recording()
        self.audioFilename = self.getDocumentsDirectory().appendingPathComponent("\(String(self.recordings.count))")
        
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
    
    fileprivate func fetchRecordingsFromStored() {
        recordings.removeAll()
        if let storedRecordings = UserDefaults.standard.object(forKey: "recordings") as? [String] {
            for recording in storedRecordings {
                let urlRecording = URL(string: recording)
                recordings.append(urlRecording!)
            }
        }
    }
    
    func storeRecordings() {
        var recordingsAsStrings = [String]()
        for recording in recordings {
            recordingsAsStrings.append(recording.absoluteString)
        }
        UserDefaults.standard.set(recordingsAsStrings, forKey: "recordings")
    }
    
    func resetLocalRecordings(alert: UIAlertAction!) {
        UserDefaults.standard.set(nil, forKey: "recordings")
        recordings.removeAll()
        print("Reset local recordings")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioRecorder = nil
        recordings.append(audioFilename)
        
        print("Recorder finished recording")
        
        getAudioRecordingName()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player finished playing")
    }
    
    func getAudioRecordingName() {
        recording?.firstName = speakerFirstNameInputField.text
        recording?.lastName = speakerLastNameInputField.text
        recording?.speakerGender = genders[genderPicker.selectedRow(inComponent: 0)]
        recording?.noiseLevel = noiseLevels[noiseLevelPicker.selectedRow(inComponent: 0)]
        recording?.description = speakerDescriptionInputField.text
        recording?.location = speakerLocationInputField.text
        renameFile()
    }
    
}
