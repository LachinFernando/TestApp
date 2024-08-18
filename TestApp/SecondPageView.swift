//
//  SecondPageView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-18.
//

import SwiftUI

struct SecondPageView: View {
    var body: some View {
        VStack {
            Text("This is the Second Page")
                .font(.largeTitle)
                .padding()
        }
        .navigationTitle("Second Page")
    }
}

#Preview {
    SecondPageView()
}
