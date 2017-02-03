//
//  ViewController.swift
//  map
//
//  Created by thisisanewlaptop on 2/2/17.
//  Copyright © 2017 jiayi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManger = CLLocationManager()
    var monitoredRegions: Dictionary<String, Date> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManger.delegate = self;
        locationManger.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        setupData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManger.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied{
           showAlert("enable location")
        }
        
        else if CLLocationManager.authorizationStatus() == .authorizedAlways{
            locationManger.startUpdatingLocation()
        }
    }
    
    func setupData(){
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
            let title = "I am dying"
            let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
            let regionRadius = 300.0
            
            let region = CLCircularRegion(center:CLLocationCoordinate2D(latitude: coordinate.latitude, longitude:coordinate.longitude),radius: regionRadius, identifier:title);locationManger.startMonitoring(for: region)
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.coordinate = coordinate;
            restaurantAnnotation.title = "\(title)";
            mapView.addAnnotation(restaurantAnnotation)
            
            let circle = MKCircle(center: coordinate,radius: regionRadius)
            mapView.add(circle)
        }
        else{
            print("can't track")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        showAlert("enter \(region.identifier)")
        monitoredRegions[region.identifier] = Date()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlert("exit \(region.identifier)")
        monitoredRegions.removeValue(forKey: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateRegionsWithLocation(locations[0])
    }
    
    func updateRegionsWithLocation(_ location: CLLocation) {
        
        let regionMaxVisiting = 10.0
        var regionsToDelete: [String] = []
        
        for regionIdentifier in monitoredRegions.keys {
            if Date().timeIntervalSince(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
                showAlert("Thanks for visiting our restaurant")
                
                regionsToDelete.append(regionIdentifier)
            }
        }
        
        for regionIdentifier in regionsToDelete {
            monitoredRegions.removeValue(forKey: regionIdentifier)
        }
    }

    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

