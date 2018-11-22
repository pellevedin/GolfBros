//
//  RoundsController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-10-29.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase

class RoundsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let refRounds = Database.database().reference(withPath: "users")
    var roundsDict = [[String: String]]() // övegripande rond-information
    var scoreDict = [[String: String]]() // score-info, alltid 1+18 hål, summor i första posten
    var allScores = [[String: String]]()
    let lastRounds = 10 // hur många rundor vi tar med i graf och statistik på öppningssidan
    var uid: String = "" // aktuell användar-nyckel
    var timeStamp: String = "" // nyckel
    var newRound: Bool = false
    var roundsIndex: NSInteger = 0
    var snapStore = DataSnapshot() // håller läsresultatet från FireBase
    let activityindicator = UIActivityIndicatorView()

    @IBOutlet weak var golfCourse: UITextField!
    @IBOutlet weak var strokesGained: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func newRoundButton(_ sender: UIButton) {
        self.newRound = true
        createNewRound()
    }
    // Här startar vi
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // kolla vilken användare som är påloggad
        let user = Auth.auth().currentUser
        self.uid = user!.uid
        date.text = todaysDate() // anropa funktion för att hämta dagens datum
        activityindicator.startAnimating()
        downloadRounds() { (status: Bool) in
            if !status {
                self.alert(title: "Error", message: "Something went wrong")
            }
            self.activityindicator.stopAnimating()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.reloadData()
        //print(scoreDict)
    }
    override func viewWillDisappear(_ animated: Bool) {
        // här ska vi ha kod för att stoppa listner men hur?
        self.refRounds.removeAllObservers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Hantera tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.timeStamp = roundsDict [indexPath.row] ["timeStamp"]!
        self.roundsIndex = indexPath.row // håll reda på vilken rad som selekterats
        self.performSegue(withIdentifier: "showInfo", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roundsDict.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "roundsTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        // populera celler med data från roundsDict
        let myPar = self.roundsDict [indexPath.row] ["par"]
        let myScore = self.roundsDict [indexPath.row] ["score"]
        let myTextLabel = self.roundsDict [indexPath.row] ["date"]! + ", Par: " + myPar! + ", Score: " + myScore!
        cell.textLabel?.text = myTextLabel
        let myDetailTextLabel = self.roundsDict [indexPath.row] ["golfCourse"]! + " (" + self.roundsDict [indexPath.row] ["strokesGained"]! + " strokes gained)"
        cell.detailTextLabel?.text = myDetailTextLabel
        cell.accessoryType = UITableViewCell.AccessoryType.detailButton
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.timeStamp = roundsDict [indexPath.row] ["timeStamp"]! // kom ihåg vilken timestamp/nyckel som valts
        self.newRound = false // Denna rond finns sedan tidigare
        self.roundsIndex = indexPath.row // håll reda på vilken rad som selekterats
        self.performSegue(withIdentifier: "showRound", sender: self)
    }
    // hantera förberedelse inför segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRound" {
            let targetVC = segue.destination as! PlayController
            // sätt parametrar i PlayControllern
            targetVC.uid = self.uid
            // Kolla om ny rond eller inte
            if newRound {
                // sätt data i targetVC
                targetVC.scoreDict = self.scoreDict
                targetVC.golfCourse = self.golfCourse.text!
                targetVC.date = self.date.text!
                targetVC.strokesGained = self.strokesGained.text!
                targetVC.timeStamp = self.timeStamp
            }
            else {
                // sätt data i targetVC, hämta från snapStore med alla ronder
                getScoreDict() // här hämtas rätt rond från snapStore
                targetVC.scoreDict = self.scoreDict
                targetVC.golfCourse = self.roundsDict[self.roundsIndex] ["golfCourse"]!
                targetVC.date = self.roundsDict[self.roundsIndex] ["date"]!
                targetVC.strokesGained = self.roundsDict[self.roundsIndex] ["strokesGained"]!
                targetVC.timeStamp = self.timeStamp
            }
        }
        if segue.identifier == "showInfo" {
            let targetVC = segue.destination as! PlayInfoController
            // sätt parametrar i PlayInfoControllern
            targetVC.uid = self.uid
            targetVC.golfCourse = self.roundsDict[self.roundsIndex] ["golfCourse"]!
            targetVC.date = self.roundsDict[self.roundsIndex] ["date"]!
            getScoreDict()
            targetVC.scoreDict = self.scoreDict
        }
    }
    // här skapas ny rond, lagras i FireBase
    func createNewRound() {
        // Skapa nyckel för ny rond dvs timestamp
        self.timeStamp = generateTimestamp()
        // sätt  ett blankt resultatset med myScore
        self.scoreDict.removeAll()
        let myTemp = ["par": "not set", "fwHit": "not set", "gir": "not set", "putts": "not set", "score": "not set"]
        // uppdatera db för timestamp med blankt resultat
        var myHolenr: String = ""
        var myNode: String = ""
        for index in 0...18 {
            // bygg upp scoreDict
            self.scoreDict.append(myTemp)
            // skapa data dill db
            myHolenr = String(index)
            // bygg sträng timestamp / hålnr
            myNode = self.timeStamp + "/" + myHolenr
            // uppdatera db för timestamp och hålnr med blankt resultat
            self.refRounds.child(self.uid).child(myNode).setValue(myTemp)
        }
        // skapa roundinformation
        let myRound = ["golfCourse": self.golfCourse.text!,
                       "strokesGained": self.strokesGained.text!,
                       "date": self.date.text!,
                       "totHoles": "0",
                       "totPar3s": "0"
                       ] as [String : Any]
        // Uppdatera db för timestamp med rondinformation
        self.refRounds.child(self.uid).child(self.timeStamp).child("roundsDict").setValue(myRound)
        // anropa den nya viewcontroller
        self.performSegue(withIdentifier: "showRound", sender: self)
    }
    // här hämtas data från FireBase, lagras i roundsDict och snapStore
    func downloadRounds(completion: @escaping (Bool) -> Void) {
        // I roundsDict ligger användarens övergripande rond data, nyckel är timestamp
        // I scoreDict ligger användares  resultat med timestamp som "nyckel", nyckel är timestamp
        roundsDict.removeAll() // radera roundsDict innan vi fyller på igen
        // inläsning med sortering i datumordning och endast de 100 sista dvs de 100 senaste ronderna
        self.refRounds.child(self.uid).queryOrdered(byChild: "date").queryLimited(toLast: UInt(lastRounds)).observeSingleEvent(of: .value, with: {snapshot in
            self.snapStore = snapshot // spara undan alla ronder och rondresultat
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let mySnap = snap.value as? [String: AnyObject]
                var myDict: [String: String] = [:] // temporär dictionary
                myDict["par"] = mySnap?["0"]! ["par"] as? String // från "0" som håller totalresultat
                myDict["score"] = mySnap?["0"]! ["score"] as? String // från "0" som håller totalresultat
                myDict["timeStamp"] = snap.key // vi behöver nyckeln :)
                myDict["golfCourse"] = mySnap?["roundsDict"]! ["golfCourse"] as? String
                myDict["strokesGained"] = mySnap?["roundsDict"]! ["strokesGained"] as? String
                myDict["date"] = mySnap?["roundsDict"]! ["date"] as? String
                // addera till dictionary av ronder
                self.roundsDict.insert(myDict, at: 0)
            }
            self.tableView.reloadData()
            completion(true)
        })
    }
    // Diverse supportfunktioner
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        navigationController?.present(alertController, animated: false, completion: nil)
    }
    func generateTimestamp() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return (formatter.string(from: today)) as String
    }
    func todaysDate() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return (formatter.string(from: today)) as String
    }
    func getScoreDict() {
        self.scoreDict.removeAll()
        for child in self.snapStore.children {
            let snap = child as! DataSnapshot
            let mySnap = snap.value as? [String: AnyObject]
            let myTimeStamp = snap.key
            var myDict: [String: String] = [:] // temporär dictionary
            // kolla om det är den child vi vill ha
            if myTimeStamp == self.timeStamp {
                for index in 0...18 {
                    let stringIndex = String(index)
                    myDict["par"] = mySnap?[stringIndex]! ["par"] as? String
                    myDict["fwHit"] = mySnap?[stringIndex]! ["fwHit"] as? String
                    myDict["gir"] = mySnap?[stringIndex]! ["gir"] as? String
                    myDict["putts"] = mySnap?[stringIndex]! ["putts"] as? String
                    myDict["score"] = mySnap?[stringIndex]! ["score"] as? String
                    self.scoreDict.append(myDict)
                }
            }
        }
    }
}
