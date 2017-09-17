//
//  ViewController.swift
//  savemenow
//
//  Created by Ming Yi Teo on 16/9/17.
//  Copyright © 2017 Ming Yi Teo. All rights reserved.
//

import UIKit
import ArcGIS
import MapKit

class MapVC: UIViewController, AGSGeoViewTouchDelegate {

    @IBOutlet private var mapView: AGSMapView!

    private var lastQuery: AGSCancelable!

    override func viewDidLoad() {
        super.viewDidLoad()

        //instantiate map with a basemap
        let map = AGSMap(basemap: AGSBasemap.streets())
        //set initial viewpoint
        map.initialViewpoint = AGSViewpoint(center: AGSPoint(x: 544871.19, y: 6806138.66, spatialReference: AGSSpatialReference.webMercator()), scale: 2e6)

        //assign the map to the map view
        self.mapView.map = map
        //set touch delegate on map view as self
        self.mapView.touchDelegate = self

        //add the feature layer to the operational layers on map
        map.operationalLayers.add(NetworkManager.sharedInstance.featureLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

       func applyEdits() {
        NetworkManager.sharedInstance.featureTable.applyEdits { (featureEditResults: [AGSFeatureEditResult]?, error: Error?) -> Void in
            if let error = error {

            } else {
                if let featureEditResults = featureEditResults, featureEditResults.count > 0 && featureEditResults[0].completedWithErrors == false {
                }
            }
        }
    }

    func createHazard(at mappoint: AGSPoint) -> Hazard {
        //normalize geometry
        let normalizedGeometry = AGSGeometryEngine.normalizeCentralMeridian(of: mappoint)!
        //attributes for the new feature
        let hazard = Hazard(description: "testing", type: "test2")
        return hazard
    }

    // MARK: - AGSGeoViewTouchDelegate

    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        //disable interaction with map view
        self.mapView.isUserInteractionEnabled = false

        //add a feature at the tapped location
        let hazard = createHazard(at: mapPoint)
        NetworkManager.sharedInstance.addHazard(hazard: hazard) { (error) in
            if let error = error {

            } else {

            }
            //enable interaction with map view
            self.mapView.isUserInteractionEnabled = true
        }
    }

}
