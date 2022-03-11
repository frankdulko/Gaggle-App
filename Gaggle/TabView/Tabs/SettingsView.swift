//
//  SettingsView.swift
//  Gaggle
//
//  Created by Frank Dulko on 3/7/22.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var viewRouter: ViewRouter

    @State var signOutProcessing = false

    var body: some View {
        NavigationView{
            VStack{
                List{
                    NavigationLink("Display Name"){
                        
                    }
                    NavigationLink("E-mail"){
                        
                    }
                    NavigationLink("Change Password"){
                        
                    }
                }
                .listStyle(.plain)
                if signOutProcessing {
                    ProgressView()
                } else {
                    Button {
                        signOutUser()
                    } label: {
                        Text("Sign Out")
                    }
                    .padding([.leading,.trailing], 10)
                }
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
            Button(action: {
                viewRouter.currentPage = .homePage
            }, label: {
                Text("Back")
            }))
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
