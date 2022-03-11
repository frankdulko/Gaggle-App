//
//  MotherView.swift
//  AuthenticationStarter
//
//  Created by Work on 13.12.21.
//

import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var userUpdateModel = UserUpdateModel()
    
    
    var body: some View {
        switch viewRouter.currentPage {
            case .signUpPage:
                SignUpView(userModel: userUpdateModel)
            case .signInPage:
                SignInView(userModel: userUpdateModel)
            case .homePage:
                ContentView(userUpdateModel: userUpdateModel)
            case .settingsPage:
                SettingsView()
        }
    }
}

struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MotherView().environmentObject(ViewRouter())
    }
}
