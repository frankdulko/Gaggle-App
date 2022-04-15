//
//  SignUpView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/27/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    
    @State var email: String = ""
    @State var displayName: String = ""
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    @State var signUpErrorMessage = ""

    
    @State var signUpProcessing = false
    @EnvironmentObject var viewRouter : ViewRouter
    @ObservedObject var userModel : UserUpdateModel
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            VStack{
                Group{
                    Image("gaggle-icon-clear")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 200, height: 200)
                Text("Welcome")
                    .font(Font.custom("Hamish", size: 60))
                    .foregroundColor(Color.gaggleGray)
                TextField("Display Name", text: $displayName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
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
                SecureField("Confirm Password", text: $passwordConfirmation)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                Button {
                    signUpUser(displayName: displayName, userEmail: email, userPassword: password)
                } label: {
                    LoginButton(text: "SIGN UP")
                }
                .disabled(!signUpProcessing && !displayName.isEmpty && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && password == passwordConfirmation ? false : true)
                if signUpProcessing {
                    ProgressView()
                }
                if !signUpErrorMessage.isEmpty {
                    Text("Failed creating account: \(signUpErrorMessage)")
                        .foregroundColor(.red)
                }
                HStack{
                    Text("Already have an account?")
                    Button {
                        viewRouter.currentPage = .signInPage
                    } label: {
                        Text("Sign In")
                    }
                }
            }
            .padding()
        }
    }
    
    func signUpUser(displayName: String, userEmail: String, userPassword: String){
        signUpProcessing = true
        Auth.auth().createUser(withEmail: userEmail, password: userPassword){ authResult, error in
            guard error == nil else {
                signUpErrorMessage = error!.localizedDescription
                signUpProcessing = false
                return
            }
            
            switch authResult {
                case .none:
                    print("Could not create account.")
                    signUpProcessing = false
                case .some(_):
                    userModel.addUser(displayName: displayName)
                    userModel.getProfilePictureURL()
                    print("User created")
                    signUpProcessing = false
                    viewRouter.currentPage = .homePage
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(userModel: UserUpdateModel())
    }
}
