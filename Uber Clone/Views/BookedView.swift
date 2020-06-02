//
//  BookedView.swift
//  Uber Clone
//
//  Created by Yauheni Bunas on 5/31/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI
import Firebase

struct BookedView: View {
    @Binding var data: Data
    @Binding var doc: String
    @Binding var loading: Bool
    @Binding var booked: Bool
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 25) {
                Image(uiImage: UIImage(data: self.data)!)
                
                Button(action:{
                    self.loading.toggle()
                    self.booked.toggle()
                    
                    let db = Firestore.firestore()
                    db.collection("Booking").document(self.doc).delete() { (error) in
                        if error != nil {
                            print((error?.localizedDescription)!)
                            
                            return
                        }
                        
                        self.loading.toggle()
                    }
                }) {
                    Text("Cancel")
                        .foregroundColor(Color.white)
                        .padding(.vertical, 10)
                        .frame(width: UIScreen.main.bounds.width / 2)
                }
                .background(Color.red)
                .clipShape(Capsule())
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
        .background(Color.black.opacity(0.25).edgesIgnoringSafeArea(.all))
    }
}
