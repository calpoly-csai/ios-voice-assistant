//
//  RecordingCell.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/7/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit

class RecordingCell: UITableViewCell {
    
    let recordingNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hey ho, let's go"
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(recordingNameLabel)
        recordingNameLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
