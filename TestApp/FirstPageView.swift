//
//  FirstPageView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-18.
//

import SwiftUI

struct FirstPageView: View {
    var body: some View {
        VStack {
            Text("This is the First Page")
                .font(.largeTitle)
                .padding()

            NavigationLink(destination: FinalPageView()) {
                Text("Go to Final Page")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("First Page")
    }
}

#Preview {
    FirstPageView()
}
