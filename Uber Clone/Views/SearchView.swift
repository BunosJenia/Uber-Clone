//
//  SearchView.swift
//  Uber Clone
//
//  Created by Yauheni Bunas on 6/1/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct SearchView: View {
    
    @Binding var show: Bool
    @Binding var detail: Bool
    @Binding var map: MKMapView
    @Binding var source: CLLocationCoordinate2D!
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var name: String
    @Binding var distance: String
    @Binding var time: String
    
    @State var result: [SearchData] = []
    @State var text = ""
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                SearchBar(
                    result: self.$result,
                    map: self.$map,
                    source: self.$source,
                    destination: self.$destination,
                    name: self.$name,
                    distance: self.$distance,
                    time: self.$time,
                    text: self.$text
                )
                
                if self.text != "" {
                    List(self.result) { searchData in
                        VStack(alignment: .leading) {
                            Text(searchData.name)
                            
                            Text(searchData.address)
                                .font(.caption)
                        }
                        .onTapGesture {
                            self.destination = searchData.coordinate
                            self.UpdateMap()
                            self.show.toggle()
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height / 2)
                }
            }
            .padding(.horizontal, 25)
        }
        .background(Color.black.opacity(0.2).edgesIgnoringSafeArea(.all))
        .onTapGesture {
            self.show.toggle()
        }
    }
    
    func UpdateMap() {
        let point = MKPointAnnotation()
        point.subtitle = "Destination"
        point.coordinate = destination
        
        let decoder = CLGeocoder()
        decoder.reverseGeocodeLocation( CLLocation(latitude: destination.latitude, longitude: destination.longitude)) { (places, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                
                return
            }
            
            self.name = places?.first?.name ?? ""
            point.title = places?.first?.name ?? ""
            
            self.detail = true
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (direction, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                
                return
            }
            
            let polyline =  direction?.routes[0].polyline
            
            let distance = direction?.routes[0].distance as! Double
            self.distance = String(format: "%.1f", distance / 1000)
            
            let time = direction?.routes[0].expectedTravelTime as! Double
            self.time = String(format: "%.1f", time / 60)
            
            self.map.removeOverlays(self.map.overlays)
            self.map.addOverlay(polyline!)
            self.map.setRegion(MKCoordinateRegion(polyline!.boundingMapRect), animated: true)
        }
        
        self.map.removeAnnotations(self.map.annotations)
        self.map.addAnnotation(point)
    }
}

struct SearchBar: UIViewRepresentable {
    
    @Binding var result: [SearchData]
    @Binding var map:MKMapView
    @Binding var source: CLLocationCoordinate2D!
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var name: String
    @Binding var distance: String
    @Binding var time: String
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        return SearchBar.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let view = UISearchBar()
        
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar
        
        init(parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.parent.text = searchText
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = self.parent.map.region
            
            let search = MKLocalSearch(request: request)
            
            DispatchQueue.main.async {
                self.parent.result.removeAll()
            }
            
            search.start { (result, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                    
                    return
                }
                
                for i in 0 ..< result!.mapItems.count {
                    let searchData = SearchData(
                        id: i,
                        name: result!.mapItems[i].name!,
                        address: result!.mapItems[i].placemark.title!,
                        coordinate: result!.mapItems[i].placemark.coordinate
                    )
                    
                    self.parent.result.append(searchData)
                }
            }
        }
    }
}
