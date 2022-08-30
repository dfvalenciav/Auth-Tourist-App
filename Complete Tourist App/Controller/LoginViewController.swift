//
//  ViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 7/08/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    

    @IBOutlet weak var loginEmailOutlet: UITextField!
    @IBOutlet weak var loginPasswordOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginToRegisterAction(_ sender: Any) {
        performSegue(withIdentifier: "loginToRegister", sender: nil)
    }
    
    
    @IBAction func loginToMapAction(_ sender: Any) {
        if let email = loginEmailOutlet.text , let password = loginPasswordOutlet.text {
            Auth.auth().signIn(withEmail: email, password: password){
            (result, error) in
            if let result = result, error == nil {
                self.performSegue(withIdentifier: "loginToMap", sender: nil)
            }else {
                let alertController = UIAlertController(title: "Error", message: "Se ha producido un error registrando el usuario", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
}
        


