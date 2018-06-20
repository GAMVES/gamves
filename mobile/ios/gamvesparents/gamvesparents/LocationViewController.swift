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

class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
}

class LocationViewController: UIViewController, MKMapViewDelegate {

    var locations = [LocationGamves]()
   
    let regionRadius: CLLocationDistance = 1000
    var mapView: MKMapView?

    var countLocations = 0

    override func viewDidLoad() {
        super.viewDidLoad() 
        
        self.view.backgroundColor = UIColor.white

        self.mapView = MKMapView(frame: CGRect(x:0, y:20, width:(self.view.frame.width), height:self.view.frame.height))
        self.view.addSubview(self.mapView!)

        self.mapView?.delegate = self
        
        print(locations.count)
        
        var loc_0 =  locations[0] as LocationGamves
        var geo_0 = loc_0.geopoint

        let initialLocation = CLLocation(latitude: (geo_0?.latitude)!, longitude: (geo_0?.longitude)!)

        centerMapOnLocation(location: initialLocation)

        for location in locations {
            
            let lat = location.geopoint.latitude
            let long = location.geopoint.longitude

            let address = location.address
            let city = location.city
            let state = location.state
            //let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hello = MyPointAnnotation()
            hello.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            hello.title = address
            hello.subtitle = state            
            
            if countLocations == 0 {
                hello.pinTintColor = .red
            } else {
                hello.pinTintColor = .blue
            }
            
            self.mapView?.addAnnotation(hello as! MKAnnotation)

            countLocations = countLocations + 1
            
        }

        self.mapView?.showAnnotations((mapView?.annotations)!, animated: true)

    }
    
    //https://stackoverflow.com/questions/41819940/how-to-change-pin-color-in-mapkit-under-the-same-annotationview-swift3

    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            annotationView?.canShowCallout = true
           } else {
            annotationView?.annotation = annotation
        }
        if annotation is MKUserLocation {
            return nil
        }
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintColor
        }
                return annotationView
    }*/


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
