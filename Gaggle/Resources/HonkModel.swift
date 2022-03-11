//
//  HonkModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import Foundation

struct HonkModel: Identifiable{
    
    var id: String
    var honk: String
    var netLikes: Int
    var authorID: String
    var authorName: String
    var datePosted: Date
    var imageURL: String
}
