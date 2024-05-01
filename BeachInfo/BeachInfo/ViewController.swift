//
//  ViewController.swift
//  BeachInfo
//
//  Created by Don Browning on 4/26/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tidesTable: UITableView!
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
  
    var tideInfoArray: [TideInfo]!
    let cellReuseIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tidesTable.dataSource = self
        tidesTable.delegate = self
        
        tidesTable.register(TideInfoTableViewCell.self, forCellReuseIdentifier: "CustomCell")

        // Register your custom UITableViewCell if needed
        // tableView.register(YourCustomCellClass.self, forCellReuseIdentifier: "CellIdentifier")
        
        let statusLights = [beachwayStatusLight, flaglerStatusLight, crawfordStatusLight, twentySeventhStatusLight, thirdaveStatusLight]
        setupStatusLights(statusLightArray: statusLights)
        
        lastStatusRefresh.text = "n/a"
    }
    


    @IBAction func getRampStatus(_ sender: Any) {
        
        let url = "https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus"
        let tidesURL = "https://sea-lion-app-lif8v.ondigitalocean.app/tides"
        
        refreshStatusLights()
        refreshLabels()
        
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
                self.printError(errorLabel: self.beachwayLabel, errorMessage: "Error getting ramp status")
            } else
            if let data = data {
                do {
                    let rs: RampStatus = try JSONDecoder().decode(RampStatus.self, from: data)
                    self.updateUI(rs: rs)
                } catch {
                    self.printError(errorLabel: self.beachwayLabel, errorMessage: "Error: Decoding Ramps")
                }
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
                self.printError(errorLabel: self.crawfordLabel, errorMessage: "Error getting tide status")
            } else
            if let data = data {
                do {
                    // have to set the decoding strategy to .iso8601 to support timezone offsets
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let ts: TideStatus = try decoder.decode(TideStatus.self, from: data)
                    self.updateTideUI(tideInfo: ts)
                } catch  {
                    print(error)
                    self.printError(errorLabel: self.crawfordLabel, errorMessage: "Error: Decoding Tides")
                }
                
    
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
            
            self.tideInfoArray = tideInfo.tideInfo
            self.tidesTable.reloadData()
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
            switch currentRamp.accessStatus {
            case AccessStatus.accessStatusOpen:
                light.backgroundColor = UIColor.green
            case AccessStatus.accessStatus4X4Only, AccessStatus.closingInProgress:
                light.backgroundColor = UIColor.yellow
            case AccessStatus.accessStatusClosed, AccessStatus.closedForHighTide:
                light.backgroundColor = UIColor.red
            }
        
            let ucaseMessage = currentRamp.accessStatus.rawValue
            let msg = ucaseMessage.capitalized
            
            //textField.text = currentRamp.accessStatus.rawValue
            rampStatusLabel.text = msg
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
        
        let timestamp = "Last Refresh: \(formattedTime)"
        
        lastStatusRefresh.text = timestamp
    }
    
    func printError(errorLabel: UILabel, errorMessage: String) {
        errorLabel.text = errorMessage
    }
    
    func refreshStatusLights() {
        let statusLights = [beachwayStatusLight, flaglerStatusLight, crawfordStatusLight, twentySeventhStatusLight, thirdaveStatusLight]
        for light in statusLights {
            light?.backgroundColor = UIColor.white
        }
    }
    
    func refreshLabels() {
        let labels = [beachwayLabel, crawfordLabel, thirdaveLabel, twosevenLabel, flaglerLabel]
        for l in labels {
            l?.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tideInfoArray != nil {
            return tideInfoArray.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! TideInfoTableViewCell
        //let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        let cell:TideInfoTableViewCell = self.tidesTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TideInfoTableViewCell
        
        // Configure the cell
        let tideDateFormatter = DateFormatter()
        tideDateFormatter.timeStyle = .short
        let formattedDate = tideDateFormatter.string(from: tideInfoArray[indexPath.row].tideDateTime)
        
        cell.tableTideDirectionLabel?.text = "Hi"
        cell.tableTideTimeLabel?.text = formattedDate
        
        return cell
    }

    // MARK: - UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle row selection if needed
        print("You tapped cell number \(indexPath.row).")
    }
}

