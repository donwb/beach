//
//  RampStatus.swift
//  BeachInfo
//
//  Created by Don Browning on 4/26/24.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let rampStatus = try? JSONDecoder().decode(RampStatus.self, from: jsonData)


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
}

typealias RampStatus = [RampStatusElement]
