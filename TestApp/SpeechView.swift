//
// SpeechView.swift
// TestApp
//
// Created by Lachin Fernando on 2024-09-06.
//
import SwiftUI
import Speech
struct SpeechView: View {
  let synthesizer = AVSpeechSynthesizer()
  var body: some View {
    Button("Speak"){
      translateAndSpeak()
    }
    .padding()
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(8)
  }
  func translateAndSpeak() {
    // Translate transcriptionText from English to Spanish using an external translation API
    // let translatedText = translateToSpanish(text: transcriptionText)
    let translatedText: String = "Hola, mundo."
    // Use AVSpeechSynthesizer to speak the translated text
    let utterance = AVSpeechUtterance(string: translatedText)
    // “es-ES” for spanish
    utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    utterance.pitchMultiplier = 1.0
    utterance.volume = 1.0
    synthesizer.speak(utterance)
  }
}
#Preview {
  SpeechView()
}
