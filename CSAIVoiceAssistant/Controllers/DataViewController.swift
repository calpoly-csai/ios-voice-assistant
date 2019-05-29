//
//  DataViewController.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/27/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit
import AVFoundation

class DataViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private let cellReuseID = "cellReuseID"
    var dataCollectionDelegate: DataCollectionViewController?
    fileprivate var selectedIndex = 0
    fileprivate var audioPlayer: AVAudioPlayer!
    
    // MARK: - Views
    
    let selectedTrackLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Select a track"
        label.numberOfLines = 0
        
        return label
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.layer.borderColor = UIColor.lightGray.cgColor
        table.layer.borderWidth = 1
        
        return table;
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.rgb(red: 135, green: 180, blue: 255)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.dropShadow()
        
        return button
    }()
    
    private let numberOfRecordingsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Number of recordings: 0"
        
        return label
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Collected Data"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        
        configureViews()
    }
    
    private func configureViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecordingCell.self, forCellReuseIdentifier: cellReuseID)
        
        view.addSubview(selectedTrackLabel)
        selectedTrackLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 90)
        
        view.addSubview(tableView)
        tableView.anchor(top: selectedTrackLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 400)
        
        view.addSubview(playButton)
        playButton.anchor(top: tableView.bottomAnchor, leading: nil, bottom: nil, trailing: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 60)
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func getPreappendingPath() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentDirectory = URL(fileURLWithPath: path)
        return documentDirectory
    }
    
    @objc private func playTapped() {
        startPlaying()
    }
    
    fileprivate func startPlaying() {
        if let recordings = dataCollectionDelegate?.recordings {
            if recordings.count == 0 {
                return
            }
            
            var audioFilename = recordings[recordings.count - 1]
            if selectedTrackLabel.text?.count ?? 0 > 0 {
                if var file = selectedTrackLabel.text {
                    file = recordings.reversed()[selectedIndex].absoluteString
                    print(file)
                    audioFilename = URL(string: file)!
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
    }
    
}

// MARK: - TableView

extension DataViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCollectionDelegate?.recordings.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! RecordingCell
        if var name = dataCollectionDelegate?.recordings.reversed()[indexPath.row].absoluteString {
            let pathLength = name.count - getPreappendingPath().absoluteString.count
            name = String(name.suffix(pathLength))
            cell.recordingNameLabel.text = name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let string = dataCollectionDelegate?.recordings[indexPath.row].absoluteString {
            if var lastIndex = string.lastIndex(of: "/") {
                lastIndex = string.index(after: lastIndex)
                selectedTrackLabel.text = String(string.suffix(from: lastIndex))
            }
        } else {
            selectedTrackLabel.text = dataCollectionDelegate?.recordings[indexPath.row].absoluteString
        }
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataCollectionDelegate?.recordings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
