//
//  TestViewController.swift
//  ChatBot_Sample
//
//  Created by Santhosh K on 13/01/26.
//

import UIKit

class TestViewController: UIViewController, ReusableTextViewDelegate {
    
    @IBOutlet weak var tableviewChatBot: UITableView!
    @IBOutlet weak var sendBgView: UIView!
    @IBOutlet weak var chatBotBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBgHeightConstraint: NSLayoutConstraint!
    
    private var messages: [ChatMessage] = []
    private var reusableTextView: ReusableTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupReusableTextView()
    }
    
    private func setupReusableTextView() {
        // Initialize and add ReusableTextView to sendBgView
        reusableTextView = ReusableTextView()
        reusableTextView.delegate = self
        sendBgView.addSubview(reusableTextView)

        // Set the constraints for the ReusableTextView
        reusableTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reusableTextView.leftAnchor.constraint(equalTo: sendBgView.leftAnchor),
            reusableTextView.rightAnchor.constraint(equalTo: sendBgView.rightAnchor),
            reusableTextView.bottomAnchor.constraint(equalTo: sendBgView.bottomAnchor),
            reusableTextView.topAnchor.constraint(equalTo: sendBgView.topAnchor)
        ])
    }
    
    // MARK: - ReusableTextViewDelegate Methods
    func didChangeHeight(to height: CGFloat) {
        // Adjust the height of the sendBgView based on the text view height
        sendBgHeightConstraint.constant = height
    }
    
    func didAttachImages(_ images: [UIImage]) {
        // Handle image attachments (e.g., update the UI or store them)
        print("Images attached: \(images.count)")
    }

    // MARK: - Send Button Action
    @IBAction func onClickSendButton(_ sender: UIButton) {
        // Handle send button logic here
        // For example, send the message and update the table
    }
}

// MARK: - UITableView Setup
extension TestViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func setupTableView() {
        tableviewChatBot.dataSource = self
        tableviewChatBot.delegate = self
        tableviewChatBot.separatorStyle = .none
        tableviewChatBot.rowHeight = UITableView.automaticDimension
        tableviewChatBot.estimatedRowHeight = 100
        sendBgHeightConstraint.constant = 150
        
        tableviewChatBot.register(UINib(nibName: "UserMessageCell", bundle: nil), forCellReuseIdentifier: "UserMessageCell")
        tableviewChatBot.register(UINib(nibName: "ChatBotMessageCell", bundle: nil), forCellReuseIdentifier: "ChatBotMessageCell")
    }

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

