//
//  PlayController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-08-21.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase

class PlayController: UIViewController {
    
    // outlets till alla knappar och fält
    @IBOutlet weak var holeNumberLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var onParLabel: UILabel!
    @IBOutlet weak var par3Button: UIButton!
    @IBOutlet weak var par4Button: UIButton!
    @IBOutlet weak var par5Button: UIButton!
    @IBOutlet weak var fwHitLabel: UILabel!
    @IBOutlet weak var fwHitYes: UIButton!
    @IBOutlet weak var fwHitNo: UIButton!
    @IBOutlet weak var girYes: UIButton!
    @IBOutlet weak var girNo: UIButton!
    @IBOutlet weak var putts0: UIButton!
    @IBOutlet weak var putts1: UIButton!
    @IBOutlet weak var putts2: UIButton!
    @IBOutlet weak var putts3: UIButton!
    @IBOutlet weak var putts4: UIButton!
    @IBOutlet weak var putts5: UIButton!
    @IBOutlet weak var strokes1: UIButton!
    @IBOutlet weak var strokes2: UIButton!
    @IBOutlet weak var strokes3: UIButton!
    @IBOutlet weak var strokes4: UIButton!
    @IBOutlet weak var strokes5: UIButton!
    @IBOutlet weak var strokes6: UIButton!
    @IBOutlet weak var strokes7: UIButton!
    @IBOutlet weak var strokes8: UIButton!
    @IBOutlet weak var strokesMore: UIButton!
    
    // Deklarationer
    let refRounds = Database.database().reference(withPath: "users") // koppling till db
    var uid: String = ""  // kommer från seuguen
    var timeStamp: String = "" // kommer från seugen
    var golfCourse: String = "" // kommer från seugen
    var strokesGained: String = "" // kommer från seagen
    var date: String = "" // kommer från seagen
    var scoreDict = [[String: String]]() // kommer från seguen
    var holeNumber: NSInteger = 1 // håller aktuellt hålnummer, startar alltid på 1
    
