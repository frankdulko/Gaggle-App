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
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                        .font(.caption2)
                }
                .padding()
                //.background(Color(UIColor.systemRed).cornerRadius(10))
                //.padding()
                Spacer()
            }
            TextEditor(text: $post)
                .padding()
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
                    userModel.addHonk(honk: post)
                    model.addData(name: post, location: memoryModel.user.location)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Send")
                        .foregroundColor(Color.gaggleGray)
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.up")
                        .foregroundColor(.black)
                }
                .padding()
                .background(
                    Color.gaggleGreen.cornerRadius(10)
                )
                .padding()
                .cornerRadius(10)
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
