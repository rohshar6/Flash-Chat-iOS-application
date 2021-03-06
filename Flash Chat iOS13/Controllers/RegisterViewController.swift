import Firebase
import UIKit

class RegisterViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup navigation-bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: Constants.BrandColors.blue)
        setupNavigationAppearance(appearance)
        
        navigationItem.backBarButtonItem?.tintColor = .white
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        let email = emailTextfield.text ?? ""
        let password = passwordTextfield.text ?? ""
        handleAuthentication(with: email, password: password)
    }
    
    private func handleAuthentication(with email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                print("error occured: \(error.localizedDescription)")
                self.alert.message = error.localizedDescription
                self.present(self.alert, animated: true, completion: nil)
            } else {
                // Navigation to chat VC
                self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
            }
        }
    } 
}
