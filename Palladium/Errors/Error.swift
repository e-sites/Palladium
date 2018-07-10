//
//  PalladiumError.swift
//  Palladium
//
//  Created by Bas van Kuijck on 10/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

public enum Error: Swift.Error {
    case notAuthorized
    case dateInPast
    case underlying(Swift.Error)
}
