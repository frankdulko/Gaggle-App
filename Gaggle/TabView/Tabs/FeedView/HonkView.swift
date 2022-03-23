//
//  HonkView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI


struct HonkView: View{
    
    @State var honk = HonkModel(id: "", honk: "", netLikes: 0, authorID: "", authorName: "", datePosted: Date(), imageURL: "")
    @State var liked = false
    @State var disliked = false
    
    @EnvironmentObject var memoryModel: MemoryModel
    
    @ObservedObject var userModel : UserUpdateModel
    @ObservedObject var model : FeedModel


    func actionSheet() {
           guard let urlShare = URL(string: "https://developer.apple.com/xcode/swiftui/") else { return }
           let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
           UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
       }
    
    var body: some View {
        HStack{
            VStack{
                Spacer()
                WebImage(url: URL(string: model.urls[honk.authorID] ?? ""))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading, 10)
            }
        HStack{
            VStack(alignment: .leading){
                Text(honk.authorName)
                    .padding([.top, .leading], 20)
                    //.font(Font.custom("MADE Tommy Soft Light PERSONAL USE", size: 18))
                Text(honk.honk)
                    .padding(.leading, 25)
                    .font(Font.custom("MADE Tommy Soft Light PERSONAL USE", size: 18))
                Spacer()
                Menu {
                    Text(Date().formatted(date: .abbreviated, time: .complete))
                    Button(action: actionSheet){
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                } label :{
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(UIColor.systemGray))
                }
                .padding()
            }
            Spacer()
            VStack(alignment: .center){
                Button {
                    if(userModel.firuser.likes.contains(honk.id)){
                        liked = true
                        disliked = false
                    }
                    if (!liked){
                        if (userModel.firuser.dislikes.contains(honk.id)){
                            userModel.deleteDislike(honk: honk)
                            model.addLike(honk: honk, location: memoryModel.user.location)
                            honk.netLikes += 1
                            print("Deleting dislike \(honk.id)")
                        }
                        //honk.netLikes = netLikes + 1
                        //model.updateNetLikes(honkToUpdate: honk, location: memoryModel.user.location)
                        honk.netLikes += 1
                        model.addLike(honk: honk, location: memoryModel.user.location)
                        userModel.addLikes(honk: honk)
                        liked = true
                        disliked = false
                    }
                } label: {
                    if (liked == true && disliked == false) || (userModel.firuser.likes.contains(honk.id)){
                        Image("chevron_up_on")
                            .resizable()
                            .frame(width: 25, height: 15)
                    }
                    else {
                        Image("chevron_up")
                            .resizable()
                            .frame(width: 25, height: 15)
                        }
                }
                .padding()
                Text(String(honk.netLikes))
                    .font(Font.custom("aAkhirTahun", size: 18))
                Button {
                    if (userModel.firuser.dislikes.contains(honk.id)){
                        liked = false
                        disliked = true
                    }
                    if (!disliked){
                        if(userModel.firuser.likes.contains(honk.id)){
                            userModel.deleteLike(honk: honk)
                            model.addDislike(honk: honk, location: memoryModel.user.location)
                            honk.netLikes -= 1
                            print("Deleting like \(honk.id)")
                        }
                        //honk.netLikes = netLikes - 1
                        //model.updateNetLikes(honkToUpdate: honk, location: memoryModel.user.location)
                        honk.netLikes -= 1
                        model.addDislike(honk: honk, location: memoryModel.user.location)
                        userModel.addDislikes(honk: honk)
                        liked = false
                        disliked = true
                    }
                } label: {
                    if (liked == false && disliked == true) || (userModel.firuser.dislikes.contains(honk.id)) {
                        Image("chevron_down_on")
                            .resizable()
                            .frame(width: 25, height: 15)
                        
                    }
                    else {
                        Image("chevron_down")
                            .resizable()
                            .frame(width: 25, height: 15)
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.cornerRadius(20).shadow(color: Color(UIColor.systemGray5), radius: 5, x: 0, y: 10))
        }
        .padding([.top,.bottom], 5)
        .onAppear {
            model.getURL(authorID: honk.authorID)
        }
    }
}

struct HonkView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(feedModel: FeedModel(user: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs()), userModel: UserUpdateModel()).environmentObject(MemoryModel())
    }
}

