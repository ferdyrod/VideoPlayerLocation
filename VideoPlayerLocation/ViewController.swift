//
//  ViewController.swift
//  VideoPlayerLocation
//
//  Created by Ferdy Rodriguez on 12/5/16.
//  Copyright © 2016 Ferdy Rodriguez. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!

    @IBOutlet var Map: MKMapView!
    
    var defaults = UserDefaults.standard
    var isInRange:Bool = false
    var playerViewController: AVPlayerViewController!
    var locationManager:CLLocationManager!
    var upmLocation:CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(defaults.object(forKey: "inRange") != nil) {
            isInRange = defaults.bool(forKey: "inRange")
            print(isInRange)
        }
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        self.Map.showsUserLocation = true

        
        Map.delegate = self
        upmLocation = CLLocationCoordinate2DMake(40.3891852, -3.6293157)
        let circle = MKCircle(center: upmLocation, radius: 100)
        Map.add(circle)
        
    }

    
    func playVideo (loc: String) {
        self.playerViewController = AVPlayerViewController()
        self.present(playerViewController, animated: true) {
            let videoURL = URL(string: loc)
            self.playerViewController.player = AVPlayer(url: videoURL!)
            self.playerViewController.player?.play()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lat = locations.last!.coordinate.latitude
        let long = locations.last!.coordinate.longitude
        let myLocation = CLLocationCoordinate2DMake(lat, long)
        // Setting Map center
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(myLocation, span)
        Map.setRegion(region, animated: true)

        let upm = CLLocation(latitude: upmLocation.latitude, longitude: upmLocation.longitude)
        let currentLocation = CLLocation(latitude: lat, longitude: long)
        let distance = upm.distance(from: currentLocation)
        
        
        if(distance < 100) {
            if(!isInRange){
                playVideo(loc: "http://frodriguez.webfactional.com/media/RogueOne.mov")
                isInRange = true
                defaults.set(isInRange, forKey: "inRange")
            }
        } else {
            isInRange = false
            defaults.set(isInRange, forKey: "inRange")
        }
        
        print("Distance is \(distance) and its range is: \(isInRange)")
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.blue
        circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
        circle.lineWidth = 1
        return circle
    }
}

