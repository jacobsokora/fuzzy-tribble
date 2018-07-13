//
//  SearchScope.swift
//  Documents
//
//  Created by Jacob Sokora on 7/12/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import Foundation

enum SearchScope: String {
    case all
    case name
    case content
    
    static var titles: [String] {
        get {
            return [SearchScope.all.rawValue,
                    SearchScope.name.rawValue,
                    SearchScope.content.rawValue]
        }
    }
    
    static var scopes: [SearchScope] {
        get {
            return [SearchScope.all,
                    SearchScope.name,
                    SearchScope.content]
        }
    }
}
