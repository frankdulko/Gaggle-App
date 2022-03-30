//
//  WriteView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import SwiftUI
import FirebaseAuth

struct WriteView: View {
    @EnvironmentObject var memoryModel: MemoryModel
    @State private var placeholder = "What's happening?"
    @State private var post = "What's happening?"
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var model : FeedModel
    @ObservedObject var userModel : UserUpdateModel
    
//    init() {
//        UITextView.appearance().backgroundColor = .clear
//    }

    var body: some View {
        VStack{
            HStack() {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("CANCEL")
                        .font(Font.custom("CreatoDisplay-Bold", size: 14))
                        .foregroundColor(.black)
                }
                .padding()
                //.background(Color(UIColor.systemRed).cornerRadius(10))
                //.padding()
                Spacer()
            }
            TextEditor(text: $post)
                .padding()
                .font(Font.custom("CreatoDisplay-Bold", size: 18))
                .frame(width: UIScreen.main.bounds.width-50, height: 150)
                .background(Color.white.cornerRadius(20))
                .onTapGesture {
                    if self.post == placeholder {
                    self.post = ""
                    }
                }
            HStack{
                Spacer()
                Button {
                    model.addData(name: post, location: memoryModel.user.collection)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("POST")
                        .font(Font.custom("CreatoDisplay-Black", size: 20))
                        .foregroundColor(Color.gaggleGray)
                        .padding([.leading,.trailing])
                        .padding([.top, .bottom], 5)
                }
                .background(
                    LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing).cornerRadius(10)
                )
                .padding()
            }
            Spacer()
        }

        
        .background(
            Color(UIColor.systemGray6)
            )
           //LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing))
    }
}

struct WriteView_Previews: PreviewProvider {
    static var previews: some View {
        WriteView(model: FeedModel(user: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs()), userModel: UserUpdateModel()).environmentObject(MemoryModel())
    }
}
