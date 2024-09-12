//
//  ChatBotView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-09-11.
//

import SwiftUI
import Foundation
import Combine
import Alamofire
import SwiftyJSON


struct ImageIcon: View {
    var imageName: String
    var cornerSize: CGFloat = 30
    
    var body: some View {
        Image(systemName: "\(imageName)")
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(cornerSize)
    }
}


struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    var text: String
    var isLoading: Bool = false
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(isUser: false, text: "Hello, How can I help you today?")
    ]
    private var chatEndpoint = "https://dt6ts2p7gf.execute-api.us-east-1.amazonaws.com/simpleChat/ChatBot"
    private var chatRagEndppoint = "https://dt6ts2p7gf.execute-api.us-east-1.amazonaws.com/simpleChat/ChatBotRag"
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(isUser: true, text: text)
        messages.append(userMessage)
        
        // Show a loading message
        var loadingMessage = ChatMessage(isUser: false, text: "Typing...", isLoading: true)
        messages.append(loadingMessage)
        
        let createPayload: [String: Any] = [
            "httpMethod":"POST",
            "body": [
                "query": text
                ]
        ]
         // Make API call
        AF.request(
            chatRagEndppoint,
            method: .post,
            parameters: createPayload,
            encoding: JSONEncoding.default
            
        )
        .responseJSON{
            response in
            switch response.result {
            case .success(let value):
                let json  = JSON(value)
                let answer = json["data"]["answer"].stringValue
                self.messages.removeLast() // Remove the loading message
                loadingMessage.text = answer
                loadingMessage.isLoading = false
                self.messages.append(loadingMessage)
            case .failure(let error):
                let message = "Error: \(error.localizedDescription)"
                print(message)
                self.messages.removeLast() // Remove the loading message
                loadingMessage.text = message
                loadingMessage.isLoading = false
            }
        }
    }
}


struct ChatBotView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var currentMessage: String = ""
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text("WhisperBot")
                    .font(.system(size: 30, weight: .bold))
                Spacer()
            }
            .padding()
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    ImageIcon(imageName: "person.fill")
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                } else {
                                    ImageIcon(imageName: "bubble.left.fill")
                                    Text(message.isLoading ? "..." : message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                
                Button(action: {
                    viewModel.sendMessage(currentMessage)
                    currentMessage = ""
                }) {
                    ImageIcon(imageName: "paperplane.fill", cornerSize: 8)
                }
                .padding(.trailing)
                .disabled(currentMessage.isEmpty)
            }
            .padding()
        }
    }
}
#Preview {
    ChatBotView()
}
