import Firebase
import UIKit

class ChatViewController: UIViewController {
    private struct privateConstants {
        static let fontSize: CGFloat = 25
        static let bottomConstraintValue: CGFloat = 10
        static let bottomConstraintUpdateValue: CGFloat = 20
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    private lazy var barItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(handleLogout))
    private var messages: [Message] = []
    private let messageVM = MessageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarAppearance()
        
        messageVM.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
        keyBoardUtils()
    }
    
    private func setNavigationBarAppearance() {
        barItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = barItem
        navigationItem.hidesBackButton = true
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: Constants.BrandColors.blue)
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: privateConstants.fontSize), .foregroundColor: UIColor.white]
        
        setupNavigationAppearance(appearance)
        
        navigationItem.title = Constants.appName
    }
    
    private func loadMessages() {
        messages = []
        messageVM.loadMessage()
    }
    
    @objc private func handleLogout() {
        handleAuthLogout()
    }
    
    private func handleAuthLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func keyBoardUtils() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        bottomConstraint.constant = privateConstants.bottomConstraintValue
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                bottomConstraint.constant = privateConstants.bottomConstraintUpdateValue
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 10
        self.view.frame.origin.y = 0
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        messageVM.sendMessageToService(from: Auth.auth().currentUser?.email ?? "", text: messageTextfield.text ?? "")
        
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? MessageCell else { return UITableViewCell() }
        
        let messageSender = Auth.auth().currentUser?.email
        let sender = messages[indexPath.row].sender
        let isCurrentUser = messageSender == sender
        
        cell.youMessageAvatar.isHidden = isCurrentUser // if i m not sender show this.
        cell.avatarImageView.isHidden = !isCurrentUser // if i m sender show this.
        
        cell.messageBubble.backgroundColor = isCurrentUser ? UIColor(named: Constants.BrandColors.lightPurple) : UIColor(named: Constants.BrandColors.purple)
        
        cell.label.textColor = isCurrentUser ? UIColor(named: Constants.BrandColors.purple) : UIColor(named: Constants.BrandColors.lightPurple)
        
        cell.label.text = messages[indexPath.row].body
        
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {}

// MARK: -
extension ChatViewController: MessageViewModelDelegate {
    func messageViewModel(_ messageViewModel: MessageViewModel, didErrorOccurred error: Error) {
        print("Error occurred!")
    }
    
    func messageViewModel(_ messageViewModel: MessageViewModel, didSend success: Bool) {
        DispatchQueue.main.async {
            self.messageTextfield.text = ""
        }
    }
    
    func messageViewModel(_ messageViewModel: MessageViewModel, didReceive messages: [Message]) {
        self.messages = messages
        guard messages.count >= 1 else { return }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .top, animated: true)
        }
    }
}
