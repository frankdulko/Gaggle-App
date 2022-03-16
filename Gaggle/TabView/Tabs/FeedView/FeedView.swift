//
//  FeedView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//
import UIKit
import SwiftUI
import Firebase

struct FeedView: View {
    @EnvironmentObject var memoryModel : MemoryModel
    
    @ObservedObject var feedModel : FeedModel
    @ObservedObject var userModel : UserUpdateModel
    
    var body: some View {
            ZStack{
                if(memoryModel.user.checkedIn){
//              if(true){
                    VStack{
                        gaggleTitleView()
                        HStack{
                            Spacer()
                            Text(memoryModel.user.location)
                                .font(.headline)
                                .padding()
                            Spacer()
                            Menu{
                                Text("Sort by:")
                                Button {
                                    
                                } label: {
                                    Text("New")
                                }
                                Button {
                                    
                                } label: {
                                    Text("Top")
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 25, height: 15)
                                    .foregroundColor(.black)
                            }
                            .padding()
                        }
                        ScrollView{
                                VStack{
                                    ForEach(feedModel.feed, id: \.id) { honk in
                                        HonkView(honk: honk, userModel: userModel, model: feedModel)
                                    }
                                }
                            }
                        }
                    postButtonView(feedModel: feedModel, userModel: userModel)
                }
                else{
                    VStack {
                        gaggleTitleView()
                        Spacer()
                        Text("Join a location's Gaggle to participate")
                            .font(Font.largeTitle)
                            .padding()
                        Spacer()
                    }
                }
            }
            .onAppear {
                if (memoryModel.user.checkedIn){
                    feedModel.getData(location: memoryModel.user.location)
                }
            }
    }
        
//    init(feedModel: FeedModel, userModel: UserUpdateModel){
//        @EnvironmentObject var memoryModel : MemoryModel
//
//        self.feedModel = feedModel
//        self.userModel = userModel
//        self.feedModel.getData(location: memoryModel.user.location)
//    }
}


struct gaggleTitleView: View{
    var body: some View {
        HStack(alignment: .center) {
            Text("Gaggle")
                .font(Font.custom("Hamish", size: 48))
                .padding()
        }
        //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 75, alignment: .center)
        //.background(
//            LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing))
    }
}

//struct checkedInView: View{
//    @EnvironmentObject var memoryModel: MemoryModel
//    @State var showWriteView = false
//    @ObservedObject var model = FeedModel()
//
//    var body: some View {
//        VStack{
//            gaggleTitleView()
//            Text(memoryModel.user.location)
//                .font(.headline)
//                .padding()
//            ScrollView{
//                    VStack{
//                        ForEach(model.feed) { honk in
//                            HonkView(honk: honk, netLikes: honk.netLikes)
//                        }
//                    }
//                }
//            }
//    }
//}

struct postButtonView: View{
    @State var showWriteView = false
    @ObservedObject var feedModel : FeedModel
    @ObservedObject var userModel : UserUpdateModel

    var body: some View {
        Button(action: {
            self.showWriteView.toggle()
        }, label: {
            Image("gaggle-icon-clear")
                .resizable()
                .scaledToFit()
                .padding(.all, 10)
        })
    .sheet(isPresented: $showWriteView, content: {
        WriteView(model: feedModel, userModel: userModel)
    })
    .frame(width: 70, height: 70)
    .background(
        LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing).cornerRadius(70).shadow(color: Color(UIColor.systemGray5), radius: 5, x: 0, y: 10))
    .position(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 200)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(feedModel: FeedModel(user: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs()), userModel: UserUpdateModel()).environmentObject(MemoryModel())
    }
}
