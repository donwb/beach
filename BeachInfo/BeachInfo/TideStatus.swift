// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let tideStatus = try? JSONDecoder().decode(TideStatus.self, from: jsonData)

import Foundation

// MARK: - TideStatus
struct TideStatus: Codable {
    let currentTideHighOrLow: String
    let tideLevelPercentage, waterTemp: Int
    //let tideInfo: [TideInfo]
}

// MARK: - TideInfo
struct TideInfo: Codable {
    let tideDateTime: Date
    let highOrLow: String
}
