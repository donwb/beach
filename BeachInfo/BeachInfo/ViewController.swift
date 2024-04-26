//
//  ViewController.swift
//  BeachInfo
//
//  Created by Don Browning on 4/26/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var twentySeventhStatus: UITextField!
    @IBOutlet weak var thirdaveStatus: UITextField!
    @IBOutlet weak var flaglerStatus: UITextField!
    @IBOutlet weak var crawfordStatus: UITextField!
    @IBOutlet weak var beachwayStatus: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            if let beachway = rs.first(where: {$0.rampName == "BEACHWAY AV"}){
                self.beachwayStatus.text = beachway.accessStatus.rawValue
            } else {
                self.printError(textField: self.beachwayStatus)
            }
            
            
            if let crawford = rs.first(where: {$0.rampName == "CRAWFORD RD"}) {
                self.crawfordStatus.text = crawford.accessStatus.rawValue
            } else {
                self.printError(textField: self.crawfordStatus)
            }
            
            
            if let third = rs.first(where: {$0.rampName == "3RD AV"}) {
                self.thirdaveStatus.text = third.accessStatus.rawValue
            } else {
                self.printError(textField: self.thirdaveStatus)
            }
            
            
            if let twoseven = rs.first(where: {$0.rampName == "27TH AV"}) {
                self.twentySeventhStatus.text = twoseven.accessStatus.rawValue
            } else {
                self.printError(textField: self.twentySeventhStatus)
            }
            
            
            if let flagler = rs.first(where: {$0.rampName == "FLAGLER AV"}) {
                self.flaglerStatus.text = flagler.accessStatus.rawValue
            } else {
                self.printError(textField: self.flaglerStatus)
            }
            
            
        }
    }
    
    func printError(textField: UITextField) {
        textField.text = "Error getting status"
    }
}

