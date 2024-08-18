//
//  SpeakerView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-17.
//

import SwiftUI
import Speech
import AVFoundation

struct SpeakerView: View {
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var translatedText = ""
    
    var body: some View {
        VStack {
            Text("Speak in English")
                .font(.largeTitle)
                .padding()
            
            Text(recognizedText)
                .font(.title)
                .padding()
            
            Text("Translation (Spanish):")
                .font(.headline)
                .padding()
            
            Text(translatedText)
                .font(.title)
                .padding()
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    // MARK: - Speech Recognition
    func startRecording() {
        isRecording = true
        
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        let request = SFSpeechAudioBufferRecognitionRequest()
        
        let audioEngine = AVAudioEngine()
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try! audioEngine.start()
        
        recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                recognizedText = result.bestTranscription.formattedString
                translateText(text: recognizedText)
            }
            
            if error != nil || result?.isFinal == true {
                audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                isRecording = false
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
    }
    
    // MARK: - Translation
    func translateText(text: String) {
        let apiKey = "YOUR_GOOGLE_TRANSLATE_API_KEY"
        let urlStr = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)&q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&target=es&source=en"
        let url = URL(string: urlStr)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let translations = jsonResponse["data"] as? [String: Any],
                   let translation = translations["translations"] as? [[String: Any]],
                   let translatedText = translation.first?["translatedText"] as? String {
                    DispatchQueue.main.async {
                        self.translatedText = translatedText
                        speakText(text: translatedText)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Text-to-Speech
    func speakText(text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        synthesizer.speak(utterance)
    }
}

#Preview {
    SpeakerView()
}
