//
//  UserHonkRefsObs.swift
//  Gaggle
//
//  Created by Frank Dulko on 3/11/22.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftUI

//DISPLAY USER'S POSTS ON PROFILE
//PUBLISHED VARIABLE USERHONKREFS
//VIEW WILL REFRESH EVRY TIME A NEW REF IS ADDED
class UserHonkRefsObs : ObservableObject {
    
    //var userHonkRefs = [UserHonkRefs]()
    var userHonkRefs = [DocumentReference]()
    var likedHonkRefs = [DocumentReference]()
    var dislikedHonkRefs = [DocumentReference]()
    @Published var userHonks = [HonkModel]()
    @Published var likedHonks = [HonkModel]()
    @Published var dislikedHonks = [HonkModel]()
        
    //POPULATE USERHONKREFS ARRAY ON INIT
    //CALLED AFTER SIGN IN COMPLETED
    init(){
        print("UserHonkRefObs init");
        //getUserHonkRefs()
    }
    
    func getUserHonkRefs(){
        let db = Firestore.firestore()
        db.collection("Users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    for ref in data["honkRefs"] as? [DocumentReference] ?? [DocumentReference](){
                        self.userHonkRefs.append(ref)
                    }
                }
                self.getUserHonks()
            }
        }
    }
    
    func getLikedHonkRefs(){
        let db = Firestore.firestore()
        db.collection("Users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    for ref in data["honkRefs"] as? [DocumentReference] ?? [DocumentReference](){
                        self.likedHonkRefs.append(ref)
                    }
                }
                self.getLikedHonks()
            }
        }
    }
    
    func getDislikedHonkRefs(){
        let db = Firestore.firestore()
        db.collection("Users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    for ref in data["honkRefs"] as? [DocumentReference] ?? [DocumentReference](){
                        self.dislikedHonkRefs.append(ref)
                    }
                }
                self.getDislikedHonks()
            }
        }
    }
    
    func addUserHonkRef(honkRef: DocumentReference){
        let db = Firestore.firestore()
        db.collection("Users").document(Auth.auth().currentUser?.uid ?? "").updateData(["honkRefs": FieldValue.arrayUnion([honkRef])])
        userHonkRefs.append(honkRef)
    }
    
    func addLikedHonkRef(honkRef: DocumentReference){
        let db = Firestore.firestore()
        db.collection("Users").document(Auth.auth().currentUser?.uid ?? "").updateData(["likedRefs": FieldValue.arrayUnion([honkRef])])
        userHonkRefs.append(honkRef)
    }
    
    func addUserHonk(userHonk: HonkModel){
        self.userHonks.append(userHonk)
    }
    
    func addLikedHonk(likedHonk: HonkModel){
        self.likedHonks.append(likedHonk)
    }
    
    func getUserHonks(){
        self.userHonks = [HonkModel]()
        for honkRef in self.userHonkRefs {
            honkRef.getDocument { (doc, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let doc = doc, doc.exists {
                    let data = doc.data()
                    if let data = data {
                        self.userHonks.append(HonkModel(id: doc.documentID,
                                                        ref: doc.reference,
                                                        honk: data["honk"] as? String ?? "",
                                                        netLikes: data["netLikes"] as? Int ?? 0,
                                                        authorID: data["authorID"] as? String ?? "",
                                                        authorName: data["authorName"] as? String ?? "",
                                                        datePosted: data["datePosted"] as? Timestamp ?? Timestamp()))
                    }
                }
            }
        }
    }
    
    func getLikedHonks(){
        self.likedHonks = [HonkModel]()
        for honkRef in self.likedHonkRefs {
            honkRef.getDocument { (doc, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let doc = doc, doc.exists {
                    let data = doc.data()
                    if let data = data {
                        self.likedHonks.append(HonkModel(id: doc.documentID,
                                                         ref: doc.reference,
                                                         honk: data["honk"] as? String ?? "",
                                                         netLikes: data["netLikes"] as? Int ?? 0,
                                                         authorID: data["authorID"] as? String ?? "",
                                                         authorName: data["authorName"] as? String ?? "",
                                                         datePosted: data["datePosted"] as? Timestamp ?? Timestamp()))
                    }
                }
            }
        }
    }
    
    func getDislikedHonks(){
        self.dislikedHonks = [HonkModel]()
        for honkRef in self.dislikedHonkRefs {
            honkRef.getDocument { (doc, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let doc = doc, doc.exists {
                    let data = doc.data()
                    if let data = data {
                        self.dislikedHonks.append(HonkModel(id: doc.documentID,
                                                            ref: doc.reference,
                                                            honk: data["honk"] as? String ?? "",
                                                            netLikes: data["netLikes"] as? Int ?? 0,
                                                            authorID: data["authorID"] as? String ?? "",
                                                            authorName: data["authorName"] as? String ?? "",
                                                            datePosted: data["datePosted"] as? Timestamp ?? Timestamp()))
                    }
                }
            }
        }
    }
}
