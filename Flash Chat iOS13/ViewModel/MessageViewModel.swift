import UIKit

protocol MessageViewModelDelegate: AnyObject {
    func messageViewModel(_ messageViewModel: MessageViewModel, didErrorOccurred error: Error)
    func messageViewModel(_ messageViewModel: MessageViewModel, didSend success: Bool)
    func messageViewModel(_ messageViewModel: MessageViewModel, didReceive messages: [Message])
}

class MessageViewModel {
    let messageModel = MessageModels()
    weak var delegate: MessageViewModelDelegate?
    
    func sendMessageToService(from sender: String, text: String) {
        messageModel.db.collection(Constants.FStore.collectionName).addDocument(data: [
            Constants.FStore.senderField: sender,
            Constants.FStore.bodyField: text,
            Constants.FStore.dateField: Date().timeIntervalSince1970
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                self.delegate?.messageViewModel(self, didErrorOccurred: err)
            } else {
                print("Document added!")
                self.delegate?.messageViewModel(self, didSend: true)
            }
        }
    }
    
    func loadMessage() {
        messageModel.db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dateField)
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    self.delegate?.messageViewModel(self, didErrorOccurred: err)
                } else {
                    var messages = [Message]()
                    for document in querySnapshot!.documents {
                        let messageBody = document.data()[Constants.FStore.bodyField] as! String
                        let messageSender = document.data()[Constants.FStore.senderField] as! String
                        let message = Message(sender: messageSender, body: messageBody)
                        
                        messages.append(message)
                    }
                    self.delegate?.messageViewModel(self, didReceive: messages)
                }
            }
    }
}
