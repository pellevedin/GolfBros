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
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var holeNumberLabel: UILabel!
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
    let selectedBackGroundColor = UIColor.black
    let normalBackGroundColor = UIColor.white
    let selectedTextColor = UIColor.yellow
    let normalTextColor = UIColor.black
    let underParTextColor = UIColor.red
    let holeNrTextColor = UIColor.orange
    let shadedColor = UIColor.gray
    
    // alla knapphändelser
    @IBAction func parButtonClicked(_ sender: UIButton) {
        let parButton = sender as UIButton
        // i .tag ligger vilket par det är (3, 4 eller 5)
        let par = String(parButton.tag)
        updateScore(category: "par", value: par)
        if par == "3" {  // Om det är en par 3 så sätts fwhit till "not set"
            updateScore(category: "fwHit", value: "not set")}
        parButtonAction(par: par)
    }
    @IBAction func fwHitClicked(_ sender: UIButton) {
        let fwHitButton = sender as UIButton
        var fwHit: String = ""
        // i .tag ligger 0 för ingen fairwayhet och 1 för fairwayhit
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
        // i .tag ligger 0 för ingen GIR och 1 för GIR
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
        // i .tag ligger antalet puttar som angivits
        let putts = String(puttsButton.tag)
        updateScore(category: "putts", value: putts)
        puttsAction(putts: putts)
        forecastStrokes()
    }
    @IBAction func strokesClicked(_ sender: UIButton) {
        let strokesButton = sender as UIButton
        // i .tag ligger antalet slag som angivits
        let strokes = String(strokesButton.tag)
        updateScore(category: "score", value: strokes)
        strokesAction(strokes: strokes)
    }
    @IBAction func previousHoleAction(_ sender: Any) {
    // Functions for moving one hole back
        if self.holeNumber > 1 {
            self.holeNumber = self.holeNumber - 1
            holeNumberLabel.text = "#" + String(self.holeNumber)
            configureView()
        }
    }
    @IBAction func nextHoleAction(_ sender: Any) {
    // Functions for moving to next hole
        if self.holeNumber < 18 {
            self.holeNumber = self.holeNumber + 1
            holeNumberLabel.text = "#" + String(self.holeNumber)
            configureView()
        }
    }
    // controllerns programlogik
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        let user = Auth.auth().currentUser
        self.uid = user!.uid
        initialLoad() // ladda data från det som sattes i seguen dvs scoreDict
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.courseLabel.text = self.golfCourse
        self.navigationItem.title = self.date
        // möjlighet att cleara hålet och eventuella reggade resultat
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(resetAction))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        // här
        self.refRounds.removeAllObservers()
    }
    // all score-uppdatering i scoreDict sker HÄR!!!!
    func updateScore(category: String, value: String) {
        // räkna om totaler och uppdatera firebase med relevant data
        // först uppdaterar vi scoreDict med värden vi fick i anropet
        self.scoreDict [self.holeNumber] [category] = value
        // uppdatera specifik nod med rätt score i firebase
        let myChild = String(self.holeNumber) + "/" + category
        self.refRounds.child(self.uid).child(self.timeStamp).child(myChild).setValue(self.scoreDict[self.holeNumber] [category])
        // Aggregera resultat i scoreDic med node = 0
        let myCategories = ["par", "fwHit", "gir", "putts", "score"]
        // nollställ alla aggregat innan omräkning
        for myCategory in myCategories {
            scoreDict[0] [myCategory] = "0"
        }
        var myNrOfHoles: NSInteger = 0 // räknare för antal hål i ronden
        var myNrOfPar3s: NSInteger = 0 // räknare för antal par3 hål i ronden
        // Aggregera resultat
        for index in 1...18 {
            if scoreDict [index] ["par"]! != "not set" {
                scoreDict [0] ["par"] = String(Int(scoreDict [0] ["par"]!)! + Int(scoreDict [index] ["par"]!)!)
                //räkna upp antalet hål
                myNrOfHoles = myNrOfHoles + 1
                // håll reda på hur många par3 hål
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
        self.holeNumberLabel.backgroundColor = holeNrTextColor
        self.holeNumberLabel.text = "#" + String(self.holeNumber)
        configureView() // här konfigureras hålet på skärmen
    }
    func configureView() {
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
        // sätt text och fär beroende på...
        switch myScore {
        case 0:
            self.onParLabel.textColor = normalTextColor
            self.onParLabel.text = "on par"
        case Int.min..<0:
            self.onParLabel.text = String(myScore)
            self.onParLabel.textColor = underParTextColor
        default:
            self.onParLabel.text = "+" + String(myScore)
            self.onParLabel.textColor = normalTextColor
        }
    }
    // Buttonactions
    func parButtonAction (par: String) {
        resetParButtonColor()
        switch par {
        case "3":
            self.par3Button.backgroundColor = selectedBackGroundColor
            self.par3Button.setTitleColor(selectedTextColor, for: .normal)
            // vid par 3 är fwhit inte aktuellt
            //resetfwHitColor()
            disablefwHit()
            updateScore(category: "fwHit", value: "not set")
        case "4":
            self.par4Button.backgroundColor = selectedBackGroundColor
            self.par4Button.setTitleColor(selectedTextColor, for: .normal)
            enablefwHit()
        case "5":
            resetParButtonColor()
            self.par5Button.backgroundColor = selectedBackGroundColor
            self.par5Button.setTitleColor(selectedTextColor, for: .normal)
            enablefwHit()
        case "not set":
            enablefwHit()
        default:
            print ("Error in parButtonAction")
        }
    }
    func fwHitAction(fwHit: String) {
        resetfwHitColor()
        switch fwHit {
        case "yes":
            self.fwHitNo.backgroundColor = normalBackGroundColor
            self.fwHitYes.backgroundColor = selectedBackGroundColor
            self.fwHitNo.setTitleColor(normalTextColor, for: .normal)
            self.fwHitYes.setTitleColor(selectedTextColor, for: .normal)
        case "no":
            self.fwHitNo.backgroundColor = selectedBackGroundColor
            self.fwHitYes.backgroundColor = normalBackGroundColor
            self.fwHitNo.setTitleColor(selectedTextColor, for: .normal)
            self.fwHitYes.setTitleColor(normalTextColor, for: .normal)
        case "not set":
            if self.scoreDict [self.holeNumber] ["par"]! == "3" {
                disablefwHit()
            } else {
                resetfwHitColor()
            }
        default:
            print("Error in fwHitAction")
        }
    }
    func girAction(gir: String) {
        resetgirColor()
        switch gir {
        case "yes":
            self.girNo.backgroundColor = normalBackGroundColor
            self.girYes.backgroundColor = selectedBackGroundColor
            self.girNo.setTitleColor(normalTextColor, for: .normal)
            self.girYes.setTitleColor(selectedTextColor, for: .normal)
        case "no":
            self.girNo.backgroundColor = selectedBackGroundColor
            self.girYes.backgroundColor = normalBackGroundColor
            self.girNo.setTitleColor(selectedTextColor, for: .normal)
            self.girYes.setTitleColor(normalTextColor, for: .normal)
        case "not set":
            resetgirColor()
        default:
            print("Error in girAction")
        }
    }
    func puttsAction(putts: String) {
        resetPuttsButtonColor()
        switch putts {
        case "0":
            self.putts0.backgroundColor = selectedBackGroundColor
            self.putts0.setTitleColor(selectedTextColor, for: .normal)
        case "1":
            self.putts1.backgroundColor = selectedBackGroundColor
            self.putts1.setTitleColor(selectedTextColor, for: .normal)
        case "2":
            self.putts2.backgroundColor = selectedBackGroundColor
            self.putts2.setTitleColor(selectedTextColor, for: .normal)
        case "3":
            self.putts3.backgroundColor = selectedBackGroundColor
            self.putts3.setTitleColor(selectedTextColor, for: .normal)
        case "4":
            self.putts4.backgroundColor = selectedBackGroundColor
            self.putts4.setTitleColor(selectedTextColor, for: .normal)
        case "5":
            self.putts5.backgroundColor = selectedBackGroundColor
            self.putts5.setTitleColor(selectedTextColor, for: .normal)
        case "not set":
            resetPuttsButtonColor()
        default:
            print ("Error in putts action")
        }
    }
    func strokesAction(strokes: String) {
        resetStrokesButtonColor()
        switch strokes {
        case "1":
            self.strokes1.backgroundColor = selectedBackGroundColor
            self.strokes1.setTitleColor(selectedTextColor, for: .normal)
        case "2":
            self.strokes2.backgroundColor = selectedBackGroundColor
            self.strokes2.setTitleColor(selectedTextColor, for: .normal)
        case "3":
            self.strokes3.backgroundColor = selectedBackGroundColor
            self.strokes3.setTitleColor(selectedTextColor, for: .normal)
        case "4":
            self.strokes4.backgroundColor = selectedBackGroundColor
            self.strokes4.setTitleColor(selectedTextColor, for: .normal)
        case "5":
            self.strokes5.backgroundColor = selectedBackGroundColor
            self.strokes5.setTitleColor(selectedTextColor, for: .normal)
        case "6":
            self.strokes6.backgroundColor = selectedBackGroundColor
            self.strokes6.setTitleColor(selectedTextColor, for: .normal)
        case "7":
            self.strokes7.backgroundColor = selectedBackGroundColor
            self.strokes7.setTitleColor(selectedTextColor, for: .normal)
        case "8":
            self.strokes8.backgroundColor = selectedBackGroundColor
            self.strokes8.setTitleColor(selectedTextColor, for: .normal)
        case "9":
            self.strokesMore.backgroundColor = selectedBackGroundColor
            self.strokesMore.setTitleColor(selectedTextColor, for: .normal)
        case "not set":
            resetStrokesButtonColor()
        default:
            print("Error in strokes action")
        }
        calculateOnPar()
        // uppdatera med totalt antal slag
        //if scoreDict [0] ["score"] != "not set" {
        //    self.scoreLabel.text = scoreDict [0] ["score"]
        //}
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
        self.par3Button.backgroundColor = normalBackGroundColor
        self.par4Button.backgroundColor = normalBackGroundColor
        self.par5Button.backgroundColor = normalBackGroundColor
        self.par3Button.setTitleColor(normalTextColor, for: .normal)
        self.par4Button.setTitleColor(normalTextColor, for: .normal)
        self.par5Button.setTitleColor(normalTextColor, for: .normal)
    }
    func resetfwHitColor() {
        self.fwHitLabel.textColor = normalTextColor
        self.fwHitNo.backgroundColor = normalBackGroundColor
        self.fwHitYes.backgroundColor = normalBackGroundColor
        self.fwHitNo.setTitleColor(normalTextColor, for: .normal)
        self.fwHitYes.setTitleColor(normalTextColor, for: .normal)
    }
    func disablefwHit() {
        self.fwHitLabel.textColor = shadedColor
        self.fwHitYes.backgroundColor = normalBackGroundColor
        self.fwHitYes.setTitleColor(shadedColor, for: .normal)
        self.fwHitYes.isEnabled = false
        self.fwHitNo.backgroundColor = normalBackGroundColor
        self.fwHitNo.setTitleColor(shadedColor, for: .normal)
        self.fwHitNo.isEnabled = false
    }
    func enablefwHit() {
        self.fwHitLabel.textColor = normalTextColor
        self.fwHitYes.setTitleColor(normalTextColor, for: .normal)
        self.fwHitYes.isEnabled = true
        self.fwHitNo.setTitleColor(normalTextColor, for: .normal)
        self.fwHitNo.isEnabled = true
    }
    func resetgirColor() {
        self.girNo.backgroundColor = normalBackGroundColor
        self.girYes.backgroundColor = normalBackGroundColor
        self.girNo.setTitleColor(normalTextColor, for: .normal)
        self.girYes.setTitleColor(normalTextColor, for: .normal)
    }
    func resetPuttsButtonColor() {
        self.putts0.backgroundColor = normalBackGroundColor
        self.putts1.backgroundColor = normalBackGroundColor
        self.putts2.backgroundColor = normalBackGroundColor
        self.putts3.backgroundColor = normalBackGroundColor
        self.putts4.backgroundColor = normalBackGroundColor
        self.putts5.backgroundColor = normalBackGroundColor
        self.putts0.setTitleColor(normalTextColor, for: .normal)
        self.putts1.setTitleColor(normalTextColor, for: .normal)
        self.putts2.setTitleColor(normalTextColor, for: .normal)
        self.putts3.setTitleColor(normalTextColor, for: .normal)
        self.putts4.setTitleColor(normalTextColor, for: .normal)
        self.putts5.setTitleColor(normalTextColor, for: .normal)
    }
    func resetStrokesButtonColor() {
        self.strokes1.backgroundColor = normalBackGroundColor
        self.strokes2.backgroundColor = normalBackGroundColor
        self.strokes3.backgroundColor = normalBackGroundColor
        self.strokes4.backgroundColor = normalBackGroundColor
        self.strokes5.backgroundColor = normalBackGroundColor
        self.strokes6.backgroundColor = normalBackGroundColor
        self.strokes7.backgroundColor = normalBackGroundColor
        self.strokes8.backgroundColor = normalBackGroundColor
        self.strokesMore.backgroundColor = normalBackGroundColor
        self.strokes1.setTitleColor(normalTextColor, for: .normal)
        self.strokes2.setTitleColor(normalTextColor, for: .normal)
        self.strokes3.setTitleColor(normalTextColor, for: .normal)
        self.strokes4.setTitleColor(normalTextColor, for: .normal)
        self.strokes5.setTitleColor(normalTextColor, for: .normal)
        self.strokes6.setTitleColor(normalTextColor, for: .normal)
        self.strokes7.setTitleColor(normalTextColor, for: .normal)
        self.strokes8.setTitleColor(normalTextColor, for: .normal)
        self.strokesMore.setTitleColor(normalTextColor, for: .normal)
    }
}

