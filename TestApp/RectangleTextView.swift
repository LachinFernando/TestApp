//
//  RectangleTextView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-21.
//

import SwiftUI
import AVFoundation
import Alamofire
import SwiftyJSON
import Speech


class AudioHandler : ObservableObject {
    @Published var canRecord = false
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var audioFileURL : URL?
    @Published var transcriptContent: String? = nil
    @Published var translatedContent: String? = nil
    @Published var isExpanded: Bool = true
    @Published var toggleLanguage: Bool = true
    @Published var processStarted: Bool = false
    private var audioPlayer : AVAudioPlayer?
    private var audioRecorder : AVAudioRecorder?
    private var transcript: String? = nil
    private var transcriptEndpoint: String = "https://1ibs5roq6f.execute-api.us-east-1.amazonaws.com/translaterx/transcript-ai"
    
    
    init() {
        //ask for record permission. IMPORTANT: Make sure you've set `NSMicrophoneUsageDescription` in your Info.plist
        AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.canRecord = true
                } else {
                    self.canRecord = false
                }
            }
        }
    }
    
    //the URL where the recording file will be stored
    private var recordingURL : URL {
        getDocumentsDirectory().appendingPathComponent("recording.wav")
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func recordFile() {
        do {
            //set the audio session so we can record
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print(error)
            self.canRecord = false
            fatalError()
        }
        //this describes the format the that the file will be recorded in
        let settings = [
            // kAudioFormatLinearPCM - for .wav
            // kAudioFormatMPEG4AAC - for .caf and .mpfa
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            //create the recorder, pointing towards the URL from above
            audioRecorder = try AVAudioRecorder(url: recordingURL,
                                                settings: settings)
            audioRecorder?.record() //start the recording
            isRecording = true
        } catch {
            print(error)
            isRecording = false
        }
    }
    
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        audioFileURL = recordingURL
        self.isExpanded = false
        self.processStarted = true
        self.getTranscriptContents()
        
    }
    
    
    func playRecordedFile() {
        guard let audioFileURL = audioFileURL else {
            return
        }
        do {
            //create a player, again pointing towards the same URL
            self.audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            self.audioPlayer?.play()
        } catch {
            print(error)
        }
    }
    
    func translateAndSpeak() {
        // Translate transcriptionText from English to Spanish using an external translation API
        // let translatedText = translateToSpanish(text: transcriptionText)
        
        let translatedText: String = "Lachin"
        // Use AVSpeechSynthesizer to speak the translated text
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: translatedText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
    
    
    func languageToggler(){
        self.toggleLanguage = !toggleLanguage
    }
    
    
    func languageController() {
        self.transcriptContent = nil
        self.translatedContent = nil
        self.processStarted = false
    }
    
    
    func getTranscriptContents() {
        isProcessing = true
        guard let audioFileURL else {
            return
        }
        
        // Load the .wav file from the bundle or from a file path
        print(audioFileURL.path)
        if let filePath = Bundle.main.path(forResource: "rec_seg", ofType: "wav") {
            print(filePath)
            do {
                let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                
                // Step 2: Convert the Data to Base64 encoded string
                let base64String = fileData.base64EncodedString()
                
                // Print or use the Base64 string
                let createPayload: [String: Any] = [
                    "httpMethod":"POST",
                    "body": [
                        "audio": base64String
                    ]
                ]
                // send the p[ost request
                AF.request(
                    transcriptEndpoint,
                    method: .post,
                    parameters: createPayload,
                    encoding: JSONEncoding.default
                    
                )
                .responseJSON{
                    response in
                    switch response.result {
                    case .success(let value):
                        let json  = JSON(value)
                        let transcriptAudioContent = json["data"]["transcript"].stringValue
                        self.transcriptContent = transcriptAudioContent
                        let translatedAudioContent = json["data"]["translate"].stringValue
                        self.translatedContent = translatedAudioContent
                        self.isProcessing = false
                    case .failure(let error):
                        let message = "Error: \(error.localizedDescription)"
                        self.transcriptContent = "Transcript Generation Failed"
                        self.isProcessing = false
                    }
                }
                
            } catch {
                print("Error reading file: \(error.localizedDescription)")
                return
            }
        } else {
            print("File not found")
            return
        }
    }
}


