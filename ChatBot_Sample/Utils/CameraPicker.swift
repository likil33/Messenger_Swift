

import Foundation
import UIKit
import PhotosUI

// MARK: - Delegate Protocol
protocol ImagePickerManagerDelegate: AnyObject {
    func imagePickerManager(_ manager: ImagePickerManager, didSelect images: [UIImage])
    func imagePickerManagerDidCancel(_ manager: ImagePickerManager)
}

final class ImagePickerManager: NSObject {
    
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerManagerDelegate?
    private let selectionLimit: Int
    
    init(presentationController: UIViewController, delegate: ImagePickerManagerDelegate, selectionLimit: Int = 1) {
        self.presentationController = presentationController
        self.delegate = delegate
        self.selectionLimit = selectionLimit
        super.init()
    }
    
    // MARK: - Present Options
    func presentImagePickerOptions() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentCamera()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) {[weak self] _ in
            self?.presentPhotoLibrary()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {[weak self] _ in
            guard let self = self else { return }
            self.delegate?.imagePickerManagerDidCancel(self)
        })
        
        // iPad Compatibility
        if let popover = alert.popoverPresentationController, let view = presentationController?.view {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        presentationController?.present(alert, animated: true)
    }
    
    // MARK: - Private Handlers
    private func presentCamera() {
        // imagePickerController.sourceType = .camera
        // presentationController?.present(imagePickerController, animated: true)
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        presentationController?.present(picker, animated: true)
    }
    
    private func presentPhotoLibrary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = selectionLimit
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presentationController?.present(picker, animated: true)
    }
}


// MARK: - UIImagePickerControllerDelegate
extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        delegate?.imagePickerManagerDidCancel(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,  didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        let key: UIImagePickerController.InfoKey = picker.allowsEditing ? .editedImage : .originalImage
        
        if let image = info[key] as? UIImage {
            delegate?.imagePickerManager(self, didSelect: [image])
        } else {
            delegate?.imagePickerManagerDidCancel(self)
        }
    }
}


// MARK: - PHPickerViewControllerDelegate
extension ImagePickerManager: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            delegate?.imagePickerManagerDidCancel(self)
            return
        }
        /*
         itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
         DispatchQueue.main.async {
         guard let self = self, let image = object as? UIImage else {
         //self?.delegate?.imagePickerManagerDidCancel(self!)
         guard let self = self else { return }
         self.delegate?.imagePickerManagerDidCancel(self)
         return
         }
         self.delegate?.imagePickerManager(self, didSelect: image)
         }
         }
         */
        
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.delegate?.imagePickerManager(self, didSelect: images)
        }
        
    }
}




class ImageConstant {
    static func setimagePropotional(_ originalImage:UIImage) -> UIImage {
                    
        if originalImage.pngData()?.count ?? 0 < 13000000 {
            return originalImage
        }
        else {
            let targetSize = CGSize(width: 1600, height: 1600)  // Set your desired size here
            let scaledImage = ImageConstant.scaleImageProportionally(image: originalImage, targetSize: targetSize)
            let imageView = UIImageView(image: scaledImage)
            return scaledImage
        }
    }
    
    static func scaleImageProportionally(image: UIImage, targetSize: CGSize) -> UIImage {
        let originalSize = image.size
        
        // Calculate the aspect ratios of the original and target sizes
        let aspectRatioWidth = targetSize.width / originalSize.width
        let aspectRatioHeight = targetSize.height / originalSize.height
        
        // Use the smaller aspect ratio to ensure the image fits within the target size
        let scaleFactor = min(aspectRatioWidth, aspectRatioHeight)
        
        // Calculate the scaled size
        let scaledSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
        
        // Create a graphics context and draw the scaled image
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage ?? image // Return the scaled image or the original if scaling fails
    }
}




/*

// use it
 
class ProfileViewController: UIViewController {
    
    private var imagePickerManager: ImagePickerManager!
    @IBOutlet weak var imageView: UIImageView!
    
}

extension ProfileViewController: ImagePickerManagerDelegate {
    func setupCameraPicker() {
 imagePickerManager = ImagePickerManager(presentationController: self, delegate: self)
 imagePickerManager.presentImagePickerOptions()
 }
    func imagePickerManager(_ manager: ImagePickerManager, didSelect image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        // Optional: resize, compress, or store image
    }
    
    func imagePickerManagerDidCancel(_ manager: ImagePickerManager) {
        print("Image selection canceled")
    }
}

*/
 
 
