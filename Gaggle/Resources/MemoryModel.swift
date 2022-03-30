//
//  MemoryModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

struct User : Identifiable {
    let id = UUID()
    var location: String = ""
    var collection: String = ""
    var checkedIn: Bool = false
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var signedIn: Bool = false
}

class MemoryModel: ObservableObject {
    @Published var user:User
    
    init() {
    print("MemoryModel init")
    user = User()
    }
}
