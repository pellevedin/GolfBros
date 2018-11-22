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
    
    @IBAction func logInAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signIn", sender: nil)
    }
    @IBAction func signUpAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signUp", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "showHome", sender: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHome" {
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            let targetVC = tabCtrl.viewControllers![0] as! HomeController
            //targetVC.navigationItem.hidesBackButton = true
        }
    }
}
