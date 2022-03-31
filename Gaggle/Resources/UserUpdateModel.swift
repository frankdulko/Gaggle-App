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
    }
    
    func findIndexDislikes(id: String) -> Int? {
        return firuser.dislikes.firstIndex { item in item == id }
    }
    
    func findIndexLikes(id: String) -> Int? {
        return firuser.likes.firstIndex { item in item == id }
    }
    
    func addDislikes(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["dislikes": FieldValue.arrayUnion([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(-1))])
        firuser.dislikes.append(honk.id)
        print("ADDING DISLIKE")
        //setUser()
    }
    
    func deleteDislike(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["dislikes": FieldValue.arrayRemove([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(1))])
        if let index = findIndexDislikes(id: honk.id) {
            firuser.dislikes.remove(at: index)
        }
        print("DELETING DISLIKE")
        //setUser()
    }
    
    func addLikes(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["likes": FieldValue.arrayUnion([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(1))])
        firuser.likes.append(honk.id)
        print("ADDING LIKE")
        //setUser()
    }
    
    func deleteLike(honk: HonkModel){
        let uid = firuser.id
        let db = Firestore.firestore()
        db.collection("Users").document(uid).updateData(["likes": FieldValue.arrayRemove([honk.id])])
        db.collection("Users").document(honk.authorID).updateData(["karma": FieldValue.increment(Int64(-1))])
        if let index = findIndexLikes(id: honk.id) {
            firuser.likes.remove(at: index)
        }
        print("DELETING LIKE")
        //setUser()
    }
    
    //GET USER'S PROFILE PICTURE URL WHEN THE SIGN IN
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
    
    
    //UPDATES THE USER'S PROFILE PICTURE IN DATABASE
    //UPDATES USER'S PROFILE PICTURE URL LOCALLY
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
    
    //WHEN USER CREATES AN ACCOUNT, ADD INFORMATION TO FIRESTORE
    //THEN CALL SET USER
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
    
    //WHEN USER SIGNS IN, GET THEIR INFORMATION AND STORE IT LOCALLY
    //CALLED WHEN USER SIGNS IN OR AFTER ACCOUNT IS CREATED
    func setUser() {
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        if uid != "" {
            let db = Firestore.firestore()
            db.collection("Users").document(uid)
                .addSnapshotListener { documentSnapshot, error in
                  guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                  }
                  guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                  }
                    self.firuser.id = uid
                    self.firuser.displayName = data["displayName"] as? String ?? ""
                    self.firuser.karma = data["karma"] as? Int ?? 0
                    self.firuser.likes = data["likes"] as? [String] ?? []
                    self.firuser.dislikes = data["dislikes"] as? [String] ?? []
                    self.firuser.honkRefs = data["honkRefs"] as? [DocumentReference] ?? []
                }
        }
        else {
            print("Document path is empty.")
        }
    }
}
