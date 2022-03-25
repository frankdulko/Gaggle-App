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
    
    func findIndex(id: String) -> Int? {
        return feed.firstIndex { item in item.id == id }
    }
    
    //INCREMENT NETLIKES OF POST IN DATABASE AND LOCALLY
    func addLike(honk: HonkModel, location: String){
        let db = Firestore.firestore()
        db.collection(location).document(honk.id).updateData(["netLikes": FieldValue.increment(Int64(1))])
        if let index = findIndex(id: honk.id) {
          feed[index].netLikes += 1
        }
    }
    
    //DECREMENT NETLIKES OF POST IN DATABASE AND LOCALLY
    func addDislike(honk: HonkModel, location: String){
        let db = Firestore.firestore()
        db.collection(location).document(honk.id).updateData(["netLikes": FieldValue.increment(Int64(-1))])
        if let index = findIndex(id: honk.id) {
          feed[index].netLikes -= 1
        }
    }
    
    //ADD POST TO DATABASE
    func addData(name: String, location: String) {
            
        // Get a reference to the database
        let db = Firestore.firestore()
        var docRef : DocumentReference
        // Add a document to a collection
        //SAVE REFERNECE
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
        
        //UPDATE USER'S POST REFERENCES LOCALLY AND IN DATABASE
        userHonkRefsObs.addUserHonkRef(honkRef: docRef)
        //UPDATE USER'S POSTS LOCALLY
        userHonkRefsObs.addUserHonk(userHonk: HonkModel(id: docRef.documentID, honk: name, netLikes: 0, authorID: user.firuser.id, authorName: user.firuser.displayName, datePosted: Date(), imageURL: user.firuser.profilePictureURL))
    }
    
    //GET POSTS WHEN USER CHECKS IN TO SPECIFIC LOCATION
    func getData(location: String) {
        //clear the stored profile picture urls from previous check ins.
        urls.removeAll()
        let db = Firestore.firestore()
        
        //add listener to location
        //updates whenever collection changes
        //which causes published variable feed to update
        //which causes any view observing this variable to update
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
        
        //for every post at this location, get the user's profile picture url
        for honk in feed {
            //no need to get a user's profile picture url more than once if they have multiple posts
            if urls[honk.id] == nil {
                getURL(authorID: honk.authorID)
            }
        }
    }
    
    //GET PROFILE PICTURE URL OF A USER WITH THEIR ID
    //IF THEY DON'T HAVE ONE, USE DEFAULT
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
