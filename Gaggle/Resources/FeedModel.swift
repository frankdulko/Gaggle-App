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
import FirebaseFirestore

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
        addUserURL()
    }
    
    func findIndex(id: String) -> Int? {
        return feed.firstIndex { item in item.id == id }
    }
    
    //INCREMENT NETLIKES OF POST IN DATABASE AND LOCALLY
    //func addLike(honk: HonkModel, location: String){
    func addLike(honk: HonkModel){
        honk.ref.updateData(["netLikes": FieldValue.increment(Int64(1))])
        //let db = Firestore.firestore()
        //db.collection(location).document(honk.id).updateData(["netLikes": FieldValue.increment(Int64(1))])
        if let index = findIndex(id: honk.id) {
          feed[index].netLikes += 1
        }
    }
    
    //DECREMENT NETLIKES OF POST IN DATABASE AND LOCALLY
    //func addDislike(honk: HonkModel, location: String){
    func addDislike(honk: HonkModel){
        honk.ref.updateData(["netLikes": FieldValue.increment(Int64(-1))])
        //let db = Firestore.firestore()
        //db.collection(location).document(honk.id).updateData(["netLikes": FieldValue.increment(Int64(-1))])
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
                                                            "datePosted": Timestamp(),
                                                           ]) { error in
                                                                // Check for errors
                                                                if error == nil {
                                                                    self.getData(location: location)
                                                                }
                                                                else {
                                                                    // Handle the error
                                                                }
                                                                }
        docRef.setData(["ref":docRef], merge: true)
        
        //UPDATE USER'S POST REFERENCES LOCALLY AND IN DATABASE
        userHonkRefsObs.addUserHonkRef(honkRef: docRef)
        //UPDATE USER'S POSTS LOCALLY
        userHonkRefsObs.addUserHonk(userHonk: HonkModel(id: docRef.documentID, ref: docRef, honk: name, netLikes: 0, authorID: user.firuser.id, authorName: user.firuser.displayName, datePosted: Timestamp()))
    }
    
    //GET POSTS WHEN USER CHECKS IN TO SPECIFIC LOCATION
    func getData(location: String) {
        //clear the stored profile picture urls from previous check ins.
        let db = Firestore.firestore()
        
        //add listener to location
        //updates whenever collection changes
        //which causes published variable feed to update
        //which causes any view observing this variable to update
        var listener = db.collection(location)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.feed = documents.map { d in
                    return HonkModel(id: d.documentID,
                                     ref: d.reference,
                                     honk: d["honk"] as? String ?? "",
                                     netLikes: d["netLikes"] as? Int ?? 0,
                                     authorID: d["authorID"] as? String ?? "",
                                     authorName: d["authorName"] as? String ?? "",
                                     datePosted: d["datePosted"] as? Timestamp ?? Timestamp())
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
    
//    func stopListening(){
//        listener.remove()
//    }
    
    //GET PROFILE PICTURE URL OF A USER WITH THEIR ID
    //IF THEY DON'T HAVE ONE, USE DEFAULT
    func getURL(authorID: String){
        if urls[authorID] == nil {
            print("Reading Database")
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
    
    func addUserURL(){
        print("Adding User URL")
        let storageRef = Storage.storage().reference(withPath: "/profilePictures/\(user.firuser.id).jpeg")
        storageRef.downloadURL { (url, error) in
            if error != nil {
                 print((error?.localizedDescription)!)
                 let storageRef = Storage.storage().reference(withPath: "/profilePictures/default.jpeg")
                 storageRef.downloadURL { (url, error) in
                 if error != nil {
                      print((error?.localizedDescription)!)
                      return
                 }
                 self.urls[self.user.firuser.id] = url?.absoluteString ?? ""
                 return
             }
            }
            self.urls[self.user.firuser.id] = url?.absoluteString ?? ""
        }
    }
    
    //UPDATES THE USER'S PROFILE PICTURE IN DATABASE
    //UPDATES USER'S PROFILE PICTURE URL LOCALLY
    func newProfilePicture(image: UIImage){
        print("Updating Profile Picture")
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profilePictures/\(self.user.firuser.id).jpeg")
        
        // Resize the image to 200px in height with a custom extension
        //let resizedImage = image.aspectFittedToHeight(height: 200)

        // Convert the image into JPEG and compress the quality to reduce its size
        let data = image.jpegData(compressionQuality: 0.2)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let data = data {
                storageRef.putData(data, metadata: metadata) { (metadata, error) in
                        if let error = error {
                                print("Error while uploading file: ", error)
                        }
                        else {
                            storageRef.downloadURL { (url, error) in
                                if error != nil {
                                     print((error?.localizedDescription)!)
                                     return
                                }
                                self.user.firuser.profilePictureURL = url!.absoluteString
                                self.urls[self.user.firuser.id] = url!.absoluteString
                            }
                        }

                        if let metadata = metadata {
                                print("Metadata: ", metadata)
                        }
                }
        }

    }
}
