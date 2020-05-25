//
//  ViewController.swift
//  PokeRadar
//
//  Created by Valentin Sanchez on 22/05/2020.
//  Copyright © 2020 Valentin Sanchez. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import GeoFire


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    let locationManager = CLLocationManager()
    var mapCentered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.geoFireRef = Database.database().reference()
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .follow
        
        self.locationManager.delegate = self
        locationAuthStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notify), name: NSNotification.Name(rawValue: "NotifyPokemon"), object: nil)
        
    }
    
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
        }else{
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            self.mapView.showsUserLocation = true
        }
    }
    
    func centerMap(on location: CLLocation){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !mapCentered{
            if let location = userLocation.location{
                centerMap(on: location)
                mapCentered = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
        
        self.showSightingsOnMaps(on: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        let annotationForId = "Pokemon"
        if annotation.isKind(of: MKUserLocation.self){
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "character")
        }else if let dequeAnnotation = self.mapView.dequeueReusableAnnotationView(withIdentifier: annotationForId){
            annotationView = dequeAnnotation
            annotationView?.annotation = annotation
        }else{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationForId)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        if let annotationView = annotationView, let pokemonAnnotation = annotation as? PokemonAnnotation{
            annotationView.canShowCallout = true
            annotationView.image = pokemonAnnotation.pokemon.image
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(UIImage(named: "location-map-flat"), for: .normal)
            annotationView.rightCalloutAccessoryView = button
        }
        
        return annotationView
    }
    
    func creatingSighting(forlocation location: CLLocation, with pokemonId: Int){
        self.geoFire.setLocation(location, forKey: "\(pokemonId)")
    }
    
    func showSightingsOnMaps(on location: CLLocation){
        let query = self.geoFire.query(at: location, withRadius: 2.0)
        query.observe(.keyEntered, with: { (key, location) in
            //if let key = key, let location = location {
            let annotation = PokemonAnnotation(coordinate: location.coordinate, pokemonId: Int(key)!)
            self.mapView.addAnnotation(annotation)
            //}
        })
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PokemonAnnotation{
            let place = MKPlacemark(coordinate: annotation.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "\(annotation.pokemon.name) avistado"
            let distance: CLLocationDistance = 1000
            let span = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
            let options = [MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate: span.center), MKLaunchOptionsMapSpanKey : NSValue(mkCoordinateSpan: span.span), MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking] as [String : Any]
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    /*@IBAction func reportPokemon(_ sender: UIButton) {
        let location = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
        let poquemonIdRandom = arc4random_uniform(151) + 1
        self.creatingSighting(forlocation: location, with: Int(poquemonIdRandom))
    }*/
    
    @objc func notify(notif: Notification){
        if let pokemon = notif.object as? Pokemon{
            let location = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
            self.creatingSighting(forlocation: location, with: pokemon.id)
        }
        
    }
    
}
