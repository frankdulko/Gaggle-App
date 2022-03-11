//
//  GaggleApp.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import SwiftUI
import UIKit
import Firebase

@main
struct GaggleApp: App {
    
    @StateObject var memoryModel = MemoryModel()
    @StateObject var viewRouter = ViewRouter()
    
    init(){
        FirebaseApp.configure()
//        UITabBar.appearance().isTranslucent = false
//        UITabBar.appearance().barTintColor = UIColor(Color.gaggleGray)
//        UITabBar.appearance().tintColor = UIColor(Color.gaggleGreen)
        
    }
    
    var body: some Scene {
        WindowGroup {
            MotherView()
                .environmentObject(memoryModel)
                .environmentObject(viewRouter)
        }
    }
}
