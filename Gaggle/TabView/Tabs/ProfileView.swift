//
//  ProfileView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var memoryModel:MemoryModel
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var signOutProcessing = false
    @State private var image = UIImage()
    @State private var showSheet = false
    
    @ObservedObject var userModel : UserUpdateModel
    @ObservedObject var feedModel : FeedModel

    var body: some View {
        ZStack{
            VStack{
                gaggleTitleView()
                HStack(){
                    WebImage(url: userModel.firuser.profilePictureURL)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .background(Color.gaggleGray.cornerRadius(200))
                        .clipShape(Circle())
                        
        //            Text(userModel.firuser.displayName ?? "Frank")
        //                .font(.system(size: 48))
                    Text(userModel.firuser.displayName)
                        .font(.system(size: 36))
                    Spacer()
//                    Menu(systemName: "gearshape"){
//                        Button {
//                            
//                        } label: {
//                            Text("Sign Out")
//                        }
//
//                    }
                    Button {
                        withAnimation {
                            viewRouter.currentPage = .settingsPage
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }

//                    if signOutProcessing {
//                        ProgressView()
//                    } else {
//                        Button {
//                            signOutUser()
//                        } label: {
//                            Text("Sign Out")
//
//                        }
//                        .padding([.leading,.trailing], 10)
//                    }
                }
                .padding()
                HStack{
                    Spacer()
                    VStack{
                        Text("Honks")
                        Text(String(userModel.firuser.honks.count))
                    }
                    Spacer()
                    VStack{
                        Text("Score")
                        Text(String(userModel.firuser.karma))
                    }
                    Spacer()
                }
                .padding()
                .font(.title2)
                //Image(systemName: memoryModel.user.profilePicture)
                Divider()
                    .padding()
                ScrollView{
                        VStack{
                            ForEach(userModel.userHonks, id: \.id) { honk in
                                HonkView(honk: honk, userModel: userModel, model: feedModel)
                            }
                        }
                }
                Spacer()
            }
            Button {
                showSheet = true
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .frame(width: 30, height: 30)
            .background(Color(UIColor.systemBlue).cornerRadius(50).shadow(color: Color(UIColor.systemGray), radius: 5, x: 5, y: 10))
            .foregroundColor(.white)
            .position(x: 95, y: 195)

        }
        .onAppear {
            //userModel.setUser(uid: Auth.auth().currentUser?.uid ?? "")
        }
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image, userModel: userModel)
        }
    }
    
    
    func signOutUser() {
        signOutProcessing = true
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        withAnimation {
            viewRouter.currentPage = .signInPage
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userModel: UserUpdateModel(), feedModel: FeedModel(user: UserUpdateModel())).environmentObject(MemoryModel())
    }
}
