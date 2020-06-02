//
//  HomeView.swift
//  Uber Clone
//
//  Created by Yauheni Bunas on 5/30/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase

struct HomeView: View {
    
    @State var map = MKMapView()
    @State var locationManager = CLLocationManager()
    @State var alert = false
    @State var source: CLLocationCoordinate2D!
    @State var destination: CLLocationCoordinate2D!
    @State var name = ""
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var booked = false
    @State var doc = ""
    @State var data: Data = .init(count: 0)
    @State var searching = false
    @State var isShowMenu = false
    
    var body: some View {
        
        ZStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            withAnimation(.default) {
                                self.isShowMenu.toggle()
                            }
                        }) {
                            Image(systemName: "text.justify")
                                .foregroundColor(Color.black)
                        }
                        
                        VStack(alignment:.leading, spacing: 15) {
                            Text(self.destination != nil ? "Destination" : "Pick a Location")
                                .font(.title)
                            
                            if self.destination != nil {
                                Text(self.name)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            self.searching.toggle()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.black)
                        }
                    }
                    .padding()
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                    .background(Color.white)
                    
                    MapView(
                        map: self.$map,
                        locationManager: self.$locationManager,
                        alert: self.$alert,
                        source: self.$source,
                        destination: self.$destination,
                        name: self.$name,
                        distance: self.$distance,
                        time: self.$time,
                        show: self.$show
                    )
                    .onAppear {
                        self.locationManager.requestAlwaysAuthorization()
                    }
                }
                
                if self.destination != nil && self.show {
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Destination")
                                        .fontWeight(.bold)
                                    
                                    Text(self.name)
                                    
                                    Text("Distance - " + self.distance + " KM")
                                    
                                    Text("Expected time - " + self.time + "Min")
                                }
                                
                                Spacer()
                            }
                            
                            Button (action: {
                                self.loading.toggle()
                                
                                self.book()
                            }) {
                                Text("Book Now")
                                    .foregroundColor(Color.white)
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width / 2)
                            }
                            .background(Color.red)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            
                            self.map.removeOverlays(self.map.overlays)
                            self.map.removeAnnotations(self.map.annotations)
                            
                            self.destination = nil
                            
                            self.show.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.black)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                    .background(Color.white)
                }
            }
            .offset(x: self.isShowMenu ? UIScreen.main.bounds.width/1.5 : 0)
            .disabled(self.isShowMenu ? true : false)
            
            if self.loading {
                LoaderView()
            }
            
            if self.booked {
                BookedView(
                    data: self.$data,
                    doc: self.$doc,
                    loading: self.$loading,
                    booked: self.$booked
                )
            }
            
            if self.searching {
                SearchView(
                    show: self.$searching,
                    detail: self.$show,
                    map: self.$map,
                    source: self.$source,
                    destination: self.$destination,
                    name: self.$name,
                    distance: self.$distance,
                    time: self.$time
                )
            }
            
            if self.searching {
                SearchView(
                    show: self.$searching,
                    detail: self.$show,
                    map: self.$map,
                    source: self.$source,
                    destination: self.$destination,
                    name: self.$name,
                    distance: self.$distance,
                    time: self.$time
                )
            }
            
            if self.isShowMenu {
                MenuView(isShowMenu: self.$isShowMenu)
                    .transition(.move(edge: .leading))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: self.$alert) { () -> Alert in
            Alert(title: Text("Error"), message: Text("Please Enable Location in Settings!"), dismissButton: .destructive(Text("Ok")))
        }
        .gesture(self.getGesture())
    }
    
    func getGesture() -> some Gesture {
        let dragGesture = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.isShowMenu = false
                    }
                }
            }
        
        return dragGesture
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension HomeView {
    func book() {
        let db = Firestore.firestore()
        let doc = db.collection("Booking").document()
        
        self.doc = doc.documentID
        
        let from =  GeoPoint(latitude: self.source.latitude, longitude: self.source.longitude)
        let to = GeoPoint(latitude: self.destination.latitude, longitude: self.destination.longitude)
        
        doc.setData(["name":"MyName", "from":from, "to":to, "distance":self.distance, "fair":(self.distance as NSString).floatValue * 1.2]) { (error) in
            if error != nil {
                print((error?.localizedDescription)!)
                
                return
            }
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(self.doc.data(using: .ascii), forKey: "inputMessage")
            
            let image = UIImage(ciImage: (filter?.outputImage?.transformed(by: CGAffineTransform(scaleX: 5, y: 5)))!)
            
            self.data = image.pngData()!
            
            self.loading.toggle()
            self.booked.toggle()
        }
    }
    
    func getFair() -> Float {
        return (self.distance as NSString).floatValue * 1.2
    }
}
