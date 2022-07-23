//
//  ViewController.swift
//  where_I_am
//
//  Created by Paul Rosset on 16/07/2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var InfosView: UIStackView!
    @IBOutlet weak var LocationDescription: UILabel!

    let locationManager = CLLocationManager()
    var lat: Double = 0.0
    var long: Double = 0.0
    var strLocation = ""
    
    var isPasting = false
    
    let pasterboard = UIPasteboard.general
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InfosView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didInfoView))
        InfosView.addGestureRecognizer(tap)

        // Request access to location data
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let newLat = location.coordinate.latitude
            let newlong = location.coordinate.longitude
            if (newLat != lat || newlong != long) {
                // call func to retrieve new coordinates geocoded.
                let geoCode = CLGeocoder()
                let location = CLLocation(latitude: CLLocationDegrees(newLat), longitude: CLLocationDegrees(newlong))
                self.lat = newLat
                self.long = newlong
                geoCode.reverseGeocodeLocation(location) { clPlacemark, error in
                    if error != nil {
                        self.LocationDescription.text = error?.localizedDescription.description
                        return;
                    }
                    if let sl = clPlacemark?.last {
                        self.strLocation = "\(sl.subThoroughfare ?? "") \(sl.thoroughfare ?? ""), \(sl.postalCode ?? ""), \(sl.locality ?? ""), \(sl.country ?? "")"
                        self.LocationDescription.text = self.strLocation
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.LocationDescription.text = error.localizedDescription.description
    }
    
    @objc func didInfoView(sender: UITapGestureRecognizer) {
        if self.isPasting {
            return
        }
        
        self.isPasting = true
        pasterboard.string = self.strLocation
        self.LocationDescription.text = "Copied!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.LocationDescription.text = self.strLocation
            self.isPasting = false
        }
        
    }
}

