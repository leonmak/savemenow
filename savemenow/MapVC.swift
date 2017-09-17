//
//  ViewController.swift
//  savemenow
//
//  Created by Ming Yi Teo on 16/9/17.
//  Copyright © 2017 Ming Yi Teo. All rights reserved.
//

import UIKit
import ArcGIS
import CoreLocation
import MapKit

class MapVC: UIViewController, AGSGeoViewTouchDelegate, CLLocationManagerDelegate {

    @IBOutlet var addHazardButton: UIButton!
    @IBOutlet private var mapView: AGSMapView!
    var locationManager = CLLocationManager()
    private var routeGraphicsOverlay = AGSGraphicsOverlay()


    private var lastQuery: AGSCancelable!

    private var sketchEditor = AGSSketchEditor()
    private var geometryToAdd: AGSGeometry?
    
    @IBOutlet weak var sketchToolbar: UIToolbar!
    @IBOutlet weak var redoBBI: UIBarButtonItem!
    @IBOutlet weak var undoBBI: UIBarButtonItem!
    @IBOutlet weak var clearBBI: UIBarButtonItem!

    var myAgsPoint: AGSPoint!
    
    @IBAction func onAddHazard(_ sender: UIButton) {
        if sender.titleLabel?.text == "Done" {
            self.geometryToAdd = self.sketchEditor.geometry
            performSegue(withIdentifier: "AddVC", sender: nil)
        } else {
            setupSketchEditor()
            sender.alpha = 0.75
            sender.setTitle("Done", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //instantiate map with a basemap
        let map = AGSMap(basemap: AGSBasemap.streets())

        setupLocation()

        //set initial viewpoint
        map.initialViewpoint = AGSViewpoint(center: AGSPoint(x: 544871.19, y: 6806138.66, spatialReference: AGSSpatialReference.webMercator()), scale: 2e6)

        //assign the map to the map view
        self.mapView.map = map
        //set touch delegate on map view as self
        self.mapView.touchDelegate = self

        //add the feature layer to the operational layers on map
        map.operationalLayers.add(NetworkManager.sharedInstance.featureLayer)
        
        self.mapView.sketchEditor = self.sketchEditor
        clearSketchEditor()

        getRoute()
    }

    // SETUP MAP
    func setupLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            setupLocation()
        } else if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude
        let lat = userLocation.coordinate.latitude
        updateUserLocation(lat: lat, long: long)
    }


    func updateUserLocation(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.myAgsPoint = AGSPoint(clLocationCoordinate2D: coord)
        let viewpoint = AGSViewpoint(center: myAgsPoint, scale: 2000)
        self.mapView.setViewpoint(viewpoint)
    }

    // MARK: Sketch Editor
    func clearSketchEditor() {
        self.sketchToolbar.isHidden = true
        self.sketchEditor.stop()
        self.mapView.isUserInteractionEnabled = true
        self.addHazardButton.setTitle("Add hazard", for: .normal)
    }
    
    func setupSketchEditor() {
        self.sketchToolbar.isHidden = false
        self.sketchEditor.start(with: nil, creationMode: .polygon)
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.respondToGeomChanged),
                                               name: NSNotification.Name.AGSSketchEditorGeometryDidChange, object: nil)
    }
    
    func respondToGeomChanged() {
        //Enable/disable UI elements appropriately
        self.undoBBI.isEnabled = self.sketchEditor.undoManager.canUndo
        self.redoBBI.isEnabled = self.sketchEditor.undoManager.canRedo
        self.clearBBI.isEnabled = self.sketchEditor.geometry != nil && !self.sketchEditor.geometry!.isEmpty
    }
    
    @IBAction func undo() {
        if self.sketchEditor.undoManager.canUndo {
            self.sketchEditor.undoManager.undo()
        }
    }
    
    @IBAction func redo() {
        if self.sketchEditor.undoManager.canRedo {
            self.sketchEditor.undoManager.redo()
        }
    }
    
    @IBAction func clear() {
        self.sketchEditor.clearGeometry()
    }
    
    @IBAction func doneSketching() {
    }
    // MARK: End sketchEditor

    func getRoute() {
        var barriers = [AGSPolygonBarrier]()
        let hazards = NetworkManager.sharedInstance.getHazards { result, error in
            if let error = error {
                print("Route error!")
            }

            guard let result = result else {
                assertionFailure("No results")
                return
            }

            for feature in result.featureEnumerator() {
                guard let feature = feature as? AGSFeature else {
                    assertionFailure("This feature enumerator does not return features?")
                    return
                }

                let polygon = feature.geometry
                barriers.append(AGSPolygonBarrier(polygon: feature.geometry as! AGSPolygon))
            }

            let params = AGSRouteParameters()
            params.setPolygonBarriers(barriers)
            let start = AGSStop(point: self.myAgsPoint)
            let end =  AGSStop(point: AGSPoint(x: 544871.19, y: 6806138.66, spatialReference: AGSSpatialReference.webMercator()))
            params.setStops([start, end])
            NetworkManager.sharedInstance.getRoute(fromRouteParameters: params) { (result, error) in
                print(error)
                print(result)
            }
        }
    }

    // MARK: - AGSGeoViewTouchDelegate
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        // update query
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddVC", let dest = segue.destination as? AddVC {
            dest.geom = self.geometryToAdd
            clearSketchEditor()
        }
    }
}
