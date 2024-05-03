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
         var maxTemp = 0
         var minTemp = 200
         var tempsArray = [Int]()
         
         
         for temp in mutableStatus.waterTemps {
             
            if temp.waterTemp > maxTemp {
                maxTemp = temp.waterTemp
            }
            if temp.waterTemp < minTemp {
                minTemp = temp.waterTemp
            }
             tempsArray.append(temp.waterTemp)
        }
         
         let sum = tempsArray.reduce(0, +)
         let average = tempsArray.isEmpty ? 0 : Double(sum) / Double(tempsArray.count)

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
