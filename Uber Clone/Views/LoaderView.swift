//
//  LoaderView.swift
//  Uber Clone
//
//  Created by Yauheni Bunas on 5/31/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SwiftUI

struct LoaderView: View {
    @State var show = false
    
    var body: some View {
        GeometryReader {_ in
            VStack(spacing: 20) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.init(degrees: self.show ? 360 : 0))
                    .onAppear {
                        withAnimation(Animation.default.speed(0.45).repeatForever(autoreverses: false)) {
                            self.show.toggle()
                        }
                    }
                
                Text("Please Wait...")
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 40)
            .background(Color.white)
            .cornerRadius(12)
        }
        .background(Color.black.opacity(0.25).edgesIgnoringSafeArea(.all ))
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
