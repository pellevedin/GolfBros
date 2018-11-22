//
//  SignUpController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-10-14.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verifyPassword: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // vad gör denna?
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabCtrl: UITabBarController = segue.destination as! UITabBarController
        let targetVC = tabCtrl.viewControllers![0] as! HomeController
        targetVC.navigationItem.hidesBackButton = true
    }

    @IBAction func createAccount(_ sender: Any) {
        createAccount(email: email.text!, password: password.text!, verifyPassword: verifyPassword.text!)
    }
    func createAccount(email: String, password: String, verifyPassword: String) {
        if password != verifyPassword {
            let alertController = UIAlertController(title: "Passwords are not matching", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: email, password: password){ (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "showHome", sender: self)
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: false, completion: nil)
                }
            }
        }
    }
}
