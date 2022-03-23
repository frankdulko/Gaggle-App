//
//  PlaceHonks.swift
//  Gaggle
//
//  Created by Frank Dulko on 3/17/22.
//

import Foundation

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

class PlaceHonks: ObservableObject {
    
    @Published var honks = [Honk]()
    let db = Firestore.firestore()

    
    func getHonks(place: String){
        db.collection("Places").document(place)
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
              print("Current data: \(data)")
            }
    }
}

