//
//  RectangleTextView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-21.
//

import SwiftUI


struct TextInsideRectangle: View {
    var text: String
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .stroke(Color.black, lineWidth: 5)
            .frame(maxWidth: .greatestFiniteMagnitude)
            .overlay(
                Text(text)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .font(.title)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            ).padding()
    }
}


struct RectangleTextView: View {
    var body: some View {
        VStack(spacing: 10) {
            TextInsideRectangle(text: "English")
            TextInsideRectangle(text: "Spanish")
            TextInsideRectangle(text: "Suggestions")
        }
        .padding()
    }
}

#Preview {
    RectangleTextView()
}
