//
//  FIRUserModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/27/22.
//

import Foundation
import FirebaseFirestore

struct FIRUserModel: Identifiable{
    
    var id: String = ""
    var displayName: String = ""
    var honks: [String] = []
    var karma: Int = 0
    var likes: [String] = []
    var dislikes: [String] = []
    var profilePictureURL = URL(string: "")
    var honkRefs: [DocumentReference] = []
}

