//
//  ViewController.swift
//  BeachInfo
//
//  Created by Don Browning on 4/26/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var twentySeventhStatusLight: UIView!
    @IBOutlet weak var thirdaveStatusLight: UIView!
    @IBOutlet weak var flaglerStatusLight: UIView!
    @IBOutlet weak var crawfordStatusLight: UIView!
    @IBOutlet weak var beachwayStatusLight: UIView!
    @IBOutlet weak var twentySeventhStatus: UITextField!
    @IBOutlet weak var thirdaveStatus: UITextField!
    @IBOutlet weak var flaglerStatus: UITextField!
    @IBOutlet weak var crawfordStatus: UITextField!
    @IBOutlet weak var beachwayStatus: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // label.layer.cornerRadius = label.frame.size.width/2
        let statusLights = [beachwayStatusLight, flaglerStatusLight, crawfordStatusLight, twentySeventhStatusLight, thirdaveStatusLight]
        setupStatusLights(statusLightArray: statusLights)
        
        
    }
    


    @IBAction func getRampStatus(_ sender: Any) {
        
        let url = "https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus"
        // let rampStatus = try? JSONDecoder().decode(RampStatus.self, from: jsonData)
        
        
        callRampStatusAPI(rampsURL: url)
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
    
    func updateUI(rs: RampStatus) {
        DispatchQueue.main.async {
            
            self.setRampStatus(rs: rs, rampToCheck: "BEACHWAY AV", light: self.beachwayStatusLight, textField: self.beachwayStatus)
            self.setRampStatus(rs: rs, rampToCheck: "CRAWFORD RD", light: self.crawfordStatusLight, textField: self.crawfordStatus)
            self.setRampStatus(rs: rs, rampToCheck: "3RD AV", light: self.thirdaveStatusLight, textField: self.thirdaveStatus)
            self.setRampStatus(rs: rs, rampToCheck: "27TH AV", light: self.twentySeventhStatusLight, textField: self.twentySeventhStatus)
            self.setRampStatus(rs: rs, rampToCheck: "FLAGLER AV", light: self.flaglerStatusLight, textField: self.flaglerStatus)
            
        }
    }
    
    func setupStatusLights(statusLightArray: [UIView?]) {
        for light in statusLightArray{
            light?.layer.cornerRadius = 12.5
            light?.backgroundColor = UIColor.gray
        }
    }
    
    func setRampStatus(rs: RampStatus, rampToCheck: String, light: UIView, textField: UITextField) {
        // only handling open right now
        
        if let currentRamp = rs.first(where: {$0.rampName == rampToCheck}) {
            if currentRamp.accessStatus == AccessStatus.accessStatusOpen {
                light.backgroundColor = UIColor.green
            } else {
                light.backgroundColor = UIColor.yellow
            }
            
            textField.text = currentRamp.accessStatus.rawValue
        }
    }
    
    func printError(textField: UITextField) {
        textField.text = "Error getting status"
    }
}

