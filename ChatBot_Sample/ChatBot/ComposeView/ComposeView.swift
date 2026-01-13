
import UIKit

// Protocol for delegate methods
protocol ReusableTextViewDelegate: AnyObject {
    func didChangeHeight(to height: CGFloat)
    func didAttachImages(_ images: [UIImage])
}

class ReusableTextView: UIView, UITextViewDelegate {
    
    // MARK: - Properties
    weak var delegate: ReusableTextViewDelegate?
    
    private var messageTextView: IQTextView!
    private var imageCollectionView: UICollectionView!
    private var pendingImages: [UIImage] = [] {
        didSet {
            delegate?.didAttachImages(pendingImages)
        }
    }
    
    private let maxTextViewHeight: CGFloat = 120
    private let imagePreviewHeight: CGFloat = 60

    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Initialize the IQTextView
        messageTextView = IQTextView()
        messageTextView.delegate = self
        messageTextView.isScrollEnabled = false
        addSubview(messageTextView)
        
        // Constraints for messageTextView
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: topAnchor),
            messageTextView.leftAnchor.constraint(equalTo: leftAnchor),
            messageTextView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        // Setup the image preview collection view
        setupCollectionView()
    }

    // MARK: - CollectionView for Image Previews
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .zero
        
        imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imageCollectionView.isScrollEnabled = true
        imageCollectionView.alwaysBounceHorizontal = true
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        addSubview(imageCollectionView)
        
        // Set collection view constraints
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 8),
            imageCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            imageCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: imagePreviewHeight)
        ])
        
        imageCollectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "ImagePreviewCell")
    }

    // MARK: - Text View Resizing
    func resizeTextView() {
        let textViewSize = messageTextView.sizeThatFits(CGSize(width: messageTextView.frame.width, height: .infinity))
        var inputBarHeight = textViewSize.height + 15 // padding
        
        // Adjust for attached images
        if !pendingImages.isEmpty {
            inputBarHeight += imagePreviewHeight
        }

        // Limit height for text view
        if inputBarHeight > maxTextViewHeight {
            inputBarHeight = maxTextViewHeight + (pendingImages.isEmpty ? 0 : imagePreviewHeight)
        }

        // Inform delegate about the height change
        delegate?.didChangeHeight(to: inputBarHeight)
    }

    // MARK: - UITextViewDelegate Methods
    func textViewDidChange(_ textView: UITextView) {
        resizeTextView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resizeTextView()
    }

    // MARK: - Handling Images (Optional)
    func attachImages(_ images: [UIImage]) {
        pendingImages = images
        imageCollectionView.reloadData() // Make sure collection view updates
    }

    func clearImages() {
        pendingImages.removeAll()
        imageCollectionView.reloadData()
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension ReusableTextView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pendingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePreviewCell", for: indexPath) as! ImagePreviewCell
        let image = pendingImages[indexPath.item]
        cell.configure(with: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70) // Thumbnail size
    }
}
