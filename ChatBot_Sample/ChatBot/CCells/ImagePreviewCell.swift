//
//  ImagePreviewCell.swift
//  ChatBot_Sample
//
//  Created by Santhosh K on 13/01/26.
//

import UIKit

class ImagePreviewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var onRemove: (() -> Void)?

    func configure(with image: UIImage) {
        imageView.image = image
    }

    @IBAction func removeTapped(_ sender: UIButton) {
        onRemove?()
    }
}
