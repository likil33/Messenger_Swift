
    import Foundation
    import UIKit


    enum ChatSender {
        case user
        case bot
    }

    enum ChatMessageType {
        case text(String)
        case images([UIImage])
        case textWithImages(text: String, images: [UIImage])
    }


    struct ChatMessage {
        let id: UUID
        let sender: ChatSender
        let type: ChatMessageType
        let timestamp: Date
    }





