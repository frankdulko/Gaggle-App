//
//  LogInView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/27/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignInView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var signInProcessing = false
    @State var signInErrorMessage = ""
    
    @EnvironmentObject var viewRouter : ViewRouter
    @ObservedObject var userModel : UserUpdateModel
    @ObservedObject var userHonkRefsObs : UserHonkRefsObs

    var body: some View {
            VStack {
                Group{
                    Image("gaggle-icon-clear")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 200, height: 200)
                .padding()
                Text("Welcome")
                    .font(Font.custom("Hamish", size: 60))
                    .foregroundColor(Color.gaggleGray)
                TextField("E-mail", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
                    .autocapitalization(UITextAutocapitalizationType.none)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                Button  {
                    signInUser(userEmail: email, userPassword: password)
                } label: {
                    LoginButton(text: "SIGN IN")
                }
                .disabled(!signInProcessing && !email.isEmpty && !password.isEmpty ? false : true)
                if signInProcessing {
                    ProgressView()
                }
                if !signInErrorMessage.isEmpty {
                    Text("Failed creating account: \(signInErrorMessage)")
                        .foregroundColor(.red)
                }
                Spacer()
                HStack{
                    Text("Don't have an account?")
                    Button {
                        viewRouter.currentPage = .signUpPage
                    } label: {
                        Text("Sign Up")
                    }

                }
            }
            .padding()
            .background(
                LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing)
                )
        
    }
    
    func signInUser(userEmail: String, userPassword: String) {
        
        signInProcessing = true
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                signInProcessing = false
                signInErrorMessage = error!.localizedDescription
                return
            }
            switch authResult {
                case .none:
                    print("Could not sign in user.")
                    signInProcessing = false
                case .some(_):
                    print("User signed in")
                    userModel.setUser()
                    userModel.getProfilePictureURL()
                    userModel.getHonks()
                    userHonkRefsObs.getUserHonkRefs()
                    signInProcessing = false
                    withAnimation {
                        viewRouter.currentPage = .homePage
                    }
            }
               
           }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(userModel: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs())
    }
}

struct LoginButton: View {
    
    var text = ""
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.gaggleGray)
            .cornerRadius(15.0)
    }
}
