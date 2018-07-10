//
//  Constants.swift
//  Palladium
//
//  Created by Bas van Kuijck on 10/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

enum Constant {
    enum Key: String {
        case id
        case category
        case group
        case tags

        var name: String {
            return "__palladium:\(self.rawValue)"
        }
    }
}
