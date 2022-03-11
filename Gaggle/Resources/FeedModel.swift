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
    @ObservedObject var user : UserUpdateModel
    
    init(user: UserUpdateModel){
        print("Feed model init")
        self.user = user
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
                                                            "datePosted": Date()
                                                           ]) { error in
                                                                // Check for errors
                                                                if error == nil {
                                                                    self.getData(location: location)
                                                                }
                                                                else {
                                                                    // Handle the error
                                                                }
            }
        user.userHonks.append(HonkModel(id: docRef.documentID, honk: name, netLikes: 0, authorID: user.firuser.id, authorName: user.firuser.displayName, datePosted: Date(), imageURL: ""))
            
        if (docRef != nil){
                self.user.addHonkRef(honkRef: docRef)
            }
        }
    
    func getData(location: String) {

        let db = Firestore.firestore()
        var imageURL = ""
        
        //order(by: "netLikes", descending: true).
            
        db.collection(location).getDocuments { snapshot, error in

                if error == nil {
                        if let snapshot = snapshot {
                            if snapshot.documents.isEmpty{
                                print("\(location) empty")
                                db.collection(location).addDocument(
                                    data: ["honk": "Be the first to post in this Gaggle!",
                                           "authorName": "Gaggle"])
                            }
                            else {
                                DispatchQueue.main.async {
                                    
                                    self.feed = snapshot.documents.map { d in
                                        let storageRef = Storage.storage().reference(withPath: "/profilePictures/\(d["authorID"] as? String ?? "default").jpeg")
                                        storageRef.downloadURL { (url, error) in
                                            if error != nil {
                                                 print((error?.localizedDescription)!)
                                                 return
                                            }
                                            imageURL = url?.absoluteString ?? "unknown"
                                            //print(imageURL)
                                        }
                                        return HonkModel(id: d.documentID,
                                                         honk: d["honk"] as? String ?? "",
                                                         netLikes: d["netLikes"] as? Int ?? 0,
                                                         authorID: d["authorID"] as? String ?? "",
                                                         authorName: d["authorName"] as? String ?? "",
                                                         datePosted: d["datePosted"] as? Date ?? Date(),
                                                         imageURL: imageURL)
                                    }
                                }
                            }
                        }
                }
                else {
                    //print(error)
                }
        }
    }
}
