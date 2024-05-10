//
//  ContentView.swift
//  BeachLife
//
//  Created by Don Browning on 5/10/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var clickCount = 0
    @State private var beachwayStatusText: String = "...."
    @State private var crawfordStatusText: String = "...."
    @State private var flaglerStatusText: String = "...."
    @State private var thirdStatusText: String = "...."
    @State private var twentyStatusText: String = "...."
    
    @State private var beachwayLightColor: Color = .gray
    @State private var crawfordLightColor: Color = .gray
    @State private var flaglerLightColor: Color = .gray
    @State private var thirdLightColor: Color = .gray
    @State private var twentyLightColor: Color = .gray

    var body: some View {
    
        VStack(alignment: .leading) {
            HStack(alignment:.top) {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(beachwayLightColor)
                Text("Beachway")
                Text(beachwayStatusText)
                Spacer()
                
            }
            HStack() {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(crawfordLightColor)
                Text("Crawford")
                Text(crawfordStatusText)
                
            }
            HStack() {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(flaglerLightColor)
                Text("Flagler")
                Text(flaglerStatusText)
                
            }
            HStack() {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(thirdLightColor)
                Text("3rd Ave")
                Text(thirdStatusText)
                
            }
            HStack() {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(twentyLightColor)
                Text("27th Ave")
                Text(twentyStatusText)
                
            }
            Spacer()
            Button(action: {
                //incrementCounter()
                callTidesAPI()
                }) {
                    Text("Refresh")
                        .padding() // Adds padding around the text
                        .background(Color.blue) // Sets background color of the button
                        .foregroundColor(.white) // Sets text color
                        .cornerRadius(8) // Rounds the corners of the button background
                }
            Spacer()
        } .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func incrementCounter() {
        self.clickCount += 1
        print("Clicked \(self.clickCount) times!")
    }
    
   
    private func callTidesAPI() {
        let url = "https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus"
        
        let session = URLSession.shared
        
        guard let url = URL(string: url) else {return}
        
        session.dataTask(with: url) {data, response, error in
            if let error = error {
                print(error)
                print("oh shit!, there was an error calling the API")
                //self.printError(errorLabel: self.beachwayLabel, errorMessage: "Error getting ramp status")
                
            } else
            if let data = data {
                do {
                    let rs: RampStatus = try JSONDecoder().decode(RampStatus.self, from: data)
                    print("got the return, now do stuff")
                    updateRampsUI(rs: rs)
                } catch {
                    print("Error decoding ramps")
                    //self.printError(errorLabel: self.beachwayLabel, errorMessage: "Error: Decoding Ramps")
                }
            } else {
                print("data was not actually equal to data")
            }
            
        }.resume()
    }
    
    private func setRampStatus(_ rs: RampStatus, _ rampToCheck: String, accessStatusMessage: String) {
        if let currentRamp = rs.first(where: {$0.rampName == rampToCheck}) {
            print(rampToCheck)
            if currentRamp.accessStatus == AccessStatus.accessStatusOpen {
                self.beachwayLightColor = .green
            } else {
                self.beachwayLightColor = .red
            }
        }
    }
    
    private func getRampStatus(rs: RampStatus, rampToFind: String) -> (statusLabel: String, statusColor: Color) {
        if let currentRamp = rs.first(where: {$0.rampName == rampToFind}) {
            print("Found \(rampToFind)")
            var statusLightColor: Color = .indigo
            
            switch currentRamp.accessStatus {
            case AccessStatus.accessStatusOpen:
                statusLightColor = .green
            case AccessStatus.accessStatus4X4Only, AccessStatus.closingInProgress:
                statusLightColor = .yellow
            case AccessStatus.accessStatusClosed, AccessStatus.closedForHighTide, AccessStatus.closedAtCapacity, AccessStatus.closedClearedForTurtles:
                statusLightColor = .red
            }
            
            return (currentRamp.accessStatus.rawValue, statusLightColor)
        }
        return ("Eeek...", .black)
    }
    
    private func updateRampsUI(rs: RampStatus) {
        
        var currentRampInfo = getRampStatus(rs: rs, rampToFind: "BEACHWAY AV")
        self.beachwayLightColor = currentRampInfo.statusColor
        self.beachwayStatusText = currentRampInfo.statusLabel
        
        currentRampInfo = getRampStatus(rs: rs, rampToFind: "CRAWFORD RD")
        self.crawfordLightColor = currentRampInfo.statusColor
        self.crawfordStatusText = currentRampInfo.statusLabel
        
        currentRampInfo = getRampStatus(rs: rs, rampToFind: "FLAGLER AV")
        self.flaglerLightColor = currentRampInfo.statusColor
        self.flaglerStatusText = currentRampInfo.statusLabel
        
        currentRampInfo = getRampStatus(rs: rs, rampToFind: "3RD AV")
        self.thirdLightColor = currentRampInfo.statusColor
        self.thirdStatusText = currentRampInfo.statusLabel
        
        currentRampInfo = getRampStatus(rs: rs, rampToFind: "27TH AV")
        self.twentyLightColor = currentRampInfo.statusColor
        self.twentyStatusText = currentRampInfo.statusLabel
       
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
