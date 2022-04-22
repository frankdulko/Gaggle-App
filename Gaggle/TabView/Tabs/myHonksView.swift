//
//  myHonksView.swift
//  Gaggle
//
//  Created by Frank Dulko on 4/20/22.
//

import SwiftUI

struct myHonksView: View {
    
    @ObservedObject var userModel : UserUpdateModel
    @ObservedObject var feedModel : FeedModel
    @ObservedObject var userHonkRefsObs : UserHonkRefsObs
    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        VStack{
            //gaggleTitleView()
            VStack{
                HStack{
                    Text("My Honks")
                        .foregroundColor(Color.gaggleGray)
                        .multilineTextAlignment(.leading)
                        .font(Font.custom("CreatoDisplay-Black", size: 30))
                        .textCase(.uppercase)
                        .padding()
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Back")
                            .textCase(.uppercase)
                            .font(Font.custom("CreatoDisplay-Black", size: 16))
                            .padding()
                            .foregroundColor(Color.gaggleGray)
                    }
                    .padding()
                }
                ScrollView{
                    VStack{
                        ForEach(userHonkRefsObs.userHonks, id: \.id) { honk in
                            HonkView(honk: honk, userModel: userModel, model: feedModel)
                        }
                    }
                    .padding(.top)
                }
                .background(Color(UIColor.systemGray6))
                .ignoresSafeArea()
            }
        }
    }
}

struct myHonksView_Previews: PreviewProvider {
    static var previews: some View {
        myHonksView(userModel: UserUpdateModel(), feedModel: FeedModel(user: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs()), userHonkRefsObs: UserHonkRefsObs())
    }
}
