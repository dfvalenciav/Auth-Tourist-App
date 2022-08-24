//
//  RegisterViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 19/08/22.
//

import Foundation
import UIKit


class RegisterViewController: UIViewController {

    
    @IBOutlet weak var registerEmailOutlet: UITextField!
    @IBOutlet weak var registerPasswordOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func regiterToMapAction(_ sender: Any) {
        performSegue(withIdentifier: "registerToMap", sender: nil)
    }
    
}
