//
//  Prospect.swift
//  HotProspects
//
//  Created by sovanmakara on 8/6/26.
//

import SwiftData
import Foundation

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    var createdAt: Date
    
    init(
        name: String = "Anonymous",
        emailAddress: String = "",
        isContacted: Bool = false,
        createdAt: Date = .now
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
        self.createdAt = createdAt
    }
}