struct RectangleTextView: View {
    private let windowSize: CGFloat = 500
    private var guides: [String] = [
        "Use the language button to toggle between languages.",
        "E stands for English and S stands for Spanish.",
        "Use respective mic button to speak up with the language you selected.",
        "After generating script and translated script, use clear button indicated by C to record another audio."
    ]
    @State private var isExpanded: Bool = true
    @StateObject private var audioManager = AudioHandler()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Image("translate")
                            .resizable()
                            .frame(maxWidth: 50, maxHeight: 50)
                            .scaledToFit()
                        Spacer()
                        Text("Translate.Ax")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    }
                    .padding()
                    // English View
                    VStack(alignment: .leading, spacing: 5) {
                        Text("English")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        if audioManager.isProcessing {
                            ProgressView("Getting Transcript")
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        } else {
                            if audioManager.transcriptContent != nil && audioManager.translatedContent != nil {
                                Text(audioManager.toggleLanguage ? audioManager.transcriptContent ?? "Error Getting the Transcript" : audioManager.translatedContent ?? "Error Getting the Translation")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding()
                            }
                        }
                        HStack {
                            Spacer()
                            if !audioManager.isRecording && audioManager.canRecord {
                                Button("", systemImage: "mic", action: {
                                    audioManager.recordFile()
                                })
                                .padding()
                                .foregroundColor(.black)
                                .disabled(audioManager.isProcessing || !audioManager.toggleLanguage)
                            } else {
                                Button("", systemImage: "stop.circle", action: {
                                    audioManager.stopRecording()
                                })
                                .padding()
                                .foregroundColor(.black)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 4)
                    )
                    // Spanish View
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Spanish")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        if audioManager.isProcessing {
                            ProgressView("Getting Transcript")
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        } else {
                            if audioManager.transcriptContent != nil && audioManager.translatedContent != nil {
                                Text(audioManager.toggleLanguage ? audioManager.translatedContent ?? "Error Getting the Translate" : audioManager.transcriptContent ?? "Error Getting the Transcript")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding()
                            }
                        }
                        HStack {
                            Spacer()
                            if !audioManager.isRecording && audioManager.canRecord {
                                Button("", systemImage: "mic", action: {
                                    audioManager.recordFile()
                                })
                                .padding()
                                .foregroundColor(.black)
                                .disabled(audioManager.isProcessing || audioManager.toggleLanguage)
                            } else {
                                Button("", systemImage: "stop.circle", action: {
                                    audioManager.stopRecording()
                                })
                                .padding()
                                .foregroundColor(.black)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 4)
                    )
                    // List View
                    VStack(alignment: .leading) {
                        Text("Instructions")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.black)
                            .padding()
                        ForEach(guides, id:\.self) {instructions in
                            Text(instructions)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                            Divider()
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 4)
                    )
                }
                .padding()
            }
            VStack {
                // Language toggle buttons
                HStack {
                    Spacer()
                    Circle()
                        .fill(.blue)
                        .padding()
                        .overlay(
                            Button(action: {
                                audioManager.languageToggler()
                            }) {
                                Text(audioManager.toggleLanguage ? "E" : "S")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                                .disabled(audioManager.processStarted)
                        )
                        .frame(width: 75, height: 75)
                }
                .padding()
                HStack {
                    Spacer()
                    Circle()
                        .fill(.blue)
                        .padding()
                        .overlay(
                            Button(action: {
                                audioManager.languageController()
                            }) {
                                Text("C")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                                .disabled(!audioManager.processStarted)
                        )
                        .frame(width: 75, height: 75)
                }
                .padding()
            }
        }
    }
}

#Preview {
    RectangleTextView()
}
