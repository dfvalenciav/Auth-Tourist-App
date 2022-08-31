//
//  RegisterViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 19/08/22.
//

import Foundation
import UIKit
import FirebaseAuth



class RegisterViewController: UIViewController {

    
    @IBOutlet weak var registerEmailOutlet: UITextField!
    @IBOutlet weak var registerPasswordOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func regiterToMapAction(_ sender: Any) {
        if let email = registerEmailOutlet.text , let password = registerPasswordOutlet.text {
            Auth.auth().createUser(withEmail: email, password: password){
            (result, error) in
            if let result = result, error == nil {
                self.performSegue(withIdentifier: "registerToMap", sender: nil)
            }else {
                let alertController = UIAlertController(title: "Error", message: "Se ha producido un error registrando el usuario", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
