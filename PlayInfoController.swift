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
    var out9 = ["par": "0", "fwHit": "0", "gir": "0", "putts": "0", "score": "0"]
    var out9Par3s: NSInteger = 0
    var in9 = ["par": "0", "fwHit": "0", "gir": "0", "putts": "0", "score": "0"]
    var in9Par3s: NSInteger = 0
    var blueColor = UIColor(red: 0/255.0, green: 150/255.0, blue: 255/255.0, alpha: 1.0)
    var redColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    var greenColor = UIColor(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0)
    var whiteColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    var categories = ["par", "fwHit", "gir", "putts", "score"]
    var scoreDict = [[String: String]]()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headingLabel.text = self.golfCourse + ", " + self.date
        // här räknar vi ut totaler
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        aggregateInAndOut()
        self.collectionView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Deklarationer för collectionvyn
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 22
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collCell", for: indexPath) as! CollCell
        cell.textLabel.backgroundColor = whiteColor
        var cleanUpString: String = ""
        if indexPath.section == 0 {
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = "Hole"
            case 1:
                cell.textLabel.text = "Par"
            case 2:
                cell.textLabel.text = "Fw?"
            case 3:
                cell.textLabel.text = "GIR?"
            case 4:
                cell.textLabel.text = "Putts"
            case 5:
                cell.textLabel.text = "Score"
            default:
                print("hej")
            }
        }
        // hantera raderna 1 till 10
        if (indexPath.section > 0) && (indexPath.section < 10) {
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
                cell.textLabel.backgroundColor = setColor(myRow: myRow, myScore: myScore, myPar: myPar)
            default:
                print("hej")
            }
        }
        // rad 10 innehåller totaler efter 9 hål
        if indexPath.section == 10 {
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
                let myRow = indexPath.section
                let myScore = out9 ["score"]!
                let myPar = out9 ["par"]!
                cell.textLabel.backgroundColor = setColor(myRow: myRow, myScore: myScore, myPar: myPar)
            default:
                print("hej")
            }
        }
        // sedan hanterar vi hål 10-18
        if (indexPath.section > 10) && (indexPath.section < 20) {
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = String(indexPath.section - 1)
            case 1:
                cell.textLabel.text = scoreDict [indexPath.section - 1] ["par"]
            case 2:
                cell.textLabel.text = scoreDict [indexPath.section - 1] ["fwHit"]
            case 3:
                cell.textLabel.text = scoreDict [indexPath.section - 1] ["gir"]
            case 4:
                cell.textLabel.text = scoreDict [indexPath.section - 1] ["putts"]
            case 5:
                cell.textLabel.text = scoreDict [indexPath.section - 1] ["score"]
                let myRow = indexPath.section - 1
                let myScore = scoreDict[myRow] ["score"]!
                let myPar = scoreDict[myRow] ["par"]!
                cell.textLabel.backgroundColor = setColor(myRow: myRow, myScore: myScore, myPar: myPar)
            default:
                print("hej")
            }
        }
        //Och sedan en summering av de sista 9 hålen
        if indexPath.section == 20 {
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
                let myRow = indexPath.section
                let myScore = in9 ["score"]!
                let myPar = in9 ["par"]!
                cell.textLabel.backgroundColor = setColor(myRow: myRow, myScore: myScore, myPar: myPar)
            default:
                print("hej")
            }
        }
        // och slutligen sista raden dvs totaler för ronden
        if indexPath.section == 21 {
            let mySwitch = indexPath.row
            switch mySwitch {
            case 0:
                cell.textLabel.text = "Total"
            case 1:
                cell.textLabel.text = scoreDict [0] ["par"]
            case 2:
                cell.textLabel.text = fwHit
            case 3:
                cell.textLabel.text = gir
            case 4:
                cell.textLabel.text = scoreDict [0] ["putts"]
            case 5:
                cell.textLabel.text = scoreDict [0] ["score"]
                let myRow = 0
                let myScore = scoreDict[0] ["score"]!
                let myPar = scoreDict[0] ["par"]!
                cell.textLabel.backgroundColor = setColor(myRow: myRow, myScore: myScore, myPar: myPar)
            default:
                print("hej")
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
    func setColor(myRow: NSInteger, myScore: String, myPar: String) -> UIColor {
        if let myScore1 = Int(myScore) {
            if let myPar1 = Int(myPar) {
                if myScore1 == myPar1 {
                    return greenColor
                }
                if myScore1 > myPar1 {
                    return blueColor
                }
                if myScore1 < myPar1 {
                    return redColor
                }
                return whiteColor
            }
            return whiteColor
        }
        return whiteColor
    }
    func aggregateInAndOut () {
        // Summera första 9 hålen
        for index in 1...9 {
            if let myCounter = Int(self.scoreDict[index] ["par"]!) {
                self.out9 ["par"] = String(Int(self.out9 ["par"]!)! + myCounter)
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
            if let myCounter = Int(self.scoreDict[index] ["score"]!) {
                self.out9 ["score"] = String(Int(self.out9 ["score"]!)! + myCounter)
            }
        }
        //summera sista 9 hålen
        for index in 10...18 {
            if let myCounter = Int(self.scoreDict[index] ["par"]!) {
                self.in9 ["par"] = String(Int(self.in9 ["par"]!)! + myCounter)
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
            if let myCounter = Int(self.scoreDict[index] ["score"]!) {
                self.in9 ["score"] = String(Int(self.in9 ["score"]!)! + myCounter)
            }
        }
        // Summera och räkna ut procent
        let out9dfwHit = Double(self.out9["fwHit"]!)! / Double(9 - out9Par3s) * 100 as Double
        self.out9["fwHit"] = String(Int(out9dfwHit)) + "%"
        let indfwHit = Double(self.in9["fwHit"]!)! / Double(9 - in9Par3s) * 100 as Double
        self.in9["fwHit"] = String(Int(indfwHit)) + "%"
        let outdgir = Double(self.out9 ["gir"]!)! / 9 * 100 as Double
        self.out9["gir"] = String(Int(outdgir)) + "%"
        let inddgir = Double(self.in9 ["gir"]!)! / 9 * 100 as Double
        self.in9["gir"] = String(Int(inddgir)) + "%"
        let dfwHit = Double(self.scoreDict [0] ["fwHit"]!)! / Double(18 - out9Par3s - in9Par3s) * 100 as Double
        self.fwHit = String(Int(dfwHit)) + "%"
        let dgir = Double(self.scoreDict [0] ["gir"]!)! / 18 * 100 as Double
        self.gir = String(Int(dgir)) + "%"
    }
}