    // alla knapphändelser
    @IBAction func parButtonClicked(_ sender: UIButton) {
        let parButton = sender as UIButton
        let par = String(parButton.tag)
        updateScore(category: "par", value: par)
        if par == "3" {  // Om det är en par 3 så sätts fwhit till "not set"
            updateScore(category: "fwHit", value: "not set")}
        parButtonAction(par: par)
    }
    @IBAction func fwHitClicked(_ sender: UIButton) {
        let fwHitButton = sender as UIButton
        var fwHit: String = ""
        switch fwHitButton.tag {
        case 1:
            fwHit = "yes"
        case 0:
            fwHit = "no"
        default:
            fwHit = "not set"
        }
        updateScore(category: "fwHit", value: fwHit)
        fwHitAction(fwHit: fwHit)
    }
    @IBAction func girClicked(_ sender: UIButton) {
        let girButton = sender as UIButton
        var gir: String = ""
        switch girButton.tag {
        case 1:
            gir = "yes"
        case 0:
            gir = "no"
        default:
            gir = "not set"
        }
        updateScore(category: "gir", value: gir)
        girAction(gir: gir)
    }
    @IBAction func puttsClicked(_ sender: UIButton) {
        let puttsButton = sender as UIButton
        let putts = String(puttsButton.tag)
        updateScore(category: "putts", value: putts)
        puttsAction(putts: putts)
        forecastStrokes()
    }
    @IBAction func strokesClicked(_ sender: UIButton) {
        let strokesButton = sender as UIButton
        let strokes = String(strokesButton.tag)
        updateScore(category: "score", value: strokes)
        strokesAction(strokes: strokes)
    }
    @IBAction func previousHoleAction(_ sender: Any) {
    // Functions for moving one hole back
        if self.holeNumber > 1 {
            self.holeNumber = self.holeNumber - 1
            holeNumberLabel.text = String(self.holeNumber)
            configureView()
        }
    }
    @IBAction func nextHoleAction(_ sender: Any) {
    // Functions for moving to next hole
        if self.holeNumber < 18 {
            self.holeNumber = self.holeNumber + 1
            holeNumberLabel.text = String(self.holeNumber)
            configureView()
        }
    }
    //
    // controllerns programlogik
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad() // ladda data från det som sattes i seguen dvs scoreDict

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // all score-uppdatering i scoreDict sker HÄR!!!!
    func updateScore(category: String, value: String) {
        // räkna om totaler och uppdatera firebase med relevant data
        self.scoreDict [holeNumber] [category] = value
        // uppdatera specifik nod med rätt score
        let myChild = String(holeNumber) + "/" + category
        self.refRounds.child(self.uid).child(self.timeStamp).child(myChild).setValue(self.scoreDict[holeNumber] [category])
        // Aggregera resultat i scoreDic med node = 0
        let myCategories = ["par", "fwHit", "gir", "putts", "score"]
        // nollställ alla aggregat innan omräkning
        for myCategory in myCategories {
            scoreDict[0] [myCategory] = "0"
        }
        var myNrOfHoles: NSInteger = 0
        var myNrOfPar3s: NSInteger = 0
        // Aggregera resultat
        for index in 1...18 {
            if scoreDict [index] ["par"]! != "not set" {
                scoreDict [0] ["par"] = String(Int(scoreDict [0] ["par"]!)! + Int(scoreDict [index] ["par"]!)!)
                myNrOfHoles = myNrOfHoles + 1
                if scoreDict [index] ["par"]! == "3" {
                    myNrOfPar3s = myNrOfPar3s + 1
                }
            }
            if scoreDict [index] ["fwHit"]! == "yes" {
                scoreDict [0] ["fwHit"] = String(Int(scoreDict [0] ["fwHit"]!)! + 1)
            }
            if scoreDict [index] ["gir"]! == "yes" {
                scoreDict [0] ["gir"] = String(Int(scoreDict [0] ["gir"]!)! + 1)
            }
            if scoreDict [index] ["putts"]! != "not set" {
                scoreDict [0] ["putts"] = String(Int(scoreDict [0] ["putts"]!)! + Int(scoreDict [index] ["putts"]!)!)
            }
            if scoreDict [index] ["score"]! != "not set" {
                scoreDict [0] ["score"] = String(Int(scoreDict [0] ["score"]!)! + Int(scoreDict [index] ["score"]!)!)
            }
            // uppdatera totalresultat i nod noll
            self.refRounds.child(self.uid).child(self.timeStamp).child("0").setValue(self.scoreDict [0])
        }
        // uppdatera resultat i ronden
        self.refRounds.child(self.uid).child(self.timeStamp).child("roundsDict/totHoles").setValue(String(myNrOfHoles))
        self.refRounds.child(self.uid).child(self.timeStamp).child("roundsDict/totPar3s").setValue(String(myNrOfPar3s))
    }
    func forecastStrokes() {
        // Bara forecast om GIR = yes
        if self.scoreDict [self.holeNumber] ["gir"] == "yes" {
            // bara forecast om man inte tidigare angett antal strokes
            if self.scoreDict [self.holeNumber] ["score"] == "not set" {
                let myForecast = Int(self.scoreDict [self.holeNumber] ["par"]!)! - 2 + Int(self.scoreDict [self.holeNumber] ["putts"]!)!
                updateScore(category: "score", value: String(myForecast))
                //uppdatera vyn
                strokesAction(strokes: String(myForecast))
            }
        }
    }
    func initialLoad() {
        // Data finns redan i scoreDict
        // sätt färg och data i labels
        holeNumberLabel.backgroundColor = UIColor.lightGray
        holeNumberLabel.text = String(self.holeNumber)
        configureView() // här konfigureras hålet på skärmen
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .done, target: self, action: #selector(resetAction))
        // sätt rubrik till golfbana och datum
        self.navigationItem.title = self.golfCourse + ", " + self.date
    }
    func configureView() {
        // Nollställ buttons
        resetParButtonColor()
        resetfwHitColor()
        resetgirColor()
        resetPuttsButtonColor()
        resetStrokesButtonColor()
        // Sätt par buttons
        parButtonAction(par: self.scoreDict [self.holeNumber] ["par"]!)
        // Sätt fw hit buttons
        fwHitAction(fwHit: self.scoreDict [self.holeNumber] ["fwHit"]!)
        // sätt gir buttons
        girAction(gir: self.scoreDict [self.holeNumber] ["gir"]!)
        // sätt putts buttons
        puttsAction(putts: self.scoreDict [self.holeNumber] ["putts"]!)
        // sätt strokes buttons
        strokesAction(strokes: self.scoreDict [self.holeNumber] ["score"]!)
        // uppdatera med totalt antal slag
        if scoreDict [0] ["score"] != "not set" {
            scoreLabel.text = scoreDict [0] ["score"]
        }
        // Uppdatera med under / på / över par
        calculateOnPar()
    }
    // Räkna ut nuvarande resultat mot par
    func calculateOnPar() {
        var myPar: NSInteger = 0
        var myResult: NSInteger = 0
        for index in 1...18 {
            if self.scoreDict[index] ["par"] != "not set" {
                myPar = myPar + Int(self.scoreDict[index] ["par"]!)!
            }
            if self.scoreDict[index] ["score"] != "not set" {
                myResult = myResult + Int(self.scoreDict[index] ["score"]!)!
            }
        }
        let myScore = myResult - myPar
        onParLabel.textColor = UIColor.black
        onParLabel.text = "on par"
        if myScore > 0 {
            onParLabel.text = "+" + String(myScore)
            onParLabel.textColor = UIColor.black
        }
        if myScore < 0 {
            onParLabel.text = String(myScore)
            onParLabel.textColor = UIColor.red
        }
    }
    // Buttonactions
    func parButtonAction (par: String) {
        resetParButtonColor()
        if par == "3" {
            self.par3Button.backgroundColor = UIColor.black
            self.par3Button.setTitleColor(.yellow, for: .normal)
            // vid par 3 är fwhit inte aktuellt
            resetfwHitColor()
            disablefwHit()
            //updateScore(category: "fwHit", value: "not set")
        }
        if par == "4" {
            self.par4Button.backgroundColor = UIColor.black
            self.par4Button.setTitleColor(.yellow, for: .normal)
            enablefwHit()}
        if par == "5" {
            resetParButtonColor()
            self.par5Button.backgroundColor = UIColor.black
            self.par5Button.setTitleColor(.yellow, for: .normal)
            enablefwHit()}
        if par == "not set" {
            enablefwHit()
        }
    }
    func fwHitAction(fwHit: String) {
        if fwHit == "yes" {
            self.fwHitNo.backgroundColor = UIColor.white
            self.fwHitYes.backgroundColor = UIColor.black
            self.fwHitNo.setTitleColor(.black, for: .normal)
            self.fwHitYes.setTitleColor(.yellow, for: .normal)}
        if fwHit == "no" {
            self.fwHitNo.backgroundColor = UIColor.black
            self.fwHitYes.backgroundColor = UIColor.white
            self.fwHitNo.setTitleColor(.yellow, for: .normal)
            self.fwHitYes.setTitleColor(.black, for: .normal)}
    }
    func girAction(gir: String) {
        if gir == "yes" {
            self.girNo.backgroundColor = UIColor.white
            self.girYes.backgroundColor = UIColor.black
            self.girNo.setTitleColor(.black, for: .normal)
            self.girYes.setTitleColor(.yellow, for: .normal)}
        if gir == "no" {
            self.girNo.backgroundColor = UIColor.black
            self.girYes.backgroundColor = UIColor.white
            self.girNo.setTitleColor(.yellow, for: .normal)
            self.girYes.setTitleColor(.black, for: .normal)}
    }
    func puttsAction(putts: String) {
        resetPuttsButtonColor()
        if putts == "0" {
            self.putts0.backgroundColor = UIColor.black
            self.putts0.setTitleColor(.yellow, for: .normal)}
        if putts == "1" {
            self.putts1.backgroundColor = UIColor.black
            self.putts1.setTitleColor(.yellow, for: .normal)}
        if putts == "2" {
            self.putts2.backgroundColor = UIColor.black
            self.putts2.setTitleColor(.yellow, for: .normal)}
        if putts == "3" {
            self.putts3.backgroundColor = UIColor.black
            self.putts3.setTitleColor(.yellow, for: .normal)}
        if putts == "4" {
            self.putts4.backgroundColor = UIColor.black
            self.putts4.setTitleColor(.yellow, for: .normal)}
        if putts == "5" {
            self.putts5.backgroundColor = UIColor.black
            self.putts5.setTitleColor(.yellow, for: .normal)}
    }
    func strokesAction(strokes: String) {
        switch strokes {
        case "1":
            resetStrokesButtonColor()
            self.strokes1.backgroundColor = UIColor.black
            self.strokes1.setTitleColor(.yellow, for: .normal)
        case "2":
            resetStrokesButtonColor()
            self.strokes2.backgroundColor = UIColor.black
            self.strokes2.setTitleColor(.yellow, for: .normal)
        case "3":
            resetStrokesButtonColor()
            self.strokes3.backgroundColor = UIColor.black
            self.strokes3.setTitleColor(.yellow, for: .normal)
        case "4":
            resetStrokesButtonColor()
            self.strokes4.backgroundColor = UIColor.black
            self.strokes4.setTitleColor(.yellow, for: .normal)
        case "5":
            resetStrokesButtonColor()
            self.strokes5.backgroundColor = UIColor.black
            self.strokes5.setTitleColor(.yellow, for: .normal)
        case "6":
            resetStrokesButtonColor()
            self.strokes6.backgroundColor = UIColor.black
            self.strokes6.setTitleColor(.yellow, for: .normal)
        case "7":
            resetStrokesButtonColor()
            self.strokes7.backgroundColor = UIColor.black
            self.strokes7.setTitleColor(.yellow, for: .normal)
        case "8":
            resetStrokesButtonColor()
            self.strokes8.backgroundColor = UIColor.black
            self.strokes8.setTitleColor(.yellow, for: .normal)
        case "9":
            resetStrokesButtonColor()
            self.strokesMore.backgroundColor = UIColor.black
            self.strokesMore.setTitleColor(.yellow, for: .normal)
        default:
            print("something went wrong")
        }
        calculateOnPar()
    }
    @objc func resetAction() {
        // rensa aktuellt hål, dvs self.holeNumber
        updateScore(category: "par", value: "not set")
        updateScore(category: "fwHit", value: "not set")
        updateScore(category: "gir", value: "not set")
        updateScore(category: "putts", value: "not set")
        updateScore(category: "score", value: "not set")
        configureView()
    }
    // funktioner för att nollställa knappar
    func resetParButtonColor() {
        self.par3Button.backgroundColor = UIColor.white
        self.par4Button.backgroundColor = UIColor.white
        self.par5Button.backgroundColor = UIColor.white
        self.par3Button.setTitleColor(.black, for: .normal)
        self.par4Button.setTitleColor(.black, for: .normal)
        self.par5Button.setTitleColor(.black, for: .normal)
    }
    func resetfwHitColor() {
        self.fwHitLabel.textColor = UIColor.black
        self.fwHitNo.backgroundColor = UIColor.white
        self.fwHitYes.backgroundColor = UIColor.white
        self.fwHitNo.setTitleColor(.black, for: .normal)
        self.fwHitYes.setTitleColor(.black, for: .normal)
    }
    func disablefwHit() {
        self.fwHitLabel.textColor = UIColor.gray
        self.fwHitYes.setTitleColor(.gray, for: .normal)
        self.fwHitYes.isEnabled = false
        self.fwHitNo.setTitleColor(.gray, for: .normal)
        self.fwHitNo.isEnabled = false
    }
    func enablefwHit() {
        self.fwHitLabel.textColor = UIColor.black
        self.fwHitYes.setTitleColor(.black, for: .normal)
        self.fwHitYes.isEnabled = true
        self.fwHitNo.setTitleColor(.black, for: .normal)
        self.fwHitNo.isEnabled = true
    }
    func resetgirColor() {
        self.girNo.backgroundColor = UIColor.white
        self.girYes.backgroundColor = UIColor.white
        self.girNo.setTitleColor(.black, for: .normal)
        self.girYes.setTitleColor(.black, for: .normal)
    }
    func resetPuttsButtonColor() {
        self.putts0.backgroundColor = UIColor.white
        self.putts1.backgroundColor = UIColor.white
        self.putts2.backgroundColor = UIColor.white
        self.putts3.backgroundColor = UIColor.white
        self.putts4.backgroundColor = UIColor.white
        self.putts5.backgroundColor = UIColor.white
        self.putts0.setTitleColor(.black, for: .normal)
        self.putts1.setTitleColor(.black, for: .normal)
        self.putts2.setTitleColor(.black, for: .normal)
        self.putts3.setTitleColor(.black, for: .normal)
        self.putts4.setTitleColor(.black, for: .normal)
        self.putts5.setTitleColor(.black, for: .normal)
    }
    func resetStrokesButtonColor() {
        self.strokes1.backgroundColor = UIColor.white
        self.strokes2.backgroundColor = UIColor.white
        self.strokes3.backgroundColor = UIColor.white
        self.strokes4.backgroundColor = UIColor.white
        self.strokes5.backgroundColor = UIColor.white
        self.strokes6.backgroundColor = UIColor.white
        self.strokes7.backgroundColor = UIColor.white
        self.strokes8.backgroundColor = UIColor.white
        self.strokesMore.backgroundColor = UIColor.white
        self.strokes1.setTitleColor(.black, for: .normal)
        self.strokes2.setTitleColor(.black, for: .normal)
        self.strokes3.setTitleColor(.black, for: .normal)
        self.strokes4.setTitleColor(.black, for: .normal)
        self.strokes5.setTitleColor(.black, for: .normal)
        self.strokes6.setTitleColor(.black, for: .normal)
        self.strokes7.setTitleColor(.black, for: .normal)
        self.strokes8.setTitleColor(.black, for: .normal)
        self.strokesMore.setTitleColor(.black, for: .normal)
    }
}

