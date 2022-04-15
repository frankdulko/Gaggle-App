//
//  HonkModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import Foundation
import FirebaseFirestore

struct HonkModel: Identifiable, Comparable, Equatable{
    static func < (lhs: HonkModel, rhs: HonkModel) -> Bool {
        return lhs.datePosted.seconds < rhs.datePosted.seconds
    }
    
    var id: String
    var ref: DocumentReference
    var honk: String
    var netLikes: Int
    var authorID: String
    var authorName: String
    var datePosted: Timestamp
}
