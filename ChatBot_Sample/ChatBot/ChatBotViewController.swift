//
//  ChatBotViewController.swift
//  ChatBot_Sample
//
//  Created by Santhosh K on 12/01/26.
//
import UIKit

class ChatBotViewController: UIViewController {

    @IBOutlet weak var tableviewChatBot: UITableView!
    @IBOutlet weak var sendBgView: UIView!
    @IBOutlet weak var messageTextView: IQTextView!
    @IBOutlet weak var chatBotBottomConstraint: NSLayoutConstraint! // Connect to bottom of complete bgview
    @IBOutlet weak var sendBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionVW: UIView!
    private var imagePickerManager: ImagePickerManager!
    private var pendingImages: [UIImage] = []
    private var messages: [ChatMessage] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupKeyboard()
        setupTapToDismiss()
        setupTextView()
        setupCollectionView()
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableviewChatBot.dataSource = self
        tableviewChatBot.delegate = self
        tableviewChatBot.separatorStyle = .none
        tableviewChatBot.rowHeight = UITableView.automaticDimension
        tableviewChatBot.estimatedRowHeight = 100
        sendBgHeightConstraint.constant = 50
        
        
        tableviewChatBot.register(UINib(nibName: "UserMessageCell", bundle: nil), forCellReuseIdentifier: "UserMessageCell")
        tableviewChatBot.register(UINib(nibName: "ChatBotMessageCell", bundle: nil), forCellReuseIdentifier: "ChatBotMessageCell")
    }

    // MARK: - Keyboard Handling
    private func setupKeyboard() {
        KeyboardManager.shared.onKeyboardHeightChanged = { [weak self] height, _ in
            guard let self = self else { return }
            self.chatBotBottomConstraint.constant = height
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.scrollToBottom(animated: false)
            }
        }
    }

    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableviewChatBot.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    


    // MARK: - Sending Messages
    @IBAction func onClickSendButton(_ sender: UIButton) {
        guard !messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {return }
        let text = messageTextView.text!

        if !pendingImages.isEmpty {
               // Send text + images
               sendUserTextWithImages(text, images: pendingImages)
               pendingImages.removeAll() // clear after sending
        } else {
            addUserMessage(text)
        }

        imageCollectionVW.isHidden = true
        messageTextView.text = ""
        sendBgHeightConstraint.constant = 60 // default height
    }

    @IBAction func onClickAttach(_ sender: UIButton) {
        // TODO: pick image
        cameraTapped()
    }

    // MARK: - Message Handling
    private func addUserMessage(_ text: String) {
        let message = ChatMessage(id: UUID(), sender: .user, type: .text(text), timestamp: Date())
        insertMessage(message)
    }

    private func addBotMessage(_ text: String) {
        let message = ChatMessage(id: UUID(), sender: .bot, type: .text(text), timestamp: Date())
        insertMessage(message)
    }

    private func sendUserTextWithImages(_ text: String, images: [UIImage]) {
            let message = ChatMessage(id: UUID(), sender: .user, type: .textWithImages(text: text, images: images), timestamp: Date())
            insertMessage(message)
        }

    private func insertMessage(_ message: ChatMessage) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableviewChatBot.beginUpdates()
        tableviewChatBot.insertRows(at: [indexPath], with: .automatic)
        tableviewChatBot.endUpdates()

        DispatchQueue.main.async {
            self.scrollToBottom(animated: true)
        }
    }

    private func scrollToBottom(animated: Bool) {
        guard tableviewChatBot.numberOfRows(inSection: 0) > 0 else { return }
        let lastRow = tableviewChatBot.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        tableviewChatBot.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
}

// MARK: - UITableView
extension ChatBotViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        switch message.sender {
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as! UserMessageCell
            cell.configure(with: message)
            return cell
        case .bot:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBotMessageCell", for: indexPath) as! ChatBotMessageCell
            cell.configure(with: message)
            return cell
        }
    }
}


extension ChatBotViewController : UITextViewDelegate {
    
    // MARK: - TextView
    private func setupTextView() {
        messageTextView.delegate = self
        messageTextView.isScrollEnabled = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let maxTextViewHeight: CGFloat = 120 // max height for typing
        let textViewSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        var inputBarHeight = textViewSize.height + 15 // 16 = padding
        
        imageCollectionVW.isHidden = true
        // Add extra height for attached images
        if !pendingImages.isEmpty {
            inputBarHeight += 60 // height for image preview collection
            imageCollectionVW.isHidden = false
        }
        
        // Limit height but allow scrolling in UITextView after max height
        if inputBarHeight > maxTextViewHeight + (pendingImages.isEmpty ? 0 : 60) {
            inputBarHeight = maxTextViewHeight + (pendingImages.isEmpty ? 0 : 60)
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        
        sendBgHeightConstraint.constant = inputBarHeight
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }
    
    
}

extension ChatBotViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    private func setupCollectionView() {
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        imagesCollectionView.register(
            UINib(nibName: "ImagePreviewCell", bundle: nil),
            forCellWithReuseIdentifier: "ImagePreviewCell"
        )
        
        // Horizontal scrolling
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8   // space between cells
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imagesCollectionView.collectionViewLayout = layout

            imagesCollectionView.showsHorizontalScrollIndicator = false
        
        imagesCollectionView.isScrollEnabled = true
        imagesCollectionView.alwaysBounceHorizontal = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pendingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePreviewCell", for: indexPath) as! ImagePreviewCell
        let image = pendingImages[indexPath.item]
        cell.configure(with: image)
        
        // Remove image callback
        cell.onRemove = { [weak self] in
            self?.pendingImages.remove(at: indexPath.item)
            self?.imagesCollectionView.reloadData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70) // Thumbnail size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - Camera Picker
extension ChatBotViewController: ImagePickerManagerDelegate {
    
    @objc func cameraTapped() {
        imagePickerManager = ImagePickerManager( presentationController: self, delegate: self, selectionLimit: 100)
        //imagePickerManager = ImagePickerManager(presentationController: self, delegate: self)
        imagePickerManager.presentImagePickerOptions()
    }
    
    func imagePickerManager(_ manager: ImagePickerManager, didSelect images: [UIImage]) {
        DispatchQueue.main.async {
            if images.count > 0 {
                var imageArr = [UIImage]()
                for img in images {
                    imageArr.append((ImageConstant.setimagePropotional(img)))
                }
                self.pendingImages = imageArr
            }
            
            self.imagesCollectionView.reloadData()
            self.textViewDidChange(self.messageTextView)
        }
    }
    
    func imagePickerManagerDidCancel(_ manager: ImagePickerManager) {
        print("Image selection canceled")
    }
}
