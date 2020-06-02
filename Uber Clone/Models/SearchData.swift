//
//  SearchData.swift
//  Uber Clone
//
//  Created by Yauheni Bunas on 6/1/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct SearchData: Identifiable {
    var id: Int
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
}
