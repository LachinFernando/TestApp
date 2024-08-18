//
//  AudioRecorderView.swift
//  TestApp
//
//  Created by Lachin Fernando on 2024-08-18.
//

import SwiftUI
import AVFoundation


class AudioManager : ObservableObject {
    @Published var canRecord = false
    @Published var isRecording = false
    @Published var audioFileURL : URL?
    private var audioPlayer : AVAudioPlayer?
    private var audioRecorder : AVAudioRecorder?
    
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
        getDocumentsDirectory().appendingPathComponent("recording.caf")
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
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
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
            
            if audioManager.audioFileURL != nil && !audioManager.isRecording {
                Button("Play") {
                    audioManager.playRecordedFile()
                }
            }
        }
    }
}

#Preview {
    AudioRecorderView()
}
