//
//  PlayInfoController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-11-04.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit

// Cellen i egen klass
class CollCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
}


class PlayInfoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var uid: String = ""
    var timeStamp: String = ""
    var golfCourse: String = ""
    var date: String = ""
    var fwHit: String = ""
    var gir: String = ""
    var out9 = ["holes": "0", "par": "0", "fwHit": "0", "gir": "0", "putts": "0", "score": "0"]
    var out9Par3s: NSInteger = 0
    var in9 = ["holes": "0", "par": "0", "fwHit": "0", "gir": "0", "putts": "0", "score": "0"]
    var in9Par3s: NSInteger = 0
    var aboveParColor = UIColor(red: 0/255.0, green: 150/255.0, blue: 255/255.0, alpha: 1.0)
    var belowParColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    var onParColor = UIColor(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0)
    var normalCellColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    var specialCellColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 200/255.0, alpha: 1.0)
    var categories = ["holes", "par", "fwHit", "gir", "putts", "score"]
    var scoreDict = [[String: String]]()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelHole: UILabel!
    @IBOutlet weak var labelPar: UILabel!
    @IBOutlet weak var labelFwHit: UILabel!
    @IBOutlet weak var labelPutts: UILabel!
    @IBOutlet weak var labelGIR: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    
    @IBOutlet weak var totalHole: UILabel!
    @IBOutlet weak var totalPar: UILabel!
    @IBOutlet weak var totalFwHit: UILabel!
    @IBOutlet weak var totalGIR: UILabel!
    @IBOutlet weak var totalPutts: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelBackgrounds()
        self.navigationItem.title = self.golfCourse + ", " + self.date
        // här räknar vi ut totaler
        aggregateInAndOut()
        setTotals()
        self.collectionView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Deklarationer för collectionvyn
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collCell", for: indexPath) as! CollCell
        cell.textLabel.backgroundColor = normalCellColor
        var cleanUpString: String = ""
        // hantera raderna 1 till 10
        if (indexPath.section >= 0) && (indexPath.section < 9) {
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = String(indexPath.section + 1)
            case 1:
                cell.textLabel.text = scoreDict [indexPath.section + 1] ["par"]
            case 2:
                cell.textLabel.text = scoreDict [indexPath.section + 1] ["fwHit"]
            case 3:
                cell.textLabel.text = scoreDict [indexPath.section + 1] ["gir"]
            case 4:
                cell.textLabel.text = scoreDict [indexPath.section + 1] ["putts"]
            case 5:
                cell.textLabel.text = scoreDict [indexPath.section + 1] ["score"]
                let myRow = indexPath.section + 1
                let myScore = scoreDict[myRow] ["score"]!
                let myPar = scoreDict[myRow] ["par"]!
                cell.textLabel.backgroundColor = setColor(myScore: myScore, myPar: myPar)
            default:
                print("Error in setting row 1-9")
            }
        }
        // rad 10 innehåller totaler efter 9 hål
        if indexPath.section == 9 {
            cell.textLabel.backgroundColor = specialCellColor
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = "Out"
            case 1:
                cell.textLabel.text = self.out9["par"]
            case 2:
                cell.textLabel.text = self.out9["fwHit"]
            case 3:
                cell.textLabel.text = self.out9["gir"]
            case 4:
                cell.textLabel.text = self.out9["putts"]
            case 5:
                cell.textLabel.text = self.out9["score"]
                let myScore = out9 ["score"]!
                let myPar = out9 ["par"]!
                cell.textLabel.backgroundColor = setColor(myScore: myScore, myPar: myPar)
            default:
                print("Error in setting row 9")
            }
        }
        // sedan hanterar vi hål 10-18
        if (indexPath.section > 9) && (indexPath.section < 19) {
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = String(indexPath.section)
            case 1:
                cell.textLabel.text = scoreDict [indexPath.section] ["par"]
            case 2:
                cell.textLabel.text = scoreDict [indexPath.section] ["fwHit"]
            case 3:
                cell.textLabel.text = scoreDict [indexPath.section] ["gir"]
            case 4:
                cell.textLabel.text = scoreDict [indexPath.section] ["putts"]
            case 5:
                cell.textLabel.text = scoreDict [indexPath.section] ["score"]
                let myRow = indexPath.section
                let myScore = scoreDict[myRow] ["score"]!
                let myPar = scoreDict[myRow] ["par"]!
                cell.textLabel.backgroundColor = setColor(myScore: myScore, myPar: myPar)
            default:
                print("Error in setting row 10-18")
            }
        }
        //Och sedan en summering av de sista 9 hålen
        if indexPath.section == 19 {
            cell.textLabel.backgroundColor = specialCellColor
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = "In"
            case 1:
                cell.textLabel.text = self.in9["par"]
            case 2:
                cell.textLabel.text = self.in9["fwHit"]
            case 3:
                cell.textLabel.text = self.in9["gir"]
            case 4:
                cell.textLabel.text = self.in9["putts"]
            case 5:
                cell.textLabel.text = self.in9["score"]
                let myScore = in9 ["score"]!
                let myPar = in9 ["par"]!
                cell.textLabel.backgroundColor = setColor(myScore: myScore, myPar: myPar)
            default:
                print("Error in setting row 18")
            }
        }
        cleanUpString = cell.textLabel.text!
        cell.textLabel.text = cleanUp(cleanUpString: cleanUpString)
        return cell
    }
    // generella funktioner
    func cleanUp(cleanUpString: String) -> String {
        let returnString = cleanUpString
        if cleanUpString == "not set" {
            return ""
        }
        return returnString
    }
    
    func setTotals() {
        self.totalHole.backgroundColor = specialCellColor
        self.totalPar.text = scoreDict [0] ["par"]
        self.totalPar.backgroundColor = specialCellColor
        self.totalFwHit.text = fwHit
        self.totalFwHit.backgroundColor = specialCellColor
        self.totalGIR.text = gir
        self.totalGIR.backgroundColor = specialCellColor
        self.totalPutts.text = scoreDict [0] ["putts"]
        self.totalPutts.backgroundColor = specialCellColor
        self.totalScore.text = scoreDict [0] ["score"]
        let myScore = scoreDict[0] ["score"]!
        let myPar = scoreDict[0] ["par"]!
        self.totalScore.backgroundColor = setColor(myScore: myScore, myPar: myPar)
    }
    func setColor(myScore: String, myPar: String) -> UIColor {
        if let myScore1 = Int(myScore) {
            if let myPar1 = Int(myPar) {
                if myScore1 == myPar1 {
                    return onParColor
                }
                if myScore1 > myPar1 {
                    return aboveParColor
                }
                if myScore1 < myPar1 {
                    return belowParColor
                }
                return normalCellColor
            }
            return normalCellColor
        }
        return normalCellColor
    }
    func aggregateInAndOut () {
        // Summera första 9 hålen
        for index in 1...9 {
            if let myCounter = Int(self.scoreDict[index] ["par"]!) {
                self.out9 ["par"] = String(Int(self.out9 ["par"]!)! + myCounter)
                self.out9 ["holes"] = String(Int(self.out9 ["holes"]!)! + 1)
            }
            if self.scoreDict [index] ["par"] == "3" {
                out9Par3s = out9Par3s + 1
            }
            if self.scoreDict [index] ["fwHit"] == "yes" {
                self.out9 ["fwHit"] = String(Int(self.out9 ["fwHit"]!)! + 1)
            }
            if self.scoreDict[index] ["gir"] == "yes" {
                self.out9 ["gir"] = String(Int(self.out9 ["gir"]!)! + 1)
            }
            if let myCounter = Int(self.scoreDict[index] ["putts"]!) {
                self.out9 ["putts"] = String(Int(self.out9 ["putts"]!)! + myCounter)
            }
            if let myCounter = Int(self.scoreDict[index] ["score"]!) {
                self.out9 ["score"] = String(Int(self.out9 ["score"]!)! + myCounter)
            }
        }
        //summera sista 9 hålen
        for index in 10...18 {
            if let myCounter = Int(self.scoreDict[index] ["par"]!) {
                self.in9 ["par"] = String(Int(self.in9 ["par"]!)! + myCounter)
                self.in9 ["holes"] = String(Int(self.in9 ["holes"]!)! + 1)
            }
            if self.scoreDict [index] ["par"] == "3" {
                in9Par3s = in9Par3s + 1
            }
            if self.scoreDict[index] ["fwHit"] == "yes" {
                self.in9 ["fwHit"] = String(Int(self.in9 ["fwHit"]!)! + 1)
            }
            if self.scoreDict[index] ["gir"] == "yes" {
                self.in9 ["gir"] = String(Int(self.in9 ["gir"]!)! + 1)
            }
            if let myCounter = Int(self.scoreDict[index] ["putts"]!) {
                self.in9 ["putts"] = String(Int(self.in9 ["putts"]!)! + myCounter)
            }
            if let myCounter = Int(self.scoreDict[index] ["score"]!) {
                self.in9 ["score"] = String(Int(self.in9 ["score"]!)! + myCounter)
            }
        }
        // Summera och räkna ut procent
        let outNrOfHoles = Double(out9 ["holes"]!)!
        let inNrOfHoles = Double(in9 ["holes"]!)!
        let totNrOfHoles = Double(outNrOfHoles + inNrOfHoles)
        if outNrOfHoles > 0 {
            let out9dfwHit = Double(self.out9["fwHit"]!)! / (outNrOfHoles - Double(out9Par3s)) * 100 as Double
            self.out9 ["fwHit"] = String(Int(round(out9dfwHit))) + "%" as String
            let outdgir = Double(self.out9 ["gir"]!)! / outNrOfHoles * 100 as Double
            self.out9["gir"] = String(Int(round(outdgir))) + "%"
            
        } else {
            self.out9 ["fwHit"] = ""
            self.out9 ["gir"] = ""
        }
        if inNrOfHoles > 0 {
            let indfwHit = Double(self.in9["fwHit"]!)! / (inNrOfHoles - Double(in9Par3s)) * 100 as Double
            self.in9 ["fwHit"] = String(Int(round(indfwHit))) + "%"
            let inddgir = Double(self.in9 ["gir"]!)! / inNrOfHoles * 100 as Double
            self.in9["gir"] = String(Int(round(inddgir))) + "%"
        } else {
            self.in9 ["fwHit"] = ""
            self.in9 ["gir"] = ""
        }
        if totNrOfHoles > 0 {
            let dfwHit = Double(self.scoreDict [0] ["fwHit"]!)! / (totNrOfHoles - Double(out9Par3s) - Double(in9Par3s)) * 100 as Double
            self.fwHit = String(Int(round(dfwHit))) + "%"
            let dgir = Double(self.scoreDict [0] ["gir"]!)! / totNrOfHoles * 100 as Double
            self.gir = String(Int(round(dgir))) + "%"
        } else {
            self.fwHit = ""
            self.gir = ""
        }
    }
    func setLabelBackgrounds() {
        self.labelHole.backgroundColor = specialCellColor
        self.labelPar.backgroundColor = specialCellColor
        self.labelFwHit.backgroundColor = specialCellColor
        self.labelGIR.backgroundColor = specialCellColor
        self.labelPutts.backgroundColor = specialCellColor
        self.labelScore.backgroundColor = specialCellColor
        
    }
}

