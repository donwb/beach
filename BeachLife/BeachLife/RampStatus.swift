import Foundation

// MARK: - RampStatusElement
struct RampStatusElement: Codable {
    let id: Int
    let rampName: String
    let accessStatus: AccessStatus
    let objectID: Int
    let city, accessID, location: String
}

enum AccessStatus: String, Codable {
    case accessStatusOpen = "OPEN"
    case accessStatus4X4Only = "4X4 ONLY"
    case accessStatusClosed = "CLOSED"
    case closedForHighTide = "CLOSED FOR HIGH TIDE"
    case closingInProgress = "CLOSING IN PROGRESS"
    case closedClearedForTurtles = "CLOSED - CLEARED FOR TURTLES"
    case closedAtCapacity = "CLOSED - AT CAPACITY"
}

typealias RampStatus = [RampStatusElement]
