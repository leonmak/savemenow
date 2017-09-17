//
//  Hazard.swift
//  savemenow
//
//  Created by Edmund Mok on 9/16/17.
//  Copyright © 2017 Ming Yi Teo. All rights reserved.
//

import ArcGIS
import Foundation

typealias FeatureAttributes = [String: Any]

class Hazard {

    let barrier: AGSGeometry
    let description: String
    let type: String
    let date = Date()

    init(barrier: AGSGeometry, description: String, type: String) {
        self.barrier = barrier
        self.description = description
        self.type = type
    }

    func getAttributes() -> FeatureAttributes {
        return [
            "description": self.description,
            "type": self.type,
            "date": date
        ]
    }

}
