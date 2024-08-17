//
//  RandomNameView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-13.
//

import SwiftUI
import SwiftyJSON
import Alamofire
//import Alamofire

struct RandomSportsView: View {
    
    let activities = [
        "Archery",
        "Baseball",
        "Basketball",
        "Bowling",
        "Boxing",
        "Cricket",
        "Curling",
        "Fencing",
        "Golf",
        "Hiking",
        "Lacrosse",
        "Rugby",
        "Squash"
    ]
    
    @State private var selected = "Archery"
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
            VStack {
                Text("Sports Generator")
                    .font(.system(size: 40, weight: .bold))
                Circle()
                    .fill(.blue)
                    .padding()
                    .overlay(
                        Image(systemName: "figure.\(selected.lowercased())")
                            .font(.system(size: 144))
                            .foregroundColor(.white)
                    )
                Text("\(selected)!")
                    .font(.system(size: 40, weight: .light, design: .rounded))
                Button("Random Sport Selector") {
                    selected = activities.randomElement() ?? activities[0]
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
        }
    }
}

#Preview {
    RandomSportsView()
}
