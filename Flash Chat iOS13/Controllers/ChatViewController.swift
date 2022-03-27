import Firebase
import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    private lazy var barItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(handleLogout))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = barItem
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
    @objc func handleLogout() {
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
}
