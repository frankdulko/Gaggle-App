//
//  Honks.swift
//  Gaggle
//
//  Created by Frank Dulko on 3/17/22.
//

import Foundation

struct Honk: Identifiable{
    var id: String
    var honk: String
    var netLikes: Int
    var authorID: String
    var authorName: String
    var datePosted: Date
    var imageURL: String
}
