//
//  LandmarkAnnotations.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import MapKit
import UIKit


final class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(landmark: Landmark) {
        self.title = landmark.name
        self.coordinate = landmark.coordinate
    }
}
