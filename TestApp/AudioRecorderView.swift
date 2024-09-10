//
//  AudioRecorderView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-18.
//

import SwiftUI
import AVFoundation
import Alamofire
import SwiftyJSON
import Speech


class AudioManager : ObservableObject {
    @Published var canRecord = false
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var audioFileURL : URL?
    @Published var transcriptContent: String? = nil
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
            print(recordingURL)
        } catch {
            print(error)
            isRecording = false
        }
    }
    
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        audioFileURL = recordingURL
        // call the API for the transcript
        
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

struct AudioRecorderView: View {
    
    @StateObject private var audioManager = AudioManager()
    
    var body: some View
    {
        VStack {
            if !audioManager.isRecording && audioManager.canRecord {
                Button("Record") {
                    audioManager.recordFile()
                }
            } else {
                Button("Stop") {
                    audioManager.stopRecording()
                }
            }
            Circle()
                .fill(audioManager.isRecording ? Color.red : Color.green)
                .frame(width: 50, height: 50)
                .animation(.easeInOut(duration: 0.5), value: audioManager.isRecording)
                .padding()
            if audioManager.audioFileURL != nil && !audioManager.isRecording {
                Button("Play") {
                    audioManager.translateAndSpeak()
                }
                Button("Convert") {
                    audioManager.getTranscriptContents()
                }
                if audioManager.isProcessing {
                    ProgressView("Getting Transcript")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    if audioManager.transcriptContent != nil {
                        Text(audioManager.transcriptContent ?? "Error Getting the Transcript")
                            .font(.system(size: 10))
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

#Preview {
    AudioRecorderView()
}
