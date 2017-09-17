//
//  AddVC.swift
//  savemenow
//
//  Created by Leon Mak on 16/9/17.
//  Copyright © 2017 Ming Yi Teo. All rights reserved.
//

import UIKit
import ArcGIS

class AddVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerTextField : UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    var geom: AGSGeometry?
    
    let hazardTypes = ["Flood Water", "Road Block", "Toxic", "Crime", "BioHazard"]

    // Deselect text view after touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerTextField.inputView = pickerView
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hazardTypes.count

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hazardTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = hazardTypes[row]
    }

    @IBAction func addHazardBtnPressed(_ sender: Any) {
        let description = descriptionTextField.text
        let type = pickerTextField.text!
        let hazard = Hazard(barrier: self.geom!, description: description!, type: type)
        uploadHazard(hazard)
    }
    
    func uploadHazard(_ hazard: Hazard) {
        NetworkManager.sharedInstance.addHazard(hazard: hazard, completionHandler: { (result, error) in
            if let error = error {
                NSLog(error.localizedDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
