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
