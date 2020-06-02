//
//  MenuView.swift
//  HamburgerMenu
//
//  Created by Yauheni Bunas on 6/1/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @Binding var isShowMenu: Bool
    
    var body: some View {
        HStack {
            VStack() {
                HStack() {
                    VStack(alignment: .leading) {
                        Text("+375-29-000-00-00")
                            .padding()
                            .font(.headline)
                            .multilineTextAlignment(.leading)

                        Text("email@gmail.com")
                            .padding()
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(alignment: .leading)
                    
                    Spacer()
                }
                .padding(.top, 40)
                .foregroundColor(Color.white)
                .background(Color.black)
                
                VStack(alignment: .leading) {
                    Text("Profile")
                        .padding()
                    
                    Text("Setting")
                        .padding()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .foregroundColor(.primary)
            .frame(width: UIScreen.main.bounds.width / 1.5)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .overlay(Rectangle().stroke(Color.primary.opacity(0.2), lineWidth: 2).shadow(radius: 3).edgesIgnoringSafeArea(.all))
            
            Spacer(minLength: 0)
        }
    }
}
