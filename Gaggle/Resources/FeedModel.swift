//
//  FeedModel.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

class FeedModel: ObservableObject {
    
    //@EnvironmentObject var memoryModel : MemoryModel
    @Published var feed = [HonkModel]()
    @Published var urls: [String: String] = [:]
    @ObservedObject var user : UserUpdateModel
    @ObservedObject var userHonkRefsObs : UserHonkRefsObs
    
    init(user: UserUpdateModel, userHonkRefsObs: UserHonkRefsObs){
        print("Feed model init")
        self.user = user
        self.userHonkRefsObs = userHonkRefsObs
    }
    
//    func getProfilePictureURL(honk: HonkModel) -> URL{
//        var downloadURL = URL(string: "default.jpg")
//        let storageRef = Storage.storage().reference(withPath: "/profilePictures/\(honk.authorID).jpeg")
//        storageRef.downloadURL { (url, error) in
//            if error != nil {
//                 print((error?.localizedDescription)!)
//                 return
//            }
//            downloadURL = url ?? URL(string: "default.jpg")
//        }
//        return downloadURL!
//    }
    
    func findIndex(id: String) -> Int? {
        return feed.firstIndex { item in item.id == id }
    }
    
    func addLike(honk: HonkModel, location: String){
        let db = Firestore.firestore()
        db.collection(location).document(honk.id).updateData(["netLikes": FieldValue.increment(Int64(1))])
        if let index = findIndex(id: honk.id) {
          feed[index].netLikes += 1
        }
    }
    
    func addDislike(honk: HonkModel, location: String){
        let db = Firestore.firestore()
        db.collection(location).document(honk.id).updateData(["netLikes": FieldValue.increment(Int64(-1))])
        if let index = findIndex(id: honk.id) {
          feed[index].netLikes -= 1
        }
    }
    
    func updateNetLikes(honkToUpdate: HonkModel, location: String) {
            
            // Get a reference to the database
            let db = Firestore.firestore()
        
            
            // Set the data to update
            db.collection(location).document(honkToUpdate.id).setData(["netLikes": honkToUpdate.netLikes], merge: true) { error in
                
                // Check for errors
                if error == nil {
                    // Get the new data
                    self.getData(location: location)
                }
            }
        }
    
    func addData(name: String, location: String) {
            
        // Get a reference to the database
        let db = Firestore.firestore()
        var docRef : DocumentReference
        // Add a document to a collection
        docRef = db.collection(location).addDocument(data: ["honk":name,
                                                            "netLikes": 0,
                                                            "authorID": user.firuser.id,
                                                            "authorName": user.firuser.displayName,
                                                            "datePosted": Date(),
                                                            "imageURL": user.firuser.profilePictureURL
                                                           ]) { error in
                                                                // Check for errors
                                                                if error == nil {
                                                                    self.getData(location: location)
                                                                }
                                                                else {
                                                                    // Handle the error
                                                                }
            }
        
        userHonkRefsObs.addUserHonkRef(honkRef: docRef)
        userHonkRefsObs.addUserHonk(userHonk: HonkModel(id: docRef.documentID, honk: name, netLikes: 0, authorID: user.firuser.id, authorName: user.firuser.displayName, datePosted: Date(), imageURL: user.firuser.profilePictureURL))
        
        
        
        
        
//        user.userHonks.append(HonkModel(id: docRef.documentID, honk: name, netLikes: 0, authorID: user.firuser.id, authorName: user.firuser.displayName, datePosted: Date(), imageURL: user.firuser.profilePictureURL?.absoluteString ?? ""))
        
//        userHonkRefsObs.userHonkRefs.append(UserHonkRefs(id: UUID(), honkRef: docRef))
//        userHonkRefsObs.userHonks.append(HonkModel(id: docRef.documentID, honk: name, netLikes: 0, authorID: user.firuser.id, authorName: user.firuser.displayName, datePosted: Date(), imageURL: user.firuser.profilePictureURL?.absoluteString ?? ""))
        
        
        
            
            if (docRef != nil){
                    self.user.addHonkRef(honkRef: docRef)
            }
        }
//
//    func getProfilePictureURL(honk: HonkModel){
//        let storageRef = Storage.storage().reference(withPath: "/profilePictures/\(honk.authorID).jpeg")
//        storageRef.downloadURL { (url, error) in
//            if error != nil {
//                 print((error?.localizedDescription)!)
//                 return
//            }
//            honk.authorID = url?.absoluteString ?? ""
//        }
//    }
//
//    func getPictures(){
//        for honk in self.feed {
//            getProfilePictureURL(honk: honk)
//        }
//    }
    
    func getData(location: String) {
        urls.removeAll()
        let db = Firestore.firestore()
        
        db.collection(location)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.feed = documents.map { d in
                    return HonkModel(id: d.documentID,
                                honk: d["honk"] as? String ?? "",
                                netLikes: d["netLikes"] as? Int ?? 0,
                                authorID: d["authorID"] as? String ?? "",
                                authorName: d["authorName"] as? String ?? "",
                                datePosted: d["datePosted"] as? Date ?? Date(),
                                imageURL: "")
                }
            }
        
        
        for honk in feed {
            if urls[honk.id] == nil {
                getURL(authorID: honk.authorID)
            }
        }
    }
    
    func getURL(authorID: String){
        let storageRef = Storage.storage().reference(withPath: "/profilePictures/\(authorID).jpeg")
        storageRef.downloadURL { (url, error) in
            if error != nil {
                 print((error?.localizedDescription)!)
                 let storageRef = Storage.storage().reference(withPath: "/profilePictures/default.jpeg")
                 storageRef.downloadURL { (url, error) in
                 if error != nil {
                      print((error?.localizedDescription)!)
                      return
                 }
                 self.urls[authorID] = url?.absoluteString ?? ""
                 return
             }
            }
            self.urls[authorID] = url?.absoluteString ?? ""
        }
    }
}
