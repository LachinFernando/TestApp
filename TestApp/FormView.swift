//
//  FormView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-12.
//

import SwiftUI
import Alamofire
import SwiftyJSON
//import Alamofire

struct FormView: View {
    
    @State private var yearsSchool: Int? = nil
    @State private var height: Float? = nil
    @State private var countriesVisited: Int? = nil
    @State private var prediction: String = ""
    @State private var isSet: Bool = false
    @State private var warning: Bool = false
    @State private var responseMessage: String = ""
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
                .ignoresSafeArea()
            VStack {
                Text("Adult vs Child AI")
                    .font(.system(size: 40, weight: .bold))
                Spacer()
                VStack {
                    Text("Number of Years in Schhol")
                    TextField("Number of Years in Schhol", value: $yearsSchool, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Text("Height")
                    TextField("Your Height", value: $height, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Text("Number of Countries Visited")
                    TextField("Number of Countries Visited", value: $countriesVisited, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                }
                Button(action: fetchData){
                    Label("Get Predictions", systemImage: "arrow.up")
                }
                .buttonStyle(.borderedProminent)
                if isSet {
                    if warning {
                        Text("Warning Missing Data: \(prediction)")
                            .padding()
                    } else {
                        Text("Prediction: \(prediction)")
                            .padding()
                    }
                }
            }
            
        }
    }
    
    func fetchData() -> Void {
        if isSet {
            isSet = false
        }
        if warning {
            warning = false
        }
        // set the button view to true
        guard let yearsSchool else {
            prediction = "Years of School is missing"
            isSet = true
            warning = true
            return
        }
        
        guard let height else {
            prediction = "Height is missing"
            isSet = true
            warning = true
            return
        }
        
        guard let countriesVisited else {
            prediction = "Countried Visited is missing"
            isSet = true
            warning = true
            return
        }
        
        print(yearsSchool, height, countriesVisited)
        
        let url = "https://askai.aiclub.world/bf61576e-df1d-42fb-ba55-14ad1ade4cb3"
        
        let payload: [String: Any] = [
            "years_school": Float(yearsSchool),
            "height": Float(height),
            "num_countries": Int(countriesVisited)
        ]
        
        // send the p[ost request
        AF.request(
            url,
            method: .post,
            parameters: payload,
            encoding: JSONEncoding.default
            
        )
        .responseJSON {response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                guard let bodyString = json["body"].string else{
                    isSet = true
                    warning = true
                    prediction = "An issue has occured"
                    return
                }
                
                guard let bodyData = bodyString.data(using: .utf8) else {
                    isSet = true
                    warning = true
                    prediction = "An issue has occured"
                    return
                }
                
                let innerJson = JSON(bodyData)
                let predLabel = innerJson["predicted_label"].stringValue
                isSet = true
                prediction = predLabel
                
                //                if let bodyString = json["body"].string, let bodyData = bodyString.data(using: .utf8) {
                //                    // Parse the inner JSON string
                //                    do {
                //                        let innerJson = JSON(bodyData)
                //                        let predLabel = innerJson["predicted_label"].stringValue
                //                        prediction = predLabel
                //                    } catch {
                //                        debugPrint("Failed to parse the data")
                //                    }
                //                }
                
                //                if let statusCode = json["body"].string {
                //                    let predData = JSON(statusCode)
                //                    let predLabel = predData["predicted_label"].stringValue
                //                    debugPrint(predLabel)
                //                }
            case .failure(let error):
                responseMessage = "Error: \(error.localizedDescription)"
                print(responseMessage)
            }
        }
        
        
        
        // Define the URL
        //        guard let url = URL(string: "https://askai.aiclub.world/bf61576e-df1d-42fb-ba55-14ad1ade4cb3") else {
        //            print("Invalid URL")
        //            return
        //        }
        
        //        // Create the request
        //        var request = URLRequest(url: url)
        //        request.httpMethod = "POST"
        //
        //        // Define the data to be sent in the body
        //        let body: [String: Any] = [
        //            "years_school": Float(yearsSchool),
        //            "height": Float(height),
        //            "num_countries": Int(countriesVisited)
        //        ]
        //        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        //
        //        // Create the URLSession task
        //        URLSession.shared.dataTask(with: request) { data, response, error in
        //            // Handle errors
        //            if let error = error {
        //                print("Error: \(error)")
        //                return
        //            }
        //
        //            // Handle response data
        //            if let data = data {
        //                if let responseString = String(data: data, encoding: .utf8) {
        //                    DispatchQueue.main.async {
        //                        responseMessage = responseString
        //                        isSet = true
        //                    }
        //                }
        //            }
        //        }.resume()
        
        return
    }
}

#Preview {
    FormView()
}
