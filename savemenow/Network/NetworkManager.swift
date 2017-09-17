//
//  NetworkManager.swift
//  savemenow
//
//  Created by Edmund Mok on 9/16/17.
//  Copyright © 2017 Ming Yi Teo. All rights reserved.
//

import Foundation
import ArcGIS

typealias CompletionHandler = (Error?) -> Void

protocol Network {

    func getHazards()

    func addHazard(hazard: Hazard, completionHandler: CompletionHandler)

    func delete(hazard: Hazard, completionHandler: CompletionHandler)

    func getRoute()

}

class NetworkManager: Network {

    func getHazards() {

    }

    func addHazard(hazard: Hazard, completionHandler: CompletionHandler) {
        <#code#>
    }

    func delete(hazard: Hazard, completionHandler: CompletionHandler) {
        <#code#>
    }

    func getRoute() {

    }

}
