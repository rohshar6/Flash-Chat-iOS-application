import Foundation
import Firebase
struct Message {
    let sender: String
    let body: String
}

class MessageModels {
    let db = Firestore.firestore()
}
