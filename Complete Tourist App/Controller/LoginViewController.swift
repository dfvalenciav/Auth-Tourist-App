//
//  ViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 7/08/22.
//

import UIKit

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
        performSegue(withIdentifier: "loginToMap", sender: nil)
    }
    
    
}

