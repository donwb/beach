//
//  ViewController.swift
//  BeachInfo
//
//  Created by Don Browning on 4/26/24.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var waterTempLabel: UILabel!
    @IBOutlet weak var tidePercentageLabel: UILabel!
    @IBOutlet weak var tideDirectionLabel: UILabel!
    @IBOutlet weak var twosevenLabel: UILabel!
    @IBOutlet weak var thirdaveLabel: UILabel!
    @IBOutlet weak var flaglerLabel: UILabel!
    @IBOutlet weak var crawfordLabel: UILabel!
    @IBOutlet weak var beachwayLabel: UILabel!
    @IBOutlet weak var lastStatusRefresh: UILabel!
    @IBOutlet weak var twentySeventhStatusLight: UIView!
    @IBOutlet weak var thirdaveStatusLight: UIView!
    @IBOutlet weak var flaglerStatusLight: UIView!
    @IBOutlet weak var crawfordStatusLight: UIView!
    @IBOutlet weak var beachwayStatusLight: UIView!
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusLights = [beachwayStatusLight, flaglerStatusLight, crawfordStatusLight, twentySeventhStatusLight, thirdaveStatusLight]
        setupStatusLights(statusLightArray: statusLights)
        
        lastStatusRefresh.text = "n/a"
    }
    


    @IBAction func getRampStatus(_ sender: Any) {
        
        let url = "https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus"
        let tidesURL = "https://sea-lion-app-lif8v.ondigitalocean.app/tides"
        
        callRampStatusAPI(rampsURL: url)
        
        callTideStatusAPI(tideURL: tidesURL)
    }
    
    
    func callRampStatusAPI(rampsURL: String) {
        let session = URLSession.shared
        
        guard let url = URL(string: rampsURL) else {return}
        
        session.dataTask(with: url) {data, response, error in
            if let error = error {
                print(error)
                print("oh shit!, there was an error calling the API")
            } else
            if let data = data {
                let rs: RampStatus = try! JSONDecoder().decode(RampStatus.self, from: data)
                self.updateUI(rs: rs)
    
            }
            
        }.resume()
    }
    
    func callTideStatusAPI(tideURL: String) {
        let session = URLSession.shared
        
        guard let url = URL(string: tideURL) else {return}
        
        session.dataTask(with: url) {data, response, error in
            if let error = error {
                print(error)
                print("TIDES: there was an error calling the API")
            } else
            if let data = data {
                let ts: TideStatus = try! JSONDecoder().decode(TideStatus.self, from: data)
                self.updateTideUI(tideInfo: ts)
    
            }
            
        }.resume()
    }
    
    func updateUI(rs: RampStatus) {
        DispatchQueue.main.async {
            
            self.setRampStatus(rs: rs, rampToCheck: "BEACHWAY AV", light: self.beachwayStatusLight, rampStatusLabel: self.beachwayLabel)
            self.setRampStatus(rs: rs, rampToCheck: "CRAWFORD RD", light: self.crawfordStatusLight, rampStatusLabel: self.crawfordLabel)
            self.setRampStatus(rs: rs, rampToCheck: "3RD AV", light: self.thirdaveStatusLight, rampStatusLabel: self.thirdaveLabel)
            self.setRampStatus(rs: rs, rampToCheck: "27TH AV", light: self.twentySeventhStatusLight, rampStatusLabel: self.twosevenLabel)
            self.setRampStatus(rs: rs, rampToCheck: "FLAGLER AV", light: self.flaglerStatusLight, rampStatusLabel: self.flaglerLabel)
            
            self.setRampRefreshDate()
        }
    }
    
    func updateTideUI(tideInfo: TideStatus) {
        DispatchQueue.main.async {
            
           print(tideInfo)
            self.tideDirectionLabel.text = tideInfo.currentTideHighOrLow
            self.tidePercentageLabel.text = "\(tideInfo.tideLevelPercentage)%"
            self.waterTempLabel.text = "\(tideInfo.waterTemp)°"
        }
    }
    
    func setupStatusLights(statusLightArray: [UIView?]) {
        for light in statusLightArray{
            light?.layer.cornerRadius = 12.5
            light?.backgroundColor = UIColor.gray
        }
    }
    
    func setRampStatus(rs: RampStatus, rampToCheck: String, light: UIView, rampStatusLabel: UILabel) {
        // only handling open right now
        
        if let currentRamp = rs.first(where: {$0.rampName == rampToCheck}) {
            if currentRamp.accessStatus == AccessStatus.accessStatusOpen {
                light.backgroundColor = UIColor.green
            } else {
                light.backgroundColor = UIColor.yellow
            }
            
            //textField.text = currentRamp.accessStatus.rawValue
            rampStatusLabel.text = currentRamp.accessStatus.rawValue
        }
    }
    
    func setRampRefreshDate() {
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM-dd"
        timeFormatter.dateFormat = "h:mm:ss"
        
        let formattedDate = dateFormatter.string(from: currentDateTime)
        let formattedTime = timeFormatter.string(from: currentDateTime)
        
        let timestamp = "\(formattedTime) on \(formattedDate)"
        
        lastStatusRefresh.text = timestamp
    }
    
    func printError(textField: UITextField) {
        textField.text = "Error getting status"
    }
}

