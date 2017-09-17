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

    @IBOutlet var addHazardButton: UIButton!
    @IBOutlet private var mapView: AGSMapView!
    var polygonPoints: [AGSPoint] = []

    private var lastQuery: AGSCancelable!

    @IBAction func onAddHazard(_ sender: UIButton) {
        if !sender.isEnabled {
            return
        }
        if sender.titleLabel?.text == "Done" {
            //disable interaction with map view
            self.mapView.isUserInteractionEnabled = false
            //add a feature at the tapped location
            let hazard = createHazard()
            NetworkManager.sharedInstance.addHazard(hazard: hazard) { (result, error) in
                if let error = error {

                } else {

                }
                //enable interaction with map view
                self.mapView.isUserInteractionEnabled = true
                self.addHazardButton.setTitle("Add hazard", for: .normal)
                self.polygonPoints = []
            }
        } else {
            sender.isEnabled = false
            sender.alpha = 0.5
            sender.setTitle("Done", for: .normal)
        }
    }
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

    func createHazard() -> Hazard {
        let polygon = AGSPolygon(points: polygonPoints)
        //normalize geometry
        let normalizedGeometry = AGSGeometryEngine.normalizeCentralMeridian(of: polygon)!
        //attributes for the new feature
        let hazard = Hazard(barrier: polygon,
                            description: "abc", type: "123")
        return hazard
    }

    // MARK: - AGSGeoViewTouchDelegate

    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        polygonPoints.append(mapPoint)
        if polygonPoints.count > 2 {
            addHazardButton.isEnabled = true
            addHazardButton.alpha = 1
        }
    }
}
