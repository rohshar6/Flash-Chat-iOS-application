import Firebase
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    private lazy var alertAction: UIAlertAction = {
        let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        return alertAction
    }()
    
    private lazy var alert: UIAlertController = {
        let alert = UIAlertController(title: "Error Occurred", message: nil, preferredStyle: .alert)
        alert.addAction(alertAction)
        return alert
    }()
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let email = emailTextfield.text ?? ""
        let password = passwordTextfield.text ?? ""
        handleAuth(with: email, password: password)
    }
    
    private func handleAuth(with email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.alert.message = error.localizedDescription
                strongSelf.present(strongSelf.alert, animated: true, completion: nil)
            } else {
                strongSelf.performSegue(withIdentifier: "LoginToChat", sender: self)
            }
        }
    }
}
