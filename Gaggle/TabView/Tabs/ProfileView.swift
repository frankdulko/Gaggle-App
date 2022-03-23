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
    @ObservedObject var userHonkRefsObs : UserHonkRefsObs

    var body: some View {
        ZStack{
            VStack {
                gaggleTitleView()
                HStack(alignment: .top){
                    WebImage(url: URL(string: userModel.firuser.profilePictureURL))
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .scaledToFill()
                        
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
                .padding([.leading, .trailing], 10)
                HStack{
                    Spacer()
                    VStack{
                        Text("Honks")
                        Text(String(userModel.firuser.honkRefs.count))
                    }
                    Spacer()
                    VStack{
                        Text("Score")
                        Text(String(userModel.firuser.karma))
                    }
                    Spacer()
                }
                .font(.title2)
                //Image(systemName: memoryModel.user.profilePicture)
                Divider()
                    .padding([.leading, .trailing], 10)
                ScrollView{
                        VStack{
                            ForEach(userHonkRefsObs.userHonks, id: \.id) { honk in
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
            .background(Color(UIColor.systemBlue).cornerRadius(50).shadow(color: Color(UIColor.systemGray), radius: 5, x: 3, y: 3))
            .foregroundColor(.white)
            .position(x: 95, y: 165)

        }
        .onAppear {
            //userModel.setUser(uid: Auth.auth().currentUser?.uid ?? "")
            //userModel.getProfilePictureURL()
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
        ProfileView(userModel: UserUpdateModel(), feedModel: FeedModel(user: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs()), userHonkRefsObs: UserHonkRefsObs()).environmentObject(MemoryModel())
    }
}
