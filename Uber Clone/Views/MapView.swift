//
//  MapView.swift
//  Uber Clone
//
//  Created by Yauheni Bunas on 5/30/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var map: MKMapView
    @Binding var locationManager: CLLocationManager
    @Binding var alert: Bool
    @Binding var source: CLLocationCoordinate2D!
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var name: String
    @Binding var distance: String
    @Binding var time: String
    @Binding var show: Bool
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        locationManager.delegate = context.coordinator
        map.showsUserLocation = true
        
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(gesture:)))
        
        map.addGestureRecognizer(gesture)
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                self.parent.alert.toggle()
            } else {
                self.parent.locationManager.startUpdatingLocation()
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let region = MKCoordinateRegion(center: locations.last!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            self.parent.source = locations.last!.coordinate
            self.parent.map.region = region
        }
        
        @objc func tap(gesture: UIGestureRecognizer) {
            let location = gesture.location(in: self.parent.map)
            let mplocation = self.parent.map.convert(location, toCoordinateFrom: self.parent.map)
            
            let point = MKPointAnnotation()
            point.subtitle = "Destination"
            point.coordinate = mplocation
            
            self.parent.destination = mplocation
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation( CLLocation(latitude: mplocation.latitude, longitude: mplocation.longitude)) { (places, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                    
                    return
                }
                
                self.parent.name = places?.first?.name ?? ""
                point.title = places?.first?.name ?? ""
                
                self.parent.show = true
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.parent.source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: mplocation))
            
            let directions = MKDirections(request: request)
            
            directions.calculate { (direction, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                    
                    return
                }
                
                let polyline =  direction?.routes[0].polyline
                
                let distance = direction?.routes[0].distance as! Double
                self.parent.distance = String(format: "%.1f", distance / 1000)
                
                let time = direction?.routes[0].expectedTravelTime as! Double
                self.parent.time = String(format: "%.1f", time / 60)
                
                self.parent.map.removeOverlays(self.parent.map.overlays)
                self.parent.map.addOverlay(polyline!)
                self.parent.map.setRegion(MKCoordinateRegion(polyline!.boundingMapRect), animated: true)
            }
            
            self.parent.map.removeAnnotations(self.parent.map.annotations)
            self.parent.map.addAnnotation(point)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let over = MKPolylineRenderer(overlay: overlay)
        
            over.strokeColor = .red
            over.lineWidth = 3
            
            return over
        }
    }
}
