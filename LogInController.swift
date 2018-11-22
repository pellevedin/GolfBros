//
//  LoginController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-10-11.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase

class LogInController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //override func viewWillDisappear(_ animated: Bool) {
    //    Auth.auth().removeStateDidChangeListener(handle!)
    //}
   
    @IBAction func signIn(_ sender: Any) {
        signIn(email: email.text!, password: password.text!)
    }
    func signIn (email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "showHome", sender: self)
            }
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabCtrl: UITabBarController = segue.destination as! UITabBarController
        let targetVC = tabCtrl.viewControllers![0] as! HomeController
        targetVC.navigationItem.hidesBackButton = true
    }
    // not tested
    @IBAction func resetPasswordAction(_ sender: Any) {
        resetPassword(email: email.text!)
    }
    // not tested
    func resetPassword (email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            // ...
            }
        let alertController = UIAlertController(title: "Confirmation", message: "See your email-inbox for more information", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
