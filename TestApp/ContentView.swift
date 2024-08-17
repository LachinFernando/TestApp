//
//  ContentView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-12.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.9)
                .ignoresSafeArea()
            VStack {
                Text("learner Permit")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Image("monaLisa")
                    .resizable()
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                    .scaledToFit()
                Text("Mona Lisa")
                    .font(.system(size: 40, weight: .light, design: .rounded))
                Text("Hello World!").font(.system(size: 40))
            }
            .padding()
            
        }
    }
}

#Preview {
    ContentView()
}
