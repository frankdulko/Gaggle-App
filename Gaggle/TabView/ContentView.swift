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
    @ObservedObject var userUpdateModel : UserUpdateModel
    @StateObject var feedModel : FeedModel
    
    var body: some View {
        TabView{
            MapView(currentLocation: locationManager)
                .tabItem{
                    Label("", systemImage: "mappin.and.ellipse")
                }
            FeedView(feedModel: feedModel, userModel: userUpdateModel)
                .tabItem {
                    Label("", systemImage: "rectangle.grid.1x2.fill")
                }
            ProfileView(userModel: userUpdateModel, feedModel: feedModel)
                .tabItem{
                    Label("", systemImage: "person.crop.circle")
                }
        }
        .accentColor(Color.gaggleGray)
    }
    
    init(userUpdateModel: UserUpdateModel){
        self._feedModel = StateObject(wrappedValue: FeedModel(user: userUpdateModel))
        self.userUpdateModel = userUpdateModel
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userUpdateModel: UserUpdateModel())
    }
}
