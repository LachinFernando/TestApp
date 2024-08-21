//
//  CSVFileView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-18.
//

import SwiftUI
import Alamofire
import UniformTypeIdentifiers
import MobileCoreServices

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.selectedFileURL = url
            }
        }
    }
}


struct CSVFileView: View {
    @State private var selectedFileURL: URL?
    @State private var isShowingDocumentPicker = false
    @State private var uploadStatus = ""
    
    var body: some View {
        VStack {
            Button("Select CSV File") {
                isShowingDocumentPicker.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .sheet(isPresented: $isShowingDocumentPicker) {
                DocumentPicker(selectedFileURL: $selectedFileURL)
            }
            
            if let fileURL = selectedFileURL {
                Text("Selected File: \(fileURL.lastPathComponent)")
                    .padding()
                
                Button("Upload File") {
                    uploadCSVFile(fileURL: fileURL)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Text(uploadStatus)
                .padding()
        }
    }
    
    func uploadCSVFile(fileURL: URL) {
        guard let fileData = try? Data(contentsOf: fileURL) else {
            uploadStatus = "Failed to read file"
            return
        }
        
        let url = "https://yourapi.com/upload"  // Replace with your API URL
        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream"
        ]
        
        AF.upload(fileData, to: url, method: .post, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        uploadStatus = "Upload successful"
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        uploadStatus = "Upload failed: \(error.localizedDescription)"
                    }
                }
            }
    }
}


#Preview {
    CSVFileView()
}
