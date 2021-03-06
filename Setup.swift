//
//  SetupController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-08-21.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase

class SetupController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // vad gör denna?
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Setup"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    @IBAction func resetPasswordAction(_ sender: Any) {
        //fixa så vi hämtar denna info från aktuell användare
        let email: String = "blabla"
        self.resetPasswordAction(email)
    }
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

