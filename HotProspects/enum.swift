//
//  enum.swift
//  HotProspects
//
//  Created by sovanmakara on 10/6/26.
//

import Foundation

enum FilterType {
    case none, contacted, uncontacted
}

enum SortType: String, CaseIterable {
    case name = "Name"
    case recent = "Most Recent"
}
