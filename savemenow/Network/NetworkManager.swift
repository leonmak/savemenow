//
//  NetworkManager.swift
//  savemenow
//
//  Created by Edmund Mok on 9/16/17.
//  Copyright © 2017 Ming Yi Teo. All rights reserved.
//

import Foundation
import ArcGIS

typealias CompletionHandler = ([AGSFeatureEditResult]?, Error?) -> Void
typealias RoutingCompletionHandler = (AGSRouteResult?,  Error?) -> Void

protocol Network {

    var featureTable: AGSServiceFeatureTable! {get set}
    var featureLayer: AGSFeatureLayer! {get set}

    func getHazards()

    func addHazard(hazard: Hazard, completionHandler: @escaping CompletionHandler)

    func delete(hazard: AGSFeature, completionHandler: @escaping CompletionHandler)

    func getRoute(fromRouteParameters: AGSRouteParameters, completionHandler: @escaping RoutingCompletionHandler)
}

class NetworkManager: Network {

    let routeTask = AGSRouteTask(url: Constants.routingURL)
    static let sharedInstance = NetworkManager()
    var featureTable: AGSServiceFeatureTable!
    var featureLayer: AGSFeatureLayer!

    private init() {
        //instantiate service feature table using the url to the service
        self.featureTable = AGSServiceFeatureTable(url: Constants.hazardURL)
        //create a feature layer using the service feature table
        self.featureLayer = AGSFeatureLayer(featureTable: self.featureTable)

    }

    func getHazards() {

    }

    func addHazard(hazard: Hazard, completionHandler: @escaping CompletionHandler) {
        let featureAttributes = hazard.getAttributes()
        //create a new feature
        let feature = NetworkManager.sharedInstance.featureTable.createFeature(attributes: featureAttributes, geometry: nil)

        //add the feature to the feature table
        NetworkManager.sharedInstance.featureTable.add(feature) { (error) in
            if let error = error {

            } else {
                self.applyEdits(completionHandler: completionHandler)
            }
        }

    }

    func delete(hazard: AGSFeature, completionHandler: @escaping CompletionHandler) {
        self.featureTable.delete(hazard) { [weak self] error in
            if let error = error {
                return completionHandler(nil, error)
            }

            self?.featureTable.applyEdits(completion: completionHandler)
        }
    }


    func getRoute(fromRouteParameters routeParameters: AGSRouteParameters, completionHandler: @escaping RoutingCompletionHandler) {
        self.routeTask.solveRoute(with: routeParameters, completion: completionHandler)
    }

}
