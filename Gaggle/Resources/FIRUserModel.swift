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
    var karma: Int = 0
    var likes: [String] = []
    var dislikes: [String] = []
    var profilePictureURL : String = ""
    var honkRefs: [DocumentReference] = []
}

