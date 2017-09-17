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

protocol Network {

    var featureTable: AGSServiceFeatureTable! {get set}
    var featureLayer: AGSFeatureLayer! {get set}

    func getHazards()

    func addHazard(hazard: Hazard, completionHandler: @escaping CompletionHandler)

    func delete(hazard: AGSFeature, completionHandler: @escaping CompletionHandler)

    func getRoute()

}

class NetworkManager: Network {

    static let sharedInstance = NetworkManager()
    var featureTable: AGSServiceFeatureTable!
    var featureLayer: AGSFeatureLayer!

    private init() {
        //instantiate service feature table using the url to the service
        self.featureTable = AGSServiceFeatureTable(url: URL(string: "https://services5.arcgis.com/P8eoqXPWOi74mr8K/arcgis/rest/services/hazards/FeatureServer/0")!)
        //create a feature layer using the service feature table
        self.featureLayer = AGSFeatureLayer(featureTable: self.featureTable)

    }

    func getHazards() {

    }

    func addHazard(hazard: Hazard, completionHandler: @escaping CompletionHandler) {
        let featureAttributes = ["description": hazard.description,
                                "type": hazard.type]
        //create a new feature
        let feature = NetworkManager.sharedInstance.featureTable.createFeature(attributes: featureAttributes, geometry: nil)

        //add the feature to the feature table
        NetworkManager.sharedInstance.featureTable.add(feature) { error in completionHandler(nil, error) }

    }

    func delete(hazard: AGSFeature, completionHandler: @escaping CompletionHandler) {
        self.featureTable.delete(hazard) { [weak self] error in
            if let error = error {
                return completionHandler(nil, error)
            }

            self?.applyEdits(completionHandler: completionHandler)
        }
    }

    private func applyEdits(completionHandler: @escaping CompletionHandler) {
        self.featureTable.applyEdits { (result, error) in completionHandler(result, error) }
    }

    func getRoute() {

    }

}
