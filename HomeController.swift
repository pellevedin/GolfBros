//
//  HomeController.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-08-21.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import Firebase
import SwiftCharts

class HomeController: UIViewController {
    
    let refRounds = Database.database().reference(withPath: "users")
    var roundsDict = [[String: String]]() // övegripande rond-information
    var aggregateArray: [Double] = []
    var uid: String = "" // aktuell användar-nyckel
    var timeStamp: String = "" // nyckel
    var newRound: Bool = false
    let lastRounds = 10 // hur många rundor vi tar med i graf och statistik på öppningssidan
    var roundsIndex: NSInteger = 0
    var snapStore = DataSnapshot() // håller läsresultatet från FireBase
    let activityindicator = UIActivityIndicatorView()
    var fwHitVar: Double = 0  // räknare
    var girVar: Double = 0  // räknare
    var puttsVar: Double = 0  // räknare
    
    @IBOutlet weak var loggedInUserLabel: UILabel!
    
    // Här ska diagrammet visas
    @IBOutlet weak var myChart: UIView!
    //Deklarationer för diagrammet
    fileprivate var chart: Chart?
    @IBOutlet weak var graphLabelLeft: UILabel!
    @IBOutlet weak var grapgLabelRight: UILabel!
    
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var fwHitLabel: UILabel!
    @IBOutlet weak var girLabel: UILabel!
    @IBOutlet weak var puttsLabel: UILabel!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // vad gör denna?
       
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "GolfBros"
        // kolla vilken användare som är påloggad
        let user = Auth.auth().currentUser
        self.uid = user!.uid
        if let user = user {
            loggedInUserLabel.text = user.email
        }
        downloadRounds() { (status: Bool) in
            if !status {
                self.alert(title: "Error", message: "Something went wrong")
                return
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        // här ska vi ha kod för att stoppa listner men hur?
        self.refRounds.removeAllObservers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func downloadRounds(completion: @escaping (Bool) -> Void) {
        // I roundsDict ligger användarens övergripande rond data, nyckel är timestamp
        // I scoreDict ligger användares  resultat med timestamp som "nyckel", nyckel är timestamp
        roundsDict.removeAll() // radera roundsDict innan vi fyller på igen
        // inläsning med sortering i datumordning
        self.refRounds.child(self.uid).queryOrdered(byChild: "date").queryLimited(toLast: UInt(lastRounds)).observeSingleEvent(of: .value, with: {snapshot in
            self.snapStore = snapshot // spara undan alla ronder och rondresultat
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let mySnap = snap.value as? [String: AnyObject]
                var myDict: [String: String] = [:] // temporär dictionary
                myDict["par"] = mySnap?["0"]! ["par"] as? String // från "0" som håller totalresultat
                myDict["fwHit"] = mySnap?["0"]! ["fwHit"] as? String // från "0" som håller totalresultat
                myDict["gir"] = mySnap?["0"]! ["gir"] as? String // från "0" som håller totalresultat
                myDict["putts"] = mySnap?["0"]! ["putts"] as? String // från "0" som håller totalresultat
                myDict["score"] = mySnap?["0"]! ["score"] as? String // från "0" som håller totalresultat
                myDict["totHoles"] = mySnap?["roundsDict"]! ["totHoles"] as? String
                myDict["totPar3s"] = mySnap?["roundsDict"]! ["totPar3s"] as? String
                myDict["date"] = mySnap?["roundsDict"]! ["date"] as? String
                // addera till dictionary av ronder
                self.roundsDict.append(myDict)
            }
            self.aggregateResults()
            self.createChart()
            completion(true)
        })
    }
    func aggregateResults () {
        // skapa 3 nyckeltal för home
        let maxRounds = self.roundsDict.count
        if maxRounds == 0 {
            return
        }
        var my1: Double = 0
        var avg: Double = 0
        for index in 0...(maxRounds - 1) {
            //Räkna ut det procentuella värdet av fairway hits
            let my2 = Double(self.roundsDict [index] ["fwHit"]!)! / (Double(self.roundsDict [index] ["totHoles"]!)! - Double(self.roundsDict[index] ["totPar3s"]!)!) * 100
            // återlagra det procentuella värdet istället för antalsvärdet
            self.roundsDict [index] ["fwHit"] = String(my2)
            my1 = my1 + my2
        }
        avg = my1 / Double(maxRounds)
        self.fwHitLabel.text = String(Int(avg)) + "%"
        my1 = 0
        avg = 0
        for index in 0...(maxRounds - 1) {
            //Räkna ut det procentuella värdet av GIR
            let my2 = Double(self.roundsDict [index] ["gir"]!)! / Double(self.roundsDict[index] ["totHoles"]!)! * 100
            // återlagra det procentuella värdet istället för antalsvärdet
            self.roundsDict [index] ["gir"] = String(my2)
            my1 = my1 + my2
        }
        avg = my1 / Double(maxRounds)
        self.girLabel.text = String(Int(avg)) + "%"
        my1 = 0
        avg = 0
        for index in 0...(maxRounds - 1) {
            my1 = my1 + Double(self.roundsDict [index] ["putts"]!)!
        }
        avg = my1 / Double(maxRounds)
        self.puttsLabel.text = String(Int(avg))
        self.avgLabel.text = "Averages last " + String(maxRounds) + " rounds"
        self.graphLabelLeft.text = "Fairway Hits"
        self.graphLabelLeft.textColor = UIColor.red
        self.grapgLabelRight.text = "Greens in regulation"
        self.grapgLabelRight.textColor = UIColor.blue
        //self.trendLabel.text = "Trends last " + String(maxRounds) + " rounds"
    }
    // Generell alertfunktion
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        navigationController?.present(alertController, animated: false, completion: nil)
    }
    
