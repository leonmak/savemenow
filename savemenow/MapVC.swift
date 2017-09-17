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

class MapVC: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!

    var centerMapOnUserLocation: Bool = true
    var updateLocationTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.map = AGSMap(basemapType: .streetsWithReliefVector, latitude: 34.057, longitude: -117.196, levelOfDetail: 17)

    }
    
    func updateUserLocation() {
        DispatchQueue.main.async {
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
