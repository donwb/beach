//
//  Item.swift
//  BeachLife
//
//  Created by Don Browning on 5/10/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
