//
//  AsyncView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-09-10.
//

import SwiftUI
import Alamofire


//// Struct for the Data section in the response
//struct ResponseData: Decodable {
//    let questions: [String]
//}
//
//// Struct for the overall API response
//struct ApiResponse: Decodable {
//    let statusCode: Int
//    let data: ResponseData
//    let error: [String]
//}
//
//// Service to handle API requests
//class ApiService {
//    // Async function to perform the API request
//    func fetchData(from url: String, payload createPayload: [String: Any]) async throws -> ApiResponse {
//        return try await withCheckedThrowingContinuation { continuation in
//            AF.request(url, method: .post, parameters: createPayload,encoding: JSONEncoding.default).validate().responseDecodable(of: ApiResponse.self) { response in
//                switch response.result {
//                case .success(let data):
//                    print(data)
//                    continuation.resume(returning: data)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//}


struct AsyncView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            if viewModel.questions != [] {
                List(viewModel.questions, id: \.self) { question in
                    Text(question)
                }
            } else if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            }
            
            Button("Fetch Data") {
                viewModel.loadData()
            }
        }
        .padding()
    }
}

// ViewModel to handle data fetching and background task management
class ViewModel: ObservableObject {
    @Published var questions: [String] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiService = ApiService()
    
    func loadData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                // URL of the API endpoint
                let url = "https://1ibs5roq6f.execute-api.us-east-1.amazonaws.com/translaterx/questionGenerator"
                let createPayload: [String: Any] = [
                    "httpMethod":"POST",
                    "body": [
                        "symptoms": "My head is like burning time to time and have a vomiting feeling."
                    ]
                ]
                // Replace with your actual URL
                let responseData = try await apiService.fetchData(from: url, payload: createPayload)
                DispatchQueue.main.async {
                    print(responseData)
                    self.questions = responseData.data.questions
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}


#Preview {
    AsyncView()
}
