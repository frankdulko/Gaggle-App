//
//  ContentView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var feedModel : FeedModel
    @ObservedObject var userHonkRefsObs : UserHonkRefsObs
    @ObservedObject var userUpdateModel : UserUpdateModel

    @State private var selection = 2
    
    var body: some View {
        TabView(selection: $selection){
            MapView(currentLocation: locationManager, feedModel: feedModel)
                .tabItem{
                    Label("", systemImage: "mappin.and.ellipse")
                }
                .tag(1)
            FeedView(feedModel: feedModel, userModel: userUpdateModel)
                .tabItem {
                    Label("", systemImage: "rectangle.grid.1x2.fill")
                }
                .tag(2)
            ProfileView(userModel: userUpdateModel, feedModel: feedModel, userHonkRefsObs: userHonkRefsObs)
                .tabItem{
                    Label("", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .accentColor(Color.gaggleGray)
    }
    
    init(userUpdateModel: UserUpdateModel, userHonkRefsObs: UserHonkRefsObs){
        print("Content View init")
        self._feedModel = StateObject(wrappedValue: FeedModel(user: userUpdateModel, userHonkRefsObs: userHonkRefsObs))
        self.userUpdateModel = userUpdateModel
        self.userHonkRefsObs = userHonkRefsObs
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userUpdateModel: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs())
    }
}
