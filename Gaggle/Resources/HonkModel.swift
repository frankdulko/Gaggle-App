//
//  HonkModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import Foundation
import FirebaseFirestore

struct HonkModel: Identifiable{
    var id: String
    var ref: DocumentReference
    var honk: String
    var netLikes: Int
    var authorID: String
    var authorName: String
    var datePosted: Timestamp
}
