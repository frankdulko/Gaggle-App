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
import MapKit
import FirebaseStorage

class UserUpdateModel: ObservableObject {
    
    @Published var firuser = FIRUserModel()
    @Published var userHonks = [HonkModel]()
    
    init(){
        print("User update model init")
        setUser()
        getHonks()
    }
    
    func addDislikes(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["dislikes": FieldValue.arrayUnion([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(-1))])
        print("ADDING DISLIKE")
        setUser()
    }
    
    func deleteDislike(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["dislikes": FieldValue.arrayRemove([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(1))])
        print("DELETING DISLIKE")
        setUser()
    }
    
    func addLikes(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["likes": FieldValue.arrayUnion([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(1))])
        print("ADDING LIKE")
        setUser()
    }
    
    func deleteLike(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["likes": FieldValue.arrayRemove([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(-1))])
        print("DELETING LIKE")
        setUser()
    }
    
    func addHonk(honk: String){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["honks": FieldValue.arrayUnion([honk])])
        setUser()
    }
    
    func addHonkRef(honkRef: DocumentReference){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["honkRefs": FieldValue.arrayUnion([honkRef])])
    }
    
    func getHonks(){
        self.userHonks = [HonkModel]()
        for honkRef in self.firuser.honkRefs {
            honkRef.getDocument { (doc, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let doc = doc, doc.exists {
                    let data = doc.data()
                    if let data = data {
                        //GETTING HERE
                        self.userHonks.append(HonkModel(id: doc.documentID,
                                                        honk: data["honk"] as? String ?? "",
                                                        netLikes: data["netLikes"] as? Int ?? 0,
                                                        authorID: data["authorID"] as? String ?? "",
                                                        authorName: data["authorName"] as? String ?? "",
                                                        datePosted: data["datePosted"] as? Date ?? Date(),
                                                        imageURL: ""))
                    }
                }
            }
            
        }
        print(userHonks.count)
    }
        
        
//        var returnHonk = HonkModel(id: "", honk: "", netLikes: 0, authorID: "", authorName: "", datePosted: Date(), imageURL: "")
//        honkRef.getDocument { (doc, error) -> HonkModel in
//            guard error == nil else {
//                print("error", error ?? "")
//                return
//            }
//
//            if let doc = doc, doc.exists {
//                let data = doc.data()
//                if let data = data {
//                    //GETTING HERE
//                    returnHonk =  HonkModel(id: doc.documentID,
//                                     honk: data["honk"] as? String ?? "",
//                                     netLikes: data["netLikes"] as? Int ?? 0,
//                                     authorID: data["authorID"] as? String ?? "",
//                                     authorName: data["authorName"] as? String ?? "",
//                                     datePosted: data["datePosted"] as? Date ?? Date(),
//                                     imageURL: "")
//                }
//            }
//        }
//        return returnHonk
   // }
    
    func getProfilePictureURL(){
        let uid = Auth.auth().currentUser?.uid ?? ""
        print(uid)

        let storageRef = Storage.storage().reference(withPath: "/profilePictures/\(uid).jpeg")
        storageRef.downloadURL { (url, error) in
        if error != nil {
             print((error?.localizedDescription)!)
            let storageRef = Storage.storage().reference(withPath: "/profilePictures/default.jpeg")
            storageRef.downloadURL { (url, error) in
            if error != nil {
                 print((error?.localizedDescription)!)
                 return
            }
            self.firuser.profilePictureURL = url?.absoluteString ?? ""
            }
             return
        }
        self.firuser.profilePictureURL = url?.absoluteString ?? ""
        }
    }
    
    func newProfilePicture(image: UIImage){
        print("Updating Profile Picture")
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profilePictures/\(self.firuser.id).jpeg")
        
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
                                self.firuser.profilePictureURL = url!.absoluteString
                            }
                        }

                        if let metadata = metadata {
                                print("Metadata: ", metadata)
                        }
                }
        }

    }
    
    func addUser(displayName: String){
        let uid = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        
        db.collection("Users").document(uid).setData(["displayName": displayName,
                                                      "karma": 0,
                                                      "likes": [],
                                                      "dislikes": [],
                                                      "honkRefs": []]) { error in
            if error == nil {
                self.setUser()
            }
            else{
                //ERROR
            }
        }
        setUser()
    }
    
    func setUser() {
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        if uid != "" {
        
            let db = Firestore.firestore()
            let docRef = db.collection("Users").document(uid)

            docRef.getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        self.firuser.id = uid
                        self.firuser.displayName = data["displayName"] as? String ?? ""
                        self.firuser.karma = data["karma"] as? Int ?? 0
                        self.firuser.likes = data["likes"] as? [String] ?? []
                        self.firuser.dislikes = data["dislikes"] as? [String] ?? []
                        self.firuser.honkRefs = data["honkRefs"] as? [DocumentReference] ?? []
                    }
                }
            }
        }
        else {
            print("Document path is empty.")
        }
    }
}
