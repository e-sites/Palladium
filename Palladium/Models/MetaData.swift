//
//  MetaData.swift
//  Palladium
//
//  Created by Bas van Kuijck on 10/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

public struct MetaData {
    public let id: String
    public var category: String?
    public var group: String?
    public var tags: [String] = []

    public init(id: String, category: String? = nil, group: String? = nil, tags: [String] = []) {
        self.id = id
        if group != nil && category == nil {
            fatalError("`category` should be specified in order to use a `group`")
        }
        self.category = category
        self.group = group
        self.tags = tags
    }
}

