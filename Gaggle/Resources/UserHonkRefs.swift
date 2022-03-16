//
//  UserHonkRefs.swift
//  Gaggle
//
//  Created by Frank Dulko on 3/11/22.
//

import Foundation
import FirebaseFirestore

struct UserHonkRefs : Identifiable {
    var id : UUID
    var honkRef : DocumentReference
}
