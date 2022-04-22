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
    @State var honks = true
    @State var likes = false
    @State var dislikes = false
    @State var showMyHonks = false
    
    @ObservedObject var userModel : UserUpdateModel
    @ObservedObject var feedModel : FeedModel
    @ObservedObject var userHonkRefsObs : UserHonkRefsObs

    var body: some View {
        ZStack{
            VStack {
                //gaggleTitleView()
                HStack(alignment: .top){
                    WebImage(url: URL(string: userModel.firuser.profilePictureURL))
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .scaledToFill()
                    VStack(alignment: .leading){
                        Text(userModel.firuser.displayName)
                            .font(Font.custom("CreatoDisplay-Bold", size: 30))
                            .padding()
                        HStack{
                            Spacer()
                            VStack{
                                Text("Honks")
                                    .font(Font.custom("CreatoDisplay-Regular", size: 20))
                                Text(String(userModel.firuser.honkRefs.count))
                                    .font(Font.custom("aAkhirTahun", size: 20))
                            }
                            Spacer()
                            VStack{
                                Text("Score")
                                    .font(Font.custom("CreatoDisplay-Regular", size: 20))
                                Text(String(userModel.firuser.karma))
                                    .font(Font.custom("aAkhirTahun", size: 20))

                            }
                            Spacer()
                        }
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            //viewRouter.currentPage = .settingsPage
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }

                }
                .padding([.leading, .trailing], 10)
                Divider()
                    .padding([.leading, .trailing], 10)
                HStack{
                    Button(action: {
                        self.showMyHonks.toggle()
                    }, label: {
                        Text("My Honks")
                            .textCase(.uppercase)
                            .font(Font.custom("CreatoDisplay-Black", size: 16))
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                    })
                    .sheet(isPresented: $showMyHonks, content: {
                        myHonksView(userModel: userModel, feedModel: feedModel, userHonkRefsObs: userHonkRefsObs)
                    })
                    .padding()
                    Spacer()
                }
                Spacer()
//                Text("Honks")
//                    .font(Font.custom("CreatoDisplay-Bold", size: 20))
//                Divider()
//                ScrollView{
//                    VStack{
//                        ForEach(userHonkRefsObs.userHonks, id: \.id) { honk in
//                            HonkView(honk: honk, userModel: userModel, model: feedModel)
//                        }
//                    }
//                }
//                HStack{
//                    Spacer()
//                    Text("Honks")
//                        .font(Font.custom("LouisGeorgeCafeBold", size: 20))
//                        .background(honks ? .gray : .white)
//                    Spacer()
//                    Text("Likes")
//                        .font(Font.custom("LouisGeorgeCafeBold", size: 20))
//                        .background(likes ? .gray : .white)
//                    Spacer()
//                    Text("Dislikes")
//                        .font(Font.custom("LouisGeorgeCafeBold", size: 20))
//                        .background(dislikes ? .gray : .white)
//                    Spacer()
//                }
//                TabView{
//                    ScrollView{
//                            VStack{
//                                ForEach(userHonkRefsObs.userHonks, id: \.id) { honk in
//                                    HonkView(honk: honk, userModel: userModel, model: feedModel)
//                                }
//                            }
//                    }
//                    .tabItem{}
//                    .onAppear {
//                        withAnimation{
//                            honks = true
//                            likes = false
//                            dislikes = false
//                        }
//                    }
//                    ScrollView{
//                            VStack{
//                                ForEach(userHonkRefsObs.likedHonks, id: \.id) { honk in
//                                    HonkView(honk: honk, userModel: userModel, model: feedModel)
//                                }
//                            }
//                    }
//                    .tabItem {}
//                    .onAppear {
//                        withAnimation{
//                            honks = false
//                            likes = true
//                            dislikes = false
//                        }
//                    }
//                }
//                .tabViewStyle(.page)
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
            .position(x: 95, y: 85)

        }
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image, userModel: userModel, feedModel: feedModel)
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
