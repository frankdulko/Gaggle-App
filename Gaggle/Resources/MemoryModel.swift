//
//  MemoryModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import Foundation
import CoreLocation
import MapKit

struct User : Identifiable {
    let id = UUID()
    var profilePicture:String = "person.crop.circle.fill"
    var username:String = "Frank"
    var location: String = "Check In to show Location"
    var checkedIn: Bool = false
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var signedIn: Bool = false
}

struct Item : Identifiable {
  let id = UUID()
  var likes:Int = 0
  var visits:Int = 0
  var text:String
}

class MemoryModel: ObservableObject {
    @Published var user:User
    @Published var items:[Item]
    
    init() {
    print("MemoryModel init")
    // items for testing
    items = [Item(text:"View 0"),Item(text:"View 1"),Item(text:"View 2"),Item(text:"View 3")]
    user = User()
    }
    func like(_ id:UUID) {
    if let index = findIndex( id) {
      items[index].likes += 1
    }
    }
    func unlike(_ id:UUID) {
    if let index = findIndex( id) {
      items[index].likes -= 1
    }
    }
    func visit(_ id:UUID) {
    if let index = findIndex( id) {
      items[index].visits += 1
    }
    }
    func resetCounts(_ id:UUID) {
    if let index = findIndex( id) {
      items[index].visits = 0;
      items[index].likes = 0;
    }
    }
    func findIndex(_ id: UUID) -> Int? {
    return items.firstIndex { item in item.id == id }
    }
}
