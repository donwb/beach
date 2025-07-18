import Foundation

// MARK: - TideStatus
struct TideStatus: Codable {
    let currentTideHighOrLow: String
    let tideLevelPercentage, waterTemp: Int
    let tideInfo: [TideInfo]
    let waterTemps: [WaterTemp]
    
    var currentWaterStats: CurrentWaterStats? = nil
    
    static func computeCurrentWaterStats(tideStatus: TideStatus) -> TideStatus {
        var mutableStatus = tideStatus

        let tempsArray = mutableStatus.waterTemps.map { $0.waterTemp }
        let maxTemp = tempsArray.max() ?? 0
        let minTemp = tempsArray.min() ?? 200
        let average = tempsArray.isEmpty ? 0 : Double(tempsArray.reduce(0, +)) / Double(tempsArray.count)

        mutableStatus.currentWaterStats = CurrentWaterStats(min: minTemp, max: maxTemp, average: average, allTemps: tempsArray)
        return mutableStatus
    }
}

// MARK: - TideInfo
struct TideInfo: Codable {
    let tideDateTime: Date
    let highOrLow: String
}

struct WaterTemp: Codable {
    let stationID, stationName: String
    let waterTemp: Int
    
}

struct CurrentWaterStats: Codable {
    var min, max: Int
    var average: Double
    var allTemps: [Int]
}
