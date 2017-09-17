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
//    var polygonPoints: [AGSPoint] = []

    private var lastQuery: AGSCancelable!

    private var sketchEditor = AGSSketchEditor()
    private var geometryToAdd: AGSGeometry?
    
    @IBOutlet weak var sketchToolbar: UIToolbar!
    @IBOutlet weak var redoBBI: UIBarButtonItem!
    @IBOutlet weak var undoBBI: UIBarButtonItem!
    @IBOutlet weak var clearBBI: UIBarButtonItem!
    
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func applyEdits() {
        NetworkManager.sharedInstance.featureTable.applyEdits { (featureEditResults: [AGSFeatureEditResult]?, error: Error?) -> Void in
            if let error = error {
                NSLog(error.localizedDescription)
            } else {
                if let featureEditResults = featureEditResults, featureEditResults.count > 0 && featureEditResults[0].completedWithErrors == false {
                }
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
