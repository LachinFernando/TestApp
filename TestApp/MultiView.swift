//
//  MultiView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-18.
//

import SwiftUI

struct MultiView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Try Out Navigation")
                // First Page Navigation
                NavigationLink(destination: FirstPageView()) {
                    Text("Go to First Page")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Second Page Navigation
                NavigationLink(destination: SecondPageView()) {
                    Text("Go to Second Page")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                Text("This is Navigation Test")
            }
            .navigationTitle("Home Page")
        }
    }
}

#Preview {
    MultiView()
}
