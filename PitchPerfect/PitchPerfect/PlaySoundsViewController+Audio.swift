//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright Â© 2016 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: Alerts
    // Struct of alert messages. This is a convenient way to have all of the alert
    // messages in a single place. This is a good practice to follow if you have
    // other static items that you want to use throughout your app.
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState (raw values correspond to sender tags)
    // Enumeration used by the configureUI function to set the states depending on whether
    // or not we're playing audio.
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    // This function is where we try to load the audio recording file passed in from the
    // RecordSoundsViewController. If loading the audio file fails, we present an alert
    // message to the user.
    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    // Main function in the extension which carries out playing audio. There are optional
    // parameters in this function prototype. The code = nil that comes after the rate
    // parameter means that rate is an optional parameter in the function. If rate isn't
    // passed into the function, it will be assined to the default value of nil.
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio. Create an AVAudioPlayerNode.
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        // Check if the rate of pitch parameters were passed in, since they are optional.
        
        let changeRatePitchNode = AVAudioUnitTimePitch()
        // If the pitch parameter isn't nil, then execute the code inside the if statement.
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        // If the rate parameter isn't nil, then execute the code inside the if. Otherwise,
        // skip it.
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        // Add echo and reverb nodes only if the parameters were passed in for echo and
        // reverb and set to True.
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        // This if block wires up the connections of the echo and reverb nodes based on the
        // the cases mentioned on line 79.
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        // Tell the audio player to stop playing any current audio and schedule
        // a recorded audio for playback. This ensures that the recorded audio is in memory
        // and ready to be played.
        audioPlayerNode.stop()
        
        // This is a trailing closure. Closures are functions or chunks of code that
        // can be passed around like variables. This function takes a closure that runs
        // when the audio file is ready to start playing. The code in this closure sets a timer to fire when the audio is done playing that resets the buttons into the not playing state.
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    // This function handles stopping the playback recording.
    @objc func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        // We don't want the timer that we created in the scheduleFile trailing closure to fire when we're stopping here. This if statement cancels the timer from firing.
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    // This is a helper function to connect a set of audio nodes together in the audio engine. This cuts down on the duplication of code in the playSounds function.
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions
    // Helper function in charge of enabling and disabling the playback buttons and the stop button.
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }
    
    // Another helper function used by configuireUI function which will either enable or disable all of the playback buttons depending on which boolean values were passed in.
    func setPlayButtonsEnabled(_ enabled: Bool) {
        slowButton.isEnabled = enabled
        highPitchButton.isEnabled = enabled
        fastButton.isEnabled = enabled
        lowPitchButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }
    
    // This function will display an alert message to the user using UIAlertController if something goes wrong.
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
