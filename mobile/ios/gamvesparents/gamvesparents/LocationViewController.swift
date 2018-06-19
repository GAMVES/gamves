//
//  LocationViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 23/01/2018.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import MapKit
import Parse

class LocationViewController: UIViewController {

    var locations = [PFGeoPoint]()
   
    let regionRadius: CLLocationDistance = 1000
    var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.view.backgroundColor = UIColor.white

        self.mapView = MKMapView(frame: CGRect(x:0, y:20, width:(self.view.frame.width), height:self.view.frame.height))
        self.view.addSubview(self.mapView!)

        let initialLocation = CLLocation(latitude: locations[0].latitude, longitude: locations[0].longitude)

        centerMapOnLocation(location: initialLocation)
        
        for location in locations {
            
            let lat = location.latitude
            let long = location.longitude
            
            /*let artwork = Artwork(title: "King David Kalakaua",
            locationName: "Waikiki Gateway Park",
            discipline: "Sculpture",
            coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))*/

            let artwork = Artwork(title: "King David Kalakaua",
            locationName: "Waikiki Gateway Park",
            discipline: "Sculpture",
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
            
            self.mapView?.addAnnotation(artwork)
            
        }

        

    }

    func centerMapOnLocation(location: CLLocation) {
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 
        regionRadius, regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