    func createChart () {
        let labelSettings = ChartLabelSettings(font: GBChartsDefaults.labelFont)
        let bgColors = [UIColor.red, UIColor.blue, UIColor(red: 0, green: 0.7, blue: 0, alpha: 1), UIColor(red: 1, green: 0.5, blue: 0, alpha: 1), UIColor.black]
        // fwHits
        func createChartPointsFwHit(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(1, Double(roundsDict [0] ["fwHit"]!)!, color),
                createChartPoint(2, Double(roundsDict [1] ["fwHit"]!)!, color),
                createChartPoint(3, Double(roundsDict [2] ["fwHit"]!)!, color),
                createChartPoint(4, Double(roundsDict [3] ["fwHit"]!)!, color),
                createChartPoint(5, Double(roundsDict [4] ["fwHit"]!)!, color),
                createChartPoint(6, Double(roundsDict [5] ["fwHit"]!)!, color),
                createChartPoint(7, Double(roundsDict [6] ["fwHit"]!)!, color)
            ]
        }
        // gir
        func createChartPointsGIR(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(1, Double(roundsDict [0] ["gir"]!)!, color),
                createChartPoint(2, Double(roundsDict [1] ["gir"]!)!, color),
                createChartPoint(3, Double(roundsDict [2] ["gir"]!)!, color),
                createChartPoint(4, Double(roundsDict [3] ["gir"]!)!, color),
                createChartPoint(5, Double(roundsDict [4] ["gir"]!)!, color),
                createChartPoint(6, Double(roundsDict [5] ["gir"]!)!, color),
                createChartPoint(7, Double(roundsDict [6] ["gir"]!)!, color)
            ]
        }
        
        
        let chartPointsFwHit = createChartPointsFwHit(bgColors[4])
        let chartPointsGIR = createChartPointsGIR(bgColors[4])
        
        let xValues0 = chartPointsFwHit.map{$0.x}
        
        let chartSettings = GBChartsDefaults.chartSettingsWithPanZoom
        
        let top: CGFloat = 0
        let viewFrame = CGRect(x: 0, y: top, width: myChart.frame.size.width, height: myChart.frame.size.height - top - 10)
        
        let yValuesLeft = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPointsFwHit, minSegmentCount: 5, maxSegmentCount: 10, multiple: 20, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: GBChartsDefaults.labelFont, fontColor: bgColors[4]))}, addPaddingSegmentIfEdge: false)
        
        let yValuesRight = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPointsFwHit, minSegmentCount: 5, maxSegmentCount: 10, multiple: 20, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: GBChartsDefaults.labelFont, fontColor: bgColors[4]))}, addPaddingSegmentIfEdge: false)
        
        let axisTitleFont = GBChartsDefaults.labelFont
        
        let yModelsLeft: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValuesLeft, lineColor: bgColors[4], axisTitleLabels: [])
        ]
        let yModelsRight: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValuesRight, lineColor: bgColors[4], axisTitleLabels: [])
        ]
        let xModelsBottom: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues0, lineColor: bgColors[4], axisTitleLabels: [ChartAxisLabel(text: "Last rounds", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[4]))])
        ]
        
        // calculate coords space in the background to keep UI smooth
        DispatchQueue.global(qos: .background).async {
            
            let coordsSpace = ChartCoordsSpace(chartSettings: chartSettings, chartSize: viewFrame.size, yLowModels: yModelsLeft, yHighModels: yModelsRight, xLowModels: xModelsBottom)
            
            DispatchQueue.main.async {
                
                let chartInnerFrame = coordsSpace.chartInnerFrame
                
                // create axes
                let yAxesLeft = coordsSpace.yLowAxesLayers
                let yAxesRight = coordsSpace.yHighAxesLayers
                let xAxesBottom = coordsSpace.xLowAxesLayers
                
                // create layers with references to axes and with colors
                let lineModelFwHit = ChartLineModel(chartPoints: chartPointsFwHit, lineColor: bgColors[0], animDuration: 1, animDelay: 0)
                let lineModelGIR = ChartLineModel(chartPoints: chartPointsGIR, lineColor: bgColors[1], animDuration: 1, animDelay: 0)
                
                let chartPointsLineLayerFwHit = ChartPointsLineLayer<ChartPoint>(xAxis: xAxesBottom[0].axis, yAxis: yAxesLeft[0].axis, lineModels: [lineModelFwHit])
                let chartPointsLineLayerGIR = ChartPointsLineLayer<ChartPoint>(xAxis: xAxesBottom[0].axis, yAxis: yAxesLeft[0].axis, lineModels: [lineModelGIR])
                
                let lineLayers = [chartPointsLineLayerFwHit, chartPointsLineLayerGIR]

                
                let layers: [ChartLayer] = [
                    yAxesLeft[0], xAxesBottom[0], yAxesRight[0],
                    lineLayers[0], lineLayers[1]
                    ]
                
                let chart = Chart(
                    frame: viewFrame,
                    innerFrame: chartInnerFrame,
                    settings: chartSettings,
                    layers: layers
                )
                self.myChart.addSubview(chart.view)
                self.chart = chart
            }
        }
    }
    
    fileprivate func createChartPoint(_ x: Double, _ y: Double, _ labelColor: UIColor) -> ChartPoint {
        let labelSettings = ChartLabelSettings(font: GBChartsDefaults.labelFont, fontColor: labelColor)
        return ChartPoint(x: ChartAxisValueDouble(x, labelSettings: labelSettings), y: ChartAxisValueDouble(y, labelSettings: labelSettings))
    }
}
  

