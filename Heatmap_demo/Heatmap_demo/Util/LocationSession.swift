//
//  LocationManager.swift
//  SinghaSaleVisit
//
//  Created by Detchat Boonpragob on 7/2/2562 BE.
//  Copyright © 2562 Zoso. All rights reserved.
//

import Foundation
import MapKit


class LocationSession:NSObject, CLLocationManagerDelegate
{
    static let sharedInstance:LocationSession = LocationSession()
    
    private var locationManager : CLLocationManager?
    var currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    var currentLat:CLLocationDegrees
    {
        get {
            return self.currentLocation.latitude.roundTo(places: 8)
        }
    }
    var currentLong:CLLocationDegrees
    {
        get {
            return self.currentLocation.longitude.roundTo(places: 8)
        }
    }
    
    //MARK: Location Manager
    func startUpdateLocation()  {
        if locationManager != nil  {
            locationManager!.stopUpdatingLocation()
        }
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        if locationManager!.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)){
            locationManager!.requestWhenInUseAuthorization()
        }
        
        let status  = CLLocationManager.authorizationStatus()
        
        if CLLocationManager.locationServicesEnabled(), (status == .authorizedAlways || status == .authorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
        }
        else
        {
            let alertVC = UIAlertController.init(title: "Application require location service", message: "Please open location service in setting before use.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "ok", style: .default, handler: nil))
            
            if let window = UIApplication.shared.delegate?.window {
                window!.visibleViewController()?.present(alertVC, animated: true, completion: nil)
            }
        }
        
    }
    
    func stopUpdateLocation()  {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.last?.coordinate {
            currentLocation = coord
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location fail : \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .denied,.notDetermined,.restricted:
            manager.requestWhenInUseAuthorization()
            break
        }
    }
}

