//
//  StartController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-10-14.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase

class StartController: UIViewController {
 
    @IBOutlet weak var emailText1: UITextField!
    @IBOutlet weak var passwordText1: UITextField!
    @IBOutlet weak var emailText2: UITextField!
    @IBOutlet weak var passwordText2: UITextField!
    @IBOutlet weak var verifyPwText: UITextField!

    // Användare vill logga in
    @IBAction func logIAction(_ sender: Any) {
        logIn(email: emailText1.text!, password: passwordText1.text!)
        }
    // Användare vill skapa en ny user
    @IBAction func signUpAction(_ sender: Any) {
        signUp(email: emailText2.text!, password: passwordText2.text!, verifyPassword: verifyPwText.text!)
        }
    // Ännu inte implementerat
    @IBAction func displayPrivacy(_ sender: UIButton) {
        print("lägg in länk till hemsida")
        }
    // Funktion för att visa om password och verify password är samma
    @IBOutlet weak var matchingPWLabel: UILabel!
    @IBAction func matchingPW(_ sender: UITextField) {
        if passwordText2.text == verifyPwText.text {
            self.matchingPWLabel.text = "match!"
            self.matchingPWLabel.textColor = UIColor.black
        }
        else {
            self.matchingPWLabel.text = "no match!"
            self.matchingPWLabel.textColor = UIColor.red
            }
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Kolla om användare redan är påloggad i tidigare session
        self.navigationItem.title = "Sign in or sign-up!"
        if Auth.auth().currentUser != nil {
            // Gå vidare till homecontroller
            let view = self.storyboard?.instantiateViewController(withIdentifier: "HomeController") as! UITabBarController
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = view
            }
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Försök logga in existerande användare
    func logIn (email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "HomeController") as! UITabBarController
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.window!.rootViewController = view
            }
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    // Försök skapa ny användare
    func signUp (email: String, password: String, verifyPassword: String) {
        if password != verifyPassword {
            let alertController = UIAlertController(title: "Passwords are not matching", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: email, password: password){ (user, error) in
                if error == nil {
                    let view = self.storyboard?.instantiateViewController(withIdentifier: "HomeController") as! UITabBarController
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.window!.rootViewController = view
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
