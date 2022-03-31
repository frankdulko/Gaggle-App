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
    @StateObject var userHonkRefsObs = UserHonkRefsObs()
    
    
    var body: some View {
        switch viewRouter.currentPage {
            case .signUpPage:
                SignUpView(userModel: userUpdateModel)
            case .signInPage:
                SignInView(userModel: userUpdateModel, userHonkRefsObs: userHonkRefsObs)
            case .homePage:
                ContentView(userUpdateModel: userUpdateModel, userHonkRefsObs: userHonkRefsObs)
            case .settingsPage:
                SettingsView(userUpdateModel: userUpdateModel, userHonkRefsObs: userHonkRefsObs)
        }
    }
}

struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MotherView().environmentObject(ViewRouter())
    }
}
