//
//  ListView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-09-10.
//

import SwiftUI

struct ListView: View {
    private var names: [String] = ["A", "B", "C"]
    
    // Define your list of strings
    let strings = ["Hello", "World", "SwiftUI", "is", "awesome"]
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    //                        // Create a List view and loop through the strings
                    //                        List(strings, id: \.self) { string in
                    //                            Text(string) // Display each string in a Text view
                    //                        }
                    //                        .navigationTitle("List of Strings")
                    ForEach(strings, id:\.self){ userName in
                        Text(userName)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        Divider()
                    }
                }
            }
        }
    }
}

#Preview {
    ListView()
}
