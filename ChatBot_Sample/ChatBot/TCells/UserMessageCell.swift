//
//  UserMessageCell.swift
//  ChatBot_Sample
//
//  Created by Santhosh K on 12/01/26.
//

import UIKit

class UserMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    

    func configure(with message: ChatMessage) {

        // Reset state (VERY IMPORTANT for reused cells)
        messageLabel.isHidden = true
        messageImageView.isHidden = true
        messageLabel.text = nil
        messageImageView.image = nil

        switch message.type {

        case .text(let text):
            messageLabel.isHidden = false
            messageLabel.text = text

        case .images(let images):
            guard let firstImage = images.first else { return }
            messageImageView.isHidden = false
            messageImageView.image = firstImage

        case .textWithImages(let text, let images):
            messageLabel.isHidden = false
            messageLabel.text = text

            if let firstImage = images.first {
                messageImageView.isHidden = false
                messageImageView.image = firstImage
            }
        }
    }

    
}
